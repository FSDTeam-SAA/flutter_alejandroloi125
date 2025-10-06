// lib/feature/investment/services/investment_service.dart
import 'package:dio/dio.dart';
import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/api_client.dart';
import 'dart:io';

class InvestmentService {
  final Dio _dio;
  InvestmentService(ApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> create({
    required String name,
    required String description,
    required String category,
    required int fundingGoal,
    required String fundingDuration,
    required String location,
    required String investmentTerms,
    File? image, // optional
  }) async {
    final hasImage = image != null;
    final data = hasImage
        ? FormData.fromMap({
      'name': name,
      'description': description,
      'category': category,
      'funding_goal': fundingGoal,
      'funding_duration': fundingDuration,
      'location': location,
      'investment_terms': investmentTerms,
      'image': await MultipartFile.fromFile(image!.path),
    })
        : {
      'name': name,
      'description': description,
      'category': category,
      'funding_goal': fundingGoal,
      'funding_duration': fundingDuration,
      'location': location,
      'investment_terms': investmentTerms,
    };

    final r = await _dio.post(
      ApiPaths.createInvestment,
      data: data,
      options: Options(contentType: hasImage ? 'multipart/form-data' : 'application/json'),
    );
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<Map<String, dynamic>> getAll({int page = 1, int limit = 10}) async {
    final r = await _dio.get(ApiPaths.allInvestment, queryParameters: {
      'page': page,
      'limit': limit,
    });
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<Map<String, dynamic>> getMine(String userId,
      {int page = 1, int limit = 10}) async {
    final r = await _dio.get(
      ApiPaths.allInvestmentByUser(userId),
      queryParameters: {'page': page, 'limit': limit},
    );
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final r = await _dio.get(ApiPaths.getInvestmentById(id));
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<Map<String, dynamic>> update(
      String id, {
        String? name,
        String? description,
        String? category,
        int? fundingGoal,
        String? fundingDuration,
        String? location,
        String? investmentTerms,
      }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (fundingGoal != null) body['funding_goal'] = fundingGoal;
    if (fundingDuration != null) body['funding_duration'] = fundingDuration;
    if (location != null) body['location'] = location;
    if (investmentTerms != null) body['investment_terms'] = investmentTerms;

    final r = await _dio.patch(
      ApiPaths.updateInvestment(id),
      data: body, // Postman shows JSON body for update
    );
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiPaths.deleteInvestment(id));
  }
}
