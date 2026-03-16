// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';

abstract class YaloMessageAuthService {
  // Auth calls the /auth endpoint and caches the token.
  // If the token is expired it renews it with the refresh token.
  Future<Result<String>> auth();
}
