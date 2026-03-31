// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';

@customElement('attachment-message')
export class AttachmentMessage extends LitElement {
  static styles = css`
    :host {
      display: block;
    }

    .attachment {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .attachment-icon {
      color: var(--yalo-chat-attachment-icon-color, #7c8086);
      display: flex;
      align-items: center;
      flex-shrink: 0;
    }

    .attachment-name {
      font-size: 0.875rem;
      word-break: break-word;
      user-select: none;
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

  private _getDisplayName(): string {
    const fullName = this.message.fileName ?? '';
    const lastSlash = Math.max(
      fullName.lastIndexOf('/'),
      fullName.lastIndexOf('\\')
    );
    return lastSlash >= 0 ? fullName.substring(lastSlash + 1) : fullName;
  }

  render() {
    return html`
      <div class="attachment">
        <span class="attachment-icon">
          ${unsafeHTML(this.config.icons?.document)}
        </span>
        <span class="attachment-name">${this._getDisplayName()}</span>
      </div>
    `;
  }
}
