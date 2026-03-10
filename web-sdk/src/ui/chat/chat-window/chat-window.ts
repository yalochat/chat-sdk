// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';

import '@ui/chat/chat-header/chat-header.ts';
import '@ui/chat/chat-footer/chat-footer.ts';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context.ts';
import { provide } from '@lit/context';
import Logger from '@log/logger.ts';
import { loggerContext } from '@log/logger-context.ts';

@customElement('yalo-chat-window')
export class YaloChatWindow extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-background: #ffffff;
      --yalo-chat-corner-radius: 12px;
      --yalo-chat-font: sans-serif;
      --yalo-chat-column-item-space: 8px;
      --yalo-chat-row-item-space: 8px;

      display: none;
      position: fixed;
      bottom: 80px;
      right: 24px;
      z-index: 9999;
    }

    :host([open]) {
      display: block;
    }

    .chat-window {
      width: 360px;
      height: 520px;
      background: var(--yalo-chat-background);
      border-radius: var(--yalo-chat-corner-radius);
      font-family: var(--yalo-chat-font);
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }

    .chat-body {
      flex: 1;
      overflow-y: auto;
    }
  `;

  @property({ type: Boolean, reflect: true })
  open: boolean = false;

  @property({ attribute: false })
  @provide({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @provide({ context: loggerContext })
  logger: Logger = new Logger();

  connectedCallback() {
    super.connectedCallback();
    this.logger.debug('Initialized with config', this.config);
  }

  private _handleClose = () => {
    this.open = false;
    this.dispatchEvent(
      new Event('yalo-chat-close', { bubbles: true, composed: true }),
    );
  };

  render() {
    return html`
      <div class="chat-window" >
        <chat-header @close=${this._handleClose}>
        </chat-header>
        <div class="chat-body">
          <slot></slot>
        </div>
        <chat-footer>
        </chat-footer>
      </div>
    `;
  }
}
