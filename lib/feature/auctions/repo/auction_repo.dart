// lib/feature/auctions/repo/auction_repo.dart
import '../model/auction_model.dart';

import '../model/chat_model.dart';
import '../services/auctions_services.dart';

class AuctionRepository {
  final AuctionService service;
  AuctionRepository(this.service);

  Future<AuctionModel> getAuctions() async {
    final json = await service.fetchAuctions();
    return AuctionModel.fromJson(json);
  }


  Future<ChatResponse> getAuctionChat(String auctionId) async {
    final json = await service.fetchAuctionChat(auctionId);
    return ChatResponse.fromJson(json);
  }

}
