// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Locale } from '@i18n/index';
import type { YaloChatTheme } from '@ui/theme/theme';

export interface YaloChatClientConfig {
  channelId: string;
  organizationId: string;
  target: string;
  locale?: Locale;
  theme?: YaloChatTheme;
}
