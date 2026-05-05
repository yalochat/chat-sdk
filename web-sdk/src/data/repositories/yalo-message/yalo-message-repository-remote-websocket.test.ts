// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Err, Ok } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import { ProductMessageRequest_Orientation } from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type {
  MessageCallback,
  YaloMessageService,
} from '@data/services/yalo-message/yalo-message-service';
import type { YaloMediaService } from '@data/services/yalo-media/yalo-media-service';
import { YaloMessageRepositoryRemoteWebSocket } from './yalo-message-repository-remote-websocket';

const okService = (): {
  service: YaloMessageService;
  emit: (item: unknown) => void;
} => {
  let cb: MessageCallback | undefined;
  return {
    service: {
      sendMessage: vi.fn().mockResolvedValue(new Ok(undefined)),
      subscribe: vi.fn((c: MessageCallback) => {
        cb = c;
      }),
      unsubscribe: vi.fn(() => {
        cb = undefined;
      }),
    },
    emit: (item) => cb?.(item as never),
  };
};

const failingService = (
  error: Error = new Error('send failed')
): YaloMessageService => ({
  sendMessage: vi.fn().mockResolvedValue(new Err(error)),
  subscribe: vi.fn(),
  unsubscribe: vi.fn(),
});

const okMedia = (id = 'media-id'): YaloMediaService => ({
  uploadMedia: vi.fn().mockResolvedValue(new Ok({ id })),
  downloadMedia: vi.fn().mockResolvedValue(new Ok({})),
});

const failingMedia = (
  error: Error = new Error('upload failed')
): YaloMediaService => ({
  uploadMedia: vi.fn().mockResolvedValue(new Err(error)),
  downloadMedia: vi.fn().mockResolvedValue(new Ok({})),
});

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

const textPollItem = (id: string, text: string, date?: Date) => ({
  id,
  userId: 'user-1',
  status: 0,
  date,
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
});

const productPollItem = (
  id: string,
  orientation: ProductMessageRequest_Orientation
) => ({
  id,
  userId: 'user-1',
  status: 0,
  message: {
    correlationId: '',
    timestamp: new Date(),
    productMessageRequest: {
      timestamp: new Date(),
      orientation,
      products: [
        {
          sku: 'SKU-1',
          name: 'Apples',
          price: 5,
          imagesUrl: ['https://cdn.example.com/a.png'],
          salePrice: 4,
          subunits: 1,
          unitStep: 1,
          unitName: '{amount, plural, one {bag} other {bags}}',
          subunitStep: 1,
          unitsAdded: 0,
          subunitsAdded: 0,
        },
      ],
    },
  },
});

