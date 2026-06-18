// Copyright (c) Yalochat, Inc. All rights reserved.

import YaloChatClient, {
  type YaloChatClientInitOptions,
} from '@data/services/client/yalo-chat-client';
import type { YaloChatClientConfig } from '@domain/config/chat-config';

export type YaloOpenConfig = YaloChatClientConfig & YaloChatClientInitOptions;

export interface YaloOpenQueue {
  push(config: YaloOpenConfig): void;
}

declare global {
  interface Window {
    yaloOpen?: YaloOpenConfig[] | YaloOpenQueue;
  }
}

function openClient(config: YaloOpenConfig): YaloChatClient {
  const { onOpen, onClose, ...clientConfig } = config;
  const client = new YaloChatClient(clientConfig);
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
