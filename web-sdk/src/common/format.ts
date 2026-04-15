// Copyright (c) Yalochat, Inc. All rights reserved.

export function formatCurrency(
  value: number,
  options: { locale?: string; currency: string }
): string {
  return new Intl.NumberFormat(options.locale, {
    style: 'currency',
    currency: options.currency,
  }).format(value);
}
