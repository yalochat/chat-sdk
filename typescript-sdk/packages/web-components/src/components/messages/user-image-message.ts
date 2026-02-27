// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import './image-placeholder.js';

@customElement('yalo-user-image-message')
export class YaloUserImageMessage extends LitElement {
  @property({ type: String }) fileName = '';
  @property({ type: String }) content = '';

  static styles = css`
    :host { display: flex; justify-content: flex-end; flex-direction: column; align-items: flex-end; gap: 4px; }
    .image-wrap {
      max-width: 200px;
      border-radius: 12px;
      overflow: hidden;
    }
    img {
      width: 100%;
      height: auto;
      display: block;
    }
    .caption {
      background: var(--yalo-user-msg-color, #F9FAFC);
      color: var(--yalo-user-msg-text-color, #000);
      border-radius: 12px 12px 4px 12px;
      padding: 6px 10px;
      font-size: 13px;
      max-width: 200px;
    }
  `;

  render() {
    return html`
      <div class="image-wrap">
        ${this.fileName
          ? html`<img src="${this.fileName}" alt="image" />`
          : html`<yalo-image-placeholder></yalo-image-placeholder>`}
      </div>
      ${this.content ? html`<div class="caption">${this.content}</div>` : ''}
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-user-image-message': YaloUserImageMessage;
  }
}
