// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { css, html, LitElement, nothing, type PropertyValues } from 'lit';
import { customElement, property, query } from 'lit/decorators.js';
import { repeat } from 'lit/directives/repeat.js';
import { localized, msg } from '@lit/localize';
import { loggerContext, type Logger } from '@log/logger-context';
import type {
  ChatMessage,
  MessageButton,
} from '@domain/models/chat-message/chat-message';
import ChatMessageListController from './chat-message-list-controller';
import './user-message';
import './assistant-message';
import './chat-quick-replies';
import './message-avatar';

@customElement('yalo-chat-message-list')
@localized()
export default class ChatMessageList extends LitElement {
  static styles = css`
    :host {
      width: 100%;
      display: flex;
      flex-direction: column;
    }

    .message-list {
      flex: 1;
      margin: 0;
      padding: 0;
      overflow-y: auto;
      display: flex;
      flex-direction: column-reverse;
      overflow-anchor: none;
      scrollbar-color: var(--yalo-chat-message-list-scrollbar-color, #bdbdbd)
        var(--yalo-chat-message-list-scrollbar-track-color, transparent);
    }

    .message-list::-webkit-scrollbar {
      width: 0.375em;
    }

    .message-list::-webkit-scrollbar-track {
      background: var(
        --yalo-chat-message-list-scrollbar-track-color,
        transparent
      );
    }

    .message-list::-webkit-scrollbar-thumb {
      background: var(--yalo-chat-message-list-scrollbar-color, #bdbdbd);
      border-radius: 1rem;
    }

    .chat-message {
      display: flex;
      margin: 0.25rem 0.5rem;
    }

    .user-message {
      justify-content: flex-end;
    }

    .agent-message {
      justify-content: flex-start;
      display: flow;
    }

    .welcome-image {
      display: flex;
      justify-content: center;
      margin-bottom: 0.5rem;
    }

    .welcome-image img {
      width: var(--yalo-chat-welcome-image-width, 3rem);
      height: var(--yalo-chat-welcome-image-height, auto);
    }

    .bubble {
      max-width: 70%;
      padding: 0.5rem 0.75rem;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      background: var(--yalo-chat-user-message-background, #f9fafc);
      word-break: break-word;
    }

    .loader {
      display: flex;
      justify-content: center;
      padding: 0.5rem;
      height: 48px;
      margin: var(--yalo-chat-loader-margin, 0);
    }

    .spinner {
      width: 48px;
      height: 48px;
      border: 5px solid var(--yalo-chat-spinner-color, #2207f1);
      border-bottom-color: transparent;
      border-radius: 50%;
      display: inline-block;
      box-sizing: border-box;
      animation: rotation 1s linear infinite;
    }

    @keyframes rotation {
      0% {
        transform: rotate(0deg);
      }
      100% {
        transform: rotate(360deg);
      }
    }

    .writing-loader {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding-left: 1rem;
      margin: var(--yalo-chat-writing-loader-margin, 0);
    }

    /* Drawn like an assistant message bubble, so a theme that styles
       those styles the typing indicator too. */
    .writing-bubble {
      display: flex;
      align-items: center;
      padding: var(--yalo-chat-assistant-message-bubble-padding, 0);
      background: var(--yalo-chat-assistant-message-background, transparent);
      border: var(--yalo-chat-assistant-message-border, none);
      border-radius: var(--yalo-chat-assistant-message-border-radius, 0);
    }

    .writing-loader.with-avatar {
      padding-left: 0.5rem;
    }

    .writing-loader.avatar-below {
      align-items: flex-end;
    }

    .writing-loader.avatar-below > :last-child {
      margin-bottom: var(--yalo-chat-avatar-size, 2rem);
    }

    .writing-loader.leaving {
      animation: writing-fade-out 220ms ease-out forwards;
    }

    .writing-text {
      color: var(--yalo-chat-dot-color, #2207f1);
      font-size: 0.875rem;
    }

    .writing-token {
      opacity: 0;
      animation: writing-token-fade-in 180ms ease-out forwards;
      animation-delay: calc(var(--_token-index) * 25ms);
    }

    .visually-hidden {
      position: absolute;
      width: 1px;
      height: 1px;
      overflow: hidden;
      clip-path: inset(50%);
      white-space: nowrap;
    }

    @keyframes writing-token-fade-in {
      to {
        opacity: 1;
      }
    }

    @keyframes writing-fade-out {
      to {
        opacity: 0;
      }
    }

    @media (prefers-reduced-motion: reduce) {
      .writing-loader.leaving,
      .writing-token {
        animation: none;
        opacity: 1;
      }
    }

    .dot-loader {
      width: 30px;
      aspect-ratio: 2;
      --_g: no-repeat
        radial-gradient(
          circle closest-side,
          var(--yalo-chat-dot-color, #2207f1) 90%,
          #0000
        );
      background:
        var(--_g) 0% 50%,
        var(--_g) 50% 50%,
        var(--_g) 100% 50%;
      background-size: calc(100% / 3) 50%;
      animation: l3 1s infinite linear;
    }
    @keyframes l3 {
      20% {
        background-position:
          0% 0%,
          50% 50%,
          100% 50%;
      }
      40% {
        background-position:
          0% 100%,
          50% 0%,
          100% 50%;
      }
      60% {
        background-position:
          0% 50%,
          50% 100%,
          100% 0%;
      }
      80% {
        background-position:
          0% 50%,
          50% 50%,
          100% 100%;
      }
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @consume({ context: loggerContext })
  logger!: Logger;

  @property({ attribute: false })
  chatMessages: Array<ChatMessage> = [];

  @property({ type: Boolean })
  isLoading: boolean = false;

  @property({ type: Boolean })
  isWriting: boolean = false;

  @query('.message-list')
  messageList!: HTMLUListElement;

  @query('.loader')
  loader!: HTMLLIElement;

  private _chatMessageListController = new ChatMessageListController(this);

  connectedCallback() {
    super.connectedCallback();
  }

  updated(changedProperties: PropertyValues<this>): void {
    this._chatMessageListController.calculateScroll(changedProperties);
  }

  render() {
    const isInlineQuickReplies = this.config.quickReplyType === 'inline';
    const hasUserMessage = this.chatMessages.some(
      (message) => message.role === 'USER'
    );
    const showWelcomeOnly =
      this.config.welcomeMessageType === 'verticalQuickReplies' &&
      !hasUserMessage &&
      this.chatMessages.length === 1;

    // Newest first, so this is the person's first message. Only replies after
    // it can be rated, which keeps the welcome message free of feedback.
    const firstUserMessageIndex = this.chatMessages.findLastIndex(
      (message) => message.role === 'USER'
    );

    let quickReplies: MessageButton[] = [];
    let latestReplyMessageId: ChatMessage['id'];
    for (const message of this.chatMessages) {
      if (message.role === 'USER') {
        break;
      }
      const replies = message.buttons.filter(
        (button) => button.type === 'reply'
      );
      if (replies.length > 0) {
        quickReplies = replies;
        latestReplyMessageId = message.id;
        break;
      }
    }

    const writingAvatar = this._chatMessageListController.writingAvatar;
    const writingText =
      this.config.texts?.writingIndicator ?? msg('Writing...');

    return html`
      <ul class="message-list">
        ${this.isWriting || this._chatMessageListController.isWritingLeaving
          ? html` <li
              class="writing-loader ${this.isWriting
                ? ''
                : 'leaving'} ${writingAvatar
                ? 'with-avatar'
                : ''} ${writingAvatar &&
              this.config.typingIndicatorAvatarPosition === 'below'
                ? 'avatar-below'
                : ''}"
              role="status"
            >
              ${writingAvatar
                ? html`<yalo-chat-message-avatar
                    sender="assistant"
                    .avatar=${writingAvatar}
                  ></yalo-chat-message-avatar>`
                : nothing}
              <div class="writing-bubble">
                ${this.config.typingIndicatorType === 'text'
                  ? html`<span class="writing-text"
                      ><span class="visually-hidden">${writingText}</span
                      >${Array.from(writingText).map(
                        (token, index) =>
                          html`<span
                            class="writing-token"
                            aria-hidden="true"
                            style="--_token-index: ${index}"
                            >${token}</span
                          >`
                      )}</span
                    >`
                  : html`<span class="dot-loader"></span>`}
              </div>
            </li>`
          : nothing}
        ${repeat(
          this.chatMessages,
          (chatMessage) => chatMessage.id,
          (chatMessage, index) => {
            const isUser = chatMessage.role === 'USER';
            return html`
              <li
                class="chat-message ${isUser
                  ? 'user-message'
                  : 'agent-message'}"
              >
                ${showWelcomeOnly && this.config.image != null
                  ? html`<div class="welcome-image">
                      <img src=${this.config.image} alt="" />
                    </div>`
                  : nothing}
                ${isUser
                  ? html`<yalo-chat-user-message
                      .message=${chatMessage}
                      .showAvatar=${this._chatMessageListController.showsAvatar(
                        index
                      )}
                    ></yalo-chat-user-message>`
                  : html`<yalo-chat-assistant-message
                      .message=${chatMessage}
                      .showInlineReplies=${showWelcomeOnly ||
                      chatMessage.id === latestReplyMessageId}
                      .centered=${showWelcomeOnly}
                      .showFeedback=${index < firstUserMessageIndex}
                      .showAvatar=${this._chatMessageListController.showsAvatar(
                        index
                      )}
                    ></yalo-chat-assistant-message>`}
              </li>
            `;
          }
        )}
        <li class="loader"></li>
      </ul>
      ${isInlineQuickReplies || showWelcomeOnly
        ? nothing
        : html`<yalo-chat-quick-replies
            .replies=${quickReplies}
          ></yalo-chat-quick-replies>`}
    `;
  }
}
