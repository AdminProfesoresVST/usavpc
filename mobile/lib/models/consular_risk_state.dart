/// Consular Risk State Model
/// Based on 9 FAM forensic analysis principles from consular-singularity-engine skill.
///
/// This model tracks the real-time visa approval probability and 
/// multi-axis risk assessment for the Consular Risk Dashboard.
library;

import 'package:flutter/foundation.dart';

/// Risk categories based on 9 FAM 214(b) evaluation standards.
enum RiskCategory {
  /// 70-100% approval probability
  low,
  
  /// 40-69% approval probability
  moderate,
  
  /// 20-39% approval probability
  high,
  
  /// 0-19% approval probability - 214(b) denial imminent
  critical,
}

extension RiskCategoryExtension on RiskCategory {
  String get label {
    switch (this) {
      case RiskCategory.low:
        return 'LOW RISK';
      case RiskCategory.moderate:
        return 'MODERATE';
      case RiskCategory.high:
        return 'HIGH RISK';
      case RiskCategory.critical:
        return '214(b) IMMINENT';
    }
  }
  
  String get description {
    switch (this) {
      case RiskCategory.low:
        return 'Strong ties demonstrated. Favorable profile.';
      case RiskCategory.moderate:
        return 'Some concerns. Additional documentation recommended.';
      case RiskCategory.high:
        return 'Multiple red flags detected. Review required.';
      case RiskCategory.critical:
        return 'Profile indicates high probability of 214(b) refusal.';
    }
  }
}

/// Red flag alert triggered during forensic analysis.
@immutable
class RedFlagAlert {
  final String id;
  final String title;
  final String description;
  final RedFlagSeverity severity;
  final DateTime timestamp;
  final String? fieldKey;

  const RedFlagAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.fieldKey,
  });
}

enum RedFlagSeverity {
  warning,
  critical,
}

/// 5-axis friction map data for radar chart visualization.
@immutable
class FrictionMapData {
  /// Economic Ties: Salary vs Cost of Living ratio (0.0-1.0)
  final double economicTies;
  
  /// Social Anchors: Family, Property, Community ties (0.0-1.0)
  final double socialAnchors;
  
  /// Documentary Integrity: Quality of uploaded evidence (0.0-1.0)
  final double documentaryIntegrity;
  
  /// Inconsistency Score: Contradictions detected (0.0-1.0, lower is better)
  final double inconsistencyScore;
  
  /// Travel History Depth: Quality of prior OECD travel (0.0-1.0)
  final double travelHistoryDepth;

  const FrictionMapData({
    required this.economicTies,
    required this.socialAnchors,
    required this.documentaryIntegrity,
    required this.inconsistencyScore,
    required this.travelHistoryDepth,
  });

  factory FrictionMapData.empty() => const FrictionMapData(
    economicTies: 0.0,
    socialAnchors: 0.0,
    documentaryIntegrity: 0.0,
    inconsistencyScore: 0.0,
    travelHistoryDepth: 0.0,
  );

  /// Calculate overall strength (excluding inconsistency which is negative)
  double get overallStrength {
    final positive = (economicTies + socialAnchors + documentaryIntegrity + travelHistoryDepth) / 4;
    final penalty = inconsistencyScore * 0.3;
    return (positive - penalty).clamp(0.0, 1.0);
  }

  List<double> toRadarValues() => [
    economicTies,
    socialAnchors,
    documentaryIntegrity,
    1.0 - inconsistencyScore, // Invert for visualization (higher = better)
    travelHistoryDepth,
  ];

  static List<String> get axisLabels => [
    'Economic',
    'Social',
    'Documents',
    'Consistency',
    'Travel',
  ];
}

/// Complete consular risk state for the dashboard.
@immutable
class ConsularRiskState {
  /// Visa approval probability from 0.0 (certain denial) to 1.0 (certain approval)
  final double visaApprovalProbability;
  
  /// Current risk category based on probability
  final RiskCategory riskCategory;
  
  /// Friction map data for radar chart
  final FrictionMapData frictionMap;
  
  /// Active red flag alerts
  final List<RedFlagAlert> redFlags;
  
  /// Last analysis timestamp
  final DateTime? lastAnalysis;
  
  /// Whether analysis is in progress
  final bool isAnalyzing;

  const ConsularRiskState({
    required this.visaApprovalProbability,
    required this.riskCategory,
    required this.frictionMap,
    required this.redFlags,
    this.lastAnalysis,
    this.isAnalyzing = false,
  });

  factory ConsularRiskState.initial() => ConsularRiskState(
    visaApprovalProbability: 0.0,
    riskCategory: RiskCategory.critical,
    frictionMap: FrictionMapData.empty(),
    redFlags: const [],
    lastAnalysis: null,
    isAnalyzing: false,
  );

  ConsularRiskState copyWith({
    double? visaApprovalProbability,
    RiskCategory? riskCategory,
    FrictionMapData? frictionMap,
    List<RedFlagAlert>? redFlags,
    DateTime? lastAnalysis,
    bool? isAnalyzing,
  }) {
    return ConsularRiskState(
      visaApprovalProbability: visaApprovalProbability ?? this.visaApprovalProbability,
      riskCategory: riskCategory ?? this.riskCategory,
      frictionMap: frictionMap ?? this.frictionMap,
      redFlags: redFlags ?? this.redFlags,
      lastAnalysis: lastAnalysis ?? this.lastAnalysis,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }

  /// Derive risk category from probability
  static RiskCategory categoryFromProbability(double probability) {
    if (probability >= 0.7) return RiskCategory.low;
    if (probability >= 0.4) return RiskCategory.moderate;
    if (probability >= 0.2) return RiskCategory.high;
    return RiskCategory.critical;
  }
}
