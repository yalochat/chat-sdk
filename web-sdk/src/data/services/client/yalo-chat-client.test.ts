// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatWindow } from '@ui/chat/chat-window/yalo-chat-window';
import type { ChatCommand } from '@domain/models/command/chat-command';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import YaloChatClient from './yalo-chat-client';

const baseConfig = {
  channelId: 'channel-1',
  organizationId: 'org-1',
  channelName: 'Test Chat',
  target: 'chat-target',
};

const getChatWindow = () =>
  document.body.querySelector('yalo-chat-window') as YaloChatWindow;

describe('YaloChatClient', () => {
  let targetEl: HTMLButtonElement;

  beforeEach(async () => {
    targetEl = document.createElement('button');
    targetEl.id = baseConfig.target;
    document.body.appendChild(targetEl);
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.restoreAllMocks();
  });

  describe('init', () => {
    it('appends yalo-chat-window to the document body', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(getChatWindow()).not.toBeNull();
    });

    it('sets config on the chat window element', async () => {
      const client = new YaloChatClient({
        ...baseConfig,
        icons: { send: '<i>custom</i>' },
      });
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(getChatWindow().config.channelId).toBe(baseConfig.channelId);
      expect(getChatWindow().config.icons?.send).toBe('<i>custom</i>');
    });

    it('warns when target element is not found', async () => {
      const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
      const client = new YaloChatClient({
        ...baseConfig,
        target: 'nonexistent',
      });
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(warn).toHaveBeenCalledWith(
        `Target element "#nonexistent" not found. Chat window will not work.`
      );
    });

    it('opens chat when target is clicked and chat is closed', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      targetEl.click();
      expect(getChatWindow().open).toBe(true);
    });

    it('closes chat when target is clicked and chat is open', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      targetEl.click();
      expect(getChatWindow().open).toBe(false);
    });

    it('closes chat on yalo-chat-close event', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      getChatWindow().dispatchEvent(new Event('yalo-chat-close'));
      expect(getChatWindow().open).toBe(false);
    });
  });

  describe('open', () => {
    it('sets open to true on the chat window', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      expect(getChatWindow().open).toBe(true);
    });

    it('adds open class to target element', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      expect(targetEl.classList.contains('open')).toBe(true);
    });
  });

  describe('registerCommand', () => {
    it('stores the command and passes it to the chat window after init', async () => {
      const client = new YaloChatClient(baseConfig);
      const callback = vi.fn();
      client.registerCommand('addToCart', callback);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(getChatWindow().commands.get('addToCart')).toBe(callback);
    });

    it('updates the chat window when registering after init', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      const callback = vi.fn();
      client.registerCommand('removeFromCart', callback);
      expect(getChatWindow().commands.get('removeFromCart')).toBe(callback);
    });

    it('allows registering multiple commands', async () => {
      const client = new YaloChatClient(baseConfig);
      const addCallback = vi.fn();
      const removeCallback = vi.fn();
      client.registerCommand('addToCart', addCallback);
      client.registerCommand('removeFromCart', removeCallback);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(getChatWindow().commands).toMatchObject(
        new Map<ChatCommand, unknown>([
          ['addToCart', addCallback],
          ['removeFromCart', removeCallback],
        ])
      );
    });

    it('overwrites a previously registered command', async () => {
      const client = new YaloChatClient(baseConfig);
      const first = vi.fn();
      const second = vi.fn();
      client.registerCommand('clearCart', first);
      client.registerCommand('clearCart', second);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(getChatWindow().commands.get('clearCart')).toBe(second);
    });
  });

  describe('close', async () => {
    it('sets open to false on the chat window', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      client.close();
      expect(getChatWindow().open).toBe(false);
    });

    it('removes open class from target element', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      client.close();
      expect(targetEl.classList.contains('open')).toBe(false);
    });
  });
});
