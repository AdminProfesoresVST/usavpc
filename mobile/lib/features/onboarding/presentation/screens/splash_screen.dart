import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Splash screen - Auditado 2026-01-25: l10n + AppTheme centralizados
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      context.go('/services');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.navyPrimary,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          
          // Disclaimer at bottom
          Positioned(
            left: 0, 
            right: 0,
            bottom: AppTheme.espacioSecciones,
            child: Text(
              l10n.splashDisclaimer,
              textAlign: TextAlign.center,
              style: AppTheme.captionGreyRegular.copyWith(color: AppTheme.inkInverse24),
            ),
          ),
        ],
      ),
    );
  }
}
