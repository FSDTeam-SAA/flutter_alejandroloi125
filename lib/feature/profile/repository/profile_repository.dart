// lib/feature/profile/repository/profile_repository.dart
import 'dart:io';
import 'package:alejandroloi/feature/auth/user.dart';
import 'package:flutter/foundation.dart';
import '../service/profile_service.dart';

class ProfileRepository {
  final ProfileService service;
  ProfileRepository(this.service);
  // Key: UserID, Value: User
  Map<String, User> _cachedUsers = {};

  Future<User> fetch(String userId, {bool forceFetch = false}) async {
    debugPrint("ProfileRepository: fetch called with userId: $userId, forceFetch: $forceFetch");
    if(forceFetch == false && _cachedUsers.containsKey(userId)) {
      print("Returning cached user for ID: $userId");
      return _cachedUsers[userId]!;
    }
    debugPrint("Fetching user from service for ID: $userId");
    final res = await service.getUser(userId);
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to load user');
    }
    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    _cachedUsers[userId] = User.fromJson(data);
    return _cachedUsers[userId]!;
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
