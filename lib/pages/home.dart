import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:provider/provider.dart';
import 'package:dandani/providers/userProvider.dart';

import 'package:dandani/models/listMitraModel.dart';
import 'package:dandani/util/colors.dart';
import 'package:dandani/widgets/widget.dart';
import 'package:dandani/pages/search.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Slider Image
  static final List<String> imgList = [
    'banner1.png',
    'banner2.png',
    'banner3.png'
  ];

  // Slider
  final CarouselSlider autoPlayImage = CarouselSlider(
    options: CarouselOptions(
      autoPlay: true,
      aspectRatio: 3.0,
      // enlargeCenterPage: true,
    ),
    items: imgList.map((fileImage) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/${fileImage}',
          ),
        ),
      );
    }).toList(),
  );

  // API
  String address = "";
  late Future<List<ListMitra>> mitras;
  late Timer refreshData;

  @override
  void initState() {
    super.initState();
    mitras = fetchAPI();

    refreshData = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        mitras = fetchAPI();
      });
    });
  }

  Future<List<ListMitra>> fetchAPI() async {
    final http.Response response;
    if (address != "") {
      final Uri url = Uri.parse('http://dandani.vaard.site/api/district');
      final Map<String, String> body = {
        'province': address.split(',')[0],
        'city': address.split(',')[1],
        'district': address.split(',')[2],
      };

      response = await http.post(url, body: body);
    } else {
      response = await http.get(Uri.parse('http://dandani.vaard.site/mitras'));
    }

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<ListMitra> mitraList =
          jsonList.map((json) => ListMitra.fromJson(json)).toList();
      return mitraList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _search = TextEditingController();
    var user = Provider.of<UserProvider>(context).user;
    setState(() {
      address = user.address;
    });

    return Scaffold(
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
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 40, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/logo-white.png',
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          iconSize: 25,
                          color: Colors.white,
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.7),
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Cari'),
                                  content: TextField(
                                    controller: _search,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: 'Cari tempat servis ...',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Batal',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          String search = _search.text;
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SearchPage(
                                                search: search,
                                                city: "",
                                                district: "",
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Cari',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: purplePrimary,
                                          shadowColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Slide Banner
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                    margin: EdgeInsets.only(top: 30), child: autoPlayImage),
              ),
              // Kategori
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        kategoriWidget(
                          text: 'Laptop',
                          keyword: 'laptop',
                          icon: Icons.laptop,
                          searchController: _search,
                        ),
                        kategoriWidget(
                          text: 'Handphone',
                          keyword: 'hp',
                          icon: Icons.smartphone,
                          searchController: _search,
                        ),
                        kategoriWidget(
                          text: 'Televisi',
                          keyword: 'tv',
                          icon: Icons.tv,
                          searchController: _search,
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          kategoriWidget(
                            text: 'AC',
                            keyword: 'ac',
                            icon: Icons.ac_unit,
                            searchController: _search,
                          ),
                          kategoriWidget(
                            text: 'Motor',
                            keyword: 'motor',
                            icon: Icons.motorcycle,
                            searchController: _search,
                          ),
                          kategoriWidget(
                            text: 'Lainnya',
                            keyword: 'search',
                            icon: Icons.electrical_services,
                            searchController: _search,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // List Jasa
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Show
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 30),
                      child: FutureBuilder(
                        future: mitras,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<ListMitra> mitraList = snapshot.data!;
                            return StaggeredGridView.countBuilder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              itemCount: mitraList.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  jasaListWidget(
                                account: mitraList[index].account,
                                name: mitraList[index].name,
                                desc: mitraList[index].desc,
                                specialist: mitraList[index].specialist,
                                whatsapp: mitraList[index].whatsapp,
                                province: mitraList[index].province,
                                city: mitraList[index].city,
                                district: mitraList[index].district,
                                maps: mitraList[index].maps,
                                photo: mitraList[index].photo,
                              ),
                              staggeredTileBuilder: (int index) =>
                                  StaggeredTile.fit(1),
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 80),
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        'Tidak Ditemukan',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ),
                                    Text(
                                      'Data tempat service di alamat anda belum tersedia, coba cari di alamat lain.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: const CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SEKITARMU',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.7),
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Cari'),
                                    content: TextField(
                                      controller: _search,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: 'Cari tempat servis ...',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Batal',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            String search = _search.text;
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchPage(
                                                  search: search,
                                                  city: "",
                                                  district: "",
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Cari',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: purplePrimary,
                                            shadowColor: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0)),
                            child: Text(
                              'Cari Jasa',
                              style: TextStyle(
                                  color: purpleSecondary,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
