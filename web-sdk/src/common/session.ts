// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { xxhash32 } from '@common/hash';

function computeOpenContextHash(
  config: YaloChatClientConfig
): string | undefined {
  const { openContext, differentSessionPerContext } = config;
  if (differentSessionPerContext !== true || openContext === undefined) {
    return undefined;
  }
  return xxhash32(JSON.stringify(openContext));
}

export function computeSessionId(config: YaloChatClientConfig): string {
  const { organizationId, channelId, userId } = config;
  const base = `${organizationId}-${channelId}-${userId ?? 'anonymous'}`;
  const hash = computeOpenContextHash(config);
  return hash === undefined ? base : `${base}-${hash}`;
}

export function computeEffectiveAuthUserId(
  config: YaloChatClientConfig
): string | undefined {
  const { userId } = config;
  const hash = computeOpenContextHash(config);
  if (userId === undefined || hash === undefined) {
    return userId;
  }
  return `${userId}-${hash}`;
}
