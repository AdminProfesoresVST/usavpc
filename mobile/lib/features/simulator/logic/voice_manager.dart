import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceManager {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  
  bool _isSttAvailable = false;
  bool _isListening = false;

  Future<void> initialize() async {
    _isSttAvailable = await _stt.initialize(
      onError: (e) => print('STT Error: $e'),
      onStatus: (s) => print('STT Status: $s'),
    );
    await _tts.setLanguage("es-US"); // Spanish (US)
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<void> startListening({
    required Function(String) onResult, 
    required Function(bool) onListeningStateChanged
  }) async {
    if (!_isSttAvailable) {
      print("STT not available");
      return;
    }

    if (!_isListening) {
      onListeningStateChanged(true);
      await _stt.listen(
        onResult: (result) {
           onResult(result.recognizedWords);
           if (result.finalResult) {
             onListeningStateChanged(false);
           }
        },
        localeId: "es_US",
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    }
  }

  Future<void> stopListening() async {
    await _stt.stop();
  }
}
