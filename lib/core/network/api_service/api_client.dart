// lib/core/network/api_service/api_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/token_store.dart';

import '../../env/env.dart';

class ApiClient {
  final TokenStore _store;
  late final Dio dio;

  ApiClient(this._store) {
    dio = Dio(BaseOptions(
      baseUrl: AppEnv.baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
    ));
    dio.interceptors.add(PrettyDioLogger(
      compact: true, requestBody: true, responseBody: true,
    ));
    dio.interceptors.add(_AuthInterceptor(_store));
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenStore store;
  _AuthInterceptor(this.store);

  bool _refreshing = false;
  final List<void Function()> _queue = [];

  bool _isRefreshCall(RequestOptions o) =>
      o.path.contains(ApiPaths.refreshToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await store.readAccess();
    if (token != null && token.isNotEmpty && !_isRefreshCall(options)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode ?? 0;

    if (status == 401 && !_isRefreshCall(err.requestOptions)) {
      if (_refreshing) {
        _queue.add(() => _retry(err, handler));
        return;
      }

      _refreshing = true;
      try {
        final refresh = await store.readRefresh();
        if (refresh == null || refresh.isEmpty) return handler.next(err);

        final dio = Dio(BaseOptions(baseUrl: AppEnv.baseUrl));
        final r = await dio.post(ApiPaths.refreshToken, data: {'refreshToken': refresh});
        final map = (r.data is Map) ? r.data as Map : <String, dynamic>{};

        final access  = map['accessToken'] ?? map['token'];
        final refreshNew = map['refreshToken'];
        await store.saveTokens(access: access as String?, refresh: refreshNew as String?);

        for (final fn in _queue) fn();
        _queue.clear();

        return _retry(err, handler);
      } catch (_) {
        return handler.next(err);
      } finally {
        _refreshing = false;
      }
    }
    handler.next(err);
  }

  Future<void> _retry(DioException err, ErrorInterceptorHandler handler) async {
    final o = err.requestOptions;
    final dio = Dio(BaseOptions(baseUrl: AppEnv.baseUrl));

    final access = await store.readAccess();
    final headers = Map<String, dynamic>.from(o.headers);
    if (access != null && access.isNotEmpty) {
      headers['Authorization'] = 'Bearer $access';
    }

    try {
      final res = await dio.request(
        o.path,
        data: o.data,
        queryParameters: o.queryParameters,
        options: Options(method: o.method, headers: headers),
      );
      handler.resolve(res);
    } catch (_) {
      handler.next(err);
    }
  }
}


// import 'package:alejandroloi/core/network/api_service/token_meneger.dart';
// import 'package:dio/dio.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
//
// import 'package:alejandroloi/core/network/api_service/token_store.dart';
//
// import '../../env/env.dart';
//
// class ApiClient {
//   final TokenStore tokenStore;
//   late final Dio dio;
//
//   ApiClient(this.tokenStore) {
//     final options = BaseOptions(
//       baseUrl: AppEnv.baseUrl,
//       connectTimeout: const Duration(seconds: 25),
//       receiveTimeout: const Duration(seconds: 25),
//       contentType: 'application/json',
//       responseType: ResponseType.json,
//     );
//
//     dio = Dio(options);
//
//     // Interceptors order matters: logger first, then auth/refresh.
//     dio.interceptors.add(PrettyDioLogger(
//       requestBody: true, responseBody: true, compact: true,
//     ));
//     dio.interceptors.add(TokenMeneger(dio, tokenStore).interceptor);
//   }
//
//
//
//
//
// }
