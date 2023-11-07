import 'package:dandani/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dandani/pages/mainContent.dart';
import 'package:dandani/pages/login.dart';
import 'package:dandani/pages/home.dart';
import 'package:dandani/pages/detail.dart';
import 'package:dandani/pages/account.dart';

import 'package:dandani/providers/mitra.dart';
import 'package:dandani/providers/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userEmail = prefs.getString('user_email');

  runApp(MyApp(isUserLoggedIn: userEmail != null ? '/maincontent' : '/login'));

  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String isUserLoggedIn;
  MyApp({required this.isUserLoggedIn});

  final ThemeData appTheme = ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: purplePrimary),
    primaryColor: purplePrimary,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MitraProvider()),
      ],
      child: MaterialApp(
        theme: appTheme,
        title: 'Dandani',
        initialRoute: isUserLoggedIn,
        routes: {
          '/login': (context) => LoginPage(),
          '/maincontent': (context) => MainContent(),
          '/home': (context) => HomePage(),
          '/detail': (context) => DetailPage(),
          '/account': (context) => AccountPage(),
        },
      ),
    );
  }
}
