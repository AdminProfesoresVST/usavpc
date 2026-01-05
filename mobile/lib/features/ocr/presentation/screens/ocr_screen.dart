import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OCRScreen extends ConsumerWidget {
  const OCRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: Text(
          'Escaneo de Documento',
          style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF112E51), // Navy
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          // Skip/Next Button for Testing
          IconButton(
            onPressed: () {
               final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';
               context.push('/chat-intake?type=$visaType'); // Navigates to Chat Form
            },
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Saltar Escaneo (Test)',
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Progress Indicator
          Container(
            color: const Color(0xFF112E51),
            padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
            child: Row(
              children: [
                _StepIndicator(current: 1, total: 3, label: 'Escanear'),
                const Expanded(child: Divider(color: Colors.white24, height: 1)),
                _StepIndicator(current: 2, total: 3, label: 'Verificar', isActive: false),
                const Expanded(child: Divider(color: Colors.white24, height: 1)),
                _StepIndicator(current: 3, total: 3, label: 'Confirmar', isActive: false),
              ],
            ),
          ),

          // 2. Instructions Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Illustration
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.document_scanner_outlined, size: 60, color: const Color(0xFF112E51)),
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Instrucciones de Captura',
                  style: GoogleFonts.publicSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF112E51),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Para asegurar un procesamiento rápido, sigue estos consejos:',
                  style: GoogleFonts.publicSans(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Tips
                _InstructionRow(icon: Icons.light_mode, text: 'Busca un lugar con buena iluminación.'),
                const SizedBox(height: 16),
                _InstructionRow(icon: Icons.crop_free, text: 'Alinea las 4 esquinas del pasaporte.'),
                const SizedBox(height: 16),
                _InstructionRow(icon: Icons.flash_off, text: 'Evita reflejos (apaga el flash si es necesario).'),
              ],
            ),
          ),

          // 3. Action Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                   // Simulate opening camera (or TODO: Implement real camera)
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Abriendo Cámara... (Simulado)')),
                   );
                   // In real app: context.push('/camera-view');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112E51),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.camera_alt, color: Colors.white),
                     SizedBox(width: 8),
                     Text('INICIAR ESCANEO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final String label;
  final bool isActive;

  const _StepIndicator({required this.current, required this.total, required this.label, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white24,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            current.toString(),
            style: TextStyle(
              color: isActive ? const Color(0xFF112E51) : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF112E51), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.publicSans(fontSize: 14, color: const Color(0xFF334155)),
          ),
        ),
      ],
    );
  }
}
