// Copyright (c) Yalochat, Inc. All rights reserved.
import type { ImageRequireSource, ImageURISource } from 'react-native';

/** How a conversation is scoped, and whether it is remembered. */
export type SessionMode = 'shared' | 'perContext' | 'ephemeral';

/** How much the SDK writes to the device log. Each level includes the ones after it. */
export type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'silent';

/** Where the chat puts the quick replies a message offers. */
export type QuickReplyType = 'modal' | 'inline';

/** How the first message of a conversation is drawn. */
export type WelcomeMessageType = 'none' | 'verticalQuickReplies';

/** Where the pictures a person sends may come from. */
export type ImageSource = 'all' | 'screenshots';

/**
 * Your own copy for strings the chat would otherwise show in its built-in
 * translations. A string given here is shown as given whatever the device
 * language. Leave a field out to keep the built-in translation.
 */
export type YaloChatTexts = {
  /** What the message input shows while it is empty. */
  inputPlaceholder?: string;
  /** The title of the alert shown when a picked picture is turned away. */
  imageNotAllowed?: string;
  /** The button that closes that alert. */
  invalidImageAlertButtonText?: string;
  /** What `typingIndicatorType: 'text'` shows while a reply is being written. */
  writingIndicator?: string;
};

/** What the chat shows while a reply is being written. */
export type TypingIndicatorType = 'threeDots' | 'text';

/** Where the assistant avatar sits beside the typing indicator. */
export type TypingIndicatorAvatarPosition = 'center' | 'below';

/** Which messages get the avatar of their side. */
export type AvatarDisplay = 'lastInGroup' | 'everyMessage';

/** Where the buttons a channel message keeps are drawn. */
export type MessageButtonsPosition = 'belowMessage' | 'insideMessage';

/**
 * The small round picture drawn beside the messages of one side. Either up to
 * two characters of text, or an image the chat shows once it has loaded.
 */
export type YaloChatMessageAvatar =
  { text: string } | { image: ImageURISource | ImageRequireSource };

/** The details of one conversation. */
export type YaloChatClientConfig = {
  channelId: string;
  organizationId: string;
  channelName: string;
  /** Who the person is in your app. Leave it out for an anonymous conversation. */
  userId?: string;
  /**
   * Returns a JWT (RFC 7519) signed by your backend that proves who the
   * signed-in person is. Called each time the chat authenticates. Set
   * `userId` to the token's `sub` as well.
   */
  userAuthTokenProvider?: () => Promise<string | null | undefined>;
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
  texts?: YaloChatTexts;
  imageSource?: ImageSource;
  /** Android only. The folders a picture may come from with `imageSource` set to `'screenshots'`. */
  screenshotFolders?: string[];
  /**
   * Regular expressions a picked picture's file name has to match in full.
   * Android checks the name with its extension, iOS without it.
   */
  allowedImageNames?: string[];
  typingIndicatorType?: TypingIndicatorType;
  typingIndicatorAvatarPosition?: TypingIndicatorAvatarPosition;
  /** Drawn beside the person's messages. Left out, none is drawn. */
  userMessageAvatar?: YaloChatMessageAvatar;
  /** Drawn beside the channel's messages. Left out, none is drawn. */
  assistantMessageAvatar?: YaloChatMessageAvatar;
  avatarDisplay?: AvatarDisplay;
  /** Whether each message shows the time it was sent inside its bubble. */
  showTimestamps?: boolean;
  messageButtonsPosition?: MessageButtonsPosition;
};
