// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatMessageAvatar } from '@domain/config/chat-config';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-chat-message-avatar')
export class MessageAvatar extends LitElement {
  static styles = css`
    :host {
      display: flex;
      flex-shrink: 0;
    }

    .avatar {
      display: flex;
      align-items: center;
      justify-content: center;
      width: var(--yalo-chat-avatar-size, 2rem);
      height: var(--yalo-chat-avatar-size, 2rem);
      border-radius: 50%;
      overflow: hidden;
      font-size: var(--yalo-chat-avatar-font-size, 0.875rem);
      font-weight: var(--yalo-chat-avatar-font-weight, 600);
      line-height: 1;
    }

    .avatar.user {
      background: var(--yalo-chat-user-avatar-background, #dde4ec);
      color: var(--yalo-chat-user-avatar-color, #181818);
    }

    .avatar.assistant {
      background: var(--yalo-chat-assistant-avatar-background, #2207f1);
      color: var(--yalo-chat-assistant-avatar-color, #ffffff);
    }

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  `;

  @property({ attribute: false })
  avatar!: Exclude<YaloChatMessageAvatar, { type: 'none' }>;

  @property()
  sender: 'user' | 'assistant' = 'user';

  render() {
    return html`<span class="avatar ${this.sender}" aria-hidden="true">
      ${this.avatar.type === 'image'
        ? html`<img src=${this.avatar.url} alt="" />`
        : [...this.avatar.text].slice(0, 2).join('')}
    </span>`;
  }
}
