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

  describe('fetchToken', () => {
    it('returns Ok with the auth response', async () => {
      vi.stubGlobal('fetch', mockFetch(makeAuthResponse()));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.fetchToken();

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value.accessToken).toBe('access-token');
    });

    it('posts to /auth endpoint', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.fetchToken();

      expect(fetchSpy).toHaveBeenCalledWith(
        'https://api.example.com/auth',
        expect.objectContaining({ method: 'POST' })
      );
    });

    it('sends correct body fields', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);
      vi.setSystemTime(new Date('2026-01-01T00:00:00Z'));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.fetchToken();

      const [, init] = fetchSpy.mock.calls[0];
      const body = JSON.parse(init.body);
      expect(body.user_type).toBe('anonymous');
      expect(body.channel_id).toBe('channel-1');
      expect(body.organization_id).toBe('org-1');
      expect(body.timestamp).toBe(Math.floor(new Date('2026-01-01T00:00:00Z').getTime() / 1000));
    });

    it('returns Err when request fails', async () => {
      vi.stubGlobal('fetch', mockFetch({}, false, 401));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.fetchToken();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Auth failed: 401');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Network error')));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.fetchToken();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });

    it('sends third_party_anonymous user type and user_id when userId is set', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const config = { ...baseConfig, userId: 'custom-user-123' };
      const service = new YaloMessageAuthServiceRemote('https://api.example.com', config);
      await service.fetchToken();

      const [, init] = fetchSpy.mock.calls[0];
      const body = JSON.parse(init.body);
      expect(body).toMatchObject({
        user_type: 'third_party_anonymous',
        user_id: 'custom-user-123',
      });
    });

    it('does not include user_id when userId is not set', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.fetchToken();

      const [, init] = fetchSpy.mock.calls[0];
      const body = JSON.parse(init.body);
      expect(body.user_type).toBe('anonymous');
      expect(body).not.toHaveProperty('user_id');
    });

    it('wraps non-Error thrown values in an Error', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue('string error'));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.fetchToken();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('string error');
    });
  });

  describe('refreshToken', () => {
    it('returns Ok with the auth response', async () => {
      vi.stubGlobal('fetch', mockFetch(makeAuthResponse({ accessToken: 'new-token' })));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.refreshToken('my-refresh-token');

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value.accessToken).toBe('new-token');
    });

    it('posts to /oauth/token with refresh_token grant', async () => {
      const fetchSpy = mockFetch(makeAuthResponse());
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      await service.refreshToken('my-refresh-token');

      const [url, init] = fetchSpy.mock.calls[0];
      expect(url).toBe('https://api.example.com/oauth/token');
      const body = new URLSearchParams(init.body);
      expect(body.get('grant_type')).toBe('refresh_token');
      expect(body.get('refresh_token')).toBe('my-refresh-token');
      expect(init.headers['Content-Type']).toBe('application/x-www-form-urlencoded');
    });

    it('returns Err when request fails', async () => {
      vi.stubGlobal('fetch', mockFetch({}, false, 403));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.refreshToken('my-refresh-token');

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Refresh failed: 403');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Network error')));

      const service = new YaloMessageAuthServiceRemote('https://api.example.com', baseConfig);
      const result = await service.refreshToken('my-refresh-token');

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });
  });
});
