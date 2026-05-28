// Copyright (c) Yalochat, Inc. All rights reserved.

import YaloChatClient from '@data/services/client/yalo-chat-client';
import type { YaloChatClientConfig } from '@domain/config/chat-config';

export interface YaloOpenQueue {
  push(config: YaloChatClientConfig): void;
}

declare global {
  interface Window {
    yaloOpen?: YaloChatClientConfig[] | YaloOpenQueue;
  }
}

function openClient(config: YaloChatClientConfig): YaloChatClient {
  const client = new YaloChatClient(config);
  client.init();
  client.open();
  return client;
}

export function installYaloOpenQueue(): void {
  const existing = window.yaloOpen;
  const pending = Array.isArray(existing) ? existing : [];
  window.yaloOpen = {
    push(config: YaloChatClientConfig) {
      openClient(config);
    },
  };
  for (const config of pending) {
    openClient(config);
  }
}
