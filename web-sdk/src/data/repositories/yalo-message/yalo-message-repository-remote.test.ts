// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Err, Ok } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import { YaloMessageRepositoryRemote } from './yalo-message-repository-remote';
import type { YaloMediaService } from '@data/services/yalo-media/yalo-media-service';

// Flush the microtask queue (promise chain) for the initial poll() call
// without triggering the 2000ms setTimeout that reschedules the next poll.
// Fake timers only mock setTimeout/setInterval — native Promise resolution
// still runs through the real microtask queue.
const flushPoll = async () => {
  for (let i = 0; i < 20; i++) {
    await Promise.resolve();
  }
};

const setTabHidden = (hidden: boolean) => {
  Object.defineProperty(document, 'hidden', {
    configurable: true,
    value: hidden,
  });
  Object.defineProperty(document, 'visibilityState', {
    configurable: true,
    value: hidden ? 'hidden' : 'visible',
  });
  document.dispatchEvent(new Event('visibilitychange'));
};

const makeToken = (userId: string) => {
  const payload = btoa(JSON.stringify({ user_id: userId }))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
  return `header.${payload}.signature`;
};

const mockTokenRepository = (token: string): TokenRepository => ({
  getToken: vi.fn().mockResolvedValue(new Ok(token)),
});

const failingTokenRepository = (): TokenRepository => ({
  getToken: vi.fn().mockResolvedValue(new Err(new Error('auth failed'))),
});

const mockMediaService = (): YaloMediaService => ({
  uploadMedia: vi.fn().mockResolvedValue(new Ok({})),
  downloadMedia: vi.fn().mockResolvedValue(new Ok({})),
});

const baseConfig = {
  channelId: 'channel-1',
  organizationId: 'org-1',
  channelName: 'Test Chat',
  target: 'chat-target',
};

const makeMessage = (
  overrides: Partial<ConstructorParameters<typeof ChatMessage>[0]> = {}
) =>
  new ChatMessage({
    id: 1,
    role: 'USER',
    content: 'hello',
    type: 'text',
    status: 'IN_PROGRESS',
    timestamp: new Date('2026-01-01T00:00:00Z'),
    ...overrides,
  });

const makePollItem = (id: string, text: string, date?: Date) => ({
  id,
  message: {
    correlationId: '',
    timestamp: new Date(),
    textMessageRequest: {
      timestamp: new Date(),
      content: {
        text,
        timestamp: undefined,
        status: 1,
        role: 2,
      },
    },
  },
  date,
  userId: 'user-1',
  status: 0,
});

const makeVideoPollItem = (
  id: string,
  opts: {
    mediaUrl?: string;
    mediaType?: string;
    byteCount?: number;
    fileName?: string;
    duration?: number;
    text?: string;
    date?: Date;
  } = {}
) => ({
  id,
  message: {
    correlationId: '',
    timestamp: new Date(),
    videoMessageRequest: {
      timestamp: new Date(),
      content: {
        mediaUrl: opts.mediaUrl ?? 'https://example.com/video.mp4',
        mediaType: opts.mediaType ?? 'video/mp4',
        byteCount: opts.byteCount ?? 1024,
        fileName: opts.fileName ?? 'video.mp4',
        duration: opts.duration ?? 30,
        text: opts.text,
        timestamp: undefined,
        status: 1,
        role: 2,
      },
    },
  },
  date: opts.date,
  userId: 'user-1',
  status: 0,
});

const makeButtonsPollItem = (
  id: string,
  opts: {
    header?: string;
    body?: string;
    footer?: string;
    buttons?: string[];
    date?: Date;
  } = {}
) => ({
  id,
  message: {
    correlationId: '',
    timestamp: new Date(),
    buttonsMessageRequest: {
      timestamp: new Date(),
      content: {
        header: opts.header ?? '',
        body: opts.body ?? 'Pick one',
        footer: opts.footer ?? '',
        buttons: opts.buttons ?? ['Option A', 'Option B'],
      },
    },
  },
  date: opts.date,
  userId: 'user-1',
  status: 0,
});

