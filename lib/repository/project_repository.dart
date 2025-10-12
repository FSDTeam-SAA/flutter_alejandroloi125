// lib/feature/project/repository/project_repository.dart
import 'package:dio/dio.dart';
import '../feature/models/project.dart';
import '../feature/service/models/project_page.dart';
import '../services/project_service.dart';

class ProjectRepository {
  final ProjectService service;
  ProjectRepository(this.service);

  Exception _wrap(DioException e) {
    final d = e.response?.data;
    final msg = (d is Map && d['message'] is String)
        ? d['message'] as String
        : (e.message ?? 'Network error');
    return Exception(msg);
  }

  Future<Project> create({
    required String title,
    required String description,
    required String category,
    required int minBudget,
    required int maxBudget,
    required int durationDays,
    required String location,
    required List<String> skills,
  }) async {
    try {
      final r = await service.create(
        title: title,
        description: description,
        category: category,
        minBudget: minBudget,
        maxBudget: maxBudget,
        durationDays: durationDays,
        location: location,
        skills: skills,
      );
      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Create failed');
      }

      final data = (r['data'] is Map)
          ? Map<String, dynamic>.from(r['data'])
          : <String, dynamic>{};
      final p = (data['project'] is Map)
          ? Map<String, dynamic>.from(data['project'])
          : data;

      return Project.fromJson(p);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // —— NEW: submit proposal ——
  Future<void> submitProposal({
    required String projectId,
    required String coverLetter,
    required int budget,
    required int deliveryDays,
  }) async {
    try {
      final r = await service.submitProposal(
        projectId: projectId,
        coverLetter: coverLetter,
        budget: budget,
        deliveryDays: deliveryDays,
      );
      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Proposal submit failed');
      }
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }


  Future<ProjectPage> getAll({int page = 1, int limit = 10}) async {
    try {
      final r = await service.getAll(page: page, limit: limit);
      if (r['success'] != true) throw Exception(r['message'] ?? 'Fetch failed');

      final data = (r['data'] is Map) ? Map<String, dynamic>.from(r['data']) : <String, dynamic>{};
      final meta = (data['meta'] is Map) ? Map<String, dynamic>.from(data['meta']) : <String, dynamic>{};
      final list = (data['projects'] is List) ? List.from(data['projects']) : const <dynamic>[];

      final items = list
          .whereType<Map>()
          .map((m) => Project.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      return ProjectPage(
        total : (meta['total'] as num?)?.toInt() ?? items.length,
        page  : (meta['page']  as num?)?.toInt() ?? page,
        limit : (meta['limit'] as num?)?.toInt() ?? limit,
        pages : (meta['pages'] as num?)?.toInt() ?? 1,
        items : items,
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }


  Future<ProjectPage> getAllByUser(
      String userId, {
        int page = 1,
        int limit = 10,
      }) async {
    try {
      final r = await service.getAllByUser(userId, page: page, limit: limit);
      if (r['success'] != true) throw Exception(r['message'] ?? 'Fetch failed');

      final data = (r['data'] is Map) ? Map<String, dynamic>.from(r['data']) : <String, dynamic>{};
      final meta = (data['meta'] is Map) ? Map<String, dynamic>.from(data['meta']) : <String, dynamic>{};
      final list = (data['projects'] is List) ? List.from(data['projects']) : const <dynamic>[];

      final items = list
          .whereType<Map>()
          .map((m) => Project.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      return ProjectPage(
        total : (meta['total'] as num?)?.toInt() ?? items.length,
        page  : (meta['page']  as num?)?.toInt() ?? page,
        limit : (meta['limit'] as num?)?.toInt() ?? limit,
        pages : (meta['pages'] as num?)?.toInt() ?? 1,
        items : items,
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Project> getById(String id) async {
    try {
      final r = await service.getById(id);
      if (r['success'] != true) throw Exception(r['message'] ?? 'Fetch failed');

      final data = (r['data'] is Map) ? Map<String, dynamic>.from(r['data']) : <String, dynamic>{};
      final p = (data['project'] is Map)
          ? Map<String, dynamic>.from(data['project'])
          : data;
      return Project.fromJson(p);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Project> update(
      String id, {
        String? title,
        String? description,
        String? category,
        int? minBudget,
        int? maxBudget,
        int? deadlineDays,
        String? location,
        List<String>? skills,
        String? status,
      }) async {
    try {
      final r = await service.update(
        id,
        title: title,
        description: description,
        category: category,
        minBudget: minBudget,
        maxBudget: maxBudget,
        deadlineDays: deadlineDays,
        location: location,
        skills: skills,
        status: status,
      );
      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Update failed');
      }
      final data = (r['data'] is Map) ? Map<String, dynamic>.from(r['data']) : <String, dynamic>{};
      final p = (data['project'] is Map)
          ? Map<String, dynamic>.from(data['project'])
          : data;
      return Project.fromJson(p);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      final r = await service.delete(id);
      if (r['success'] != true) throw Exception(r['message'] ?? 'Delete failed');
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }
}
