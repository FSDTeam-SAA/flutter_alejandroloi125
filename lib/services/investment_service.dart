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

  // Future<Map<String, dynamic>> getById(String id) async {
  //   final r = await _dio.get(ApiPaths.investmentById(id)); // adjust path if different
  //   return Map<String, dynamic>.from(r.data ?? const {});
  // }

  // === CHANGE: robust details fetch that tolerates different route names & methods ===
  Future<Map<String, dynamic>> getById(String id) async {
    // 1) Try common GET paths: /get-investment/{id}, /getById/{id}, /{id}, etc.
    final getPaths = <String>[
      '/investment/get-investment/${Uri.encodeComponent(id)}',
      '/investment/getById/${Uri.encodeComponent(id)}',
      '/investment/get/${Uri.encodeComponent(id)}',
      '/investment/${Uri.encodeComponent(id)}',
    ];

    for (final p in getPaths) {
      try {
        final r = await _dio.get(p);
        if (_ok(r)) return Map<String, dynamic>.from(r.data ?? const {});
      } on DioException {
        // keep trying
      }
    }

    // 2) Some servers expect the id via query string on GET
    final getQueryPaths = <String>[
      '/investment/get-investment',
      '/investment/getById',
      '/investment/get',
    ];
    for (final p in getQueryPaths) {
      try {
        final r = await _dio.get(p, queryParameters: {'id': id, '_id': id, 'investmentId': id});
        if (_ok(r)) return Map<String, dynamic>.from(r.data ?? const {});
      } on DioException {
        // try next
      }
    }

    // 3) Finally, try POST endpoints that accept the id in the body
    final postPaths = <String>[
      '/investment/get-investment',
      '/investment/getById',
      '/investment/get',
    ];
    final bodies = [
      {'id': id},
      {'_id': id},
      {'investmentId': id},
    ];
    for (final p in postPaths) {
      for (final body in bodies) {
        try {
          final r = await _dio.post(p, data: body);
          if (_ok(r)) return Map<String, dynamic>.from(r.data ?? const {});
        } on DioException {
          // keep trying
        }
      }
    }

    throw Exception('Investment details endpoint not found (tried GET & POST variants).');
  }

  // Helper: accept either {success:true} or plain 2xx as success
  bool _ok(Response r) {
    final sc = r.statusCode ?? 0;
    if (sc < 200 || sc >= 300) return false;
    final d = r.data;
    if (d is Map && d.containsKey('success')) return d['success'] == true;
    return true;
  }



  // /// GET /investment/all-investment?userid=<id>&page=&limit=
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

  // POST /user/favorite/project/{id}/favourite
  Future<void> toggleFavorite(String projectId) async {
    await _dio.post('/user/favorite/project/$projectId/favourite');
  }




}
