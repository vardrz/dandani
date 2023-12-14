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
              .orderBy('timestamp', descending: true)
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
            messageId: messageDoc.id,
            senderId: messageDoc['senderId'],
            content: messageDoc['content'],
            timestamp: (messageDoc['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        return Conversation(
          id: doc.id,
          title: doc.data()['title'],
          read: doc.data()['read'],
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

  Future<List<Conversation>> getConversationsByMitra(
      String title, mitraEmail) async {
    Conversation loadConversations = Conversation(
      id: '-',
      title: title,
      read: true,
      participants: List<String>.from([userLoggedEmail, mitraEmail]),
      messages: List<Message>.empty(),
    );

    setActiveConversation(loadConversations);

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('participants', isEqualTo: [userLoggedEmail, mitraEmail])
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
              messageId: messageDoc.id,
              senderId: messageDoc['senderId'],
              content: messageDoc['content'],
              timestamp: (messageDoc['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

          return Conversation(
            id: doc.id,
            title: doc.data()['title'],
            read: doc.data()['read'],
            participants: List<String>.from(doc['participants']),
            messages: messages,
          );
        }));

        setActiveConversation(conversations.first);
      } else {
        Conversation conversations = Conversation(
          id: '-',
          title: title,
          read: true,
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

  Future<void> refreshConversation(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance.collection('chats').doc(id).get();

      if (documentSnapshot.exists) {
        List<Message> messages = [];
        QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(id)
                .collection('messages')
                .orderBy('timestamp')
                .get();

        messages = messagesSnapshot.docs.map((messageDoc) {
          return Message(
            messageId: messageDoc.id,
            senderId: messageDoc['senderId'],
            content: messageDoc['content'],
            timestamp: (messageDoc['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        Conversation conversation = Conversation(
          id: documentSnapshot.id,
          title: documentSnapshot.data()?['title'],
          read: documentSnapshot.data()?['read'],
          participants: List<String>.from(documentSnapshot['participants']),
          messages: messages,
        );

        setActiveConversation(conversation);
      } else {
        print('Dokumen dengan ID $id tidak ditemukan.');
      }

      notifyListeners();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> createConversationAndSendMessage(
      String mitraEmail, mitraName, content) async {
    try {
      // Create new chat and send message
      CollectionReference chatsRef =
          FirebaseFirestore.instance.collection('chats');

      DocumentReference newChat = await chatsRef.add({
        'participants': [userLoggedEmail, mitraEmail],
        'timestamp': Timestamp.now(),
        'title': mitraName,
        'read': true
      });
      CollectionReference sendMessage = newChat.collection('messages');
      await sendMessage.add({
        'senderId': userLoggedEmail,
        'content': content,
        'timestamp': Timestamp.now(),
      });

      // Store to activeConversation
      String newChatId = newChat.id;

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(newChatId)
              .get();

      List<Message> messages = [];
      QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(newChatId)
              .collection('messages')
              .orderBy('timestamp')
              .get();

      messages = messagesSnapshot.docs.map((messageDoc) {
        return Message(
          messageId: messageDoc.id,
          senderId: messageDoc['senderId'],
          content: messageDoc['content'],
          timestamp: (messageDoc['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      Conversation conversation = Conversation(
        id: documentSnapshot.id,
        title: documentSnapshot.data()?['title'],
        read: documentSnapshot.data()?['read'],
        participants: List<String>.from(documentSnapshot['participants']),
        messages: messages,
      );

      setActiveConversation(conversation);

      notifyListeners();
    } catch (e) {
      print('Error creating conversation and sending message: $e');
    }
  }

  Future<void> readConversation(String conversationId) async {
    try {
      // update read
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .update({'read': true});
    } catch (e) {
      print('Error update read: $e');
      throw e;
    }
  }
}
