// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';

abstract class YaloMessageAuthService {
  // Auth calls the /auth endpoint and caches the token.
  // If the token is expired it renews it with the refresh token.
  Future<Result<TokenEntry>> auth();
}
