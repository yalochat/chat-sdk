// Copyright (c) Yalochat, Inc. All rights reserved.

import { Ok, type Result } from '@domain/common/result';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import type { YaloMessageAuthService } from '@data/services/yalo-message/yalo-message-auth-service';

// Refresh a little before the server-side expiry so a request never goes out
// with a token that dies in flight.
const EXPIRY_MARGIN_MS = 60_000;

interface CachedToken {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
}

// TokenRepositoryLocal persists to IndexedDB, which does not exist outside a
// browser. The CLI only needs the token for the lifetime of one process, and a
// fresh process should be a fresh anonymous visitor, so memory is enough.
export class TokenRepositoryMemory implements TokenRepository {
  private readonly _auth: YaloMessageAuthService;
  private readonly _now: () => number;
  private _token?: CachedToken;

  constructor(auth: YaloMessageAuthService, now: () => number = Date.now) {
    this._auth = auth;
    this._now = now;
  }

  async getToken(): Promise<Result<string>> {
    if (this._token && this._now() < this._token.expiresAt) {
      return new Ok(this._token.accessToken);
    }

    const result = this._token
      ? await this._auth.refreshToken(this._token.refreshToken)
      : await this._auth.fetchToken();
    if (!result.ok) {
      this._token = undefined;
      return result;
    }

    const { accessToken, refreshToken, expiresIn } = result.value;
    this._token = {
      accessToken,
      refreshToken,
      expiresAt: this._now() + expiresIn * 1000 - EXPIRY_MARGIN_MS,
    };
    return new Ok(accessToken);
  }

  async clearSession(): Promise<Result<boolean>> {
    this._token = undefined;
    return new Ok(true);
  }
}
