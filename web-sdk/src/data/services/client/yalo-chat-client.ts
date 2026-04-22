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
    document.body.appendChild(this.chatWindowEl);

    this.targetEl = document.getElementById(this.config.target);

    if (!this.targetEl) {
      console.warn(
        `Target element "#${this.config.target}" not found. Chat window will not work.`
      );
      return;
    }

    new ResizeObserver(() => this._updatePosition()).observe(this.targetEl);
    window.addEventListener('resize', () => this._updatePosition());
    this._updatePosition();

    this.targetEl.addEventListener('click', () => {
      if (this.chatWindowEl?.open) {
        this.close();
      } else {
        this.open();
      }
    });

    this.chatWindowEl.addEventListener('yalo-chat-close', () => {
      this.close();
    });
  }

  private _updatePosition(): void {
    if (!this.targetEl || !this.chatWindowEl) return;
    const rect = this.targetEl.getBoundingClientRect();
    const gap = 8;
    const bottom = window.innerHeight - rect.top + gap;
    const right = window.innerWidth - rect.right;
    this.chatWindowEl.style.setProperty(
      '--yalo-chat-inset-bottom',
      `${bottom}px`
    );
    this.chatWindowEl.style.setProperty(
      '--yalo-chat-inset-right',
      `${right}px`
    );
  }

  open(): void {
    if (this.chatWindowEl) this.chatWindowEl.open = true;
    this.targetEl?.classList.add('open');
  }

  close(): void {
    if (this.chatWindowEl) this.chatWindowEl.open = false;
    this.targetEl?.classList.remove('open');
  }

  registerCommand(command: ChatCommand, callback: ChatCommandCallback): void {
    this._commands.set(command, callback);
    if (this.chatWindowEl) {
      this.chatWindowEl.commands = new Map(this._commands);
    }
  }
}
