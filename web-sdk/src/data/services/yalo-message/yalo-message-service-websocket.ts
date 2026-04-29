// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import {
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

export class YaloMessageServiceWebSocket implements YaloMessageService {
  private readonly _wsUrl: string;
  private readonly _tokenRepository: TokenRepository;
  private _socket?: WebSocket;
  private _callback?: MessageCallback;
  private _pendingFrames: string[] = [];
  private _reconnectAttempt = 0;
  private _reconnectTimeout?: ReturnType<typeof setTimeout>;
  private _running = false;

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
    this._pendingFrames = [];
    this._reconnectAttempt = 0;
    if (this._reconnectTimeout) {
      clearTimeout(this._reconnectTimeout);
      this._reconnectTimeout = undefined;
    }
    if (this._socket) {
      this._socket.close();
      this._socket = undefined;
    }
  }

  async sendMessage(message: SdkMessage): Promise<Result<void>> {
    try {
      const frame = JSON.stringify(SdkMessage.toJSON(message));
      if (this._socket?.readyState === WebSocket.OPEN) {
        this._socket.send(frame);
      } else {
        this._pendingFrames.push(frame);
        if (!this._running) {
          this._running = true;
          this._connect();
        }
      }
      return new Ok(undefined);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
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

    if (!this._running) return;

    const url = `${this._wsUrl}?token=${encodeURIComponent(tokenResult.value)}`;
    const socket = new WebSocket(url);
    this._socket = socket;

    socket.addEventListener('open', () => {
      this._reconnectAttempt = 0;
      const queued = this._pendingFrames;
      this._pendingFrames = [];
      for (const frame of queued) socket.send(frame);
    });

    socket.addEventListener('message', (event: MessageEvent) => {
      if (typeof event.data !== 'string') return;
      try {
        const item = PollMessageItem.fromJSON(JSON.parse(event.data));
        this._callback?.(item);
      } catch {
        // ignore malformed frames
      }
    });

    socket.addEventListener('close', () => {
      if (this._socket === socket) this._socket = undefined;
      if (this._running) this._scheduleReconnect();
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
