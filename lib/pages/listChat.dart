import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dandani/providers/listChatProvider.dart';

class ListChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Chat')),
      ),
      body: Consumer<ConversationProvider>(
        builder: (context, conversationProvider, child) {
          var conversations = conversationProvider.conversations;
          var userEmail = conversationProvider.userLoggedEmail;
          return ListView.separated(
            padding: EdgeInsets.only(top: 10),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              var conversation = conversations[index];
              var lastMessage = conversation.messages.isNotEmpty
                  ? (conversation.messages.last.senderId == userEmail)
                      ? (conversation.messages.last.content.length > 20)
                          ? 'Me: ' +
                              conversation.messages.last.content
                                  .replaceAll("\n", " ")
                                  .substring(0, 20) +
                              '...'
                          : 'Me: ' +
                              conversation.messages.last.content
                                  .replaceAll("\n", " ")
                      : (conversation.messages.last.content.length > 20)
                          ? conversation.messages.last.content
                                  .replaceAll("\n", " ")
                                  .substring(0, 20) +
                              '...'
                          : conversation.messages.last.content
                              .replaceAll("\n", " ")
                  : '...';

              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://cdn3d.iconscout.com/3d/premium/thumb/young-man-5748694-4800737.png'),
                ),
                title: Text(
                  (conversation.participants[1] == userEmail)
                      ? conversation.participants[0]
                      : conversation.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(lastMessage),
                onTap: () {
                  var conversationProvider =
                      Provider.of<ConversationProvider>(context, listen: false);
                  conversationProvider.setActiveConversation(conversation);
                  Navigator.pushNamed(context, '/chat');
                },
              );
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: Colors.grey,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
