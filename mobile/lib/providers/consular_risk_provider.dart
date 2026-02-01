import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/models/consular_risk_state.dart';
import 'package:mobile/providers/user_profile_provider.dart';

part 'consular_risk_provider.g.dart';

/// Consular Risk Provider
/// Implements 9 FAM weighted scoring algorithm from consular-singularity-engine skill.
/// 
/// Weights based on 9 FAM 401.1 priorities:
/// - Economic Ties (Ve): 30%
/// - Social Anchors (Vs): 25%
/// - Documentary Integrity: 20%
/// - Travel History (Vh): 15%
/// - Consistency/Honesty (Vc): 10%

@riverpod
class ConsularRisk extends _$ConsularRisk {
  @override
  ConsularRiskState build() {
    // Watch user profile for reactive updates
    final profileAsync = ref.watch(fetchUserProfileProvider);
    
    return profileAsync.when(
      data: (profile) => _analyzeProfile(profile),
      loading: () => ConsularRiskState.initial().copyWith(isAnalyzing: true),
      error: (_, __) => ConsularRiskState.initial(),
    );
  }

  ConsularRiskState _analyzeProfile(Map<String, dynamic>? profile) {
    if (profile == null) {
      return ConsularRiskState.initial();
    }

    final redFlags = <RedFlagAlert>[];
    
    // === ECONOMIC TIES (Ve) - 30% Weight ===
    double economicScore = 0.0;
    final salary = profile['monthly_salary'] as num?;
    final employment = profile['employment_status'] as String?;
    
    if (salary != null && salary > 0) {
      // Higher salary = stronger ties
      economicScore = (salary / 10000).clamp(0.0, 1.0);
    }
    if (employment == 'employed' || employment == 'self_employed') {
      economicScore = (economicScore + 0.3).clamp(0.0, 1.0);
    } else if (employment == 'unemployed') {
      redFlags.add(RedFlagAlert(
        id: 'rf_unemployed',
        title: 'SIN EMPLEO REGISTRADO',
        description: 'La falta de empleo formal debilita significativamente los lazos económicos.',
        severity: RedFlagSeverity.critical,
        timestamp: DateTime.now(),
        fieldKey: 'employment_status',
      ));
    }

    // === SOCIAL ANCHORS (Vs) - 25% Weight ===
    double socialScore = 0.0;
    final maritalStatus = profile['marital_status'] as String?;
    final hasChildren = profile['has_children'] as bool? ?? false;
    final ownsProperty = profile['owns_property'] as bool? ?? false;
    
    if (maritalStatus == 'married') socialScore += 0.4;
    if (hasChildren) socialScore += 0.3;
    if (ownsProperty) socialScore += 0.3;
    socialScore = socialScore.clamp(0.0, 1.0);
    
    if (maritalStatus == 'single' && !hasChildren && !ownsProperty) {
      redFlags.add(RedFlagAlert(
        id: 'rf_no_anchors',
        title: 'LAZOS SOCIALES DÉBILES',
        description: 'Perfil soltero sin hijos ni propiedades detectadas. Mayor riesgo de arraigo.',
        severity: RedFlagSeverity.warning,
        timestamp: DateTime.now(),
      ));
    }

    // === DOCUMENTARY INTEGRITY - 20% Weight ===
    double docScore = 0.0;
    final passportUploaded = profile['passport_verified'] as bool? ?? false;
    final bankStatementsUploaded = profile['bank_statements_verified'] as bool? ?? false;
    final employmentLetterUploaded = profile['employment_letter_verified'] as bool? ?? false;
    
    if (passportUploaded) docScore += 0.4;
    if (bankStatementsUploaded) docScore += 0.3;
    if (employmentLetterUploaded) docScore += 0.3;
    docScore = docScore.clamp(0.0, 1.0);

    // === TRAVEL HISTORY (Vh) - 15% Weight ===
    double travelScore = 0.0;
    final previousVisas = profile['previous_visas_count'] as int? ?? 0;
    final oecdCountriesVisited = profile['oecd_countries_visited'] as int? ?? 0;
    
    travelScore = ((previousVisas * 0.2) + (oecdCountriesVisited * 0.1)).clamp(0.0, 1.0);
    
    if (previousVisas == 0 && oecdCountriesVisited == 0) {
      redFlags.add(RedFlagAlert(
        id: 'rf_no_travel',
        title: 'SIN HISTORIAL DE VIAJES',
        description: 'Pasaporte sin viajes internacionales previos registrados.',
        severity: RedFlagSeverity.warning,
        timestamp: DateTime.now(),
      ));
    }

    // === CONSISTENCY/HONESTY (Vc) - 10% Weight ===
    double inconsistencyScore = 0.0;
    
    // Check trip duration
    final tripDuration = profile['intended_stay_days'] as int?;
    if (tripDuration != null && tripDuration > 90) {
      inconsistencyScore += 0.3;
      redFlags.add(RedFlagAlert(
        id: 'rf_long_stay',
        title: 'DURACIÓN DE VIAJE EXTENSA',
        description: 'La estadía planeada ($tripDuration días) excede el perfil turístico estándar.',
        severity: RedFlagSeverity.critical,
        timestamp: DateTime.now(),
        fieldKey: 'intended_stay_days',
      ));
    }
    
    // Check purpose mismatch
    final purpose = profile['travel_purpose'] as String?;
    if (purpose == 'tourism' && (tripDuration ?? 0) > 60) {
      inconsistencyScore += 0.2;
    }
    
    inconsistencyScore = inconsistencyScore.clamp(0.0, 1.0);

    // === CALCULATE FINAL PROBABILITY ===
    // Weighted formula per 9 FAM
    final probability = (
      (economicScore * 0.30) +
      (socialScore * 0.25) +
      (docScore * 0.20) +
      (travelScore * 0.15) +
      ((1.0 - inconsistencyScore) * 0.10)
    ).clamp(0.0, 1.0);

    final frictionMap = FrictionMapData(
      economicTies: economicScore,
      socialAnchors: socialScore,
      documentaryIntegrity: docScore,
      inconsistencyScore: inconsistencyScore,
      travelHistoryDepth: travelScore,
    );

    return ConsularRiskState(
      visaApprovalProbability: probability,
      riskCategory: ConsularRiskState.categoryFromProbability(probability),
      frictionMap: frictionMap,
      redFlags: redFlags,
      lastAnalysis: DateTime.now(),
      isAnalyzing: false,
    );
  }

  /// Trigger adversarial sentence simulation
  Future<List<String>> runSentenceSimulation() async {
    final currentState = state;
    final questions = <String>[];
    
    // Generate 3 trap questions based on weak areas
    if (currentState.frictionMap.economicTies < 0.5) {
      questions.add('How do you plan to fund ${currentState.frictionMap.economicTies < 0.3 ? "such an extended" : "your"} trip without stable income?');
    }
    
    if (currentState.frictionMap.socialAnchors < 0.5) {
      questions.add('What compelling reason would bring you back to your home country?');
    }
    
    if (currentState.frictionMap.travelHistoryDepth < 0.3) {
      questions.add('Why is the United States your first international destination?');
    }
    
    // Always add at least one probing question
    if (questions.isEmpty) {
      questions.add('What would happen to your responsibilities at home if you decided to stay longer than planned?');
    }
    
    // Cap at 3 questions
    return questions.take(3).toList();
  }
}
