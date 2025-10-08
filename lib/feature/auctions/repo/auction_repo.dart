// lib/feature/auctions/repo/auction_repo.dart
import '../model/auction_model.dart';

import '../services/auctions_services.dart';

class AuctionRepository {
  final AuctionService service;
  AuctionRepository(this.service);

  Future<AuctionModel> getAuctions() async {
    final json = await service.fetchAuctions();
    return AuctionModel.fromJson(json);
  }
}
