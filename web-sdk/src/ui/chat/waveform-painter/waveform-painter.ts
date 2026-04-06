// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { localized } from '@lit/localize';
import { loggerContext, type Logger } from '@log/logger-context';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property, query } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import { WaveformPainterController } from './waveform-painter-controller';

@customElement('waveform-recorder')
@localized()
export class WaveformPainter extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-waveform-color: #2207f1;
      --yalo-chat-waveform-close-button-color: #7c8086;
      --yalo-chat-waveform-timer-color: #7c8086;
    }

    .waveform-recorder {
      display: flex;
      flex-direction: row;
      gap: var(--yalo-chat-row-item-space);
    }

    .waveform-canvas {
      width: 90%;
      height: 1.6em;
    }

    .waveform-cancel-button {
      width: 10%;
      appearance: none;
      border: none;
      outline: none;
      background: none;
      color: var(--yalo-chat-waveform-close-button-color);
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      flex-shrink: 0;
      padding: 0;
    }

    .material-symbols-outlined {
      font-size: 1.5em;
      font-family: 'Material Symbols Outlined';
    }

    .recording-time {
      color: var(--yalo-chat-waveform-timer-color);
      display: flex;
      align-items: center;
      margin-left: 0.5rem;
    }
  `;
  @consume({ context: loggerContext })
  logger!: Logger;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ type: Array, attribute: false })
  amplitudes: Array<number> = [];

  @property({ type: Boolean })
  animated: boolean = true;

  @property()
  time: string = '0:00';

  @query('.waveform-canvas')
  canvas!: HTMLCanvasElement;

  waveformController = new WaveformPainterController(this);

  render() {
    return html`
      <div class="waveform-recorder">
        ${this.animated
          ? html` <span class="recording-time">${this.time}</span>`
          : nothing}
        <canvas class="waveform-canvas"></canvas>
        ${this.animated
          ? html` <button
              class="waveform-cancel-button"
              type="button"
              @click=${() =>
                this.dispatchEvent(new Event('yalo-chat-stop-voice-message'))}
            >
              ${unsafeHTML(this.config.icons?.close)}
            </button>`
          : nothing}
      </div>
    `;
  }
}
