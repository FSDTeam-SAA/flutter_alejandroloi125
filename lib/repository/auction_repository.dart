import '../feature/models/auction.dart';
import '../services/auction_service.dart';

class AuctionRepository {
  final AuctionService service;
  AuctionRepository(this.service);

  Future<AuctionResponse> create(AuctionCreateRequest req) {
    return service.createAuction(req);
  }

  Future<AuctionListResponse> getAll({int page = 1, int limit = 10}) =>
      service.getAll(page: page, limit: limit);

  Future<AuctionDto> getById(String id) => service.getById(id);

  Future<AuctionListResponse> getByUser(String userId,
      {int page = 1, int limit = 10}) =>
      service.getByUser(userId, page: page, limit: limit);

  // Future<void> bid(String id, int amount) => service.bid(id, amount);

  Future<void> bid(String id, int amount, {String? message}) =>
      service.bid(id, amount, message: message);

  Future<List<BidItem>> getBids(String auctionId) => service.getBids(auctionId);

  Future<void> bidOrMessage(
      String auctionId, {
        int? amount,
        String? message,
      }) =>
      service.bidOrMessage(auctionId, amount: amount, message: message);


}
