// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  type YaloChatClientConfig,
  yaloChatClientConfigContext,
} from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { localized, msg } from '@lit/localize';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@localized()
@customElement('yalo-chat-header')
export class ChatHeader extends LitElement {
  static styles = css`
    .chat-header {
      display: var(--yalo-chat-header-display, flex);
      gap: 1rem;
      align-items: center;
      justify-content: space-between;
      padding: var(--yalo-chat-header-padding, 12px 16px);
      background: var(--yalo-chat-header-background, #f1f5fc);
      color: var(--yalo-chat-header-color, #010101);
      border-radius: var(--yalo-chat-header-border-radius, 0);
      border-top: var(
        --yalo-chat-header-border-top,
        var(--yalo-chat-header-border, none)
      );
      border-right: var(
        --yalo-chat-header-border-right,
        var(--yalo-chat-header-border, none)
      );
      border-bottom: var(
        --yalo-chat-header-border-bottom,
        var(--yalo-chat-header-border, none)
      );
      border-left: var(
        --yalo-chat-header-border-left,
        var(--yalo-chat-header-border, none)
      );
    }

    .chat-header-title-group {
      margin: 0;
      flex-grow: 1;
    }

    .chat-header-title {
      font-size: var(--yalo-chat-header-title-font-size, 1.2rem);
      padding: 0;
      margin: 0;
      font-weight: var(--yalo-chat-header-title-font-weight, 600);
    }

    .header-icon {
      width: var(--yalo-chat-header-icon-width, 3rem);
      height: var(--yalo-chat-header-icon-height, auto);
    }

    .chat-status {
      margin: 0;
      font-size: 0.8rem;
    }

    .yalo-watermark {
      margin: 0;
      font-size: var(--yalo-chat-header-watermark-font-size, 0.7rem);
      font-weight: var(--yalo-chat-header-watermark-font-weight, 400);
      color: var(--yalo-chat-header-watermark-color, #747474);
    }

    .yalo-watermark[data-position='header-left'] {
      text-align: left;
    }

    .yalo-watermark[data-position='header-right'] {
      text-align: right;
    }

    .yalo-watermark b {
      font-weight: var(--yalo-chat-header-watermark-brand-font-weight, 700);
    }

    .chat-close-btn {
      background: none;
      border: none;
      color: var(--yalo-chat-close-btn-color, #010101);
      cursor: pointer;
      padding: 4px;
      display: var(--yalo-chat-close-btn-display, flex);
      align-items: center;
      justify-content: center;
      border-radius: 4px;
      line-height: 1;
      font-size: 1.5rem;
    }

    .chat-close-btn:hover {
      background: color-mix(in srgb, currentColor 15%, transparent);
    }

    .yalo-icon {
      font-size: var(--yalo-chat-header-icon-font-size, 1.5rem);
      font-family: var(
        --yalo-chat-icon-font-family,
        'Material Symbols Outlined'
      );
      font-weight: var(--yalo-chat-icon-font-weight, normal);
      line-height: 1;
      font-feature-settings: 'liga';
    }

    .yalo-icon[data-icon='close']::before {
      content: var(--yalo-chat-icon-close, 'close');
    }

    .yalo-icon-img {
      width: var(--yalo-chat-header-icon-font-size, 1.5rem);
      height: var(--yalo-chat-header-icon-font-size, 1.5rem);
      object-fit: contain;
      vertical-align: middle;
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ attribute: false })
  statusMessage: string = '';

  private _handleClose = () => {
    this.dispatchEvent(new Event('close'));
  };

  render() {
    const watermarkPosition = this.config.yaloWatermark ?? 'header-left';
    return html`
      <header class="chat-header">
        ${this.config.image != null
          ? html`<img class="header-icon" src="${this.config.image}" />`
          : nothing}
        <hgroup class="chat-header-title-group">
          <h1 class="chat-header-title">${this.config.channelName}</h1>
          ${this.statusMessage !== ''
            ? html`<p class="chat-status">${this.statusMessage}</p>`
            : nothing}
          ${watermarkPosition === 'none'
            ? nothing
            : html`<p class="yalo-watermark" data-position=${watermarkPosition}>
                ${msg(html`By <b>Yalo</b>`)}
              </p>`}
        </hgroup>
        ${this.config.hideCloseButton
          ? nothing
          : html`<button
              class="chat-close-btn"
              aria-label="${msg(`Close Chat`)}"
              @click=${this._handleClose}
            >
              ${this.config?.icons?.close
                ? html`<img
                    class="yalo-icon-img"
                    src=${this.config.icons.close}
                    alt=""
                    aria-hidden="true"
                  />`
                : html`<span
                    class="yalo-icon"
                    data-icon="close"
                    aria-hidden="true"
                  ></span>`}
            </button>`}
      </header>
    `;
  }
}
