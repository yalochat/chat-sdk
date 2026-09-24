// Copyright (c) Yalochat, Inc. All rights reserved.

import { describe, expect, it } from 'vitest';
import {
  PollMessageItem,
  type SdkMessage,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import { toJsonLine, toPrettyLine } from './format';

function item(message: Partial<SdkMessage>): PollMessageItem {
  return PollMessageItem.fromJSON({
    id: 'poll-1',
    date: '2026-09-24T12:58:30.000Z',
    userId: 'yalo_user_1',
    message,
  });
}

describe('format', () => {
  it('prints text with its buttons', () => {
    const line = toPrettyLine(
      item({
        textMessageRequest: {
          content: { text: 'Soy Juliet' },
          buttons: [{ text: 'Ver catálogo' }, { text: 'Ver promos' }],
        },
      } as unknown as Partial<SdkMessage>)
    );
    expect(line).toBe(
      '← [textMessageRequest] Soy Juliet [Ver catálogo | Ver promos]'
    );
  });

  it('summarizes products and commands', () => {
    const products = toPrettyLine(
      item({
        productMessageRequest: {
          products: [
            { sku: '1', name: 'Yerba' },
            { sku: '2', name: 'Mug' },
          ],
        },
      } as unknown as Partial<SdkMessage>)
    );
    expect(products).toBe('← [productMessageRequest] 2 products: Yerba, Mug');

    const command = toPrettyLine(
      item({
        customCommandRequest: { commandId: 'test-command' },
      } as unknown as Partial<SdkMessage>)
    );
    expect(command).toBe('← [customCommandRequest] command=test-command');
  });

  it('emits the raw SdkMessage as one JSON line', () => {
    const line = toJsonLine(
      item({
        textMessageRequest: { content: { text: 'hola' } },
      } as unknown as Partial<SdkMessage>)
    );
    const parsed = JSON.parse(line);
    expect(parsed.id).toBe('poll-1');
    expect(parsed.date).toBe('2026-09-24T12:58:30.000Z');
    expect(parsed.message.textMessageRequest.content.text).toBe('hola');
    expect(line).not.toContain('\n');
  });
});
