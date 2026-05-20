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
    it('appends the chat window inside the target element', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(targetEl.querySelector('yalo-chat-window')).not.toBeNull();
    });

    it('does not open the chat window automatically', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(getChatWindow().open).toBe(false);
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

    it('does not bind a click handler to the target element', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
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

    it('forwards the configured openContext to the chat window', async () => {
      const client = new YaloChatClient({
        ...baseConfig,
        openContext: 'product-page',
      });
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      expect(getChatWindow().openContext).toBe('product-page');
    });

    it('leaves openContext undefined when not configured', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      expect(getChatWindow().openContext).toBeUndefined();
    });

    it('invokes the onOpen handler after opening', async () => {
      const client = new YaloChatClient(baseConfig);
      const onOpen = vi.fn(() => {
        expect(getChatWindow().open).toBe(true);
      });
      client.init({ onOpen });
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      expect(onOpen).toHaveBeenCalledOnce();
    });

    it('does not invoke onOpen until open is called', async () => {
      const client = new YaloChatClient(baseConfig);
      const onOpen = vi.fn();
      client.init({ onOpen });
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(onOpen).not.toHaveBeenCalled();
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

    it('invokes the onClose handler after closing programmatically', async () => {
      const client = new YaloChatClient(baseConfig);
      const onClose = vi.fn(() => {
        expect(getChatWindow().open).toBe(false);
      });
      client.init({ onClose });
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      client.close();
      expect(onClose).toHaveBeenCalledOnce();
    });

    it('invokes the onClose handler when closed via the yalo-chat-close event', async () => {
      const client = new YaloChatClient(baseConfig);
      const onClose = vi.fn();
      client.init({ onClose });
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.open();
      getChatWindow().dispatchEvent(new Event('yalo-chat-close'));
      expect(onClose).toHaveBeenCalledOnce();
    });
  });

  describe('dispose', () => {
    it('removes the chat window from the DOM', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.dispose();
      expect(document.querySelector('yalo-chat-window')).toBeNull();
    });

    it('clears the chatWindowEl reference', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.dispose();
      expect(client.chatWindowEl).toBeNull();
    });

    it('unsubscribes the message stream', async () => {
      const { YaloMessageRepositoryRemote } = await import(
        '@data/repositories/yalo-message/yalo-message-repository-remote'
      );
      const unsubscribeSpy = vi.spyOn(
        YaloMessageRepositoryRemote.prototype,
        'unsubscribeMessages'
      );
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.dispose();
      expect(unsubscribeSpy).toHaveBeenCalled();
    });

    it('is safe to call before init', () => {
      const client = new YaloChatClient(baseConfig);
      expect(() => client.dispose()).not.toThrow();
    });

    it('allows re-initializing after dispose', async () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      client.dispose();
      client.init();
      await vi.waitUntil(
        () => client.chatWindowEl?.yaloMessageRepository != null
      );
      expect(targetEl.querySelector('yalo-chat-window')).not.toBeNull();
    });
  });
});
