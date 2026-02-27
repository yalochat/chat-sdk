// Copyright (c) Yalochat, Inc. All rights reserved.

import { err, ok, type Result } from '../../../common/result.js';
import type { ImageData } from '../../../domain/image-data.js';
import type { CameraService } from './camera-service.js';

export class CameraServiceWeb implements CameraService {
  private blobStore = new Map<string, string>(); // fileName → blobUrl

  async pickImage(): Promise<Result<ImageData | undefined>> {
    return new Promise((resolve) => {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = 'image/*';

      input.onchange = async () => {
        const file = input.files?.[0];
        if (!file) {
          resolve(ok(undefined));
          return;
        }
        try {
          const bytes = new Uint8Array(await file.arrayBuffer());
          const path = URL.createObjectURL(file);
          resolve(ok({ path, bytes, mimeType: file.type }));
        } catch (e) {
          resolve(err(e instanceof Error ? e : new Error(String(e))));
        }
      };

      input.oncancel = () => resolve(ok(undefined));
      input.click();
    });
  }

  async save(fileName: string, data: Uint8Array, mimeType: string): Promise<Result<string>> {
    try {
      const blob = new Blob([data.buffer as ArrayBuffer], { type: mimeType });
      const url = URL.createObjectURL(blob);
      this.blobStore.set(fileName, url);
      return ok(url);
    } catch (e) {
      return err(e instanceof Error ? e : new Error(String(e)));
    }
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
