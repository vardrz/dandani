import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> sendNotif(String topic, sender, message) async {
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAzz3OWV4:APA91bFduiij6nTeSTGzfmBHOeGy-YHLa2hzUaT9SrNSZNgd39N0EhlWO9Sk291iewXWPP5d_nbKb-wOO_Vgfib70RVts1qOtspH8g2CbLNdK2fjauD006HQiSxHYbVH09rlYEdJGqxx',
    };

    var body = {
      'notification': {
        'title': 'Pesan Baru',
        'body': sender + ': ' + message,
      },
      'to': '/topics/$topic',
    };

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Notifikasi berhasil dikirim!');
        print(response.body);
      } else {
        print('Gagal mengirim notifikasi - ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
