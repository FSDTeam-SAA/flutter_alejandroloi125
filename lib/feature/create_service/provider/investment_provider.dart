// lib/service/create_service/provider/investment_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../models/investment.dart';

class InvestmentProvider with ChangeNotifier {
  // ----- form state
  final formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool submitting = false;
  String? error;

  // ----- fields
  String? title, category, description, location, terms;
  int? fundingGoal, durationDays;

  // image from picker (optional)
  File? imageFile;
  void setImage(File? f) {
    imageFile = f;
    notifyListeners();
  }

  // ----- setters
  void setTitle(String v)        => title = v;
  void setCategory(String v)     => category = v;
  void setDescription(String v)  => description = v;
  void setLocation(String v)     => location = v;
  void setTerms(String v)        => terms = v;
  void setFundingGoal(String v)  => fundingGoal = int.tryParse(v);
  void setDurationDays(String v) => durationDays = int.tryParse(v);

  // ----- validators
  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }
  String? requiredTitle(String? v)    => _required(v, 'Investment title');
  String? requiredCategory(String? v) => _required(v, 'Category');
  String? requiredDesc(String? v)     => _required(v, 'Description');
  String? requiredLocation(String? v) => _required(v, 'Location');
  String? requiredTerms(String? v)    => _required(v, 'Investment terms');
  String? numberRequired(String? v, String label, {int min = 1}) {
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
  Map<String, dynamic> _buildPayload() {
    return {
      'name': title!.trim(),
      'description': description!.trim(),
      'category': category!.trim(),
      'funding_goal': fundingGoal,
      // Your backend example shows "3month". If you prefer number-of-days, keep as int.
      'funding_duration': durationDays, // or '${durationDays}day' if server expects text
      'location': location!.trim(),
      'investment_terms': terms!.trim(),
    };
  }

  Future<Map<String, dynamic>> _createInvestmentJson(Map<String, dynamic> payload) async {
    final uri = ApiConstants.api('investment/create-investment');
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

  Future<Map<String, dynamic>> _createInvestmentMultipart({
    required Map<String, String> fields,
    File? image,
  }) async {
    final uri = ApiConstants.api('investment/create-investment');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(ApiConstants.authOnlyHeaders()); // no content-type here

    req.fields.addAll(fields);
    if (image != null) {
      req.files.add(await http.MultipartFile.fromPath('imageLink', image.path));
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
      final jsonPayload = _buildPayload();

      late Map<String, dynamic> resp;
      if (imageFile != null) {
        // multipart with file
        final fields = <String, String>{
          'name': jsonPayload['name'] as String,
          'description': jsonPayload['description'] as String,
          'category': jsonPayload['category'] as String,
          'funding_goal': (jsonPayload['funding_goal'] ?? '').toString(),
          'funding_duration': jsonPayload['funding_duration'] is int
              ? '${jsonPayload['funding_duration']}day' // tweak if needed ("3month")
              : (jsonPayload['funding_duration']?.toString() ?? ''),
          'location': jsonPayload['location'] as String,
          'investment_terms': jsonPayload['investment_terms'] as String,
        };
        resp = await _createInvestmentMultipart(fields: fields, image: imageFile);
      } else {
        // pure JSON
        resp = await _createInvestmentJson(jsonPayload);
      }

      final ok = (resp['success'] == true) || (resp['data'] != null);
      if (!ok) {
        error = (resp['message'] as String?) ?? 'Failed to create investment';
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
  List<Investment> investments = [];
  bool loadingList = false;

  Future<bool> fetchAllInvestments() async {
    loadingList = true;
    error = null;
    notifyListeners();

    try {
      final uri = ApiConstants.api('investment/all-investment');
      final res = await http.get(uri, headers: ApiConstants.jsonHeaders()).timeout(const Duration(seconds: 25));

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
      final list = (data is Map) ? data['investments'] : null;

      final items = (list is List ? list : const [])
          .whereType<Map<String, dynamic>>()
          .map(Investment.fromMap)
          .toList();

      investments = items;
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

  Future<bool> deleteInvestment(String id) async {
    _deletingIds.add(id);
    notifyListeners();
    try {
      final uri = ApiConstants.api('investment/$id');
      final res = await http.delete(uri, headers: ApiConstants.jsonHeaders()).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200 || res.statusCode == 204) {
        investments.removeWhere((e) => e.id == id);
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
  Investment? currentInvestment;
  bool loadingOne = false;

  Future<bool> fetchInvestmentById(String id) async {
    loadingOne = true;
    error = null;
    notifyListeners();

    try {
      final uri = ApiConstants.api('investment/get-investment/$id');
      final res = await http.get(uri, headers: ApiConstants.jsonHeaders()).timeout(const Duration(seconds: 25));

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
        currentInvestment = Investment.fromMap(data);
      } else {
        currentInvestment = null;
      }

      loadingOne = false;
      notifyListeners();
      return currentInvestment != null;
    } catch (e) {
      loadingOne = false;
      currentInvestment = null;
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}


// // lib/service/create_service/provider/investment_provider.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';                         // ★ ADD
// import '../../../constants/api_constants.dart';
// import '../models/investment.dart';
//
//
// class InvestmentProvider with ChangeNotifier {
//   // ---- Form state
//   final formKey = GlobalKey<FormState>();
//   AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
//   bool submitting = false;
//   String? error;
//
//   // ---- Fields
//   String? title, category, description, location, terms;
//   int? fundingGoal, durationDays;
//
//   // ★ ADD: hold the selected image (optional)
//   File? imageFile;
//   void setImage(File? f) {                // call this from the picker
//     imageFile = f;
//     notifyListeners();
//   }
//
//   // ---- Setters
//   void setTitle(String v) => title = v;
//
//   void setCategory(String v) => category = v;
//
//   void setDescription(String v) => description = v;
//
//   void setLocation(String v) => location = v;
//
//   void setTerms(String v) => terms = v;
//
//   void setFundingGoal(String v) => fundingGoal = int.tryParse(v);
//
//   void setDurationDays(String v) => durationDays = int.tryParse(v);
//
//   // ---- Validators
//   String? _required(String? v, String label) {
//     if (v == null || v.trim().isEmpty) return '$label is required';
//     return null;
//   }
//
//   String? requiredTitle(String? v) => _required(v, 'Investment title');
//
//   String? requiredCategory(String? v) => _required(v, 'Category');
//
//   String? requiredDesc(String? v) => _required(v, 'Description');
//
//   String? requiredLocation(String? v) => _required(v, 'Location');
//
//   String? requiredTerms(String? v) => _required(v, 'Investment terms');
//
//   String? numberRequired(String? v, String label, {int min = 1}) {
//     if (v == null || v.trim().isEmpty) return '$label is required';
//     final n = int.tryParse(v);
//     if (n == null || n < min) return 'Enter a valid $label (≥ $min)';
//     return null;
//   }
//
//   void _turnOnAutovalidate() {
//     if (autovalidateMode != AutovalidateMode.onUserInteraction) {
//       autovalidateMode = AutovalidateMode.onUserInteraction;
//       notifyListeners();
//     }
//   }
//
//   // -----------------------------
//   // API: Create investment
//   // -----------------------------
//
//   /// Build payload as your backend expects.
//   Map<String, dynamic> _buildPayload() {
//     return {
//       "name": title!.trim(),
//       "description": description!.trim(),
//       "category": category!.trim(),
//       "funding_goal": fundingGoal, // int
//       // If your API expects a string like "3month", adapt here:
//       // "funding_duration": "${durationDays}day",
//       "funding_duration": durationDays, // send as number if backend supports it
//       "location": location!.trim(),
//       "investment_terms": terms!.trim(),
//     };
//   }
//
//   Future<Map<String, dynamic>> _createInvestment(
//     Map<String, dynamic> payload,
//   ) async {
//     final uri = ApiConstants.api('investment/create-investment');
//
//     final res = await http
//         .post(
//           uri,
//           headers: ApiConstants.jsonHeaders(), // includes bearer if set in .env
//           body: jsonEncode(payload),
//         )
//         .timeout(const Duration(seconds: 25));
//
//     // Success: backend typically returns 201 (Created)
//     if (res.statusCode == 200 || res.statusCode == 201) {
//       return jsonDecode(res.body) as Map<String, dynamic>;
//     }
//
//     // Try to extract a helpful error message from the body
//     try {
//       final body = jsonDecode(res.body);
//       final msg = (body is Map && body['message'] is String)
//           ? body['message'] as String
//           : 'Unexpected error (${res.statusCode})';
//       throw Exception(msg);
//     } catch (_) {
//       throw Exception('Unexpected error (${res.statusCode})');
//     }
//   }
//
//   // -----------------------------
//   // Submit: validate + call API for create investment
//   // -----------------------------
//   Future<bool> submit() async {
//     final form = formKey.currentState!;
//     if (!form.validate()) {
//       _turnOnAutovalidate();
//       error = 'Please fill all the fields';
//       notifyListeners();
//       return false;
//     }
//
//     if ((category ?? '').isEmpty) {
//       error = 'Please choose a category';
//       _turnOnAutovalidate();
//       notifyListeners();
//       return false;
//     }
//
//     submitting = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       final payload = _buildPayload();
//       final resp = await _createInvestment(payload);
//
//       final ok = (resp['success'] == true) || (resp['data'] != null);
//       if (!ok) {
//         error = (resp['message'] as String?) ?? 'Failed to create investment';
//         submitting = false;
//         notifyListeners();
//         return false;
//       }
//
//       submitting = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       submitting = false;
//       error = e.toString().replaceFirst('Exception: ', '');
//       notifyListeners();
//       return false;
//     }
//   }
//
//   // lib/service/create_service/provider/investment_provider.dart (additions)
//
//   // state for list
//   List<Investment> investments = [];
//   bool loadingList = false;
//
//   Future<bool> fetchAllInvestments() async {
//     loadingList = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       final uri = ApiConstants.api('investment/all-investment');
//
//       final res = await http
//           .get(uri, headers: ApiConstants.jsonHeaders())
//           .timeout(const Duration(seconds: 25));
//
//       if (res.statusCode != 200) {
//         // try to show server message
//         try {
//           final body = jsonDecode(res.body);
//           final msg = (body is Map && body['message'] is String)
//               ? body['message'] as String
//               : 'Unexpected error (${res.statusCode})';
//           throw Exception(msg);
//         } catch (_) {
//           throw Exception('Unexpected error (${res.statusCode})');
//         }
//       }
//
//       final body = jsonDecode(res.body);
//       // Expecting shape:
//       // { success: true, data: { meta: {...}, investments: [ ... ] } }
//       final data = (body is Map) ? body['data'] : null;
//       final list = (data is Map) ? data['investments'] : null;
//
//       final items = (list is List ? list : [])
//           .whereType<Map<String, dynamic>>() // <-- key fix
//           .map(Investment.fromMap)
//           .toList();
//
//       investments = items;
//       loadingList = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       loadingList = false;
//       error = e.toString().replaceFirst('Exception: ', '');
//       notifyListeners();
//       return false;
//     }
//   }
//
//
//
//   // Track which items are deleting (to disable buttons / show spinners)
//   final Set<String> _deletingIds = {};
//
//   Set<String> get deletingIds => _deletingIds;
//
//   // DELETE /investment/:id
//   Future<bool> deleteInvestment(String id) async {
//     // optimistic UI flag
//     _deletingIds.add(id);
//     notifyListeners();
//
//     try {
//       final uri = ApiConstants.api('investment/$id');
//
//       final res = await http
//           .delete(uri, headers: ApiConstants.jsonHeaders())
//           .timeout(const Duration(seconds: 25));
//
//       // Many APIs return 200/204 on successful delete
//       if (res.statusCode == 200 || res.statusCode == 204) {
//         // remove from local list
//         investments.removeWhere((e) => e.id == id);
//         _deletingIds.remove(id);
//         notifyListeners();
//         return true;
//       }
//
//       // bubble up server message when possible
//       try {
//         final body = jsonDecode(res.body);
//         final msg = (body is Map && body['message'] is String)
//             ? body['message'] as String
//             : 'Unexpected error (${res.statusCode})';
//         throw Exception(msg);
//       } catch (_) {
//         throw Exception('Unexpected error (${res.statusCode})');
//       }
//     } catch (e) {
//       _deletingIds.remove(id);
//       error = e.toString().replaceFirst('Exception: ', '');
//       notifyListeners();
//       return false;
//     }
//   }
//
//
// // 🔶 ADD: single-investment state
//   Investment? currentInvestment;
//   bool loadingOne = false;
//
// // 🔶 ADD: GET /investment/get-investment/:id
//   Future<bool> fetchInvestmentById(String id) async {
//     loadingOne = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       final uri = ApiConstants.api('investment/get-investment/$id');
//
//       final res = await http
//           .get(uri, headers: ApiConstants.jsonHeaders())
//           .timeout(const Duration(seconds: 25));
//
//       if (res.statusCode != 200) {
//         try {
//           final body = jsonDecode(res.body);
//           final msg = (body is Map && body['message'] is String)
//               ? body['message'] as String
//               : 'Unexpected error (${res.statusCode})';
//           throw Exception(msg);
//         } catch (_) {
//           throw Exception('Unexpected error (${res.statusCode})');
//         }
//       }
//
//       final decoded = jsonDecode(res.body);
//       // expected: { success: true, data: { ...investment... } }
//       final data = (decoded is Map) ? decoded['data'] : null;
//
//       if (data is Map<String, dynamic>) {
//         currentInvestment = Investment.fromMap(data);
//       } else {
//         currentInvestment = null;
//       }
//
//       loadingOne = false;
//       notifyListeners();
//       return currentInvestment != null;
//     } catch (e) {
//       loadingOne = false;
//       currentInvestment = null;
//       error = e.toString().replaceFirst('Exception: ', '');
//       notifyListeners();
//       return false;
//     }
//   }
//
//
//
// }
//
