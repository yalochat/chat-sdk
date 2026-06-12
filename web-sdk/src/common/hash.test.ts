// Copyright (c) Yalochat, Inc. All rights reserved.

import { describe, expect, it } from 'vitest';
import { xxhash32 } from '@common/hash';

describe('xxhash32', () => {
  it('returns the same hash for the same input', () => {
    expect(xxhash32('hello world')).toBe(xxhash32('hello world'));
  });

  it('returns different hashes for different inputs', () => {
    expect(xxhash32('hello')).not.toBe(xxhash32('world'));
  });

  it('handles the empty string', () => {
    expect(xxhash32('')).toMatch(/^[0-9a-z]+$/);
  });

  it('handles inputs longer than one xxhash block (16 bytes)', () => {
    expect(xxhash32('a'.repeat(1000))).toMatch(/^[0-9a-z]+$/);
  });

  it('produces distinct hashes for inputs that differ only by a trailing byte', () => {
    expect(xxhash32('aaaa')).not.toBe(xxhash32('aaab'));
  });

  it('produces distinct hashes for keys reordered inside an object literal', () => {
    expect(xxhash32(JSON.stringify({ a: 1, b: 2 }))).not.toBe(
      xxhash32(JSON.stringify({ b: 2, a: 1 }))
    );
  });
});
