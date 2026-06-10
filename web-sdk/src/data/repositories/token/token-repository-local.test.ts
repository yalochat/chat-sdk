// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Ok, Err } from '@domain/common/result';
import type { YaloMessageAuthService } from '@data/services/yalo-message/yalo-message-auth-service';
import { TokenRepositoryLocal } from './token-repository-local';

const DB_NAME = 'YaloChatMessages';
const DB_VERSION = 1;
const SESSION_ID = 'org-1-channel-1-user-1';

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION);
    request.onupgradeneeded = (event) => {
      TokenRepositoryLocal.upgrade((event.target as IDBOpenDBRequest).result);
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

function deleteDb(): Promise<void> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.deleteDatabase(DB_NAME);
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
}

const makeAuthResponse = (overrides: Partial<{
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}> = {}) => ({
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresIn: 3600,
  tokenType: 'Bearer',
  clientId: 'client-1',
  ...overrides,
});

const makeAuthService = (overrides: Partial<YaloMessageAuthService> = {}): YaloMessageAuthService => ({
  fetchToken: vi.fn().mockResolvedValue(new Ok(makeAuthResponse())),
  refreshToken: vi.fn().mockResolvedValue(new Ok(makeAuthResponse())),
  ...overrides,
});

describe('TokenRepositoryLocal', () => {
  let db: IDBDatabase;

  beforeEach(async () => {
    vi.useFakeTimers();
    db = await openDb();
  });

  afterEach(async () => {
    vi.restoreAllMocks();
    vi.useRealTimers();
    db.close();
    await deleteDb();
  });

  describe('getToken', () => {
    it('fetches a token when store is empty', async () => {
      const authService = makeAuthService();
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);

      const result = await repo.getToken();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('access-token');
      expect(authService.fetchToken).toHaveBeenCalledOnce();
    });

    it('returns cached token when still valid', async () => {
      const authService = makeAuthService();
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);

      await repo.getToken();
      const result = await repo.getToken();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('access-token');
      expect(authService.fetchToken).toHaveBeenCalledOnce();
    });

    it('persists token to IndexedDB', async () => {
      const repo = new TokenRepositoryLocal(db, SESSION_ID, makeAuthService());

      await repo.getToken();

      // A second repo instance with a fresh auth service reads the cached token
      const freshAuthService = makeAuthService();
      const repo2 = new TokenRepositoryLocal(db, SESSION_ID, freshAuthService);
      const result = await repo2.getToken();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('access-token');
      expect(freshAuthService.fetchToken).not.toHaveBeenCalled();
    });

    it('uses refresh token when access token is expired', async () => {
      const authService = makeAuthService({
        refreshToken: vi.fn().mockResolvedValue(
          new Ok(makeAuthResponse({ accessToken: 'refreshed-token' }))
        ),
      });
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);

      await repo.getToken();
      vi.advanceTimersByTime(3601 * 1000);

      const result = await repo.getToken();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('refreshed-token');
      expect(authService.fetchToken).toHaveBeenCalledOnce();
      expect(authService.refreshToken).toHaveBeenCalledOnce();
    });

    it('updates IndexedDB after refresh', async () => {
      const authService = makeAuthService({
        refreshToken: vi.fn().mockResolvedValue(
          new Ok(makeAuthResponse({ accessToken: 'refreshed-token', refreshToken: 'new-refresh' }))
        ),
      });
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);

      await repo.getToken();
      vi.advanceTimersByTime(3601 * 1000);
      await repo.getToken();

      // Verify updated token is persisted by reading with a new instance
      const freshAuthService = makeAuthService();
      const result = await new TokenRepositoryLocal(db, SESSION_ID, freshAuthService).getToken();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('refreshed-token');
      expect(freshAuthService.fetchToken).not.toHaveBeenCalled();
    });

    it('falls back to fetchToken when refresh fails', async () => {
      const authService = makeAuthService({
        refreshToken: vi.fn().mockResolvedValue(new Err(new Error('Refresh failed: 403'))),
        fetchToken: vi.fn().mockResolvedValue(new Ok(makeAuthResponse({ accessToken: 'fresh-token' }))),
      });
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);

      await repo.getToken();
      vi.advanceTimersByTime(3601 * 1000);

      const result = await repo.getToken();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('fresh-token');
      expect(authService.refreshToken).toHaveBeenCalledOnce();
      expect(authService.fetchToken).toHaveBeenCalledTimes(2);
    });

    it('clears stored token when refresh fails', async () => {
      const authService = makeAuthService({
        refreshToken: vi.fn().mockResolvedValue(new Err(new Error('Refresh failed: 403'))),
      });
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);

      await repo.getToken();
      vi.advanceTimersByTime(3601 * 1000);
      await repo.getToken();

      expect(authService.fetchToken).toHaveBeenCalledTimes(2);
    });

    it('returns Err when fetchToken fails', async () => {
      const authService = makeAuthService({
        fetchToken: vi
          .fn()
          .mockResolvedValue(new Err(new Error('Auth failed: 401'))),
      });
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);

      const result = await repo.getToken();

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.message).toBe('Auth failed: 401');
      }
    });

    it('returns Err when the underlying IndexedDB connection is closed', async () => {
      const authService = makeAuthService();
      const repo = new TokenRepositoryLocal(db, SESSION_ID, authService);
      db.close();

      const result = await repo.getToken();

      expect(result).toMatchObject({ ok: false });
    });
  });

  describe('session isolation', () => {
    it('does not share tokens across sessions', async () => {
      const mineAuth = makeAuthService({
        fetchToken: vi
          .fn()
          .mockResolvedValue(new Ok(makeAuthResponse({ accessToken: 'mine' }))),
      });
      const theirsAuth = makeAuthService({
        fetchToken: vi
          .fn()
          .mockResolvedValue(new Ok(makeAuthResponse({ accessToken: 'theirs' }))),
      });
      const mine = new TokenRepositoryLocal(db, SESSION_ID, mineAuth);
      const theirs = new TokenRepositoryLocal(db, 'other-session', theirsAuth);

      const mineResult = await mine.getToken();
      const theirsResult = await theirs.getToken();

      expect(mineResult).toMatchObject({ ok: true, value: 'mine' });
      expect(theirsResult).toMatchObject({ ok: true, value: 'theirs' });
      expect(mineAuth.fetchToken).toHaveBeenCalledOnce();
      expect(theirsAuth.fetchToken).toHaveBeenCalledOnce();
    });

    it('clearSession returns Err when the database is closed', async () => {
      const repo = new TokenRepositoryLocal(db, SESSION_ID, makeAuthService());
      db.close();
      const result = await repo.clearSession();
      expect(result).toMatchObject({ ok: false });
    });

    it('clearSession only removes the configured session token', async () => {
      const mine = new TokenRepositoryLocal(db, SESSION_ID, makeAuthService());
      const theirsAuth = makeAuthService();
      const theirs = new TokenRepositoryLocal(db, 'other-session', theirsAuth);
      await mine.getToken();
      await theirs.getToken();

      await mine.clearSession();

      const freshTheirsAuth = makeAuthService();
      const freshTheirs = new TokenRepositoryLocal(
        db,
        'other-session',
        freshTheirsAuth
      );
      await freshTheirs.getToken();

      expect(freshTheirsAuth.fetchToken).not.toHaveBeenCalled();
    });
  });
});
