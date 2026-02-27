// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-numeric-text-field')
export class YaloNumericTextField extends LitElement {
  @property({ type: Number }) value = 0;
  @property({ type: Number }) step = 1;
  @property({ type: Number }) min = 0;

  static styles = css`
    :host {
      display: flex;
      align-items: center;
      gap: 4px;
    }
    button {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      border: 1px solid var(--yalo-input-border-color, #E8E8E8);
      background: none;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      color: var(--yalo-numeric-ctrl-icon-color, #7C8086);
      font-size: 18px;
      line-height: 1;
    }
    button:disabled { opacity: 0.4; cursor: default; }
    span {
      min-width: 32px;
      text-align: center;
      font-size: 14px;
    }
  `;

  private _emit(newVal: number) {
    this.dispatchEvent(new CustomEvent('value-change', { detail: newVal, bubbles: true, composed: true }));
  }

  render() {
    return html`
      <button ?disabled=${this.value <= this.min} @click=${() => this._emit(this.value - this.step)}>−</button>
      <span>${this.value}</span>
      <button @click=${() => this._emit(this.value + this.step)}>+</button>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-numeric-text-field': YaloNumericTextField;
  }
}
