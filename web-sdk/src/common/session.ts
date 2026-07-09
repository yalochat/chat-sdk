// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { xxhash32 } from '@common/hash';

function computeOpenContextHash(
  config: YaloChatClientConfig
): string | undefined {
  const { openContext, sessionMode } = config;
  if (sessionMode !== 'perContext' || openContext === undefined) {
    return undefined;
  }
  return xxhash32(JSON.stringify(openContext));
}

export function computeSessionId(
  config: YaloChatClientConfig,
  ephemeralToken?: string
): string {
  const { organizationId, channelId, userId } = config;
  const base = `${organizationId}-${channelId}-${userId ?? 'anonymous'}`;
  if (config.sessionMode === 'ephemeral' && ephemeralToken !== undefined) {
    return `${base}-${ephemeralToken}`;
  }
  const hash = computeOpenContextHash(config);
  return hash === undefined ? base : `${base}-${hash}`;
}

export function computeEffectiveAuthUserId(
  config: YaloChatClientConfig,
  ephemeralToken?: string
): string | undefined {
  const { userId } = config;
  if (config.sessionMode === 'ephemeral') {
    // Anonymous: let the backend mint a fresh identity on each auth.
    if (userId == null) {
      return undefined;
    }
    // Defensive: no token to append, so keep the user id as-is.
    if (ephemeralToken === undefined) {
      return userId;
    }
    return `${userId}-${ephemeralToken}`;
  }
  if (userId == null) {
    return undefined;
  }
  const hash = computeOpenContextHash(config);
  if (hash === undefined) {
    return userId;
  }
  return `${userId}-${hash}`;
}
