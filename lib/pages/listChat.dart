import 'package:dandani/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dandani/providers/listChatProvider.dart';

class ListChatPage extends StatefulWidget {
  @override
  State<ListChatPage> createState() => _ListChatPageState();
}

class _ListChatPageState extends State<ListChatPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // start: refress notif when from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("app in resume");
      Provider.of<ConversationProvider>(context, listen: false)
          .getConversations();
    } else if (state == AppLifecycleState.paused) {
      print("app in paused");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
                  backgroundImage: conversation.participants[1] == userEmail
                      ? AssetImage('assets/images/user.webp')
                      : AssetImage('assets/images/service.webp'),
                ),
                title: FittedBox(
                  alignment: Alignment.topLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    (conversation.participants[1] == userEmail)
                        ? conversation.participants[0]
                        : conversation.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                subtitle: Text(
                  lastMessage,
                  style: TextStyle(
                      fontWeight: !conversation.read &&
                              conversation.messages.last.senderId != userEmail
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                trailing: Visibility(
                  visible: !conversation.read &&
                      conversation.messages.last.senderId != userEmail,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: purplePrimary,
                    ),
                  ),
                ),
                onTap: () {
                  var conversationProvider =
                      Provider.of<ConversationProvider>(context, listen: false);

                  conversationProvider.setActiveConversation(conversation);
                  if (!conversation.read &&
                      conversation.messages.last.senderId != userEmail) {
                    conversationProvider.readConversation(conversation.id);
                    conversationProvider.getConversations();
                  }
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
