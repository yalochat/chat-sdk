// Copyright (c) Yalochat, Inc. All rights reserved.

import { createContext } from '@lit/context';
import type { ChatMessageRepository } from './chat-message-repository';

export type { ChatMessageRepository };
export const chatMessageRepositoryContext =
  createContext<ChatMessageRepository>(Symbol('ChatMessageRepository'));
