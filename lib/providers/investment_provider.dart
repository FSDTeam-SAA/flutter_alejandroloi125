// lib/feature/investment/providers/investment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import '../feature/aven/view/my_event_investments/my_event_investment_detail.dart';
import '../feature/models/investment.dart';
import '../repository/investment_repository.dart';

class InvestmentProvider extends ChangeNotifier {
  final InvestmentRepository repo;
  InvestmentProvider(this.repo);

  bool _loading = false;
  String? _error;
  List<Investment> _items = [];
  Investment? _detail;

  bool get loading => _loading;
  String? get error => _error;
  List<Investment> get items => _items;
  Investment? get detail => _detail;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  // -------- validators ----------
  String? vRequired(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    return null;
  }

  String? vNumber(String? v, String name, {num min = 0}) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    final n = num.tryParse(v);
    if (n == null) return 'Enter a valid number for $name';
    if (n < min) return '$name must be at least $min';
    return null;
  }

  // -------- actions ----------
  Future<bool> create({
    required String name,
    required String description,
    required String category,
    required int fundingGoal,
    required String fundingDuration,
    required String location,
    required String investmentTerms,
    dynamic imageFile,
  }) async {
    _setError(null); _setLoading(true);
    try {
      final it = await repo.create(
        name: name,
        description: description,
        category: category,
        fundingGoal: fundingGoal,
        fundingDuration: fundingDuration,
        location: location,
        investmentTerms: investmentTerms,
        imageFile: imageFile,
      );
      _items = [it, ..._items]; // prepend
      return true;
    } catch (e) {
      _setError(e.toString()); return false;
    } finally { _setLoading(false); }
  }

  Future<bool> fetchAll({int page = 1, int limit = 10}) async {
    _setError(null); _setLoading(true);
    try { _items = await repo.getAll(page: page, limit: limit); return true; }
    catch (e) { _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }

  Future<bool> fetchMine(String userId, {int page = 1, int limit = 10}) async {
    _setError(null); _setLoading(true);
    try { _items = await repo.getMine(userId, page: page, limit: limit); return true; }
    catch (e) { _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }

  Future<bool> fetchById(String id) async {
    _setError(null); _setLoading(true);
    try { _detail = await repo.getById(id); return true; }
    catch (e) { _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }

  Future<bool> update(String id, Map<String, dynamic> body) async {
    _setError(null); _setLoading(true);
    try {
      final updated = await repo.update(id, body);
      _items = _items.map((e) => e.id == id ? updated : e).toList();
      if (_detail?.id == id) _detail = updated;
      return true;
    } catch (e) {
      _setError(e.toString()); return false;
    } finally { _setLoading(false); }
  }

  // Future<bool> remove(String id) async {
  //   _setError(null); _setLoading(true);
  //   try {
  //     await repo.delete(id);
  //     _items.removeWhere((e) => e.id == id);
  //     if (_detail?.id == id) _detail = null;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _setError(e.toString()); return false;
  //   } finally { _setLoading(false); }
  // }
}
