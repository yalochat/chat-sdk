// Copyright (c) Yalochat, Inc. All rights reserved.

import { formatNumber, formatUnit } from '../common/format';

describe('formatNumber', () => {
  it('formats a number in en-US locale', () => {
    const result = formatNumber(1234.5, 'en-US');
    expect(result).toBe('1,234.5');
  });
});

describe('formatUnit', () => {
  it('returns the "one" plural form', () => {
    const pattern = '{amount, plural, one {box} other {boxes}}';
    expect(formatUnit(1, pattern, 'en')).toBe('box');
  });

  it('returns the "other" plural form', () => {
    const pattern = '{amount, plural, one {box} other {boxes}}';
    expect(formatUnit(3, pattern, 'en')).toBe('boxes');
  });

  it('falls back gracefully when no plural rule matches exactly', () => {
    const pattern = '{amount, plural, other {items}}';
    expect(formatUnit(5, pattern, 'en')).toBe('items');
  });
});
