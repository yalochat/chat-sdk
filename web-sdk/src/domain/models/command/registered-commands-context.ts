// Copyright (c) Yalochat, Inc. All rights reserved.

import { createContext } from '@lit/context';
import type { RegisteredCommandHandler } from './channel-command';

// Commands the host registered through YaloChatClient.registerCommand, keyed
// by command id. Provided by yalo-chat-window so nested components can react
// to client -> channel overrides (e.g. goToCart).
export type RegisteredCommands = Map<string, RegisteredCommandHandler>;

export const registeredCommandsContext = createContext<RegisteredCommands>(
  Symbol('RegisteredCommands')
);
