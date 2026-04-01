// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { YaloMediaServiceRemote } from './yalo-media-service-remote';
import { Ok, Err } from '@domain/common/result';
import type { TokenRepository } from '@data/repositories/token/token-repository';

const makeTokenRepository = (token = 'test-token'): TokenRepository => ({
  getToken: vi.fn().mockResolvedValue(new Ok(token)),
});

const makeUploadResponse = () => ({
  id: 'yalo_63cfd924-19dc-455a-b755-c949e62fc4e7',
  signed_url: 'https://storage.googleapis.com/example/file.jpeg',
  original_name: 'photo.jpeg',
  type: 'image',
  metadata: { user_id: 'abc123' },
  created_at: '2026-03-19T15:56:21.629107809Z',
  expires_at: '2026-03-19T16:56:21.190587072Z',
});

describe('YaloMediaServiceRemote', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('uploadMedia', () => {
    it('returns Ok with MediaUploadResponse on 201', async () => {
      const responseBody = makeUploadResponse();
      vi.stubGlobal(
        'fetch',
        vi.fn().mockResolvedValue({
          status: 201,
          json: vi.fn().mockResolvedValue(responseBody),
        })
      );

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository()
      );
      const file = new File(['fake image'], 'photo.jpeg', {
        type: 'image/jpeg',
      });
      const result = await service.uploadMedia(file);

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.value.id).toBe(
          'yalo_63cfd924-19dc-455a-b755-c949e62fc4e7'
        );
        expect(result.value.signed_url).toBe(
          'https://storage.googleapis.com/example/file.jpeg'
        );
        expect(result.value.original_name).toBe('photo.jpeg');
        expect(result.value.type).toBe('image');
      }
    });

    it('POSTs to correct URL with Authorization header and FormData', async () => {
      const fetchSpy = vi.fn().mockResolvedValue({
        status: 201,
        json: vi.fn().mockResolvedValue(makeUploadResponse()),
      });
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository('my-token')
      );
      const file = new File(['data'], 'photo.jpeg', { type: 'image/jpeg' });
      await service.uploadMedia(file);

      expect(fetchSpy).toHaveBeenCalledWith(
        'https://api.example.com/all/media',
        expect.objectContaining({
          method: 'POST',
          headers: { Authorization: 'Bearer my-token' },
        })
      );

      const [, init] = fetchSpy.mock.calls[0];
      expect(init.body).toBeInstanceOf(FormData);
      expect(init.body.get('file')).toBeInstanceOf(File);
    });

    it('returns Err on non-201 status', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockResolvedValue({ status: 400 })
      );

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository()
      );
      const file = new File(['data'], 'photo.jpeg', { type: 'image/jpeg' });
      const result = await service.uploadMedia(file);

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('Failed to upload media: 400');
    });

    it('returns Err when token fetch fails', async () => {
      const tokenRepo: TokenRepository = {
        getToken: vi
          .fn()
          .mockResolvedValue(new Err(new Error('auth failed'))),
      };

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        tokenRepo
      );
      const file = new File(['data'], 'photo.jpeg', { type: 'image/jpeg' });
      const result = await service.uploadMedia(file);

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('auth failed');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository()
      );
      const file = new File(['data'], 'photo.jpeg', { type: 'image/jpeg' });
      const result = await service.uploadMedia(file);

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });

    it('wraps non-Error thrown values', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue('string error'));

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository()
      );
      const file = new File(['data'], 'photo.jpeg', { type: 'image/jpeg' });
      const result = await service.uploadMedia(file);

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('string error');
    });
  });

  describe('downloadMedia', () => {
    it('returns Ok with Blob on 200', async () => {
      const blob = new Blob(['image data'], { type: 'image/jpeg' });
      vi.stubGlobal(
        'fetch',
        vi.fn().mockResolvedValue({
          ok: true,
          blob: vi.fn().mockResolvedValue(blob),
        })
      );

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository()
      );
      const result = await service.downloadMedia(
        'https://example.com/image.jpg'
      );

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBeInstanceOf(Blob);
    });

    it('returns Err on non-200 response', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockResolvedValue({ ok: false, status: 404 })
      );

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository()
      );
      const result = await service.downloadMedia(
        'https://example.com/image.jpg'
      );

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('Failed to download media: 404');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const service = new YaloMediaServiceRemote(
        'https://api.example.com',
        makeTokenRepository()
      );
      const result = await service.downloadMedia(
        'https://example.com/image.jpg'
      );

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });
  });
});
