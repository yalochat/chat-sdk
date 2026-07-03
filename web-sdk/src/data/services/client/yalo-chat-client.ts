// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatWindow } from '@ui/chat/chat-window/yalo-chat-window';
import '@ui/chat/chat-window/yalo-chat-window';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  ChatCommand,
  ChatCommandCallback,
} from '@domain/models/command/chat-command';
import type {
  CustomCommandHandler,
  CustomCommandId,
  GetCartHandler,
  RegisteredCommandHandler,
} from '@domain/models/command/channel-command';

export interface YaloChatClientInitOptions {
  onOpen?: () => void;
  onClose?: () => void;
}

export default class YaloChatClient {
  private config: YaloChatClientConfig;
  chatWindowEl: YaloChatWindow | null = null;
  private targetEl: HTMLElement | null = null;
  private _commands = new Map<string, RegisteredCommandHandler>();
  private _onOpen?: () => void;
  private _onClose?: () => void;

  constructor(config: YaloChatClientConfig) {
    this.config = config;
  }

  init(options?: YaloChatClientInitOptions): void {
    this._onOpen = options?.onOpen;
    this._onClose = options?.onClose;

    this.chatWindowEl = document.createElement(
      'yalo-chat-window'
    ) as YaloChatWindow;
    this.chatWindowEl.config = this.config;
    this.chatWindowEl.commands = new Map(this._commands);

    this.targetEl = document.getElementById(this.config.target);

    const mountInto = this.targetEl ?? document.body;
    mountInto.appendChild(this.chatWindowEl);

    if (!this.targetEl) {
      console.warn(
        `Target element "#${this.config.target}" not found. Chat window will not work.`
      );
      return;
    }

    this.chatWindowEl.addEventListener('yalo-chat-close', () => this.close());
  }

  open(): void {
    if (this.chatWindowEl) {
      this.chatWindowEl.openContext = this.config.openContext;
      this.chatWindowEl.open = true;
    }
    this._onOpen?.();
  }

  close(): void {
    if (this.chatWindowEl) {
      this.chatWindowEl.open = false;
    }
    this._onClose?.();
  }

  // Registers a handler the chat can invoke on the host, keyed by command id.
  // Client -> channel command ids (ChatCommands) run instead of the built-in
  // remote call. Any other id answers the matching channel command request and
  // its result is sent back to the channel as the response.
  registerCommand(command: 'getCart', handler: GetCartHandler): void;
  registerCommand(command: ChatCommand, callback: ChatCommandCallback): void;
  registerCommand(
    command: CustomCommandId,
    handler: CustomCommandHandler
  ): void;
  registerCommand(command: string, handler: RegisteredCommandHandler): void {
    this._commands.set(command, handler);
    if (this.chatWindowEl) {
      this.chatWindowEl.commands = new Map(this._commands);
    }
  }

  dispose(): void {
    if (this.chatWindowEl) {
      this.chatWindowEl.remove();
      this.chatWindowEl = null;
    }
    this.targetEl = null;
  }
}
