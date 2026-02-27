// Copyright (c) Yalochat, Inc. All rights reserved.

export type Result<T> = { ok: true; value: T } | { ok: false; error: Error };

export const ok = <T>(value: T): Result<T> => ({ ok: true, value });
export const err = (error: Error): Result<never> => ({ ok: false, error });
