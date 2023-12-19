import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'package:dandani/util/colors.dart';

import 'package:dandani/providers/authProvider.dart';

Future<bool> redirect() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userEmail = prefs.getString('user_email') ?? '';
  return userEmail != '' && userEmail.isNotEmpty;
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String textLogin;

  @override
  void initState() {
    textLogin = "Masuk";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.flip(
            flipY: true,
            child: WaveWidget(
              config: CustomConfig(
                colors: [purpleSecondary, purplePrimary],
                durations: [
                  5000,
                  4000,
                ],
                heightPercentages: [
                  -1.00,
                  -0.55,
                ],
              ),
              backgroundColor: Colors.transparent,
              size: Size(double.infinity, 50),
              waveAmplitude: 0,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: Offset(-13, 20),
                  child: Image.asset(
                    "assets/logo-purple.png",
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, bottom: 30),
                  child: Text(
                    'Masuk atau Daftar dengan akun Google anda.',
                    style: TextStyle(
                        fontSize: 20,
                        // fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.lato().fontFamily,
                        color: purplePrimary),
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
                          // Navigator.pushReplacementNamed(context, '/maincontent');
                          Timer(Duration(seconds: 1), () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/maincontent', (route) => false);
                          });
                        });
                        return SocialLoginButton(
                          backgroundColor: purpleSecondary,
                          textColor: white,
                          text: "Success",
                          buttonType: SocialLoginButtonType.google,
                          borderRadius: 30,
                          fontSize: 17,
                          onPressed: () {},
                        );
                      } else {
                        return SocialLoginButton(
                          backgroundColor: purplePrimary,
                          textColor: white,
                          text: textLogin,
                          buttonType: SocialLoginButtonType.google,
                          borderRadius: 30,
                          fontSize: 17,
                          onPressed: () async {
                            setState(() => textLogin = 'Sign in ...');
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
          WaveWidget(
            config: CustomConfig(
              colors: [purpleSecondary, purplePrimary],
              durations: [
                5000,
                4000,
              ],
              heightPercentages: [
                -1.00,
                -0.55,
              ],
            ),
            backgroundColor: Colors.transparent,
            size: Size(double.infinity, 30),
            waveAmplitude: 0,
          ),
        ],
      ),
    );
  }
}
