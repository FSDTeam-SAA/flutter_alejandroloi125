import 'dart:io';
import 'package:flutter/foundation.dart';

import '../feature/models/investment.dart';
import '../feature/service/models/investment_page.dart';
import '../repository/investment_repository.dart';

class InvestmentProvider extends ChangeNotifier {
  final InvestmentRepository repo;
  InvestmentProvider(this.repo);

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  final List<Investment> _items = [];
  int _page = 1, _pages = 1;
  List<Investment> get items => List.unmodifiable(_items);
  int get page => _page;
  int get pages => _pages;

  void _set({bool? loading, String? error}) {
    if (loading != null) _loading = loading;
    _error = error;
    notifyListeners();
  }



  // ---- validators (same as before) ----
  String? vRequired(String? v, String name) =>
      (v == null || v.trim().isEmpty) ? '$name is required' : null;

  String? vNumber(String? v, String name, {num min = 1}) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    final n = num.tryParse(v);
    if (n == null) return 'Enter a valid number for $name';
    if (n < min) return '$name must be at least $min';
    return null;
  }

  Future<Investment> getById(String id) async {
    try {
      final inv = await repo.getById(id);
      return inv;
    } catch (e) {
      // optionally store error in provider
      rethrow;
    }
  }

  // ---- list (by user) ----
  Future<void> fetchByUser({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    _set(loading: true, error: null);
    try {
      final InvestmentPage r =
      await repo.getAllByUser(userId: userId, page: page, limit: limit);
      _applyPage(r, append: page > 1);
      _set(loading: false);
    } catch (e) {
      _set(loading: false, error: e.toString());
    }
  }

  Future<void> fetchMoreByUser({
    required String userId,
    int limit = 10,
  }) async {
    if (_loading || _page >= _pages) return;
    await fetchByUser(userId: userId, page: _page + 1, limit: limit);
  }

  // ---- helpers ----
  void _applyPage(InvestmentPage r, {required bool append}) {
    _page = r.page;
    _pages = r.pages;

    if (!append || _page == 1) {
      _items
        ..clear()
        ..addAll(r.items);
      return;
    }

    // de-dupe on id when appending
    final map = {for (final it in _items) it.id: it};
    for (final it in r.items) {
      map[it.id] = it;
    }
    _items
      ..clear()
      ..addAll(map.values);
  }








  String? vDays(String? v) {
    final err = vNumber(v, 'Funding duration (days)', min: 1);
    if (err != null) return err;
    if (int.parse(v!.trim()) > 365) return 'Funding duration max is 365 days';
    return null;
  }


  String? vImage(File? f) => (f == null) ? 'Image is required' : null;

  // ---- create (unchanged) ----
  Future<bool> create({
    required String name,
    required String description,
    required String category,
    required String fundingGoalStr,
    required String durationDaysStr,
    required String location,
    required String investmentTerms,
    required File imageFile,
    // required List<File> imageFiles, // <-- multiple images
  }) async {
    final errs = <String?>[
      vRequired(name, 'Title'),
      vRequired(description, 'Description'),
      vRequired(category, 'Category'),
      vNumber(fundingGoalStr, 'Funding goal', min: 1),
      vNumber(durationDaysStr, 'Funding duration (days)', min: 1),
      vRequired(location, 'Location'),
      vRequired(investmentTerms, 'Investment terms'),
      vImage(imageFile),
    ].where((e) => e != null).cast<String>().toList();

    if (errs.isNotEmpty) {
      _set(error: errs.first);
      return false;
    }

    _set(loading: true, error: null);
    try {
      final fundingGoal = int.parse(fundingGoalStr.trim());
      final duration = '${durationDaysStr.trim()} day';

      await repo.create(
        name: name.trim(),
        description: description.trim(),
        category: category.trim(),
        fundingGoal: fundingGoal,
        fundingDuration: duration,
        location: location.trim(),
        investmentTerms: investmentTerms.trim(),
        imageFile: imageFile,
      );

      _set(loading: false);
      return true;
    } catch (e) {
      _set(loading: false, error: e.toString());
      return false;
    }
  }

  // ---- list (uses typed InvestmentPage) ----
  Future<void> fetch({int page = 1, int limit = 10}) async {
    _set(loading: true, error: null);
    try {
      final InvestmentPage r = await repo.getAll(page: page, limit: limit);
      _page = r.page;
      _pages = r.pages;

      if (page == 1) _items.clear();
      _items.addAll(r.items);

      _set(loading: false);
    } catch (e) {
      _set(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() => fetch(page: 1);

  Future<void> delete(String id) async {
    _set(loading: true, error: null);
    try {
      await repo.delete(id);
      _items.removeWhere((e) => e.id == id);
      _set(loading: false);
    } catch (e) {
      _set(loading: false, error: e.toString());
    }
  }






}
