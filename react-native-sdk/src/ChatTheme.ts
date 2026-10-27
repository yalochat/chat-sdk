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
  agentMessageBackground?: ColorValue;
  onAgentMessageBackground?: ColorValue;
  agentMessageBorderColor?: ColorValue;
  /** Room between the box around a message the channel sent and its content, in points. */
  agentMessagePadding?: number;
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
  inputShape?: ChatShape;
  userMessageShape?: ChatShape;
  agentMessageShape?: ChatShape;
  imageShape?: ChatShape;
  quickReplyShape?: ChatShape;
  postbackShape?: ChatShape;
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
  'agentMessageShape',
  'imageShape',
  'quickReplyShape',
  'postbackShape',
]);

const sizeKeys = new Set<string>(['agentMessagePadding']);

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
  const native: Record<string, number | Corners> = {};
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
