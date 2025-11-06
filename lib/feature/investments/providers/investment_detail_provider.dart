// lib/feature/investment/state/investment_detail_provider.dart
import 'package:flutter/foundation.dart';
import '../../../repository/investment_repository.dart';
import '../../models/investment.dart';

enum LoadState { idle, loading, ready, error }

class InvestmentDetailProvider with ChangeNotifier {
  final InvestmentRepository repo;
  InvestmentDetailProvider(this.repo);

  LoadState _state = LoadState.idle;
  LoadState get state => _state;

  Investment? _inv; Investment? get inv => _inv;
  String? _error;    String? get error => _error;
  bool _favBusy = false; bool get favBusy => _favBusy;

  Future<void> init(String id, {Investment? prefetched}) async {
    if (_state == LoadState.loading) return;
    _state = LoadState.loading; _error = null; _inv = prefetched; notifyListeners();
    try {
      _inv = prefetched ?? await repo.getById(id);
      _state = LoadState.ready; notifyListeners();
    } catch (e) {
      _state = LoadState.error; _error = e.toString(); notifyListeners();
    }
  }

  Future<void> toggleFavorite(String projectId) async {
    if (_favBusy || _inv == null) return;
    _favBusy = true;
    _inv = _inv!.copyWith(isFavorite: !_inv!.isFavorite); // optimistic
    notifyListeners();
    try {
      await repo.toggleFavorite(projectId);
    } catch (_) {
      _inv = _inv!.copyWith(isFavorite: !_inv!.isFavorite); // revert
      _favBusy = false; notifyListeners();
      rethrow;
    }
    _favBusy = false; notifyListeners();
  }
}
