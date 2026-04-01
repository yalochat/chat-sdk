// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';

export interface MediaUploadResponse {
  id: string;
  signed_url: string;
  original_name: string;
  type: string;
  metadata: Record<string, unknown>;
  created_at: string;
  expires_at: string;
}

export interface YaloMediaService {
  uploadMedia(file: File): Promise<Result<MediaUploadResponse>>;
  downloadMedia(url: string): Promise<Result<Blob>>;
}
