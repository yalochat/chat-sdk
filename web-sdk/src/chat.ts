// Copyright (c) Yalochat, Inc. All rights reserved.

import { installYaloOpenQueue } from './queue-open';

export { default as YaloChatClient } from './data/services/client/yalo-chat-client';
export type { YaloChatClientInitOptions } from './data/services/client/yalo-chat-client';
export type { YaloChatClientConfig } from './domain/config/chat-config';
export {
  ChatCommands,
  type ChatCommand,
  type ChatCommandCallback,
} from './domain/models/command/chat-command';
export { YaloChatWindow } from './ui/chat/chat-window/yalo-chat-window';
export { installYaloOpenQueue, type YaloOpenQueue } from './queue-open';

installYaloOpenQueue();
