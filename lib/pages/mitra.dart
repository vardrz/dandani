import 'dart:convert';
import 'dart:async';
import 'package:dandani/pages/mitraPhoto.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dandani/util/colors.dart';
import 'package:dandani/pages/mitraRegist.dart';
import 'package:change_case/change_case.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

import 'package:dandani/pages/mitraUpdate.dart';
import 'package:dandani/providers/mitraProvider.dart';
import 'package:dandani/models/detailMitraModel.dart';

class Data {
  final String account;
  final String name;
  final String desc;
  final String specialist;
  final String whatsapp;
  final String province;
  final String city;
  final String district;
  final String maps;
  final String photo;

  Data({
    required this.account,
    required this.name,
    required this.desc,
    required this.specialist,
    required this.whatsapp,
    required this.province,
    required this.city,
    required this.district,
    required this.maps,
    required this.photo,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      account: json['account'],
      name: json['name'],
      desc: json['desc'],
      specialist: json['specialist'],
      whatsapp: json['whatsapp'],
      province: json['province'],
      city: json['city'],
      district: json['district'],
      maps: json['maps'] ?? '',
      photo: json['photo'],
    );
  }
}

class MitraPage extends StatefulWidget {
  @override
  State<MitraPage> createState() => _MitraPageState();
}

class _MitraPageState extends State<MitraPage> {
  late Future<List<Data>> mitras;
  late Timer refreshData;

  void initState() {
    super.initState();
    mitras = fetchData();

    refreshData = Timer.periodic(Duration(seconds: 10), (timer) {
      print("refress");
      setState(() {
        mitras = fetchData();
      });
    });
  }

  Future<List<Data>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    final response =
        await http.get(Uri.parse('https://dandani.vaard.site/mitras/$email'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Data.fromJson(data)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Gagal memuat data dari API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Data>>(
          future: mitras,
          builder: (context, snapshot) {
            return Stack(
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
                _listView(snapshot, context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _listView(AsyncSnapshot snapshot, BuildContext context) {
    // if (snapshot.connectionState == ConnectionState.waiting) {
    //   return Center(child: CircularProgressIndicator());
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (snapshot.data == null || snapshot.data!.isEmpty) {
      return BeforeRegister();
    } else {
      return Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                margin: EdgeInsets.only(top: 70),
                padding: EdgeInsets.only(bottom: 30),
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/load.gif'),
                  foregroundImage:
                      snapshot.data[0].photo.toString().contains('default.jpg')
                          ? AssetImage('assets/images/default.jpg')
                          : NetworkImage(snapshot.data[0].photo.split(',')[0])
                              as ImageProvider,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PhotoMitra(email: snapshot.data[0].account),
                    ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 13, bottom: 28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: purplePrimary,
                  ),
                  child: Icon(Ionicons.sync, color: white),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
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
                            child: Icon(Ionicons.storefront_outline),
                          ),
                          Flexible(
                            child: Text(
                              snapshot.data[0].name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                            child: Icon(Ionicons.location_outline),
                          ),
                          Flexible(
                            child: Text(
                              snapshot.data[0].district
                                      .toString()
                                      .toCapitalCase() +
                                  ", " +
                                  snapshot.data[0].city
                                      .toString()
                                      .toCapitalCase(),
                              style: TextStyle(fontSize: 18),
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
                            child: Icon(Ionicons.build_outline),
                          ),
                          Flexible(
                            child: Text(
                              snapshot.data[0].specialist
                                  .toString()
                                  .replaceAll(', ', ',')
                                  .replaceAll(',', ', ')
                                  .toTitleCase(),
                              style: TextStyle(fontSize: 18),
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
                            child: Icon(Ionicons.logo_whatsapp),
                          ),
                          Flexible(
                            child: Text(
                              snapshot.data[0].whatsapp
                                  .toString()
                                  .replaceAll('6208', '628'),
                              style: TextStyle(fontSize: 18),
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
                        final Mitra mitra = Mitra(
                          snapshot.data[0].account,
                          snapshot.data[0].name,
                          snapshot.data[0].desc,
                          snapshot.data[0].specialist,
                          snapshot.data[0].whatsapp,
                          snapshot.data[0].province,
                          snapshot.data[0].city.toString().toCapitalCase(),
                          snapshot.data[0].district.toString().toCapitalCase(),
                          snapshot.data[0].maps,
                          snapshot.data[0].photo,
                        );
                        Provider.of<MitraProvider>(context, listen: false)
                            .setMitra(mitra);
                        Navigator.pushNamed(context, '/detail');
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 20, bottom: 5),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: purpleSecondary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                              color: white,
                            ),
                            Text(
                              '  Lihat Jasa',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MitraUpdate(
                              name: snapshot.data[0].name,
                              desc: snapshot.data[0].desc,
                              specialist: snapshot.data[0].specialist,
                              whatsapp: snapshot.data[0].whatsapp,
                              province: snapshot.data[0].province,
                              city: snapshot.data[0].city,
                              district: snapshot.data[0].district,
                              maps: snapshot.data[0].maps,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 30),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: purplePrimary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_document,
                              size: 15,
                              color: white,
                            ),
                            Text(
                              '  Edit Data Mitra',
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
      );
    }
  }
}

class BeforeRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purplePrimary,
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                "Gabung Mitra",
                style: TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold, color: white),
              ),
            ),
            Text(
              "Promosikan jasa anda di aplikasi Dandani agar lebih banyak dijangkau orang.",
              style: TextStyle(fontSize: 20, color: white),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegistMitra()));
              },
              child: Container(
                margin: EdgeInsets.only(top: 30),
                width: 200,
                height: 37,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: white),
                child: Center(
                  child: Text(
                    "Gabung",
                    style: TextStyle(
                        color: purplePrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
