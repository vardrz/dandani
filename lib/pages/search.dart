import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;

import 'package:dandani/models/listMitraModel.dart';
import 'package:dandani/util/colors.dart';
import 'package:dandani/widgets/widget.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class SearchPage extends StatefulWidget {
  final String search;
  final String city;
  final String district;

  const SearchPage({
    Key? key,
    required this.search,
    required this.city,
    required this.district,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  TextEditingController _search = TextEditingController();
  late String search, city, district;
  String filter = '0';
  bool loading = false;

  // API
  late Future<List<ListMitra>> mitras;
  List<Map<String, String>> province = [];

  @override
  void initState() {
    super.initState();
    search = widget.search;
    city = widget.city;
    district = widget.district;

    mitras = fetchAPI();
    fetchProvince();
  }

  Future<List<ListMitra>> fetchAPI() async {
    final response = await http.get(
        Uri.parse('http://dandani.vaard.site/search/$search/$city/$district'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<ListMitra> mitraList =
          jsonList.map((json) => ListMitra.fromJson(json)).toList();
      setState(() => loading = false);
      return mitraList;
    } else {
      setState(() => loading = false);
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchProvince() async {
    final response = await http.get(Uri.parse(
        'https://vardrz.github.io/api-wilayah-indonesia/api/provinces.json'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      for (var data in jsonResponse) {
        setState(() {
          province.add({
            'id': data['id'],
            'name': data['name'],
          });
        });
      }
    } else if (response.statusCode == 404) {
      province = [];
    } else {
      throw Exception('Gagal memuat data dari API');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        Container(
                          margin: EdgeInsets.only(left: 50),
                          child: Text(
                            "Search",
                            style: TextStyle(
                              fontSize: 20,
                              color: white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                                          String key = _search.text;
                                          setState(() {
                                            search = key;
                                            loading = true;

                                            mitras = fetchAPI();
                                          });
                                          Navigator.pop(context);
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
              // List Jasa
              Container(
                margin: EdgeInsets.only(top: 30),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Show
                    if (loading)
                      Container(
                          margin: EdgeInsets.only(top: 80),
                          child: CircularProgressIndicator())
                    else
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
                                itemBuilder:
                                    (BuildContext context, int index) =>
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
                                  child: Column(
                                    children: [
                                      Text(
                                        'Tidak Ditemukan Hasil',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text('Coba cari dengan keyword lain.'),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Container(
                              margin: EdgeInsets.only(top: 80),
                              child: const CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    // Filter
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FutureBuilder(
                            future: mitras,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  "${snapshot.data!.length} hasil pencarian '$search'",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              return Text(
                                "0 hasil pencarian '$search'",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          InkWell(
                            onTap: () => _filter(),
                            child: Text(
                              filter != '0' ? '$filter Filter' : 'Filter',
                              style: const TextStyle(
                                color: purpleSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
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

  void _filter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        List<Map<String, String>> kota = [];
        List<String> kecamatan = [];

        Future<void> fetchKota(id, StateSetter state) async {
          final response = await http.get(Uri.parse(
              'https://vardrz.github.io/api-wilayah-indonesia/api/regencies/${id}.json'));

          if (response.statusCode == 200) {
            var kotaName = '';
            kota = [];
            kecamatan = [];

            List<dynamic> jsonResponse = json.decode(response.body);
            for (var data in jsonResponse) {
              if (data['name'] == 'KABUPATEN S I A K') {
                kotaName = 'KABUPATEN SIAK';
              } else if (data['name'] == 'KOTA D U M A I') {
                kotaName = 'KOTA DUMAI';
              } else if (data['name'] == 'KOTA B A T A M') {
                kotaName = 'KOTA BATAM';
              }

              state(() {
                kota.add({
                  'id': data['id'],
                  'name': (data['name'] == 'KABUPATEN S I A K' ||
                          data['name'] == 'KOTA D U M A I' ||
                          data['name'] == 'KOTA B A T A M')
                      ? kotaName
                      : data['name'],
                });
              });
            }
          } else if (response.statusCode == 404) {
            kota = [];
          } else {
            throw Exception('Gagal memuat data dari API');
          }
        }

        Future<void> fetchKecamatan(id, StateSetter state) async {
          final response = await http.get(Uri.parse(
              'https://vardrz.github.io/api-wilayah-indonesia/api/districts/${id}.json'));

          if (response.statusCode == 200) {
            kecamatan = [];
            List<dynamic> jsonResponse = json.decode(response.body);
            for (var data in jsonResponse) {
              state(() {
                kecamatan.add(data['name']);
              });
            }
          } else if (response.statusCode == 404) {
            kecamatan = [];
          } else {
            throw Exception('Gagal memuat data dari API');
          }
        }

        return StatefulBuilder(
          builder: (context, state) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        "Filter by area",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    // Prov
                    FormBuilderDropdown(
                      name: 'prov',
                      decoration: InputDecoration(
                        labelText: 'Provinsi',
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(8.0),
                          ),
                          borderSide: new BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                            color: purplePrimary, fontWeight: FontWeight.bold),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: purplePrimary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      menuMaxHeight: 300,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      items: province
                          .map((prov) => DropdownMenuItem(
                                child: Text(prov['name']!),
                                value: prov['id'],
                              ))
                          .toList(),
                      onChanged: (id) {
                        print('Provinsi dipilih: $id');
                        fetchKota(id, state);
                      },
                    ),
                    // Kota
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: FormBuilderDropdown(
                        name: 'kota',
                        decoration: InputDecoration(
                          labelText: 'Kota',
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(8.0),
                            ),
                            borderSide: new BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                              color: purplePrimary,
                              fontWeight: FontWeight.bold),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: purplePrimary,
                              width: 2.0,
                            ),
                          ),
                        ),
                        menuMaxHeight: 300,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        items: kota
                            .map((kota) => DropdownMenuItem(
                                  child: Text(kota['name']!),
                                  value: kota['name'],
                                ))
                            .toList(),
                        onChanged: (name) {
                          print('Kota dipilih: $name');
                          var kotaId = kota
                              .firstWhere((element) => element['name'] == name);
                          fetchKecamatan(kotaId['id'], state);
                        },
                      ),
                    ),
                    // Kecamatan
                    FormBuilderDropdown(
                      name: 'kecamatan',
                      decoration: InputDecoration(
                        labelText: 'Kecamatan',
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(8.0),
                          ),
                          borderSide: new BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                            color: purplePrimary, fontWeight: FontWeight.bold),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: purplePrimary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      menuMaxHeight: 300,
                      items: kecamatan
                          .map((kec) => DropdownMenuItem(
                                child: Text(kec),
                                value: kec,
                              ))
                          .toList(),
                    ),
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 5),
                        width: double.infinity,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: purplePrimary),
                        child: Text(
                          'Terapkan',
                          style: TextStyle(
                              color: white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        if (_formKey.currentState!.saveAndValidate()) {
                          // print(_formKey.currentState!.value);
                          Navigator.pop(context);
                          setState(() {
                            city = _formKey.currentState?.value['kota'];
                            if (_formKey.currentState?.value['kecamatan'] ==
                                null) {
                              district = '';
                              filter = '1';
                            } else {
                              district =
                                  _formKey.currentState?.value['kecamatan'];
                              filter = '2';
                            }
                            loading = true;

                            mitras = fetchAPI();
                          });
                        }
                      },
                    ),
                    Visibility(
                      visible: filter != '0',
                      child: InkWell(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: purpleSecondary,
                          ),
                          child: Text(
                            'Hapus Filter',
                            style: TextStyle(
                                color: white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            city = '';
                            district = '';
                            filter = '0';
                            loading = true;

                            mitras = fetchAPI();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
