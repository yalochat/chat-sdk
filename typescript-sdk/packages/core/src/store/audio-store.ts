// Copyright (c) Yalochat, Inc. All rights reserved.

import type { AudioRepository } from '../data/repositories/audio/audio-repository.js';
import type { AudioData } from '../domain/audio-data.js';

export type AudioStatus =
  | 'idle'
  | 'recording'
  | 'stopped'
  | 'error';

export interface AudioState {
  status: AudioStatus;
  amplitudes: number[];
  previewAmplitudes: number[];
  durationMs: number;
  audioData?: AudioData;
  errorMessage?: string;
}

function initialAudioState(): AudioState {
  return {
    status: 'idle',
    amplitudes: [],
    previewAmplitudes: [],
    durationMs: 0,
  };
}

const PREVIEW_BINS = 40;
const AMPLITUDE_INTERVAL_MS = 50;

/** Replaces Flutter's AudioBloc. */
export class AudioStore extends EventTarget {
  private _state: AudioState = initialAudioState();
  private _unsubscribeAmplitude?: () => void;

  constructor(private readonly audioRepository: AudioRepository) {
    super();
  }

  get state(): Readonly<AudioState> {
    return this._state;
  }

  private setState(patch: Partial<AudioState>): void {
    this._state = { ...this._state, ...patch };
    this.dispatchEvent(new CustomEvent('change', { detail: this._state }));
  }

  async startRecording(fileName: string): Promise<void> {
    const result = await this.audioRepository.startRecording(fileName);
    if (result.ok) {
      this.setState({
        status: 'recording',
        amplitudes: [],
        previewAmplitudes: new Array(PREVIEW_BINS).fill(0),
        durationMs: 0,
        audioData: undefined,
        errorMessage: undefined,
      });

      this._unsubscribeAmplitude = this.audioRepository.onAmplitude(
        AMPLITUDE_INTERVAL_MS,
        (dbfs) => {
          const newAmplitudes = [...this._state.amplitudes, dbfs];
          const durationMs = this.audioRepository.getDuration();
          this.setState({ amplitudes: newAmplitudes, durationMs });
        },
      );
    } else {
      this.setState({ status: 'error', errorMessage: result.error.message });
    }
  }

  async stopRecording(): Promise<AudioData | undefined> {
    this._unsubscribeAmplitude?.();
    const result = await this.audioRepository.stopRecording();
    if (result.ok) {
      const audioData = result.value;
      this.setState({ status: 'stopped', audioData });
      return audioData;
    } else {
      this.setState({ status: 'error', errorMessage: result.error.message });
      return undefined;
    }
  }

  async cancelRecording(fileName: string): Promise<void> {
    this._unsubscribeAmplitude?.();
    await this.audioRepository.stopRecording();
    await this.audioRepository.delete(fileName);
    this.setState(initialAudioState());
  }

  reset(): void {
    this._unsubscribeAmplitude?.();
    this.setState(initialAudioState());
  }
}
