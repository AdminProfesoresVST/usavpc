import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/services/ai_repository.dart';
import 'package:mobile/widgets/feedback_card.dart';
import 'package:mobile/services/voice_manager.dart';
import 'package:mobile/widgets/waveform_visualizer.dart';
import 'package:mobile/widgets/consul_bubble.dart';
import 'package:mobile/widgets/user_bubble.dart';
import 'package:mobile/models/chat_message.dart';
import 'package:mobile/models/simulator_models.dart';
import 'package:mobile/services/dashboard_repository_impl.dart';

/// Chat interface for voice-based interview simulation with full i18n.
/// Updated: 2026-01-23 - Chat bubbles UI redesign with message history
/// Design: Consul messages appear as elegant left-aligned text, user messages
/// appear as right-aligned chat bubbles. Full conversation history is preserved.
class Ds160InterviewSimulatorScreen extends ConsumerStatefulWidget {
  const Ds160InterviewSimulatorScreen({super.key});

  @override
  ConsumerState<Ds160InterviewSimulatorScreen> createState() => _Ds160InterviewSimulatorScreenState();
}

class _Ds160InterviewSimulatorScreenState extends ConsumerState<Ds160InterviewSimulatorScreen> {
  final VoiceManager _voiceManager = VoiceManager();
  final ScrollController _scrollController = ScrollController();
  AvatarState _avatarState = AvatarState.idle;
  
  // Message History - Full conversation persists
  final List<ChatMessage> _messages = [];
  
