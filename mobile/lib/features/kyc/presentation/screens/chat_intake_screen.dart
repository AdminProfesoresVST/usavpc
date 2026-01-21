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

    // SYSTEM INSTRUCTION: Force the AI to acknowledge context and follow strict order
    final systemInstruction = """
SYSTEM_INSTRUCTION:
1. CONTEXT: The user is applying for a ${widget.visaType} visa.
2. VERIFIED DATA: Use these confirmed details, DO NOT ask for them again:
   - Surname: ${surname ?? 'Provided'}
   - Passport Number: ${passport ?? 'Provided'}
   - Date of Birth: ${dob ?? 'Provided'}
   - Nationality: ${state.uri.queryParameters['nationality'] ?? 'Provided'}
   - Given Name: ${state.uri.queryParameters['given_name'] ?? 'Provided'}

3. STRICT ORDER: You MUST ask questions in this exact order corresponding to the DS-160 form:
   - Step 1: Personal Address & Phone (Current)
   - Step 2: Passport Details (Only if missing details like City of Issuance)
   - Step 3: Travel Plans (Purpose, Arrival Date, Length of Stay, Address in US)
   - Step 4: Travel Companions
   - Step 5: Previous US Travel
   - Step 6: U.S. Contact (Person or Organization)
   - Step 7: Family Information (Father, Mother, Spouse)
   - Step 8: Work / Education / Training (Current & Previous)
   - Step 9: Security & Background

4. CURRENT TASK: Start immediately with Step 1 (Address & Phone). 
   - Ask: "What is your current home address?"
   - Do NOT ask "How long did you work there?" until Step 8.
   - Do NOT ask for Name/DOB/Passport Number (already verified).

5. DATA EXTRACTION & POLISHING:
   - Listen to the user's answer.
   - REWRITE/POLISH the answer to be formal and official (e.g. if user says "i live in new york", polish to "New York, NY, USA").
   - Extract the standardized data into a JSON block: [[UPDATE: {"field_name": "Polished Value"}]]
   - Example response: "Got it. And what is your phone number? [[UPDATE: {"home_address": "123 Main St, New York, NY, 10001, USA"}]]"
""";

    _sendMessage(systemInstruction, customContext: initialContext, isSystemPrompt: true); 
  }

  void _addBotMessage(String fullText) {
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
