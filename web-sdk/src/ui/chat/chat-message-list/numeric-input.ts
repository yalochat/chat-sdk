// Copyright (c) Yalochat, Inc. All rights reserved.

import { css, html, LitElement } from 'lit';
import { customElement, property, query } from 'lit/decorators.js';
import NumericInputController from './numeric-input-controller';

@customElement('numeric-input')
export class NumericInput extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-numeric-icon-color: #334155;
      --yalo-chat-numeric-text-color: #111111;
      --yalo-chat-numeric-border-color: #dde4ec;
      --yalo-chat-numeric-radius: 0.5rem;
      --yalo-chat-numeric-padding: 0.25rem;
      --yalo-chat-numeric-gap: 0.5rem;
      --yalo-chat-numeric-font-size: 0.875rem;
      display: block;
    }

    .field {
      display: flex;
      align-items: center;
      gap: var(--yalo-chat-numeric-gap);
      border: 1px solid var(--yalo-chat-numeric-border-color);
      border-radius: var(--yalo-chat-numeric-radius);
      padding: var(--yalo-chat-numeric-padding);
    }

    button {
      background: none;
      border: none;
      cursor: pointer;
      color: var(--yalo-chat-numeric-icon-color);
      font-size: 1.25rem;
      line-height: 1;
      width: 1.75rem;
      height: 1.75rem;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: 50%;
    }

    button:hover {
      background-color: rgba(34, 7, 241, 0.08);
    }

    button:disabled {
      color: var(--yalo-chat-numeric-border-color);
      cursor: not-allowed;
      background: none;
    }

    input {
      flex: 1 1 auto;
      min-width: 0;
      border: none;
      outline: none;
      background: transparent;
      text-align: center;
      color: var(--yalo-chat-numeric-text-color);
      font-size: var(--yalo-chat-numeric-font-size);
      font-family: inherit;
    }
  `;

  private _controller = new NumericInputController(this);

  @property({ type: Number })
  value = 0;

  @property({ type: String })
  unitName = '';

  @property({ type: Number })
  step = 1;

  @property({ type: Number })
  min = 0;

  @query('input')
  inputElement!: HTMLInputElement;

  render() {
    return html`
      <div class="field">
        <button
          type="button"
          aria-label="Decrease"
          ?disabled=${this._controller.removeDisabled}
          @click=${this._controller.onRemove}
        >
          &minus;
        </button>
        <input
          type="text"
          inputmode="numeric"
          .value=${this._controller.displayValue}
          @focus=${this._controller.onFocus}
          @blur=${this._controller.onBlur}
          @keydown=${this._controller.onKeyDown}
          @beforeinput=${this._controller.onBeforeInput}
        />
        <button
          type="button"
          aria-label="Increase"
          @click=${this._controller.onAdd}
        >
          +
        </button>
      </div>
    `;
  }
}
