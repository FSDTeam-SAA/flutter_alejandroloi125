import 'dart:io';
import 'package:dio/dio.dart';
import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/api_client.dart';

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
    required File imageFile,
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'description': description,
      'category': category,
      'funding_goal': fundingGoal,
      'funding_duration': fundingDuration,
      'location': location,
      'investment_terms': investmentTerms,
      'imageLink': await MultipartFile.fromFile(imageFile.path),
    });

    final res = await _dio.post(
      ApiPaths.createInvestment,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  Future<Map<String, dynamic>> getAll({int page = 1, int limit = 10}) async {
    final res = await _dio.get(
      ApiPaths.allInvestment,
      queryParameters: {'page': page, 'limit': limit},
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  /// GET /investment/all-investment?userid=<id>&page=&limit=
  Future<Map<String, dynamic>> getAllByUser({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final url = ApiPaths.allInvestmentByUser(userId);
    final res = await _dio.get(url, queryParameters: {'page': page, 'limit': limit});
    // return _map(res.data);
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  Future<Map<String, dynamic>> getOne(String id) async {
    final res = await _dio.get(ApiPaths.getInvestmentById(id));
    // return _map(res.data);
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  Future<Map<String, dynamic>> delete(String id) async {
    final res = await _dio.delete(ApiPaths.deleteInvestment(id));
    return Map<String, dynamic>.from(res.data ?? const {});
  }
}
