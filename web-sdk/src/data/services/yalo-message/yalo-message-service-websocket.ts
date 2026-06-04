// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import {
  ConnectionAck,
  ConnectionAckType,
  PollMessageItem,
  SdkMessage,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import type {
  MessageCallback,
  YaloMessageService,
} from './yalo-message-service';

const INITIAL_BACKOFF_MS = 1000;
const MAX_BACKOFF_MS = 30000;
const ACK_TIMEOUT_MS = 10000;

export class YaloMessageServiceWebSocket implements YaloMessageService {
  private readonly _wsUrl: string;
  private readonly _tokenRepository: TokenRepository;
  private _socket?: WebSocket;
  private _callback?: MessageCallback;
  private _reconnectAttempt = 0;
  private _reconnectTimeout?: ReturnType<typeof setTimeout>;
  private _ackTimeout?: ReturnType<typeof setTimeout>;
  private _running = false;
  private _pendingFrames: string[] = [];
  private _connectionAcked = false;

  constructor(baseUrl: string, tokenRepository: TokenRepository) {
    this._wsUrl = `wss://${baseUrl}/websocket/v1/connect/webchat`;
    this._tokenRepository = tokenRepository;
  }

  subscribe(callback: MessageCallback): void {
    this._callback = callback;
    this._running = true;
    this._connect();
  }

  unsubscribe(): void {
    this._running = false;
    this._callback = undefined;
    this._reconnectAttempt = 0;
    this._pendingFrames = [];
    this._connectionAcked = false;
    if (this._reconnectTimeout) {
      clearTimeout(this._reconnectTimeout);
      this._reconnectTimeout = undefined;
    }
    this._clearAckTimeout();
    if (this._socket) {
      this._socket.close();
      this._socket = undefined;
    }
  }

  async sendMessage(message: SdkMessage): Promise<Result<void>> {
    if (!this._running) {
      return new Err(new Error('WebSocket is not connected'));
    }
    let frame: string;
    try {
      frame = JSON.stringify(SdkMessage.toJSON(message));
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
    if (
      !this._connectionAcked ||
      this._socket?.readyState !== WebSocket.OPEN
    ) {
      this._pendingFrames.push(frame);
      return new Ok(undefined);
    }
    try {
      this._socket.send(frame);
      return new Ok(undefined);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  private _clearAckTimeout(): void {
    if (this._ackTimeout) {
      clearTimeout(this._ackTimeout);
      this._ackTimeout = undefined;
    }
  }

  private _flushPending(): void {
    const pending = this._pendingFrames;
    this._pendingFrames = [];
    for (const frame of pending) {
      try {
        this._socket?.send(frame);
      } catch {
        // The caller already received Ok at enqueue time.
      }
    }
  }

  private async _connect(): Promise<void> {
    if (!this._running) return;
    if (this._socket) return;

    const tokenResult = await this._tokenRepository.getToken();
    if (!tokenResult.ok) {
      this._scheduleReconnect();
      return;
    }

    const url = `${this._wsUrl}?token=${encodeURIComponent(tokenResult.value)}`;
    const socket = new WebSocket(url);
    this._socket = socket;

    socket.addEventListener('open', () => {
      this._reconnectAttempt = 0;
      this._ackTimeout = setTimeout(() => {
        this._ackTimeout = undefined;
        socket.close();
      }, ACK_TIMEOUT_MS);
    });

    socket.addEventListener('message', (event: MessageEvent) => {
      if (typeof event.data !== 'string') {
        return;
      }
      let parsed: unknown;
      try {
        parsed = JSON.parse(event.data);
      } catch {
        return;
      }
      if (typeof parsed !== 'object' || parsed === null) {
        return;
      }
      try {
        if (!this._connectionAcked) {
          const ack = ConnectionAck.fromJSON(parsed);
          if (ack.type === ConnectionAckType.CONNECTION_ACK_TYPE_CONNECTION_ACK) {
            this._connectionAcked = true;
            this._clearAckTimeout();
            this._flushPending();
          }
          return;
        }
        const item = PollMessageItem.fromJSON(parsed);
        this._callback?.(item);
      } catch {
        // ignore malformed frames
      }
    });

    socket.addEventListener('error', () => {
      socket.close();
    });

    socket.addEventListener('close', () => {
      if (this._socket === socket) {
        this._socket = undefined;
      }
      this._connectionAcked = false;
      this._clearAckTimeout();
      if (this._running) {
        this._scheduleReconnect();
      }
    });
  }

  private _scheduleReconnect(): void {
    if (!this._running || this._reconnectTimeout) return;
    const delay = Math.min(
      MAX_BACKOFF_MS,
      INITIAL_BACKOFF_MS * 2 ** this._reconnectAttempt
    );
    this._reconnectAttempt++;
    this._reconnectTimeout = setTimeout(() => {
      this._reconnectTimeout = undefined;
      this._connect();
    }, delay);
  }
}
