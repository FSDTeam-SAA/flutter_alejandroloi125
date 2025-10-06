// lib/feature/investment/repository/investment_repository.dart
import 'package:dio/dio.dart';

import '../feature/models/investment.dart';
import '../services/investment_service.dart';

class InvestmentRepository {
  final InvestmentService service;
  InvestmentRepository(this.service);

  Exception _wrap(DioException e) {
    final d = e.response?.data;
    final msg = (d is Map && d['message'] is String)
        ? d['message'] as String
        : (e.message ?? 'Network error');
    return Exception(msg);
  }

  Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  List<Map<String, dynamic>> _asListOfMap(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  Future<Investment> create({
    required String name,
    required String description,
    required String category,
    required int fundingGoal,
    required String fundingDuration,
    required String location,
    required String investmentTerms,
    dynamic imageFile, // File/XFile/null
  }) async {
    try {
      final r = await service.create(
        name: name,
        description: description,
        category: category,
        fundingGoal: fundingGoal,
        fundingDuration: fundingDuration,
        location: location,
        investmentTerms: investmentTerms,
        image: imageFile,
      );
      if (r is Map && r['success'] != true) {
        throw Exception(r['message'] ?? 'Create failed');
      }
      // Accept {data:{investment:{...}}} or {data:{...}} or flat {...}
      final data = _asMap(r?['data']?['investment']) //
          .isNotEmpty
          ? _asMap(r['data']['investment'])
          : (_asMap(r?['data']).isNotEmpty ? _asMap(r['data']) : _asMap(r));
      return Investment.fromJson(data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<List<Investment>> getAll({int page = 1, int limit = 10}) async {
    try {
      final r = await service.getAll(page: page, limit: limit);
      if (r is Map && r['success'] != true) {
        throw Exception(r['message'] ?? 'Fetch failed');
      }
      // Postman shows: { data: { investments: [...] } }
      final list = _asListOfMap(r?['data']?['investments']) //
          .isNotEmpty
          ? _asListOfMap(r['data']['investments'])
          : _asListOfMap(r?['data']);
      return list.map(Investment.fromJson).toList();
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<List<Investment>> getMine(
      String userId, {
        int page = 1,
        int limit = 10,
      }) async {
    try {
      final r = await service.getMine(userId, page: page, limit: limit);
      if (r is Map && r['success'] != true) {
        throw Exception(r['message'] ?? 'Fetch failed');
      }
      final list = _asListOfMap(r?['data']?['investments']) //
          .isNotEmpty
          ? _asListOfMap(r['data']['investments'])
          : _asListOfMap(r?['data']);
      return list.map(Investment.fromJson).toList();
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Investment> getById(String id) async {
    try {
      final r = await service.getById(id);
      if (r is Map && r['success'] != true) {
        throw Exception(r['message'] ?? 'Fetch failed');
      }
      final data = _asMap(r?['data']?['investment']) //
          .isNotEmpty
          ? _asMap(r['data']['investment'])
          : (_asMap(r?['data']).isNotEmpty ? _asMap(r['data']) : _asMap(r));
      return Investment.fromJson(data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Investment> update(String id, Map<String, dynamic> body) async {
    try {
      final r = await service.update(
        id,
        name: body['name'],
        description: body['description'],
        category: body['category'],
        fundingGoal: body['funding_goal'],
        fundingDuration: body['funding_duration'],
        location: body['location'],
        investmentTerms: body['investment_terms'],
      );
      if (r is Map && r['success'] != true) {
        throw Exception(r['message'] ?? 'Update failed');
      }
      final data = _asMap(r?['data']?['investment']) //
          .isNotEmpty
          ? _asMap(r['data']['investment'])
          : (_asMap(r?['data']).isNotEmpty ? _asMap(r['data']) : _asMap(r));
      return Investment.fromJson(data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }
  //
  // Future<void> delete(String id) async {
  //   try {
  //     final r = await service.delete(id); // may be 204 (null body) or a Map
  //     if (r is Map && r['success'] == false) {
  //       throw Exception(r['message'] ?? 'Delete failed');
  //     }
  //     // if r is null/empty and no error thrown → treat as success
  //   } on DioException catch (e) {
  //     throw _wrap(e);
  //   }
  // }
}
