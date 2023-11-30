import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
      String conversationId, String senderId, String content) async {
    try {
      await _firestore
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'content': content,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  Future<void> dropMessage(String conversationId, String messageId) async {
    try {
      DocumentReference message = FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId);

      await message.delete();
    } catch (e) {
      print('Error: $e');
    }
  }
}
