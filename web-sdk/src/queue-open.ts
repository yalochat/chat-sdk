// Copyright (c) Yalochat, Inc. All rights reserved.

import YaloChatClient, {
  type YaloChatClientInitOptions,
} from '@data/services/client/yalo-chat-client';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  ChatCommand,
  ChatCommandCallback,
} from '@domain/models/command/chat-command';
import type {
  ChannelCommandHandlerMap,
  CustomCommandHandler,
  CustomCommandId,
} from '@domain/models/command/channel-command';

// Command registrations a consumer can declare inline in a yaloOpen config.
// `registerCommands` maps a client -> channel command to its callback, and
// `onCommand` maps a channel -> client custom command id to its handler. Both
// are registered before the chat window opens.
export interface YaloOpenCommandOptions {
  registerCommands?: Partial<Record<ChatCommand, ChatCommandCallback>>;
  onCommand?: ChannelCommandHandlerMap;
}

export type YaloOpenConfig = YaloChatClientConfig &
  YaloChatClientInitOptions &
  YaloOpenCommandOptions;

export interface YaloOpenQueue {
  push(config: YaloOpenConfig): void;
}

declare global {
  interface Window {
    yaloOpen?: YaloOpenConfig[] | YaloOpenQueue;
  }
}

function openClient(config: YaloOpenConfig): YaloChatClient {
  const { onOpen, onClose, registerCommands, onCommand, ...clientConfig } =
    config;
  const client = new YaloChatClient(clientConfig);
  if (registerCommands) {
    for (const [command, callback] of Object.entries(registerCommands)) {
      if (callback) {
        client.registerCommand(command as ChatCommand, callback);
      }
    }
  }
  if (onCommand) {
    for (const [commandId, handler] of Object.entries(onCommand)) {
      if (handler) {
        client.onCommand(
          commandId as CustomCommandId,
          handler as CustomCommandHandler
        );
      }
    }
  }
  client.init({ onOpen, onClose });
  client.open();
  return client;
}

export function installYaloOpenQueue(): void {
  const existing = window.yaloOpen;
  const pending = Array.isArray(existing) ? existing : [];
  window.yaloOpen = {
    push(config: YaloOpenConfig) {
      openClient(config);
    },
  };
  for (const config of pending) {
    openClient(config);
  }
}
