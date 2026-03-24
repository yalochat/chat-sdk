// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';
import type { AuthResponse } from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

export type { AuthResponse };

export interface YaloMessageAuthService {
  fetchToken(): Promise<Result<AuthResponse>>;
  refreshToken(refreshToken: string): Promise<Result<AuthResponse>>;
}
