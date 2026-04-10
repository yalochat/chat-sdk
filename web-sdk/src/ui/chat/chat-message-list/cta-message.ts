// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';

@customElement('cta-message')
export class CTAMessage extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-cta-footer-color: #7c8086;
      --yalo-chat-cta-border-radius: 0.5rem;
      --yalo-chat-cta-color: #1111111;
      --yalo-chat-cta-font-size: 0.875rem;
      --yalo-chat-cta-padding: 0.5rem;
    }

    .cta-message {
      display: block;
      padding: var(--yalo-chat-cta-padding);
    }

    .header {
      font-weight: bold;
      margin-bottom: 0.25rem;
    }

    .body {
      margin-bottom: 0.25rem;
      word-break: break-word;
    }

    .footer {
      font-size: 0.75em;
      color: var(--yalo-chat-cta-footer-color);
      margin-bottom: 0.5rem;
    }

    .buttons {
      display: flex;
      flex-direction: column;
    }

    a {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      padding: var(--yalo-chat-cta-padding);
      border-top: 1px solid var(--yalo-chat-cta-buttons-border-color);
      color: var(--yalo-chat-cta-color);
      text-align: center;
      text-decoration: none;
      font-size: var(--yalo-chat-cta-font-size);
      word-break: break-word;
    }

    .arrow {
      display: flex;
      align-items: center;
      flex-shrink: 0;
    }

    .material-symbols-outlined {
      font-size: 1.5rem;
      font-family: 'Material Symbols Outlined';
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ attribute: false })
  message!: ChatMessage;

  render() {
    return html`
      <div class="cta-message">
        ${this.message.header
          ? html`<div class="header">${this.message.header}</div>`
          : null}
        ${this.message.content
          ? html`<div class="body">${this.message.content}</div>`
          : null}
        ${this.message.footer
          ? html`<div class="footer">${this.message.footer}</div>`
          : null}
      </div>
      <div class="buttons">
        ${this.message.ctaButtons.map(
          (btn) =>
            html`<a href=${btn.url} target="_blank" rel="noopener noreferrer"
              >${btn.text}<span class="arrow"
                >${unsafeHTML(this.config.icons?.arrowForward)}</span
              ></
            >`
        )}
      </div>
    `;
  }
}
