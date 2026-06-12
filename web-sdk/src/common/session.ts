// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { xxhash32 } from '@common/hash';

function computeOpenContextHash(
  openContext: YaloChatClientConfig['openContext']
): string | undefined {
  if (openContext === undefined) {
    return undefined;
  }
  return xxhash32(JSON.stringify(openContext));
}

export function computeSessionId(config: YaloChatClientConfig): string {
  const { organizationId, channelId, userId, openContext } = config;
  const base = `${organizationId}-${channelId}-${userId ?? 'anonymous'}`;
  const hash = computeOpenContextHash(openContext);
  return hash === undefined ? base : `${base}-${hash}`;
}

export function computeEffectiveAuthUserId(
  config: YaloChatClientConfig
): string | undefined {
  const { userId, openContext } = config;
  const hash = computeOpenContextHash(openContext);
  if (userId === undefined || hash === undefined) {
    return userId;
  }
  return `${userId}-${hash}`;
}
