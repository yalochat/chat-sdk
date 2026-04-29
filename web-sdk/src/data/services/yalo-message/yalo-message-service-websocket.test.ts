// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Err, Ok, type Result } from '@domain/common/result';
import {
  MessageRole,
  MessageStatus,
  PollMessageItem,
  SdkMessage,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import { YaloMessageServiceWebSocket } from './yalo-message-service-websocket';

const sockets: MockSocket[] = [];

class MockSocket extends EventTarget {
  readyState = 0;
  url: string;
  send = vi.fn();
  close = vi.fn(() => {
    this.readyState = 3;
    this.dispatchEvent(new Event('close'));
  });
  constructor(url: string) {
    super();
    this.url = url;
    sockets.push(this);
  }
}

const stubWebSocket = () => {
  vi.stubGlobal(
    'WebSocket',
    Object.assign(MockSocket, { CONNECTING: 0, OPEN: 1, CLOSING: 2, CLOSED: 3 })
  );
};

const open = (s: MockSocket) => {
  s.readyState = 1;
  s.dispatchEvent(new Event('open'));
};
const closed = (s: MockSocket) => {
  s.readyState = 3;
  s.dispatchEvent(new Event('close'));
};
const message = (s: MockSocket, data: string) =>
  s.dispatchEvent(new MessageEvent('message', { data }));

const makeTokenRepository = (
  result: Result<string> = new Ok('jwt.token.value')
): TokenRepository => ({
  getToken: vi.fn().mockResolvedValue(result),
});

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
  },
  timestamp: new Date('2026-01-01T00:00:00Z'),
});

const flush = () => vi.advanceTimersByTimeAsync(0);

