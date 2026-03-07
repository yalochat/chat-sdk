// Copyright (c) Yalochat, Inc. All rights reserved.

export const SUPPORTED_LOCALES = ['en', 'es', 'pt'] as const;
export type Locale = (typeof SUPPORTED_LOCALES)[number];

type Translations = {
  [key in Locale]: Record<string, string>;
};

const translations: Translations = {
  en: {
    'chat.title': 'Chat',
    'chat.close': 'Close chat',
  },
  es: {
    'chat.title': 'Chat',
    'chat.close': 'Cerrar chat',
  },
  pt: {
    'chat.title': 'Chat',
    'chat.close': 'Fechar chat',
  },
};

export class Translator {
  private locale: Locale;
  constructor(locale: Locale = 'en') {
    this.locale = locale;
  }

  // Translates a key to its corresponding value
  public t(key: string) {
    return translations[this.locale][key];
  }
}
