// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-chat-attachment-message')
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

    .yalo-icon {
      font-size: var(--yalo-chat-attachment-message-icon-font-size, 1.5rem);
      font-family: var(
        --yalo-chat-icon-font-family,
        'Material Symbols Outlined'
      );
      line-height: 1;
      font-feature-settings: 'liga';
    }

    .yalo-icon[data-icon='document']::before {
      content: var(--yalo-chat-icon-document, 'description');
    }
  `;

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
          <span class="yalo-icon" data-icon="document" aria-hidden="true"></span>
        </span>
        <span class="attachment-name">${this._getDisplayName()}</span>
      </div>
    `;
  }
}
