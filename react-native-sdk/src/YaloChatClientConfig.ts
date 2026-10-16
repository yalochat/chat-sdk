// Copyright (c) Yalochat, Inc. All rights reserved.

/** How a conversation is scoped, and whether it is remembered. */
export type SessionMode = 'shared' | 'perContext' | 'ephemeral';

/** How much the SDK writes to the device log. Each level includes the ones after it. */
export type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'silent';

/** Where the chat puts the quick replies a message offers. */
export type QuickReplyType = 'modal' | 'inline';

/** How the first message of a conversation is drawn. */
export type WelcomeMessageType = 'none' | 'verticalQuickReplies';

/** The details of one conversation. */
export type YaloChatClientConfig = {
  channelId: string;
  organizationId: string;
  channelName: string;
  /** Who the person is in your app. Leave it out for an anonymous conversation. */
  userId?: string;
  logLevel?: LogLevel;
  quickReplyType?: QuickReplyType;
  welcomeMessageType?: WelcomeMessageType;
  /** What the chat is opened from, sent to the channel when the conversation is empty. */
  openContext?: Record<string, string>;
  sessionMode?: SessionMode;
  hideWatermark?: boolean;
  hideVoiceButton?: boolean;
  hideAttachmentButton?: boolean;
  hideFeedbackButtons?: boolean;
};
