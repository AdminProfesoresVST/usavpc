import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/kyc/data/ai_repository.dart';

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
    // Initial Greeting - This can be local or fetched. Keeping local for speed.
    Future.delayed(const Duration(milliseconds: 500), () {
      _addBotMessage('¡Hola! Soy tu asistente virtual. Vamos a completar tu formulario para la visa ${widget.visaType.toUpperCase()}.');
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) async {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Real API Call
      final response = await ref.read(aiRepositoryProvider).sendMessage(
        message: text,
        visaType: widget.visaType,
      );
      _addBotMessage(response);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')),
      );
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
    if (_isLoading) return; // Prevent double send
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _addUserMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Asistente Consular',
              style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Trámite ${widget.visaType.toUpperCase()}',
              style: GoogleFonts.publicSans(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF112E51), // Navy
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF112E51)),
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
    print(message);
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF112E51) : Colors.white,
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
          style: GoogleFonts.publicSans(
            color: isUser ? Colors.white : const Color(0xFF334155),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
