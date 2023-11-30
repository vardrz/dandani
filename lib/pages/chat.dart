import 'package:dandani/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

import 'package:dandani/providers/chatProvider.dart';
import 'package:dandani/providers/listChatProvider.dart';
import 'package:dandani/models/conversationsModel.dart';
import 'package:dandani/models/messagesModel.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _msgId = ''; // Menampung Message ID yang akan diberi aksi
  bool _actionButton = false; // Appbar Action Show
  bool _showScrollButton = false; // Scroll to bottom
  bool _onloadScroll = true; // Scroll to bottom
  bool _emptyMessage = true; // Scroll to bottom
  late ScrollController _scrollController;

  // First Load
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      setState(() {
        _showScrollButton = _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  // Function scroll to bottom
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messageStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(Provider.of<ConversationProvider>(context).activeConversation?.id)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final conversationProvider = Provider.of<ConversationProvider>(context);

    Conversation? activeConversation = conversationProvider.activeConversation;
    var userEmail = conversationProvider.userLoggedEmail;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(_actionButton
              ? 'Aksi'
              : (activeConversation!.participants[1] == userEmail)
                  ? activeConversation.participants[0]
                  : activeConversation.title),
        ),
        actions: [
          if (_actionButton)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                chatProvider.dropMessage(activeConversation!.id, _msgId);
                conversationProvider.getConversations();
                // conversationProvider.refreshConversation(activeConversation.id);

                setState(() {
                  _actionButton = false;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: messageStream(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Jika data tersedia, tampilkan dalam UI
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages =
                snapshot.data!.docs;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_onloadScroll) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
                setState(() {
                  _onloadScroll = false;
                });
              }
            });

            return GestureDetector(
              onTap: () => setState(() {
                _actionButton ? _actionButton = false : [];
              }),
              child: Stack(
                children: [
                  if (activeConversation!.messages.isEmpty) ...[
                    Visibility(
                      visible: _emptyMessage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 30,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: Color(0xFFE8E8EE),
                            ),
                            child: Center(
                                child: Text(
                              'Belum ada Pesan',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            )),
                          ),
                        ],
                      ),
                    )
                  ],
                  Container(
                    margin: EdgeInsets.only(bottom: 60),
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 20, bottom: 30),
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final messageData = messages[index].data();
                        final Message message = Message(
                          messageId: messages[index].id,
                          senderId: messageData['senderId'],
                          content: messageData['content'],
                          timestamp:
                              (messageData['timestamp'] as Timestamp).toDate(),
                        );

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _actionButton = false;
                            });
                          },
                          onLongPress: () {
                            if (message.senderId == userEmail) {
                              setState(() {
                                _msgId = message.messageId;
                                _actionButton = true;
                              });
                            }
                          },
                          child: BubbleSpecialThree(
                            text: message.content,
                            color: (message.senderId == userEmail)
                                ? purplePrimary
                                : Color(0xFFE8E8EE),
                            tail: true,
                            textStyle: TextStyle(
                                color: (message.senderId == userEmail)
                                    ? white
                                    : Colors.black,
                                fontSize: 16),
                            isSender:
                                (message.senderId == userEmail) ? true : false,
                          ),
                        );
                      },
                    ),
                  ),
                  MessageBar(
                    onSend: (content) async {
                      try {
                        FocusScope.of(context).unfocus(); // Hide Keyboard
                        // Send Message
                        if (activeConversation.id == '-') {
                          await conversationProvider
                              .createConversationAndSendMessage(
                                  activeConversation.participants[1],
                                  activeConversation.title,
                                  content);
                        } else {
                          await chatProvider.sendMessage(
                              activeConversation.id, userEmail, content);
                        }
                        conversationProvider
                            .getConversations(); // Refress List Conversation
                        setState(() =>
                            _emptyMessage = false); // Hide 'belum ada pesan'
                        _scrollController.jumpTo(_scrollController
                            .position.maxScrollExtent); // Scroll end

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pesan berhasil dikirim!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } catch (e) {
                        print('Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal mengirim pesan!')),
                        );
                      }
                    },
                    actions: [
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.camera_alt,
                            color: purplePrimary,
                            size: 24,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                    sendButtonColor: purplePrimary,
                    messageBarHitText: "Ketik pesan ...",
                  ),
                ],
              ),
            );
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: _showScrollButton
          ? Container(
              margin: EdgeInsets.only(bottom: 60),
              child: FloatingActionButton(
                onPressed: _scrollToBottom,
                mini: true,
                child: Icon(Icons.arrow_downward),
              ),
            )
          : null,
    );
  }
}
