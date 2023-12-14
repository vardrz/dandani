import 'package:change_case/change_case.dart';

class ListMitra {
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

  ListMitra(
      {required this.account,
      required this.name,
      required this.desc,
      required this.specialist,
      required this.whatsapp,
      required this.province,
      required this.city,
      required this.district,
      required this.maps,
      required this.photo});

  factory ListMitra.fromJson(Map<String, dynamic> json) {
    return ListMitra(
      account: json['account'],
      name: json['name'],
      desc: json['desc'],
      specialist: json['specialist'],
      whatsapp: json['whatsapp'],
      province: json['province'],
      city: json['city'].toString().toCapitalCase(),
      district: json['district'].toString().toCapitalCase(),
      maps: json['maps'],
      photo: json['photo'],
    );
  }
}
