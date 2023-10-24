import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:dandani/providers/homeAPI.dart';

import 'package:dandani/util/colors.dart';
import 'package:dandani/widgets/widget.dart';

import 'package:dandani/pages/account.dart';
import 'package:dandani/pages/chat.dart';
import 'package:dandani/pages/mitra.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Bottom Navigation
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    ListChatPage(),
    MitraPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 10, // Penyebaran bayangan
                blurRadius: 20, // Ketajaman bayangan
                offset: Offset(0, 2), // Posisi bayangan (x, y)
              ),
            ],
          ),
          child: MoltenBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            // borderSize: 2,
            borderColor: purplePrimary,
            barColor: white,
            domeCircleColor: purplePrimary,
            borderRaduis: BorderRadius.all(Radius.zero),
            tabs: [
              MoltenTab(
                  icon: Icon(Icons.home),
                  selectedColor: white,
                  unselectedColor: grey),
              MoltenTab(
                  icon: Icon(Icons.chat_bubble),
                  selectedColor: white,
                  unselectedColor: grey),
              MoltenTab(
                  icon: Icon(Icons.store),
                  selectedColor: white,
                  unselectedColor: grey),
              MoltenTab(
                  icon: Icon(Icons.account_circle),
                  selectedColor: white,
                  unselectedColor: grey),
            ],
          ),
        ));
  }
}

class HomePageContent extends StatelessWidget {
  // Slider Image
  static final List<String> imgList = [
    'dummy-banner.jpg',
    'dummy-banner.jpg',
    'dummy-banner.jpg'
  ];

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

  @override
  Widget build(BuildContext context) {
    final listMitras = Provider.of<HomeApiProvider>(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              flexibleSpace: Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 40, bottom: 5),
                color: purplePrimary,
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
                        print('pressed search');
                      },
                    ),
                  ],
                ),
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
                child: autoPlayImage,
              ),
              // Kategori
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'KATEGORI',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                            onPressed: () {
                              print('pressed all category');
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0)),
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(color: purpleSecondary),
                            ))
                      ],
                    ),
                    // Show
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        kategoriWidget(
                          text: 'Laptop',
                          icon: Icons.laptop,
                        ),
                        kategoriWidget(
                          text: 'Handphone',
                          icon: Icons.smartphone,
                        ),
                        kategoriWidget(
                          text: 'Televisi',
                          icon: Icons.tv,
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
                            icon: Icons.ac_unit,
                          ),
                          kategoriWidget(
                            text: 'Kendaraan',
                            icon: Icons.motorcycle,
                          ),
                          kategoriWidget(
                            text: 'Lainnya',
                            icon: Icons.electrical_services,
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
                child: Column(
                  children: [
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
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0)),
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(color: purpleSecondary),
                            ))
                      ],
                    ),
                    // Show
                    FutureBuilder(
                      future: listMitras.fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          return ListView.builder(
                            itemCount: listMitras.mitra.length,
                            itemBuilder: (context, index) {
                              final mitra = listMitras.mitra[index];
                              return ListTile(
                                title: Text(mitra['name']),
                              );
                            },
                          );
                        }
                      },
                    ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     for (var i = 0; i < 3; i++) ...[
                    //       jasaListWidget(
                    //           nama: 'Semoga berkah Computer',
                    //           specialist: 'Laptop',
                    //           alamat: 'Pekalongan',
                    //           foto: 'assets/dummy-banner.jpg'),
                    //     ],
                    //   ],
                    // )
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
