import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simulator intro screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class SimulatorIntroScreen extends ConsumerStatefulWidget {
  const SimulatorIntroScreen({super.key});

  @override
  ConsumerState<SimulatorIntroScreen> createState() => _SimulatorIntroScreenState();
}

class _SimulatorIntroScreenState extends ConsumerState<SimulatorIntroScreen> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final micStatus = await Permission.microphone.status;
    if (micStatus.isGranted) {
      if (mounted) setState(() => _permissionsGranted = true);
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
       if (mounted) setState(() => _permissionsGranted = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.microphoneRequired)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.navyPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.record_voice_over, size: 80, color: Colors.white),
               const SizedBox(height: 32),
               Text(
                 l10n.simulatorTitle,
                 style: context.textTheme.headlineMedium?.copyWith(
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
                 ),
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 16),
               Text(
                 l10n.simulatorDescription,
                 style: context.textTheme.bodyLarge?.copyWith(
                   color: Colors.white70,
                   height: 1.5,
                 ),
                 textAlign: TextAlign.center,
               ),
               const Spacer(),
               if (!_permissionsGranted)
                 ElevatedButton(
                   onPressed: _requestPermissions,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.white,
                     foregroundColor: AppTheme.navyPrimary,
                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                   ),
                   child: Text(l10n.enableMicrophone),
                 )
               else
                 ElevatedButton(
                   onPressed: () => context.push('/simulator/chat'),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppTheme.actionBlue,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                   ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(l10n.startInterview),
                       const SizedBox(width: 8),
                       const Icon(Icons.arrow_forward),
                     ],
                   ),
                 ),
               const SizedBox(height: 32),
             ],
          ),
        ),
      ),
    );
  }
}
