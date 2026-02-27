// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '../../../common/result.js';
import type { ImageData } from '../../../domain/image-data.js';
import type { CameraService } from '../../services/camera/camera-service.js';
import type { ImageRepository } from './image-repository.js';

export class ImageRepositoryWeb implements ImageRepository {
  constructor(private readonly cameraService: CameraService) {}

  pickImage(): Promise<Result<ImageData | undefined>> {
    return this.cameraService.pickImage();
  }

  save(fileName: string, data: Uint8Array, mimeType: string): Promise<Result<string>> {
    return this.cameraService.save(fileName, data, mimeType);
  }

  delete(fileName: string): Promise<Result<void>> {
    return this.cameraService.delete(fileName);
  }
}