describe('YaloMessageRepositoryRemoteWebSocket', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  describe('insertMessage', () => {
    it('sends a text SdkMessage via the service and returns Ok with the original message', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());
      const msg = makeMessage({ id: 7, content: 'test content' });

      const result = await repo.insertMessage(msg);

      expect(result.ok).toBe(true);
      if (result.ok) expect(result.value).toBe(msg);
      expect(service.sendMessage).toHaveBeenCalledOnce();
      expect((service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0]).toMatchObject({
        correlationId: '7',
        textMessageRequest: { content: { text: 'test content' } },
      });
    });

    it('returns Err when the service rejects the send', async () => {
      const repo = new YaloMessageRepositoryRemoteWebSocket(
        failingService(new Error('socket closed')),
        okMedia()
      );

      const result = await repo.insertMessage(makeMessage());

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('socket closed');
    });

    it('uploads media before sending a video that has a blob and uses the returned media id', async () => {
      const { service } = okService();
      const media = okMedia('media-123');
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, media);
      const msg = makeMessage({
        type: 'video',
        fileName: 'clip.mp4',
        mediaType: 'video/mp4',
        byteCount: 2048,
        duration: 15,
        blob: new Blob(['fake'], { type: 'video/mp4' }),
      });

      await repo.insertMessage(msg);

      expect(media.uploadMedia).toHaveBeenCalledOnce();
      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        videoMessageRequest: {
          content: {
            mediaUrl: 'media-123',
            mediaType: 'video/mp4',
            byteCount: 2048,
            duration: 15,
            fileName: 'clip.mp4',
          },
        },
      });
    });

    it('returns Err when media upload fails and never sends', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(
        service,
        failingMedia(new Error('upload failed'))
      );
      const msg = makeMessage({
        type: 'image',
        fileName: 'pic.png',
        mediaType: 'image/png',
        byteCount: 100,
        blob: new Blob(['x'], { type: 'image/png' }),
      });

      const result = await repo.insertMessage(msg);

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('upload failed');
      expect(service.sendMessage).not.toHaveBeenCalled();
    });

    it('uses the local file name when there is no blob to upload', async () => {
      const { service } = okService();
      const media = okMedia();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, media);
      const msg = makeMessage({
        type: 'image',
        fileName: 'remote.png',
        mediaType: 'image/png',
        byteCount: 100,
        content: 'caption',
      });

      await repo.insertMessage(msg);

      expect(media.uploadMedia).not.toHaveBeenCalled();
      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        imageMessageRequest: { content: { mediaUrl: 'remote.png' } },
      });
    });

    it('wraps thrown non-Error values into an Error', async () => {
      const service: YaloMessageService = {
        sendMessage: vi.fn().mockRejectedValue('oops'),
        subscribe: vi.fn(),
        unsubscribe: vi.fn(),
      };
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());

      const result = await repo.insertMessage(makeMessage());

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('oops');
    });
  });

  describe('cart and promotion commands', () => {
    it('sends an addToCartRequest with sku, quantity and unit type', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());

      const result = await repo.addToCart('SKU-1', 'unit', 5);

      expect(result.ok).toBe(true);
      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        addToCartRequest: { sku: 'SKU-1', quantity: 5, unitType: 1 },
      });
    });

    it('sends a removeFromCartRequest with subunit type and optional quantity', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());

      await repo.removeFromCart('SKU-1', 'subunit', 2);
      await repo.removeFromCart('SKU-1', 'subunit');

      const calls = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls;
      expect(calls[0][0]).toMatchObject({
        removeFromCartRequest: { sku: 'SKU-1', quantity: 2, unitType: 2 },
      });
      expect(calls[1][0].removeFromCartRequest.quantity).toBeUndefined();
    });

    it('sends a clearCartRequest with a timestamp', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());

      await repo.clearCart();

      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent.clearCartRequest).toBeDefined();
      expect(sent.clearCartRequest.timestamp).toBeInstanceOf(Date);
    });

    it('sends an addPromotionRequest with the promotion id', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());

      await repo.addPromotion('PROMO-1');

      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        addPromotionRequest: { promotionId: 'PROMO-1' },
      });
    });

    it('propagates send failures from cart commands', async () => {
      const repo = new YaloMessageRepositoryRemoteWebSocket(
        failingService(new Error('socket closed')),
        okMedia()
      );

      const result = await repo.addToCart('SKU-1', 'unit', 1);

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('socket closed');
    });
  });

  describe('subscribeToMessages', () => {
    it('subscribes to the service exactly once', () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());

      repo.subscribeToMessages(vi.fn());

      expect(service.subscribe).toHaveBeenCalledOnce();
    });

    it('translates a text frame into a ChatMessage and forwards it', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      const date = new Date('2026-06-01T12:00:00Z');
      emit(textPollItem('msg-1', 'Hi there', date));

      expect(callback).toHaveBeenCalledOnce();
      const [messages] = callback.mock.calls[0];
      expect(messages).toHaveLength(1);
      expect(messages[0]).toBeInstanceOf(ChatMessage);
      expect(messages[0]).toMatchObject({
        type: 'text',
        role: 'AGENT',
        content: 'Hi there',
        wiId: 'msg-1',
        timestamp: date,
      });
    });

    it('skips frames whose message body is missing or unrecognized', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({ id: 'no-msg', userId: 'u', status: 0 });
      emit({
        id: 'unknown',
        userId: 'u',
        status: 0,
        message: { correlationId: '', timestamp: new Date() },
      });

      expect(callback).not.toHaveBeenCalled();
    });

    it('parses header, footer, and buttons from text frames', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({
        id: 'txt-hfb',
        userId: 'u',
        status: 0,
        message: {
          correlationId: '',
          timestamp: new Date(),
          textMessageRequest: {
            timestamp: new Date(),
            header: 'Choose',
            footer: 'Powered by Yalo',
            buttons: [
              { text: 'Yes', buttonType: 0 },
              { text: 'No', buttonType: 0 },
            ],
            content: {
              text: 'Pick one',
              timestamp: undefined,
              status: 1,
              role: 2,
            },
          },
        },
      });

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'text',
        role: 'AGENT',
        content: 'Pick one',
        header: 'Choose',
        footer: 'Powered by Yalo',
        buttons: ['Yes', 'No'],
      });
    });

    it('translates vertical product frames into ChatMessage.product', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit(
        productPollItem(
          'prod-1',
          ProductMessageRequest_Orientation.ORIENTATION_VERTICAL
        )
      );

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'product',
        role: 'AGENT',
        wiId: 'prod-1',
        products: [{ sku: 'SKU-1', name: 'Apples', price: 5 }],
      });
    });

    it('translates horizontal product frames into ChatMessage.carousel', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit(
        productPollItem(
          'car-1',
          ProductMessageRequest_Orientation.ORIENTATION_HORIZONTAL
        )
      );

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'productCarousel',
        role: 'AGENT',
        wiId: 'car-1',
      });
    });
  });

  describe('unsubscribeMessages', () => {
    it('forwards to the underlying service', () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemoteWebSocket(service, okMedia());

      repo.subscribeToMessages(vi.fn());
      repo.unsubscribeMessages();

      expect(service.unsubscribe).toHaveBeenCalledOnce();
    });
  });
});
