// String uri='http://localhost:5004/api/v1';
String kBaseUrl='http://74.118.168.218:5004/api/v1';

// Small helper to build full paths cleanly
Uri apiUri(String path, [Map<String, dynamic>? query]) {
  // make sure path starts with a slash
  final p = path.startsWith('/') ? path : '/$path';
  final uri = Uri.parse('$kBaseUrl$p');
  return query == null ? uri : uri.replace(queryParameters: {
    for (final e in query.entries) e.key: e.value.toString(),
  });
}