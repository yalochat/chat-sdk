// Copyright (c) Yalochat, Inc. All rights reserved.

import { err, ok, type Result } from '../../../common/result.js';
import { PermissionException } from '../../../common/exceptions.js';
import type { AmplitudeCallback, AudioService } from './audio-service.js';

export class AudioServiceWeb implements AudioService {
  private mediaRecorder?: MediaRecorder;
  private audioCtx?: AudioContext;
  private analyser?: AnalyserNode;
  private chunks: Blob[] = [];
  private startTime = 0;
  private blobUrl?: string;
  private blobStore = new Map<string, string>(); // fileName → blobUrl
  private amplitudeTimer?: ReturnType<typeof setInterval>;

  async record(fileName: string): Promise<Result<void>> {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.audioCtx = new AudioContext();
      this.analyser = this.audioCtx.createAnalyser();
      this.analyser.fftSize = 256;
      this.audioCtx.createMediaStreamSource(stream).connect(this.analyser);

      this.chunks = [];
      this.startTime = Date.now();
      this.mediaRecorder = new MediaRecorder(stream, { mimeType: 'audio/webm' });
      this.mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) this.chunks.push(e.data);
      };
      this.mediaRecorder.start(100);
      this.blobUrl = undefined;
      // Remember which fileName we're recording under
      this._currentFileName = fileName;
      return ok(undefined);
    } catch (e) {
      if (e instanceof Error && e.name === 'NotAllowedError') {
        return err(new PermissionException('Microphone permission denied'));
      }
      return err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  private _currentFileName?: string;

  async stop(): Promise<Result<string>> {
    return new Promise((resolve) => {
      if (!this.mediaRecorder) {
        resolve(err(new Error('No active recording')));
        return;
      }
      this.mediaRecorder.onstop = () => {
        const blob = new Blob(this.chunks, { type: 'audio/webm' });
        const url = URL.createObjectURL(blob);
        this.blobUrl = url;
        if (this._currentFileName) {
          this.blobStore.set(this._currentFileName, url);
        }
        this.audioCtx?.close();
        resolve(ok(url));
      };
      this.mediaRecorder.stop();
      this.mediaRecorder.stream.getTracks().forEach((t) => t.stop());
      clearInterval(this.amplitudeTimer);
    });
  }

  getDuration(): number {
    return this.startTime > 0 ? Date.now() - this.startTime : 0;
  }

  onAmplitude(intervalMs: number, callback: AmplitudeCallback): () => void {
    const analyser = this.analyser;
    if (!analyser) return () => undefined;

    const buf = new Float32Array(analyser.fftSize);
    this.amplitudeTimer = setInterval(() => {
      analyser.getFloatTimeDomainData(buf);
      let sumSq = 0;
      for (const v of buf) sumSq += v * v;
      const rms = Math.sqrt(sumSq / buf.length);
      const dbfs = 20 * Math.log10(Math.max(rms, 1e-8));
      callback(dbfs);
    }, intervalMs);

    return () => clearInterval(this.amplitudeTimer);
  }

  async delete(fileName: string): Promise<Result<void>> {
    const url = this.blobStore.get(fileName);
    if (url) {
      URL.revokeObjectURL(url);
      this.blobStore.delete(fileName);
    }
    return ok(undefined);
  }
}
