// lib/feature/auth/models/user.dart
class User {
  final String id;
  final String name;
  final String email;

  // New optional profile fields
  final int? age;
  final String? gender;
  final String? phone;
  final String? nationality;
  final String? address;
  final String? avatarUrl; // or avatar

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.phone,
    this.nationality,
    this.address,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: (j['_id'] ?? j['id']).toString(),
    name: j['name'] as String? ?? '',
    email: j['email'] as String? ?? '',
    age: _parseInt(j['age']),
    gender: j['gender'] as String?,
    phone: j['phone'] as String?,
    nationality: j['nationality'] as String?,
    address: j['address'] as String?,
    avatarUrl: j['avatar'] as String? ?? j['avatarUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    if (age != null) 'age': age,
    if (gender != null) 'gender': gender,
    if (phone != null) 'phone': phone,
    if (nationality != null) 'nationality': nationality,
    if (address != null) 'address': address,
    if (avatarUrl != null) 'avatar': avatarUrl,
  };

  // Handy for immutability when updating only some fields
  User copyWith({
    String? name,
    String? email,
    int? age,
    String? gender,
    String? phone,
    String? nationality,
    String? address,
    String? avatarUrl,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}


