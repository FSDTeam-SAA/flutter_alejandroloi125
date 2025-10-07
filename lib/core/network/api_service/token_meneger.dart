import 'package:dio/dio.dart';

import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/token_store.dart';

import '../../env/env.dart';

class TokenMeneger {
  final Dio dio;
  final TokenStore store;

  TokenMeneger(this.dio, this.store);

  final Dio _refreshDio = Dio(BaseOptions(baseUrl: AppEnv.baseUrl));
  bool _refreshing = false;

  InterceptorsWrapper get interceptor => InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await store.readAccess();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
      // Only try to refresh when we got 401 back from server
      if (e.response?.statusCode == 401) {
        try {
          final newToken = await _ensureAccessToken();
          if (newToken != null) {
            final Response r = await _retry(e.requestOptions, newToken);
            return handler.resolve(r);
          }
        } catch (_) {
          // fall-through to next handler, caller will see the error
        }
      }
      return handler.next(e);
    },
  );

  Future<String?> _ensureAccessToken() async {
    if (_refreshing) {
      // Another request is already refreshing. Just wait a bit and read again.
    } else {
      _refreshing = true;
      try {
        final refreshToken = await store.readRefresh();
        if (refreshToken == null || refreshToken.isEmpty) {
          await store.clear();
          return null;
        }
        final resp = await _refreshDio.post(
          ApiPaths.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        final data = resp.data is Map ? resp.data as Map : <String, dynamic>{};
        final access = data['accessToken'] ?? data['token'];
        final refresh = data['refreshToken'];

        if (access is String) {
          await store.saveTokens(access: access, refresh: refresh as String?);
          return access;
        }
      } finally {
        _refreshing = false;
      }
    }
    // read whatever we have now
    return store.readAccess();
  }

  Future<Response<dynamic>> _retry(RequestOptions req, String token) {
    final opts = Options(
      method: req.method,
      headers: Map<String, dynamic>.from(req.headers)
        ..['Authorization'] = 'Bearer $token',
    );
    return dio.request(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      options: opts,
    );
  }
}
