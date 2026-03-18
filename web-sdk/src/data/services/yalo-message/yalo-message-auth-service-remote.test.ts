// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok } from '@domain/common/result';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { YaloMessageAuthServiceRemote } from './yalo-message-auth-service-remote';

const baseConfig = {
  channelId: 'channel-1',
  organizationId: 'org-1',
  channelName: 'Test Chat',
  target: 'chat-target',
};

const baseUrl = 'https://api.example.com';

const makeAuthResponse = (overrides: Record<string, unknown> = {}) => ({
  access_token: 'access-abc',
  token_type: 'Bearer',
  expires_in: 3600,
  refresh_token: 'refresh-xyz',
  client_id: 'client-1',
  ...overrides,
});

describe('YaloMessageAuthServiceRemote', () => {
  let service: YaloMessageAuthServiceRemote;

  beforeEach(() => {
    service = new YaloMessageAuthServiceRemote(baseUrl, baseConfig);
    vi.stubGlobal('fetch', vi.fn());
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  const mockFetchOk = (body: unknown) => {
    vi.mocked(fetch).mockResolvedValue({
      ok: true,
      json: async () => body,
    } as Response);
  };

  const mockFetchErr = (status: number) => {
    vi.mocked(fetch).mockResolvedValue({
      ok: false,
      status,
    } as Response);
  };

  describe('POST /auth — anonymous token', () => {
    it('returns Ok with the access token on success', async () => {
      mockFetchOk(makeAuthResponse());
      const result = await service.auth();
      expect(result).toBeInstanceOf(Ok);
      expect((result as Ok<string>).value).toBe('access-abc');
    });

    it('calls the /auth endpoint with POST', async () => {
      mockFetchOk(makeAuthResponse());
      await service.auth();
      const [url, init] = vi.mocked(fetch).mock.calls[0] as [
        string,
        RequestInit,
      ];
      expect(url).toBe(`${baseUrl}/auth`);
      expect(init.method).toBe('POST');
    });

    it('sends channelId and organizationId in the request body', async () => {
      mockFetchOk(makeAuthResponse());
      await service.auth();
      const [, init] = vi.mocked(fetch).mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.channel_id).toBe(baseConfig.channelId);
      expect(body.organization_id).toBe(baseConfig.organizationId);
      expect(body.user_type).toBe('anonymous');
    });

    it('returns Err when /auth responds with a non-ok status', async () => {
      mockFetchErr(401);
      const result = await service.auth();
      expect(result).toBeInstanceOf(Err);
      expect((result as Err).error.message).toContain('401');
    });

    it('returns Err when fetch throws a network error', async () => {
      vi.mocked(fetch).mockRejectedValue(new Error('Network failure'));
      const result = await service.auth();
      expect(result).toBeInstanceOf(Err);
      expect((result as Err).error.message).toBe('Network failure');
    });

    it('wraps non-Error throws in an Error', async () => {
      vi.mocked(fetch).mockRejectedValue('oops');
      const result = await service.auth();
      expect(result).toBeInstanceOf(Err);
      expect((result as Err).error).toBeInstanceOf(Error);
    });
  });

  describe('POST /oauth/token — token refresh', () => {
    it('uses the cached token without fetching again when not expired', async () => {
      mockFetchOk(makeAuthResponse({ expires_in: 3600 }));
      await service.auth();
      const result = await service.auth();
      expect(vi.mocked(fetch)).toHaveBeenCalledTimes(1);
      expect(result).toBeInstanceOf(Ok);
      expect((result as Ok<string>).value).toBe('access-abc');
    });

    it('calls /oauth/token with the refresh token when the access token is expired', async () => {
      // First call: issue a token that expires immediately (expires_in = 0)
      mockFetchOk(makeAuthResponse({ expires_in: 0 }));
      await service.auth();

      // Second call: the token is expired, expect a refresh
      mockFetchOk(makeAuthResponse({ access_token: 'access-refreshed' }));
      const result = await service.auth();

      expect(vi.mocked(fetch)).toHaveBeenCalledTimes(2);
      const [url, init] = vi.mocked(fetch).mock.calls[1] as [
        string,
        RequestInit,
      ];
      expect(url).toBe(`${baseUrl}/oauth/token`);
      expect(init.method).toBe('POST');
      expect((result as Ok<string>).value).toBe('access-refreshed');
    });

    it('sends the refresh_token in the URLSearchParams body', async () => {
      mockFetchOk(makeAuthResponse({ expires_in: 0 }));
      await service.auth();

      mockFetchOk(makeAuthResponse());
      await service.auth();

      const [, init] = vi.mocked(fetch).mock.calls[1] as [string, RequestInit];
      const params = new URLSearchParams(init.body as string);
      expect(params.get('grant_type')).toBe('refresh_token');
      expect(params.get('refresh_token')).toBe('refresh-xyz');
    });

    it('returns Err and clears the cache when /oauth/token fails', async () => {
      mockFetchOk(makeAuthResponse({ expires_in: 0 }));
      await service.auth();

      mockFetchErr(400);
      const refreshResult = await service.auth();
      expect(refreshResult).toBeInstanceOf(Err);
      expect((refreshResult as Err).error.message).toContain('400');

      // After the failed refresh the cache is cleared, the next call re-fetches
      mockFetchOk(makeAuthResponse({ access_token: 'access-new' }));
      const retryResult = await service.auth();
      expect(retryResult).toBeInstanceOf(Ok);
      expect((retryResult as Ok<string>).value).toBe('access-new');
    });

    it('returns Err when the refresh fetch throws', async () => {
      mockFetchOk(makeAuthResponse({ expires_in: 0 }));
      await service.auth();

      vi.mocked(fetch).mockRejectedValue(new Error('Refresh network error'));
      const result = await service.auth();
      expect(result).toBeInstanceOf(Err);
      expect((result as Err).error.message).toBe('Refresh network error');
    });
  });
});
