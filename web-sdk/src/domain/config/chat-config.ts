// Copyright (c) Yalochat, Inc. All rights reserved.

import type { LogLevel } from '@log/logger';

export interface YaloChatClientConfig {
  channelId: string;
  organizationId: string;
  channelName: string;
  target: string;
  image?: string;
  locale?: string;
  audioWaveformColor?: string;
  userId?: string;
  openContext?: Record<string, unknown>;
  hideCloseButton?: boolean;
  hideHeader?: boolean;
  hideAttachmentButton?: boolean;
  hideVoiceButton?: boolean;
  persistent?: boolean;
  differentSessionPerContext?: boolean;
  logLevel?: LogLevel;
}
