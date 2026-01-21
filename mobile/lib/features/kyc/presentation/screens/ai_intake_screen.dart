import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';

/// AI-powered chat intake with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class AiIntakeScreen extends ConsumerStatefulWidget {
  const AiIntakeScreen({super.key});

  @override
  ConsumerState<AiIntakeScreen> createState() => _AiIntakeScreenState();
}

class _AiIntakeScreenState extends ConsumerState<AiIntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _formData = {};
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final app = await supabase
            .from('applications')
            .select('form_data')
            .eq('user_id', userId)
            .maybeSingle();
        if (app != null && app['form_data'] != null) {
          _formData = Map<String, dynamic>.from(app['form_data']);
        }
      }

      final questions = await supabase
          .from('ds160_questions')
          .select()
          .eq('is_active', true)
          .order('section')
          .order('section_order');

      _questions = (questions as List).where((q) {
        if (q['skip_if_ocr'] == true && _formData[q['field_key']] != null) {
          return false;
        }
        if (q['depends_on'] != null && q['depends_on_value'] != null) {
          final dependValue = _formData[q['depends_on']];
          if (dependValue != q['depends_on_value']) {
            return false;
          }
        }
        return true;
      }).toList().cast<Map<String, dynamic>>();

      setState(() => _isLoading = false);
      _askNextQuestion();
    } catch (e) {
      setState(() => _isLoading = false);
      _addBotMessage(context.l10n.loadingQuestionsError(e.toString()));
    }
  }

  void _addBotMessage(String text, {List<String>? tips, String? example}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        tips: tips,
        example: example,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
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

  void _askNextQuestion() {
    if (_currentQuestionIndex >= _questions.length) {
      _completeIntake();
      return;
    }

    final question = _questions[_currentQuestionIndex];
    final tips = (question['tips'] as List?)?.cast<String>() ?? [];
    final example = question['example_good'] as String?;
    final questionText = question['question_friendly'] as String;
    
    _addBotMessage(questionText, tips: tips, example: example);
  }

  Future<void> _handleSend() async {
    if (_isSending) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _addUserMessage(text);
    _controller.clear();
    setState(() => _isSending = true);

    try {
      final question = _questions[_currentQuestionIndex];
      final fieldKey = question['field_key'] as String;
      
      final validationRegex = question['validation_regex'] as String?;
      if (validationRegex != null && !RegExp(validationRegex).hasMatch(text)) {
        final errorMsg = question['validation_error'] as String? ?? 
            context.l10n.validationError;
        _addBotMessage(errorMsg);
        setState(() => _isSending = false);
        return;
      }

      _formData[fieldKey] = text;
      
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('applications').upsert({
          'user_id': userId,
          'form_data': _formData,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }

      _currentQuestionIndex++;
      _askNextQuestion();
    } catch (e) {
      _addBotMessage(context.l10n.savingError(e.toString()));
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _completeIntake() {
    _addBotMessage(context.l10n.intakeComplete);
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            isAction: true,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalQuestions = _questions.length;
    final answeredQuestions = _currentQuestionIndex;
    final progress = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeaderWithProgress(
        title: l10n.ds160Assistant,
        subtitle: totalQuestions > 0 
            ? l10n.questionProgress(answeredQuestions + 1, totalQuestions)
            : null,
        progress: progress,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _ChatBubble(
                      message: _messages[index],
                      onAction: () => context.push('/dashboard'),
                    ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
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
                    borderSide: BorderSide.none,
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
                onPressed: _isSending ? null : _handleSend,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
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
  final List<String>? tips;
  final String? example;
  final bool isAction;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.tips,
    this.example,
    this.isAction = false,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAction;

  const _ChatBubble({required this.message, this.onAction});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    if (message.isAction) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ElevatedButton(
          onPressed: onAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(l10n.viewMyApplication, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.navyPrimary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: isUser ? null : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
          if (message.tips != null && message.tips!.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 8, top: 4),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 6),
                      Text(l10n.tips, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...message.tips!.map((tip) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: Colors.amber.shade800)),
                        Expanded(child: Text(tip, style: TextStyle(fontSize: 12, color: Colors.amber.shade900))),
                      ],
                    ),
                  )),
                  if (message.example != null) ...[
                    const SizedBox(height: 6),
                    Text('${l10n.example}: ${message.example}', 
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.amber.shade800)),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
