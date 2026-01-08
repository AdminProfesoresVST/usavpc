
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/kyc/data/ai_repository.dart';
import 'package:mobile/features/simulator/logic/voice_manager.dart';
import 'package:mobile/features/simulator/presentation/widgets/avatar_widget.dart';

class ChatInterfaceScreen extends ConsumerStatefulWidget {
  const ChatInterfaceScreen({super.key});

  @override
  ConsumerState<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends ConsumerState<ChatInterfaceScreen> {
  final VoiceManager _voiceManager = VoiceManager();
  AvatarState _avatarState = AvatarState.idle;
  String _transcript = "Presione el micrófono para hablar...";
  String _lastResponse = "Conectando con el Oficial Consular...";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    await _voiceManager.initialize();
    
    // Slight delay to ensure UI is ready before initial greeting
    Future.delayed(const Duration(milliseconds: 500), () {
        _startSimulation();
    });
  }
  
  @override
  void dispose() {
    _voiceManager.stopSpeaking();
    _voiceManager.stopListening();
    super.dispose();
  }

  Future<void> _startSimulation() async {
    await _sendMessageToAI(null); 
  }

  Future<void> _sendMessageToAI(String? userMessage) async {
    if (mounted) {
       setState(() {
          _avatarState = AvatarState.thinking;
          if (userMessage != null) _transcript = userMessage; 
       });
    }

    try {
      final response = await ref.read(aiRepositoryProvider).sendMessage(
        message: userMessage ?? "", 
        visaType: 'B1/B2',
        mode: 'simulator'
      );

      if (mounted) {
        setState(() {
          _avatarState = AvatarState.speaking;
          _lastResponse = response;
        });
        
        // Speak Response
        await _voiceManager.speak(response);
        
        // After speaking, go back to idle
        if (mounted) setState(() => _avatarState = AvatarState.idle);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = "Error: ${e.toString()}";
          _avatarState = AvatarState.idle;
        });
      }
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _voiceManager.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() {
         _isListening = true;
         _transcript = "Escuchando...";
      });
      
      _voiceManager.startListening(
        onResult: (text) {
           if (mounted) setState(() => _transcript = text);
        },
        onListeningStateChanged: (isListening) {
           if (mounted) {
              setState(() => _isListening = isListening);
              if (!isListening && _transcript.isNotEmpty && _transcript != "Escuchando...") {
                 // Auto-send on silence/stop
                 _sendMessageToAI(_transcript);
              }
           }
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Entrevista en Curso', style: GoogleFonts.publicSans(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navyPrimary,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Avatar Area
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarWidget(state: _avatarState, size: 240),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SingleChildScrollView(
                        child: Text(
                          _lastResponse,
                          style: GoogleFonts.publicSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.navyPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
              ),
            ),
          ),
          
          // Transcript Area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
               child: Center(
                 child: Text(
                   '"$_transcript"',
                   style: GoogleFonts.publicSans(
                     fontSize: 16,
                     color: _isListening ? Colors.redAccent : Colors.grey.shade600,
                     fontStyle: FontStyle.italic,
                     fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
                   ),
                   textAlign: TextAlign.center,
                 ),
               ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : AppTheme.actionBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(
                             color: _isListening ? Colors.redAccent.withOpacity(0.5) : Colors.black26, 
                             blurRadius: _isListening ? 20 : 8, 
                             offset: const Offset(0, 4)
                           )
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic, 
                        color: Colors.white, 
                        size: 36
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
