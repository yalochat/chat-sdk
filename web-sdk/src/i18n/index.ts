// Copyright (c) Yalochat, Inc. All rights reserved.

import { configureLocalization } from '@lit/localize';

// Generated via output.localeCodesModule
import { sourceLocale, targetLocales } from './locale-codes';

export const { getLocale, setLocale } = configureLocalization({
  sourceLocale,
  targetLocales,
  loadLocale: (locale) => import(`./locales/${locale}.ts`),
});
