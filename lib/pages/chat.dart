import 'package:dandani/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
// import 'package:dandani/providers/chatProvider.dart';
import 'package:dandani/providers/listChatProvider.dart';
import 'package:dandani/models/conversationsModel.dart';
import 'package:dandani/models/messagesModel.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Chat? chat = Provider.of<ChatProvider>(context).chat;
    Conversation? activeConversation =
        Provider.of<ConversationProvider>(context).activeConversation;

    var userEmail = Provider.of<ConversationProvider>(context).userLoggedEmail;
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
            fit: BoxFit.contain,
            child: Text((activeConversation!.participants[1] == userEmail)
                ? activeConversation.participants[0]
                : activeConversation.title)),
      ),
      body: Stack(
        children: [
          if (activeConversation.messages.isEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 30,
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
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
          ],
          ListView.builder(
            padding: EdgeInsets.only(top: 20),
            itemCount: activeConversation.messages.length,
            itemBuilder: (context, index) {
              Message message = activeConversation.messages[index];
              return BubbleSpecialThree(
                text: message.content,
                color: (message.senderId == userEmail)
                    ? purplePrimary
                    : Color(0xFFE8E8EE),
                tail: true,
                textStyle: TextStyle(
                    color:
                        (message.senderId == userEmail) ? white : Colors.black,
                    fontSize: 16),
                isSender: (message.senderId == userEmail) ? true : false,
              );
            },
          ),
          MessageBar(
            onSend: (content) => print(content),
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
}
