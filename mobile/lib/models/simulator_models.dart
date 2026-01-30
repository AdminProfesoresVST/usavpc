class SimulatorFeedback {
  final String score; // "buena", "regular", "mala" OR numeric string
  final String critique; // Main feedback message
  final String recommendation;
  final int? scoreDelta; // NEW: points gained/lost
  final int? currentScore; // NEW: current total score

  SimulatorFeedback({
    required this.score,
    required this.critique,
    required this.recommendation,
    this.scoreDelta,
    this.currentScore,
  });

  factory SimulatorFeedback.fromJson(Map<String, dynamic> json) {
    // Parse score: can be string ("buena") or number (75)
    String scoreStr = 'ok';
    if (json['score'] != null) {
      scoreStr = json['score'].toString();
    }
    
    return SimulatorFeedback(
      score: scoreStr,
      critique: json['critique'] ?? json['message'] ?? '', // NEW: message is the main feedback text
      recommendation: json['recommendation'] ?? '', 
      scoreDelta: json['score_delta'] is int ? json['score_delta'] : null,
      currentScore: json['score'] is int ? json['score'] : null,
    );
  }
}

class SimulatorResponse {
  final String textToSpeak;
  final SimulatorFeedback? feedback;

  SimulatorResponse({
    required this.textToSpeak,
    this.feedback,
  });
}

enum AvatarState { idle, speaking, thinking }
