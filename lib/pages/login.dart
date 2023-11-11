import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

import 'package:dandani/util/colors.dart';

import 'package:dandani/providers/authProvider.dart';

Future<bool> redirect() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userEmail = prefs.getString('user_email') ?? '';
  return userEmail != '' && userEmail.isNotEmpty;
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: purplePrimary,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(-10, 0),
              child: Image.asset(
                "assets/logo-white.png",
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                'Masuk atau Daftar dengan akun Google anda.',
                style: TextStyle(fontSize: 25, color: white),
              ),
            ),
            FutureBuilder<bool>(
              future: redirect(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  bool isUserLoggedIn = snapshot.data ?? false;

                  if (isUserLoggedIn) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/maincontent');
                    });
                    return SizedBox.shrink();
                  } else {
                    return SocialLoginButton(
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      text: 'Masuk',
                      buttonType: SocialLoginButtonType.google,
                      borderRadius: 30,
                      fontSize: 17,
                      onPressed: () async {
                        await authProvider.signInWithGoogle();
                      },
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
