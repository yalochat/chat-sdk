// Copyright (c) Yalochat, Inc. All rights reserved.

import { createContext } from '@lit/context';

import type { YaloChatClientConfig } from './chat-config';
export type { YaloChatClientConfig };
export const yaloChatClientConfigContext = createContext<YaloChatClientConfig>(
  Symbol('YaloChatClientConfig')
);
