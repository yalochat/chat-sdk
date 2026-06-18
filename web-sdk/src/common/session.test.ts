// Copyright (c) Yalochat, Inc. All rights reserved.

import { describe, expect, it } from 'vitest';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import {
  computeEffectiveAuthUserId,
  computeSessionId,
} from '@common/session';

const baseConfig: YaloChatClientConfig = {
  channelId: 'ch-1',
  organizationId: 'org-1',
  channelName: 'Test',
  target: 'target',
};

describe('computeSessionId', () => {
  it('returns the same sessionId for two configs with the same openContext when sessionMode is perContext', () => {
    const a = computeSessionId({
      ...baseConfig,
      sessionMode: 'perContext',
      openContext: { source: 'product-page', sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      sessionMode: 'perContext',
      openContext: { source: 'product-page', sku: '123' },
    });

    expect(a).toBe(b);
  });

  it('returns different sessionIds when openContext differs and sessionMode is perContext', () => {
    const a = computeSessionId({
      ...baseConfig,
      sessionMode: 'perContext',
      openContext: { source: 'product-page', sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      sessionMode: 'perContext',
      openContext: { source: 'product-page', sku: '456' },
    });

    expect(a).not.toBe(b);
  });

  it('ignores openContext when sessionMode is unset', () => {
    const withContext = computeSessionId({
      ...baseConfig,
      openContext: { sku: '123' },
    });
    const withoutContext = computeSessionId(baseConfig);

    expect(withContext).toBe(withoutContext);
  });

  it('ignores openContext when sessionMode is shared', () => {
    expect(
      computeSessionId({
        ...baseConfig,
        sessionMode: 'shared',
        openContext: { sku: '123' },
      })
    ).toBe('org-1-ch-1-anonymous');
  });

  it('keeps the legacy sessionId shape when no openContext is provided', () => {
    expect(computeSessionId(baseConfig)).toBe('org-1-ch-1-anonymous');
  });

  it('includes the userId when provided and no openContext is set', () => {
    expect(computeSessionId({ ...baseConfig, userId: 'user-9' })).toBe(
      'org-1-ch-1-user-9'
    );
  });

  it('appends the openContext hash to the userId-keyed base when both are provided and sessionMode is perContext', () => {
    expect(
      computeSessionId({
        ...baseConfig,
        sessionMode: 'perContext',
        userId: 'user-9',
        openContext: { sku: '123' },
      })
    ).toMatch(/^org-1-ch-1-user-9-[0-9a-z]+$/);
  });

  it('does not collapse two different users to the same sessionId when their openContext is identical', () => {
    const a = computeSessionId({
      ...baseConfig,
      sessionMode: 'perContext',
      userId: 'user-9',
      openContext: { sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      sessionMode: 'perContext',
      userId: 'user-10',
      openContext: { sku: '123' },
    });

    expect(a).not.toBe(b);
  });

  it('appends the ephemeral token to the anonymous base when sessionMode is ephemeral', () => {
    expect(
      computeSessionId(
        { ...baseConfig, sessionMode: 'ephemeral' },
        'token-abc'
      )
    ).toBe('org-1-ch-1-anonymous-token-abc');
  });

  it('appends the ephemeral token to the userId base when sessionMode is ephemeral', () => {
    expect(
      computeSessionId(
        { ...baseConfig, sessionMode: 'ephemeral', userId: 'user-9' },
        'token-abc'
      )
    ).toBe('org-1-ch-1-user-9-token-abc');
  });

  it('ignores openContext when sessionMode is ephemeral', () => {
    expect(
      computeSessionId(
        {
          ...baseConfig,
          sessionMode: 'ephemeral',
          openContext: { sku: '123' },
        },
        'token-abc'
      )
    ).toBe('org-1-ch-1-anonymous-token-abc');
  });
});

describe('computeEffectiveAuthUserId', () => {
  it('returns undefined when no userId is provided, even with openContext and sessionMode on', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        sessionMode: 'perContext',
        openContext: { sku: 'A' },
      })
    ).toBeUndefined();
  });

  it('returns the original userId unchanged when no openContext is provided', () => {
    expect(
      computeEffectiveAuthUserId({ ...baseConfig, userId: 'u1' })
    ).toBe('u1');
  });

  it('returns the original userId unchanged when sessionMode is unset', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        userId: 'u1',
        openContext: { sku: 'A' },
      })
    ).toBe('u1');
  });

  it('appends the openContext hash to the userId when both are provided and sessionMode is perContext', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        sessionMode: 'perContext',
        userId: 'u1',
        openContext: { sku: 'A' },
      })
    ).toMatch(/^u1-[0-9a-z]+$/);
  });

  it('returns the same effective userId for two identical openContexts', () => {
    const config: YaloChatClientConfig = {
      ...baseConfig,
      sessionMode: 'perContext',
      userId: 'u1',
    };
    const a = computeEffectiveAuthUserId({
      ...config,
      openContext: { sku: 'A' },
    });
    const b = computeEffectiveAuthUserId({
      ...config,
      openContext: { sku: 'A' },
    });

    expect(a).toBe(b);
  });

  it('returns different effective userIds when openContext differs', () => {
    const config: YaloChatClientConfig = {
      ...baseConfig,
      sessionMode: 'perContext',
      userId: 'u1',
    };
    const a = computeEffectiveAuthUserId({
      ...config,
      openContext: { sku: 'A' },
    });
    const b = computeEffectiveAuthUserId({
      ...config,
      openContext: { sku: 'B' },
    });

    expect(a).not.toBe(b);
  });

  it('appends the ephemeral token to the userId when sessionMode is ephemeral', () => {
    expect(
      computeEffectiveAuthUserId(
        { ...baseConfig, sessionMode: 'ephemeral', userId: 'u1' },
        'token-abc'
      )
    ).toBe('u1-token-abc');
  });

  it('returns undefined for an anonymous ephemeral session so the backend mints a fresh identity', () => {
    expect(
      computeEffectiveAuthUserId(
        { ...baseConfig, sessionMode: 'ephemeral' },
        'token-abc'
      )
    ).toBeUndefined();
  });
});
