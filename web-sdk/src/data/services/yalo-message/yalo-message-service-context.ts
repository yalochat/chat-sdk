// Copyright (c) Yalochat, Inc. All rights reserved.

import { createContext } from '@lit/context';
import type { YaloMessageService } from './yalo-message-service';

export type { YaloMessageService };
export const yaloMessageServiceContext =
  createContext<YaloMessageService>(Symbol('YaloMessageService'));
