// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '../../../common/result.js';
import type { ImageData } from '../../../domain/image-data.js';

export interface CameraService {
  /**
   * Opens a file picker or camera capture and returns image data.
   * Returns undefined if the user cancelled.
   */
  pickImage(): Promise<Result<ImageData | undefined>>;

  /** Saves an image at the given path and returns its URL. */
  save(fileName: string, data: Uint8Array, mimeType: string): Promise<Result<string>>;

  /** Deletes a previously saved image by fileName. */
  delete(fileName: string): Promise<Result<void>>;
}
