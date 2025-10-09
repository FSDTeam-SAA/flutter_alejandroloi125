// lib/feature/auctions/service/auction_service.dart
import '../../../core/network/api_service/api_client.dart';

class AuctionService {
  final ApiClient apiClient;
  AuctionService(this.apiClient);

  Future<Map<String, dynamic>> fetchAuctions() async {
    final res = await apiClient.dio.get('/auction/all-auction');
    if (res.statusCode == 200) return res.data;
    throw Exception('Failed to load auctions');
  }

  Future<Map<String, dynamic>> fetchUpcomingAuctions() async {
    final res = await apiClient.dio.get('/auction/upcoming-auction');
    if (res.statusCode == 200) return res.data;
    throw Exception('Failed to load upcoming auctions');
  }

  Future<Map<String, dynamic>> fetchAuctionChat(String auctionId) async {
// Corrected URL as per your BASE_URL example
    final res = await apiClient.dio.get('/auction/get-auction/$auctionId');
    if (res.statusCode == 200) return res.data;
    throw Exception('Failed to load auction chat');
  }

/*  Future<Map<String,dynamic>> fetchAuctionChat(String auctionId) async {
    final res = await apiClient.dio.get('/auction/chat/$auctionId');
    if (res.statusCode == 200) return res.data;
    throw Exception('Failed to load auction chat');
  }*/

}
