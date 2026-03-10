// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  type YaloChatClientConfig,
  yaloChatClientConfigContext,
} from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement, query } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';

@customElement('chat-footer')
export class ChatFooter extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-input-border: 1px solid #e8e8e8;
      --yalo-chat-input-border-radius: 25.5px;
      --yalo-chat-input-font-size: 16px;
      --yalo-chat-send-btn-background: #2207F1;
      --yalo-chat-send-btn-color: white;
    }

    .chat-form {
      display: flex;
      padding: 8px;
      gap: 1rem;
    }

    .chat-input {
      flex-grow: 1;
      appearance: none;
      border: var(--yalo-chat-input-border);
      border-radius: var(--yalo-chat-input-border-radius);
      padding: var(--yalo-chat-column-item-space);
      outline: none;
      font-family: inherit;
      resize: none;
      overflow-y: hidden;
      font-size: var(--yalo-chat-input-font-size);
      line-height: 1.5;
      max-height: calc(1.5em * 3 + var(--yalo-chat-column-item-space) * 2);
      box-sizing: border-box;
    }

    .chat-send-button {
      appearance: none;
      border: none;
      outline: none;
      background: var(--yalo-chat-send-btn-background);
      color: var(--yalo-chat-send-btn-color);
      border-radius: 50%;
      width: 2.5rem;
      height: 2.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      flex-shrink: 0;
    }

    .material-symbols-outlined {
      font-size: 24px;
      font-family: 'Material Symbols Outlined';
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @query('.chat-input')
  private _textarea!: HTMLTextAreaElement;

  private _onSubmit = (e: Event) => {
    e.preventDefault();
    const value = this._textarea.value.trim();
    if (!value) return;
    this.dispatchEvent(
      new CustomEvent('yalo-chat-send-text-message', {
        detail: value,
        bubbles: true,
        composed: true,
      }),
    );
    this._textarea.value = '';
    this._textarea.style.height = 'auto';
    this._textarea.style.overflowY = 'hidden';
  };

  private _onKeydown = (e: KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      this._onSubmit(e);
    }
  };

  private _onInput() {
    const el = this._textarea;
    el.style.overflowY = 'hidden';
    el.style.height = 'auto';
    el.style.height = `${el.scrollHeight}px`;
    const maxHeight = parseFloat(getComputedStyle(el).maxHeight);
    if (el.scrollHeight > maxHeight) {
      el.style.overflowY = 'scroll';
    }
  }

  render() {
    return html`
      <footer class="chat-footer">
        <form class="chat-form" @submit=${this._onSubmit}>
          <textarea 
            id="yalo-chat-input"
            class="chat-input"
            rows="1"
            @input=${this._onInput}
            @keydown=${this._onKeydown}
          ></textarea>
          <button class="chat-send-button">
            ${unsafeHTML(this.config.icons?.send)}
          </button>
        </form>
      </footer>
    `;
  }
}
