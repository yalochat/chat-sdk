// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import '@ui/chat/waveform-painter/waveform-painter';

@customElement('yalo-chat-voice-message')
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

    .yalo-icon {
      font-size: var(--yalo-chat-voice-message-icon-font-size, 1.5rem);
      font-family: var(
        --yalo-chat-icon-font-family,
        'Material Symbols Outlined'
      );
      line-height: 1;
      font-feature-settings: 'liga';
    }

    .yalo-icon[data-icon='play']::before {
      content: var(--yalo-chat-icon-play, 'play_arrow');
    }
    .yalo-icon[data-icon='pause']::before {
      content: var(--yalo-chat-icon-pause, 'pause');
    }

    yalo-chat-waveform-recorder {
      flex-grow: 1;
    }
  `;

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
          <span
            class="yalo-icon"
            data-icon=${this._playing ? 'pause' : 'play'}
            aria-hidden="true"
          ></span>
        </button>
        <yalo-chat-waveform-recorder
          .amplitudes=${this.message.amplitudes ?? []}
          .animated=${false}
        ></yalo-chat-waveform-recorder>
      </div>
    `;
  }
}
