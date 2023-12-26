import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:dandani/providers/userProvider.dart';

import 'package:dandani/util/colors.dart';

class AccountUpdate extends StatefulWidget {
  final String docid;
  final String name;
  final String address;

  const AccountUpdate({
    Key? key,
    required this.docid,
    required this.name,
    required this.address,
  }) : super(key: key);

  @override
  State<AccountUpdate> createState() => _AccountUpdateState();
}

class _AccountUpdateState extends State<AccountUpdate> {
  late String docid, name;
  final _formKey = GlobalKey<FormBuilderState>();
  double lat = 0, long = 0;
  List<Map<String, String>> province = [];
  List<Map<String, String>> kota = [];
  List<String> kecamatan = [];

  @override
  void initState() {
    super.initState();

    docid = widget.docid;
    name = widget.name;
    fetchProvince();

    if (widget.address != '') {
      Timer(Duration(seconds: 2), () async {
        var provId = province.firstWhere(
            (element) => element['name'] == widget.address.split(',')[0]);
        fetchKota(provId['id']);
      });
      Timer(Duration(seconds: 4), () {
        var kotaId = kota.firstWhere(
            (element) => element['name'] == widget.address.split(',')[1]);
        fetchKecamatan(kotaId['id']);
      });
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
        title: Text('Update Profile'),
        backgroundColor: purplePrimary,
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Nama
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: FormBuilderTextField(
                    initialValue: name,
                    name: 'nama',
                    decoration: InputDecoration(
                      labelText: 'Nama',
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
                // Provinsi
                Container(
                  margin: EdgeInsetsDirectional.only(top: 20, bottom: 10),
                  child: FormBuilderDropdown(
                    initialValue: widget.address != ''
                        ? widget.address.split(',')[0]
                        : '',
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
                      // print('Provinsi dipilih: $name');
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
                    initialValue: widget.address != ''
                        ? widget.address.split(',')[1]
                        : '',
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
                      // print('Kota dipilih: $name');
                      var kotaId =
                          kota.firstWhere((element) => element['name'] == name);
                      fetchKecamatan(kotaId['id']);
                    },
                  ),
                ),
                // Kecamatan
                FormBuilderDropdown(
                  initialValue:
                      widget.address != '' ? widget.address.split(',')[2] : '',
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
                  onTap: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      Provider.of<UserProvider>(context, listen: false)
                          .updateUserData(
                        docid,
                        _formKey.currentState?.value['nama'],
                        '${_formKey.currentState?.value['prov']},${_formKey.currentState?.value['kota']},${_formKey.currentState?.value['kecamatan']}',
                      );

                      Navigator.pop(context);
                    } else {
                      _showError(context);
                    }
                  },
                )
              ],
            ),
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
