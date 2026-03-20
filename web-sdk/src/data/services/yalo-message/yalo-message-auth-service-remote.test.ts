// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { YaloMessageAuthServiceRemote } from './yalo-message-auth-service-remote';

const baseConfig = {
  channelId: 'channel-1',
  organizationId: 'org-1',
  channelName: 'Test Chat',
  target: 'chat-target',
};

const makeAuthResponse = (overrides: Record<string, unknown> = {}) => ({
  accessToken: 'access-token',
  tokenType: 'Bearer',
  expiresIn: 3600,
  refreshToken: 'refresh-token',
  clientId: 'client-1',
  ...overrides,
});

const mockFetch = (response: unknown, ok = true, status = 200) =>
  vi.fn().mockResolvedValue({
    ok,
    status,
    json: vi.fn().mockResolvedValue(response),
  });

describe('YaloMessageAuthServiceRemote', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  describe('auth', () => {
    it('fetches a token when no cache exists', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.auth();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('access-token');
      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy).toHaveBeenCalledWith(
        'https://api.example.com/auth',
        expect.objectContaining({ method: 'POST' })
      );
    });

    it('sends correct body fields on initial auth', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      vi.setSystemTime(new Date('2026-01-01T00:00:00Z'));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.auth();

      const [, init] = fetchSpy.mock.calls[0];
      const body = JSON.parse(init.body);
      expect(body.user_type).toBe('anonymous');
      expect(body.channel_id).toBe('channel-1');
      expect(body.organization_id).toBe('org-1');
      expect(body.timestamp).toBe(Math.floor(new Date('2026-01-01T00:00:00Z').getTime() / 1000));
    });

    it('returns cached access token when token is still valid', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.auth();

      const result = await service.auth();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('access-token');
      expect(fetchSpy).toHaveBeenCalledOnce();
    });

    it('uses refresh token when access token is expired', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.auth();

      // Advance past expiresIn (3600 seconds)
      vi.advanceTimersByTime(3601 * 1000);

      const refreshResponse = makeAuthResponse({ accessToken: 'new-access-token' });
      fetchSpy.mockResolvedValue({
        ok: true,
        status: 200,
        json: vi.fn().mockResolvedValue(refreshResponse),
      });

      const result = await service.auth();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe('new-access-token');
      expect(fetchSpy).toHaveBeenCalledTimes(2);
      expect(fetchSpy.mock.calls[1][0]).toBe('https://api.example.com/oauth/token');
    });

    it('sends refresh_token grant type when refreshing', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.auth();
      vi.advanceTimersByTime(3601 * 1000);

      fetchSpy.mockResolvedValue({
        ok: true,
        status: 200,
        json: vi.fn().mockResolvedValue(makeAuthResponse()),
      });

      await service.auth();

      const [, init] = fetchSpy.mock.calls[1];
      const body = new URLSearchParams(init.body);
      expect(body.get('grant_type')).toBe('refresh_token');
      expect(body.get('refresh_token')).toBe('refresh-token');
      expect(init.headers['Content-Type']).toBe('application/x-www-form-urlencoded');
    });

    it('returns Err when initial auth request fails', async () => {
      vi.stubGlobal('fetch', mockFetch({}, false, 401));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.auth();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Auth failed: 401');
    });

    it('returns Err when refresh request fails and clears cache', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.auth();
      vi.advanceTimersByTime(3601 * 1000);

      fetchSpy.mockResolvedValue({ ok: false, status: 403, json: vi.fn() });

      const result = await service.auth();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Refresh failed: 403');

      // After cache is cleared, next call should hit /auth again
      fetchSpy.mockResolvedValue({
        ok: true,
        status: 200,
        json: vi.fn().mockResolvedValue(makeAuthResponse({ accessToken: 'fresh-token' })),
      });

      const retryResult = await service.auth();
      expect(retryResult.ok).toBe(true);
      if (retryResult.ok) expect(retryResult.value).toBe('fresh-token');
      expect(fetchSpy.mock.calls[2][0]).toBe('https://api.example.com/auth');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Network error')));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.auth();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });

    it('wraps non-Error thrown values in an Error', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue('string error'));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.auth();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('string error');
    });

    it('updates the cache with new token data after refresh', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.auth();
      vi.advanceTimersByTime(3601 * 1000);

      const newResponse = makeAuthResponse({
        accessToken: 'refreshed-token',
        refreshToken: 'new-refresh-token',
        expiresIn: 7200,
      });
      fetchSpy.mockResolvedValue({
        ok: true,
        status: 200,
        json: vi.fn().mockResolvedValue(newResponse),
      });

      await service.auth();

      // Should use cached refreshed token without another fetch
      const cachedResult = await service.auth();
      expect(cachedResult.ok).toBe(true);
      if (cachedResult.ok) expect(cachedResult.value).toBe('refreshed-token');
      expect(fetchSpy).toHaveBeenCalledTimes(2);
    });
  });
});
