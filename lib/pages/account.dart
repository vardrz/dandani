import 'package:dandani/util/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'package:dandani/providers/userProvider.dart';
import 'package:dandani/providers/authProvider.dart';

class AccountPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Transform.flip(
                  flipY: true,
                  child: WaveWidget(
                    config: CustomConfig(
                      colors: [
                        purpleSecondary,
                        purplePrimary,
                      ],
                      durations: [
                        5000,
                        4000,
                      ],
                      heightPercentages: [
                        -1.00,
                        -0.85,
                      ],
                    ),
                    backgroundColor: Colors.transparent,
                    size: Size(double.infinity, 100),
                    waveAmplitude: 0,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.13,
                    // top: 100,
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 30),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage('assets/load.gif'),
                          foregroundImage: NetworkImage(user.photo),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => print('Edit Foto User'),
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.only(bottom: 25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: purplePrimary,
                          ),
                          child: Icon(Ionicons.sync, color: white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Divider(
                        color: grey,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Icon(Icons.person),
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  user.name,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: grey,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Icon(Icons.mail),
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  user.email,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: grey,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Icon(Icons.maps_home_work),
                            ),
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                (user.address == ''
                                    ? 'Alamat belum di atur'
                                    : user.address),
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: grey,
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Press Edit Profile");
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 20, bottom: 5),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: purplePrimary,
                          ),
                          child: Center(
                              child: Text(
                            'Edit Profile',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: white),
                          )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Logout'),
                                content: Text('Logout dari akun ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .signOut();
                                      print(
                                          "UnsubscribeToTopic: ${user.email.replaceAll('@', '')}");
                                      FirebaseMessaging.instance
                                          .unsubscribeFromTopic(
                                              user.email.replaceAll('@', ''));
                                      Navigator.of(context)
                                          .pushReplacementNamed('/login');
                                    },
                                    child: Text('Ya'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: grey,
                          ),
                          child: Center(
                              child: Text(
                            'Logout',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: white),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
