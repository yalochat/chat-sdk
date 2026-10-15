// Copyright (c) Yalochat, Inc. All rights reserved.
import {
  useCallback,
  useMemo,
  useRef,
  useSyncExternalStore,
  type ComponentRef,
} from 'react';
import {
  Image,
  StyleSheet,
  type ImageRequireSource,
  type ImageURISource,
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
  /**
   * Drawn as a circle beside the channel name, and above the welcome message
   * when it is drawn with vertical quick replies.
   */
  avatar?: ImageURISource | ImageRequireSource;
  /** Shows a back button in the header that calls it. */
  onBack?: () => void;
  style?: StyleProp<ViewStyle>;
  testID?: string;
};

/**
 * The chat screen: a header, the conversation and the message input. It fills
 * the space it is given and leaves safe areas and the keyboard to the host.
 */
export function Chat({
  client,
  theme,
  avatar,
  onBack,
  style,
  testID,
}: ChatProps) {
  const chat = useRef<ComponentRef<typeof YaloChatView>>(null);
  const config = useMemo(() => JSON.stringify(client.config), [client]);
  const nativeTheme = useMemo(() => serializeTheme(theme ?? {}), [theme]);
  const avatarUri = useMemo(() => avatarUriOf(avatar), [avatar]);
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
      avatar={avatarUri}
      showsBackButton={onBack !== undefined}
      commands={commands}
      onBack={() => onBack?.()}
      onCommand={onCommand}
    />
  );
}

// Bundled images resolve to a URL in development and to an app asset in a
// release build, which the native chat loads either way.
function avatarUriOf(avatar: ChatProps['avatar']): string {
  if (avatar === undefined) {
    return '';
  }
  return Image.resolveAssetSource(avatar)?.uri ?? '';
}

const styles = StyleSheet.create({
  chat: {
    flex: 1,
  },
});
