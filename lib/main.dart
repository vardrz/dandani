import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dandani/pages/login.dart';
import 'package:dandani/pages/home.dart';
import 'package:dandani/pages/account.dart';

import 'package:dandani/providers/auth.dart';
import 'package:dandani/providers/homeAPI.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userEmail = prefs.getString('user_email');

  runApp(MyApp(isUserLoggedIn: userEmail != null ? '/home' : '/login'));

  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String isUserLoggedIn;
  MyApp({required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HomeApiProvider()),
      ],
      child: MaterialApp(
        title: 'Dandani',
        initialRoute: isUserLoggedIn,
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/account': (context) => AccountPage(),
        },
      ),
    );
  }
}
