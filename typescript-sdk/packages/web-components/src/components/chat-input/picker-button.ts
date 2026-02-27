// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

/** A bordered square button used in the attachment picker. */
@customElement('yalo-picker-button')
export class YaloPickerButton extends LitElement {
  @property({ type: String }) label = '';

  static styles = css`
    button {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      width: 72px;
      height: 72px;
      border-radius: 12px;
      border: 1px solid var(--yalo-picker-btn-border-color, #E6E6E6);
      background: none;
      cursor: pointer;
      gap: 4px;
      font-size: 12px;
      color: var(--yalo-action-icon-color, #000);
    }
    button:hover { background: var(--yalo-user-msg-color, #F9FAFC); }
    .icon { font-size: 24px; }
  `;

  render() {
    return html`
      <button
        aria-label=${this.label}
        @click=${() => this.dispatchEvent(new CustomEvent('pick', { bubbles: true, composed: true }))}
      >
        <span class="icon"><slot name="icon"></slot></span>
        <span>${this.label}</span>
      </button>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-picker-button': YaloPickerButton;
  }
}
