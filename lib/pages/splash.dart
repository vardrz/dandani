import 'package:dandani/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: purplePrimary,
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Image.asset("assets/logo-white.png",
            width: MediaQuery.of(context).size.width * 0.7),
      ),
      asyncNavigationCallback: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userEmail = prefs.getString('user_email');
        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacementNamed(
            context, userEmail != null ? '/maincontent' : '/login');
      },
    );
  }
}
