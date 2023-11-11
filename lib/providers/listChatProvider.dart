import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dandani/models/conversationsModel.dart';
import 'package:dandani/models/messagesModel.dart';

class ConversationProvider with ChangeNotifier {
  var userLoggedEmail;

  // Get Active Conversation
  Conversation? _activeConversation;
  Conversation? get activeConversation => _activeConversation;

  void setActiveConversation(Conversation conversation) {
    _activeConversation = conversation;
    notifyListeners();
  }

  // Get Conversation
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  ConversationProvider() {
    getConversations().then((conversations) {
      _conversations = conversations;
      notifyListeners();
    });
  }

  Future<List<Conversation>> getConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('user_email') ?? '';

    userLoggedEmail = userEmail;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: userEmail)
              .get();

      List<Conversation> conversations =
          await Future.wait(querySnapshot.docs.map((doc) async {
        QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await doc
            .reference
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .get();

        List<Message> messages = messagesSnapshot.docs.map((messageDoc) {
          return Message(
            senderId: messageDoc['senderId'],
            content: messageDoc['content'],
            timestamp: (messageDoc['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        return Conversation(
          id: doc.id,
          title: doc.data()['title'],
          participants: List<String>.from(doc['participants']),
          messages: messages,
        );
      }));

      _conversations = conversations;
      notifyListeners();
      return conversations;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Conversation>> getConversationsByEmail(
      String title, mitraEmail) async {
    Conversation loadConversations = Conversation(
      id: '-',
      title: title,
      participants: List<String>.from([userLoggedEmail, mitraEmail]),
      messages: List<Message>.empty(),
    );

    setActiveConversation(loadConversations);

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: userLoggedEmail)
              .where('title', isEqualTo: title)
              .get();

      if (querySnapshot.docs.length > 0) {
        List<Conversation> conversations =
            await Future.wait(querySnapshot.docs.map((doc) async {
          QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await doc
              .reference
              .collection('messages')
              .orderBy('timestamp', descending: false)
              .get();

          List<Message> messages = messagesSnapshot.docs.map((messageDoc) {
            return Message(
              senderId: messageDoc['senderId'],
              content: messageDoc['content'],
              timestamp: (messageDoc['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

          return Conversation(
            id: doc.id,
            title: doc.data()['title'],
            participants: List<String>.from(doc['participants']),
            messages: messages,
          );
        }));

        setActiveConversation(conversations.first);
      } else {
        Conversation conversations = Conversation(
          id: '-',
          title: title,
          participants: List<String>.from([userLoggedEmail, mitraEmail]),
          messages: List<Message>.empty(),
        );

        setActiveConversation(conversations);
      }

      notifyListeners();
      return conversations;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
