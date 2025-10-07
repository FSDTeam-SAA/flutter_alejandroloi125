import 'package:flutter/foundation.dart';
import '../feature/models/auction.dart';
import '../repository/auction_repository.dart';

class AuctionProvider extends ChangeNotifier {
  final AuctionRepository repo;
  AuctionProvider(this.repo);

  bool _loading = false;
  String? _error;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<AuctionResponse> createAuction(AuctionCreateRequest req) async {
    _set(loading: true, error: null);
    try {
      final res = await repo.create(req);
      _set(loading: false, error: null);
      return res;
    } catch (e) {
      _set(loading: false, error: e.toString());
      rethrow;
    }
  }

  void _set({bool? loading, String? error}) {
    if (loading != null) _loading = loading;
    _error = error;
    notifyListeners();
  }

  // list
  Future<AuctionListResponse> all({int page = 1, int limit = 10}) async {
    try {
      return await repo.getAll(page: page, limit: limit);
    } catch (e) {
      _set(error: e.toString());
      rethrow;
    }
  }

  // detail
  Future<AuctionDto> one(String id) async {
    try {
      return await repo.getById(id);
    } catch (e) {
      _set(error: e.toString());
      rethrow;
    }
  }
}
