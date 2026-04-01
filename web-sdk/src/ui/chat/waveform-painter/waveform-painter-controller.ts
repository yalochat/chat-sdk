// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { WaveformPainter } from './waveform-painter';

export class WaveformPainterController implements ReactiveController {
  host: WaveformPainter;
  canvasContext?: CanvasRenderingContext2D;

  private _unmounted = false;

  constructor(host: WaveformPainter) {
    this.host = host;
    this.host.addController(this);
  }

  hostUpdated(): void {
    if (!this.host.animated) {
      this._draw();
    }
  }

  _draw = (): void => {
    const ctx = this.canvasContext || this.host.canvas.getContext('2d');
    if (ctx === null) return;

    const strokeColor = this.host.config.audioWaveformColor || '#2207f1';
    ctx.fillStyle = strokeColor;

    const barWidth = this.host.canvas.width / this.host.amplitudes.length;
    for (let i = 0; i < this.host.amplitudes.length; i++) {
      const amplitude = this.host.amplitudes[i];
      const height = Math.max(
        0.05 * this.host.canvas.height,
        amplitude * this.host.canvas.height
      );

      ctx.clearRect(i * barWidth, 0, barWidth, this.host.canvas.height);
      ctx.beginPath();
      ctx.roundRect(
        i * barWidth,
        this.host.canvas.height / 2 - height,
        barWidth * 0.8,
        height * 2,
        [50]
      );
      ctx.fill();
    }

    if (!this._unmounted && this.host.animated) {
      requestAnimationFrame(this._draw);
    }
  };

  hostConnected(): void {
    if (this.host.animated) {
      requestAnimationFrame(this._draw);
    }
  }

  hostDisconnected(): void {
    this._unmounted = true;
  }
}
