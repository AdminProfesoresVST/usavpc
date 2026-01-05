import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/simulator/logic/silence_detector.dart';

void main() {
  test('SilenceDetector triggers event after silence duration', () async {
    final detector = SilenceDetector(
      thresholdDb: -40,
      silenceDuration: const Duration(milliseconds: 100),
    );

    bool silenceDetected = false;
    final subscription = detector.onSilenceDetected.listen((_) {
      silenceDetected = true;
    });

    // Simulate silence (empty list or low volume)
    detector.processAudioChunk([0, 0, 0]); // Silence
    
    // Wait for duration
    await Future.delayed(const Duration(milliseconds: 150));
    
    expect(silenceDetected, true);
    await subscription.cancel();
    detector.dispose();
  });

  test('SilenceDetector resets on noise', () async {
     final detector = SilenceDetector(
      thresholdDb: -40,
      silenceDuration: const Duration(milliseconds: 100),
    );

    bool silenceDetected = false;
    final subscription = detector.onSilenceDetected.listen((_) {
      silenceDetected = true;
    });

    // Silence starts
    detector.processAudioChunk([0]);
    
    // Noise interrupts before timeout
    await Future.delayed(const Duration(milliseconds: 50));
    detector.processAudioChunk([100, 100]); // Noise
    
    // Wait past original timeout
    await Future.delayed(const Duration(milliseconds: 60));
    
    expect(silenceDetected, false);
    
    await subscription.cancel();
    detector.dispose();
  });
}
