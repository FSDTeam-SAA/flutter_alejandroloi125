// core/network/api_service/api_client.dart
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
    dio.interceptors.add(PrettyDioLogger(requestBody: true, responseBody: true));
    dio.interceptors.add(_AuthInterceptor(_store));
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenStore store;
  _AuthInterceptor(this.store);

  bool _refreshing = false;

  bool _isRefresh(RequestOptions o) => o.path.contains(ApiPaths.refreshToken);

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    final access = await store.readAccess();
    if (access != null && access.isNotEmpty && !_isRefresh(o)) {
      o.headers['Authorization'] = 'Bearer $access';
    }
    h.next(o);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler h) async {
    if (err.response?.statusCode == 401 && !_isRefresh(err.requestOptions)) {
      if (_refreshing) return h.next(err); // keep it simple
      _refreshing = true;
      try {
        final refresh = await store.readRefresh();
        if (refresh == null || refresh.isEmpty) return h.next(err);

        final tmp = Dio(BaseOptions(baseUrl: AppEnv.baseUrl));
        final r = await tmp.post(ApiPaths.refreshToken, data: {'refreshToken': refresh});
        final map = (r.data is Map) ? r.data as Map : <String, dynamic>{};
        final access = (map['accessToken'] ?? map['token']) as String?;
        final refreshNew = map['refreshToken'] as String?;
        await store.saveTokens(access: access, refresh: refreshNew);

        // retry original
        final o = err.requestOptions;
        final headers = Map<String, dynamic>.from(o.headers);
        if (access != null) headers['Authorization'] = 'Bearer $access';
        final res = await tmp.request(
          o.path,
          data: o.data,
          queryParameters: o.queryParameters,
          options: Options(method: o.method, headers: headers),
        );
        return h.resolve(res);
      } catch (_) {
        return h.next(err);
      } finally {
        _refreshing = false;
      }
    }
    h.next(err);
  }
}


