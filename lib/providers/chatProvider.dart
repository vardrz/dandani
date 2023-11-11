import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  Chat? _chat;
  Chat? get chat => _chat;

  void setChat(Chat chat) {
    _chat = chat;
    notifyListeners();
  }
}

class Chat {
  final String userLoggedEmail;
  final String userMitraEmail;
  final String userMitraName;

  Chat(
    this.userLoggedEmail,
    this.userMitraEmail,
    this.userMitraName,
  );
}
