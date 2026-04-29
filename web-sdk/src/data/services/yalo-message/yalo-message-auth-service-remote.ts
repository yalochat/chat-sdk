// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type { YaloMessageAuthService } from './yalo-message-auth-service';
import { AuthResponse } from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

export class YaloMessageAuthServiceRemote implements YaloMessageAuthService {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;

  constructor(baseUrl: string, config: YaloChatClientConfig) {
    this._baseUrl = `https://${baseUrl}/v1/channels`;
    this._config = config;
  }

  async fetchToken(): Promise<Result<AuthResponse>> {
    try {
      const response = await fetch(`${this._baseUrl}/auth`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_type: this._config.userId ? 'third_party_anonymous' : 'anonymous',
          channel_id: this._config.channelId,
          organization_id: this._config.organizationId,
          timestamp: Math.floor(Date.now() / 1000),
          ...(this._config.userId && { user_id: this._config.userId }),
        }),
      });

      if (!response.ok) {
        return new Err(new Error(`Auth failed: ${response.status}`));
      }

      return new Ok(AuthResponse.fromJSON(await response.json()));
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async refreshToken(refreshToken: string): Promise<Result<AuthResponse>> {
    try {
      const response = await fetch(`${this._baseUrl}/oauth/token`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          grant_type: 'refresh_token',
          refresh_token: refreshToken,
        }),
      });

      if (!response.ok) {
        return new Err(new Error(`Refresh failed: ${response.status}`));
      }

      return new Ok(AuthResponse.fromJSON(await response.json()));
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }
}
