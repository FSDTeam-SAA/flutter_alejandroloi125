// lib/feature/profile/service/profile_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/api_client.dart';

class ProfileService {
  final Dio _dio;
  ProfileService(ApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> getUser(String userId) async {
    final r = await _dio.get('${ApiPaths.userGetOne}/$userId');
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<Map<String, dynamic>> updateUser({
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? nationality,
    String? address,
    File? avatar,
  }) async {
    final form = FormData();

    void add(String k, dynamic v) { if (v != null && '$v'.isNotEmpty) form.fields.add(MapEntry(k, '$v')); }

    add('name', name);
    add('age', age);
    add('gender', gender);
    add('phone', phone);
    add('nationality', nationality);
    add('address', address);

    if (avatar != null) {
      form.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(avatar.path, filename: avatar.path.split('/').last),
      ));
    }

    final r = await _dio.put(
      ApiPaths.userUpdate,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Map<String, dynamic>.from(r.data ?? const {});
  }
}
