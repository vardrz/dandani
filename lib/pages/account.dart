import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dandani/providers/auth.dart';

Future<Map<String, String>> getUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userEmail = prefs.getString('user_email') ?? '';
  String userName = prefs.getString('user_name') ?? '';
  String userPhoto = prefs.getString('user_photo') ?? '';

  Map<String, String> userData = {
    'email': userEmail,
    'name': userName,
    'photoURL': userPhoto,
  };

  return userData;
}

class AccountPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No user data available.'));
          } else {
            Map<String, String> userData = snapshot.data!;
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData['photoURL'] ?? ''),
                ),
                SizedBox(height: 20),
                Text(
                  userData['name'] ?? '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(userData['email'] ?? ''),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: EdgeInsets.only(left: 20, right: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .signOut();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: Color(0xffffffff),
                        ),
                      )),
                )
              ],
            ));
          }
        },
      ),
    );
  }
}
