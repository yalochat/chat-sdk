// Copyright (c) Yalochat, Inc. All rights reserved.

import { err, ok, type Result } from '../../../common/result.js';
import type { AudioData } from '../../../domain/audio-data.js';
import type { AudioService } from '../../services/audio/audio-service.js';
import { compressWaveformForPreview } from '../../../use-cases/audio-processing.js';
import type { AudioRepository } from './audio-repository.js';

const PREVIEW_BINS = 40;

export class AudioRepositoryWeb implements AudioRepository {
  private rawAmplitudes: number[] = [];
  private previewAmplitudes: number[] = new Array(PREVIEW_BINS).fill(0);
  private totalSamples = 0;
  private currentFileName?: string;

  constructor(private readonly audioService: AudioService) {}

  async startRecording(fileName: string): Promise<Result<void>> {
    this.rawAmplitudes = [];
    this.previewAmplitudes = new Array(PREVIEW_BINS).fill(0);
    this.totalSamples = 0;
    this.currentFileName = fileName;
    return this.audioService.record(fileName);
  }

  async stopRecording(): Promise<Result<AudioData>> {
    const stopResult = await this.audioService.stop();
    if (!stopResult.ok) return err(stopResult.error);

    const duration = this.audioService.getDuration();
    return ok({
      fileName: stopResult.value,
      amplitudes: [...this.rawAmplitudes],
      amplitudesFilePreview: [...this.previewAmplitudes],
      duration,
    });
  }

  getDuration(): number {
    return this.audioService.getDuration();
  }

  onAmplitude(intervalMs: number, callback: (dbfs: number) => void): () => void {
    return this.audioService.onAmplitude(intervalMs, (dbfs) => {
      this.rawAmplitudes.push(dbfs);
      this.totalSamples++;
      this.previewAmplitudes = compressWaveformForPreview(
        dbfs,
        this.totalSamples,
        this.previewAmplitudes,
      );
      callback(dbfs);
    });
  }

  delete(fileName: string): Promise<Result<void>> {
    return this.audioService.delete(fileName);
  }
}
