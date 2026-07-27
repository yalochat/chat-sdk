// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import AssistantMessageController from './assistant-message-controller';
import { renderMarkdown } from './render-markdown';
import './attachment-message';
import './image-message';
import './product-confirmation-message';
import './product-message';
import './video-message';
import './voice-message';

@customElement('yalo-chat-assistant-message')
export class AssistantMessage extends LitElement {
  static styles = css`
    :host {
      display: flow;
      justify-content: flex-start;
      margin: 0.25rem 0.5rem;
      padding: var(--yalo-chat-assistant-message-padding, 0 0 0 0.5rem);
      color: var(--yalo-chat-assistant-message-color, #181818);
      animation: yalo-chat-assistant-message-appear
        var(--yalo-chat-message-appear-duration, 0.3s) ease;
    }

    @keyframes yalo-chat-assistant-message-appear {
      from {
        opacity: 0;
        transform: translateY(0.5rem);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    @media (prefers-reduced-motion: reduce) {
      :host {
        animation: none;
      }
    }

    p {
      margin: 0;
      word-break: break-word;
      font-size: var(--yalo-chat-assistant-message-font-size, 1rem);
      font-weight: var(--yalo-chat-assistant-message-font-weight, normal);
      padding: var(--yalo-chat-assistant-message-bubble-padding, 0);
      background: var(--yalo-chat-assistant-message-background, transparent);
      border: var(--yalo-chat-assistant-message-border, none);
      border-radius: var(--yalo-chat-assistant-message-border-radius, 0);
    }

    a {
      color: var(--yalo-chat-link-button-color, #2207f1);
    }

    .voice-bubble {
      max-width: 90%;
    }

    .image-bubble,
    .video-bubble {
      max-width: 90%;
      border-radius: 1.125rem;
      border-bottom-left-radius: 0.25rem;
      overflow: hidden;
    }

    .attachment-bubble {
      max-width: 90%;
    }

    .product-bubble {
      width: 100%;
      max-width: 100%;
    }

    .header {
      font-weight: var(--yalo-chat-message-header-font-weight, bold);
      margin-bottom: 0.25rem;
      word-break: break-word;
    }

    .footer {
      color: var(--yalo-chat-message-footer-color, #7c8086);
      font-size: var(--yalo-chat-message-footer-font-size, 0.75em);
      margin-top: 0.25rem;
      word-break: break-word;
    }

    .buttons {
      display: flex;
      flex-direction: column;
      gap: var(--yalo-chat-buttons-gap, 0.5rem);
      margin-top: 0.5rem;
    }

    .buttons button,
    .buttons a {
      padding: var(--yalo-chat-buttons-padding, 0.5rem);
      border: 1px solid var(--yalo-chat-buttons-border-color, #9db1c8);
      border-radius: var(--yalo-chat-buttons-border-radius, 0.5rem);
      background: var(--yalo-chat-buttons-background, transparent);
      color: var(--yalo-chat-buttons-color, #111111);
      font-size: var(--yalo-chat-buttons-font-size, 0.875rem);
      cursor: pointer;
      word-break: break-word;
    }

    .buttons a {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      text-align: center;
      text-decoration: none;
    }

    .buttons .arrow {
      display: flex;
      align-items: center;
      flex-shrink: 0;
      font-size: 1rem;
    }

    .yalo-icon {
      font-size: var(--yalo-chat-assistant-message-icon-font-size, 1rem);
      font-family: var(
        --yalo-chat-icon-font-family,
        'Material Symbols Outlined'
      );
      font-weight: var(--yalo-chat-icon-font-weight, normal);
      line-height: 1;
      font-feature-settings: 'liga';
    }

    .yalo-icon[data-icon='arrow-forward']::before {
      content: var(--yalo-chat-icon-arrow-forward, 'arrow_forward');
    }

    .buttons button:hover,
    .buttons a:hover {
      background-color: var(--yalo-chat-buttons-hover-background, #dde4ec);
    }

    .chips-container {
      display: grid;
      grid-template-rows: 0fr;
      opacity: 0;
      transition:
        grid-template-rows
          var(--yalo-chat-quick-replies-animation-duration, 0.3s) ease,
        opacity var(--yalo-chat-quick-replies-animation-duration, 0.3s) ease;
    }

    .chips-container.open {
      grid-template-rows: 1fr;
      opacity: 1;
    }

    .chips-inner {
      overflow: hidden;
      min-height: 0;
    }

    .chips {
      display: flex;
      flex-wrap: wrap;
      justify-content: flex-start;
      gap: var(--yalo-chat-quick-replies-gap, 0.5rem);
      margin-top: 0.5rem;
    }

    .chips button {
      padding: var(--yalo-chat-quick-replies-chip-padding, 0.5rem 0.75rem);
      border: 1px solid
        var(--yalo-chat-quick-replies-chip-border-color, #9db1c8);
      border-radius: var(--yalo-chat-quick-replies-chip-border-radius, 1.125rem);
      background: var(--yalo-chat-quick-replies-chip-background, transparent);
      color: var(--yalo-chat-quick-replies-chip-color, #111111);
      font-size: var(--yalo-chat-quick-replies-chip-font-size, 0.875rem);
      font-weight: var(--yalo-chat-quick-replies-chip-font-weight, normal);
      cursor: pointer;
      word-break: break-word;
    }

    .chips button:hover {
      background-color: var(
        --yalo-chat-quick-replies-chip-hover-background,
        #dde4ec
      );
    }

    :host([centered]) {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-left: auto;
      margin-right: auto;
    }

    :host([centered]) .header,
    :host([centered]) p,
    :host([centered]) .footer,
    :host([centered]) .buttons {
      text-align: center;
      align-items: center;
    }

    :host([centered]) p {
      padding: var(--yalo-chat-vertical-quick-replies-message-bubble-padding, 0);
      background: var(
        --yalo-chat-vertical-quick-replies-message-background,
        transparent
      );
      border: var(--yalo-chat-vertical-quick-replies-message-border, none);
      border-radius: var(
        --yalo-chat-vertical-quick-replies-message-border-radius,
        0
      );
    }

    :host([centered]) .chips-container,
    :host([centered]) .chips {
      width: 100%;
    }

    :host([centered]) .chips {
      flex-direction: column;
      align-items: center;
    }

    :host([centered]) .chips button {
      width: 100%;
      max-width: var(--yalo-chat-vertical-quick-replies-chip-max-width, 20rem);
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  private _controller = new AssistantMessageController(this);

  @property({ attribute: false })
  message!: ChatMessage;

  @property({ type: Boolean })
  showInlineReplies = false;

  @property({ type: Boolean, reflect: true })
  centered = false;

  render() {
    let body;
    switch (this.message.type) {
      case 'voice':
        body = html`<div class="voice-bubble">
          <yalo-chat-voice-message .message=${this.message}></yalo-chat-voice-message>
        </div>`;
        break;
      case 'image':
        body = html`<div class="image-bubble">
          <yalo-chat-image-message .message=${this.message}></yalo-chat-image-message>
        </div>`;
        break;
      case 'video':
        body = html`<div class="video-bubble">
          <yalo-chat-video-message .message=${this.message}></yalo-chat-video-message>
        </div>`;
        break;
      case 'attachment':
        body = html`<div class="attachment-bubble">
          <yalo-chat-attachment-message .message=${this.message}></yalo-chat-attachment-message>
        </div>`;
        break;
      case 'product':
        body = html`<div class="product-bubble">
          <yalo-chat-product-message
            .message=${this.message}
            direction="vertical"
          ></yalo-chat-product-message>
        </div>`;
        break;
      case 'productCarousel':
        body = html`<div class="product-bubble">
          <yalo-chat-product-message
            .message=${this.message}
            direction="horizontal"
          ></yalo-chat-product-message>
        </div>`;
        break;
      case 'productConfirmation':
        return html`<yalo-chat-product-confirmation-message
          .message=${this.message}
        ></yalo-chat-product-confirmation-message>`;
      case 'text':
      default:
        body = html`<p>${renderMarkdown(this.message.content)}</p>`;
    }

    const buttons = this.message.buttons.filter(
      (button) => button.type !== 'reply'
    );
    const isInlineQuickReplies =
      this.config.quickReplyType === 'inline' || this.centered;
    const replies = isInlineQuickReplies
      ? this.message.buttons.filter((button) => button.type === 'reply')
      : [];
    const showReplies = this.showInlineReplies && replies.length > 0;

    return html`
      ${this.message.header
        ? html`<div class="header">${this.message.header}</div>`
        : null}
      ${body}
      ${this.message.footer
        ? html`<div class="footer">${this.message.footer}</div>`
        : null}
      ${buttons.length > 0
        ? html`<div class="buttons">
            ${buttons.map((button) =>
              button.type === 'link' && button.url
                ? html`<a
                    href=${button.url}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    ${button.text}
                    <span class="arrow">
                      <span
                        class="yalo-icon"
                        data-icon="arrow-forward"
                        aria-hidden="true"
                      ></span>
                    </span>
                  </a>`
                : html`<button
                    type="button"
                    @click=${() => this._controller.onReplyClick(button.text)}
                  >
                    ${button.text}
                  </button>`
            )}
          </div>`
        : null}
      ${replies.length > 0
        ? html`<div
            class="chips-container ${showReplies ? 'open' : ''}"
            aria-hidden=${!showReplies}
          >
            <div class="chips-inner">
              <div class="chips">
                ${replies.map(
                  (reply) => html`<button
                    type="button"
                    @click=${() => this._controller.onReplyClick(reply.text)}
                  >
                    ${reply.text}
                  </button>`
                )}
              </div>
            </div>
          </div>`
        : null}
    `;
  }
}
