// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-assistant-message')
export class YaloAssistantMessage extends LitElement {
  @property({ type: String }) content = '';

  static styles = css`
    :host { display: flex; justify-content: flex-start; }
    .bubble {
      background: transparent;
      color: var(--yalo-assistant-msg-text-color, #000);
      border-radius: 4px 16px 16px 16px;
      padding: 10px 14px;
      max-width: 75%;
      word-break: break-word;
      white-space: pre-wrap;
      font-size: 14px;
      line-height: 1.4;
    }
  `;

  render() {
    return html`<div class="bubble">${this.content}</div>`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-assistant-message': YaloAssistantMessage;
  }
}
