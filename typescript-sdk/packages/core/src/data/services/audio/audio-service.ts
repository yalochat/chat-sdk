// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '../../../common/result.js';

/** Observable-like callback for amplitude stream values. */
export type AmplitudeCallback = (dbfs: number) => void;

export interface AudioService {
  /**
   * Starts recording audio into the given fileName (a key/identifier).
   * Requests microphone permission — may throw PermissionException.
   */
  record(fileName: string): Promise<Result<void>>;

  /** Stops the active recording and resolves with the Blob URL or path. */
  stop(): Promise<Result<string>>;

  /** Returns the current recording duration in milliseconds. */
  getDuration(): number;

  /**
   * Subscribes to amplitude values emitted every intervalMs.
   * Returns an unsubscribe function.
   */
  onAmplitude(intervalMs: number, callback: AmplitudeCallback): () => void;

  /** Deletes a previously recorded audio file by its fileName. */
  delete(fileName: string): Promise<Result<void>>;
}
