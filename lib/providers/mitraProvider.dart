import 'package:dandani/models/detailMitraModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class MitraProvider extends ChangeNotifier {
  Mitra? _mitra;
  Mitra? get mitra => _mitra;

  void setMitra(Mitra mitra) {
    _mitra = mitra;
    notifyListeners();
  }

  Future<void> storeMitra(String name, desc, specialist, whatsapp, province,
      city, district, maps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString('user_email') ?? '';

    final Uri url = Uri.parse('http://dandani.vaard.site/api/mitras');
    final Map<String, String> body = {
      'account': account,
      'name': name,
      'desc': desc,
      'specialist': specialist,
      'whatsapp': whatsapp,
      'province': province,
      'city': city,
      'district': district,
      'maps': maps,
    };

    final Response response = await post(url, body: body);

    if (response.statusCode == 201) {
      print(response);
    } else {
      print(response);
    }

    notifyListeners();
  }

  Future<void> updateMitra(String name, desc, specialist, whatsapp, province,
      city, district, maps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString('user_email') ?? '';

    final Uri url = Uri.parse('http://dandani.vaard.site/api/mitras/update');
    final Map<String, String> body = {
      'account': account,
      'name': name,
      'desc': desc,
      'specialist': specialist,
      'whatsapp': whatsapp,
      'province': province,
      'city': city,
      'district': district,
      'maps': maps,
    };

    final Response response = await post(url, body: body);

    if (response.statusCode == 201) {
      print(response.statusCode);
      print(response);
    } else {
      print(response);
    }

    notifyListeners();
  }
}
