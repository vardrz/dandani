import 'package:dandani/models/detailMitra.dart';
import 'package:flutter/material.dart';

class MitraProvider extends ChangeNotifier {
  Mitra? _mitra;
  Mitra? get mitra => _mitra;

  void setMitra(Mitra mitra) {
    _mitra = mitra;
    notifyListeners();
  }
}
