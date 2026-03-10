// Copyright (c) Yalochat, Inc. All rights reserved.

import { type YaloChatClientConfig, yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement } from 'lit/decorators.js';

@customElement('chat-header')
export class ChatHeader extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-header-background: #000;
      --yalo-chat-header-color: #ffffff;
      --yalo-chat-close-btn-color: #ffffff;
    }

    .chat-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 16px;
      background: var(--yalo-chat-header-background);
      color: var(--yalo-chat-header-color);
    }

    .chat-header-title {
      font-size: 16px;
      font-weight: 600;
      margin: 0;
    }

    .chat-close-btn {
      background: none;
      border: none;
      color: var(--yalo-chat-close-btn-color);
      cursor: pointer;
      padding: 4px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 4px;
      line-height: 1;
      font-size: 20px;
    }

    .chat-close-btn:hover {
      background: color-mix(in srgb, currentColor 15%, transparent);
    }
  `;

  @consume({ context: yaloChatClientConfigContext})
  config!: YaloChatClientConfig;

  private _handleClose = () => {
    this.dispatchEvent(new Event('close'));
  };

  render() {
    return html`
      <header class="chat-header">
        <span class="chat-header-title">${this.config?.channelName}</span>
        <button
          class="chat-close-btn"
          aria-label="${this.config.channelName}"
          @click=${this._handleClose}
        >
          &#x2715;
        </button>
      </header>
    `;
  }
}
