// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-image-placeholder')
export class YaloImagePlaceholder extends LitElement {
  @property({ type: Number }) size = 32;

  static styles = css`
    :host {
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: var(--yalo-img-placeholder-bg-color, #F9FAFC);
      border-radius: 8px;
      width: 100%;
      aspect-ratio: 1;
    }
    svg {
      color: var(--yalo-img-placeholder-icon-color, #7C8086);
    }
  `;

  render() {
    return html`
      <svg width="${this.size}" height="${this.size}" viewBox="0 0 24 24" fill="currentColor">
        <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
      </svg>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-image-placeholder': YaloImagePlaceholder;
  }
}
