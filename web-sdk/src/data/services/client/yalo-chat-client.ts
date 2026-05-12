// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatWindow } from '@ui/chat/chat-window/yalo-chat-window';
import '@ui/chat/chat-window/yalo-chat-window';
import {
  defaultIcons,
  type YaloChatClientConfig,
} from '@domain/config/chat-config';
import type {
  ChatCommand,
  ChatCommandCallback,
} from '@domain/models/command/chat-command';

export default class YaloChatClient {
  private config: YaloChatClientConfig;
  chatWindowEl: YaloChatWindow | null = null;
  private targetEl: HTMLElement | null = null;
  private _commands = new Map<ChatCommand, ChatCommandCallback>();

  constructor(config: YaloChatClientConfig) {
    this.config = {
      icons: {
        ...defaultIcons,
        ...config.icons,
      },
      ...config,
    };
  }

  init(): void {
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
  }

  close(): void {
    if (this.chatWindowEl) this.chatWindowEl.open = false;
  }

  registerCommand(command: ChatCommand, callback: ChatCommandCallback): void {
    this._commands.set(command, callback);
    if (this.chatWindowEl) {
      this.chatWindowEl.commands = new Map(this._commands);
    }
  }
}
