class Message {
  final String messageId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}