const makeCTAPollItem = (
  id: string,
  opts: {
    header?: string;
    body?: string;
    footer?: string;
    buttons?: { text: string; url: string }[];
    date?: Date;
  } = {}
) => ({
  id,
  message: {
    correlationId: '',
    timestamp: new Date(),
    ctaMessageRequest: {
      timestamp: new Date(),
      content: {
        header: opts.header ?? '',
        body: opts.body ?? 'Check these links',
        footer: opts.footer ?? '',
        buttons: opts.buttons ?? [
          { text: 'Visit', url: 'https://example.com' },
        ],
      },
    },
  },
  date: opts.date,
  userId: 'user-1',
  status: 0,
});

type ProductInput = {
  sku?: string;
  name?: string;
  price?: number;
  imagesUrl?: string[];
  salePrice?: number;
  subunits?: number;
  unitStep?: number;
  unitName?: string;
  subunitName?: string;
  subunitStep?: number;
  unitsAdded?: number;
  subunitsAdded?: number;
};

const makeProtoProduct = (overrides: ProductInput = {}) => ({
  sku: overrides.sku ?? 'SKU-1',
  name: overrides.name ?? 'Widget',
  price: overrides.price ?? 9.99,
  imagesUrl: overrides.imagesUrl ?? ['https://cdn.example.com/widget.png'],
  salePrice: overrides.salePrice,
  subunits: overrides.subunits ?? 1,
  unitStep: overrides.unitStep ?? 1,
  unitName: overrides.unitName ?? '{amount, plural, one {box} other {boxes}}',
  subunitName: overrides.subunitName,
  subunitStep: overrides.subunitStep ?? 1,
  unitsAdded: overrides.unitsAdded ?? 0,
  subunitsAdded: overrides.subunitsAdded ?? 0,
});

const makeProductPollItem = (
  id: string,
  opts: {
    products?: ProductInput[];
    orientation?: 'ORIENTATION_VERTICAL' | 'ORIENTATION_HORIZONTAL';
    date?: Date;
  } = {}
) => ({
  id,
  message: {
    correlationId: '',
    timestamp: new Date(),
    productMessageRequest: {
      timestamp: new Date(),
      products: (opts.products ?? [{}]).map(makeProtoProduct),
      orientation: opts.orientation ?? 'ORIENTATION_VERTICAL',
    },
  },
  date: opts.date,
  userId: 'user-1',
  status: 0,
});

const mockOkFetch = (body: unknown = {}, status = 200) =>
  vi.fn().mockResolvedValue({
    ok: true,
    status,
    json: vi.fn().mockResolvedValue(body),
  });

const mockErrFetch = (status = 500) =>
  vi.fn().mockResolvedValue({ ok: false, status, json: vi.fn() });

