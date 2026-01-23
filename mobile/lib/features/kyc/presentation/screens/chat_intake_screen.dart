import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/kyc/data/ai_repository.dart';
import 'package:mobile/features/kyc/data/form_persistence_service.dart';
import 'dart:convert';

/// Chat intake screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class ChatIntakeScreen extends ConsumerStatefulWidget {
  final String visaType;

  const ChatIntakeScreen({super.key, required this.visaType});

  @override
  ConsumerState<ChatIntakeScreen> createState() => _ChatIntakeScreenState();
}

class _ChatIntakeScreenState extends ConsumerState<ChatIntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final state = GoRouterState.of(context);
    final surname = state.uri.queryParameters['surname'];
    final passport = state.uri.queryParameters['passport'];
    final dob = state.uri.queryParameters['dob'];

    final initialContext = {
       'visa_type': widget.visaType,
       if (surname != null) 'surname': surname,
       if (passport != null) 'passport_number': passport,
       if (dob != null) 'date_of_birth': dob,
    };

    // SYSTEM INSTRUCTION: Define the AI Persona as an Expert Consultant
    final systemInstruction = """
SYSTEM_INSTRUCTION:
ROLE: You are an expert US Visa Consultant assisting the user with their DS-160 application.
GOAL: Guide the user through the form naturally, like a human professional. Do NOT act like a robot reading a script.

CONTEXT:
- Visa Type: ${widget.visaType}
- Verified Data: Surname=${surname ?? 'Provided'}, Passport=${passport ?? 'Provided'}, DOB=${dob ?? 'Provided'}.

GUIDELINES:
1. **Be "Alive"**: Use natural language. Acknowledge what the user says. If they are unsure, explain WHY you need the information (e.g., "I need your address to know where to mail your documents").
2. **Flexible Flow**: You have a list of sections (Address, Travel, Work, Family), but follow the conversation naturally. If the user mentions their job while talking about travel, ask about the job then.
3. **Data Integrity**: You MUST eventually collect all required DS-160 fields.
4. **Polite & Professional**: Be helpful, patient, and clear.

DATA POLISHING (CRITICAL):
- As the user answers, EXTRACT and POLISH the data into formal format.
- Return the polished data in a hidden JSON block: [[UPDATE: {"field_name": "Formal Value"}]]
- Example: 
  User: "im a teacher at hogwarts"
  AI: "That sounds fascinating. How long have you been teaching there? [[UPDATE: {"occupation": "Teacher", "employer_name": "Hogwarts School"}]]"

START:
Begin by introducing yourself briefly as their assistant and asking for their current address to get started.
""";

    // Inject strict system instruction into the CONTEXT
    final fullContext = {
       ...initialContext,
       'system_instruction': systemInstruction,
    };

    // Send a natural greeting trigger, but the AI will see the system instruction in context
    _sendMessage("Hello, I am ready.", customContext: fullContext, isSystemPrompt: true); 
  }

  void _addBotMessage(String fullText) {
    if (fullText.trim() == "Please answer the question.") return; // Ignore default error response
    // 1. Separate Conversational Text from Data Block
    String displayText = fullText;
    final regex = RegExp(r'\[\[UPDATE:\s*(\{.*?\})\s*\]\]');
    final match = regex.firstMatch(fullText);

    if (match != null) {
      // Extract Clean Text for UI
      displayText = fullText.replaceAll(match.group(0)!, '').trim();
      
      // Parse JSON and Save to DB
      try {
        final jsonStr = match.group(1)!;
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        
        // Save to Supabase (Fire & Forget)
        ref.read(formPersistenceProvider).updateFormData(data);
        debugPrint("✅ Saved polished data: $data");
      } catch (e) {
        debugPrint("❌ Failed to parse/save AI data: $e");
      }
    }

    setState(() {
      _messages.add(ChatMessage(text: displayText, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _sendMessage(String text, {Map<String, dynamic>? customContext, bool isSystemPrompt = false}) async {
    if (text.isNotEmpty) {
      if (mounted && !isSystemPrompt) {
        setState(() {
          _messages.add(ChatMessage(text: text, isUser: true));
          _isLoading = true;
        });
      } else if (mounted && isSystemPrompt) {
         setState(() => _isLoading = true);
      }
      if (!isSystemPrompt) _scrollToBottom();
    } else {
         if (mounted) {
           setState(() => _isLoading = true);
         }
    }

    try {
      final response = await ref.read(aiRepositoryProvider).sendMessage(
        message: text,
        visaType: widget.visaType,
        extraContext: customContext,
      );
      _addBotMessage(response);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.error(e.toString().replaceAll("Exception: ", "")))),
        );
      }
    }
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

  void _handleSend() {
    if (_isLoading) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _sendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeaderWithProgress(
        title: l10n.ds160Assistant,
        subtitle: widget.visaType.toUpperCase(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
          _buildInputArea(l10n),
        ],
      ),
    );
  }

  Widget _buildInputArea(dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.typeYourResponse,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppTheme.navyPrimary),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.navyPrimary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _handleSend,
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.navyPrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          message.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isUser ? Colors.white : Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
