// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatWindow } from '@ui/chat/chat-window';
import '@ui/chat/chat-window';
import type { YaloChatClientConfig } from '@domain/config/chat-config';

export default class YaloChatClient {
  private config: YaloChatClientConfig;
  private chatWindowEl: YaloChatWindow | null = null;
  private targetEl: HTMLElement | null = null;

  constructor(config: YaloChatClientConfig) {
    this.config = config;
  }

  init(): void {
    this.chatWindowEl = document.createElement(
      'yalo-chat-window',
    ) as YaloChatWindow;
    this.chatWindowEl.config = this.config;

    document.body.appendChild(this.chatWindowEl);
    this.targetEl = document.getElementById(this.config.target);

    if (!this.targetEl) {
      console.warn(
        `Target element "#${this.config.target}" not found. Chat window will not work.`,
      );
      return;
    }

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

  open(): void {
    if (this.chatWindowEl) this.chatWindowEl.open = true;
    this.targetEl?.classList.add('open');
  }

  close(): void {
    if (this.chatWindowEl) this.chatWindowEl.open = false;
    this.targetEl?.classList.remove('open');
  }
}
