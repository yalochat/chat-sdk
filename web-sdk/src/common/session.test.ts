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
  it('returns the same sessionId for two configs with the same openContext when differentSessionPerContext is true', () => {
    const a = computeSessionId({
      ...baseConfig,
      differentSessionPerContext: true,
      openContext: { source: 'product-page', sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      differentSessionPerContext: true,
      openContext: { source: 'product-page', sku: '123' },
    });

    expect(a).toBe(b);
  });

  it('returns different sessionIds when openContext differs and differentSessionPerContext is true', () => {
    const a = computeSessionId({
      ...baseConfig,
      differentSessionPerContext: true,
      openContext: { source: 'product-page', sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      differentSessionPerContext: true,
      openContext: { source: 'product-page', sku: '456' },
    });

    expect(a).not.toBe(b);
  });

  it('ignores openContext when differentSessionPerContext is unset', () => {
    const withContext = computeSessionId({
      ...baseConfig,
      openContext: { sku: '123' },
    });
    const withoutContext = computeSessionId(baseConfig);

    expect(withContext).toBe(withoutContext);
  });

  it('ignores openContext when differentSessionPerContext is explicitly false', () => {
    expect(
      computeSessionId({
        ...baseConfig,
        differentSessionPerContext: false,
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

  it('appends the openContext hash to the userId-keyed base when both are provided and the flag is on', () => {
    expect(
      computeSessionId({
        ...baseConfig,
        differentSessionPerContext: true,
        userId: 'user-9',
        openContext: { sku: '123' },
      })
    ).toMatch(/^org-1-ch-1-user-9-[0-9a-z]+$/);
  });

  it('does not collapse two different users to the same sessionId when their openContext is identical', () => {
    const a = computeSessionId({
      ...baseConfig,
      differentSessionPerContext: true,
      userId: 'user-9',
      openContext: { sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      differentSessionPerContext: true,
      userId: 'user-10',
      openContext: { sku: '123' },
    });

    expect(a).not.toBe(b);
  });
});

describe('computeEffectiveAuthUserId', () => {
  it('returns undefined when no userId is provided, even with openContext and the flag on', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        differentSessionPerContext: true,
        openContext: { sku: 'A' },
      })
    ).toBeUndefined();
  });

  it('returns the original userId unchanged when no openContext is provided', () => {
    expect(
      computeEffectiveAuthUserId({ ...baseConfig, userId: 'u1' })
    ).toBe('u1');
  });

  it('returns the original userId unchanged when differentSessionPerContext is unset', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        userId: 'u1',
        openContext: { sku: 'A' },
      })
    ).toBe('u1');
  });

  it('appends the openContext hash to the userId when both are provided and the flag is on', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        differentSessionPerContext: true,
        userId: 'u1',
        openContext: { sku: 'A' },
      })
    ).toMatch(/^u1-[0-9a-z]+$/);
  });

  it('returns the same effective userId for two identical openContexts', () => {
    const config = {
      ...baseConfig,
      differentSessionPerContext: true,
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
    const config = {
      ...baseConfig,
      differentSessionPerContext: true,
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
});
