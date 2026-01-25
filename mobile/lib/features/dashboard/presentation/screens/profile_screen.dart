import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper Provider for Profile Data
final profileDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('No user');

  final app = await supabase
      .from('applications')
      .select('form_data, status, passport_image_url, simulator_history, simulator_score')
      .eq('user_id', userId)
      .maybeSingle();

  final profile = await supabase
      .from('profiles')
      .select('id, email, phone, role')
      .eq('id', userId)
      .maybeSingle();

  return {
    'app': app,
    'profile': profile,
    'email': supabase.auth.currentUser?.email,
  };
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricsPreference();
  }

  Future<void> _loadBiometricsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', value);
    setState(() => _biometricsEnabled = value);
    if (mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? l10n.biometricsEnabled : l10n.biometricsDisabled)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(profileDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.profileTitle, style: AppTheme.h1WhiteBold),
        backgroundColor: AppTheme.navyPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.inkInverse),
      ),
      body: profileAsync.when(
        data: (data) => _buildBody(context, data, l10n),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary)),
        error: (e, _) => Center(child: Text(l10n.error(e.toString()))),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> data, dynamic l10n) {
    final app = data['app'] as Map<String, dynamic>?;
    final formData = app?['form_data'] as Map<String, dynamic>?;
    final passportData = formData?['ocr_data'] ?? formData;
    final profile = data['profile'] as Map<String, dynamic>?;
    final email = data['email'] ?? 'User';

    final String name = (passportData?['given_name'] ?? 'Guest').toString().toUpperCase();
    final String surname = (passportData?['surname'] ?? '').toString().toUpperCase();
    final String fullName = '$name $surname'.trim();
    final String nationality = (passportData?['nationality'] ?? 'N/A').toString();
    final String passportNumber = (passportData?['passport_number'] ?? passportData?['document_number'] ?? '---').toString();
    final String dob = (passportData?['birth_date'] ?? passportData?['date_of_birth'] ?? '---').toString();

    final simulatorHistory = app?['simulator_history'] as List<dynamic>? ?? [];
    final simulatorScore = app?['simulator_score'] as int?;
    final passportImageUrl = app?['passport_image_url'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Identity Card (Compact)
          _buildIdentityCard(context, l10n, fullName, nationality, passportNumber, dob, email),
          SizedBox(height: AppTheme.espacioEntreSecciones),

          // Expediente Digital
          _buildSectionHeader(l10n.digitalFile),
          SizedBox(height: AppTheme.espacioEntreCampos),
          _buildMenuItem(Icons.assignment_outlined, l10n.ds160Responses, 
              formData != null ? l10n.fieldsCount(formData.keys.length) : l10n.noData,
              () => _showDS160Data(context, formData)),
          _buildMenuItem(Icons.folder_outlined, l10n.myDocuments, 
              passportImageUrl != null ? l10n.documentCount(1) : l10n.noDocuments,
              () => _showDocuments(context, passportImageUrl),
              trailing: passportImageUrl != null ? const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 14) : null),
          _buildMenuItem(Icons.history_outlined, l10n.simulatorHistory, 
              simulatorHistory.isNotEmpty ? l10n.sessionsCount(simulatorHistory.length) : l10n.noSessions,
              () => _showSimulatorHistory(context, simulatorHistory, simulatorScore)),

          SizedBox(height: AppTheme.espacioEntreSecciones),

          // Cuenta
          _buildSectionHeader(l10n.accountSection),
          SizedBox(height: AppTheme.espacioEntreCampos),
          _buildMenuItem(Icons.person_outline, l10n.basicInfo, email,
              () => _showBasicInfo(context, profile, email)),

          SizedBox(height: AppTheme.espacioEntreSecciones),

          // Seguridad
          _buildSectionHeader(l10n.securitySection),
          SizedBox(height: AppTheme.espacioEntreCampos),
          _buildMenuItem(Icons.lock_outline, l10n.changePassword, l10n.updateAccess,
              () => _handlePasswordReset(context)),
          _buildBiometricsSwitch(l10n),

          SizedBox(height: AppTheme.espacioEntreSecciones),

          // Configuración
          _buildSectionHeader(l10n.settingsOption),
          SizedBox(height: AppTheme.espacioEntreCampos),
          _buildMenuItem(Icons.language_outlined, l10n.languageSettingTitle, "ES / EN",
              () => _showLanguageSelector(context)),
          _buildMenuItem(Icons.help_outline, l10n.helpOption, "soporte@usavpc.org",
              () => _copySupportEmail(context)),
          _buildMenuItem(Icons.description_outlined, l10n.legal, l10n.termsAndPrivacy,
              () => _showLegalDocs(context)),

          SizedBox(height: AppTheme.espacioEntreSecciones),

          // Sign Out Button (Navy, not Red)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: Text(l10n.logoutOption),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.navyPrimary,
                side: const BorderSide(color: AppTheme.navyPrimary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
              ),
            ),
          ),
          SizedBox(height: AppTheme.espacioEntreCards),
        ],
      ),
    );
  }

  // ============== COMPACT IDENTITY CARD ==============
  Widget _buildIdentityCard(BuildContext context, dynamic l10n, String name, String nat, String passport, String dob, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary,
        borderRadius: AppTheme.inputRadius,
        image: const DecorationImage(
          image: AssetImage('assets/images/logo.png'),
          opacity: 0.08,
          alignment: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.inkInverse,
                child: Text(
                  name.isNotEmpty ? name[0] : 'U',
                  style: AppTheme.h2NavyBold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTheme.bodyWhiteBold),
                    const SizedBox(height: 2),
                    Text(email, style: AppTheme.captionWhiteRegular),
                    SizedBox(height: AppTheme.espacioEntreLabelInput),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.inkInverse24,
                        borderRadius: AppTheme.smallRadius,
                      ),
                      child: Text(l10n.verified, style: AppTheme.captionWhiteBold.copyWith(fontSize: 9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.espacioEntreGrupos),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIdField(l10n.passport, passport),
              _buildIdField(l10n.nationality, nat),
              _buildIdField(l10n.birthDate, dob),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.captionWhiteBold.copyWith(fontSize: 9, color: AppTheme.inkInverse70)),
        const SizedBox(height: 2),
        Text(value, style: AppTheme.captionWhiteRegular.copyWith(fontSize: AppTheme.fuenteCaption)),
      ],
    );
  }

  // ============== MENU ITEM (COMPACT) ==============
  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        borderRadius: AppTheme.buttonRadius,
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(icon, color: AppTheme.navyPrimary, size: AppTheme.iconoEnTarjeta),
        title: Text(title, style: AppTheme.labelBold.copyWith(fontSize: 13)),
        subtitle: Text(subtitle, style: AppTheme.captionGreyRegular.copyWith(fontSize: AppTheme.fuenteCaption)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.dividerGrey, size: 18),
      ),
    );
  }

  Widget _buildBiometricsSwitch(dynamic l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        borderRadius: AppTheme.buttonRadius,
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: SwitchListTile(
        dense: true,
        value: _biometricsEnabled,
        onChanged: _toggleBiometrics,
        activeTrackColor: AppTheme.navyPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        secondary: Icon(Icons.fingerprint, color: AppTheme.navyPrimary, size: AppTheme.iconoEnTarjeta),
        title: Text(l10n.biometricsLabel, style: AppTheme.labelBold.copyWith(fontSize: 13)),
        subtitle: Text(_biometricsEnabled ? l10n.activated : l10n.deactivated, style: AppTheme.captionGreyRegular.copyWith(fontSize: AppTheme.fuenteCaption)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: AppTheme.captionGreyBold.copyWith(letterSpacing: 1),
      ),
    );
  }

  // ============== UNIFIED BOTTOMSHEET DESIGN ==============
  void _showBottomSheet(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.inkInverse,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 32, height: 4,
              decoration: BoxDecoration(color: AppTheme.dividerGrey, borderRadius: AppTheme.smallRadius),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(title, style: AppTheme.h2NavyBold),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDS160Data(BuildContext context, Map<String, dynamic>? formData) {
    final l10n = context.l10n;
    if (formData == null || formData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noFormData)));
      return;
    }
    _showBottomSheet(context, l10n.ds160Data, Column(
      children: formData.entries.map((e) => _buildInfoRow(e.key.replaceAll('_', ' '), e.value.toString())).toList(),
    ));
  }

  void _showDocuments(BuildContext context, String? passportUrl) {
    final l10n = context.l10n;
    if (passportUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noDocuments)));
      return;
    }
    _showBottomSheet(context, l10n.myDocuments, Column(
      children: [
        ClipRRect(
          borderRadius: AppTheme.buttonRadius,
          child: Image.network(passportUrl, height: 180, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 180, color: AppTheme.backgroundGrey, child: const Center(child: Icon(Icons.broken_image)))),
        ),
        SizedBox(height: AppTheme.espacioEntreGrupos),
        Text(l10n.scannedPassport, style: AppTheme.labelBold),
      ],
    ));
  }

  void _showSimulatorHistory(BuildContext context, List<dynamic> history, int? score) {
    final l10n = context.l10n;
    _showBottomSheet(context, l10n.simulatorHistory, 
      history.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: AppTheme.iconoGrande, color: AppTheme.dividerGrey),
              SizedBox(height: AppTheme.espacioEntreGrupos),
              Text(l10n.noPracticeSessions, style: AppTheme.captionGreyRegular),
              SizedBox(height: AppTheme.espacioEntreSecciones),
              ElevatedButton(
                onPressed: () { Navigator.pop(context); context.push('/simulator/chat'); },
                child: Text(l10n.startSimulation),
              ),
            ],
          )
        : Column(
            children: [
              if (score != null) 
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: AppTheme.softBlue, borderRadius: AppTheme.buttonRadius),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${l10n.currentScore}: ', style: AppTheme.labelBold),
                      Text('$score%', style: AppTheme.h2NavyBold),
                    ],
                  ),
                ),
              ...history.asMap().entries.map((entry) => _buildInfoRow(l10n.sessionNumber(entry.key + 1), entry.value.toString())),
            ],
          ),
    );
  }

  void _showBasicInfo(BuildContext context, Map<String, dynamic>? profile, String email) {
    final l10n = context.l10n;
    _showBottomSheet(context, l10n.accountInfo, Column(
      children: [
        _buildInfoRow(l10n.email, email),
        _buildInfoRow(l10n.phone, profile?['phone']?.toString() ?? l10n.notRegistered),
        _buildInfoRow(l10n.role, profile?['role']?.toString() ?? 'client'),
      ],
    ));
  }

  Future<void> _handlePasswordReset(BuildContext context) async {
    final l10n = context.l10n;
    final supabase = ref.read(supabaseClientProvider);
    final email = supabase.auth.currentUser?.email;
    if (email == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.changePassword, style: AppTheme.h2NavyBold),
        content: Text(l10n.passwordResetDialogContent(email)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await supabase.auth.resetPasswordForEmail(email);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordResetSent(email))));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.error(e.toString()))));
              }
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = context.l10n;
    _showBottomSheet(context, l10n.selectLanguage, Column(
      children: [
        _buildOptionTile(l10n.spanishLanguage, true, () { Navigator.pop(context); }),
        _buildOptionTile(l10n.englishLanguage, false, () { Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.languageChangeRequiresRestart))); }),
      ],
    ));
  }

  void _showLegalDocs(BuildContext context) {
    final l10n = context.l10n;
    _showBottomSheet(context, l10n.legalDocuments, Column(
      children: [
        _buildMenuItem(Icons.description_outlined, l10n.termsOfService, l10n.viewDocument, () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.openingTerms)));
        }),
        _buildMenuItem(Icons.privacy_tip_outlined, l10n.privacyPolicy, l10n.viewDocument, () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.openingPrivacy)));
        }),
      ],
    ));
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: AppTheme.smallRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: AppTheme.captionGreyBold.copyWith(fontSize: AppTheme.fuenteCaption)),
          Flexible(child: Text(value, style: AppTheme.labelRegular.copyWith(fontSize: AppTheme.fuenteLabel), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, bool selected, VoidCallback onTap) {
    return ListTile(
      dense: true,
      onTap: onTap,
      title: Text(title, style: AppTheme.labelRegular),
      trailing: selected ? const Icon(Icons.check_circle, color: AppTheme.navyPrimary, size: 18) : null,
    );
  }

  void _copySupportEmail(BuildContext context) {
    final l10n = context.l10n;
    Clipboard.setData(const ClipboardData(text: 'soporte@usavpc.org'));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emailCopied)));
  }

  Future<void> _handleLogout(BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    if (mounted) context.go('/services');
  }
}
