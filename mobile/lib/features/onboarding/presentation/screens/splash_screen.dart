import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Splash screen - minimal changes needed, just consistency.
/// Updated: 2026-01-21 - Applied AppTheme constants
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
    return Scaffold(
      backgroundColor: AppTheme.navyPrimary,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.15, // Subtle branding
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                // Removed Spinner: App loads fast, spinner looks cheap
              ],
            ),
          ),
          
          // Disclaimer at bottom - bilingual
          Positioned(
            left: 0, 
            right: 0,
            bottom: 32,
            child: Text(
              'Non-government service provider / Proveedor privado',
              textAlign: TextAlign.center,
              style: AppTheme.captionGreyRegular.copyWith(color: AppTheme.inkInverse24),
            ),
          ),
        ],
      ),
    );
  }
}
