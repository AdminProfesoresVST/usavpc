import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔧 ADMIN PAYMENT CONFIG SCREEN
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Admin screen to configure payment providers:
/// - Google Play (product IDs, sandbox mode)
/// - App Store (product IDs, sandbox mode)
/// - PayPal (client ID, secret, URLs)
/// 
/// Created: 2026-01-31
/// ═══════════════════════════════════════════════════════════════════════════

class AdminPaymentConfigScreen extends ConsumerStatefulWidget {
  const AdminPaymentConfigScreen({super.key});

  @override
  ConsumerState<AdminPaymentConfigScreen> createState() => _AdminPaymentConfigScreenState();
}

class _AdminPaymentConfigScreenState extends ConsumerState<AdminPaymentConfigScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Google Play config
  bool _googlePlayEnabled = true;
  bool _googlePlaySandbox = true;
  final _googlePlayProductsController = TextEditingController();
  
  // App Store config
  bool _appStoreEnabled = true;
  bool _appStoreSandbox = true;
  final _appStoreProductsController = TextEditingController();
  
  // PayPal config
  bool _paypalEnabled = true;
  bool _paypalSandbox = true;
  final _paypalClientIdController = TextEditingController();
  final _paypalSecretController = TextEditingController();
  final _paypalReturnUrlController = TextEditingController();
  final _paypalCancelUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _googlePlayProductsController.dispose();
    _appStoreProductsController.dispose();
    _paypalClientIdController.dispose();
    _paypalSecretController.dispose();
    _paypalReturnUrlController.dispose();
    _paypalCancelUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final configs = await supabase.from('payment_config').select();
      
      for (final config in configs) {
        final id = config['id'] as String;
        final isEnabled = config['is_enabled'] as bool? ?? true;
        final isSandbox = config['is_sandbox'] as bool? ?? true;
        final configData = config['config'] as Map<String, dynamic>? ?? {};
        
        switch (id) {
          case 'google_play':
            _googlePlayEnabled = isEnabled;
            _googlePlaySandbox = isSandbox;
            final products = (configData['product_ids'] as List?)?.join(', ') ?? '';
            _googlePlayProductsController.text = products;
            break;
            
          case 'app_store':
            _appStoreEnabled = isEnabled;
            _appStoreSandbox = isSandbox;
            final products = (configData['product_ids'] as List?)?.join(', ') ?? '';
            _appStoreProductsController.text = products;
            break;
            
          case 'paypal':
            _paypalEnabled = isEnabled;
            _paypalSandbox = isSandbox;
            _paypalClientIdController.text = configData['client_id'] ?? '';
            _paypalSecretController.text = configData['secret'] ?? '';
            _paypalReturnUrlController.text = configData['return_url'] ?? '';
            _paypalCancelUrlController.text = configData['cancel_url'] ?? '';
            break;
        }
      }
    } catch (e) {
      _showError('Error loading config: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    
    try {
      final supabase = Supabase.instance.client;
      
      // Save Google Play config
      await supabase.from('payment_config').upsert({
        'id': 'google_play',
        'provider': 'google_play',
        'is_enabled': _googlePlayEnabled,
        'is_sandbox': _googlePlaySandbox,
        'config': {
          'product_ids': _googlePlayProductsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        },
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Save App Store config
      await supabase.from('payment_config').upsert({
        'id': 'app_store',
        'provider': 'app_store',
        'is_enabled': _appStoreEnabled,
        'is_sandbox': _appStoreSandbox,
        'config': {
          'product_ids': _appStoreProductsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        },
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Save PayPal config
      await supabase.from('payment_config').upsert({
        'id': 'paypal',
        'provider': 'paypal',
        'is_enabled': _paypalEnabled,
        'is_sandbox': _paypalSandbox,
        'config': {
          'client_id': _paypalClientIdController.text,
          'secret': _paypalSecretController.text,
          'return_url': _paypalReturnUrlController.text,
          'cancel_url': _paypalCancelUrlController.text,
        },
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      _showSuccess('Configuración guardada correctamente');
    } catch (e) {
      _showError('Error saving config: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.successGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
        title: const Text('Configuración de Pagos'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveConfig,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Google Play Section
                  _buildProviderCard(
                    title: 'Google Play',
                    icon: Icons.shop,
                    iconColor: AppTheme.successGreen,
                    isEnabled: _googlePlayEnabled,
                    onEnabledChanged: (v) => setState(() => _googlePlayEnabled = v),
                    isSandbox: _googlePlaySandbox,
                    onSandboxChanged: (v) => setState(() => _googlePlaySandbox = v),
                    children: [
                      _buildTextField(
                        controller: _googlePlayProductsController,
                        label: 'Product IDs (separados por coma)',
                        hint: 'premium_monthly, premium_yearly',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // App Store Section
                  _buildProviderCard(
                    title: 'App Store',
                    icon: Icons.apple,
                    iconColor: AppTheme.inkPrimary,
                    isEnabled: _appStoreEnabled,
                    onEnabledChanged: (v) => setState(() => _appStoreEnabled = v),
                    isSandbox: _appStoreSandbox,
                    onSandboxChanged: (v) => setState(() => _appStoreSandbox = v),
                    children: [
                      _buildTextField(
                        controller: _appStoreProductsController,
                        label: 'Product IDs (separados por coma)',
                        hint: 'premium_monthly, premium_yearly',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // PayPal Section
                  _buildProviderCard(
                    title: 'PayPal',
                    icon: Icons.account_balance_wallet,
                    iconColor: AppTheme.actionBlue,
                    isEnabled: _paypalEnabled,
                    onEnabledChanged: (v) => setState(() => _paypalEnabled = v),
                    isSandbox: _paypalSandbox,
                    onSandboxChanged: (v) => setState(() => _paypalSandbox = v),
                    children: [
                      _buildTextField(
                        controller: _paypalClientIdController,
                        label: 'Client ID',
                        hint: 'Tu PayPal Client ID',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _paypalSecretController,
                        label: 'Secret',
                        hint: 'Tu PayPal Secret',
                        obscure: true,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _paypalReturnUrlController,
                        label: 'Return URL',
                        hint: 'https://tuapp.com/payment/success',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _paypalCancelUrlController,
                        label: 'Cancel URL',
                        hint: 'https://tuapp.com/payment/cancel',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navyPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Guardar Configuración',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Help Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.actionBlue),
                            const SizedBox(width: 8),
                            Text(
                              'Instrucciones',
                              style: AppTheme.labelBold.copyWith(color: AppTheme.actionBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Google Play: Crea productos en Google Play Console y copia los IDs aquí.\n'
                          '• App Store: Crea productos en App Store Connect y copia los IDs aquí.\n'
                          '• PayPal: Obtén las credenciales de tu cuenta PayPal Business.\n'
                          '• Sandbox: Activa para pruebas, desactiva para pagos reales.',
                          style: AppTheme.captionGreyRegular.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProviderCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required ValueChanged<bool> onEnabledChanged,
    required bool isSandbox,
    required ValueChanged<bool> onSandboxChanged,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.h2NavyBold.copyWith(fontSize: 18),
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onEnabledChanged,
                  activeColor: AppTheme.successGreen,
                ),
              ],
            ),
          ),
          
          // Body
          if (isEnabled)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sandbox Toggle
                  Row(
                    children: [
                      Icon(
                        isSandbox ? Icons.science : Icons.verified,
                        color: isSandbox ? AppTheme.warningOrange : AppTheme.successGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSandbox ? 'Modo Sandbox (Pruebas)' : 'Modo Producción',
                        style: AppTheme.labelBold.copyWith(
                          color: isSandbox ? AppTheme.warningOrange : AppTheme.successGreen,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: isSandbox,
                        onChanged: onSandboxChanged,
                        activeColor: AppTheme.warningOrange,
                        inactiveThumbColor: AppTheme.successGreen,
                        inactiveTrackColor: AppTheme.successGreen.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...children,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.cardBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.cardBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.actionBlue, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.dividerGreyLight,
      ),
    );
  }
}
