// Copyright (c) Yalochat, Inc. All rights reserved.

import { createContext } from '@lit/context';
import type { YaloMessageRepository } from './yalo-message-repository';

export type { YaloMessageRepository };
export const yaloMessageRepositoryContext =
  createContext<YaloMessageRepository>(Symbol('YaloMessageRepository'));
