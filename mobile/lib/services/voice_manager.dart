import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class VoiceManager {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  
  bool _isSttAvailable = false;
  bool _isListening = false;

  Future<void> initialize() async {
    _isSttAvailable = await _stt.initialize(


    );
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05); // Ligeramente más agudo para sonar más "despierto"
    await _tts.setSpeechRate(0.55); // 0.5 es muy lento en Android, 0.55 es más fluido

    // Intentar buscar una voz de alta calidad (Network/Neural)
    try {
      final voices = await _tts.getVoices;
      final List<dynamic> validVoices = List<dynamic>.from(voices);

      // Prioridad 1: Voces 'es-US' de red (Google Network/Neural)
      var bestVoice = validVoices.firstWhere((v) {
         final name = v['name'].toString().toLowerCase();
         final locale = v['locale'].toString().toLowerCase();
         return locale.contains('es-us') && (name.contains('network') || name.contains('neural') || name.contains('premium'));
      }, orElse: () => null);

      // Prioridad 2: Cualquier voz 'es-US'
      bestVoice ??= validVoices.firstWhere((v) => v['locale'].toString().toLowerCase().contains('es-us'), orElse: () => null);

      // Prioridad 3: Cualquier voz 'es'
      bestVoice ??= validVoices.firstWhere((v) => v['locale'].toString().toLowerCase().contains('es'), orElse: () => null);

      if (bestVoice != null) {
        await _tts.setVoice({
          "name": bestVoice["name"],
          "locale": bestVoice["locale"]
        });
        debugPrint("✅ Voz seleccionada: ${bestVoice['name']} (${bestVoice['locale']})");
      } else {
         await _tts.setLanguage("es-US"); // Fallback
      }
    } catch (e) {
      debugPrint("⚠️ Error configurando voz avanzada: $e");
      await _tts.setLanguage("es-US");
    }

    await _tts.awaitSpeakCompletion(true); // Critical for animation timing
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

      return;
    }

    if (!_isListening) {
      _isListening = true;
      onListeningStateChanged(true);
      
      await _stt.listen(
        onResult: (result) {
           onResult(result.recognizedWords);
           if (result.finalResult) {
             _isListening = false;
             onListeningStateChanged(false);
           }
        },
        localeId: "es_US",
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          partialResults: true,
        ),
      );
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
  }
}
