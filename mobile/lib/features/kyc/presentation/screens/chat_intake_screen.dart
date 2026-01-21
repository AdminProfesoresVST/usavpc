import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/kyc/data/ai_repository.dart';

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

    _sendMessage("", customContext: initialContext); 
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _sendMessage(String text, {Map<String, dynamic>? customContext}) async {
    if (text.isNotEmpty) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: text, isUser: true));
          _isLoading = true;
        });
      }
      _scrollToBottom();
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
