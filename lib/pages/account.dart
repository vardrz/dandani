import 'package:dandani/util/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(100),
                        bottomLeft: Radius.circular(100)),
                    color: purplePrimary,
                  ),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  // padding: EdgeInsets.only(top: 60),
                  // child:
                ),
                Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 23,
                                letterSpacing: 2,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/load.gif'),
                          foregroundImage: NetworkImage(user.photo),
                        ),
                      ],
                    )),
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
                              padding: const EdgeInsets.only(right: 50),
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
                              padding: const EdgeInsets.only(right: 50),
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
                              padding: const EdgeInsets.only(right: 50),
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
                      InkWell(
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
                      InkWell(
                        onTap: () async {
                          Provider.of<AuthProvider>(context, listen: false)
                              .signOut();
                          print("UnsubscribeToTopic: " +
                              user.email.replaceAll('@', ''));
                          await FirebaseMessaging.instance.unsubscribeFromTopic(
                              user.email.replaceAll('@', ''));
                          Navigator.of(context).pushReplacementNamed('/login');
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
