// Copyright (c) Yalochat, Inc. All rights reserved.

export interface ImageData {
  /** File path or Blob URL */
  path: string;
  /** Raw image bytes */
  bytes: Uint8Array;
  /** MIME type (e.g. "image/jpeg") */
  mimeType: string;
}
