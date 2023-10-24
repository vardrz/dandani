import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'package:dandani/models/listMitra.dart';

class HomeApiProvider with ChangeNotifier {
  List<Map<String, dynamic>> _listMitra = [];

  List<Map<String, dynamic>> get mitra => _listMitra;

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('http://mocki.io/v1/d4867d8b-b5d5-4a48-a4ab-79131b5809b8'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _listMitra = data.cast<Map<String, dynamic>>();
      notifyListeners();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
