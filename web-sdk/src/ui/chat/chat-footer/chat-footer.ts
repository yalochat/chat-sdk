// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  type YaloChatClientConfig,
  yaloChatClientConfigContext,
} from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';

@customElement('chat-footer')
export class ChatFooter extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-send-icon: '';
    }
    .chat-form {
      display: flex;
      
    }
    .chat-input {
      flex-grow: 1;
    }

    .material-symbols-outlined {
      font-size: 24px;
      font-family: 'Material Symbols Outlined';
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  render() {
    return html`
      <footer class="chat-footer">
        <form class="chat-form">
          <input id="yalo-chat-input" class="chat-input" />
          <button >
            ${unsafeHTML(this.config.icons?.send)}
          </button>
        </form>
      </footer>
    `;
  }
}
