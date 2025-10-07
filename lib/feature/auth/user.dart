class User {
  final String id;
  final String? name;
  final String? email;
  final String? username;
  final String? phone;
  final String? role;
  final bool? verified;
  final String? verificationToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    this.name,
    this.email,
    this.username,
    this.phone,
    this.role,
    this.verified,
    this.verificationToken,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final ver = (json['verificationInfo'] as Map?) ?? {};
    return User(
      id: (json['_id'] ?? '').toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      verified: ver['verified'] as bool?,
      verificationToken: ver['token'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'role': role,
      'verificationInfo': {
        'token': verificationToken,
        'verified': verified,
      },
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
