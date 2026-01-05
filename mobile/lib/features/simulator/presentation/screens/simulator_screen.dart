import 'package:flutter/material.dart';
import 'package:mobile/features/simulator/presentation/widgets/avatar_widget.dart';
import 'package:mobile/features/simulator/presentation/widgets/voice_controls.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  bool _isListening = false;
  AvatarState _avatarState = AvatarState.idle;

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      _avatarState = _isListening ? AvatarState.speaking : AvatarState.thinking;
      
      // Simulate thought process
      if (!_isListening) {
           Future.delayed(const Duration(seconds: 2), () {
               if (mounted) setState(() => _avatarState = AvatarState.idle);
           });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Simulator')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AvatarWidget(state: _avatarState, size: 250),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                  _avatarState == AvatarState.speaking 
                      ? "Listening..." 
                      : _avatarState == AvatarState.thinking 
                          ? "Officer is thinking..." 
                          : "Press the mic to answer the officer's question.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
              ),
          ),
          const SizedBox(height: 32),
          VoiceControls(
            isListening: _isListening,
            onToggleListening: _toggleListening,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
