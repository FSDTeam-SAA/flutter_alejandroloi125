import 'dart:io';
import 'package:dio/dio.dart';

import '../feature/models/investment.dart';
import '../feature/service/models/investment_page.dart';
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

  Future<Investment> create({
    required String name,
    required String description,
    required String category,
    required int fundingGoal,
    required String fundingDuration,
    required String location,
    required String investmentTerms,
    required File imageFile,
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
        imageFile: imageFile,
      );

      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Create failed');
      }

      Map<String, dynamic> asMap(dynamic v) =>
          v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

      final data = asMap(r['data']?['investment']).isNotEmpty
          ? asMap(r['data']['investment'])
          : (asMap(r['data']).isNotEmpty ? asMap(r['data']) : asMap(r));

      return Investment.fromJson(data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  /// GET /investment/all-investment => returns:
  /// { success, data: { meta: {total,page,limit,pages}, investments: [...] } }
  Future<InvestmentPage> getAll({int page = 1, int limit = 10}) async {
    try {
      final r = await service.getAll(page: page, limit: limit);
      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Fetch failed');
      }

      final data = (r['data'] is Map) ? Map<String, dynamic>.from(r['data']) : <String, dynamic>{};
      final meta = (data['meta'] is Map) ? Map<String, dynamic>.from(data['meta']) : <String, dynamic>{};
      final list = (data['investments'] is List) ? List.from(data['investments']) : const <dynamic>[];

      final items = list
          .whereType<Map>()
          .map((m) => Investment.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      return InvestmentPage(
        total: (meta['total'] as num?)?.toInt() ?? items.length,
        page: (meta['page'] as num?)?.toInt() ?? page,
        limit: (meta['limit'] as num?)?.toInt() ?? limit,
        pages: (meta['pages'] as num?)?.toInt() ?? 1,
        items: items,
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<InvestmentPage> getAllByUser({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final r = await service.getAllByUser(userId: userId, page: page, limit: limit);
      return _toPage(r, page, limit);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }



  // Future<Investment> getById(String id) async {
  //   final res = await service.getById(id);
  //   if (res['success'] != true) {
  //     throw Exception(res['message'] ?? 'Failed to load investment');
  //   }
  //   final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  //   return Investment.fromJson(data);
  // }

  // lib/repository/investment_repository.dart
// …imports & class unchanged…

  // === CHANGE: tolerant details parsing ===
  Future<Investment> getById(String id) async {
    try {
      final raw = await service.getById(id);

      // Handle explicit failure envelopes
      if (raw['success'] == false) {
        throw Exception(raw['message'] ?? 'Failed to load investment');
      }

      // Normalize shapes: {data:{investment:{...}}} OR {data:{...}} OR {...}
      Map<String, dynamic> asMap(dynamic v) =>
          v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

      final data = asMap(raw['data']);
      final item = asMap(data['investment']).isNotEmpty
          ? asMap(data['investment'])
          : (data.isNotEmpty ? data : asMap(raw));

      if (item.isEmpty) throw Exception('Investment not found');
      return Investment.fromJson(item);
    } on DioException catch (e) {
      // Map 404 to a friendly message
      if (e.response?.statusCode == 404) {
        throw Exception('Investment not found (404)');
      }
      rethrow;
    }
  }


  Future<Investment> getOne(String id) async {
    try {
      final r = await service.getOne(id);
      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Fetch failed');
      }
      final data = (r['data'] is Map) ? Map<String, dynamic>.from(r['data']) : <String, dynamic>{};
      final item = (data['investment'] is Map)
          ? Map<String, dynamic>.from(data['investment'])
          : data;
      return Investment.fromJson(item);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }


  /// DELETE /investment/{id}
  Future<void> delete(String id) async {
    try {
      final r = await service.delete(id);
      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Delete failed');
      }
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }
}

// ---- helpers ----
InvestmentPage _toPage(Map<String, dynamic> raw, int page, int limit) {
  if (raw['success'] != true) {
    throw Exception(raw['message'] ?? 'Fetch failed');
  }
  final data = (raw['data'] is Map) ? Map<String, dynamic>.from(raw['data']) : <String, dynamic>{};
  final meta = (data['meta'] is Map) ? Map<String, dynamic>.from(data['meta']) : <String, dynamic>{};
  final list = (data['investments'] is List) ? List.from(data['investments']) : const [];

  final items = list
      .whereType<Map>()
      .map((m) => Investment.fromJson(Map<String, dynamic>.from(m)))
      .toList();

  return InvestmentPage(
    total: (meta['total'] as num?)?.toInt() ?? items.length,
    page: (meta['page'] as num?)?.toInt() ?? page,
    limit: (meta['limit'] as num?)?.toInt() ?? limit,
    pages: (meta['pages'] as num?)?.toInt() ?? 1,
    items: items,
  );
}