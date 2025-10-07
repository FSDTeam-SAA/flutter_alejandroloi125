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
}

