// Copyright (c) Yalochat, Inc. All rights reserved.

import { createContext } from '@lit/context';
import type { YaloMessageAuthService } from './yalo-message-auth-service';

export type { YaloMessageAuthService };
export const yaloMessageAuthServiceContext =
  createContext<YaloMessageAuthService>(Symbol('YaloMessageAuthService'));
