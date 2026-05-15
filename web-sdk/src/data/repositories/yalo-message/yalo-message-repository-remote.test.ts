// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Err, Ok } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import {
  ButtonType,
  MessageRole,
  MessageStatus,
  ProductMessageRequest_Orientation,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type {
  MessageCallback,
  YaloMessageService,
} from '@data/services/yalo-message/yalo-message-service';
import type { YaloMediaService } from '@data/services/yalo-media/yalo-media-service';
import { YaloMessageRepositoryRemote } from './yalo-message-repository-remote';

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

describe('YaloMessageRepositoryRemote', () => {
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
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
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
      const repo = new YaloMessageRepositoryRemote(
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
      const repo = new YaloMessageRepositoryRemote(service, media);
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
      const repo = new YaloMessageRepositoryRemote(
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
      const repo = new YaloMessageRepositoryRemote(service, media);
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
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      const result = await repo.insertMessage(makeMessage());

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('oops');
    });

    it('sends a voice message with amplitudes and duration', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia('voice-id'));
      const msg = makeMessage({
        type: 'voice',
        fileName: 'note.ogg',
        mediaType: 'audio/ogg',
        byteCount: 500,
        amplitudes: [1, 2, 3],
        duration: 12,
        blob: new Blob(['x'], { type: 'audio/ogg' }),
      });

      await repo.insertMessage(msg);

      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        voiceNoteMessageRequest: {
          content: {
            mediaUrl: 'voice-id',
            mediaType: 'audio/ogg',
            byteCount: 500,
            fileName: 'note.ogg',
            amplitudesPreview: [1, 2, 3],
            duration: 12,
          },
        },
      });
    });

    it('sends an attachment message with file metadata', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia('attach-id'));
      const msg = makeMessage({
        type: 'attachment',
        fileName: 'doc.pdf',
        content: 'see attached',
        mediaType: 'application/pdf',
        byteCount: 4096,
        blob: new Blob(['x'], { type: 'application/pdf' }),
      });

      await repo.insertMessage(msg);

      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        attachmentMessageRequest: {
          content: {
            text: 'see attached',
            mediaUrl: 'attach-id',
            mediaType: 'application/pdf',
            byteCount: 4096,
            fileName: 'doc.pdf',
          },
        },
      });
    });

    it('uses an empty correlationId when the message has no id', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      await repo.insertMessage(makeMessage({ id: undefined }));

      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent.correlationId).toBe('');
    });

    it('returns Err for unsupported message types', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      const result = await repo.insertMessage(
        makeMessage({ type: 'product', content: '' })
      );

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('UnimplementedError');
      expect(service.sendMessage).not.toHaveBeenCalled();
    });
  });

  describe('cart and promotion commands', () => {
    it('sends an addToCartRequest with sku, quantity and unit type', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      const result = await repo.addToCart('SKU-1', 'unit', 5);

      expect(result.ok).toBe(true);
      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        addToCartRequest: { sku: 'SKU-1', quantity: 5, unitType: 1 },
      });
    });

    it('sends a removeFromCartRequest with subunit type and optional quantity', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

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
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      await repo.clearCart();

      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent.clearCartRequest).toBeDefined();
      expect(sent.clearCartRequest.timestamp).toBeInstanceOf(Date);
    });

    it('sends an addPromotionRequest with the promotion id', async () => {
      const { service } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      await repo.addPromotion('PROMO-1');

      const sent = (service.sendMessage as ReturnType<typeof vi.fn>).mock.calls[0][0];
      expect(sent).toMatchObject({
        addPromotionRequest: { promotionId: 'PROMO-1' },
      });
    });

    it('propagates send failures from cart commands', async () => {
      const repo = new YaloMessageRepositoryRemote(
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
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      repo.subscribeToMessages(vi.fn());

      expect(service.subscribe).toHaveBeenCalledOnce();
    });

    it('translates a text frame into a ChatMessage and forwards it', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
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
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
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
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
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
              { text: 'Open', buttonType: 2, url: 'https://example.com' },
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
        buttons: [
          { text: 'Yes', type: 'reply' },
          { text: 'Open', type: 'link', url: 'https://example.com' },
        ],
      });
    });

    it('translates vertical product frames into ChatMessage.product', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
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

    it('translates an imageMessageRequest preferring mediaUrl over fileName', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({
        id: 'img-1',
        userId: 'u',
        status: 0,
        date: new Date('2026-02-02T00:00:00Z'),
        message: {
          correlationId: '',
          timestamp: new Date(),
          imageMessageRequest: {
            timestamp: new Date(),
            buttons: [],
            content: {
              text: 'caption',
              timestamp: undefined,
              status: MessageStatus.MESSAGE_STATUS_SENT,
              role: MessageRole.MESSAGE_ROLE_AGENT,
              mediaUrl: 'https://cdn/img.png',
              mediaType: 'image/png',
              byteCount: 1000,
              fileName: 'fallback.png',
            },
          },
        },
      });

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'image',
        content: 'caption',
        fileName: 'https://cdn/img.png',
        mediaType: 'image/png',
        byteCount: 1000,
      });
    });

    it('falls back to fileName when image mediaUrl is empty', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({
        id: 'img-2',
        userId: 'u',
        status: 0,
        message: {
          correlationId: '',
          timestamp: new Date(),
          imageMessageRequest: {
            timestamp: new Date(),
            buttons: [],
            content: {
              text: undefined,
              timestamp: undefined,
              status: MessageStatus.MESSAGE_STATUS_SENT,
              role: MessageRole.MESSAGE_ROLE_AGENT,
              mediaUrl: '',
              mediaType: 'image/png',
              byteCount: 0,
              fileName: 'local.png',
            },
          },
        },
      });

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'image',
        fileName: 'local.png',
        content: '',
      });
    });

    it('translates a voiceNoteMessageRequest into a voice ChatMessage', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({
        id: 'voice-1',
        userId: 'u',
        status: 0,
        message: {
          correlationId: '',
          timestamp: new Date(),
          voiceNoteMessageRequest: {
            timestamp: new Date(),
            buttons: [],
            content: {
              timestamp: undefined,
              status: MessageStatus.MESSAGE_STATUS_SENT,
              role: MessageRole.MESSAGE_ROLE_AGENT,
              mediaUrl: 'voice.ogg',
              mediaType: 'audio/ogg',
              byteCount: 200,
              fileName: 'voice.ogg',
              amplitudesPreview: [0, 5, 9],
              duration: 7,
            },
          },
        },
      });

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'voice',
        fileName: 'voice.ogg',
        amplitudes: [0, 5, 9],
        duration: 7,
        mediaType: 'audio/ogg',
        byteCount: 200,
      });
    });

    it('translates a videoMessageRequest into a video ChatMessage', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({
        id: 'video-1',
        userId: 'u',
        status: 0,
        message: {
          correlationId: '',
          timestamp: new Date(),
          videoMessageRequest: {
            timestamp: new Date(),
            buttons: [],
            content: {
              text: 'a clip',
              timestamp: undefined,
              status: MessageStatus.MESSAGE_STATUS_SENT,
              role: MessageRole.MESSAGE_ROLE_AGENT,
              mediaUrl: 'https://cdn/v.mp4',
              mediaType: 'video/mp4',
              byteCount: 2048,
              fileName: 'fallback.mp4',
              duration: 30,
            },
          },
        },
      });

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'video',
        content: 'a clip',
        fileName: 'https://cdn/v.mp4',
        duration: 30,
        mediaType: 'video/mp4',
        byteCount: 2048,
      });
    });

    it('translates an attachmentMessageRequest into an attachment ChatMessage', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({
        id: 'att-1',
        userId: 'u',
        status: 0,
        message: {
          correlationId: '',
          timestamp: new Date(),
          attachmentMessageRequest: {
            timestamp: new Date(),
            buttons: [],
            content: {
              text: 'see file',
              timestamp: undefined,
              status: MessageStatus.MESSAGE_STATUS_SENT,
              role: MessageRole.MESSAGE_ROLE_AGENT,
              mediaUrl: 'https://cdn/doc.pdf',
              mediaType: 'application/pdf',
              byteCount: 4096,
              fileName: 'doc.pdf',
            },
          },
        },
      });

      expect(callback.mock.calls[0][0][0]).toMatchObject({
        type: 'attachment',
        content: 'see file',
        fileName: 'https://cdn/doc.pdf',
        mediaType: 'application/pdf',
        byteCount: 4096,
      });
    });

    it('falls back to current time when the frame has no date', () => {
      vi.useRealTimers();
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      const before = Date.now();
      emit(textPollItem('msg-no-date', 'no date'));
      const after = Date.now();

      const received = callback.mock.calls[0][0][0];
      expect(received.timestamp.getTime()).toBeGreaterThanOrEqual(before);
      expect(received.timestamp.getTime()).toBeLessThanOrEqual(after);
    });

    it('maps postback buttons and defaults unrecognized button types to reply', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
      const callback = vi.fn();
      repo.subscribeToMessages(callback);

      emit({
        id: 'btn-mix',
        userId: 'u',
        status: 0,
        message: {
          correlationId: '',
          timestamp: new Date(),
          textMessageRequest: {
            timestamp: new Date(),
            buttons: [
              { text: 'Back', buttonType: ButtonType.BUTTON_TYPE_POSTBACK },
              { text: 'Mystery', buttonType: ButtonType.UNRECOGNIZED },
            ],
            content: {
              text: 'hi',
              timestamp: undefined,
              status: MessageStatus.MESSAGE_STATUS_SENT,
              role: MessageRole.MESSAGE_ROLE_AGENT,
            },
          },
        },
      });

      expect(callback.mock.calls[0][0][0].buttons).toEqual([
        { text: 'Back', type: 'postback', url: undefined },
        { text: 'Mystery', type: 'reply', url: undefined },
      ]);
    });

    it('translates horizontal product frames into ChatMessage.carousel', () => {
      const { service, emit } = okService();
      const repo = new YaloMessageRepositoryRemote(service, okMedia());
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
      const repo = new YaloMessageRepositoryRemote(service, okMedia());

      repo.subscribeToMessages(vi.fn());
      repo.unsubscribeMessages();

      expect(service.unsubscribe).toHaveBeenCalledOnce();
    });
  });
});
