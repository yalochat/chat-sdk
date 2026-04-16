// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { css, html, LitElement } from 'lit';
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
      --yalo-chat-background: #ffffff;
      --yalo-chat-corner-radius: 12px;
      --yalo-chat-font: sans-serif;
      --yalo-chat-column-item-space: 8px;
      --yalo-chat-row-item-space: 8px;

      display: none;
      position: fixed;
      bottom: var(--yalo-chat-inset-bottom, 80px);
      right: var(--yalo-chat-inset-right, 24px);
      z-index: 9999;
    }

    :host([open]) {
      display: block;
    }

    .chat-window {
      width: 500px;
      height: 720px;
      background: var(--yalo-chat-background);
      border-radius: var(--yalo-chat-corner-radius);
      font-family: var(--yalo-chat-font);
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
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

  private _chatWindowController = new YaloChatWindowController(this);

  firstUpdated(): void {
    setLocale(this.config.locale || 'en');
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
        <chat-header @close=${this._handleClose}> </chat-header>
        <main class="chat-body">
          <chat-message-list
            .chatMessages=${this._chatWindowController.chatMessages}
            .isLoading=${this._chatWindowController.isLoadingMessages}
            .isWriting=${this._chatWindowController.isWriting}
            @yalo-chat-fetch-next-page=${() =>
              this._chatWindowController.fetchNextPage()}
            @yalo-chat-send-text-message=${(e: CustomEvent) =>
              this._chatWindowController.sendTextMessage(e)}
          >
          </chat-message-list>
        </main>
        <chat-footer
          @yalo-chat-send-text-message=${(e: CustomEvent) =>
            this._chatWindowController.sendTextMessage(e)}
          @yalo-chat-send-voice-message=${(e: CustomEvent) =>
            this._chatWindowController.sendVoiceMessage(e)}
          @yalo-chat-send-image-message=${(e: CustomEvent) =>
            this._chatWindowController.sendImageMessage(e)}
          @yalo-chat-send-attachment-message=${(e: CustomEvent) =>
            this._chatWindowController.sendAttachmentMessage(e)}
        >
        </chat-footer>
      </div>
    `;
  }
}
