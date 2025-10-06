// lib/feature/profile/repository/profile_repository.dart
import 'dart:io';
import 'package:alejandroloi/feature/auth/user.dart';
import '../service/profile_service.dart';

class ProfileRepository {
  final ProfileService service;
  ProfileRepository(this.service);

  Future<User> fetch(String userId) async {
    final res = await service.getUser(userId);
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to load user');
    }
    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return User.fromJson(data);
  }

  Future<User> update({
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? nationality,
    String? address,
    File? avatar,
  }) async {
    final res = await service.updateUser(
      name: name, age: age, gender: gender, phone: phone,
      nationality: nationality, address: address, avatar: avatar,
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Profile update failed');
    }
    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return User.fromJson(data);
  }
}




//
//
// // lib/feature/profile/data/profile_repository.dart
// import 'dart:io';
// import 'package:alejandroloi/feature/auth/user.dart';
//
// import '../service/profile_service.dart';
//
// class ProfileRepository {
//   final ProfileService service;
//   ProfileRepository(this.service);
//
//   Future<User> fetch(String userId) async {
//     final res = await service.getUser(userId);
//     if (res['success'] != true) {
//       throw Exception(res['message'] ?? 'Failed to load user');
//     }
//     // Same typed cast here
//     // final data = (res['data'] as Map?) ?? {};
//     final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
//     return User.fromJson(data);
//   }
//
//   Future<User> update({
//     String? name,
//     int? age,
//     String? gender,
//     String? phone,
//     String? nationality,
//     String? address,
//     File? avatar,
//   }) async {
//     final res = await service.updateUser(
//       name: name,
//       age: age,
//       gender: gender,
//       phone: phone,
//       nationality: nationality,
//       address: address,
//       avatar: avatar,
//     );
//     if (res['success'] != true) {
//       throw Exception(res['message'] ?? 'Profile update failed');
//     }
//     // final data = (res['data'] as Map?) ?? {};
//     // Same typed cast here
//     final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
//     return User.fromJson(data);
//   }
// }
