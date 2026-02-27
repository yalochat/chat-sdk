// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '../../../common/result.js';
import type { AudioData } from '../../../domain/audio-data.js';

export interface AudioRepository {
  /** Starts recording audio under the given fileName. */
  startRecording(fileName: string): Promise<Result<void>>;

  /** Stops recording and returns the captured AudioData. */
  stopRecording(): Promise<Result<AudioData>>;

  /** Returns current recording duration in milliseconds. */
  getDuration(): number;

  /**
   * Subscribes to amplitude values (dBFS) emitted every intervalMs.
   * Returns an unsubscribe function.
   */
  onAmplitude(intervalMs: number, callback: (dbfs: number) => void): () => void;

  /** Deletes a previously recorded audio file. */
  delete(fileName: string): Promise<Result<void>>;
}
