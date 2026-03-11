// Copyright (c) Yalochat, Inc. All rights reserved.

import type { LitElement } from 'lit';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import './chat-window';
import type { YaloChatWindow } from './chat-window';

const baseConfig = {
  channelId: 'channel-1',
  organizationId: 'org-1',
  channelName: 'Test Chat',
  target: 'chat-target',
};

const createElement = async (): Promise<YaloChatWindow> => {
  const el = document.createElement('yalo-chat-window') as YaloChatWindow;
  el.config = baseConfig;
  document.body.appendChild(el);
  await el.updateComplete;
  return el;
};

const getFooter = (el: YaloChatWindow): LitElement =>
  el.shadowRoot?.querySelector('chat-footer') as unknown as LitElement;

const getTextarea = (el: YaloChatWindow): HTMLTextAreaElement =>
  getFooter(el).shadowRoot?.querySelector(
    '.chat-input',
  ) as unknown as HTMLTextAreaElement;

const getSendButton = (el: YaloChatWindow): HTMLButtonElement =>
  getFooter(el).shadowRoot?.querySelector(
    '.chat-send-button',
  ) as unknown as HTMLButtonElement;

describe('YaloChatWindow', () => {
  let el: YaloChatWindow;

  beforeEach(async () => {
    el = await createElement();
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('open/close', () => {
    it('is closed by default', () => {
      expect(el.open).toBe(false);
      expect(el.hasAttribute('open')).toBe(false);
    });

    it('reflects open attribute when opened', async () => {
      el.open = true;
      await el.updateComplete;
      expect(el.hasAttribute('open')).toBe(true);
    });

    it('removes open attribute when closed', async () => {
      el.open = true;
      await el.updateComplete;
      el.open = false;
      await el.updateComplete;
      expect(el.hasAttribute('open')).toBe(false);
    });

    it('closes and dispatches yalo-chat-close when header close button is clicked', async () => {
      el.open = true;
      await el.updateComplete;

      const header = el.shadowRoot?.querySelector('chat-header') as LitElement;
      await header.updateComplete;

      const closed = new Promise<void>((resolve) => {
        el.addEventListener('yalo-chat-close', () => resolve(), { once: true });
      });

      header.shadowRoot
        ?.querySelector<HTMLButtonElement>('.chat-close-btn')
        ?.click();

      await closed;
      expect(el.open).toBe(false);
    });
  });

  describe('sending messages', () => {
    it('emits yalo-chat-send-text-message when send button is clicked', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Hello world';

      const received = new Promise<string>((resolve) => {
        el.addEventListener(
          'yalo-chat-send-text-message',
          (e) => resolve((e as CustomEvent<string>).detail),
          { once: true },
        );
      });

      getSendButton(el).click();

      expect(await received).toBe('Hello world');
    });

    it('clears the textarea after sending', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Hello world';
      getSendButton(el).click();

      expect(textarea.value).toBe('');
    });

    it('does not emit when textarea is empty', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      let emitted = false;
      el.addEventListener('yalo-chat-send-text-message', () => {
        emitted = true;
      });

      getSendButton(el).click();

      expect(emitted).toBe(false);
    });

    it('does not emit when textarea contains only whitespace', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      let emitted = false;
      el.addEventListener('yalo-chat-send-text-message', () => {
        emitted = true;
      });

      getTextarea(el).value = '   ';
      getSendButton(el).click();

      expect(emitted).toBe(false);
    });

    it('emits on Enter key', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Via keyboard';

      const received = new Promise<string>((resolve) => {
        el.addEventListener(
          'yalo-chat-send-text-message',
          (e) => resolve((e as CustomEvent<string>).detail),
          { once: true },
        );
      });

      textarea.dispatchEvent(
        new KeyboardEvent('keydown', {
          key: 'Enter',
          bubbles: true,
          composed: true,
        }),
      );

      expect(await received).toBe('Via keyboard');
    });

    it('does not emit on Shift+Enter', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      let emitted = false;
      el.addEventListener('yalo-chat-send-text-message', () => {
        emitted = true;
      });

      const textarea = getTextarea(el);
      textarea.value = 'Draft';
      textarea.dispatchEvent(
        new KeyboardEvent('keydown', {
          key: 'Enter',
          shiftKey: true,
          bubbles: true,
          composed: true,
        }),
      );

      expect(emitted).toBe(false);
    });
  });

  describe('chat-footer expansion', () => {
    it('sets overflow-y to scroll when text exceeds max height', async () => {
      el.open = true;
      await el.updateComplete;

      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true }),
      );

      expect(textarea.style.overflowY).toBe('scroll');
    });

    it('grows the textarea height when long text is entered', async () => {
      el.open = true;
      await el.updateComplete;

      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      const initialHeight = textarea.scrollHeight;

      textarea.value = 'Line 1\nLine 2\nLine 3';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true }),
      );

      expect(textarea.scrollHeight).toBeGreaterThan(initialHeight);
    });

    it('resets textarea height after sending', async () => {
      el.open = true;
      await el.updateComplete;

      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Line 1\nLine 2\nLine 3';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true }),
      );

      getSendButton(el).click();

      expect(textarea.style.height).toBe('auto');
    });
  });
});
