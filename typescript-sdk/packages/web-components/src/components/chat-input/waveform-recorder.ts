// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-waveform-recorder')
export class YaloWaveformRecorder extends LitElement {
  @property({ type: Array }) amplitudes: number[] = [];
  @property({ type: Number }) durationMs = 0;
  @property({ type: Number }) extraOffset = 0;

  static styles = css`
    :host {
      display: flex;
      align-items: center;
      gap: 8px;
      flex: 1;
      height: 44px;
      padding: 0 4px;
    }
    canvas {
      flex: 1;
      min-width: 0;
      height: 28px;
      display: block;
    }
    .timer {
      font-size: 13px;
      color: var(--yalo-timer-text-color, #7C8086);
      min-width: 44px;
    }
    .cancel {
      background: none;
      border: none;
      cursor: pointer;
      font-size: 18px;
      color: var(--yalo-cancel-rec-icon-color, #7C8086);
    }
  `;

  private _formatTime(ms: number): string {
    const s = Math.floor(ms / 1000);
    const m = Math.floor(s / 60);
    return `${m}:${String(s % 60).padStart(2, '0')}`;
  }

  render() {
    return html`
      <button class="cancel"
        @click=${() => this.dispatchEvent(new CustomEvent('cancel', { bubbles: true, composed: true }))}
        aria-label="cancel recording"
      >✕</button>
      <canvas id="waveform"></canvas>
      <span class="timer">${this._formatTime(this.durationMs)}</span>
    `;
  }

  updated() {
    const canvas = this.shadowRoot?.querySelector<HTMLCanvasElement>('canvas');
    if (!canvas) return;
    const H = 28;
    // Use the recorder's own clientWidth (stable flex allocation) to avoid the
    // circular dependency where canvas.offsetWidth reflects the previously-set
    // canvas.width attribute, inflating its intrinsic size and causing overflow.
    const cancelBtn = this.shadowRoot?.querySelector<HTMLElement>('.cancel');
    const timer = this.shadowRoot?.querySelector<HTMLElement>('.timer');
    const occupied = (cancelBtn?.offsetWidth ?? 0) + (timer?.offsetWidth ?? 0) + 24 + this.extraOffset; // 2×8px gaps + 2×4px host padding
    const w = this.clientWidth - occupied;
    if (w <= 0) return; // layout not ready; next amplitude update will trigger updated() again
    canvas.width = w;
    canvas.height = H;
    const ctx = canvas.getContext('2d');
    if (!ctx || !this.amplitudes.length) return;
    ctx.clearRect(0, 0, w, H);
    const color = getComputedStyle(this).getPropertyValue('--yalo-wave-color').trim() || '#5C5EE8';
    ctx.fillStyle = color;
    const barW = 3;
    const gap = 2;
    const maxBarH = H - 6; // leave 3px headroom top and bottom
    const total = Math.floor(w / (barW + gap));
    const samples = this.amplitudes.slice(-total);
    samples.forEach((amp, i) => {
      const normalized = Math.max(0, Math.min(1, (amp + 60) / 60));
      const h = Math.max(3, normalized * maxBarH);
      ctx.fillRect(i * (barW + gap), (H - h) / 2, barW, h);
    });
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-waveform-recorder': YaloWaveformRecorder;
  }
}
