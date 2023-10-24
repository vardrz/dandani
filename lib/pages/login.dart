import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

import 'package:dandani/providers/auth.dart';

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
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/7/7e/Dart-logo.png',
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: 38,
                  right: 35,
                  bottom: 20),
              child: Text(
                'Masuk atau Daftar dengan akun Google anda.',
                style: TextStyle(fontSize: 25),
              )),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
              child: FutureBuilder<bool>(
                future: redirect(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    bool isUserLoggedIn = snapshot.data ?? false;

                    if (isUserLoggedIn) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacementNamed(context, '/home');
                      });
                      return SizedBox.shrink();
                    } else {
                      return SocialLoginButton(
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
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
              )),
        ],
      )),
    );
  }
}
