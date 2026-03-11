// Copyright (c) Yalochat, Inc. All rights reserved.

export interface PageInfo {
  readonly pageSize: number;
  readonly cursor?: number;
  readonly nextCursor?: number;
  readonly prevCursor?: number;
}

export interface Page<T> {
  readonly data: T[];
  readonly pageInfo: PageInfo;
}
