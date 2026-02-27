// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '../../../common/result.js';
import type { ImageData } from '../../../domain/image-data.js';

export interface ImageRepository {
  /** Opens file picker and returns selected image data, or undefined if cancelled. */
  pickImage(): Promise<Result<ImageData | undefined>>;

  /** Saves an image and returns its URL / path. */
  save(fileName: string, data: Uint8Array, mimeType: string): Promise<Result<string>>;

  /** Deletes a saved image. */
  delete(fileName: string): Promise<Result<void>>;
}