  // State Variables
  SimulatorFeedback? _lastFeedback;
  Map<String, dynamic>? _userProfile;
  bool _isListening = false;
  bool _isLoadingProfile = true;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileAndInit();
  }

  Future<void> _loadProfileAndInit() async {
    try {
      final result = await ref.read(dashboardRepositoryProvider).getProfileData();
      final app = result['app'] as Map<String, dynamic>?;
      if (app != null) {
        _userProfile = app['form_data'];
      }
    } catch (e) {
      // Error loading profile, but we continue
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }

    await _voiceManager.initialize();
    
    // Start immediately with explicit greeting request
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 100), () => _startSimulation());
    }
  }

  @override
  void dispose() {
    _voiceManager.stopSpeaking();
    _voiceManager.stopListening();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startSimulation() async {
    // Send a hidden system prompt to force a greeting
    await _sendMessageToAI("SYSTEM_START_INTERVIEW_GREETING"); 
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessageToAI(String? userMessage) async {
    bool isSystemMessage = userMessage == "SYSTEM_START_INTERVIEW_GREETING";
    
    // Add user message to history (if not system message)
    if (!isSystemMessage && userMessage != null && userMessage.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(sender: ChatSender.user, text: userMessage));
      });
      _scrollToBottom();
    }
    
    if (mounted) {
       setState(() {
          _avatarState = AvatarState.thinking;
       });
    }

    try {
      // Send raw message to fixed AiRepository (Simulator Mode)
      // Profile data is passed to AI for context-aware responses
      final simResponse = await ref.read(aiRepositoryProvider).sendSimulatorInteraction(
        message: userMessage ?? context.l10n.startInterview, 
        visaType: 'B1/B2',
        profileData: _userProfile 
      );

      if (mounted) {
        setState(() {
          _avatarState = AvatarState.speaking;
          // Add consul response to message history
          _messages.add(ChatMessage(sender: ChatSender.consul, text: simResponse.textToSpeak));
          _lastFeedback = simResponse.feedback; 
        });
        _scrollToBottom();
        
        await _voiceManager.speak(simResponse.textToSpeak);
        
        if (mounted) setState(() => _avatarState = AvatarState.idle);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(sender: ChatSender.consul, text: context.l10n.error(e.toString())));
          _avatarState = AvatarState.idle;
        });
        _scrollToBottom();
      }
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _voiceManager.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      _textController.clear(); 
      
      _voiceManager.startListening(
        onResult: (text) {
           if (mounted) {
              setState(() => _textController.text = text);
           }
        },
        onListeningStateChanged: (isListening) {
           if (mounted) {
              setState(() => _isListening = isListening);
              if (!isListening && _textController.text.isNotEmpty) {
                 _sendMessageToAI(_textController.text);
                 _textController.clear();
              }
           }
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.inkInverse,
      appBar: AppHeader(
        title: l10n.simulatorTitle,  // i18n compliant
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.inkInverse),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Avatar & Status Area (Compact)
          Container(
            padding: AppTheme.paddingVertical,
            decoration: BoxDecoration(
              color: AppTheme.inkInverse,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dividerGrey,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dynamic Visualizer: Avatar OR Waveform
                // Dynamic Visualizer: Always Visible Waveform
                Center(
                  child: SizedBox(
                    height: 60,
                    child: WaveformVisualizer(
                      isActive: _avatarState == AvatarState.speaking, // True = High Energy, False = Idle Wave
                      barCount: 20,
                    ),
                  ),
                ),
                
                // Feedback Card (if available)
                if (_lastFeedback != null) 
                  Padding(
                    padding: AppTheme.paddingHorizontal.copyWith(top: AppTheme.espacioEntreGrupos),
                    child: FeedbackCard(feedback: _lastFeedback!),
                  ),
              ],
            ),
          ),
          
          // Chat Messages Area (Scrollable)
          Expanded(
            child: _isLoadingProfile
                ? const Center(child: CircularProgressIndicator(color: AppTheme.actionBlue))
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          l10n.connectingToOfficer,
                          style: AppTheme.bodyPrimaryRegular.copyWith(color: AppTheme.inkSecondary),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: AppTheme.paddingEstandar,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return message.isConsul
                              ? ConsulBubble(text: message.text)
                              : UserBubble(text: message.text);
                        },
                      ),
          ),
          
          // Minimalist Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: AppTheme.inkInverse,
              border: Border(top: BorderSide(color: AppTheme.cardBorderColor, width: 1)),
            ),
            child: Row(
               children: [
                   // Mic Button (Small, Left)
                   GestureDetector(
                     onTap: _toggleListening,
                     child: Container(
                       width: 36,
                       height: 36,
                       decoration: BoxDecoration(
                         color: _isListening ? AppTheme.errorRedLight : AppTheme.dividerGrey,
                         shape: BoxShape.circle,
                       ),
                       child: Icon(
                         _isListening ? Icons.stop : Icons.mic,
                         color: _isListening ? AppTheme.errorRed : AppTheme.inkSecondary,
                         size: AppTheme.iconoMini,
                       ),
                     ),
                   ),
                   const SizedBox(width: 12),
                   // Text Input (Clean)
                   Expanded(
                     child: Container(
                       height: 40,
                       decoration: BoxDecoration(
                         color: AppTheme.dividerGreyLight,
                         borderRadius: AppTheme.badgeRadius,
                         border: Border.all(color: AppTheme.cardBorderColor),
                       ),
                       child: TextField(
                         controller: _textController,
                         style: AppTheme.labelRegular.copyWith(color: AppTheme.navyPrimary),
                         decoration: InputDecoration(
                           hintText: _isListening ? l10n.listening : l10n.typeYourResponse,
                           hintStyle: AppTheme.labelRegular.copyWith(color: AppTheme.inkSecondary),
                           border: InputBorder.none,
                           contentPadding: AppTheme.paddingCampo,
                           isDense: true,
                           suffixIcon: _textController.text.isNotEmpty
                               ? GestureDetector(
                                   onTap: () {
                                     _sendMessageToAI(_textController.text);
                                     _textController.clear();
                                   },
                                   child: Container(
                                     margin: const EdgeInsets.only(right: AppTheme.espacioEntreLabelInput),
                                     child: Icon(
                                       Icons.send_rounded,
                                       color: AppTheme.actionBlue,
                                       size: AppTheme.iconoEnTarjeta,
                                     ),
                                   ),
                                 )
                               : null,
                         ),
                         onSubmitted: (value) {
                           if (value.trim().isNotEmpty) {
                             _sendMessageToAI(value);
                             _textController.clear();
                           }
                         },
                         onChanged: (text) => setState(() {}),
                       ),
                     ),
                   ),
               ],
            ),
          ),
        ],
      ),
    );
  }
}
