// Copyright (c) Yalochat, Inc. All rights reserved.

import type { LogLevel } from '@log/logger';

export const SESSION_MODES = ['shared', 'perContext', 'ephemeral'] as const;
export type SessionMode = (typeof SESSION_MODES)[number];

export const WELCOME_MESSAGE_TYPES = ['none', 'verticalQuickReplies'] as const;
export type WelcomeMessageType = (typeof WELCOME_MESSAGE_TYPES)[number];

export const QUICK_REPLY_TYPES = ['modal', 'inline'] as const;
export type QuickReplyType = (typeof QUICK_REPLY_TYPES)[number];

export const TYPING_INDICATOR_TYPES = ['three-dots', 'text'] as const;
export type TypingIndicatorType = (typeof TYPING_INDICATOR_TYPES)[number];

export const TYPING_INDICATOR_AVATAR_POSITIONS = ['center', 'below'] as const;
export type TypingIndicatorAvatarPosition =
  (typeof TYPING_INDICATOR_AVATAR_POSITIONS)[number];

export const YALO_WATERMARK_POSITIONS = [
  'none',
  'header-left',
  'header-right',
] as const;
export type YaloWatermarkPosition = (typeof YALO_WATERMARK_POSITIONS)[number];

export const AVATAR_DISPLAYS = ['lastInGroup', 'everyMessage'] as const;
export type AvatarDisplay = (typeof AVATAR_DISPLAYS)[number];

export type YaloChatMessageAvatar =
  | { type: 'none' }
  | { type: 'text'; text: string }
  | { type: 'image'; url: string };

export interface YaloChatTexts {
  inputPlaceholder?: string;
  writingIndicator?: string;
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
  thumbUp?: string;
  thumbDown?: string;
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
  /**
   * Gives the app's own signed-in identity, for channels set up to verify it.
   * Called each time the SDK authenticates, so it should resolve to a fresh
   * JWT (RFC 7519) signed by the app's backend. When set, the backend takes
   * the user from the token. Set `userId` to the token's `sub` as well, since
   * it keeps each user's conversation apart in the browser.
   */
  userAuthTokenProvider?: () => Promise<string | null | undefined>;
  openContext?: Record<string, unknown>;
  hideCloseButton?: boolean;
  hideHeader?: boolean;
  yaloWatermark?: YaloWatermarkPosition;
  hideAttachmentButton?: boolean;
  hideVoiceButton?: boolean;
  hideFeedbackButtons?: boolean;
  sessionMode?: SessionMode;
  logLevel?: LogLevel;
  welcomeMessageType?: WelcomeMessageType;
  quickReplyType?: QuickReplyType;
  typingIndicatorType?: TypingIndicatorType;
  texts?: YaloChatTexts;
  icons?: YaloChatIcons;
  userMessageAvatar?: YaloChatMessageAvatar;
  assistantMessageAvatar?: YaloChatMessageAvatar;
  avatarDisplay?: AvatarDisplay;
  typingIndicatorAvatarPosition?: TypingIndicatorAvatarPosition;
}
