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
  it('returns the same sessionId for two configs with the same openContext', () => {
    const a = computeSessionId({
      ...baseConfig,
      openContext: { source: 'product-page', sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      openContext: { source: 'product-page', sku: '123' },
    });

    expect(a).toBe(b);
  });

  it('returns different sessionIds when openContext differs', () => {
    const a = computeSessionId({
      ...baseConfig,
      openContext: { source: 'product-page', sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      openContext: { source: 'product-page', sku: '456' },
    });

    expect(a).not.toBe(b);
  });

  it('keeps the legacy sessionId shape when no openContext is provided', () => {
    expect(computeSessionId(baseConfig)).toBe('org-1-ch-1-anonymous');
  });

  it('includes the userId when provided and no openContext is set', () => {
    expect(computeSessionId({ ...baseConfig, userId: 'user-9' })).toBe(
      'org-1-ch-1-user-9'
    );
  });

  it('appends the openContext hash to the userId-keyed base when both are provided', () => {
    expect(
      computeSessionId({
        ...baseConfig,
        userId: 'user-9',
        openContext: { sku: '123' },
      })
    ).toMatch(/^org-1-ch-1-user-9-[0-9a-z]+$/);
  });

  it('does not collapse two different users to the same sessionId when their openContext is identical', () => {
    const a = computeSessionId({
      ...baseConfig,
      userId: 'user-9',
      openContext: { sku: '123' },
    });
    const b = computeSessionId({
      ...baseConfig,
      userId: 'user-10',
      openContext: { sku: '123' },
    });

    expect(a).not.toBe(b);
  });
});

describe('computeEffectiveAuthUserId', () => {
  it('returns undefined when no userId is provided, even with openContext', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        openContext: { sku: 'A' },
      })
    ).toBeUndefined();
  });

  it('returns the original userId unchanged when no openContext is provided', () => {
    expect(
      computeEffectiveAuthUserId({ ...baseConfig, userId: 'u1' })
    ).toBe('u1');
  });

  it('appends the openContext hash to the userId when both are provided', () => {
    expect(
      computeEffectiveAuthUserId({
        ...baseConfig,
        userId: 'u1',
        openContext: { sku: 'A' },
      })
    ).toMatch(/^u1-[0-9a-z]+$/);
  });

  it('returns the same effective userId for two identical openContexts', () => {
    const config = { ...baseConfig, userId: 'u1' };
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
    const config = { ...baseConfig, userId: 'u1' };
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
