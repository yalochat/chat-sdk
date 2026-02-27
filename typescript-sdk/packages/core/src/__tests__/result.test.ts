// Copyright (c) Yalochat, Inc. All rights reserved.

import { ok, err } from '../common/result';

describe('Result', () => {
  it('ok wraps a value', () => {
    const result = ok(42);
    expect(result.ok).toBe(true);
    if (result.ok) expect(result.value).toBe(42);
  });

  it('err wraps an error', () => {
    const error = new Error('oops');
    const result = err(error);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error).toBe(error);
  });

  it('ok with void/undefined', () => {
    const result = ok(undefined);
    expect(result.ok).toBe(true);
  });
});
