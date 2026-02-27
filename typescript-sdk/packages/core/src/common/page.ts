// Copyright (c) Yalochat, Inc. All rights reserved.

export interface PageInfo {
  total?: number;
  totalPages?: number;
  page?: number;
  cursor?: number;
  nextCursor?: number;
  prevCursor?: number;
  pageSize: number;
}

export interface Page<T> {
  data: T[];
  pageInfo: PageInfo;
}

export type PageDirection = 'initial' | 'next' | 'prev';

export const DEFAULT_PAGE_SIZE = 30;
