// Copyright (c) Yalochat, Inc. All rights reserved.

import { describe, expect, it } from 'vitest';
import { parseArgs, UsageError } from './args';

const ids = ['--channel-id', 'ch-1', '--org-id', 'org-1'];

describe('parseArgs', () => {
  it('returns help with no arguments or -h', () => {
    expect(parseArgs([])).toEqual({ command: 'help' });
    expect(parseArgs(['send', '-h'])).toEqual({ command: 'help' });
  });

  it('parses send with defaults', () => {
    expect(parseArgs(['send', 'hola', 'mundo', ...ids])).toEqual({
      command: 'send',
      text: 'hola mundo',
      waitMs: 30_000,
      quietMs: 20_000,
      common: {
        env: 'prod',
        channelId: 'ch-1',
        organizationId: 'org-1',
        userId: undefined,
        context: undefined,
        json: false,
      },
    });
  });

  it('parses chat with every option', () => {
    const parsed = parseArgs([
      'chat',
      ...ids,
      '--env',
      'staging',
      '--user-id',
      'u-1',
      '--context',
      '{"sku":"123"}',
      '--json',
    ]);
    expect(parsed).toEqual({
      command: 'chat',
      common: {
        env: 'staging',
        channelId: 'ch-1',
        organizationId: 'org-1',
        userId: 'u-1',
        context: '{"sku":"123"}',
        json: true,
      },
    });
  });

  it('converts --wait and --quiet from seconds', () => {
    const parsed = parseArgs([
      'send',
      'x',
      ...ids,
      '--wait',
      '5',
      '--quiet',
      '1.5',
    ]);
    expect(parsed).toMatchObject({ waitMs: 5000, quietMs: 1500 });
  });

  it.each([
    [['send', 'x'], '--channel-id and --org-id are required'],
    [['send', ...ids], 'send needs the text to send'],
    [['send', 'x', ...ids, '--env', 'dev'], '--env must be prod or staging'],
    [
      ['send', 'x', ...ids, '--context', '{bad'],
      '--context must be valid JSON',
    ],
    [['send', 'x', ...ids, '--wait', '0'], '--wait must be a positive number'],
    [['send', 'x', ...ids, '--nope'], 'unknown option --nope'],
    [['send', 'x', '--channel-id'], '--channel-id needs a value'],
    [['talk', ...ids], 'unknown command talk'],
  ])('rejects %j', (argv, message) => {
    expect(() => parseArgs(argv)).toThrow(UsageError);
    expect(() => parseArgs(argv)).toThrow(message);
  });
});
