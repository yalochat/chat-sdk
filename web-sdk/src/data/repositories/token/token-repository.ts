// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';

export interface TokenRepository {
  getToken(): Promise<Result<string>>;
}
