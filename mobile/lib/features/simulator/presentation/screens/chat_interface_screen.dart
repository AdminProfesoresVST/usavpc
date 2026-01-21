import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/kyc/data/ai_repository.dart';
import 'package:mobile/features/simulator/logic/voice_manager.dart';
import 'package:mobile/features/simulator/presentation/widgets/avatar_widget.dart';

/// Chat interface for voice-based interview simulation with full i18n.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class ChatInterfaceScreen extends ConsumerStatefulWidget {
  const ChatInterfaceScreen({super.key});

  @override
  ConsumerState<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends ConsumerState<ChatInterfaceScreen> {
  final VoiceManager _voiceManager = VoiceManager();
  AvatarState _avatarState = AvatarState.idle;
  late String _transcript;
  late String _lastResponse;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _transcript = '';
    _lastResponse = '';
    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    await _voiceManager.initialize();
    
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
        
        await _voiceManager.speak(response);
        
        if (mounted) setState(() => _avatarState = AvatarState.idle);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = context.l10n.error(e.toString());
          _avatarState = AvatarState.idle;
        });
      }
    }
  }

  void _toggleListening() {
    final l10n = context.l10n;
    
    if (_isListening) {
      _voiceManager.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() {
         _isListening = true;
         _transcript = l10n.listening;
      });
      
      _voiceManager.startListening(
        onResult: (text) {
           if (mounted) setState(() => _transcript = text);
        },
        onListeningStateChanged: (isListening) {
           if (mounted) {
              setState(() => _isListening = isListening);
              if (!isListening && _transcript.isNotEmpty && _transcript != l10n.listening) {
                 _sendMessageToAI(_transcript);
              }
           }
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    // Set initial values if empty
    if (_transcript.isEmpty) _transcript = l10n.pressMicToSpeak;
    if (_lastResponse.isEmpty) _lastResponse = l10n.connectingToOfficer;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppHeader(title: l10n.interviewInProgress),
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
                          style: context.textTheme.titleMedium?.copyWith(
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
                   style: context.textTheme.bodyLarge?.copyWith(
                     color: _isListening ? AppTheme.errorRed : Colors.grey.shade600,
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
                        color: _isListening ? AppTheme.errorRed : AppTheme.actionBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(
                             color: _isListening ? AppTheme.errorRed.withOpacity(0.5) : Colors.black26, 
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
