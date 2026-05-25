enum MessageRole { user, assistant }
enum MessageType { text, quickActions }

class ChatMessage {
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}