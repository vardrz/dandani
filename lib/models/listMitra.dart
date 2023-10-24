class ListMitra {
  final String name;
  final String specialist;
  final String address;
  final String photo;

  ListMitra(
      {required this.name,
      required this.specialist,
      required this.address,
      required this.photo});

  factory ListMitra.fromJson(Map<String, dynamic> json) {
    return ListMitra(
      name: json['name'],
      specialist: json['specialist'],
      address: json['address'],
      photo: json['photo'],
    );
  }
}
