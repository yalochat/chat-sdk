// Copyright (c) Yalochat, Inc. All rights reserved.

import type { LogLevel } from '@log/logger';

export const SESSION_MODES = ['shared', 'perContext', 'ephemeral'] as const;
export type SessionMode = (typeof SESSION_MODES)[number];

export const WELCOME_MESSAGE_TYPES = ['none', 'verticalQuickReplies'] as const;
export type WelcomeMessageType = (typeof WELCOME_MESSAGE_TYPES)[number];

export const QUICK_REPLY_TYPES = ['modal', 'inline'] as const;
export type QuickReplyType = (typeof QUICK_REPLY_TYPES)[number];

export const YALO_WATERMARK_POSITIONS = [
  'none',
  'header-left',
  'header-right',
] as const;
export type YaloWatermarkPosition = (typeof YALO_WATERMARK_POSITIONS)[number];

export interface YaloChatTexts {
  inputPlaceholder?: string;
}

export interface YaloChatIcons {
  send?: string;
  mic?: string;
  attachment?: string;
  close?: string;
  play?: string;
  pause?: string;
  document?: string;
  arrowForward?: string;
  check?: string;
  error?: string;
}

export interface YaloChatClientConfig {
  channelId: string;
  organizationId: string;
  channelName: string;
  target: string;
  image?: string;
  locale?: string;
  audioWaveformColor?: string;
  recordingWaveformColor?: string;
  userId?: string;
  openContext?: Record<string, unknown>;
  hideCloseButton?: boolean;
  hideHeader?: boolean;
  yaloWatermark?: YaloWatermarkPosition;
  hideAttachmentButton?: boolean;
  hideVoiceButton?: boolean;
  sessionMode?: SessionMode;
  logLevel?: LogLevel;
  welcomeMessageType?: WelcomeMessageType;
  quickReplyType?: QuickReplyType;
  texts?: YaloChatTexts;
  icons?: YaloChatIcons;
}
