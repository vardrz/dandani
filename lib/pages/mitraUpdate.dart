import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:provider/provider.dart';
import 'package:dandani/providers/mitraProvider.dart';
import 'package:dandani/pages/mainContent.dart';

import 'package:dandani/util/colors.dart';

class MitraUpdate extends StatefulWidget {
  final String name;
  final String desc;
  final String specialist;
  final String whatsapp;
  final String province;
  final String city;
  final String district;
  final String maps;

  // const MitraUpdate({super.key});
  const MitraUpdate({
    Key? key,
    required this.name,
    required this.desc,
    required this.specialist,
    required this.whatsapp,
    required this.province,
    required this.city,
    required this.district,
    required this.maps,
  }) : super(key: key);

  @override
  State<MitraUpdate> createState() => _MitraUpdateState();
}

class _MitraUpdateState extends State<MitraUpdate> {
  final _formKey = GlobalKey<FormBuilderState>();
  late String latlong;

  List<Map<String, String>> province = [];
  List<Map<String, String>> kota = [];
  List<String> kecamatan = [];

  @override
  void initState() {
    super.initState();
    fetchProvince();

    latlong = widget.maps;
    Timer(Duration(seconds: 1), () async {
      var provId =
          province.firstWhere((element) => element['name'] == widget.province);
      fetchKota(provId['id']);
    });
    Timer(Duration(seconds: 3), () {
      var kotaId = kota.firstWhere((element) => element['name'] == widget.city);
      fetchKecamatan(kotaId['id']);
    });
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

  Future<void> fetchKota(id) async {
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

        setState(() {
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

  Future<void> fetchKecamatan(id) async {
    final response = await http.get(Uri.parse(
        'https://vardrz.github.io/api-wilayah-indonesia/api/districts/${id}.json'));

    if (response.statusCode == 200) {
      kecamatan = [];
      List<dynamic> jsonResponse = json.decode(response.body);
      for (var data in jsonResponse) {
        setState(() {
          kecamatan.add(data['name']);
        });
      }
    } else if (response.statusCode == 404) {
      kecamatan = [];
    } else {
      throw Exception('Gagal memuat data dari API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Data Mitra'),
        backgroundColor: purplePrimary,
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Nama
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: FormBuilderTextField(
                    initialValue: widget.name,
                    name: 'nama',
                    decoration: InputDecoration(
                      labelText: 'Nama Jasa/Tempat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ),
                // Deskripsi
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: FormBuilderTextField(
                    initialValue: widget.desc,
                    name: 'deskripsi',
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      helperText:
                          'Jelaskan jasa service apa yang anda tawarkan dengan sedetail mungkin.',
                      helperMaxLines: 2,
                      helperStyle: TextStyle(color: purplePrimary),
                      alignLabelWithHint: true,
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
                    maxLines: 8,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ),
                // Spesialis
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: FormBuilderTextField(
                    initialValue: widget.specialist,
                    name: 'spesialis',
                    decoration: InputDecoration(
                      labelText: 'Spesialis',
                      helperText:
                          'Contoh: Laptop,Komputer,Monitor\n(Pisahkan dengan koma)',
                      helperMaxLines: 2,
                      helperStyle: TextStyle(color: purplePrimary),
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ),
                // Whatsapp
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: FormBuilderField(
                    initialValue: widget.whatsapp,
                    name: 'whatsapp',
                    builder: (value) {
                      return IntlPhoneField(
                        initialValue: widget.whatsapp,
                        decoration: InputDecoration(
                          labelText: 'Nomor Whatsapp',
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
                        initialCountryCode: 'ID',
                        countries: [
                          Country(
                            name: 'Indonesia',
                            flag: '🇮🇩',
                            code: 'ID',
                            dialCode: '62',
                            nameTranslations: {
                              'en': 'Indonesia',
                              'id': 'Indonesia',
                            },
                            minLength: 10,
                            maxLength: 13,
                          )
                        ],
                        showDropdownIcon: false,
                        flagsButtonMargin: EdgeInsets.only(left: 10),
                        onChanged: (phone) {
                          value.didChange(phone.completeNumber);
                        },
                      );
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(13),
                    ]),
                  ),
                ),
                // Provinsi
                Container(
                  margin: EdgeInsetsDirectional.only(top: 20, bottom: 10),
                  child: FormBuilderDropdown(
                    initialValue: widget.province,
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
                              value: prov['name'],
                            ))
                        .toList(),
                    onChanged: (name) {
                      print('Provinsi dipilih: $name');
                      var provId = province
                          .firstWhere((element) => element['name'] == name);
                      fetchKota(provId['id']);
                    },
                  ),
                ),
                // Kota
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: FormBuilderDropdown(
                    initialValue: widget.city,
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
                    items: kota
                        .map((kota) => DropdownMenuItem(
                              child: Text(kota['name']!),
                              value: kota['name'],
                            ))
                        .toList(),
                    onChanged: (name) {
                      print('Kota dipilih: $name');
                      var kotaId =
                          kota.firstWhere((element) => element['name'] == name);
                      fetchKecamatan(kotaId['id']);
                    },
                  ),
                ),
                // Kecamatan
                FormBuilderDropdown(
                  initialValue: widget.district,
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
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  items: kecamatan
                      .map((kec) => DropdownMenuItem(
                            child: Text(kec),
                            value: kec,
                          ))
                      .toList(),
                ),
                // Pick Location
                InkWell(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      color: grey,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.search,
                            color: white,
                          ),
                        ),
                        Text(
                          'Tentukan lokasi.',
                          style: TextStyle(fontSize: 18, color: white),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    _showMap(context);
                  },
                ),
                // Koordinat
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: FormBuilderTextField(
                    initialValue: latlong,
                    readOnly: true,
                    name: 'latlong',
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        borderSide: new BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      floatingLabelStyle: TextStyle(
                          color: purplePrimary, fontWeight: FontWeight.bold),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        borderSide: BorderSide(
                          color: purplePrimary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onTap: () => _showMap(context),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(8,
                          errorText: 'Tentukan lokasi anda.'),
                    ]),
                  ),
                ),
                // Submit Button
                InkWell(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: purplePrimary),
                    child: Text(
                      'Perbarui Data',
                      style: TextStyle(
                          color: white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Konfirmasi'),
                            content: Text('Perbarui data anda?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Provider.of<MitraProvider>(context,
                                          listen: false)
                                      .updateMitra(
                                    _formKey.currentState?.value['nama'],
                                    _formKey.currentState?.value['deskripsi'],
                                    _formKey.currentState?.value['spesialis'],
                                    _formKey.currentState?.value['whatsapp'],
                                    _formKey.currentState?.value['prov'],
                                    _formKey.currentState?.value['kota'],
                                    _formKey.currentState?.value['kecamatan'],
                                    _formKey.currentState?.value['latlong'],
                                  );
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainContent(
                                          fromMitraRegist: true),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 60,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: purplePrimary),
                                  child: Text(
                                    'Perbarui',
                                    style: TextStyle(color: white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      _showError(context);
                    }
                  },
                ),
                // Back
                // InkWell(
                //   child: Container(
                //     margin: EdgeInsets.only(bottom: 10),
                //     width: double.infinity,
                //     height: 60,
                //     alignment: Alignment.center,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(50),
                //       color: purpleSecondary,
                //     ),
                //     child: Text(
                //       'Kembali',
                //       style: TextStyle(
                //           color: white,
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold),
                //     ),
                //   ),
                //   onTap: () => Navigator.pop(context),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: purplePrimary, width: 5))),
          child: Center(
            child: OpenStreetMapSearchAndPick(
                locationPinIconColor: purplePrimary,
                locationPinText: '',
                center: LatLong(double.parse(latlong.split(',').first),
                    double.parse(latlong.split(',').last)),
                buttonColor: purplePrimary,
                buttonText: 'Pilih lokasi ini',
                onPicked: (pickedData) {
                  Navigator.pop(context);
                  setState(() {
                    latlong =
                        "${pickedData.latLong.latitude},${pickedData.latLong.longitude}";
                    _formKey.currentState!.patchValue({'latlong': '$latlong'});
                  });
                }),
          ),
        );
      },
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
