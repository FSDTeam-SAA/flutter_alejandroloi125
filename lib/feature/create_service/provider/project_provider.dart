import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  // ---- Form state
  final formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool submitting = false;
  String? error;

  // ---- Fields bound to CreateProjectView
  String? title, category, description, location;
  String? skillsText; // comma-separated -> List<String>
  int? budgetMin, budgetMax, durationDays; // UI asks "Number of day"

  // optional image (if your create endpoint accepts it)
  File? imageFile;
  void setImage(File? f) {
    imageFile = f;
    notifyListeners();
  }

  // ---- Setters
  void setTitle(String v)        => title = v;
  void setCategory(String v)     => category = v;
  void setDescription(String v)  => description = v;
  void setLocation(String v)     => location = v;
  void setSkillsText(String v)   => skillsText = v;
  void setBudgetMin(String v)    => budgetMin = int.tryParse(v);
  void setBudgetMax(String v)    => budgetMax = int.tryParse(v);
  void setDurationDays(String v) => durationDays = int.tryParse(v);

  // ---- Validators
  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }
  String? requiredTitle(String? v)    => _required(v, 'Project name');
  String? requiredCategory(String? v) => _required(v, 'Category');
  String? requiredDesc(String? v)     => _required(v, 'Description');
  String? requiredLocation(String? v) => _required(v, 'Location');

  String? numberRequired(String? v, String label, {int min = 0}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = int.tryParse(v);
    if (n == null || n < min) return 'Enter a valid $label (≥ $min)';
    return null;
  }

  void _turnOnAutovalidate() {
    if (autovalidateMode != AutovalidateMode.onUserInteraction) {
      autovalidateMode = AutovalidateMode.onUserInteraction;
      notifyListeners();
    }
  }

  // ---------- CREATE ----------
  /// Build payload exactly as the API expects.
  Map<String, dynamic> _buildCreatePayload() {
    // Split skills by comma -> List<String>
    final skillList = (skillsText ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return {
      // API expects "name"
      'name': title!.trim(),
      'description': description!.trim(),
      'category': category!.trim(),
      'budget_min': budgetMin,
      'budget_max': budgetMax,

      // API expects a STRING with unit: "<n>day" or "<n>month".
      // Your UI collects "Number of day", so send "<days>day".
      'duration': durationDays != null ? '${durationDays}day' : null,

      'location': location!.trim(),
      'skills': skillList, // JSON array
    };
  }

  Future<Map<String, dynamic>> _createProjectJson(Map<String, dynamic> payload) async {
    final uri = ApiConstants.api('project/create-project');
    final res = await http
        .post(uri, headers: ApiConstants.jsonHeaders(), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 25));

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    try {
      final body = jsonDecode(res.body);
      final msg = (body is Map && body['message'] is String)
          ? body['message'] as String
          : 'Unexpected error (${res.statusCode})';
      throw Exception(msg);
    } catch (_) {
      throw Exception('Unexpected error (${res.statusCode})');
    }
  }

  Future<Map<String, dynamic>> _createProjectMultipart({
    required Map<String, String> fields,
    File? image,
  }) async {
    final uri = ApiConstants.api('project/create-project');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(ApiConstants.authOnlyHeaders()); // no content-type here
    req.fields.addAll(fields);

    if (image != null) {
      // change 'image' if backend uses a different field
      req.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    try {
      final body = jsonDecode(res.body);
      final msg = (body is Map && body['message'] is String)
          ? body['message'] as String
          : 'Unexpected error (${res.statusCode})';
      throw Exception(msg);
    } catch (_) {
      throw Exception('Unexpected error (${res.statusCode})');
    }
  }

  Future<bool> submit() async {
    final form = formKey.currentState!;
    if (!form.validate()) {
      _turnOnAutovalidate();
      error = 'Please fill all the fields';
      notifyListeners();
      return false;
    }
    if ((category ?? '').isEmpty) {
      error = 'Please choose a category';
      _turnOnAutovalidate();
      notifyListeners();
      return false;
    }

    submitting = true;
    error = null;
    notifyListeners();

    try {
      final payload = _buildCreatePayload();

      late Map<String, dynamic> resp;
      if (imageFile != null) {
        // multipart: mirror the JSON body; JSON-encode the skills list
        final fields = <String, String>{
          'name': (payload['name'] ?? '').toString(),
          'description': (payload['description'] ?? '').toString(),
          'category': (payload['category'] ?? '').toString(),
          'budget_min': (payload['budget_min'] ?? '').toString(),
          'budget_max': (payload['budget_max'] ?? '').toString(),
          'duration': (payload['duration'] ?? '').toString(), // "<n>day"
          'location': (payload['location'] ?? '').toString(),
          'skills': jsonEncode(payload['skills'] ?? const <String>[]),
        };
        resp = await _createProjectMultipart(fields: fields, image: imageFile);
      } else {
        // pure JSON
        resp = await _createProjectJson(payload);
      }

      final ok = (resp['success'] == true) || (resp['data'] != null);
      if (!ok) {
        error = (resp['message'] as String?) ?? 'Failed to create project';
        submitting = false;
        notifyListeners();
        return false;
      }

      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      submitting = false;
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ---------- LIST ----------
  List<Project> projects = [];
  bool loadingList = false;

  Future<bool> fetchAllProjects() async {
    loadingList = true;
    error = null;
    notifyListeners();

    try {
      final uri = ApiConstants.api('project/all-project');
      final res = await http
          .get(uri, headers: ApiConstants.jsonHeaders())
          .timeout(const Duration(seconds: 25));

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          final msg = (body is Map && body['message'] is String)
              ? body['message'] as String
              : 'Unexpected error (${res.statusCode})';
          throw Exception(msg);
        } catch (_) {
          throw Exception('Unexpected error (${res.statusCode})');
        }
      }

      final decoded = jsonDecode(res.body);
      // Expecting: { success: true, data: { projects: [...] } }
      final data = (decoded is Map) ? decoded['data'] : null;
      final list = (data is Map) ? (data['projects'] ?? data['items']) : null;

      final items = (list is List ? list : const [])
          .whereType<Map<String, dynamic>>()
          .map(Project.fromMap)
          .toList();

      projects = items;
      loadingList = false;
      notifyListeners();
      return true;
    } catch (e) {
      loadingList = false;
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ---------- DELETE ----------
  final Set<String> _deletingIds = {};
  Set<String> get deletingIds => _deletingIds;

  Future<bool> deleteProject(String id) async {
    _deletingIds.add(id);
    notifyListeners();
    try {
      final uri = ApiConstants.api('project/$id');
      final res = await http
          .delete(uri, headers: ApiConstants.jsonHeaders())
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200 || res.statusCode == 204) {
        projects.removeWhere((e) => e.id == id);
        _deletingIds.remove(id);
        notifyListeners();
        return true;
      }
      try {
        final body = jsonDecode(res.body);
        final msg = (body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Unexpected error (${res.statusCode})';
        throw Exception(msg);
      } catch (_) {
        throw Exception('Unexpected error (${res.statusCode})');
      }
    } catch (e) {
      _deletingIds.remove(id);
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ---------- DETAILS ----------
  Project? currentProject;
  bool loadingOne = false;

  Future<bool> fetchProjectById(String id) async {
    loadingOne = true;
    error = null;
    notifyListeners();

    try {
      final uri = ApiConstants.api('project/get-project/$id');
      final res = await http
          .get(uri, headers: ApiConstants.jsonHeaders())
          .timeout(const Duration(seconds: 25));

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          final msg = (body is Map && body['message'] is String)
              ? body['message'] as String
              : 'Unexpected error (${res.statusCode})';
          throw Exception(msg);
        } catch (_) {
          throw Exception('Unexpected error (${res.statusCode})');
        }
      }

      final decoded = jsonDecode(res.body);
      final data = (decoded is Map) ? decoded['data'] : null;

      if (data is Map<String, dynamic>) {
        currentProject = Project.fromMap(data);
      } else {
        currentProject = null;
      }

      loadingOne = false;
      notifyListeners();
      return currentProject != null;
    } catch (e) {
      loadingOne = false;
      currentProject = null;
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ---------- PROPOSAL SUBMIT ----------
  Future<bool> submitProposal({
    required String projectId,
    required int budgetAmount,
    required int days,
    required String coverLetter,
  }) async {
    try {
      // Pick the endpoint your backend actually uses.
      // If your backend differs, just change the path below.
      //
      // option A (recommended naming):
      // final uri = ApiConstants.api('proposal/create-proposal');
      //
      // option B (project-scoped):
      // final uri = ApiConstants.api('project/$projectId/submit-proposal');
      //
      // For now we'll use a generic proposal endpoint that includes the projectId in the body:
      final uri = ApiConstants.api('proposal/create-proposal');

      final payload = {
        'project_id': projectId,
        'budget': budgetAmount,                   // e.g. 1500
        'duration': '${days}day',                 // backend often expects "10day"
        'cover_letter': coverLetter.trim(),
      };

      final res = await http
          .post(uri, headers: ApiConstants.jsonHeaders(), body: jsonEncode(payload))
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      }

      try {
        final body = jsonDecode(res.body);
        final msg = (body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Unexpected error (${res.statusCode})';
        throw Exception(msg);
      } catch (_) {
        throw Exception('Unexpected error (${res.statusCode})');
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }




}
