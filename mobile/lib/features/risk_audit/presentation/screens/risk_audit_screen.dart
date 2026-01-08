import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/risk_audit/logic/risk_evaluator.dart';

class RiskAuditScreen extends ConsumerStatefulWidget {
  const RiskAuditScreen({super.key});

  @override
  ConsumerState<RiskAuditScreen> createState() => _RiskAuditScreenState();
}

class _RiskAuditScreenState extends ConsumerState<RiskAuditScreen> {
  late Future<RiskEvaluation> _auditFuture;
  final RiskEvaluator _evaluator = RiskEvaluator();

  @override
  void initState() {
    super.initState();
    _auditFuture = _evaluator.evaluate(
      visaType: 'B1/B2',
      age: '30', // TODO: Get from State
      hasStrongTies: true, // TODO: Get from State
      hasTravelHistory: false, // TODO: Get from State
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Auditoría de Aprobación',
          style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF112E51),
        elevation: 1,
      ),
      body: FutureBuilder<RiskEvaluation>(
        future: _auditFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
             return Center(child: Text("Error analizando datos: ${snapshot.error}"));
          }

          final evaluation = snapshot.data!;
          final isHighApproval = evaluation.score > 70;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Probabilidad de Aprobación',
                        style: GoogleFonts.publicSans(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${evaluation.score}%',
                        style: GoogleFonts.publicSans(
                          fontSize: 64, 
                          fontWeight: FontWeight.bold, 
                          color: isHighApproval ? Colors.green.shade600 : Colors.orange.shade600
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isHighApproval ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Riesgo ${evaluation.riskLevel}',
                          style: GoogleFonts.publicSans(
                            color: isHighApproval ? Colors.green.shade700 : Colors.orange.shade700, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Factors
                Text('Análisis Factorial', style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF112E51))),
                const SizedBox(height: 16),
                
                ...evaluation.positiveFactors.map((f) => _buildFactorTile(f, true)),
                 if (evaluation.negativeFactors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...evaluation.negativeFactors.map((f) => _buildFactorTile(f, false)),
                 ],

                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {
                     context.go('/'); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF112E51),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('VOLVER AL INICIO', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildFactorTile(String text, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.warning,
            color: isPositive ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.publicSans(fontSize: 14))),
        ],
      ),
    );
  }
}
