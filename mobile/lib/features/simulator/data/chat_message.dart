/// Model for chat messages in the simulator interview.
/// Created: 2026-01-23 - Chat bubbles UI redesign
enum ChatSender { consul, user }

class ChatMessage {
  final ChatSender sender;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isConsul => sender == ChatSender.consul;
  bool get isUser => sender == ChatSender.user;
}
