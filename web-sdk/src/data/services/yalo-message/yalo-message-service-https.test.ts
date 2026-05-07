// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Err, Ok } from '@domain/common/result';
import {
  MessageRole,
  MessageStatus,
  type SdkMessage,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import { YaloMessageServiceHttps } from './yalo-message-service-https';

// Flush the microtask queue (promise chain) for the initial poll() call
// without triggering the 2000ms setTimeout that reschedules the next poll.
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

const okTokenRepository = (token: string): TokenRepository => ({
  getToken: vi.fn().mockResolvedValue(new Ok(token)),
});

const failingTokenRepository = (): TokenRepository => ({
  getToken: vi.fn().mockResolvedValue(new Err(new Error('auth failed'))),
});

const baseConfig = {
  channelId: 'channel-1',
  organizationId: 'org-1',
  channelName: 'Test Chat',
  target: 'chat-target',
};

const makeTextMessage = (text: string): SdkMessage => ({
  correlationId: `cid-${text}`,
  textMessageRequest: {
    content: {
      timestamp: new Date('2026-01-01T00:00:00Z'),
      text,
      status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
      role: MessageRole.MESSAGE_ROLE_USER,
    },
    timestamp: new Date('2026-01-01T00:00:00Z'),
    buttons: [],
  },
  timestamp: new Date('2026-01-01T00:00:00Z'),
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

const mockOkFetch = (body: unknown = {}, status = 200) =>
  vi.fn().mockResolvedValue({
    ok: true,
    status,
    json: vi.fn().mockResolvedValue(body),
  });

const mockErrFetch = (status = 500) =>
  vi.fn().mockResolvedValue({ ok: false, status, json: vi.fn() });

describe('YaloMessageServiceHttps', () => {
  const token = makeToken('user-42');

  let addEventListenerSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    vi.useFakeTimers();
    addEventListenerSpy = vi.spyOn(document, 'addEventListener');
  });

  afterEach(() => {
    for (const [type, listener] of addEventListenerSpy.mock.calls) {
      if (type === 'visibilitychange') {
        document.removeEventListener(
          'visibilitychange',
          listener as EventListener
        );
      }
    }
    setTabHidden(false);
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  describe('sendMessage', () => {
    it('returns auth Err when auth fails', async () => {
      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        failingTokenRepository()
      );

      const result = await service.sendMessage(makeTextMessage('hi'));

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('auth failed');
    });

    it('posts to /webchat/inbound_messages with bearer token, channel and user headers', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      await service.sendMessage(makeTextMessage('hi'));

      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy.mock.calls[0][0]).toBe(
        'https://api.example.com/v1/channels/webchat/inbound_messages'
      );
      expect(fetchSpy.mock.calls[0][1]).toMatchObject({
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          authorization: `Bearer ${token}`,
          'x-channel-id': 'channel-1',
          'x-user-id': 'user-42',
        },
      });
    });

    it('serializes the SdkMessage as JSON in the body', async () => {
      const fetchSpy = mockOkFetch();
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      await service.sendMessage(makeTextMessage('hello world'));

      const body = JSON.parse(fetchSpy.mock.calls[0][1].body);
      expect(body).toMatchObject({
        correlationId: 'cid-hello world',
        textMessageRequest: { content: { text: 'hello world' } },
      });
    });

    it('returns Ok on success', async () => {
      vi.stubGlobal('fetch', mockOkFetch());

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const result = await service.sendMessage(makeTextMessage('hi'));

      expect(result.ok).toBe(true);
    });

    it('returns Err on non-ok HTTP response', async () => {
      vi.stubGlobal('fetch', mockErrFetch(422));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const result = await service.sendMessage(makeTextMessage('hi'));

      expect(result.ok).toBe(false);
      if (!result.ok)
        expect(result.error.message).toBe('sendMessage failed: 422');
    });

    it('returns Err when fetch throws', async () => {
      vi.stubGlobal(
        'fetch',
        vi.fn().mockRejectedValue(new Error('Network error'))
      );

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const result = await service.sendMessage(makeTextMessage('hi'));

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('Network error');
    });

    it('wraps non-Error thrown values', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue('oops'));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const result = await service.sendMessage(makeTextMessage('hi'));

      expect(result.ok).toBe(false);
      if (!result.ok) expect(result.error.message).toBe('oops');
    });
  });

  describe('subscribe', () => {
    it('does nothing when auth fails', async () => {
      const fetchSpy = vi.fn();
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        failingTokenRepository()
      );
      const callback = vi.fn();
      service.subscribe(callback);

      await flushPoll();

      expect(fetchSpy).not.toHaveBeenCalled();
      expect(callback).not.toHaveBeenCalled();
    });

    it('fetches /webchat/messages with correct headers', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());

      await flushPoll();

      const [url, init] = fetchSpy.mock.calls[0];
      expect(url).toMatch(
        /^https:\/\/api\.example\.com\/v1\/channels\/webchat\/messages\?/
      );
      expect(init.headers).toMatchObject({
        authorization: `Bearer ${token}`,
        'x-channel-id': 'channel-1',
        'x-user-id': 'user-42',
        accept: 'application/json',
      });
    });

    it('emits one PollMessageItem per new item', async () => {
      const items = [
        makePollItem('msg-1', 'Hi'),
        makePollItem('msg-2', 'There'),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const callback = vi.fn();
      service.subscribe(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledTimes(2);
      expect(callback.mock.calls[0][0]).toMatchObject({ id: 'msg-1' });
      expect(callback.mock.calls[1][0]).toMatchObject({ id: 'msg-2' });
    });

    it('does not emit when there are no new items', async () => {
      vi.stubGlobal('fetch', mockOkFetch([]));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const callback = vi.fn();
      service.subscribe(callback);

      await flushPoll();

      expect(callback).not.toHaveBeenCalled();
    });

    it('deduplicates items across polls', async () => {
      const items = [makePollItem('msg-1', 'Hi')];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const callback = vi.fn();
      service.subscribe(callback);

      await flushPoll();
      expect(callback).toHaveBeenCalledOnce();

      await vi.advanceTimersByTimeAsync(2000);
      expect(callback).toHaveBeenCalledOnce();
    });

    it('skips items without a message body', async () => {
      const items = [
        {
          id: 'msg-no-body',
          message: undefined,
          userId: '',
          status: 0,
        },
        makePollItem('msg-with-body', 'Hello'),
      ];
      vi.stubGlobal('fetch', mockOkFetch(items));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const callback = vi.fn();
      service.subscribe(callback);

      await flushPoll();

      expect(callback).toHaveBeenCalledOnce();
      expect(callback.mock.calls[0][0]).toMatchObject({ id: 'msg-with-body' });
    });

    it('uses Date.now() - 5000 for since on the first poll', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);
      vi.setSystemTime(new Date('2026-06-01T00:00:00Z'));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());

      await flushPoll();

      const url = new URL(fetchSpy.mock.calls[0][0] as string);
      expect(url.searchParams.get('since')).toBe(String(Date.now() - 5000));
    });

    it('uses the latest item timestamp for since on subsequent polls', async () => {
      const firstBatch = [
        makePollItem('msg-1', 'older', new Date('2026-06-01T12:00:00Z')),
        makePollItem('msg-2', 'newest', new Date('2026-06-01T12:00:05Z')),
      ];
      const fetchSpy = mockOkFetch(firstBatch);
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());

      await flushPoll();
      await vi.advanceTimersByTimeAsync(2000);

      const secondUrl = new URL(fetchSpy.mock.calls[1][0] as string);
      expect(secondUrl.searchParams.get('since')).toBe(
        String(new Date('2026-06-01T12:00:05Z').getTime())
      );
    });

    it('schedules the next poll after the interval', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());

      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      await vi.advanceTimersByTimeAsync(2000);
      expect(fetchSpy).toHaveBeenCalledTimes(2);
    });

    it('swallows network errors and retries on the next poll', async () => {
      const fetchSpy = vi.fn().mockRejectedValue(new Error('Network error'));
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const callback = vi.fn();

      expect(() => service.subscribe(callback)).not.toThrow();
      await flushPoll();

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

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const callback = vi.fn();
      service.subscribe(callback);

      await flushPoll();

      expect(callback).not.toHaveBeenCalled();
    });
  });

  describe('visibility', () => {
    it('stops scheduling polls while the tab is hidden', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());

      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      setTabHidden(true);

      await vi.advanceTimersByTimeAsync(10_000);
      expect(fetchSpy).toHaveBeenCalledTimes(1);
    });

    it('fires an immediate catch-up poll when the tab becomes visible again', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      setTabHidden(true);
      await vi.advanceTimersByTimeAsync(10_000);
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      setTabHidden(false);
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(2);
    });

    it('does not poll on visibility change after unsubscribe', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      service.unsubscribe();

      setTabHidden(true);
      setTabHidden(false);
      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('unsubscribe', () => {
    it('stops polling after unsubscribe', async () => {
      const fetchSpy = mockOkFetch([]);
      vi.stubGlobal('fetch', fetchSpy);

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      service.subscribe(vi.fn());

      await flushPoll();
      expect(fetchSpy).toHaveBeenCalledTimes(1);

      service.unsubscribe();

      await vi.advanceTimersByTimeAsync(10_000);
      expect(fetchSpy).toHaveBeenCalledTimes(1);
    });

    it('resets the since watermark and seen ids so resubscribing replays', async () => {
      const items = [
        makePollItem('msg-1', 'Hi', new Date('2026-06-01T12:00:00Z')),
      ];
      const fetchSpy = mockOkFetch(items);
      vi.stubGlobal('fetch', fetchSpy);
      vi.setSystemTime(new Date('2026-06-02T00:00:00Z'));

      const service = new YaloMessageServiceHttps(
        'api.example.com',
        baseConfig,
        okTokenRepository(token)
      );
      const callback = vi.fn();
      service.subscribe(callback);
      await flushPoll();

      service.unsubscribe();

      service.subscribe(callback);
      await flushPoll();

      expect(callback).toHaveBeenCalledTimes(2);

      const lastUrl = new URL(
        fetchSpy.mock.calls[fetchSpy.mock.calls.length - 1][0] as string
      );
      expect(lastUrl.searchParams.get('since')).toBe(String(Date.now() - 5000));
    });
  });
});
