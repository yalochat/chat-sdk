// Copyright (c) Yalochat, Inc. All rights reserved.

export interface AudioData {
  /** File path or Blob URL for the recorded audio */
  fileName: string;
  /** Raw amplitude values captured during recording */
  amplitudes: number[];
  /** Compressed waveform for UI preview */
  amplitudesFilePreview: number[];
  /** Duration in milliseconds */
  duration: number;
}
