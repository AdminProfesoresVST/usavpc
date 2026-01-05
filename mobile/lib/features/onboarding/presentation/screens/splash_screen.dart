import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    // Longer duration to transmit "authority" and "seriousness"
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      context.go('/services');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Requested: White Background
      body: Stack(
        children: [
          // Centered Big Logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 250, // Requested: Large
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                // Optional: Loading indicator, but kept minimal as requested?
                // Providing a small one just to show activity, or removing if "just logo" is preferred.
                // Keeping it distinct (blue) so it's visible on white.
                const CircularProgressIndicator(color: Color(0xFF112E51)),
              ],
            ),
          ),
          
          // Disclaimer at bottom
          const Positioned(
            left: 0, 
            right: 0,
            bottom: 32,
            child: Text(
              'Non-government service provider / Proveedor privado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
