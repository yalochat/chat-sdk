// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import {
  yaloChatClientConfigContext,
  type YaloChatClientConfig,
} from '@domain/config/chat-config-context';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { consume } from '@lit/context';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import { localized, msg } from '@lit/localize';
import UserMessageController from './user-message-controller';
import './image-message';
import './voice-message';
import './attachment-message';

@localized()
@customElement('user-message')
export class UserMessage extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-user-message-error-color: #a01600;
      --yalo-chat-user-message-error-text-color: #461a1a;
      display: flex;
      justify-content: flex-end;
      margin: 0.25rem 0.5rem;
      width: 100%;
    }

    .error-wrapper {
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      max-width: 80%;
      cursor: pointer;
    }

    .error-row {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .error-icon {
      flex-shrink: 0;
      color: var(--yalo-chat-user-message-error-color);
      font-size: 1.25rem;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .material-symbols-outlined {
      font-size: 1.25rem;
      font-family: 'Material Symbols Outlined';
      font-variation-settings: 'FILL' 1;
    }

    .error-label {
      font-size: 0.75rem;
      color: var(--yalo-chat-user-message-error-text-color);
      margin-top: 0.25rem;
      align-self: flex-end;
    }

    .error-label .retry {
      text-decoration: underline;
      font-weight: bold;
    }

    .bubble {
      max-width: 80%;
      padding: 0.5rem 0.75rem;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      background: var(--yalo-chat-user-message-background, #f9fafc);
      word-break: break-word;
    }

    .error-wrapper .bubble,
    .error-wrapper .voice-bubble,
    .error-wrapper .image-bubble {
      max-width: 100%;
    }

    .voice-bubble {
      width: 60%;
      padding: 0.5rem 0.75rem;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      background: var(--yalo-chat-user-message-background, #f9fafc);
    }

    .image-bubble {
      max-width: 80%;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      overflow: hidden;
    }
  `;

  private _controller = new UserMessageController(this);

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ attribute: false })
  message!: ChatMessage;

  private _renderBubble() {
    switch (this.message.type) {
      case 'voice':
        return html`<div class="voice-bubble">
          <voice-message .message=${this.message}></voice-message>
        </div>`;
      case 'image':
        return html`<div class="image-bubble">
          <image-message .message=${this.message}></image-message>
        </div>`;
      case 'attachment':
        return html`<span class="bubble">
          <attachment-message .message=${this.message}></attachment-message>
        </span>`;
      case 'text':
      default:
        return html`<span class="bubble">${this.message.content}</span>`;
    }
  }

  render() {
    if (this._controller.isError) {
      return html`
        <div
          class="error-wrapper"
          role="button"
          tabindex="0"
          @click=${() => this._controller.retryMessage()}
        >
          <div class="error-row">
            <span class="error-icon" aria-hidden="true">
              ${unsafeHTML(this.config.icons?.error)}
            </span>
            ${this._renderBubble()}
          </div>
          <span class="error-label">
            ${msg('Not delivered.')}
            <span class="retry">${msg('Retry')}</span>
          </span>
        </div>
      `;
    }

    return this._renderBubble();
  }
}
