// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { css, html, LitElement, nothing, type PropertyValues } from 'lit';
import { customElement, property, query } from 'lit/decorators.js';
import { repeat } from 'lit/directives/repeat.js';
import { loggerContext, type Logger } from '@log/logger-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import ChatMessageListController from './chat-message-list-controller';
import './user-message';
import './assistant-message';

@customElement('chat-message-list')
export default class ChatMessageList extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-user-message-background: #f9fafc;
      --yalo-chat-spinner-color: #2207f1;
      --yalo-chat-dot-color: #2207f1;
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
      padding-left: 0.5rem;
    }

    .bubble {
      max-width: 70%;
      padding: 0.5rem 0.75rem;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      background: var(--yalo-chat-user-message-background);
      word-break: break-word;
    }

    .loader {
      display: flex;
      justify-content: center;
      padding: 0.5rem;
      height: 48px;
    }

    .spinner {
      width: 48px;
      height: 48px;
      border: 5px solid var(--yalo-chat-spinner-color);
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
      padding-left: 1rem;
    }

    .dot-loader {
      width: 30px;
      aspect-ratio: 2;
      --_g: no-repeat
        radial-gradient(
          circle closest-side,
          var(--yalo-chat-dot-color) 90%,
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
    return html`
      <ul class="message-list">
        ${this.isWriting
          ? html` <li class="writing-loader">
              <span class="dot-loader"></span>
            </li>`
          : nothing}
        ${repeat(
          this.chatMessages,
          (chatMessage) => chatMessage.id,
          (chatMessage) => {
            const isUser = chatMessage.role === 'USER';
            return html`
              <li
                class="chat-message ${isUser
                  ? 'user-message'
                  : 'agent-message'}"
              >
                ${isUser
                  ? html`<user-message .message=${chatMessage}></user-message>`
                  : html`<assistant-message
                      .message=${chatMessage}
                    ></assistant-message>`}
              </li>
            `;
          }
        )}
        <li class="loader"></li>
      </ul>
    `;
  }
}
