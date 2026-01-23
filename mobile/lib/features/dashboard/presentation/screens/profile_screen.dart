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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? "Biometría activada" : "Biometría desactivada")),
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
        iconTheme: const IconThemeData(color: Colors.white),
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
          _buildIdentityCard(context, fullName, nationality, passportNumber, dob, email),
          const SizedBox(height: 16),

          // Expediente Digital
          _buildSectionHeader("Expediente Digital"),
          const SizedBox(height: 8),
          _buildMenuItem(Icons.assignment_outlined, "Respuestas DS-160", 
              formData != null ? "${formData.keys.length} campos" : "Sin datos",
              () => _showDS160Data(context, formData)),
          _buildMenuItem(Icons.folder_outlined, "Mis Documentos", 
              passportImageUrl != null ? "1 Documento" : "Sin documentos",
              () => _showDocuments(context, passportImageUrl),
              trailing: passportImageUrl != null ? const Icon(Icons.check_circle, color: Colors.green, size: 14) : null),
          _buildMenuItem(Icons.history_outlined, "Historial de Simulaciones", 
              simulatorHistory.isNotEmpty ? "${simulatorHistory.length} sesiones" : "Sin sesiones",
              () => _showSimulatorHistory(context, simulatorHistory, simulatorScore)),

          const SizedBox(height: 16),

          // Cuenta
          _buildSectionHeader("Cuenta"),
          const SizedBox(height: 8),
          _buildMenuItem(Icons.person_outline, "Información Básica", email,
              () => _showBasicInfo(context, profile, email)),

          const SizedBox(height: 16),

          // Seguridad
          _buildSectionHeader("Seguridad"),
          const SizedBox(height: 8),
          _buildMenuItem(Icons.lock_outline, "Cambiar Contraseña", "Actualizar acceso",
              () => _handlePasswordReset(context)),
          _buildBiometricsSwitch(),

          const SizedBox(height: 16),

          // Configuración
          _buildSectionHeader(l10n.settingsOption),
          const SizedBox(height: 8),
          _buildMenuItem(Icons.language_outlined, l10n.languageSettingTitle, "ES / EN",
              () => _showLanguageSelector(context)),
          _buildMenuItem(Icons.help_outline, l10n.helpOption, "soporte@usavpc.org",
              () => _copySupportEmail(context)),
          _buildMenuItem(Icons.description_outlined, "Legal", "Términos y privacidad",
              () => _showLegalDocs(context)),

          const SizedBox(height: 16),

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ============== COMPACT IDENTITY CARD ==============
  Widget _buildIdentityCard(BuildContext context, String name, String nat, String passport, String dob, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary,
        borderRadius: BorderRadius.circular(12),
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
                backgroundColor: Colors.white,
                child: Text(
                  name.isNotEmpty ? name[0] : 'U',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(email, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("VERIFIED", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIdField("PASAPORTE", passport),
              _buildIdField("NACIONALIDAD", nat),
              _buildIdField("NACIMIENTO", dob),
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
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ============== MENU ITEM (COMPACT) ==============
  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(icon, color: AppTheme.navyPrimary, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkPrimary)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.inkSecondary)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.dividerGrey, size: 18),
      ),
    );
  }

  Widget _buildBiometricsSwitch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: SwitchListTile(
        dense: true,
        value: _biometricsEnabled,
        onChanged: _toggleBiometrics,
        activeColor: AppTheme.navyPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        secondary: const Icon(Icons.fingerprint, color: AppTheme.navyPrimary, size: 20),
        title: const Text("Biometría", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkPrimary)),
        subtitle: Text(_biometricsEnabled ? "Activado" : "Desactivado", style: TextStyle(fontSize: 11, color: AppTheme.inkSecondary)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: AppTheme.inkSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  // ============== UNIFIED BOTTOMSHEET DESIGN ==============
  void _showBottomSheet(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
              decoration: BoxDecoration(color: AppTheme.dividerGrey, borderRadius: BorderRadius.circular(2)),
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
    if (formData == null || formData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sin datos de formulario")));
      return;
    }
    _showBottomSheet(context, "Datos DS-160", Column(
      children: formData.entries.map((e) => _buildInfoRow(e.key.replaceAll('_', ' '), e.value.toString())).toList(),
    ));
  }

  void _showDocuments(BuildContext context, String? passportUrl) {
    if (passportUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sin documentos")));
      return;
    }
    _showBottomSheet(context, "Mis Documentos", Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(passportUrl, height: 180, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 180, color: AppTheme.backgroundGrey, child: const Center(child: Icon(Icons.broken_image)))),
        ),
        const SizedBox(height: 12),
        const Text("Pasaporte Escaneado", style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    ));
  }

  void _showSimulatorHistory(BuildContext context, List<dynamic> history, int? score) {
    _showBottomSheet(context, "Historial de Simulaciones", 
      history.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 48, color: AppTheme.dividerGrey),
              const SizedBox(height: 12),
              const Text("Sin sesiones de práctica", style: TextStyle(color: AppTheme.inkSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () { Navigator.pop(context); context.push('/simulator/chat'); },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navyPrimary),
                child: const Text("Iniciar Simulación"),
              ),
            ],
          )
        : Column(
            children: [
              if (score != null) 
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: AppTheme.softBlue, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Puntaje Actual: ", style: TextStyle(fontWeight: FontWeight.w500)),
                      Text("$score%", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyPrimary, fontSize: 18)),
                    ],
                  ),
                ),
              ...history.asMap().entries.map((entry) => _buildInfoRow("Sesión ${entry.key + 1}", entry.value.toString())),
            ],
          ),
    );
  }

  void _showBasicInfo(BuildContext context, Map<String, dynamic>? profile, String email) {
    _showBottomSheet(context, "Información de Cuenta", Column(
      children: [
        _buildInfoRow("Email", email),
        _buildInfoRow("Teléfono", profile?['phone']?.toString() ?? 'No registrado'),
        _buildInfoRow("Rol", profile?['role']?.toString() ?? 'client'),
      ],
    ));
  }

  Future<void> _handlePasswordReset(BuildContext context) async {
    final supabase = ref.read(supabaseClientProvider);
    final email = supabase.auth.currentUser?.email;
    if (email == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cambiar Contraseña", style: TextStyle(color: AppTheme.navyPrimary)),
        content: Text("Se enviará un enlace de recuperación a:\n$email"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navyPrimary),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await supabase.auth.resetPasswordForEmail(email);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enlace enviado a $email")));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    _showBottomSheet(context, "Seleccionar Idioma", Column(
      children: [
        _buildOptionTile("🇪🇸  Español", true, () { Navigator.pop(context); }),
        _buildOptionTile("🇺🇸  English", false, () { Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cambio de idioma requiere reinicio"))); }),
      ],
    ));
  }

  void _showLegalDocs(BuildContext context) {
    _showBottomSheet(context, "Documentos Legales", Column(
      children: [
        _buildMenuItem(Icons.description_outlined, "Términos de Servicio", "Ver documento", () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Abriendo términos...")));
        }),
        _buildMenuItem(Icons.privacy_tip_outlined, "Política de Privacidad", "Ver documento", () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Abriendo política...")));
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.inkSecondary)),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.inkPrimary), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, bool selected, VoidCallback onTap) {
    return ListTile(
      dense: true,
      onTap: onTap,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: selected ? const Icon(Icons.check_circle, color: AppTheme.navyPrimary, size: 18) : null,
    );
  }

  void _copySupportEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'soporte@usavpc.org'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email copiado")));
  }

  Future<void> _handleLogout(BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    if (mounted) context.go('/services');
  }
}
