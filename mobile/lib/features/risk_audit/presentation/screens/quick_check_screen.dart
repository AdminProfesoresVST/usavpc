import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';

class QuickCheckScreen extends ConsumerStatefulWidget {
  const QuickCheckScreen({super.key});

  @override
  ConsumerState<QuickCheckScreen> createState() => _QuickCheckScreenState();
}

class _QuickCheckScreenState extends ConsumerState<QuickCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ds160Controller = TextEditingController();
  bool _hasDs160 = true; // Product B assumes they have it, but maybe checking?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Auditoría Preliminar',
          style: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppTheme.navyPrimary, // Navy
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Verificación de Elegibilidad',
                style: GoogleFonts.publicSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Antes de simular su entrevista, analizaremos su perfil básico para detectar riesgos evidentes.',
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Question 1: Visa Type
              Text(
                'Tipo de Visa Solicitada',
                style: GoogleFonts.publicSans(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'B1/B2',
                    items: const [
                      DropdownMenuItem(value: 'B1/B2', child: Text('B1/B2 - Turismo y Negocios')),
                      DropdownMenuItem(value: 'F1', child: Text('F1 - Estudiante')),
                      DropdownMenuItem(value: 'H2', child: Text('H2 - Trabajo Temporal')),
                    ],
                    onChanged: (val) {},
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Question 2: DS-160
              Text(
                '¿Ya completó su formulario DS-160?',
                style: GoogleFonts.publicSans(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RadioOption(
                      label: 'Sí, tengo el código',
                      selected: _hasDs160,
                      onTap: () => setState(() => _hasDs160 = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RadioOption(
                      label: 'No, aún no',
                      selected: !_hasDs160,
                      onTap: () => setState(() => _hasDs160 = false),
                    ),
                  ),
                ],
              ),
              
              if (_hasDs160) ...[
                const SizedBox(height: 24),
                Text(
                  'Código de Confirmación DS-160',
                  style: GoogleFonts.publicSans(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ds160Controller,
                  decoration: const InputDecoration(
                    hintText: 'Ej: AA00...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el código';
                    if (!value.toUpperCase().startsWith('AA')) return 'Debe comenzar con "AA"';
                    return null;
                  },
                ),
              ],
              
               if (!_hasDs160) ...[
                const SizedBox(height: 24),
                 Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Para una auditoría precisa, recomendamos tener el formulario listo. Puede continuar, pero el análisis será limitado.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Action Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_hasDs160 && !_formKey.currentState!.validate()) return;
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.actionBlue, // Official Blue
                    foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Rectangular
                     elevation: 0,
                  ),
                  child: Text(
                    'COMENZAR ANÁLISIS',
                    style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // TODO: Save data to provider/repo
    // Navigate to Risk Audit (Loading/Result)
    // For now, let's assume we go to Simulator directly or a placeholder
    // In plan: Quick Check -> Risk Audit -> Simulator
    
    // Simulating Analysis delay
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator())
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        context.push('/risk-audit'); // Go to Risk Audit
      }
    });
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF112E51).withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF112E51) : Colors.grey.shade300,
            width: selected ? 2 : 1
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF112E51) : Colors.grey.shade400,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF112E51) : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
