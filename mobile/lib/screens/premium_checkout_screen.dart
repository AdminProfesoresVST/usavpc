import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Premium Checkout Screen
/// Displays plan details and payment options (Google Play, App Store, PayPal)
class PremiumCheckoutScreen extends ConsumerStatefulWidget {
  final String planId;
  
  const PremiumCheckoutScreen({super.key, required this.planId});

  @override
  ConsumerState<PremiumCheckoutScreen> createState() => _PremiumCheckoutScreenState();
}

class _PremiumCheckoutScreenState extends ConsumerState<PremiumCheckoutScreen> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isMonthly = widget.planId == 'monthly';
    
    final planData = isMonthly 
      ? _PlanData(
          name: 'Plan Mensual',
          price: '\$9.99',
          period: '/mes',
          features: [
            'Simulador de Entrevista ilimitado',
            'IA Consular Avanzada',
            'Tips personalizados',
            'Historial de sesiones',
          ],
          savings: null,
        )
      : _PlanData(
          name: 'Plan Anual',
          price: '\$79.99',
          period: '/año',
          features: [
            'Todo del Plan Mensual',
            'Auditoría de Documentos',
            'Soporte Prioritario',
            'Acceso a nuevas funciones',
          ],
          savings: 'Ahorra \$40 (33%)',
        );
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plan Summary Card
              _buildPlanSummaryCard(planData),
              
              const SizedBox(height: 24),
              
              // Payment Methods Section
              Text(
                'Método de Pago',
                style: AppTheme.h2NavyBold,
              ),
              const SizedBox(height: 16),
              
              // Google Play
              _buildPaymentOption(
                id: 'google_play',
                icon: Icons.shopping_bag_outlined,
                title: 'Google Play',
                subtitle: 'Pago seguro con tu cuenta Google',
                color: const Color(0xFF34A853),
              ),
              
              const SizedBox(height: 12),
              
              // Apple App Store
              _buildPaymentOption(
                id: 'app_store',
                icon: Icons.apple,
                title: 'App Store',
                subtitle: 'Pago con Apple ID',
                color: const Color(0xFF000000),
              ),
              
              const SizedBox(height: 12),
              
              // PayPal
              _buildPaymentOption(
                id: 'paypal',
                icon: Icons.payment,
                title: 'PayPal',
                subtitle: 'Tarjeta de crédito o cuenta PayPal',
                color: const Color(0xFF003087),
              ),
              
              const SizedBox(height: 32),
              
              // Checkout Button
              _buildCheckoutButton(),
              
              const SizedBox(height: 16),
              
              // Security Notice
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppTheme.inkSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pago 100% seguro y encriptado',
                      style: AppTheme.captionSecondary,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Terms
              Text(
                'Al continuar, aceptas los Términos de Servicio y Política de Privacidad. '
                'Puedes cancelar tu suscripción en cualquier momento.',
                style: AppTheme.captionSecondary.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlanSummaryCard(_PlanData plan) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.navyPrimary,
            AppTheme.navyPrimary.withBlue(120),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyPrimary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Name & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: AppTheme.h2NavyBold.copyWith(color: Colors.white),
                ),
                if (plan.savings != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      plan.savings!,
                      style: AppTheme.labelBold.copyWith(
                        color: AppTheme.navyPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.price,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    plan.period,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Features List
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.cardBorderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.labelBold.copyWith(
                        color: AppTheme.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.captionSecondary,
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? color : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? color : AppTheme.cardBorderColor,
                    width: 2,
                  ),
                ),
                child: isSelected 
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCheckoutButton() {
    final isEnabled = _selectedPaymentMethod != null && !_isProcessing;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        gradient: isEnabled
          ? LinearGradient(
              colors: [
                AppTheme.navyPrimary,
                AppTheme.navyPrimary.withBlue(100),
              ],
            )
          : null,
        color: isEnabled ? null : AppTheme.cardBorderColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
          ? [
              BoxShadow(
                color: AppTheme.navyPrimary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _processPayment : null,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  'Continuar con el Pago',
                  style: AppTheme.buttonWhiteBold.copyWith(
                    fontSize: 16,
                    color: isEnabled ? Colors.white : AppTheme.inkSecondary,
                  ),
                ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Pago Exitoso!',
              style: AppTheme.h2NavyBold,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu suscripción Premium está activa',
              style: AppTheme.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).go('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Continuar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
    
    setState(() => _isProcessing = false);
  }
}

class _PlanData {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final String? savings;
  
  const _PlanData({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.savings,
  });
}
