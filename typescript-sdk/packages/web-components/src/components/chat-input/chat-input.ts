// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import type { ChatStore, AudioStore, ImageStore } from '@yalo/chat-sdk-core';
import type { ChatState, AudioState, ImageState } from '@yalo/chat-sdk-core';
import { initialChatState } from '@yalo/chat-sdk-core';
import './quick-reply.js';
import './image-preview.js';
import './action-button.js';
import './attachment-button.js';
import './waveform-recorder.js';

@customElement('yalo-chat-input')
export class YaloChatInput extends LitElement {
  @property({ attribute: false }) chatStore!: ChatStore;
  @property({ attribute: false }) audioStore!: AudioStore;
  @property({ attribute: false }) imageStore!: ImageStore;
  @property({ type: Boolean }) showAttachmentButton = true;

  @state() private _chatState: ChatState = initialChatState();
  @state() private _audioState?: AudioState;
  @state() private _imageState?: ImageState;
  @state() private _attachmentOpen = false;

  private _chatHandler = (e: Event) => {
    this._chatState = (e as CustomEvent<ChatState>).detail;
  };
  private _audioHandler = (e: Event) => {
    this._audioState = (e as CustomEvent<AudioState>).detail;
  };
  private _imageHandler = (e: Event) => {
    this._imageState = (e as CustomEvent<ImageState>).detail;
  };

  connectedCallback() {
    super.connectedCallback();
    this.chatStore?.addEventListener('change', this._chatHandler);
    this.audioStore?.addEventListener('change', this._audioHandler);
    this.imageStore?.addEventListener('change', this._imageHandler);
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.chatStore?.removeEventListener('change', this._chatHandler);
    this.audioStore?.removeEventListener('change', this._audioHandler);
    this.imageStore?.removeEventListener('change', this._imageHandler);
  }

  static styles = css`
    :host { display: flex; flex-direction: column; }
    .input-row {
      display: flex;
      align-items: center;
      gap: 4px;
      padding: 6px 8px;
      border-top: 1px solid var(--yalo-input-border-color, #E8E8E8);
      background: var(--yalo-bg-color, #FFFFFF);
    }
    yalo-action-button {
      flex-shrink: 0;
    }
    .text-wrap {
      flex: 1;
      display: flex;
      align-items: center;
      background: var(--yalo-input-color, #FFFFFF);
      border: 1px solid var(--yalo-input-border-color, #E8E8E8);
      border-radius: 25px;
      padding: 6px 12px;
      max-height: 120px;
      overflow: hidden;
    }
    textarea {
      flex: 1;
      border: none;
      outline: none;
      resize: none;
      background: transparent;
      font-size: 14px;
      font-family: inherit;
      line-height: 1.4;
      max-height: 108px;
      overflow-y: auto;
      color: inherit;
    }
    textarea::placeholder { color: var(--yalo-hint-text-color, #BEBEBE); }
    .image-preview-wrap { padding: 6px 16px 0; }
  `;

  private async _sendText() {
    const text = this._chatState.userMessage.trim();
    if (!text) return;
    await this.chatStore.sendTextMessage(text);
  }

  private _onInput(e: InputEvent) {
    const text = (e.target as HTMLTextAreaElement).value;
    this.chatStore.updateUserMessage(text);
  }

  private _onKeyDown(e: KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      this._sendText();
    }
  }

  private async _toggleRecording() {
    if (this._audioState?.status === 'recording') {
      const audioData = await this.audioStore.stopRecording();
      if (audioData) {
        await this.chatStore.sendVoiceMessage({
          fileName: audioData.fileName,
          amplitudes: audioData.amplitudesFilePreview,
          duration: audioData.duration,
        });
      }
    } else {
      const fileName = `voice_${Date.now()}.webm`;
      await this.audioStore.startRecording(fileName);
    }
  }

  private async _cancelRecording() {
    const fileName = `voice_${Date.now()}.webm`;
    await this.audioStore.cancelRecording(fileName);
  }

  private async _pickImage() {
    this._attachmentOpen = false;
    await this.imageStore.pickImage();
  }

  private async _removeImage() {
    const path = this._imageState?.imageData?.path;
    if (path) await this.imageStore.deleteImage(path);
    else this.imageStore.clearImage();
  }

  private async _sendWithImage() {
    const imageData = this._imageState?.imageData;
    if (!imageData) return;
    const text = this._chatState.userMessage.trim();
    await this.chatStore.sendImageMessage(imageData.path, text || undefined);
    this.imageStore.clearImage();
    this.chatStore.updateUserMessage('');
  }

  private _onQuickReply(e: CustomEvent) {
    const reply = e.detail as string;
    this.chatStore.sendTextMessage(reply);
    this.chatStore.clearQuickReplies();
  }

  render() {
    const isRecording = this._audioState?.status === 'recording';
    const hasImage = this._imageState?.status === 'selected';
    const text = this._chatState.userMessage;
    const quickReplies = this._chatState.quickReplies;

    return html`
      ${quickReplies.length ? html`
        <yalo-quick-reply
          .replies=${quickReplies}
          @quick-reply-selected=${this._onQuickReply}
        ></yalo-quick-reply>
      ` : ''}

      ${hasImage && this._imageState?.imageData ? html`
        <div class="image-preview-wrap">
          <yalo-image-preview
            .src=${this._imageState.imageData.path}
            @remove=${this._removeImage}
          ></yalo-image-preview>
        </div>
      ` : ''}

      <div class="input-row">
        ${isRecording
          ? html`
            <yalo-waveform-recorder
              .amplitudes=${this._audioState?.amplitudes ?? []}
              .durationMs=${this._audioState?.durationMs ?? 0}
              .extraOffset=${44}
              @cancel=${this._cancelRecording}
            ></yalo-waveform-recorder>
            <yalo-action-button label="stop recording" primary @action=${this._toggleRecording}>⏹</yalo-action-button>
          `
          : html`
            ${this.showAttachmentButton ? html`
              <yalo-attachment-button
                .open=${this._attachmentOpen}
                @toggle=${() => { this._attachmentOpen = !this._attachmentOpen; }}
                @pick=${this._pickImage}
              ></yalo-attachment-button>
            ` : ''}

            <div class="text-wrap">
              <textarea
                rows="1"
                placeholder="Type a message..."
                .value=${text}
                @input=${this._onInput}
                @keydown=${this._onKeyDown}
              ></textarea>
            </div>

            ${hasImage
              ? html`<yalo-action-button label="send" primary @action=${this._sendWithImage}>➤</yalo-action-button>`
              : text.trim()
                ? html`<yalo-action-button label="send" primary @action=${this._sendText}>➤</yalo-action-button>`
                : html`<yalo-action-button label="record audio" @action=${this._toggleRecording}>🎤</yalo-action-button>`
            }
          `}
      </div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-chat-input': YaloChatInput;
  }
}
