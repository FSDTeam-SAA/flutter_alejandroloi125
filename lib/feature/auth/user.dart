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

  // ✅ Add these so UI can compile:
  final String? address;
  final String? gender;
  final String? nationality;

  /// age can be int or string depending on backend
  final dynamic age;

  /// Direct URL to show in UI (extracted from "avatar" map or string)
  final String? avatarUrl;

  /// Avatar may come as a String or as { url: "..." }
  final String? avatar;   // raw string if server returns string
  final String? imageUrl; // normalized url (works if server returns a map)

  // Optional arrays the API returns
  final List<dynamic>? favoriteAuction;
  final List<dynamic>? favoriteProject;
  final List<dynamic>? favoriteInvest;

  const User({
    required this.id,
    this.name,
    this.email,
    this.username,
    this.phone,
    this.role,
    this.address,
    this.gender,
    this.nationality,
    this.age,
    this.avatar,
    this.imageUrl,
    this.favoriteAuction,
    this.favoriteProject,
    this.favoriteInvest,
    this.avatarUrl,

    this.verified,
    this.verificationToken,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final ver = (json['verificationInfo'] as Map?) ?? {};
    // Normalize avatar
    String? imgUrl;
    final a = json['avatar'];
    if (a is String) {
      imgUrl = a;
    } else if (a is Map && a['url'] != null) {
      imgUrl = a['url'].toString();
    }
    return User(
      id: (json['_id'] ?? '').toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      phone: json['phone']?.toString(),

      // ✅ address/gender/nationality exist now
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      nationality: json['nationality']?.toString(),
      age: json['age'],                // keep dynamic (int or string)
      avatar: a is String ? a : null,  // preserve raw string if provided
      imageUrl: imgUrl,                // normalized usable url

      favoriteAuction: (json['favorite_auction'] as List?) ?? const [],
      favoriteProject: (json['favorite_project'] as List?) ?? const [],
      favoriteInvest: (json['favorite_invest'] as List?) ?? const [],

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
      'address': address,
      'gender': gender,
      'nationality': nationality,
      'age': age,
      'avatar': avatar ?? imageUrl,
      'favorite_auction': favoriteAuction,
      'favorite_project': favoriteProject,
      'favorite_invest': favoriteInvest,
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
