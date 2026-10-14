// Copyright (c) Yalochat, Inc. All rights reserved.
import { useMemo } from 'react';
import { StyleSheet, type StyleProp, type ViewStyle } from 'react-native';
import { serializeTheme, type ChatTheme } from './ChatTheme';
import type { YaloChatClient } from './YaloChatClient';
import YaloChatView from './YaloChatViewNativeComponent';

export type ChatProps = {
  client: YaloChatClient;
  theme?: ChatTheme;
  /** Shows a back button in the header that calls it. */
  onBack?: () => void;
  style?: StyleProp<ViewStyle>;
  testID?: string;
};

/**
 * The chat screen: a header, the conversation and the message input. It fills
 * the space it is given and leaves safe areas and the keyboard to the host.
 */
export function Chat({ client, theme, onBack, style, testID }: ChatProps) {
  const config = useMemo(() => JSON.stringify(client.config), [client]);
  const nativeTheme = useMemo(() => serializeTheme(theme ?? {}), [theme]);
  return (
    <YaloChatView
      testID={testID}
      style={[styles.chat, style]}
      config={config}
      theme={nativeTheme}
      showsBackButton={onBack !== undefined}
      onBack={() => onBack?.()}
    />
  );
}

const styles = StyleSheet.create({
  chat: {
    flex: 1,
  },
});
