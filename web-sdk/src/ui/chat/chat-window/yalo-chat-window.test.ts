// Copyright (c) Yalochat, Inc. All rights reserved.

import type { LitElement } from 'lit';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import './yalo-chat-window';
import type { YaloChatWindow } from './yalo-chat-window';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { Err, Ok } from '@domain/common/result';

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
  // hostConnected is async wait until it finishes setting up the repositories
  await vi.waitUntil(() => el.yaloMessageRepository !== undefined);
  return el;
};

const getFooter = (el: YaloChatWindow): LitElement =>
  el.shadowRoot?.querySelector('chat-footer') as unknown as LitElement;

const getTextarea = (el: YaloChatWindow): HTMLTextAreaElement =>
  getFooter(el).shadowRoot?.querySelector(
    '.chat-input'
  ) as unknown as HTMLTextAreaElement;

const getSendButton = (el: YaloChatWindow): HTMLButtonElement =>
  getFooter(el).shadowRoot?.querySelector(
    '.chat-action-button'
  ) as unknown as HTMLButtonElement;

const DB_NAME = 'YaloChatMessages';

const clearDb = (): Promise<void> =>
  new Promise((resolve, reject) => {
    const open = indexedDB.open(DB_NAME);
    open.onerror = () => reject(open.error);
    open.onsuccess = () => {
      const db = open.result;
      const stores = Array.from(db.objectStoreNames);
      if (stores.length === 0) {
        db.close();
        resolve();
        return;
      }
      const tx = db.transaction(stores, 'readwrite');
      tx.oncomplete = () => {
        db.close();
        resolve();
      };
      tx.onerror = () => {
        db.close();
        reject(tx.error);
      };
      for (const name of stores) {
        tx.objectStore(name).clear();
      }
    };
  });

