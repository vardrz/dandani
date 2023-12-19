import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:dandani/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'package:dandani/pages/accountUpdate.dart';
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdatePpPage(
                                currentPhoto: user.photo,
                                email: user.email,
                                uid: user.uid,
                              ),
                            ),
                          );
                        },
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
                            Flexible(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountUpdate(
                                docid: user.uid,
                                name: user.name,
                                address: user.address == '' ? '' : user.address,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 20, bottom: 5),
                          height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: purplePrimary,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_document,
                                size: 15,
                                color: white,
                              ),
                              Text(
                                '  Edit Profile',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: white),
                              ),
                            ],
                          ),
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
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: grey,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                size: 15,
                                color: white,
                              ),
                              Text(
                                '  Logout',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: white),
                              ),
                            ],
                          ),
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

class UpdatePpPage extends StatefulWidget {
  final String currentPhoto;
  final String email;
  final String uid;

  const UpdatePpPage({
    Key? key,
    required this.currentPhoto,
    required this.email,
    required this.uid,
  }) : super(key: key);

  @override
  State<UpdatePpPage> createState() => _UpdatePpPageState();
}

class _UpdatePpPageState extends State<UpdatePpPage> {
  String currentPhoto = '', email = '';
  bool picked = false, loading = false;
  late File cacheImage; // show after pick image

  @override
  void initState() {
    super.initState();
    email = widget.email;
    currentPhoto = widget.currentPhoto;
  }

  upload() async {
    final storage = FirebaseStorage.instance;
    final reference = storage.ref().child(
        'account/${email.replaceAll('@gmail.com', '')}${path.extension(cacheImage.path)}');

    reference.putFile(cacheImage).whenComplete(() async {
      final url = await reference.getDownloadURL();
      print(url);

      Provider.of<UserProvider>(context, listen: false)
          .updatePhoto(widget.uid, url);

      setState(() => loading = false);
      Navigator.pop(context);
    });
  }

  pickImg() async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    print(path.extension(pickedFile!.path));
    print(await File(pickedFile.path).length());

    setState(() {
      picked = true;
      cacheImage = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Container(
                    padding: EdgeInsets.only(bottom: 30),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('assets/load.gif'),
                      foregroundImage: picked
                          ? FileImage(cacheImage)
                          : NetworkImage(currentPhoto) as ImageProvider,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      pickImg();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: purplePrimary,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_search, size: 15, color: white),
                          Text(
                            '  Pilih Foto',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (picked) {
                        setState(() => loading = true);
                        upload();
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Container(
                              height: 100,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: purplePrimary, width: 5))),
                              child: Row(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: Icon(
                                        Icons.dangerous_outlined,
                                        size: 30,
                                      )),
                                  Expanded(
                                    child: Text(
                                      'Tidak ada perubahan!',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: purpleSecondary,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_outlined,
                              size: 15, color: white),
                          Text(
                            '  Simpan Perubahan',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 30, bottom: 50),
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: grey,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_circle_left_outlined,
                            size: 15,
                            color: white,
                          ),
                          Text(
                            '  Kembali',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: loading, child: CircularProgressIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
