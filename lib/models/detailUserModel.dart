class User {
  final String uid;
  final String name;
  final String email;
  final String photo;
  final String address;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.photo,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      photo: json['photo'],
      address: json['address'],
    );
  }
}
