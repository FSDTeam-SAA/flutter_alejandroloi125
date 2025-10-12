// lib/feature/project/providers/project_provider.dart
import 'package:flutter/foundation.dart';
import '../feature/models/project.dart';
import '../feature/service/models/project_page.dart';
import '../repository/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository repo;
  ProjectProvider(this.repo);

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;
  Project? _current;

  final List<Project> _items = [];
  int _page = 1, _pages = 1;
  List<Project> get items => List.unmodifiable(_items);
  int get page => _page;
  int get pages => _pages;

  void _set({bool? loading, String? error}) {
    if (loading != null) _loading = loading;
    _error = error;
    notifyListeners();
  }

  // ----------------- validators -----------------
  String? vRequired(String? v, String name) =>
      (v == null || v.trim().isEmpty) ? '$name is required' : null;

  String? vInt(String? v, String name, {int min = 0}) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Enter a valid number for $name';
    if (n < min) return '$name must be ≥ $min';
    return null;
  }

  // ----------------- create -----------------
  Future<bool> create({
    required String title,
    required String description,
    required String category,
    required String minBudgetStr,
    required String maxBudgetStr,
    required String deadlineDaysStr,
    required String location,
    required String skillsCsv, // comma separated in the UI
  }) async {
    // form validation here as a safety net too
    final errs = <String?>[
      vRequired(title, 'Title'),
      vRequired(description, 'Description'),
      vRequired(category, 'Category'),
      vInt(minBudgetStr, 'Min budget', min: 0),
      vInt(maxBudgetStr, 'Max budget', min: 0),
      vInt(deadlineDaysStr, 'Deadline (days)', min: 1),
      vRequired(location, 'Location'),
    ].where((e) => e != null).cast<String>().toList();

    if (errs.isNotEmpty) {
      _set(error: errs.first);
      return false;
    }

    final minB = int.parse(minBudgetStr.trim());
    final maxB = int.parse(maxBudgetStr.trim());
    if (maxB > 0 && minB > maxB) {
      _set(error: 'Max budget must be greater than or equal to Min budget');
      return false;
    }

    final days = int.parse(deadlineDaysStr.trim());
    final skills = skillsCsv
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _set(loading: true, error: null);
    try {
      await repo.create(
        title: title.trim(),
        description: description.trim(),
        category: category.trim(),
        minBudget: minB,
        maxBudget: maxB,
        durationDays: days,
        location: location.trim(),
        skills: skills,
      );
      _set(loading: false);
      return true;
    } catch (e) {
      _set(loading: false, error: e.toString());
      return false;
    }
  }

  // ================= LIST =================
  Future<void> fetch({int page = 1, int limit = 10}) async {
    _set(loading: true, error: null);
    try {
      final ProjectPage r = await repo.getAll(page: page, limit: limit);
      _page = r.page;
      _pages = r.pages;
      if (page == 1) _items.clear();
      _items.addAll(r.items);
      _set(loading: false);
    } catch (e) {
      _set(loading: false, error: e.toString());
    }
  }



  // LIST (by user)
  Future<void> fetchMine(String userId, {int page = 1, int limit = 10}) async {
    _set(loading: true, error: null);
    try {
      final ProjectPage r = await repo.getAllByUser(userId, page: page, limit: limit);
      _page = r.page;
      _pages = r.pages;
      if (page == 1) _items.clear();
      _items.addAll(r.items);
      _set(loading: false);
    } catch (e) {
      _set(loading: false, error: e.toString());
    }
  }

  Future<void> fetchMoreMine(String userId, {int limit = 10}) async {
    if (_loading || _page >= _pages) return;
    await fetchMine(userId, page: _page + 1, limit: limit);
  }

  Future<void> refresh() => fetch(page: 1);

  // ================= GET ONE =================
  Future<Project?> getById(String id) async {
    _set(loading: true, error: null);
    try {
      _current = await repo.getById(id);
      _set(loading: false);
      return _current;
    } catch (e) {
      _set(loading: false, error: e.toString());
      return null;
    }
  }

  // ================= UPDATE =================
  Future<bool> update(
      String id, {
        String? title,
        String? description,
        String? category,
        String? minBudgetStr,
        String? maxBudgetStr,
        String? deadlineDaysStr,
        String? location,
        String? skillsCsv,
        String? status,
      }) async {
    // quick optional validations if strs provided
    if (minBudgetStr != null && vInt(minBudgetStr, 'Min budget', min: 0) != null) {
      _set(error: vInt(minBudgetStr, 'Min budget', min: 0));
      return false;
    }
    if (maxBudgetStr != null && vInt(maxBudgetStr, 'Max budget', min: 0) != null) {
      _set(error: vInt(maxBudgetStr, 'Max budget', min: 0));
      return false;
    }
    if (deadlineDaysStr != null &&
        vInt(deadlineDaysStr, 'Deadline (days)', min: 1) != null) {
      _set(error: vInt(deadlineDaysStr, 'Deadline (days)', min: 1));
      return false;
    }

    final minB = minBudgetStr != null ? int.parse(minBudgetStr) : null;
    final maxB = maxBudgetStr != null ? int.parse(maxBudgetStr) : null;
    if (minB != null && maxB != null && maxB > 0 && minB > maxB) {
      _set(error: 'Max budget must be greater than or equal to Min budget');
      return false;
    }
    final days = deadlineDaysStr != null ? int.parse(deadlineDaysStr) : null;
    final skills = skillsCsv?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    _set(loading: true, error: null);
    try {
      final updated = await repo.update(
        id,
        title: title,
        description: description,
        category: category,
        minBudget: minB,
        maxBudget: maxB,
        deadlineDays: days,
        location: location,
        skills: skills,
        status: status,
      );

      // replace in local list
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx != -1) _items[idx] = updated;
      if (_current?.id == id) _current = updated;

      _set(loading: false);
      return true;
    } catch (e) {
      _set(loading: false, error: e.toString());
      return false;
    }
  }

  // ================= DELETE =================
  Future<bool> delete(String id) async {
    _set(loading: true, error: null);
    try {
      await repo.delete(id);
      _items.removeWhere((e) => e.id == id);
      if (_current?.id == id) _current = null;
      _set(loading: false);
      return true;
    } catch (e) {
      _set(loading: false, error: e.toString());
      return false;
    }
  }
}
