// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import {
  YaloChatClient,
  IdbService,
  AudioServiceWeb,
  CameraServiceWeb,
  ChatMessageRepositoryIdb,
  YaloMessageRepositoryRemote,
  ImageRepositoryWeb,
  AudioRepositoryWeb,
  ChatStore,
  AudioStore,
  ImageStore,
} from '@yalo/chat-sdk-core';
import type { ChatTheme } from '../theme/chat-theme.js';
import { applyTheme, defaultChatTheme } from '../theme/chat-theme.js';
import './chat-app-bar.js';
import './message-list.js';
import './chat-input/chat-input.js';

/**
 * <yalo-chat> — Root web component.
 *
 * Usage:
 * ```html
 * <yalo-chat
 *   name="John"
 *   flow-key="abc"
 *   user-token="xyz"
 *   auth-token="Bearer ..."
 *   chat-base-url="https://api.yalo.com"
 *   show-attachment-button="true"
 * ></yalo-chat>
 * <script>
 *   const chat = document.querySelector('yalo-chat');
 *   chat.theme = { sendButtonColor: '#2207F1' };
 *   chat.addEventListener('shop-pressed', () => {});
 * </script>
 * ```
 */
@customElement('yalo-chat')
export class YaloChat extends LitElement {
  // ── Attributes / properties ───────────────────────────────────────────────
  @property({ type: String }) name = '';
  @property({ type: String, attribute: 'flow-key' }) flowKey = '';
  @property({ type: String, attribute: 'user-token' }) userToken = '';
  @property({ type: String, attribute: 'auth-token' }) authToken = '';
  @property({ type: String, attribute: 'chat-base-url' }) chatBaseUrl = '';
  @property({ type: Boolean, attribute: 'show-attachment-button' }) showAttachmentButton = true;
  @property({ type: Boolean, attribute: 'show-shop-button' }) showShopButton = false;
  @property({ type: Boolean, attribute: 'show-cart-button' }) showCartButton = false;
  @property({ attribute: false })
  set theme(val: Partial<ChatTheme>) {
    this._theme = { ...defaultChatTheme, ...val };
    applyTheme(this._theme, this);
    this.requestUpdate('theme');
  }
  get theme(): ChatTheme { return this._theme; }

  @state() private _theme: ChatTheme = defaultChatTheme;
  @state() private _ready = false;

  private _chatStore?: ChatStore;
  private _audioStore?: AudioStore;
  private _imageStore?: ImageStore;

  static styles = css`
    :host {
      display: flex;
      flex-direction: column;
      background: var(--yalo-bg-color, #FFFFFF);
      height: 100%;
      font-family: system-ui, -apple-system, sans-serif;
      overflow: hidden;
    }
    yalo-message-list {
      flex: 1;
      min-height: 0;
      overflow: hidden;
    }
    .error {
      padding: 16px;
      color: red;
      font-size: 14px;
    }
  `;

  connectedCallback() {
    super.connectedCallback();
    applyTheme(this._theme, this);
    this._init();
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this._chatStore?.dispose();
  }

  private async _init() {
    if (!this.chatBaseUrl || !this.flowKey || !this.userToken) {
      console.warn('[yalo-chat] Missing required attributes: chat-base-url, flow-key, user-token');
      this._ready = true;
      return;
    }

    const client = new YaloChatClient({
      name: this.name,
      flowKey: this.flowKey,
      userToken: this.userToken,
      authToken: this.authToken,
      chatBaseUrl: this.chatBaseUrl,
    });

    const idb = new IdbService();
    const audioService = new AudioServiceWeb();
    const cameraService = new CameraServiceWeb();

    const chatMessageRepo = new ChatMessageRepositoryIdb(idb);
    const yaloMessageRepo = new YaloMessageRepositoryRemote(client);
    const imageRepo = new ImageRepositoryWeb(cameraService);
    const audioRepo = new AudioRepositoryWeb(audioService);

    this._chatStore = new ChatStore({
      chatMessageRepository: chatMessageRepo,
      yaloMessageRepository: yaloMessageRepo,
      imageRepository: imageRepo,
      name: this.name,
    });
    this._audioStore = new AudioStore(audioRepo);
    this._imageStore = new ImageStore(imageRepo);

    await this._chatStore.initialize();
    this._ready = true;
  }

  render() {
    if (!this._ready) {
      return html``;
    }

    if (!this._chatStore || !this._audioStore || !this._imageStore) {
      return html`<div class="error">Missing required attributes.</div>`;
    }

    return html`
      <yalo-chat-app-bar
        .title=${this._chatStore.state.chatTitle || this.name}
        .isTyping=${this._chatStore.state.isSystemTypingMessage}
        .typingText=${this._chatStore.state.chatStatusText}
        .showShopButton=${this.showShopButton}
        .showCartButton=${this.showCartButton}
        @shop-pressed=${() => this.dispatchEvent(new CustomEvent('shop-pressed', { bubbles: true }))}
        @cart-pressed=${() => this.dispatchEvent(new CustomEvent('cart-pressed', { bubbles: true }))}
      ></yalo-chat-app-bar>

      <yalo-message-list .store=${this._chatStore}></yalo-message-list>

      <yalo-chat-input
        .chatStore=${this._chatStore}
        .audioStore=${this._audioStore}
        .imageStore=${this._imageStore}
        .showAttachmentButton=${this.showAttachmentButton}
      ></yalo-chat-input>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-chat': YaloChat;
  }
}
