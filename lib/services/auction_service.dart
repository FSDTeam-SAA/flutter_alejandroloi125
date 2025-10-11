import 'dart:io';
import 'package:dio/dio.dart';

import '../constants/api_paths.dart';
import '../core/network/api_service/api_client.dart';
import '../feature/models/auction.dart';

class AuctionService {
  final Dio _dio;
  AuctionService(ApiClient client) : _dio = client.dio;

  Future<AuctionResponse> createAuction(AuctionCreateRequest req) async {
    // Strong client-side guard: image is required
    if (req.imagePath.isEmpty) {
      throw ArgumentError('Image is required');
    }

    final form = FormData();

    // image
    form.files.add(MapEntry(
      'imageLink', // <-- matches Postman/body key
      await MultipartFile.fromFile(
        req.imagePath,
        filename: req.imagePath.split(Platform.pathSeparator).last,
      ),
    ));

    // multi-value categories: category=cat1, category=cat2, ...
    if (req.category.isEmpty) {
      // Allow backend to coerce, but at least send one value
      form.fields.add(const MapEntry('category', 'general'));
    } else {
      for (final c in req.category) {
        form.fields.add(MapEntry('category', c));
      }
    }

    // other fields
    for (final e in req.toMultipartFields().entries) {
      form.fields.add(MapEntry(e.key, e.value));
    }

    final res = await _dio.post(
      ApiPaths.createAuction,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        error: 'Unexpected response type: ${res.data.runtimeType}',
      );
    }

    final Map<String, dynamic> root = (res.data as Map).cast<String, dynamic>();
    return AuctionResponse.fromJson(root);
  }

  // ---------- LIST ----------
  Future<AuctionListResponse> getAll({int page = 1, int limit = 10}) async {
    final res = await _dio.get(
      ApiPaths.allAuction,
      queryParameters: {'page': page, 'limit': limit},
    );
    final root = (res.data as Map).cast<String, dynamic>();
    return AuctionListResponse.fromJson(root);
  }

  // ---------- DETAIL ----------
  Future<AuctionDto> getById(String id) async {
    final res = await _dio.get(ApiPaths.getAuctionById(id));
    final root = (res.data as Map).cast<String, dynamic>();
    final data =
    (root['data'] as Map).cast<String, dynamic>(); // controller shape
    return AuctionDto.fromJson(data);
  }

  // Optional: list by user id
  Future<AuctionListResponse> getByUser(String userId,
      {int page = 1, int limit = 10}) async {
    final res = await _dio.get(
      ApiPaths.allAuctionByUser(userId),
      queryParameters: {'page': page, 'limit': limit},
    );
    final root = (res.data as Map).cast<String, dynamic>();
    return AuctionListResponse.fromJson(root);
  }

// // lib/services/auction_service.dart
//   Future<void> bid(String auctionId, int amount) async {
//     await _dio.post(ApiPaths.bidAuction(auctionId), data: {'amount': amount});
//   }

  Future<void> bid(String auctionId, int amount, {String? message}) async {
    final body = <String, dynamic>{'amount': amount};
    if (message != null && message.trim().isNotEmpty) {
      body['message'] = message.trim();
    }
    await _dio.patch(ApiPaths.bidAuction(auctionId), data: body);
  }


  // GET /auction/bid/:id
  Future<List<BidItem>> getBids(String auctionId) async {
    final res = await _dio.get(ApiPaths.bidAuction(auctionId));
    final root = (res.data as Map).cast<String, dynamic>();
    final list = (root['data'] is List) ? List.from(root['data']) : const <dynamic>[];
    return list
        .whereType<Map>()
        .map((m) => BidItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }



  // PATCH /auction/bid/:id -> send message OR amount
  Future<void> bidOrMessage(
      String auctionId, {
        int? amount,
        String? message,
      }) async {
    final body = <String, dynamic>{};
    if (amount != null) body['amount'] = amount; // send number
    if (message != null && message.trim().isNotEmpty) {
      body['message'] = message.trim();
    }
    if (body.isEmpty) {
      throw ArgumentError('Provide either amount or message');
    }
    await _dio.patch(ApiPaths.bidAuction(auctionId), data: body);
  }


}


class BidItem {
  final String id;
  final int? amount;
  final String? message;
  final String? userId;
  final DateTime createdAt;

  BidItem({
    required this.id,
    this.amount,
    this.message,
    this.userId,
    required this.createdAt,
  });

  factory BidItem.fromJson(Map<String, dynamic> j) {
    DateTime parseDt(dynamic v) {
      try { return DateTime.parse(v.toString()); } catch (_) { return DateTime.now(); }
    }

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return BidItem(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      amount: asInt(j['amount']),
      message: j['message']?.toString(),
      userId: j['user']?.toString(),
      createdAt: parseDt(j['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

