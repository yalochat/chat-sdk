// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type { RegisteredCommandHandler } from '@domain/models/command/channel-command';
import { registeredCommandsContext } from '@domain/models/command/registered-commands-context';
import { css, html, LitElement, nothing, type PropertyValues } from 'lit';
import { customElement, property } from 'lit/decorators.js';

import '@ui/chat/chat-header/chat-header';
import '@ui/chat/chat-footer/chat-footer';
import '@ui/chat/chat-message-list/chat-message-list';
import {
  type ChatMessageRepository,
  chatMessageRepositoryContext,
} from '@data/repositories/chat-message/chat-message-repository-context';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { provide } from '@lit/context';
import Logger from '@log/logger';
import { loggerContext } from '@log/logger-context';
import YaloChatWindowController from './yalo-chat-window-controller';

import {
  type YaloMessageRepository,
  yaloMessageRepositoryContext,
} from '@data/repositories/yalo-message/yalo-message-repository-context';
import {
  type YaloMediaService,
  yaloMediaServiceContext,
} from '@data/services/yalo-media/yalo-media-service-context';
import { setLocale } from '@i18n/index';

@customElement('yalo-chat-window')
export class YaloChatWindow extends LitElement {
  static styles = css`
    :host {
      display: none;
      width: var(--yalo-chat-width, auto);
      height: var(--yalo-chat-height, auto);
    }

    :host([open]) {
      display: block;
    }

    .chat-window {
      width: 100%;
      height: 100%;
      background: var(--yalo-chat-background, #ffffff);
      border-radius: var(--yalo-chat-corner-radius, 12px);
      font-family: var(--yalo-chat-font, sans-serif);
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }

    .chat-body {
      flex: 1;
      overflow-y: auto;
      display: flex;
    }
  `;

  @property({ type: Boolean, reflect: true })
  open: boolean = false;

  @property({ attribute: false })
  openContext?: Record<string, unknown>;

  @property({ attribute: false })
  @provide({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @provide({ context: loggerContext })
  logger: Logger = new Logger();

  @provide({ context: chatMessageRepositoryContext })
  chatMessageRepository!: ChatMessageRepository;

  @provide({ context: yaloMessageRepositoryContext })
  yaloMessageRepository!: YaloMessageRepository;

  @provide({ context: yaloMediaServiceContext })
  yaloMediaService!: YaloMediaService;

  @property({ attribute: false })
  @provide({ context: registeredCommandsContext })
  commands = new Map<string, RegisteredCommandHandler>();

  private _chatWindowController = new YaloChatWindowController(this);

  firstUpdated(): void {
    setLocale(this.config.locale || 'en');
  }

  updated(changed: PropertyValues<this>): void {
    if (changed.has('open') && this.open) {
      this._chatWindowController.requestGuidanceCardIfEmpty();
    }
  }

  private _handleClose = () => {
    this.open = false;
    this.dispatchEvent(
      new Event('yalo-chat-close', { bubbles: true, composed: true })
    );
  };

  render() {
    return html`
      <div class="chat-window">
        ${this.config.hideHeader
          ? nothing
          : html`<yalo-chat-header
              .statusMessage=${this._chatWindowController.chatStatusText}
              @close=${this._handleClose}
            >
            </yalo-chat-header>`}
        <main class="chat-body">
          <yalo-chat-message-list
            .chatMessages=${this._chatWindowController.chatMessages}
            .isLoading=${this._chatWindowController.isLoadingMessages}
            .isWriting=${this._chatWindowController.isWriting}
            @yalo-chat-fetch-next-page=${() =>
              this._chatWindowController.fetchNextPage()}
            @yalo-chat-send-text-message=${(e: CustomEvent) =>
              this._chatWindowController.sendTextMessage(e)}
            @yalo-chat-retry-message=${(e: CustomEvent) =>
              this._chatWindowController.retryMessage(e)}
            @yalo-chat-product-quantity-change=${(e: CustomEvent) =>
              this._chatWindowController.updateProductQuantity(e)}
            @yalo-chat-product-add-to-cart=${(e: CustomEvent) =>
              this._chatWindowController.markProductAddedToCart(e)}
            @yalo-chat-product-confirmation-clicked=${(e: CustomEvent) =>
              this._chatWindowController.markProductConfirmationClicked(e)}
            @yalo-chat-go-to-cart=${() => this._chatWindowController.goToCart()}
          >
          </yalo-chat-message-list>
        </main>
        <yalo-chat-footer
          @yalo-chat-send-text-message=${(e: CustomEvent) =>
            this._chatWindowController.sendTextMessage(e)}
          @yalo-chat-send-voice-message=${(e: CustomEvent) =>
            this._chatWindowController.sendVoiceMessage(e)}
          @yalo-chat-send-image-message=${(e: CustomEvent) =>
            this._chatWindowController.sendImageMessage(e)}
          @yalo-chat-send-attachment-message=${(e: CustomEvent) =>
            this._chatWindowController.sendAttachmentMessage(e)}
        >
        </yalo-chat-footer>
      </div>
    `;
  }
}
