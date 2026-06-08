// Copyright (c) Yalochat, Inc. All rights reserved.

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
  persistent?: boolean;
}
