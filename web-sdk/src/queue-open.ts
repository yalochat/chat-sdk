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

// Lifecycle callbacks specific to the queue path. `onReady` hands back the
// created client once it is initialized, so hosts that open through the queue
// (and never hold a client reference) can still drive it imperatively, for
// example to call `client.sendTextMessage(...)` later. It is the reliable way
// to get the client from the queue: it fires whether you push before or after
// the SDK script loads.
export interface YaloOpenLifecycleOptions {
  onReady?: (client: YaloChatClient) => void;
}

export type YaloOpenConfig = YaloChatClientConfig &
  YaloChatClientInitOptions &
  YaloOpenCommandOptions &
  YaloOpenLifecycleOptions;

export interface YaloOpenQueue {
  push(config: YaloOpenConfig): void;
}

declare global {
  interface Window {
    yaloOpen?: YaloOpenConfig[] | YaloOpenQueue;
  }
}

function openClient(config: YaloOpenConfig): YaloChatClient {
  const { onOpen, onClose, onReady, registerCommands, ...clientConfig } = config;
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
  onReady?.(client);
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
