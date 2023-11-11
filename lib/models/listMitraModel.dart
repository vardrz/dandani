class ListMitra {
  final String account;
  final String name;
  final String specialist;
  final String district;
  final String city;
  final String photo;

  ListMitra(
      {required this.account,
      required this.name,
      required this.specialist,
      required this.district,
      required this.city,
      required this.photo});

  factory ListMitra.fromJson(Map<String, dynamic> json) {
    return ListMitra(
      account: json['account'],
      name: json['name'],
      specialist: json['specialist'],
      district: json['district'],
      city: json['city'],
      photo: json['photo'],
    );
  }
}
