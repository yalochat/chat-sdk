// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ImageData } from '../domain/image-data.js';
import type { ImageRepository } from '../data/repositories/image/image-repository.js';

export type ImageStatus = 'idle' | 'selected' | 'error';

export interface ImageState {
  status: ImageStatus;
  imageData?: ImageData;
  errorMessage?: string;
}

function initialImageState(): ImageState {
  return { status: 'idle' };
}

/** Replaces Flutter's ImageBloc. */
export class ImageStore extends EventTarget {
  private _state: ImageState = initialImageState();

  constructor(private readonly imageRepository: ImageRepository) {
    super();
  }

  get state(): Readonly<ImageState> {
    return this._state;
  }

  private setState(patch: Partial<ImageState>): void {
    this._state = { ...this._state, ...patch };
    this.dispatchEvent(new CustomEvent('change', { detail: this._state }));
  }

  async pickImage(): Promise<void> {
    const result = await this.imageRepository.pickImage();
    if (result.ok) {
      if (result.value) {
        this.setState({ status: 'selected', imageData: result.value, errorMessage: undefined });
      }
      // If undefined, user cancelled — keep current state
    } else {
      this.setState({ status: 'error', errorMessage: result.error.message });
    }
  }

  async deleteImage(fileName: string): Promise<void> {
    await this.imageRepository.delete(fileName);
    this.setState(initialImageState());
  }

  clearImage(): void {
    this.setState(initialImageState());
  }
}
