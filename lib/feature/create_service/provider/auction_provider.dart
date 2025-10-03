import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../models/auction.dart';

class AuctionProvider with ChangeNotifier {
  // form / submit
  bool submitting = false;
  String? error;

  // fields for create
  String? title, category, description, location, shippingDetails;
  int? startingBid;
  int? durationMinutes; // 10/20/30/60
  String? scheduleDate; // dd-MM-yyyy
  String? scheduleTime; // h:mm AM/PM

  // setters
  void setTitle(String v) => title = v;
  void setCategory(String v) => category = v;
  void setDescription(String v) => description = v;
  void setLocation(String v) => location = v;
  void setShippingDetails(String v) => shippingDetails = v;
  void setStartingBid(String v) =>
      startingBid = int.tryParse(v.replaceAll(',', '').trim());
  void setDurationMinutes(int? v) => durationMinutes = v;
  void setSchedule({String? date, String? time}) {
    scheduleDate = date ?? scheduleDate;
    scheduleTime = time ?? scheduleTime;
  }

  Map<String, dynamic> _buildCreatePayload() {
    final map = <String, dynamic>{
      'name': title?.trim(),
      'description': description?.trim(),
      'category': category?.trim(),
      'starting_bid': startingBid,
      'duration': durationMinutes,
      'location': location?.trim(),
      'skills': <String>[],
      'schedule': {
        'date': scheduleDate,
        'time': scheduleTime,
      },
    };
    map.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
    return map;
  }

  Future<bool> submit() async {
    if ((title ?? '').isEmpty ||
        (category ?? '').isEmpty ||
        startingBid == null ||
        durationMinutes == null ||
        (scheduleDate ?? '').isEmpty ||
        (scheduleTime ?? '').isEmpty) {
      error = 'Please fill all fields (including date & time)';
      notifyListeners();
      return false;
    }

    submitting = true;
    error = null;
    notifyListeners();

    try {
      final res = await http.post(
        ApiConstants.api('auction/create-auction'),
        headers: ApiConstants.jsonHeaders(),
        body: jsonEncode(_buildCreatePayload()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        submitting = false;
        notifyListeners();
        return true;
      }

      try {
        final body = jsonDecode(res.body);
        error = (body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed (${res.statusCode})';
      } catch (_) {
        error = 'Failed (${res.statusCode})';
      }

      submitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      submitting = false;
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ---------- LIST ----------
  List<Auction> items = [];
  bool loadingList = false;

  Future<bool> fetchAll() async {
    loadingList = true;
    error = null;
    notifyListeners();
    try {
      final res = await http.get(
        ApiConstants.api('auction/all-auction'),
        headers: ApiConstants.jsonHeaders(),
      );
      if (res.statusCode != 200) {
        throw Exception('Failed (${res.statusCode})');
      }
      final decoded = jsonDecode(res.body);
      final data = (decoded is Map) ? decoded['data'] : null;
      final list = (data is Map) ? (data['auctions'] ?? data['items']) : null;
      items = (list is List ? list : const [])
          .whereType<Map<String, dynamic>>()
          .map(Auction.fromMap)
          .toList();

      loadingList = false;
      notifyListeners();
      return true;
    } catch (e) {
      loadingList = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---------- DETAILS ----------
  Auction? current;
  bool loadingOne = false;

  Future<bool> fetchById(String id) async {
    loadingOne = true;
    error = null;
    notifyListeners();
    try {
      final res = await http.get(
        ApiConstants.api('auction/get-auction/$id'),
        headers: ApiConstants.jsonHeaders(),
      );
      if (res.statusCode != 200) throw Exception('Failed (${res.statusCode})');
      final decoded = jsonDecode(res.body);
      final data = (decoded is Map) ? decoded['data'] : null;
      current = (data is Map<String, dynamic>) ? Auction.fromMap(data) : null;
      loadingOne = false;
      notifyListeners();
      return current != null;
    } catch (e) {
      loadingOne = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---------- DELETE (optional, if your API supports it) ----------
  final Set<String> _deletingIds = {};
  Set<String> get deletingIds => _deletingIds;

  Future<bool> deleteById(String id) async {
    _deletingIds.add(id);
    notifyListeners();
    try {
      final res = await http.delete(
        ApiConstants.api('auction/$id'),
        headers: ApiConstants.jsonHeaders(),
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        items.removeWhere((e) => e.id == id);
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
}
