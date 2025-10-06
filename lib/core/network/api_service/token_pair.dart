// lib/core/network/models/token_pair.dart
class TokenPair {
  final String accessToken;
  final String refreshToken;
  const TokenPair({required this.accessToken, required this.refreshToken});

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
    accessToken: (json['accessToken'] ?? json['token'] ?? '').toString(),
    refreshToken: (json['refreshToken'] ?? '').toString(),
  );
}
