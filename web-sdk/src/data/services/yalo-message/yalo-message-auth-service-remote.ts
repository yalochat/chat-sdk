// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type { YaloMessageAuthService } from './yalo-message-auth-service';

interface AuthResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
  refresh_token: string;
  client_id: string;
}

interface TokenCache {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
}

export class YaloMessageAuthServiceRemote implements YaloMessageAuthService {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;
  private _cache: TokenCache | null = null;

  constructor(baseUrl: string, config: YaloChatClientConfig) {
    this._baseUrl = baseUrl;
    this._config = config;
  }

  async auth(): Promise<Result<string>> {
    if (this._cache && Date.now() < this._cache.expiresAt) {
      return new Ok(this._cache.accessToken);
    }

    if (this._cache?.refreshToken) {
      return this._refresh(this._cache.refreshToken);
    }

    return this._fetchToken();
  }

  private async _fetchToken(): Promise<Result<string>> {
    try {
      const response = await fetch(`${this._baseUrl}/auth`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_type: 'anonymous',
          channel_id: this._config.channelId,
          organization_id: this._config.organizationId,
          timestamp: Math.floor(Date.now() / 1000),
        }),
      });

      if (!response.ok) {
        return new Err(new Error(`Auth failed: ${response.status}`));
      }

      const data = (await response.json()) as AuthResponse;
      this._storeCache(data);
      return new Ok(data.access_token);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  private async _refresh(refreshToken: string): Promise<Result<string>> {
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
        this._cache = null;
        return new Err(new Error(`Refresh failed: ${response.status}`));
      }

      const data = (await response.json()) as AuthResponse;
      this._storeCache(data);
      return new Ok(data.access_token);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  private _storeCache(data: AuthResponse): void {
    this._cache = {
      accessToken: data.access_token,
      refreshToken: data.refresh_token,
      expiresAt: Date.now() + data.expires_in * 1000,
    };
  }
}