describe('YaloMessageRepositoryRemote', () => {
  const token = makeToken('user-42');

  let addEventListenerSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    vi.useFakeTimers();
    addEventListenerSpy = vi.spyOn(document, 'addEventListener');
  });

  afterEach(() => {
    for (const [type, listener] of addEventListenerSpy.mock.calls) {
      if (type === 'visibilitychange') {
        document.removeEventListener('visibilitychange', listener as EventListener);
      }
    }
    setTabHidden(false);
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  describe('insertMessage', () => {
    it('returns auth Err when auth fails', async () => {
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        failingTokenRepository(),
        mockMediaService()
      );
      const result = await repo.insertMessage(makeMessage());

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('auth failed');
    });

    it('posts to /webchat/inbound_messages', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.insertMessage(makeMessage());

      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy.mock.calls[0][0]).toBe(
        'https://api.example.com/webchat/inbound_messages'
      );
      expect(fetchSpy.mock.calls[0][1].method).toBe('POST');
    });

    it('sends correct auth and channel headers', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.insertMessage(makeMessage());

      const { headers } = fetchSpy.mock.calls[0][1];
      expect(headers.authorization).toBe(`Bearer ${token}`);
      expect(headers['x-channel-id']).toBe('channel-1');
      expect(headers['x-user-id']).toBe('user-42');
    });

    it('includes message content in request body', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const msg = makeMessage({ id: 7, content: 'test content' });
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.insertMessage(msg);

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.correlationId).toBe('7');
      expect(body.textMessageRequest.content.text).toBe('test content');
    });

    it('returns Ok with the original message on success', async () => {
      vi.stubGlobal('fetch', mockOkFetch());

      const msg = makeMessage();
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.insertMessage(msg);

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe(msg);
    });

    it('returns Err on non-ok HTTP response', async () => {
      vi.stubGlobal('fetch', mockErrFetch(422));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.insertMessage(makeMessage());

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('insertMessage failed: 422');
    });

    it('returns Err when fetch throws an Error', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.insertMessage(makeMessage());

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });

    it('wraps non-Error thrown values', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue('oops'));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.insertMessage(makeMessage());

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('oops');
    });

    it('includes videoMessageRequest in body for video messages', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const msg = makeMessage({
        type: 'video',
        fileName: 'clip.mp4',
        mediaType: 'video/mp4',
        byteCount: 2048,
        duration: 15,
        content: 'my caption',
      });
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.insertMessage(msg);

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.videoMessageRequest).toBeDefined();
      expect(body.videoMessageRequest.content.mediaUrl).toBe('clip.mp4');
      expect(body.videoMessageRequest.content.mediaType).toBe('video/mp4');
      expect(body.videoMessageRequest.content.byteCount).toBe(2048);
      expect(body.videoMessageRequest.content.fileName).toBe('clip.mp4');
      expect(body.videoMessageRequest.content.duration).toBe(15);
      expect(body.videoMessageRequest.content.text).toBe('my caption');
      expect(body.textMessageRequest).toBeUndefined();
    });

    it('uploads media before sending video when blob is present', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const mediaService: YaloMediaService = {
        uploadMedia: vi.fn().mockResolvedValue(new Ok({ id: 'media-123' })),
        downloadMedia: vi.fn().mockResolvedValue(new Ok({})),
      };
      const msg = makeMessage({
        type: 'video',
        fileName: 'clip.mp4',
        mediaType: 'video/mp4',
        byteCount: 2048,
        duration: 15,
        blob: new Blob(['fake-video-data'], { type: 'video/mp4' }),
      });
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mediaService
      );
      await repo.insertMessage(msg);

      expect(mediaService.uploadMedia).toHaveBeenCalledOnce();
      const uploadedFile = (mediaService.uploadMedia as ReturnType<typeof vi.fn>)
        .mock.calls[0][0] as File;
      expect(uploadedFile.name).toBe('clip.mp4');
      expect(uploadedFile.type).toBe('video/mp4');

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.videoMessageRequest.content.mediaUrl).toBe('media-123');
    });
  });

  describe('addToCart', () => {
    it('returns auth Err when auth fails', async () => {
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        failingTokenRepository(),
        mockMediaService()
      );
      const result = await repo.addToCart('SKU-1', 3);

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('auth failed');
    });

    it('posts to /webchat/inbound_messages with addToCartRequest', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.addToCart('SKU-1', 5);

      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy.mock.calls[0][0]).toBe(
        'https://api.example.com/webchat/inbound_messages'
      );

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.addToCartRequest).toMatchObject({
        sku: 'SKU-1',
        quantity: 5,
      });
    });

    it('sends correct auth and channel headers', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.addToCart('SKU-1', 1);

      const { headers } = fetchSpy.mock.calls[0][1];
      expect(headers).toMatchObject({
        authorization: `Bearer ${token}`,
        'x-channel-id': 'channel-1',
        'x-user-id': 'user-42',
      });
    });

    it('returns Ok on success', async () => {
      vi.stubGlobal('fetch', mockOkFetch());

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.addToCart('SKU-1', 2);

      expect(result.ok).toBe(true);
    });

    it('returns Err on non-ok HTTP response', async () => {
      vi.stubGlobal('fetch', mockErrFetch(422));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.addToCart('SKU-1', 1);

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('addToCart failed: 422');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.addToCart('SKU-1', 1);

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });
  });

  describe('removeFromCart', () => {
    it('returns auth Err when auth fails', async () => {
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        failingTokenRepository(),
        mockMediaService()
      );
      const result = await repo.removeFromCart('SKU-1');

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('auth failed');
    });

    it('posts removeFromCartRequest with quantity', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.removeFromCart('SKU-1', 2);

      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy.mock.calls[0][0]).toBe(
        'https://api.example.com/webchat/inbound_messages'
      );

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.removeFromCartRequest).toMatchObject({
        sku: 'SKU-1',
        quantity: 2,
      });
    });

    it('posts removeFromCartRequest without quantity to remove entire SKU', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.removeFromCart('SKU-1');

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.removeFromCartRequest.sku).toBe('SKU-1');
      expect(body.removeFromCartRequest.quantity).toBeUndefined();
    });

    it('sends correct auth and channel headers', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.removeFromCart('SKU-1');

      const { headers } = fetchSpy.mock.calls[0][1];
      expect(headers).toMatchObject({
        authorization: `Bearer ${token}`,
        'x-channel-id': 'channel-1',
        'x-user-id': 'user-42',
      });
    });

    it('returns Ok on success', async () => {
      vi.stubGlobal('fetch', mockOkFetch());

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.removeFromCart('SKU-1');

      expect(result.ok).toBe(true);
    });

    it('returns Err on non-ok HTTP response', async () => {
      vi.stubGlobal('fetch', mockErrFetch(422));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.removeFromCart('SKU-1');

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('removeFromCart failed: 422');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.removeFromCart('SKU-1');

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });
  });

  describe('clearCart', () => {
    it('returns auth Err when auth fails', async () => {
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        failingTokenRepository(),
        mockMediaService()
      );
      const result = await repo.clearCart();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('auth failed');
    });

    it('posts clearCartRequest to /webchat/inbound_messages', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.clearCart();

      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy.mock.calls[0][0]).toBe(
        'https://api.example.com/webchat/inbound_messages'
      );

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.clearCartRequest).toBeDefined();
      expect(body.clearCartRequest.timestamp).toBeDefined();
    });

    it('sends correct auth and channel headers', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.clearCart();

      const { headers } = fetchSpy.mock.calls[0][1];
      expect(headers).toMatchObject({
        authorization: `Bearer ${token}`,
        'x-channel-id': 'channel-1',
        'x-user-id': 'user-42',
      });
    });

    it('returns Ok on success', async () => {
      vi.stubGlobal('fetch', mockOkFetch());

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.clearCart();

      expect(result.ok).toBe(true);
    });

    it('returns Err on non-ok HTTP response', async () => {
      vi.stubGlobal('fetch', mockErrFetch(500));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.clearCart();

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('clearCart failed: 500');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.clearCart();

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });
  });

  describe('addPromotion', () => {
    it('returns auth Err when auth fails', async () => {
      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        failingTokenRepository(),
        mockMediaService()
      );
      const result = await repo.addPromotion('PROMO-1');

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('auth failed');
    });

    it('posts addPromotionRequest with promotionId', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.addPromotion('PROMO-1');

      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy.mock.calls[0][0]).toBe(
        'https://api.example.com/webchat/inbound_messages'
      );

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body.addPromotionRequest).toMatchObject({
        promotionId: 'PROMO-1',
      });
    });

    it('sends correct auth and channel headers', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      await repo.addPromotion('PROMO-1');

      const { headers } = fetchSpy.mock.calls[0][1];
      expect(headers).toMatchObject({
        authorization: `Bearer ${token}`,
        'x-channel-id': 'channel-1',
        'x-user-id': 'user-42',
      });
    });

    it('returns Ok on success', async () => {
      vi.stubGlobal('fetch', mockOkFetch());

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.addPromotion('PROMO-1');

      expect(result.ok).toBe(true);
    });

    it('returns Err on non-ok HTTP response', async () => {
      vi.stubGlobal('fetch', mockErrFetch(400));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.addPromotion('PROMO-1');

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('addPromotion failed: 400');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const result = await repo.addPromotion('PROMO-1');

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });
  });

  describe('subscribeToMessages', () => {
    it('does nothing when auth fails', async () => {
      const fetchSpy = vi.fn();
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        failingTokenRepository(),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(fetchSpy).not.toHaveBeenCalled();
      expect(callback).not.toHaveBeenCalled();
    });

    it('fetches /webchat/messages with correct headers', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());

      await flushPoll();

      const [url, init] = fetchSpy.mock.calls[0];
      expect(url).toMatch(/^https:\/\/api\.example\.com\/webchat\/messages\?/);
      expect(init.headers.authorization).toBe(`Bearer ${token}`);
      expect(init.headers['x-channel-id']).toBe('channel-1');
      expect(init.headers['x-user-id']).toBe('user-42');
    });

    it('calls callback with new messages', async () => {
      const items = [makePollItem('msg-1', 'Hi there')];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      const [messages] = callback.mock.calls[0];
      expect(messages).toHaveLength(1);
      expect(messages[0]).toBeInstanceOf(ChatMessage);
      expect(messages[0].content).toBe('Hi there');
      expect(messages[0].role).toBe('AGENT');
      expect(messages[0].wiId).toBe('msg-1');
    });

    it('does not call callback when there are no new messages', async () => {
      vi.stubGlobal('fetch', mockOkFetch([]));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).not.toHaveBeenCalled();
    });

    it('deduplicates messages across polls', async () => {
      const items = [makePollItem('msg-1', 'Hi')];
      const fetchSpy = mockOkFetch(items);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      // First poll
      await flushPoll();
      expect(callback).toHaveBeenCalledOnce();

      // Second poll — same item; advanceTimersByTimeAsync runs the timer AND awaits the async callback
      await vi.advanceTimersByTimeAsync(2000);
      expect(callback).toHaveBeenCalledOnce(); // still only once
    });

    it('filters out items without textMessageRequest', async () => {
      const items = [
        {
          id: 'msg-no-text',
          message: { correlationId: '', timestamp: new Date() },
          date: undefined,
          userId: '',
          status: 0,
        },
        makePollItem('msg-with-text', 'Hello'),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      expect(callback.mock.calls[0][0]).toHaveLength(1);
      expect(callback.mock.calls[0][0][0].wiId).toBe('msg-with-text');
    });

    it('uses the item date when available', async () => {
      const date = new Date('2026-06-01T12:00:00Z');
      const items = [makePollItem('msg-1', 'Hi', date)];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback.mock.calls[0][0][0].timestamp).toEqual(date);
    });

    it('swallows network errors and schedules next poll', async () => {
      const fetchSpy = vi.fn().mockRejectedValue(new Error('Network error'));
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();

      // Should not throw
      expect(() => repo.subscribeToMessages(callback)).not.toThrow();
      await flushPoll();

      // Advance to the next poll — fetch should be called again with success
      const successItems = [makePollItem('msg-1', 'recovered')];
      fetchSpy.mockResolvedValue({
        ok: true,
        status: 200,
        json: vi.fn().mockResolvedValue(successItems),
      });

      await vi.advanceTimersByTimeAsync(2000);

      expect(callback).toHaveBeenCalledOnce();
    });

    it('silently skips non-ok poll responses', async () => {
      vi.stubGlobal('fetch', mockErrFetch(503));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).not.toHaveBeenCalled();
    });

    it('uses Date.now() - 5000 for since on the first poll', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);
      vi.setSystemTime(new Date('2026-06-01T00:00:00Z'));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());

      await flushPoll();

      const url = new URL(fetchSpy.mock.calls[0][0] as string);
      expect(url.searchParams.get('since')).toBe(String(Date.now() - 5000));
    });

    it('uses the last received message timestamp for since on subsequent polls', async () => {
      const firstBatch = [
        makePollItem('msg-1', 'older', new Date('2026-06-01T12:00:00Z')),
        makePollItem('msg-2', 'newest', new Date('2026-06-01T12:00:05Z')),
      ];
      const fetchSpy = mockOkFetch(firstBatch);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());

      await flushPoll();
      await vi.advanceTimersByTimeAsync(2000);

      const secondUrl = new URL(fetchSpy.mock.calls[1][0] as string);
      expect(secondUrl.searchParams.get('since')).toBe(
        String(new Date('2026-06-01T12:00:05Z').getTime())
      );
    });

    it('falls back to Date.now() - 5000 when polled items have no date', async () => {
      const items = [makePollItem('msg-1', 'no date')];
      const fetchSpy = mockOkFetch(items);
      vi.stubGlobal('fetch', fetchSpy);
      vi.setSystemTime(new Date('2026-06-01T00:00:00Z'));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());

      await flushPoll();
      await vi.advanceTimersByTimeAsync(2000);

      const secondSince = new URL(fetchSpy.mock.calls[1][0] as string)
        .searchParams.get('since');
      expect(secondSince).toBe(String(Date.now() - 5000));
    });

    it('schedules the next poll after the interval', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());

      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      // advanceTimersByTimeAsync runs the scheduled timer AND awaits the async poll callback
      await vi.advanceTimersByTimeAsync(2000);
      expect(fetchSpy).toHaveBeenCalledTimes(2);
    });

    it('translates video poll items into ChatMessage.video', async () => {
      const date = new Date('2026-03-15T10:00:00Z');
      const items = [
        makeVideoPollItem('vid-1', {
          mediaUrl: 'https://cdn.example.com/v.mp4',
          mediaType: 'video/mp4',
          byteCount: 5000,
          duration: 60,
          text: 'Watch this',
          date,
        }),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      const [messages] = callback.mock.calls[0];
      expect(messages).toHaveLength(1);
      expect(messages[0]).toBeInstanceOf(ChatMessage);
      expect(messages[0].type).toBe('video');
      expect(messages[0].role).toBe('AGENT');
      expect(messages[0].fileName).toBe('https://cdn.example.com/v.mp4');
      expect(messages[0].duration).toBe(60);
      expect(messages[0].mediaType).toBe('video/mp4');
      expect(messages[0].byteCount).toBe(5000);
      expect(messages[0].content).toBe('Watch this');
      expect(messages[0].wiId).toBe('vid-1');
      expect(messages[0].timestamp).toEqual(date);
    });

    it('translates buttons poll items into ChatMessage.buttons', async () => {
      const date = new Date('2026-05-01T08:00:00Z');
      const items = [
        makeButtonsPollItem('btn-1', {
          header: 'Choose',
          body: 'Pick one option',
          footer: 'Tap a button',
          buttons: ['Yes', 'No', 'Maybe'],
          date,
        }),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      const [messages] = callback.mock.calls[0];
      expect(messages).toHaveLength(1);
      expect(messages[0]).toMatchObject({
        type: 'buttons',
        role: 'AGENT',
        header: 'Choose',
        content: 'Pick one option',
        footer: 'Tap a button',
        buttons: ['Yes', 'No', 'Maybe'],
        wiId: 'btn-1',
        timestamp: date,
      });
    });

    it('translates CTA poll items into ChatMessage.cta', async () => {
      const date = new Date('2026-05-02T09:00:00Z');
      const items = [
        makeCTAPollItem('cta-1', {
          header: 'Links',
          body: 'Check these out',
          footer: 'Powered by Yalo',
          buttons: [
            { text: 'Google', url: 'https://google.com' },
            { text: 'GitHub', url: 'https://github.com' },
          ],
          date,
        }),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      const [messages] = callback.mock.calls[0];
      expect(messages).toHaveLength(1);
      expect(messages[0]).toMatchObject({
        type: 'cta',
        role: 'AGENT',
        header: 'Links',
        content: 'Check these out',
        footer: 'Powered by Yalo',
        ctaButtons: [
          { text: 'Google', url: 'https://google.com' },
          { text: 'GitHub', url: 'https://github.com' },
        ],
        wiId: 'cta-1',
        timestamp: date,
      });
    });

    it('translates vertical product poll items into ChatMessage.product', async () => {
      const date = new Date('2026-07-10T10:00:00Z');
      const items = [
        makeProductPollItem('prod-1', {
          orientation: 'ORIENTATION_VERTICAL',
          products: [
            {
              sku: 'A-1',
              name: 'Apples',
              price: 5,
              imagesUrl: ['https://cdn.example.com/a.png'],
              salePrice: 4,
              unitName: '{amount, plural, one {bag} other {bags}}',
            },
            { sku: 'B-2', name: 'Bananas', price: 3 },
          ],
          date,
        }),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      const [messages] = callback.mock.calls[0];
      expect(messages).toHaveLength(1);
      expect(messages[0]).toBeInstanceOf(ChatMessage);
      expect(messages[0]).toMatchObject({
        type: 'product',
        role: 'AGENT',
        wiId: 'prod-1',
        timestamp: date,
        products: [
          {
            sku: 'A-1',
            name: 'Apples',
            price: 5,
            salePrice: 4,
            imagesUrl: ['https://cdn.example.com/a.png'],
            unitName: '{amount, plural, one {bag} other {bags}}',
          },
          { sku: 'B-2', name: 'Bananas', price: 3 },
        ],
      });
    });

    it('translates horizontal product poll items into ChatMessage.carousel', async () => {
      const date = new Date('2026-07-11T11:00:00Z');
      const items = [
        makeProductPollItem('car-1', {
          orientation: 'ORIENTATION_HORIZONTAL',
          products: [{ sku: 'C-3', name: 'Cherries', price: 7 }],
          date,
        }),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      const [messages] = callback.mock.calls[0];
      expect(messages).toHaveLength(1);
      expect(messages[0]).toMatchObject({
        type: 'productCarousel',
        role: 'AGENT',
        wiId: 'car-1',
        timestamp: date,
        products: [{ sku: 'C-3', name: 'Cherries', price: 7 }],
      });
    });
  });

  describe('visibility', () => {
    it('stops scheduling polls while the tab is hidden', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());

      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      setTabHidden(true);

      await vi.advanceTimersByTimeAsync(10_000);
      expect(fetchSpy).toHaveBeenCalledTimes(1);
    });

    it('fires an immediate catch-up poll when the tab becomes visible again', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      setTabHidden(true);
      await vi.advanceTimersByTimeAsync(10_000);
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      setTabHidden(false);
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(2);
    });

    it('resumes regular polling cadence after becoming visible', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());
      await flushPoll();

      setTabHidden(true);
      setTabHidden(false);
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(2);

      await vi.advanceTimersByTimeAsync(2000);
      expect(fetchSpy).toHaveBeenCalledTimes(3);
    });

    it('does not poll on visibility change after unsubscribe', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      repo.unsubscribeMessages();

      setTabHidden(true);
      setTabHidden(false);
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('unsubscribeMessages', () => {
    it('stops polling after unsubscribe', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());

      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      repo.unsubscribeMessages();

      // Advance well past the poll interval — no timer should fire
      await vi.advanceTimersByTimeAsync(10_000);
      expect(fetchSpy).toHaveBeenCalledTimes(1);
    });

    it('resets the since watermark after unsubscribe', async () => {
      const items = [
        makePollItem('msg-1', 'Hi', new Date('2026-06-01T12:00:00Z')),
      ];
      const fetchSpy = mockOkFetch(items);
      vi.stubGlobal('fetch', fetchSpy);
      vi.setSystemTime(new Date('2026-06-02T00:00:00Z'));

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      repo.subscribeToMessages(vi.fn());
      await flushPoll();

      repo.unsubscribeMessages();
      repo.subscribeToMessages(vi.fn());
      await flushPoll();

      const lastUrl = new URL(
        fetchSpy.mock.calls[fetchSpy.mock.calls.length - 1][0] as string
      );
      expect(lastUrl.searchParams.get('since')).toBe(String(Date.now() - 5000));
    });

    it('clears seen IDs so resubscribing picks up old messages', async () => {
      const items = [makePollItem('msg-1', 'Hi')];
      const fetchSpy = mockOkFetch(items);
      vi.stubGlobal('fetch', fetchSpy);

      const repo = new YaloMessageRepositoryRemote(
        'https://api.example.com',
        baseConfig,
        mockTokenRepository(token),
        mockMediaService()
      );
      const callback = vi.fn();

      repo.subscribeToMessages(callback);
      await flushPoll();
      expect(callback).toHaveBeenCalledTimes(1);

      repo.unsubscribeMessages();

      repo.subscribeToMessages(callback);
      await flushPoll();
      expect(callback).toHaveBeenCalledTimes(2); // same msg delivered again after reset
    });
  });
});
