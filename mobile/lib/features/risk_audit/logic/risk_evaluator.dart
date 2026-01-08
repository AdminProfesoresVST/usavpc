import 'dart:math';

class RiskEvaluation {
  final int score;
  final String riskLevel; // Bajo, Medio, Alto
  final List<String> positiveFactors;
  final List<String> negativeFactors;

  RiskEvaluation({
    required this.score,
    required this.riskLevel,
    required this.positiveFactors,
    required this.negativeFactors,
  });
}

class RiskEvaluator {
  Future<RiskEvaluation> evaluate({
    required String visaType,
    String? age,
    String? nationality,
    bool hasTravelHistory = false, // To be fed from form/chat
    bool hasStrongTies = true,    // To be fed from form/chat
  }) async {
    // Simulate complex calculation delay
    await Future.delayed(const Duration(milliseconds: 1500));

    int baseScore = 50;
    List<String> pros = [];
    List<String> cons = [];

    // 1. Visa Type Analysis
    if (visaType.toLowerCase().contains('b1') || visaType.toLowerCase().contains('b2')) {
      baseScore += 10;
      pros.add("Tipo de visa común con alta tasa de aprobación histórica.");
    } else {
      baseScore -= 5;
      cons.add("Tipo de visa con requisitos estrictos.");
    }

    // 2. Age Analysis (Heuristic: 18-60 is working age, <18 or >60 is lower risk)
    if (age != null) {
      // Parse approx age from MRZ format (YYMMDD) or standard
      // Simplified for this demo
      int? ageNum = int.tryParse(age);
      if (ageNum != null) {
         if (ageNum > 18 && ageNum < 60) {
            baseScore += 5; // Working age needs to prove ties
         } else {
            baseScore += 15; // Minors/Seniors usually lower risk
            pros.add("Rango de edad de menor riesgo migratorio.");
         }
      }
    }

    // 3. Ties & History
    if (hasStrongTies) {
      baseScore += 20;
      pros.add("Lazos fuertes demostrados (Simulado: Trabajo/Casa).");
    } else {
      baseScore -= 20;
      cons.add("Falta documentación de arraigo fuerte.");
    }

    if (hasTravelHistory) {
      baseScore += 10;
      pros.add("Historial de viajes positivo previo.");
    }

    // Cap Score
    int finalScore = min(99, max(1, baseScore));
    
    // Determine Level
    String level = "Medio";
    if (finalScore > 80) level = "Bajo"; // High Score = Low Risk
    if (finalScore < 50) level = "Alto"; // Low Score = High Risk

    return RiskEvaluation(
      score: finalScore,
      riskLevel: level,
      positiveFactors: pros,
      negativeFactors: cons,
    );
  }
}
