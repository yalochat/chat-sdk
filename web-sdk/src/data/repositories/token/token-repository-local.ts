// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { YaloMessageAuthService } from '@data/services/yalo-message/yalo-message-auth-service';
import type { TokenRepository } from './token-repository';

interface StoredToken {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
  ephemeral?: boolean;
}

export class TokenRepositoryLocal implements TokenRepository {
  private static readonly _STORE_NAME = 'session';
  private static readonly _KEY_PREFIX = 'token:';

  static upgrade(db: IDBDatabase): void {
    if (!db.objectStoreNames.contains(TokenRepositoryLocal._STORE_NAME)) {
      db.createObjectStore(TokenRepositoryLocal._STORE_NAME);
    }
  }

  // Lists the sessions that stored an ephemeral token, so the caller can work
  // out which of them no document owns any more. Sessions of any other mode are
  // never reported: an anonymous shared session would lose its identity along
  // with its token, so its record has to survive.
  static listEphemeralSessions(db: IDBDatabase): Promise<Result<string[]>> {
    return new Promise((resolve) => {
      try {
        const sessionIds: string[] = [];
        const tx = db.transaction(TokenRepositoryLocal._STORE_NAME, 'readonly');
        const store = tx.objectStore(TokenRepositoryLocal._STORE_NAME);
        const request = store.openCursor();

        request.onsuccess = () => {
          const cursor = request.result;
          if (!cursor) {
            resolve(new Ok(sessionIds));
            return;
          }
          if ((cursor.value as StoredToken).ephemeral === true) {
            sessionIds.push(
              String(cursor.key).slice(TokenRepositoryLocal._KEY_PREFIX.length)
            );
          }
          cursor.continue();
        };

        request.onerror = () => {
          resolve(
            new Err(
              request.error ?? new Error('Unable to list ephemeral sessions')
            )
          );
        };
      } catch (e) {
        resolve(new Err(e instanceof Error ? e : new Error(String(e))));
      }
    });
  }

  // Deletes the tokens of the given sessions. Deleting a key that is already
  // gone succeeds, so callers can pass sessions the sweep may have taken.
  static clearSessions(
    db: IDBDatabase,
    sessionIds: string[]
  ): Promise<Result<boolean>> {
    return new Promise((resolve) => {
      if (sessionIds.length === 0) {
        resolve(new Ok(true));
        return;
      }
      try {
        const tx = db.transaction(TokenRepositoryLocal._STORE_NAME, 'readwrite');
        const store = tx.objectStore(TokenRepositoryLocal._STORE_NAME);
        tx.oncomplete = () => resolve(new Ok(true));
        tx.onerror = () => {
          resolve(new Err(tx.error ?? new Error('Unable to clear sessions')));
        };
        for (const sessionId of sessionIds) {
          store.delete(`${TokenRepositoryLocal._KEY_PREFIX}${sessionId}`);
        }
      } catch (e) {
        resolve(new Err(e instanceof Error ? e : new Error(String(e))));
      }
    });
  }

  private readonly _db: IDBDatabase;
  private readonly _authService: YaloMessageAuthService;
  private readonly _key: string;
  private readonly _ephemeral: boolean;

  constructor(
    db: IDBDatabase,
    sessionId: string,
    authService: YaloMessageAuthService,
    ephemeral: boolean = false
  ) {
    this._db = db;
    this._authService = authService;
    this._key = `${TokenRepositoryLocal._KEY_PREFIX}${sessionId}`;
    this._ephemeral = ephemeral;
  }

  async getToken(): Promise<Result<string>> {
    try {
      const stored = await this._read();

      if (stored && Date.now() < stored.expiresAt) {
        return new Ok(stored.accessToken);
      }

      if (stored?.refreshToken) {
        const result = await this._authService.refreshToken(
          stored.refreshToken
        );
        if (result.ok) {
          await this._write(result.value);
          return new Ok(result.value.accessToken);
        }
        await this._clear();
      }

      const result = await this._authService.fetchToken();
      if (!result.ok) {
        return new Err(result.error);
      }

      await this._write(result.value);
      return new Ok(result.value.accessToken);
    } catch (e) {
      if (e instanceof Error) {
        return new Err(e);
      }
      return new Err(new Error(String(e)));
    }
  }

  async clearSession(): Promise<Result<boolean>> {
    try {
      await this._clear();
      return new Ok(true);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  private _read(): Promise<StoredToken | null> {
    return new Promise((resolve, reject) => {
      const tx = this._db.transaction(TokenRepositoryLocal._STORE_NAME, 'readonly');
      const store = tx.objectStore(TokenRepositoryLocal._STORE_NAME);
      const request = store.get(this._key);
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
        ephemeral: this._ephemeral,
      };
      const request = store.put(record, this._key);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  private _clear(): Promise<void> {
    return new Promise((resolve, reject) => {
      const tx = this._db.transaction(TokenRepositoryLocal._STORE_NAME, 'readwrite');
      const store = tx.objectStore(TokenRepositoryLocal._STORE_NAME);
      const request = store.delete(this._key);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }
}
