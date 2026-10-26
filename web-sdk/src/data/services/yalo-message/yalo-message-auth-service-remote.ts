// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type { YaloMessageAuthService } from './yalo-message-auth-service';
import { AuthResponse } from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

// Who the backend is told it is talking to, with the name `/auth` expects.
const UserType = {
  anonymous: 'anonymous',
  thirdPartyAnonymous: 'third_party_anonymous',
  externalUser: 'external_user',
} as const;
type UserType = (typeof UserType)[keyof typeof UserType];

export class YaloMessageAuthServiceRemote implements YaloMessageAuthService {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;

  constructor(baseUrl: string, config: YaloChatClientConfig) {
    this._baseUrl = `https://${baseUrl}/v1/channels`;
    this._config = config;
  }

  async fetchToken(): Promise<Result<AuthResponse>> {
    try {
      const provider = this._config.userAuthTokenProvider;
      const userAuthToken = provider ? await provider() : undefined;
      if (provider && !userAuthToken?.trim()) {
        return new Err(
          new Error('Auth failed: the user auth token provider gave nothing')
        );
      }

      const response = await fetch(`${this._baseUrl}/auth`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_type: this._userType(userAuthToken),
          channel_id: this._config.channelId,
          organization_id: this._config.organizationId,
          timestamp: Math.floor(Date.now() / 1000),
          ...(this._config.userId && { user_id: this._config.userId }),
          ...(userAuthToken && { token: userAuthToken }),
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

  // A verified token makes the person an external user whatever else is set.
  private _userType(userAuthToken: string | null | undefined): UserType {
    if (userAuthToken) {
      return UserType.externalUser;
    }
    return this._config.userId
      ? UserType.thirdPartyAnonymous
      : UserType.anonymous;
  }
}