describe('YaloChatWindow', () => {
  let el: YaloChatWindow;

  beforeEach(async () => {
    el = await createElement();
  });

  afterEach(async () => {
    document.body.innerHTML = '';
    await clearDb();
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
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true })
      );
      await footer.updateComplete;

      const received = new Promise<ChatMessage>((resolve) => {
        el.addEventListener(
          'yalo-chat-send-text-message',
          (e) => resolve((e as CustomEvent<ChatMessage>).detail),
          { once: true }
        );
      });

      getSendButton(el).click();

      const message = await received;
      expect(message.content).toBe('Hello world');
      expect(message.role).toBe('USER');
      expect(message.type).toBe('text');
      expect(message.status).toBe('IN_PROGRESS');
      expect(message.timestamp).toBeInstanceOf(Date);
    });

    it('clears the textarea after sending', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Hello world';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true })
      );
      await footer.updateComplete;
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

      const received = new Promise<ChatMessage>((resolve) => {
        el.addEventListener(
          'yalo-chat-send-text-message',
          (e) => resolve((e as CustomEvent<ChatMessage>).detail),
          { once: true }
        );
      });

      textarea.dispatchEvent(
        new KeyboardEvent('keydown', {
          key: 'Enter',
          bubbles: true,
          composed: true,
        })
      );

      expect((await received).content).toBe('Via keyboard');
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
        })
      );

      expect(emitted).toBe(false);
    });
  });

  describe('error display', () => {
    it('marks message as ERROR when remote insert fails', async () => {
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Err(new Error('network down'))
      );

      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Will fail';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true })
      );
      await footer.updateComplete;

      getSendButton(el).click();

      await vi.waitUntil(() => {
        const messages = el.shadowRoot
          ?.querySelector('chat-message-list') as unknown as {
          chatMessages: ChatMessage[];
        };
        return messages?.chatMessages?.[0]?.status === 'ERROR';
      });

      const list = el.shadowRoot?.querySelector(
        'chat-message-list'
      ) as unknown as { chatMessages: ChatMessage[] };

      expect(list.chatMessages[0]).toMatchObject({
        content: 'Will fail',
        status: 'ERROR',
      });

      const persisted = await el.chatMessageRepository.getChatMessagePageDesc(
        null,
        10
      );
      expect(persisted.ok && persisted.value.data[0]).toMatchObject({
        content: 'Will fail',
        status: 'ERROR',
      });
    });

    const findById = (
      list: { chatMessages: ChatMessage[] },
      id: number | undefined
    ): ChatMessage | undefined =>
      list.chatMessages.find((m) => m.id === id);

    it('retries an errored message and clears the error on success', async () => {
      const insertSpy = vi
        .spyOn(el.yaloMessageRepository, 'insertMessage')
        .mockResolvedValueOnce(new Err(new Error('network down')));

      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Retry me';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true })
      );
      await footer.updateComplete;
      getSendButton(el).click();

      const list = el.shadowRoot?.querySelector(
        'chat-message-list'
      ) as unknown as { chatMessages: ChatMessage[] };

      await vi.waitUntil(() =>
        list.chatMessages.some(
          (m) => m.content === 'Retry me' && m.status === 'ERROR'
        )
      );
      const errored = list.chatMessages.find(
        (m) => m.content === 'Retry me' && m.status === 'ERROR'
      ) as ChatMessage;
      const erroredId = errored.id;

      insertSpy.mockResolvedValueOnce(new Ok(errored));

      el.shadowRoot
        ?.querySelector('chat-message-list')
        ?.dispatchEvent(
          new CustomEvent('yalo-chat-retry-message', {
            detail: errored,
            bubbles: true,
            composed: true,
          })
        );

      await vi.waitUntil(
        () => findById(list, erroredId)?.status === 'IN_PROGRESS'
      );

      expect(insertSpy).toHaveBeenCalledTimes(2);
      expect(findById(list, erroredId)).toMatchObject({
        id: erroredId,
        content: 'Retry me',
        status: 'IN_PROGRESS',
      });

      const persisted = await el.chatMessageRepository.getChatMessagePageDesc(
        null,
        100
      );
      const persistedMessage =
        persisted.ok && persisted.value.data.find((m) => m.id === erroredId);
      expect(persistedMessage).toMatchObject({
        id: erroredId,
        content: 'Retry me',
        status: 'IN_PROGRESS',
      });
    });

    it('keeps the message in ERROR when retry fails again', async () => {
      const insertSpy = vi
        .spyOn(el.yaloMessageRepository, 'insertMessage')
        .mockResolvedValue(new Err(new Error('still down')));

      const footer = getFooter(el);
      await footer.updateComplete;

      const textarea = getTextarea(el);
      textarea.value = 'Stays errored';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true })
      );
      await footer.updateComplete;
      getSendButton(el).click();

      const list = el.shadowRoot?.querySelector(
        'chat-message-list'
      ) as unknown as { chatMessages: ChatMessage[] };

      await vi.waitUntil(() =>
        list.chatMessages.some(
          (m) => m.content === 'Stays errored' && m.status === 'ERROR'
        )
      );
      const errored = list.chatMessages.find(
        (m) => m.content === 'Stays errored' && m.status === 'ERROR'
      ) as ChatMessage;
      const erroredId = errored.id;

      el.shadowRoot
        ?.querySelector('chat-message-list')
        ?.dispatchEvent(
          new CustomEvent('yalo-chat-retry-message', {
            detail: errored,
            bubbles: true,
            composed: true,
          })
        );

      await vi.waitUntil(() => insertSpy.mock.calls.length >= 2);
      await vi.waitUntil(() => findById(list, erroredId)?.status === 'ERROR');

      expect(findById(list, erroredId)).toMatchObject({
        id: erroredId,
        status: 'ERROR',
      });
    });
  });

  describe('sizing', () => {
    it('respects --yalo-chat-width and --yalo-chat-height overrides', async () => {
      el.open = true;
      el.style.setProperty('--yalo-chat-width', '320px');
      el.style.setProperty('--yalo-chat-height', '600px');
      await el.updateComplete;

      expect(getComputedStyle(el)).toMatchObject({
        width: '320px',
        height: '600px',
      });
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
        new Event('input', { bubbles: true, composed: true })
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
        new Event('input', { bubbles: true, composed: true })
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
        new Event('input', { bubbles: true, composed: true })
      );

      getSendButton(el).click();

      expect(textarea.style.height).toBe('auto');
    });
  });
});
