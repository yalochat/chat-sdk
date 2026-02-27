// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';

@customElement('yalo-user-voice-message')
export class YaloUserVoiceMessage extends LitElement {
  @property({ type: String }) fileName = '';
  @property({ type: Array }) amplitudes: number[] = [];
  @property({ type: Number }) duration = 0;

  @state() private _playing = false;
  @state() private _elapsed = 0;
  private _audio?: HTMLAudioElement;
  private _interval?: ReturnType<typeof setInterval>;

  static styles = css`
    :host { display: flex; justify-content: flex-end; }
    .bubble {
      display: flex;
      align-items: center;
      gap: 8px;
      background: var(--yalo-user-msg-color, #F9FAFC);
      border-radius: 16px 16px 4px 16px;
      padding: 8px 12px;
      max-width: 260px;
    }
    button {
      background: none;
      border: none;
      cursor: pointer;
      padding: 0;
      color: var(--yalo-play-icon-color, #7C8086);
      font-size: 22px;
      line-height: 1;
    }
    canvas { width: 150px; height: 36px; }
    .timer {
      font-size: 11px;
      color: var(--yalo-timer-text-color, #7C8086);
      min-width: 32px;
      text-align: right;
    }
  `;

  private _togglePlay() {
    if (!this.fileName) return;
    if (!this._audio) {
      this._audio = new Audio(this.fileName);
      this._audio.onended = () => {
        this._playing = false;
        clearInterval(this._interval);
        this._elapsed = 0;
      };
    }
    if (this._playing) {
      this._audio.pause();
      clearInterval(this._interval);
    } else {
      this._audio.play();
      this._interval = setInterval(() => {
        this._elapsed = Math.round((this._audio?.currentTime ?? 0) * 1000);
      }, 200);
    }
    this._playing = !this._playing;
  }

  private _formatTime(ms: number): string {
    const s = Math.floor(ms / 1000);
    const m = Math.floor(s / 60);
    return `${m}:${String(s % 60).padStart(2, '0')}`;
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    clearInterval(this._interval);
    this._audio?.pause();
  }

  render() {
    return html`
      <div class="bubble">
        <button @click=${this._togglePlay} aria-label="${this._playing ? 'pause' : 'play'}">
          ${this._playing ? '⏸' : '▶'}
        </button>
        <canvas id="waveform"></canvas>
        <span class="timer">${this._formatTime(this._playing ? this._elapsed : this.duration)}</span>
      </div>
    `;
  }

  updated() {
    const canvas = this.shadowRoot?.querySelector<HTMLCanvasElement>('canvas');
    if (!canvas || !this.amplitudes.length) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    canvas.width = 150;
    canvas.height = 36;
    ctx.clearRect(0, 0, 150, 36);
    ctx.fillStyle = getComputedStyle(this).getPropertyValue('--yalo-wave-color').trim() || '#5C5EE8';
    const barW = 3;
    const gap = 2;
    const total = Math.floor(150 / (barW + gap));
    const samples = this.amplitudes.slice(-total);
    samples.forEach((amp, i) => {
      const normalized = Math.max(0, Math.min(1, (amp + 60) / 60));
      const h = Math.max(3, normalized * 36);
      ctx.fillRect(i * (barW + gap), (36 - h) / 2, barW, h);
    });
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-user-voice-message': YaloUserVoiceMessage;
  }
}
