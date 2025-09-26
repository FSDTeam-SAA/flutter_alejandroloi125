// lib/feature/auth/models/user.dart
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['_id'] as String,
    name: j['name'] as String? ?? '',
    email: j['email'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
  };
}
