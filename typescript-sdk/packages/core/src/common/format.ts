// Copyright (c) Yalochat, Inc. All rights reserved.

/**
 * Formats a number as currency using the given locale.
 * Defaults to the browser locale if none is provided.
 */
export function formatCurrency(val: number, locale?: string): string {
  const l = locale ?? (typeof navigator !== 'undefined' ? navigator.language : 'en-US');
  return new Intl.NumberFormat(l, { style: 'currency', currency: 'USD' }).format(val);
}

/**
 * Formats a number using locale-aware decimal formatting.
 */
export function formatNumber(val: number, locale?: string): string {
  const l = locale ?? (typeof navigator !== 'undefined' ? navigator.language : 'en-US');
  return new Intl.NumberFormat(l).format(val);
}

/**
 * Formats a unit value using an ICU-style plural pattern.
 * Pattern example: "{amount, plural, one {box} other {boxes}}"
 */
export function formatUnit(amount: number, pattern: string, locale?: string): string {
  const rounded = Math.round(amount);
  const l = locale ?? (typeof navigator !== 'undefined' ? navigator.language : 'en');
  const pr = new Intl.PluralRules(l);
  const rule = pr.select(rounded);

  // Extract all "keyword {text}" pairs from the pattern.
  // This handles patterns like: "{amount, plural, one {box} other {boxes}}"
  const choices: Record<string, string> = {};
  const choiceRe = /(\w+)\s*\{([^}]*)\}/g;
  let m: RegExpExecArray | null;
  while ((m = choiceRe.exec(pattern)) !== null) {
    const keyword = m[1];
    // Skip "amount" — it's the variable name inside {amount, plural, ...}
    if (keyword !== 'amount') {
      choices[keyword] = m[2];
    }
  }

  const text = choices[rule] ?? choices['other'];
  if (text === undefined) return pattern.replace(/\{amount\}/g, String(rounded));
  return text.trim().replace(/\{amount\}/g, String(rounded));
}
