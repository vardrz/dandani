import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dandani/models/detailUserModel.dart';

class UserProvider with ChangeNotifier {
  late User _user;
  User get user => _user;

  UserProvider() {
    getUserData().then((userData) {
      _user = userData;
      notifyListeners();
    }).catchError((error) {
      throw Exception('Failed to get user data: $error');
    });
  }

  Future<User> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('user_email') ?? '';

    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      QuerySnapshot<Object?> querySnapshot =
          await users.where('email', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        var dataUser =
            (querySnapshot.docs.first.data() as Map<String, dynamic>);
        return User.fromJson(dataUser);
      } else {
        throw Exception(
            'Pengguna dengan email $userEmail tidak ditemukan di Database.');
      }
    } catch (e) {
      throw Exception('Failed: $e');
    }
  }

  Future<void> updateUserData(String newEmail) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      QuerySnapshot<Object?> querySnapshot =
          await users.where('email', isEqualTo: newEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        var dataUser =
            (querySnapshot.docs.first.data() as Map<String, dynamic>);
        _user = User.fromJson(dataUser);
        notifyListeners();
      } else {
        throw Exception(
            'Pengguna dengan email $newEmail tidak ditemukan di Database.');
      }
    } catch (e) {
      throw Exception('Gagal memperbarui data pengguna: $e');
    }
  }
}
