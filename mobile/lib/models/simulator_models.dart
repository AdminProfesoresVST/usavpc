class SimulatorFeedback {
  final String score; // "buena", "regular", "mala"
  final String critique;
  final String recommendation;

  SimulatorFeedback({
    required this.score,
    required this.critique,
    required this.recommendation,
  });

  factory SimulatorFeedback.fromJson(Map<String, dynamic> json) {
    return SimulatorFeedback(
      score: json['score'] ?? 'ok',
      critique: json['critique'] ?? '',
      recommendation: json['recommendation'] ?? '',
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
