import 'package:flutter/foundation.dart';

class Project {
  final String id;
  final String title;            // the API calls it "name" but we surface as title
  final String description;
  final String category;         // API may return ["build"]; we normalize
  final String location;

  final int? budgetMin;
  final int? budgetMax;
  final int? durationDays;       // parsed from "15day" / "3month" etc.
  final List<String> skills;

  final String? status;
  final int? proposalsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.budgetMin,
    this.budgetMax,
    this.durationDays,
    this.skills = const [],
    this.status,
    this.proposalsCount,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  });

  factory Project.fromMap(Map<String, dynamic> m) {
    int? _parseDuration(dynamic raw) {
      if (raw == null) return null;
      if (raw is int) return raw;
      if (raw is String) {
        final n = int.tryParse(RegExp(r'\d+').firstMatch(raw)?.group(0) ?? '');
        if (n == null) return null;
        if (raw.contains('month')) return n * 30;
        if (raw.contains('day')) return n;
        return n;
      }
      return null;
    }

    String? _firstImage(dynamic v) {
      if (v is List && v.isNotEmpty) {
        final first = v.first;
        if (first is Map && first['url'] is String && first['url'].toString().isNotEmpty) {
          return first['url'] as String;
        }
        if (first is String && first.isNotEmpty) return first;
      }
      if (v is String && v.isNotEmpty) return v;
      return null;
    }

    List<String> _skills(dynamic v) {
      if (v is List) {
        return v.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      if (v is String) {
        return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    DateTime? _dt(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    String _category(dynamic v) {
      if (v is List && v.isNotEmpty) return (v.first ?? '').toString();
      return (v ?? '').toString();
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return Project(
      id: (m['_id'] ?? m['id'] ?? '').toString(),
      title: (m['title'] ?? m['name'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      category: _category(m['category']),
      location: (m['location'] ?? '').toString(),
      budgetMin: _toInt(m['budget_min'] ?? m['minBudget'] ?? m['budgetMin']),
      budgetMax: _toInt(m['budget_max'] ?? m['maxBudget'] ?? m['budgetMax']),
      durationDays: _parseDuration(m['duration'] ?? m['deadline'] ?? m['duration_days']),
      skills: _skills(m['skills']),
      status: (m['status']?.toString().isEmpty ?? true) ? null : m['status'].toString(),
      proposalsCount: _toInt(m['project_proposal'] ?? m['proposals'] ?? m['proposalsCount']),
      createdAt: _dt(m['createdAt']),
      updatedAt: _dt(m['updatedAt']),
      imageUrl: _firstImage(m['images'] ?? m['image']),
    );
  }
}
