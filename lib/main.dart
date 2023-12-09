import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notification_permissions/notification_permissions.dart';
// Pages
import 'package:dandani/pages/splash.dart';
import 'package:dandani/pages/mainContent.dart';
import 'package:dandani/pages/login.dart';
import 'package:dandani/pages/home.dart';
import 'package:dandani/pages/detail.dart';
import 'package:dandani/pages/account.dart';
import 'package:dandani/pages/chat.dart';
// Util
import 'package:dandani/util/colors.dart';
// Provider
import 'package:dandani/providers/authProvider.dart';
import 'package:dandani/providers/userProvider.dart';
import 'package:dandani/providers/mitraProvider.dart';
import 'package:dandani/providers/listChatProvider.dart';
import 'package:dandani/providers/chatProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationPermissions.requestNotificationPermissions();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData appTheme = ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: purplePrimary),
    primaryColor: purplePrimary,
    primarySwatch: Colors.deepPurple,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MitraProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ConversationProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        theme: appTheme,
        title: 'Dandani',
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginPage(),
          '/maincontent': (context) => MainContent(),
          '/home': (context) => HomePage(),
          '/detail': (context) => DetailPage(),
          '/chat': (context) => ChatPage(),
          '/account': (context) => AccountPage(),
        },
      ),
    );
  }
}
