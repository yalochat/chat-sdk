// Copyright (c) Yalochat, Inc. All rights reserved.

import YaloChatClient, {
  type YaloChatClientInitOptions,
} from '@data/services/client/yalo-chat-client';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  CustomCommandHandler,
  CustomCommandId,
  RegisteredCommandsMap,
} from '@domain/models/command/channel-command';

// Command registrations a consumer can declare inline in a yaloOpen config.
// `registerCommands` maps a command id to its handler, with the same semantics
// as YaloChatClient.registerCommand. All entries are registered before the
// chat window opens.
export interface YaloOpenCommandOptions {
  registerCommands?: RegisteredCommandsMap;
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
  const { onOpen, onClose, registerCommands, ...clientConfig } = config;
  const client = new YaloChatClient(clientConfig);
  if (registerCommands) {
    for (const [command, handler] of Object.entries(registerCommands)) {
      if (handler) {
        client.registerCommand(
          command as CustomCommandId,
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
