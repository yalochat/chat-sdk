// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import '@ui/chat/waveform-painter/waveform-painter';

@customElement('voice-message')
export class VoiceMessage extends LitElement {
  static styles = css`
    :host {
      display: block;
    }

    .voice-container {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .play-button {
      appearance: none;
      border: none;
      outline: none;
      background: none;
      color: var(--yalo-chat-play-button-color, #7c8086);
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0;
      flex-shrink: 0;
    }

    .material-symbols-outlined {
      font-size: 1.5rem;
      font-family: 'Material Symbols Outlined';
    }

    waveform-recorder {
      flex-grow: 1;
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ attribute: false })
  message!: ChatMessage;

  @state()
  private _playing = false;

  private _audio: HTMLAudioElement | null = null;

  private _togglePlayback() {
    if (this._playing) {
      this._audio?.pause();
      this._playing = false;
      return;
    }

    if (!this._audio) {
      const src = this.message.blob
        ? URL.createObjectURL(this.message.blob)
        : this.message.content || this.message.fileName || '';
      if (!src) return;
      this._audio = new Audio(src);
      this._audio.addEventListener('ended', () => {
        this._playing = false;
      });
    }

    this._audio.play();
    this._playing = true;
  }

  disconnectedCallback(): void {
    super.disconnectedCallback();
    this._audio?.pause();
    this._audio = null;
  }

  render() {
    return html`
      <div class="voice-container">
        <button
          class="play-button"
          type="button"
          @click=${() => this._togglePlayback()}
        >
          ${unsafeHTML(
            this._playing ? this.config.icons?.pause : this.config.icons?.play
          )}
        </button>
        <waveform-recorder
          .amplitudes=${this.message.amplitudes ?? []}
          .animated=${false}
        ></waveform-recorder>
      </div>
    `;
  }
}
