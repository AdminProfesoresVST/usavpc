
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

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
    // We don't need camera strictly for voice sim, but let's check mic
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
          const SnackBar(content: Text('Se requiere micrófono para el simulador de voz.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.record_voice_over, size: 80, color: Colors.white),
               const SizedBox(height: 32),
               Text(
                 'Simulador de Entrevista',
                 style: GoogleFonts.publicSans(
                   fontSize: 28,
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
                 ),
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 16),
               Text(
                 'Practique con nuestro Oficial Consular de IA. Responda verbalmente para evaluar su fluidez y coherencia.',
                 style: GoogleFonts.publicSans(
                   fontSize: 16,
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
                   child: const Text('HABILITAR MICRÓFONO'),
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
                       const Text('INICIAR ENTREVISTA'),
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
