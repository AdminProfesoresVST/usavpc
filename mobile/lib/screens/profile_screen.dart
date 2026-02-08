import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/services/dashboard_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/providers/dashboard_provider.dart';
import 'package:mobile/models/dashboard_data.dart';
import 'package:mobile/models/user_document.dart'; // [FIX] Import DocumentProgress
import 'package:mobile/widgets/document_checklist.dart';
import 'package:mobile/widgets/cards/application_status_card.dart';
import 'package:mobile/providers/document_providers.dart';

// Helper Provider for Profile Data
final profileDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(dashboardRepositoryProvider).getProfileData();
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
    final dashboardAsync = ref.watch(dashboardProvider);
    
    // [FIX] Source of Truth Consistency
    // Instead of trusting the RPC provider (which might drift), we calculate progress
    // directly from the SAME list provider that feeds the DocumentChecklist below.
    // This ensures "0/8" appears in both places.
    final documentsAsync = ref.watch(ds160DocumentsWithStatusProvider);
    
    // Calculate synthetic progress from the list
    DocumentProgress? calculatedProgress;
    if (documentsAsync.hasValue) {
      final docs = documentsAsync.value!;
      final total = docs.length;
      final uploaded = docs.where((d) => d.isUploaded).length;
      final ocrComplete = docs.where((d) => d.isOcrComplete).length;
      final verified = docs.where((d) => d.isVerified).length;
      
      calculatedProgress = DocumentProgress(
        totalRequired: total,
        totalUploaded: uploaded,
        totalOcrComplete: ocrComplete,
        totalVerified: verified,
        progressPercentage: total > 0 ? uploaded / total : 0.0,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.profileTitle, style: AppTheme.h1WhiteBold),
        backgroundColor: AppTheme.navyPrimary,
        elevation: AppTheme.elevacionNula,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.inkInverse),
        actions: [], // [UX] Removed manual refresh button as per user feedback
      ),
      body: profileAsync.when(
        data: (data) => dashboardAsync.when(
          data: (dashboardData) => _buildBody(context, data, dashboardData, l10n, calculatedProgress),
           // If dashboard loads but profile is ready, we could show partial, but loading is safer
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary)),
          error: (e, _) => Center(child: Text(l10n.error(e.toString()))),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary)),
        error: (e, _) => Center(child: Text(l10n.error(e.toString()))),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> data, DashboardData dashboardData, dynamic l10n, DocumentProgress? docProgress) {
    final app = data['app'] as Map<String, dynamic>?;
    final formData = app?['form_data'] as Map<String, dynamic>?;
    final passportData = formData?['ocr_data'] ?? formData;
    final profile = data['profile'] as Map<String, dynamic>?;
    final email = data['email'] ?? l10n.defaultUser;

    final String name = (passportData?['given_name'] ?? l10n.guestLabel).toString().toUpperCase();
    final String surname = (passportData?['surname'] ?? '').toString().toUpperCase();
    final String fullName = '$name $surname'.trim();
    final String nationality = (passportData?['nationality'] ?? l10n.notAvailableShort).toString();
    final String passportNumber = (passportData?['passport_number'] ?? passportData?['document_number'] ?? l10n.notAvailableAndDash).toString();
    final String dob = (passportData?['birth_date'] ?? passportData?['date_of_birth'] ?? l10n.notAvailableAndDash).toString();

    final simulatorHistory = app?['simulator_history'] as List<dynamic>? ?? [];
    final simulatorScore = app?['simulator_score'] as int?;
    final passportImageUrl = app?['passport_image_url'] as String?;

    return SingleChildScrollView(
      padding: AppTheme.paddingCampo,
      child: Column(
        children: [
          // 1. Identity Card (Compact)
          _buildIdentityCard(context, l10n, fullName, nationality, passportNumber, dob, email),
          SizedBox(height: AppTheme.espacioEntreSecciones),

          // 2. Application Status (New Premium Card with Real Data)
          ApplicationStatusCard(
            status: dashboardData.status,
            progress: docProgress, // Pass real OCR progress
            lastEdited: dashboardData.lastEdited,
          ),
          SizedBox(height: AppTheme.espacioEntreSecciones),
          
          // 2.5 Document Checklist (Real progress based on uploaded docs)
          const DocumentChecklist(formType: 'DS160'),
          SizedBox(height: AppTheme.espacioEntreSecciones),

          // 3. Next Steps (Transplanted)
          Align(alignment: Alignment.centerLeft, child: Text(l10n.nextSteps, style: AppTheme.h2NavyBold)),
          SizedBox(height: AppTheme.espacioEntreCampos),
          ...dashboardData.nextSteps.map((step) => _buildActionTile(
            context,
            icon: _getIcon(step.iconCode),
            title: step.title,
            subtitle: step.subtitle,
            iconCode: step.iconCode,
          )),
          
          SizedBox(height: AppTheme.espacioEntreSecciones),
          Divider(color: AppTheme.dividerGrey),
          SizedBox(height: AppTheme.espacioEntreSecciones),

          // 4. Expediente Digital
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
          _buildMenuItem(Icons.language_outlined, l10n.languageSettingTitle, l10n.languageLabel,
              () => _showLanguageSelector(context)),
          _buildMenuItem(Icons.help_outline, l10n.helpOption, l10n.supportEmail,
              () => _copySupportEmail(context)),
          _buildMenuItem(Icons.description_outlined, l10n.legal, l10n.termsAndPrivacy,
              () => _showLegalDocs(context)),

          SizedBox(height: AppTheme.espacioEntreSecciones),

          // Sign Out Button (Navy, not Red)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, size: AppTheme.iconoMini),
              label: Text(l10n.logoutOption),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.navyPrimary,
                side: const BorderSide(color: AppTheme.navyPrimary),
                padding: AppTheme.paddingListItem,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
              ),
            ),
          ),
          SizedBox(height: AppTheme.espacioEntreCards),
        ],
      ),
    );
  }




  IconData _getIcon(String code) {
    switch (code) {
      case 'upload_file': return Icons.upload_file;
      case 'payment': return Icons.payment;
      case 'assessment': return Icons.assessment;
      case 'start': return Icons.play_arrow;
      case 'calculator': return Icons.calculate;
      case 'travel_ban': return Icons.public_off;
      default: return Icons.arrow_forward;
    }
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String subtitle,
    required String iconCode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.espacioEntreGrupos),
      decoration: AppTheme.standardCardDecoration,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
        leading: CircleAvatar(
          backgroundColor: AppTheme.navyPrimary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppTheme.navyPrimary),
        ),
        title: Text(title, style: AppTheme.h2NavyBold),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _handleDashboardNavigation(context, iconCode),
      ),
    );
  }

  void _handleDashboardNavigation(BuildContext context, String iconCode) {
    switch (iconCode) {
      case 'payment_monthly':
        GoRouter.of(context).push('/services/payment?plan=monthly');
        break;
      case 'payment_yearly':
        GoRouter.of(context).push('/services/payment?plan=yearly');
        break;
      case 'upload_file':
        GoRouter.of(context).push('/kyc'); // Verify route
        break;
      case 'payment':
        GoRouter.of(context).push('/services/payment');
        break;
      case 'assessment':
        GoRouter.of(context).push('/services/risk-audit');
        break;
      case 'start':
        GoRouter.of(context).push('/services/visa/select');
        break;
      case 'calculator':
        GoRouter.of(context).push('/services/cost/calculate');
        break;
      case 'travel_ban':
        GoRouter.of(context).push('/services/travel-ban/check');
        break;
      default:
        // do nothing or show toast
        break;
    }
  }

  // ============== COMPACT IDENTITY CARD ==============
  Widget _buildIdentityCard(BuildContext context, dynamic l10n, String name, String nat, String passport, String dob, String email) {
    return Container(
      width: double.infinity,
      padding: AppTheme.paddingEstandar,
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
                radius: AppTheme.iconoGrande / 2,
                backgroundColor: AppTheme.inkInverse,
                child: Text(
                  name.isNotEmpty ? name[0] : 'U',
                  style: AppTheme.h2NavyBold,
                ),
              ),
              const SizedBox(width: AppTheme.espacioEntreGrupos),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTheme.bodyWhiteBold),
                    const SizedBox(height: AppTheme.espacioEntreLabelInput),
                    Text(email, style: AppTheme.captionWhiteRegular),
                    SizedBox(height: AppTheme.espacioEntreLabelInput),
                    Container(
                      padding: AppTheme.paddingBadge,
                      decoration: BoxDecoration(
                        color: AppTheme.inkInverse24,
                        borderRadius: AppTheme.smallRadius,
                      ),
                      child: Text(l10n.verified, style: AppTheme.captionWhiteBold.copyWith(fontSize: AppTheme.fuenteMini)),
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
        Text(label, style: AppTheme.captionWhiteBold.copyWith(fontSize: AppTheme.fuenteMini, color: AppTheme.inkInverse70)),
        const SizedBox(height: 2),
        Text(value, style: AppTheme.captionWhiteRegular.copyWith(fontSize: AppTheme.fuenteCaption)),
      ],
    );
  }

  // ============== MENU ITEM (COMPACT) ==============
  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {Widget? trailing}) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.espacioEntreCampos),
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        borderRadius: AppTheme.buttonRadius,
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
        contentPadding: AppTheme.paddingHorizontal,
        leading: Icon(icon, color: AppTheme.navyPrimary, size: AppTheme.iconoEnTarjeta),
        title: Text(title, style: AppTheme.labelBold.copyWith(fontSize: AppTheme.fuenteLabel)),
        subtitle: Text(subtitle, style: AppTheme.captionGreyRegular.copyWith(fontSize: AppTheme.fuenteCaption)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.dividerGrey, size: AppTheme.iconoMini),
      ),
    );
  }

  Widget _buildBiometricsSwitch(dynamic l10n) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.espacioEntreCampos),
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
        contentPadding: AppTheme.paddingPequeno,
        secondary: Icon(Icons.fingerprint, color: AppTheme.navyPrimary, size: AppTheme.iconoEnTarjeta),
        title: Text(l10n.biometricsLabel, style: AppTheme.labelBold.copyWith(fontSize: AppTheme.fuenteLabel)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: AppTheme.radiusBurbuja)),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: AppTheme.paddingCompacto,
              width: 32, height: 4,
              decoration: BoxDecoration(color: AppTheme.dividerGrey, borderRadius: AppTheme.smallRadius),
            ),
            // Title
            Padding(
              padding: AppTheme.paddingCampo,
              child: Text(title, style: AppTheme.h2NavyBold),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: AppTheme.paddingEstandar,
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
                  padding: AppTheme.paddingPequeno,
                  margin: EdgeInsets.only(bottom: AppTheme.espacioEntreGrupos),
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
              final messenger = ScaffoldMessenger.of(context);
              try {
                await supabase.auth.resetPasswordForEmail(email);
                if (mounted) messenger.showSnackBar(SnackBar(content: Text(l10n.passwordResetSent(email))));
              } catch (e) {
                if (mounted) messenger.showSnackBar(SnackBar(content: Text(l10n.error(e.toString()))));
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
      margin: EdgeInsets.only(bottom: AppTheme.espacioEntreCampos),
      padding: AppTheme.paddingPequeno,
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
      trailing: selected ? const Icon(Icons.check_circle, color: AppTheme.navyPrimary, size: AppTheme.iconoMini) : null,
    );
  }

  void _copySupportEmail(BuildContext context) {
    final l10n = context.l10n;
    Clipboard.setData(ClipboardData(text: l10n.supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emailCopied)));
  }

  Future<void> _handleLogout(BuildContext context) async {
    final router = GoRouter.of(context);
    await ref.read(authProvider.notifier).signOut();
    if (mounted) router.go('/services');
  }
}
