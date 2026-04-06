// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  type YaloChatClientConfig,
  yaloChatClientConfigContext,
} from '@domain/config/chat-config-context';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import { consume } from '@lit/context';
import { localized, msg } from '@lit/localize';
import { css, html, LitElement } from 'lit';
import { customElement, query, state } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import { keyed } from 'lit/directives/keyed.js';
import { ChatFooterController } from './chat-footer-controller';
import { AudioRecordingController } from './audio-recording-controller';
import { loggerContext, type Logger } from '@log/logger-context';

import '@ui/chat/waveform-painter/waveform-painter';

@customElement('chat-footer')
@localized()
export class ChatFooter extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-input-border: 1px solid #e8e8e8;
      --yalo-chat-input-border-radius: 25.5px;
      --yalo-chat-input-font-size: 16px;
      --yalo-chat-send-btn-background: #2207f1;
      --yalo-chat-send-btn-color: white;
      --yalo-chat-attachment-button-color: #7c8086;
    }

    .chat-form {
      display: flex;
      padding: 8px;
      gap: 1rem;
    }

    .chat-input-box {
      flex-grow: 1;
      border: var(--yalo-chat-input-border);
      border-radius: var(--yalo-chat-input-border-radius);
      padding: var(--yalo-chat-column-item-space);
    }

    .chat-input {
      font-size: var(--yalo-chat-input-font-size);
      line-height: 1.5;
      appearance: none;
      max-height: calc(1.5em * 3 + var(--yalo-chat-column-item-space) * 2);
      box-sizing: border-box;
      outline: none;
      font-family: inherit;
      resize: none;
      border: none;
      overflow-y: hidden;
      width: 100%;
    }

    .chat-action-button {
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

    .chat-action-button .icon-wrapper {
      display: flex;
      align-items: center;
      justify-content: center;
      animation: icon-swap 200ms ease-out;
    }

    @keyframes icon-swap {
      0% {
        transform: scale(0) rotate(-90deg);
        opacity: 0;
      }
      100% {
        transform: scale(1) rotate(0deg);
        opacity: 1;
      }
    }

    .material-symbols-outlined {
      font-size: 1.5rem;
      font-family: 'Material Symbols Outlined';
    }

    .chat-input-container {
      display: flex;
    }

    label[for='file-picker'] {
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      flex-shrink: 0;
      color: var(--yalo-chat-attachment-button-color);
      border-radius: 50%;
      transition: background 200ms ease;
    }

    label[for='file-picker']:hover {
      background: rgba(0, 0, 0, 0.06);
    }

    input[type='file'] {
      display: none;
    }
  `;

  @consume({ context: loggerContext })
  logger!: Logger;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @query('.chat-input')
  textArea!: HTMLTextAreaElement;

  @state()
  hasText = false;

  private _chatFootercontroller = new ChatFooterController(this);
  private _audioController = new AudioRecordingController(this);

  private _handleActionClick(e: Event) {
    if (this._audioController.status === 'recording') {
      this._handleSendVoiceMessage();
      return;
    }
    if (this.hasText) {
      this._chatFootercontroller.sendTextMessage(e);
    } else {
      this._audioController.startRecording();
    }
  }

  private async _handleSendVoiceMessage() {
    const result = await this._audioController.stopRecording();

    const voiceMessage = ChatMessage.voice({
      role: 'USER',
      timestamp: new Date(),
      fileName: `voice-${Date.now()}.webm`,
      amplitudes: result.amplitudes,
      duration: result.duration,
      blob: result.blob,
    });

    this.dispatchEvent(
      new CustomEvent('yalo-chat-send-voice-message', {
        detail: { message: voiceMessage, blob: result.blob },
        bubbles: true,
        composed: true,
      })
    );
  }

  private async _handleStopRecording() {
    await this._audioController.stopRecording();
  }

  private _handleFilePicked(e: Event) {
    const input = e.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;

    const isImage = file.type.startsWith('image/');
    const message = isImage
      ? ChatMessage.image({
          role: 'USER',
          timestamp: new Date(),
          fileName: file.name,
          content: '',
          byteCount: file.size,
          mediaType: file.type,
          blob: file,
        })
      : ChatMessage.attachment({
          role: 'USER',
          timestamp: new Date(),
          fileName: file.name,
          content: '',
          byteCount: file.size,
          mediaType: file.type,
          blob: file,
        });

    this.dispatchEvent(
      new CustomEvent(
        isImage
          ? 'yalo-chat-send-image-message'
          : 'yalo-chat-send-attachment-message',
        {
          detail: { message, file },
          bubbles: true,
          composed: true,
        }
      )
    );

    input.value = '';
  }

  render() {
    const shouldShowSend =
      this.hasText || this._audioController.status === 'recording';
    return html`
      <footer class="chat-footer">
        <form
          class="chat-form"
          @submit=${(e: Event) => this._chatFootercontroller.sendTextMessage(e)}
        >
          <div class="chat-input-box">
            ${this._audioController.status === 'recording'
              ? html`<waveform-recorder
                  time=${this._audioController.formatTime(
                    this._audioController.elapsedMs
                  )}
                  .amplitudes=${this._audioController.amplitudes}
                  @yalo-chat-stop-voice-message=${() =>
                    this._handleStopRecording()}
                ></waveform-recorder>`
              : html` <div class="chat-input-container">
                  <textarea
                    id="yalo-chat-input"
                    class="chat-input"
                    rows="1"
                    placeholder="${msg('Write a message...')}"
                    @input=${() => this._chatFootercontroller.handleOnInput()}
                    @keydown=${(e: KeyboardEvent) =>
                      this._chatFootercontroller.handleOnKeyDown(e)}
                  ></textarea>
                  <label for="file-picker">
                    ${unsafeHTML(this.config.icons?.attachment)}
                  </label>
                  <input
                    id="file-picker"
                    type="file"
                    class="attachment-button"
                    accept="image/*,.pdf"
                    @change=${(e: Event) => this._handleFilePicked(e)}
                  />
                </div>`}
          </div>
          <button
            class="chat-action-button"
            type="button"
            @click=${(e: Event) => this._handleActionClick(e)}
          >
            ${keyed(
              shouldShowSend ? 'send' : 'mic',
              html`<span class="icon-wrapper"
                >${unsafeHTML(
                  shouldShowSend
                    ? this.config.icons?.send
                    : this.config.icons?.mic
                )}</span
              >`
            )}
          </button>
        </form>
      </footer>
    `;
  }
}
