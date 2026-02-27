// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-image-preview')
export class YaloImagePreview extends LitElement {
  @property({ type: String }) src = '';

  static styles = css`
    :host { display: inline-block; position: relative; }
    img {
      width: 80px;
      height: 80px;
      object-fit: cover;
      border-radius: 12px;
      display: block;
    }
    button {
      position: absolute;
      top: -6px;
      right: -6px;
      width: 20px;
      height: 20px;
      border-radius: 50%;
      background: var(--yalo-send-btn-color, #2207F1);
      color: #fff;
      border: none;
      cursor: pointer;
      font-size: 12px;
      line-height: 1;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  `;

  render() {
    return html`
      <img src="${this.src}" alt="preview" />
      <button @click=${() => this.dispatchEvent(new CustomEvent('remove', { bubbles: true, composed: true }))}>×</button>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-image-preview': YaloImagePreview;
  }
}
