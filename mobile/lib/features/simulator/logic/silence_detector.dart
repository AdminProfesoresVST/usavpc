import 'dart:async';
import 'dart:math';

class SilenceDetector {
  final double thresholdDb;
  final Duration silenceDuration;
  Timer? _silenceTimer;
  final _silenceController = StreamController<void>.broadcast();

  SilenceDetector({
    this.thresholdDb = -45.0,
    this.silenceDuration = const Duration(seconds: 2),
  });

  Stream<void> get onSilenceDetected => _silenceController.stream;

  void processAudioChunk(List<int> audioData) {
    // Calculate RMS/Decibels for the chunk
    // This is simplified. In real implementation, we parse PCM data.
    // For this mock logic, we assume audioData represents amplitude if non-empty
    
    double amplitude = 0.0;
    if (audioData.isNotEmpty) {
        amplitude = audioData.map((e) => e.abs()).reduce(max).toDouble();
    }
    
    // safe log10
    double db = amplitude > 0 ? 20 * (log(amplitude) / ln10) : -100.0;

    if (db < thresholdDb) {
      _startSilenceTimer();
    } else {
      _resetSilenceTimer();
    }
  }

  void _startSilenceTimer() {
    if (_silenceTimer == null || !_silenceTimer!.isActive) {
      _silenceTimer = Timer(silenceDuration, () {
        _silenceController.add(null);
      });
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
  }

  void dispose() {
    _silenceTimer?.cancel();
    _silenceController.close();
  }
}
