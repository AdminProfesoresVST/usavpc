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

/// Production-ready risk evaluator without artificial delays.
/// Migration: 2026-01-17 - Removed simulated delay for production.
class RiskEvaluator {
  /// Evaluate visa approval probability based on user data.
  /// This is a local heuristic calculation - no network delay needed.
  RiskEvaluation evaluate({
    required String visaType,
    String? age,
    String? nationality,
    bool hasTravelHistory = false,
    bool hasStrongTies = false,
  }) {
    int baseScore = 50;
    List<String> pros = [];
    List<String> cons = [];

    // 1. Visa Type Analysis
    if (visaType.toLowerCase().contains('b1') || visaType.toLowerCase().contains('b2')) {
      baseScore += 10;
      pros.add("Tipo de visa común con alta tasa de aprobación histórica.");
    } else if (visaType.toLowerCase().contains('f1')) {
      baseScore += 5;
      pros.add("Visa de estudiante con requisitos claros.");
    } else {
      baseScore -= 5;
      cons.add("Tipo de visa con requisitos estrictos.");
    }

    // 2. Age Analysis
    if (age != null && age.isNotEmpty) {
      int? ageNum = int.tryParse(age);
      if (ageNum != null) {
        if (ageNum >= 25 && ageNum <= 55) {
          baseScore += 10;
          pros.add("Edad económicamente activa con mayor estabilidad.");
        } else if (ageNum > 55) {
          baseScore += 15;
          pros.add("Rango de edad de menor riesgo migratorio.");
        } else if (ageNum < 18) {
          pros.add("Menor acompañado, generalmente bajo riesgo.");
          baseScore += 10;
        }
      }
    } else {
      cons.add("Datos de edad no disponibles para análisis.");
    }

    // 3. Strong Ties (Employment, Family, Property)
    if (hasStrongTies) {
      baseScore += 20;
      pros.add("Lazos fuertes demostrados (empleo, familia o propiedad).");
    } else {
      baseScore -= 15;
      cons.add("Sin evidencia de arraigo fuerte al país de origen.");
    }

    // 4. Travel History
    if (hasTravelHistory) {
      baseScore += 15;
      pros.add("Historial de viajes previo demuestra cumplimiento.");
    } else {
      cons.add("Sin historial de viajes internacionales previos.");
    }

    // 5. Nationality factor (placeholder - could be expanded)
    if (nationality != null && nationality.isNotEmpty) {
      // This is where country-specific logic could go
      pros.add("Nacionalidad registrada para análisis consular.");
    }

    // Cap score
    int finalScore = min(99, max(1, baseScore));
    
    // Determine risk level
    String level = "Medio";
    if (finalScore > 75) {
      level = "Bajo"; // High score = low risk
    } else if (finalScore < 45) {
      level = "Alto"; // Low score = high risk
    }

    return RiskEvaluation(
      score: finalScore,
      riskLevel: level,
      positiveFactors: pros,
      negativeFactors: cons,
    );
  }
}
