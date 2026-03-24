// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { YaloMessageAuthService } from '@data/services/yalo-message/yalo-message-auth-service';
import type { TokenRepository } from './token-repository';

const TOKEN_KEY = 'token';

interface StoredToken {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
}

export class TokenRepositoryLocal implements TokenRepository {
  private static readonly _STORE_NAME = 'session';

  static upgrade(db: IDBDatabase): void {
    if (!db.objectStoreNames.contains(TokenRepositoryLocal._STORE_NAME)) {
      db.createObjectStore(TokenRepositoryLocal._STORE_NAME);
    }
  }

  private readonly _db: IDBDatabase;
  private readonly _authService: YaloMessageAuthService;

  constructor(db: IDBDatabase, authService: YaloMessageAuthService) {
    this._db = db;
    this._authService = authService;
  }

  async getToken(): Promise<Result<string>> {
    const stored = await this._read();

    if (stored && Date.now() < stored.expiresAt) {
      return new Ok(stored.accessToken);
    }

    if (stored?.refreshToken) {
      const result = await this._authService.refreshToken(stored.refreshToken);
      if (result.ok) {
        await this._write(result.value);
        return new Ok(result.value.accessToken);
      }
      await this._clear();
    }

    const result = await this._authService.fetchToken();
    if (!result.ok) return new Err(result.error);

    await this._write(result.value);
    return new Ok(result.value.accessToken);
  }

  private _read(): Promise<StoredToken | null> {
    return new Promise((resolve, reject) => {
      const tx = this._db.transaction(TokenRepositoryLocal._STORE_NAME, 'readonly');
      const store = tx.objectStore(TokenRepositoryLocal._STORE_NAME);
      const request = store.get(TOKEN_KEY);
      request.onsuccess = () => resolve((request.result as StoredToken) ?? null);
      request.onerror = () => reject(request.error);
    });
  }

  private _write(data: { accessToken: string; refreshToken: string; expiresIn: number }): Promise<void> {
    return new Promise((resolve, reject) => {
      const tx = this._db.transaction(TokenRepositoryLocal._STORE_NAME, 'readwrite');
      const store = tx.objectStore(TokenRepositoryLocal._STORE_NAME);
      const record: StoredToken = {
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        expiresAt: Date.now() + data.expiresIn * 1000,
      };
      const request = store.put(record, TOKEN_KEY);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  private _clear(): Promise<void> {
    return new Promise((resolve, reject) => {
      const tx = this._db.transaction(TokenRepositoryLocal._STORE_NAME, 'readwrite');
      const store = tx.objectStore(TokenRepositoryLocal._STORE_NAME);
      const request = store.delete(TOKEN_KEY);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }
}
