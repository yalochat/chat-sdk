// Copyright (c) Yalochat, Inc. All rights reserved.
import { processColor, type ColorValue } from 'react-native';

/**
 * Corner radii in density independent points. A number rounds every corner,
 * and an object rounds only the corners it names.
 */
export type ChatShape =
  | number
  | {
      topStart?: number;
      topEnd?: number;
      bottomEnd?: number;
      bottomStart?: number;
    };

/** A width and a height in density independent points. */
export type ChatSize = { width: number; height: number };

/** How the chat paints itself. Anything left out keeps the platform default. */
export type ChatTheme = {
  background?: ColorValue;
  onBackground?: ColorValue;
  headerBackground?: ColorValue;
  onHeaderBackground?: ColorValue;
  footerBackground?: ColorValue;
  onFooterBackground?: ColorValue;
  userMessageBackground?: ColorValue;
  onUserMessageBackground?: ColorValue;
  assistantMessageBackground?: ColorValue;
  onAssistantMessageBackground?: ColorValue;
  assistantMessageBorderColor?: ColorValue;
  /** Room between the bubble of a message the channel sent and its content, in points. */
  assistantMessagePadding?: number;
  /** Room between the bubble of a message the person sent and its content, in points. */
  userMessagePadding?: number;
  typingIndicatorDotColor?: ColorValue;
  linkColor?: ColorValue;
  quickReplyBackground?: ColorValue;
  onQuickReplyBackground?: ColorValue;
  quickReplyBorderColor?: ColorValue;
  postbackBackground?: ColorValue;
  onPostbackBackground?: ColorValue;
  postbackBorderColor?: ColorValue;
  /** Background of the button the person tapped last on a message. */
  selectedPostbackBackground?: ColorValue;
  /** Color of the text on the button the person tapped last on a message. */
  onSelectedPostbackBackground?: ColorValue;
  inputBorderColor?: ColorValue;
  inputFieldBorderColor?: ColorValue;
  inputBackground?: ColorValue;
  sendButtonBackground?: ColorValue;
  onSendButtonBackground?: ColorValue;
  /** Color of the thumb that shows once a long message scrolls inside the input. */
  inputScrollbarColor?: ColorValue;
  /** Width of that thumb, in points. `0` hides it and the text still scrolls. */
  inputScrollbarWidth?: number;
  inputShape?: ChatShape;
  userMessageShape?: ChatShape;
  assistantMessageShape?: ChatShape;
  imageShape?: ChatShape;
  quickReplyShape?: ChatShape;
  postbackShape?: ChatShape;
  /** Border of the button the person tapped last on a message. Left out, it keeps `postbackBorderColor`. */
  selectedPostbackBorderColor?: ColorValue;
  /** Fill of the send button while there is nothing to send. Left out, it is drawn faded. */
  disabledSendButtonBackground?: ColorValue;
  /** Icon color of the send button while there is nothing to send. */
  onDisabledSendButtonBackground?: ColorValue;
  /** Color of the text the message input shows while it is empty. */
  inputPlaceholderColor?: ColorValue;
  /** Color of the thumbs up and thumbs down under the channel's replies. */
  feedbackButtonColor?: ColorValue;
  /** Color of the time shown inside each message with `showTimestamps` on. */
  timestampColor?: ColorValue;
  userAvatarBackground?: ColorValue;
  onUserAvatarBackground?: ColorValue;
  assistantAvatarBackground?: ColorValue;
  onAssistantAvatarBackground?: ColorValue;
  /**
   * A triangle under the bubble that shows the avatar, pointing at it. Left
   * out, bubbles have none.
   */
  messageTailSize?: ChatSize;
  /**
   * Font family for all the text in the chat. On iOS the family name of a
   * font the app registered, on Android the name of a font file in
   * `assets/fonts`, the way React Native finds fonts.
   */
  fontFamily?: string;
};

type Corners = {
  topStart: number;
  topEnd: number;
  bottomEnd: number;
  bottomStart: number;
};

const shapeKeys = new Set<string>([
  'inputShape',
  'userMessageShape',
  'assistantMessageShape',
  'imageShape',
  'quickReplyShape',
  'postbackShape',
]);

const sizeKeys = new Set<string>([
  'assistantMessagePadding',
  'userMessagePadding',
  'inputScrollbarWidth',
]);

const passedAsIsKeys = new Set<string>(['messageTailSize', 'fontFamily']);

function cornersOf(shape: ChatShape): Corners {
  if (typeof shape === 'number') {
    return {
      topStart: shape,
      topEnd: shape,
      bottomEnd: shape,
      bottomStart: shape,
    };
  }
  return {
    topStart: shape.topStart ?? 0,
    topEnd: shape.topEnd ?? 0,
    bottomEnd: shape.bottomEnd ?? 0,
    bottomStart: shape.bottomStart ?? 0,
  };
}

/** The theme as the native side reads it: colors as ARGB numbers, shapes as four corners, sizes as points. */
export function serializeTheme(theme: ChatTheme): string {
  const native: Record<string, number | string | Corners | ChatSize> = {};
  for (const [key, value] of Object.entries(theme)) {
    if (value === undefined || value === null) {
      continue;
    }
    if (shapeKeys.has(key)) {
      native[key] = cornersOf(value as ChatShape);
      continue;
    }
    if (sizeKeys.has(key)) {
      native[key] = value as number;
      continue;
    }
    if (passedAsIsKeys.has(key)) {
      native[key] = value as string | ChatSize;
      continue;
    }
    const color = processColor(value as ColorValue);
    if (typeof color === 'number') {
      native[key] = color;
    } else {
      console.warn(
        `[yalo-chat] ${key} is not a plain color, so it is ignored.`
      );
    }
  }
  return JSON.stringify(native);
}
