// lib/feature/project/services/project_service.dart
import 'package:dio/dio.dart';
import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/api_client.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_service/api_client.dart';

class ProjectService {
  final Dio _dio;
  ProjectService(ApiClient client) : _dio = client.dio;


  Future<Map<String, dynamic>> create({
    required String title,
    required String description,
    required String category,
    required int minBudget,
    required int maxBudget,
    required int deadlineDays,
    required String location,
    required List<String> skills,
  }) async {
    // === Match backend naming exactly ===
    final payload = {
      'name'       : title,                 // <— server wants "name"
      'description': description,
      // If your server stores category as array, send list with single value:
      // 'category' : [category],
      'category'   : category,
      'budget_min' : minBudget,             // <— NOT min_budget
      'budget_max' : maxBudget,             // <— NOT max_budget
      'deadline'   : '$deadlineDays day', // <— string form typically required
      'location'   : location,
      // If backend prefers comma string instead of array, do: skills.join(', ')
      'skills'     : skills,
    };

    final res = await _dio.post(ApiPaths.createProject, data: payload);
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  // LIST (all)
  Future<Map<String, dynamic>> getAll({int page = 1, int limit = 10}) async {
    final res = await _dio.get(
      ApiPaths.allProject,
      queryParameters: {'page': page, 'limit': limit},
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }

// —— SUBMIT PROPOSAL (FIXED KEYS & TYPES) ——
  Future<Map<String, dynamic>> submitProposal({
    required String projectId,
    required String coverLetter,
    required int budget,
    required int deliveryDays,
  }) async {
    final payload = {
      'cover_letter'  : coverLetter,
      'budget'        : budget.toString(),          // backend expects string
      'delivery_timer': deliveryDays.toString(),    // exact key + string
    };

    final res = await _dio.patch(ApiPaths.askProposal(projectId), data: payload);
    return (res.data is Map)
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};
  }




  Future<Map<String, dynamic>> getAllByUser(
      String userId, {
        int page = 1,
        int limit = 10,
      }) async {
    final res = await _dio.get(
      ApiPaths.allProjectByUser(userId),
      queryParameters: {'page': page, 'limit': limit},
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  // GET ONE
  Future<Map<String, dynamic>> getById(String id) async {
    final res = await _dio.get(ApiPaths.getProjectById(id));
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  // UPDATE (PATCH)
  Future<Map<String, dynamic>> update(
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
    final Map<String, dynamic> payload = {};
    if (title != null)        payload['name'] = title;
    if (description != null)  payload['description'] = description;
    if (category != null)     payload['category'] = category;
    if (minBudget != null)    payload['budget_min'] = minBudget;
    if (maxBudget != null)    payload['budget_max'] = maxBudget;
    if (deadlineDays != null) payload['deadline'] = '$deadlineDays day';
    if (location != null)     payload['location'] = location;
    if (skills != null)       payload['skills'] = skills;
    if (status != null)       payload['status'] = status;

    final res = await _dio.patch(ApiPaths.updateProject(id), data: payload);
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  // DELETE
  Future<Map<String, dynamic>> delete(String id) async {
    final res = await _dio.delete(ApiPaths.deleteProject(id));
    return Map<String, dynamic>.from(res.data ?? const {});
  }

}
