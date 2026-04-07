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

  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
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
