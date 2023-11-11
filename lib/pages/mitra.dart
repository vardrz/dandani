import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dandani/widgets/widget.dart';
import 'package:dandani/util/colors.dart';

class MitraPage extends StatefulWidget {
  @override
  State<MitraPage> createState() => _MitraPageState();
}

class _MitraPageState extends State<MitraPage> {
  Future<List<Data>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    final response =
        await http.get(Uri.parse('https://dandani.vaard.site/mitras/$email'));
    // 'https://dandani.vaard.site/mitras/berkahcomputer@gmail.com'));

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
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder<List<Data>>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return BeforeRegister();
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircleAvatar(
                              radius: 100,
                              backgroundImage:
                                  NetworkImage(snapshot.data![index].photo),
                            ),
                          ),
                          Text(
                            snapshot.data![index].name,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(snapshot.data![index].district +
                              ", " +
                              snapshot.data![index].city),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: BadgeWidget(
                                specialist: snapshot.data![index].specialist),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: purplePrimary,
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  // Navigator.of(context).pushReplacementNamed('/editMitra');
                                  print("to edit " +
                                      snapshot.data![index].account);
                                },
                                child: Text(
                                  "Edit Profile Mitra",
                                  style: TextStyle(
                                    color: white,
                                  ),
                                )),
                          )
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class Data {
  final String account;
  final String name;
  final String specialist;
  final String district;
  final String city;
  final String photo;
  final String maps;

  Data(
      {required this.account,
      required this.name,
      required this.specialist,
      required this.district,
      required this.city,
      required this.photo,
      required this.maps});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      account: json['account'],
      name: json['name'],
      specialist: json['specialist'],
      district: json['district'],
      city: json['city'],
      photo: json['photo'],
      maps: json['maps'] ?? '',
    );
  }
}

class BeforeRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "Promosikan jasa anda di aplikasi Dandani agar lebih banyak dijangkau orang.",
            style: TextStyle(fontSize: 20),
          ),
          InkWell(
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
                  color: purplePrimary),
              child: Center(
                child: Text(
                  "Gabung",
                  style: TextStyle(
                      color: white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RegistMitra extends StatelessWidget {
  const RegistMitra({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gabung Mitra'),
        backgroundColor: purplePrimary,
      ),
      body: Center(
        child: Text("Form Register Mitra"),
      ),
    );
  }
}
