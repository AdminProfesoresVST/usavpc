import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/network/supabase_client.dart';

/// AI-powered chat intake that asks DS-160 questions one at a time.
/// Fetches questions from database, shows tips, and saves responses.
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
      
      // Load user's existing form data
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

      // Load questions (skip OCR fields if already captured)
      final questions = await supabase
          .from('ds160_questions')
          .select()
          .eq('is_active', true)
          .order('section')
          .order('section_order');

      _questions = (questions as List).where((q) {
        // Skip if OCR already captured and we have the data
        if (q['skip_if_ocr'] == true && _formData[q['field_key']] != null) {
          return false;
        }
        // Skip if depends on another field that doesn't match
        if (q['depends_on'] != null && q['depends_on_value'] != null) {
          final dependValue = _formData[q['depends_on']];
          if (dependValue != q['depends_on_value']) {
            return false;
          }
        }
        return true;
      }).toList().cast<Map<String, dynamic>>();

      setState(() => _isLoading = false);
      
      // Start conversation
      _askNextQuestion();
    } catch (e) {
      setState(() => _isLoading = false);
      _addBotMessage('Error cargando preguntas: $e');
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
    
    // Use friendly question format for chat
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
      
      // Validate response
      final validationRegex = question['validation_regex'] as String?;
      if (validationRegex != null && !RegExp(validationRegex).hasMatch(text)) {
        final errorMsg = question['validation_error'] as String? ?? 
            'Hmm, eso no parece correcto. ¿Puedes verificar?';
        _addBotMessage(errorMsg);
        setState(() => _isSending = false);
        return;
      }

      // Save to form data
      _formData[fieldKey] = text;
      
      // Save to database
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('applications').upsert({
          'user_id': userId,
          'form_data': _formData,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }

      // Move to next question
      _currentQuestionIndex++;
      _askNextQuestion();
    } catch (e) {
      _addBotMessage('Error guardando: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _completeIntake() {
    _addBotMessage(
      '🎉 ¡Excelente! Has completado todas las preguntas. '
      'Tu información está guardada y lista para generar tu formulario DS-160.',
    );
    
    // Show completion button
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
    final totalQuestions = _questions.length;
    final answeredQuestions = _currentQuestionIndex;
    final progress = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            Text('Asistente DS-160', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.bold)),
            if (!_isLoading)
              Text(
                'Pregunta ${answeredQuestions + 1} de $totalQuestions',
                style: GoogleFonts.publicSans(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF112E51),
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: _isLoading ? null : PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
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
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildInputArea() {
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
                  hintText: 'Escribe tu respuesta...',
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
                color: Color(0xFF112E51),
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
          child: const Text('VER MI SOLICITUD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF112E51) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: isUser ? null : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Text(
              message.text,
              style: GoogleFonts.publicSans(
                color: isUser ? Colors.white : const Color(0xFF334155),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          // Tips section
          if (message.tips != null && message.tips!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8, top: 4),
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
                      Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...message.tips!.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
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
                    Text('Ejemplo: ${message.example}', 
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
