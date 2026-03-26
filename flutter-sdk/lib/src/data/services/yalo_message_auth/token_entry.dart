// Copyright (c) Yalochat, Inc. All rights reserved.

class TokenEntry {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String userId;

  TokenEntry({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
  });
}
