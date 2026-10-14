// Copyright (c) Yalochat, Inc. All rights reserved.
import {
  useCallback,
  useMemo,
  useRef,
  useSyncExternalStore,
  type ComponentRef,
} from 'react';
import {
  StyleSheet,
  type NativeSyntheticEvent,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import { serializeTheme, type ChatTheme } from './ChatTheme';
import type { YaloChatClient } from './YaloChatClient';
import YaloChatView, {
  Commands,
  type CommandEvent,
} from './YaloChatViewNativeComponent';

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
  const chat = useRef<ComponentRef<typeof YaloChatView>>(null);
  const config = useMemo(() => JSON.stringify(client.config), [client]);
  const nativeTheme = useMemo(() => serializeTheme(theme ?? {}), [theme]);
  const commands = useSyncExternalStore(
    client.subscribeToCommands,
    client.registeredCommands
  );

  const onCommand = useCallback(
    async ({ nativeEvent }: NativeSyntheticEvent<CommandEvent>) => {
      const { requestId, command, payload } = nativeEvent;
      let succeeded = true;
      let answer = '';
      try {
        const handler = client.commandHandler(command);
        if (!handler) {
          throw new Error(`No handler registered for command ${command}`);
        }
        answer = (await handler(payload)) ?? '';
      } catch (error) {
        console.error(`[YaloChat] command ${command} failed`, error);
        succeeded = false;
      }
      if (chat.current) {
        Commands.resolveCommand(chat.current, requestId, succeeded, answer);
      }
    },
    [client]
  );

  return (
    <YaloChatView
      ref={chat}
      testID={testID}
      style={[styles.chat, style]}
      config={config}
      theme={nativeTheme}
      showsBackButton={onBack !== undefined}
      commands={commands}
      onBack={() => onBack?.()}
      onCommand={onCommand}
    />
  );
}

const styles = StyleSheet.create({
  chat: {
    flex: 1,
  },
});
