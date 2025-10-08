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
}
