// Copyright (c) Yalochat, Inc. All rights reserved.

import { createContext } from '@lit/context';
import type { YaloMediaService } from './yalo-media-service';

export type { YaloMediaService };
export const yaloMediaServiceContext =
  createContext<YaloMediaService>(Symbol('YaloMediaService'));
