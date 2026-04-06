// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import type {
  MediaUploadResponse,
  YaloMediaService,
} from './yalo-media-service';

export class YaloMediaServiceRemote implements YaloMediaService {
  private readonly _baseUrl: string;
  private readonly _tokenRepository: TokenRepository;

  constructor(baseUrl: string, tokenRepository: TokenRepository) {
    this._baseUrl = baseUrl;
    this._tokenRepository = tokenRepository;
  }

  async uploadMedia(file: File): Promise<Result<MediaUploadResponse>> {
    const tokenResult = await this._tokenRepository.getToken();
    if (!tokenResult.ok) return tokenResult;

    try {
      const formData = new FormData();
      formData.append('file', file, file.name);

      const response = await fetch(`${this._baseUrl}/all/media`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${tokenResult.value}`,
        },
        body: formData,
      });

      if (response.status === 201) {
        const json = (await response.json()) as MediaUploadResponse;
        return new Ok(json);
      }

      return new Err(new Error(`Failed to upload media: ${response.status}`));
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async downloadMedia(url: string): Promise<Result<Blob>> {
    try {
      const response = await fetch(url);

      if (response.ok) {
        return new Ok(await response.blob());
      }

      return new Err(new Error(`Failed to download media: ${response.status}`));
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }
}
