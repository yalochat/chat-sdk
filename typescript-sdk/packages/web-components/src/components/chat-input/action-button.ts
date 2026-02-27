// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

/** A round icon button used in the chat input row. */
@customElement('yalo-action-button')
export class YaloActionButton extends LitElement {
  @property({ type: String }) label = '';
  @property({ type: Boolean }) primary = false;
  @property({ type: Boolean }) disabled = false;

  static styles = css`
    button {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      border: none;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 20px;
      transition: opacity 0.15s;
    }
    button.primary {
      background: var(--yalo-send-btn-color, #2207F1);
      color: var(--yalo-send-btn-fg-color, #EFF4FF);
    }
    button:not(.primary) {
      background: none;
      color: var(--yalo-action-icon-color, #000);
    }
    button:disabled { opacity: 0.4; cursor: default; }
  `;

  render() {
    return html`
      <button
        class=${this.primary ? 'primary' : ''}
        ?disabled=${this.disabled}
        aria-label=${this.label}
        @click=${() => this.dispatchEvent(new CustomEvent('action', { bubbles: true, composed: true }))}
      >
        <slot></slot>
      </button>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-action-button': YaloActionButton;
  }
}
