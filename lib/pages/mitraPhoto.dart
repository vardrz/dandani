import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dandani/providers/mitraProvider.dart';

import 'package:dandani/util/colors.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class PhotoMitra extends StatefulWidget {
  final String email;

  const PhotoMitra({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<PhotoMitra> createState() => _PhotoMitraState();
}

class _PhotoMitraState extends State<PhotoMitra> {
  String email = '', currentPhoto = '';
  int countPhoto = 0;
  // late List<String> photo;

  bool loading = false;
  late File cacheImage;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://dandani.vaard.site/mitras/$email'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      setState(() {
        if (jsonResponse.first['photo'].contains('default.jpg')) {
          countPhoto = 0;
        } else {
          countPhoto = jsonResponse.first['photo'].toString().split(',').length;
          currentPhoto = jsonResponse.first['photo'];
        }
      });
      print(countPhoto);
    } else {
      throw Exception('Gagal memuat data dari API');
    }
  }

  drop(String link) async {
    var postPhoto = currentPhoto.replaceAll('$link,', '');
    print(postPhoto);

    FirebaseStorage.instance.refFromURL(link).delete();

    Provider.of<MitraProvider>(context, listen: false)
        .updatePhotoMitra(email, postPhoto);
    fetchData();
    Navigator.pop(context);
  }

  upload() async {
    var filename = Random().nextInt(100) + 200;

    final storage = FirebaseStorage.instance;
    final reference = storage.ref().child(
        'mitras/${email.replaceAll('@gmail.com', '')}/$filename${path.extension(cacheImage.path)}');

    reference.putFile(cacheImage).whenComplete(() async {
      final url = await reference.getDownloadURL();

      var postPhoto = currentPhoto != '' ? "$currentPhoto$url," : "$url,";

      Provider.of<MitraProvider>(context, listen: false)
          .updatePhotoMitra(email, postPhoto);
      fetchData();
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
      cacheImage = File(pickedFile!.path);
    });

    upload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              flexibleSpace: Stack(
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
                          -0.25,
                          -0.15,
                        ],
                      ),
                      backgroundColor: Colors.transparent,
                      size: Size(double.infinity, 100),
                      waveAmplitude: 0,
                    ),
                  ),
                  Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 35),
                      child: Text(
                        "Kelola Foto",
                        style: TextStyle(color: white, fontSize: 20),
                      )),
                ],
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    Visibility(
                      visible: countPhoto > 0,
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: currentPhoto
                            .split(',')
                            .map(
                              (link) => link != ''
                                  ? InkWell(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Hapus Foto'),
                                              content: Text(
                                                  'Hapus foto ini dari daftar?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    drop(link);
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width: 60,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: purplePrimary),
                                                    child: Text(
                                                      'Hapus',
                                                      style: TextStyle(
                                                          color: white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            link,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 50),
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            width: 250,
                                            height: 180,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            )
                            .toList(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        pickImg();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          border: Border(
                            top: BorderSide(color: grey, width: 1),
                            right: BorderSide(color: grey, width: 1),
                            bottom: BorderSide(color: grey, width: 1),
                            left: BorderSide(color: grey, width: 1),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 15, color: grey),
                            Text(
                              '  Tambah Foto',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: grey),
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
      ),
    );
  }

  void _showError(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 100,
          alignment: Alignment.center,
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: purplePrimary, width: 5))),
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
                  'Ada yang masih belum benar, silahkan cek lagi!',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
