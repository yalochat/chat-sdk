// Copyright (c) Yalochat, Inc. All rights reserved.

import { WaveformCompressor } from '@domain/audio/waveform-compressor';
import type { ReactiveController, ReactiveControllerHost } from 'lit';

export type RecordingStatus = 'idle' | 'recording' | 'error';

const AMPLITUDE_DATA_POINTS = 40;
const TIMER_INTERVAL_MS = 11;
const PREFERRED_MIME = 'audio/webm;codecs=opus';
const FALLBACK_MIME = 'audio/webm';

export interface RecordingResult {
  blob: Blob;
  duration: number;
  amplitudes: number[];
}

export class AudioRecordingController implements ReactiveController {
  host: ReactiveControllerHost;

  status: RecordingStatus = 'idle';
  elapsedMs = 0;
  amplitudes: number[] = new Array(AMPLITUDE_DATA_POINTS).fill(0);
  private _mediaRecorder: MediaRecorder | null = null;
  private _audioChunks: Blob[] = [];
  private _waveformCompressor = new WaveformCompressor(AMPLITUDE_DATA_POINTS);
  private _stream: MediaStream | null = null;
  private _audioContext: AudioContext | null = null;
  private _analyser: AnalyserNode | null = null;
  private _timerInterval: ReturnType<typeof setInterval> | null = null;
  private _startTime = 0;
  private _stopResolve: ((result: RecordingResult) => void) | null = null;

  constructor(host: ReactiveControllerHost) {
    this.host = host;
    this.host.addController(this);
  }

  async startRecording(): Promise<void> {
    try {
      this._stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    } catch {
      this.status = 'error';
      this.host.requestUpdate();
      return;
    }

    this._audioContext = new AudioContext();
    const source = this._audioContext.createMediaStreamSource(this._stream);
    this._analyser = this._audioContext.createAnalyser();
    this._analyser.fftSize = 256;
    source.connect(this._analyser);

    const mimeType = MediaRecorder.isTypeSupported(PREFERRED_MIME)
      ? PREFERRED_MIME
      : MediaRecorder.isTypeSupported(FALLBACK_MIME)
        ? FALLBACK_MIME
        : '';

    this._audioChunks = [];
    this._mediaRecorder = new MediaRecorder(
      this._stream,
      mimeType ? { mimeType } : undefined
    );

    this._mediaRecorder.ondataavailable = (e: BlobEvent) => {
      if (e.data.size > 0) this._audioChunks.push(e.data);
    };

    this._mediaRecorder.onstop = () => {
      const blob = new Blob(this._audioChunks, {
        type: this._mediaRecorder?.mimeType ?? 'audio/webm',
      });
      const result: RecordingResult = {
        blob,
        duration: this.elapsedMs,
        amplitudes: this._waveformCompressor.snapshot(),
      };
      this._stopResolve?.(result);
      this._stopResolve = null;
    };

    this._mediaRecorder.start(250);
    this._startTime = Date.now();
    this.elapsedMs = 0;
    this.amplitudes = new Array(AMPLITUDE_DATA_POINTS).fill(0);
    this._waveformCompressor.reset();
    this.status = 'recording';

    this._timerInterval = setInterval(() => {
      this.elapsedMs = Date.now() - this._startTime;
      this._sampleAmplitude();
      this.host.requestUpdate();
    }, TIMER_INTERVAL_MS);

    this.host.requestUpdate();
  }

  stopRecording(): Promise<RecordingResult> {
    return new Promise((resolve) => {
      this._stopResolve = resolve;
      this._mediaRecorder?.stop();
      this._cleanup();
      this.status = 'idle';
      this.host.requestUpdate();
    });
  }

  cancelRecording(): void {
    if (this._mediaRecorder?.state === 'recording') {
      this._mediaRecorder.stop();
    }
    this._cleanup();
    this._audioChunks = [];
    this._waveformCompressor.reset();
    this._stopResolve = null;
    this.status = 'idle';
    this.elapsedMs = 0;
    this.amplitudes = new Array(AMPLITUDE_DATA_POINTS).fill(0);
    this.host.requestUpdate();
  }

  formatTime(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }

  hostConnected() {}

  hostDisconnected() {
    if (this.status === 'recording') {
      this.cancelRecording();
    }
  }

  private _sampleAmplitude(): void {
    if (!this._analyser) {
      return;
    }
    const data = new Uint8Array(this._analyser.frequencyBinCount);
    this._analyser.getByteFrequencyData(data);
    const sum = data.reduce((acc, val) => acc + val, 0);
    const avg = sum / data.length;
    const normalized = Math.min(avg / 128, 1);

    this._waveformCompressor.pushSample(normalized);
    this.amplitudes = this.amplitudes.slice(1);
    this.amplitudes.push(normalized);
  }

  private _cleanup(): void {
    if (this._timerInterval) {
      clearInterval(this._timerInterval);
      this._timerInterval = null;
    }
    this._stream?.getTracks().forEach((track) => track.stop());
    this._stream = null;
    this._audioContext?.close();
    this._audioContext = null;
    this._analyser = null;
  }
}
