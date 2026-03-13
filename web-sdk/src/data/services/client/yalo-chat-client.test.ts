// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatWindow } from '@ui/chat/chat-window/chat-window';
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

  beforeEach(() => {
    targetEl = document.createElement('button');
    targetEl.id = baseConfig.target;
    document.body.appendChild(targetEl);
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.restoreAllMocks();
  });

  describe('init', () => {
    it('appends yalo-chat-window to the document body', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      expect(getChatWindow()).not.toBeNull();
    });

    it('sets config on the chat window element', () => {
      const client = new YaloChatClient({
        ...baseConfig,
        icons: { send: '<i>custom</i>' },
      });
      client.init();
      expect(getChatWindow().config.channelId).toBe(baseConfig.channelId);
      expect(getChatWindow().config.icons?.send).toBe('<i>custom</i>');
    });

    it('warns when target element is not found', () => {
      const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
      const client = new YaloChatClient({
        ...baseConfig,
        target: 'nonexistent',
      });
      client.init();
      expect(warn).toHaveBeenCalledWith(
        `Target element "#nonexistent" not found. Chat window will not work.`
      );
    });

    it('opens chat when target is clicked and chat is closed', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      targetEl.click();
      expect(getChatWindow().open).toBe(true);
    });

    it('closes chat when target is clicked and chat is open', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      client.open();
      targetEl.click();
      expect(getChatWindow().open).toBe(false);
    });

    it('closes chat on yalo-chat-close event', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      client.open();
      getChatWindow().dispatchEvent(new Event('yalo-chat-close'));
      expect(getChatWindow().open).toBe(false);
    });
  });

  describe('open', () => {
    it('sets open to true on the chat window', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      client.open();
      expect(getChatWindow().open).toBe(true);
    });

    it('adds open class to target element', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      client.open();
      expect(targetEl.classList.contains('open')).toBe(true);
    });
  });

  describe('close', () => {
    it('sets open to false on the chat window', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      client.open();
      client.close();
      expect(getChatWindow().open).toBe(false);
    });

    it('removes open class from target element', () => {
      const client = new YaloChatClient(baseConfig);
      client.init();
      client.open();
      client.close();
      expect(targetEl.classList.contains('open')).toBe(false);
    });
  });
});
