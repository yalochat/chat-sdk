// Copyright (c) Yalochat, Inc. All rights reserved.

import { describe, expect, it, vi } from 'vitest';
import { Err, Ok } from '@domain/common/result';
import type { YaloMessageAuthService } from '@data/services/yalo-message/yalo-message-auth-service';
import { TokenRepositoryMemory } from './token-repository-memory';

function authResponse(accessToken: string, expiresIn = 3600) {
  return new Ok({
    accessToken,
    refreshToken: `refresh-${accessToken}`,
    expiresIn,
    tokenType: 'Bearer',
    clientId: 'client',
  });
}

function mockAuth() {
  return {
    fetchToken: vi.fn<YaloMessageAuthService['fetchToken']>(),
    refreshToken: vi.fn<YaloMessageAuthService['refreshToken']>(),
  };
}

describe('TokenRepositoryMemory', () => {
  it('fetches a token once and caches it', async () => {
    const auth = mockAuth();
    auth.fetchToken.mockResolvedValue(authResponse('a1'));
    const repo = new TokenRepositoryMemory(auth, () => 0);

    expect(await repo.getToken()).toEqual(new Ok('a1'));
    expect(await repo.getToken()).toEqual(new Ok('a1'));
    expect(auth.fetchToken).toHaveBeenCalledTimes(1);
  });

  it('refreshes with the refresh token once close to expiry', async () => {
    const auth = mockAuth();
    auth.fetchToken.mockResolvedValue(authResponse('a1', 3600));
    auth.refreshToken.mockResolvedValue(authResponse('a2'));
    let now = 0;
    const repo = new TokenRepositoryMemory(auth, () => now);

    await repo.getToken();
    now = 3600 * 1000 - 30_000; // inside the 60s safety margin
    expect(await repo.getToken()).toEqual(new Ok('a2'));
    expect(auth.refreshToken).toHaveBeenCalledWith('refresh-a1');
  });

  it('propagates auth errors and does not cache them', async () => {
    const auth = mockAuth();
    const failure = new Err(new Error('Auth failed: 401'));
    auth.fetchToken
      .mockResolvedValueOnce(failure)
      .mockResolvedValueOnce(authResponse('a1'));
    const repo = new TokenRepositoryMemory(auth, () => 0);

    expect(await repo.getToken()).toBe(failure);
    expect(await repo.getToken()).toEqual(new Ok('a1'));
  });

  it('clearSession forces a fresh anonymous token', async () => {
    const auth = mockAuth();
    auth.fetchToken
      .mockResolvedValueOnce(authResponse('a1'))
      .mockResolvedValueOnce(authResponse('b1'));
    const repo = new TokenRepositoryMemory(auth, () => 0);

    await repo.getToken();
    await repo.clearSession();
    expect(await repo.getToken()).toEqual(new Ok('b1'));
    expect(auth.refreshToken).not.toHaveBeenCalled();
  });
});
