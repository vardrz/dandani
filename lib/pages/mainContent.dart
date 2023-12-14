import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:dandani/providers/userProvider.dart';
import 'package:dandani/providers/listChatProvider.dart';

import 'package:dandani/util/colors.dart';

import 'package:dandani/pages/home.dart';
import 'package:dandani/pages/listChat.dart';
import 'package:dandani/pages/mitra.dart';
import 'package:dandani/pages/account.dart';

class MainContent extends StatefulWidget {
  final bool fromMitraRegist;

  const MainContent({Key? key, required this.fromMitraRegist})
      : super(key: key);

  @override
  State<MainContent> createState() => _MainContentState();
  // _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  int _selectedIndex = 0; // selected index fro Bottom Navigation

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    widget.fromMitraRegist ? _selectedIndex = 2 : _selectedIndex = 0;
  }

  Future<void> _initializeUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('user_email') ?? '';
    String? notifReceiver = prefs.getString('user_email')?.replaceAll('@', '');
    // Init userData & chat
    Provider.of<UserProvider>(context, listen: false).updateUserData(userEmail);
    Provider.of<ConversationProvider>(context, listen: false)
        .getConversations();
    // Init Topic FCM
    if (notifReceiver != null && notifReceiver.isNotEmpty) {
      print("SubscribeToTopic: " + notifReceiver);
      await FirebaseMessaging.instance.subscribeToTopic(notifReceiver);
    } else {
      print('Error: Topik tidak valid.');
    }
  }

  // Bottom Navigation
  final List<Widget> _pages = [
    HomePage(),
    ListChatPage(),
    MitraPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // if notif received
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got message on foreground!');
      Provider.of<ConversationProvider>(context, listen: false)
          .getConversations();
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked: $message");
      Provider.of<ConversationProvider>(context, listen: false)
          .getConversations();
    });

    return WillPopScope(
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SalomonBottomBar(
              backgroundColor: white,
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              items: [
                SalomonBottomBarItem(
                  icon: Icon(Icons.home),
                  title: Text("Home"),
                  selectedColor: purplePrimary,
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.message),
                  title: Text("Chat"),
                  selectedColor: purplePrimary,
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.store),
                  title: Text("Mitra"),
                  selectedColor: purplePrimary,
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.person),
                  title: Text("Akun"),
                  selectedColor: purplePrimary,
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          // Tampilkan dialog konfirmasi
          bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Konfirmasi'),
                content: Text('Keluar dari aplikasi?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Tutup dialog dan kembalikan nilai true
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Ya'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Tutup dialog dan kembalikan nilai false
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: purplePrimary),
                      child: Text(
                        'Tidak',
                        style: TextStyle(color: white),
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          // Return `false` jika pengguna membatalkan keluar
          return confirm;
        });
  }
}