describe('YaloMessageServiceWebSocket', () => {
  const baseUrl = 'api.example.com';
  const wsUrl = `wss://${baseUrl}/websocket/v1/connect/webchat`;

  beforeEach(() => {
    vi.useFakeTimers();
    sockets.length = 0;
    stubWebSocket();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  describe('subscribe', () => {
    it('opens a WebSocket with the token as a query param', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());

      service.subscribe(() => {});
      await flush();

      expect(sockets).toHaveLength(1);
      expect(sockets[0].url).toBe(`${wsUrl}?token=jwt.token.value`);
    });

    it('URL-encodes the token', async () => {
      const service = new YaloMessageServiceWebSocket(
        baseUrl,
        makeTokenRepository(new Ok('a/b+c=d'))
      );

      service.subscribe(() => {});
      await flush();

      expect(sockets[0].url).toBe(`${wsUrl}?token=a%2Fb%2Bc%3Dd`);
    });

    it('invokes the callback with parsed PollMessageItem on incoming frames', async () => {
      const callback = vi.fn();
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());

      service.subscribe(callback);
      await flush();
      open(sockets[0]);

      const frame = JSON.stringify(
        PollMessageItem.toJSON({
          id: 'msg-1',
          userId: 'user-1',
          status: 'delivered',
          date: new Date('2026-01-01T00:00:00Z'),
          message: makeTextMessage('hello'),
        })
      );
      message(sockets[0], frame);

      expect(callback).toHaveBeenCalledTimes(1);
      expect(callback.mock.calls[0][0]).toMatchObject({
        id: 'msg-1',
        userId: 'user-1',
        status: 'delivered',
      });
    });

    it('ignores malformed frames without throwing', async () => {
      const callback = vi.fn();
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());

      service.subscribe(callback);
      await flush();
      open(sockets[0]);
      message(sockets[0], 'not-json');

      expect(callback).not.toHaveBeenCalled();
    });

    it('schedules a reconnect when the token fetch fails', async () => {
      const tokenRepository = makeTokenRepository(new Err(new Error('auth failed')));
      const service = new YaloMessageServiceWebSocket(baseUrl, tokenRepository);

      service.subscribe(() => {});
      await flush();
      expect(sockets).toHaveLength(0);

      await vi.advanceTimersByTimeAsync(1000);
      expect(tokenRepository.getToken).toHaveBeenCalledTimes(2);
    });
  });

  describe('sendMessage', () => {
    it('sends the frame as SdkMessage JSON when the socket is open', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());
      service.subscribe(() => {});
      await flush();
      open(sockets[0]);

      const result = await service.sendMessage(makeTextMessage('hi'));

      expect(result.ok).toBe(true);
      expect(sockets[0].send).toHaveBeenCalledTimes(1);
      expect(JSON.parse(sockets[0].send.mock.calls[0][0])).toMatchObject({
        correlationId: 'cid-hi',
        textMessageRequest: { content: { text: 'hi' } },
      });
    });

    it('queues frames sent before the socket opens, then flushes on open', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());
      service.subscribe(() => {});
      await flush();

      const r1 = await service.sendMessage(makeTextMessage('one'));
      const r2 = await service.sendMessage(makeTextMessage('two'));

      expect(r1.ok).toBe(true);
      expect(r2.ok).toBe(true);
      expect(sockets[0].send).not.toHaveBeenCalled();

      open(sockets[0]);

      expect(sockets[0].send).toHaveBeenCalledTimes(2);
    });

    it('connects on first send when not yet subscribed', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());

      const result = await service.sendMessage(makeTextMessage('hi'));
      await flush();

      expect(result.ok).toBe(true);
      expect(sockets).toHaveLength(1);

      open(sockets[0]);
      expect(sockets[0].send).toHaveBeenCalledTimes(1);
    });
  });

  describe('reconnect', () => {
    it('reconnects after the socket closes, with exponential backoff', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());
      service.subscribe(() => {});
      await flush();
      open(sockets[0]);

      closed(sockets[0]);
      expect(sockets).toHaveLength(1);

      await vi.advanceTimersByTimeAsync(1000);
      expect(sockets).toHaveLength(2);

      closed(sockets[1]);
      await vi.advanceTimersByTimeAsync(1500);
      expect(sockets).toHaveLength(2);

      await vi.advanceTimersByTimeAsync(500);
      expect(sockets).toHaveLength(3);
    });

    it('caps the backoff delay at 30 seconds', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());
      service.subscribe(() => {});
      await flush();

      for (let i = 0; i < 8; i++) {
        const delay = Math.min(30000, 1000 * 2 ** i);
        closed(sockets[i]);
        await vi.advanceTimersByTimeAsync(delay);
      }

      closed(sockets[8]);
      await vi.advanceTimersByTimeAsync(30000);
      expect(sockets).toHaveLength(10);
    });

    it('resets the backoff after a successful open', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());
      service.subscribe(() => {});
      await flush();

      closed(sockets[0]);
      await vi.advanceTimersByTimeAsync(1000);
      closed(sockets[1]);
      await vi.advanceTimersByTimeAsync(2000);
      open(sockets[2]);
      closed(sockets[2]);

      await vi.advanceTimersByTimeAsync(1000);
      expect(sockets).toHaveLength(4);
    });
  });

  describe('unsubscribe', () => {
    it('closes the socket and stops reconnect attempts', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());
      service.subscribe(() => {});
      await flush();
      open(sockets[0]);

      service.unsubscribe();
      expect(sockets[0].close).toHaveBeenCalled();

      await vi.advanceTimersByTimeAsync(60000);
      expect(sockets).toHaveLength(1);
    });

    it('clears queued frames so they are not sent on a later subscribe', async () => {
      const service = new YaloMessageServiceWebSocket(baseUrl, makeTokenRepository());
      service.subscribe(() => {});
      await flush();

      await service.sendMessage(makeTextMessage('queued'));
      service.unsubscribe();

      service.subscribe(() => {});
      await flush();
      open(sockets[1]);

      expect(sockets[1].send).not.toHaveBeenCalled();
    });
  });
});
