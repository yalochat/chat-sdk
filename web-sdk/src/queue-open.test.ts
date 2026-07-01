// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatWindow } from '@ui/chat/chat-window/yalo-chat-window';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { installYaloOpenQueue } from './queue-open';

const baseConfig = {
  channelId: 'channel-1',
  organizationId: 'org-1',
  channelName: 'Test Chat',
  target: 'chat-target',
};

const getChatWindow = () =>
  document.body.querySelector('yalo-chat-window') as YaloChatWindow;

const waitForChatWindow = () =>
  vi.waitUntil(() => getChatWindow()?.yaloMessageRepository != null);

describe('installYaloOpenQueue', () => {
  beforeEach(() => {
    const target = document.createElement('div');
    target.id = baseConfig.target;
    document.body.appendChild(target);
  });

  afterEach(() => {
    document.body.innerHTML = '';
    delete window.yaloOpen;
    vi.restoreAllMocks();
  });

  it('does nothing when window.yaloOpen is undefined', () => {
    installYaloOpenQueue();
    expect(getChatWindow()).toBeNull();
  });

  it('drains a prefilled array and opens a chat window per config', async () => {
    window.yaloOpen = [baseConfig];
    installYaloOpenQueue();
    await waitForChatWindow();
    expect(getChatWindow().open).toBe(true);
  });

  it('opens one chat window per config in the prefilled array', async () => {
    const secondTarget = document.createElement('div');
    secondTarget.id = 'second-target';
    document.body.appendChild(secondTarget);
    window.yaloOpen = [
      baseConfig,
      { ...baseConfig, channelId: 'channel-2', target: 'second-target' },
    ];
    installYaloOpenQueue();
    await vi.waitUntil(() => {
      const windows = document.body.querySelectorAll('yalo-chat-window');
      return (
        windows.length === 2 &&
        Array.from(windows).every(
          (window) => (window as YaloChatWindow).yaloMessageRepository != null
        )
      );
    });
    expect(document.body.querySelectorAll('yalo-chat-window')).toHaveLength(2);
  });

  it('replaces window.yaloOpen with a queue exposing push', () => {
    installYaloOpenQueue();
    expect(typeof window.yaloOpen).toBe('object');
    expect(typeof (window.yaloOpen as { push: unknown }).push).toBe('function');
  });

  it('opens a chat window when push is called after install', async () => {
    installYaloOpenQueue();
    (window.yaloOpen as { push: (c: typeof baseConfig) => void }).push(
      baseConfig
    );
    await waitForChatWindow();
    expect(getChatWindow().open).toBe(true);
  });

  it('runs onOpen from a prefilled config when the chat opens', async () => {
    const onOpen = vi.fn();
    window.yaloOpen = [{ ...baseConfig, onOpen }];
    installYaloOpenQueue();
    await waitForChatWindow();
    expect(onOpen).toHaveBeenCalledTimes(1);
  });

  it('runs onClose from a pushed config when the chat closes', async () => {
    const onClose = vi.fn();
    installYaloOpenQueue();
    (
      window.yaloOpen as { push: (c: typeof baseConfig & { onClose: () => void }) => void }
    ).push({ ...baseConfig, onClose });
    await waitForChatWindow();
    getChatWindow().dispatchEvent(new CustomEvent('yalo-chat-close'));
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('registers commands from registerCommands in the config', async () => {
    const updateCallback = vi.fn();
    const clearCallback = vi.fn();
    window.yaloOpen = [
      {
        ...baseConfig,
        registerCommands: {
          updateCartProduct: updateCallback,
          clearCart: clearCallback,
        },
      },
    ];
    installYaloOpenQueue();
    await waitForChatWindow();
    expect(getChatWindow().commands).toMatchObject(
      new Map([
        ['updateCartProduct', updateCallback],
        ['clearCart', clearCallback],
      ])
    );
  });

  it('registers channel command handlers from onCommand in the config', async () => {
    const getCart = vi.fn();
    installYaloOpenQueue();
    (
      window.yaloOpen as {
        push: (c: typeof baseConfig & { onCommand: Record<string, () => void> }) => void;
      }
    ).push({ ...baseConfig, onCommand: { getCart } });
    await waitForChatWindow();
    expect(getChatWindow().channelCommands.get('getCart')).toBe(getCart);
  });

  it('opens normally when no command options are provided', async () => {
    window.yaloOpen = [baseConfig];
    installYaloOpenQueue();
    await waitForChatWindow();
    expect(getChatWindow().commands.size).toBe(0);
    expect(getChatWindow().channelCommands.size).toBe(0);
  });

  it('ignores a non-array existing window.yaloOpen value', () => {
    (window as unknown as { yaloOpen: unknown }).yaloOpen =
      'not-an-array' as unknown;
    installYaloOpenQueue();
    expect(getChatWindow()).toBeNull();
    expect(typeof (window.yaloOpen as { push: unknown }).push).toBe('function');
  });
});
