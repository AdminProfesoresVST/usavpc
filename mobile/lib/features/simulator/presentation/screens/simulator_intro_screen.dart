import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simulator intro screen with full i18n support.
/// Updated: 2026-01-22 - Refined UI for "Delicate" and "Compact" look
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
      backgroundColor: AppTheme.inkInverse,
      appBar: AppBar(
        backgroundColor: AppTheme.inkInverse,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.navyPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.navyPrimary),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Spacer(),
               Container(
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                   color: AppTheme.navyPrimary.withOpacity(0.04), // Subtle background
                   shape: BoxShape.circle,
                   border: Border.all(color: AppTheme.navyPrimary.withOpacity(0.1)),
                 ),
                 child: const Icon(Icons.mic_none_outlined, size: 48, color: AppTheme.navyPrimary),
               ),
               const SizedBox(height: 48),
               Text(
                 l10n.simulatorTitle,
                 style: AppTheme.h2NavyBold,
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 12),
               Text(
                 l10n.simulatorDescription,
                 style: AppTheme.bodyPrimaryRegular.copyWith(color: AppTheme.inkSecondary),
                 textAlign: TextAlign.center,
               ),
               const Spacer(flex: 2),
               
               if (!_permissionsGranted)
                 Center(
                   child: ElevatedButton(
                     onPressed: _requestPermissions,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppTheme.actionBlue,
                       foregroundColor: AppTheme.inkInverse,
                       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                       shape: RoundedRectangleBorder(borderRadius: AppTheme.badgeRadius),
                       elevation: 1,
                     ),
                     child: Text(l10n.enableMicrophone),
                   ),
                 )
               else
                 Center(
                   child: ElevatedButton(
                     onPressed: () => context.push('/simulator/chat'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppTheme.navyPrimary, 
                       foregroundColor: AppTheme.inkInverse,
                       elevation: 4,
                       shadowColor: AppTheme.navyPrimary.withOpacity(0.4),
                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: AppTheme.badgeRadius),
                       textStyle: AppTheme.labelBold.copyWith(color: AppTheme.inkInverse),
                     ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(l10n.startInterview.toUpperCase()),
                         const SizedBox(width: 8),
                         const Icon(Icons.arrow_forward, size: 18),
                       ],
                     ),
                   ),
                 ),
               const SizedBox(height: 48),
             ],
          ),
        ),
      ),
    );
  }
}
