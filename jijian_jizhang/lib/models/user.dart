class User {
  final int id;
  final String phone;

  const User({required this.id, required this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phone: json['phone'] as String,
    );
  }
}
