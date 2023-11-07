import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:dandani/util/colors.dart';

import 'package:dandani/pages/home.dart';
import 'package:dandani/pages/chat.dart';
import 'package:dandani/pages/mitra.dart';
import 'package:dandani/pages/account.dart';

class MainContent extends StatefulWidget {
  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  // Bottom Navigation
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ListChatPage(),
    MitraPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
