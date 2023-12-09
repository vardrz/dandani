import 'package:dandani/models/messagesModel.dart';

class Conversation {
  final String id;
  final String title;
  final bool read;
  final List<String> participants;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.read,
    required this.participants,
    required this.messages,
  });
}
