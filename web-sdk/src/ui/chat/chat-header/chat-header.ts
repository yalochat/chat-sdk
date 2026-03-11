// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  type YaloChatClientConfig,
  yaloChatClientConfigContext,
} from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { msg } from '@lit/localize';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';

@customElement('chat-header')
export class ChatHeader extends LitElement {

  static styles = css`
    :host {
      --yalo-chat-header-background: #F1F5FC;
      --yalo-chat-header-color: #010101;
      --yalo-chat-close-btn-color: #010101;
    }

    .chat-header {
      display: flex;
      gap: 1rem;
      align-items: center;
      justify-content: space-between;
      padding: 12px 16px;
      background: var(--yalo-chat-header-background);
      color: var(--yalo-chat-header-color);
    }

    .chat-header-title-group {
      margin: 0;
      flex-grow: 1;
    }


    .chat-header-title {
      font-size: 1.2rem;
      padding: 0;
      margin: 0;
      font-weight: 600;
    }

    .header-icon {
      width: 3rem;
      height: auto;
    }

    .chat-status {
      margin: 0;
      font-size: 0.8rem;
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
      font-size: 1.5rem;
    }

    .chat-close-btn:hover {
      background: color-mix(in srgb, currentColor 15%, transparent);
    }

    .material-symbols-outlined {
      font-size: 1.5rem;
      font-family: 'Material Symbols Outlined';
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @state()
  private _statusMessage: string = '';

  private _handleClose = () => {
    this.dispatchEvent(new Event('close'));
  };

  render() {
    return html`
      <header class="chat-header">
        ${
          this.config.image != null
            ? html`<img class="header-icon" src="${this.config.image}"/>`
            : nothing
        }
        <hgroup class="chat-header-title-group">
          <h1 class="chat-header-title">
            ${this.config.channelName}
          </h1>
          ${
            this._statusMessage !== ''
              ? html`<p class='chat-status'>${this._statusMessage}</p>`
              : nothing
          }
        </hgroup>
        <button
          class="chat-close-btn"
          aria-label="${msg(`Close Chat`)}"
          @click=${this._handleClose}
        >
          ${unsafeHTML(this.config.icons?.close)}
        </button>
      </header>
    `;
  }
}
