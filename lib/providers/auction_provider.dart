import 'package:flutter/foundation.dart';
import '../feature/models/auction.dart';
import '../repository/auction_repository.dart';
import '../services/auction_service.dart';

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






// ---- ADD FIELDS (below your _loading/_error) ----
  final List<AuctionDto> _items = [];
  int _page = 1, _pages = 1;

  List<AuctionDto> get items => List.unmodifiable(_items);
  int get page => _page;
  int get pages => _pages;

// ---- ADD: fetch list by user (paged) ----
  Future<void> fetchByUser({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    _set(loading: true, error: null);
    try {
      final AuctionListResponse r =
      await repo.getByUser(userId, page: page, limit: limit);
      _applyPage(r, append: page > 1);
      _set(loading: false);
    } catch (e) {
      _set(loading: false, error: e.toString());
    }
  }

// ---- ADD: fetch more ----
  Future<void> fetchMoreByUser({
    required String userId,
    int limit = 10,
  }) async {
    if (_loading || _page >= _pages) return;
    await fetchByUser(userId: userId, page: _page + 1, limit: limit);
  }

// ---- ADD: apply a page ----
  void _applyPage(AuctionListResponse r, {required bool append}) {
    _page = r.page;
    _pages = r.pages;

    if (!append || _page == 1) {
      _items
        ..clear()
        ..addAll(r.auctions);
      return;
    }

    final map = {for (final it in _items) it.id: it};
    for (final it in r.auctions) {
      map[it.id] = it;
    }
    _items
      ..clear()
      ..addAll(map.values);
  }



  // ======= chat (bids/messages) state =======
  bool _chatLoading = false;
  String? _chatError;
  List<BidMessageDto> _chat = [];
  bool get chatLoading => _chatLoading;
  String? get chatError => _chatError;
  List<BidMessageDto> get chat => List.unmodifiable(_chat);

  Future<void> fetchBids(String auctionId) async {
    _chatLoading = true;
    _chatError = null;
    notifyListeners();
    try {
      final items = await repo.getBids(auctionId);
      // _chat = items;
      _chatLoading = false;
      notifyListeners();
    } catch (e) {
      _chatLoading = false;
      _chatError = e.toString();
      notifyListeners();
    }
  }


  Future<List<BidItem>> getChat(String auctionId) async {
    try {
      return await repo.getBids(auctionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> bidOrMessage({
    required String auctionId,
    int? amount,
    String? message,
  }) async {
    try {
      await repo.bidOrMessage(auctionId, amount: amount, message: message);
    } catch (e) {
      rethrow;
    }
  }

  // Keep for compatibility if used elsewhere:
  Future<void> placeBid({required String auctionId, required int amount}) =>
      bidOrMessage(auctionId: auctionId, amount: amount);



}
