// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';

@customElement('image-message')
export class ImageMessage extends LitElement {
  static styles = css`
    :host {
      display: block;
    }

    .image-bubble {
      border-radius: 1.125rem;
      overflow: hidden;
      min-height: 4rem;
      position: relative;
    }

    .image-bubble img {
      display: block;
      max-width: 100%;
      height: auto;
      object-fit: cover;
    }

    .image-bubble img.loading {
      visibility: hidden;
      position: absolute;
    }

    .image-caption {
      padding: 0.5rem 0.75rem;
      word-break: break-word;
      font-size: 0.875rem;
    }

    .loader {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 4rem;
      padding: 1rem;
    }

    .spinner {
      width: 1.5rem;
      height: 1.5rem;
      border: 3px solid var(--yalo-chat-spinner-color, #2207f1);
      border-bottom-color: transparent;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }

    @keyframes spin {
      to {
        transform: rotate(360deg);
      }
    }
  `;

  @property({ attribute: false })
  message!: ChatMessage;

  @state()
  private _loaded = false;

  @state()
  private _error = false;

  render() {
    const src = this.message.blob
      ? URL.createObjectURL(this.message.blob)
      : this.message.fileName ?? '';

    return html`
      <div class="image-bubble">
        ${!this._loaded && !this._error
          ? html`<div class="loader"><span class="spinner"></span></div>`
          : nothing}
        <img
          class=${this._loaded ? '' : 'loading'}
          src=${src}
          alt="Image message"
          @load=${() => { this._loaded = true; }}
          @error=${() => { this._error = true; this._loaded = true; }}
        />
        ${this.message.content
          ? html`<div class="image-caption">${this.message.content}</div>`
          : nothing}
      </div>
    `;
  }
}
