// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';

export interface YaloMessageAuthService {
  // Auth calls the /auth endpoint and caches the token
  // if the token is expired it renews it with the refresh token.
  auth(): Promise<Result<string>>;
}
