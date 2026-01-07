
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/simulator/presentation/widgets/avatar_widget.dart';
import 'package:mobile/features/kyc/data/ai_repository.dart';

class ChatInterfaceScreen extends ConsumerStatefulWidget {
  const ChatInterfaceScreen({super.key});

  @override
  ConsumerState<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends ConsumerState<ChatInterfaceScreen> {
  AvatarState _avatarState = AvatarState.idle;
  String _transcript = "Presione el botón para hablar...";
  String _lastResponse = "Conectando con el Oficial Consular...";
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    // Trigger initial greeting from AI
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSimulation());
  }

  Future<void> _startSimulation() async {
    await _sendMessageToAI(null); // Null message triggers greeting in Simulator Mode
  }

  Future<void> _sendMessageToAI(String? userMessage) async {
    setState(() {
      _avatarState = AvatarState.thinking;
    });

    try {
      final response = await ref.read(aiRepositoryProvider).sendMessage(
        message: userMessage ?? "", // Send empty string for greeting if null, or handle in repo? Repo takes String.
        // Actually, route.ts checks if (!answer) for greeting. 
        // We should explicitly handle the greeting logic differently or pass null if modified.
        // Repo requires String. Let's send empty string and hope backend handles it or we modify repo to allow null/empty.
        // Wait, route.ts: "const { answer ... } = body". If answer is "", !answer is true. So empty string works.
        visaType: 'B1/B2',
        mode: 'simulator'
      );

      if (mounted) {
        setState(() {
          _avatarState = AvatarState.speaking;
          _lastResponse = response;
          if (userMessage != null) _transcript = userMessage; // Show what user said (or mocked receipt)
        });
        
        // Simulate Speaking Duration based on length
        final duration = Duration(milliseconds: response.length * 50 + 1000);
        Future.delayed(duration, () {
           if(mounted) setState(() => _avatarState = AvatarState.idle);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = "Error de conexión: ${e.toString()}";
          _avatarState = AvatarState.idle;
        });
      }
    }
  }

  // Temporary function to simulate Voice Input (Speech-to-Text would go here)
  void _simulateUserSpeech() {
    setState(() {
      _avatarState = AvatarState.idle; 
      _transcript = "Escuchando...";
    });
    
    // For now, we pop up a text input dialogue to "Simulate" speech since we don't have STT module ready/imported.
    // The user said "el maldito chat debe funcionar realmente". 
    // Real function = Text Input acting as Voice Transcript.
    
    showDialog(
      context: context, 
      builder: (c) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: const Text("Simular Voz (Input)"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Lo que dirías al oficial..."),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(c);
                _sendMessageToAI(_controller.text);
              }, 
              child: const Text("ENVIAR")
            )
          ],
        );
      }
    );
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
                     color: Colors.grey.shade600,
                     fontStyle: FontStyle.italic,
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
                    onTap: _simulateUserSpeech, // Click to Speak (Text Input for reliability)
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.actionBlue,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 36),
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
