// Copyright (c) Yalochat, Inc. All rights reserved.

import type { LitElement } from 'lit';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import './yalo-chat-window';
import type { YaloChatWindow } from './yalo-chat-window';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import { Product } from '@domain/models/product/product';
import { Err, Ok } from '@domain/common/result';
import { ChatMessageRepositoryLocal } from '@data/repositories/chat-message/chat-message-repository-local';
import { YaloMessageRepositoryRemote } from '@data/repositories/yalo-message/yalo-message-repository-remote';
import type { PollCallback } from '@data/repositories/yalo-message/yalo-message-repository';

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

const getMessageList = (
  el: YaloChatWindow
): { chatMessages: ChatMessage[]; isLoading: boolean; isWriting: boolean } =>
  el.shadowRoot?.querySelector('chat-message-list') as unknown as {
    chatMessages: ChatMessage[];
    isLoading: boolean;
    isWriting: boolean;
  };

const getHeader = (el: YaloChatWindow): { statusMessage: string } =>
  el.shadowRoot?.querySelector('chat-header') as unknown as {
    statusMessage: string;
  };

const dispatchFromFooter = (
  el: YaloChatWindow,
  type: string,
  detail: unknown
): void => {
  getFooter(el).dispatchEvent(
    new CustomEvent(type, { detail, bubbles: true, composed: true })
  );
};

const dispatchFromList = (
  el: YaloChatWindow,
  type: string,
  detail?: unknown
): void => {
  el.shadowRoot
    ?.querySelector('chat-message-list')
    ?.dispatchEvent(
      new CustomEvent(type, { detail, bubbles: true, composed: true })
    );
};

const getInput = (el: YaloChatWindow): HTMLElement =>
  getFooter(el).shadowRoot?.querySelector(
    '.chat-input'
  ) as unknown as HTMLElement;

const typeInto = (input: HTMLElement, text: string): void => {
  input.textContent = text;
  input.dispatchEvent(new Event('input', { bubbles: true, composed: true }));
};

const getSendButton = (el: YaloChatWindow): HTMLButtonElement =>
  getFooter(el).shadowRoot?.querySelector(
    '.chat-action-button'
  ) as unknown as HTMLButtonElement;

const DB_NAME = `YaloChatMessages-${baseConfig.organizationId}-${baseConfig.channelId}-anonymous`;

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

    it('renders the close button by default', async () => {
      const header = el.shadowRoot?.querySelector('chat-header') as LitElement;
      await header.updateComplete;

      expect(
        header.shadowRoot?.querySelector('.chat-close-btn')
      ).not.toBeNull();
    });

    it('hides the close button when config.hideCloseButton is true', async () => {
      document.body.innerHTML = '';
      const hidden = document.createElement(
        'yalo-chat-window'
      ) as YaloChatWindow;
      hidden.config = { ...baseConfig, hideCloseButton: true };
      document.body.appendChild(hidden);
      await vi.waitUntil(() => hidden.yaloMessageRepository !== undefined);

      const header = hidden.shadowRoot?.querySelector(
        'chat-header'
      ) as LitElement;
      await header.updateComplete;

      expect(header.shadowRoot?.querySelector('.chat-close-btn')).toBeNull();
    });
  });

  describe('sending messages', () => {
    it('emits yalo-chat-send-text-message when send button is clicked', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      typeInto(getInput(el), 'Hello world');
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

    it('clears the input after sending', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      const input = getInput(el);
      typeInto(input, 'Hello world');
      await footer.updateComplete;
      getSendButton(el).click();

      expect(input.textContent).toBe('');
    });

    it('does not emit when the input is empty', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      let emitted = false;
      el.addEventListener('yalo-chat-send-text-message', () => {
        emitted = true;
      });

      getSendButton(el).click();

      expect(emitted).toBe(false);
    });

    it('does not emit when the input contains only whitespace', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      let emitted = false;
      el.addEventListener('yalo-chat-send-text-message', () => {
        emitted = true;
      });

      typeInto(getInput(el), '   ');
      getSendButton(el).click();

      expect(emitted).toBe(false);
    });

    it('emits on Enter key', async () => {
      const footer = getFooter(el);
      await footer.updateComplete;

      const input = getInput(el);
      input.textContent = 'Via keyboard';

      const received = new Promise<ChatMessage>((resolve) => {
        el.addEventListener(
          'yalo-chat-send-text-message',
          (e) => resolve((e as CustomEvent<ChatMessage>).detail),
          { once: true }
        );
      });

      input.dispatchEvent(
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

      const input = getInput(el);
      input.textContent = 'Draft';
      input.dispatchEvent(
        new KeyboardEvent('keydown', {
          key: 'Enter',
          shiftKey: true,
          bubbles: true,
          composed: true,
        })
      );

      expect(emitted).toBe(false);
    });

    it('does not add the message when local insert fails', async () => {
      const errorSpy = vi.spyOn(el.logger, 'error');
      vi.spyOn(
        el.chatMessageRepository,
        'insertChatMessage'
      ).mockResolvedValue(new Err(new Error('db full')));
      const remoteSpy = vi.spyOn(el.yaloMessageRepository, 'insertMessage');

      dispatchFromFooter(
        el,
        'yalo-chat-send-text-message',
        ChatMessage.text({
          role: 'USER',
          timestamp: new Date(),
          content: 'will not persist',
        })
      );

      await vi.waitUntil(() =>
        errorSpy.mock.calls.some(
          (c) => c[0] === 'Unable to insert message locally'
        )
      );
      expect(remoteSpy).not.toHaveBeenCalled();
      expect(getMessageList(el).chatMessages).toHaveLength(0);
    });
  });

  describe('error display', () => {
    it('marks message as ERROR when remote insert fails', async () => {
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Err(new Error('network down'))
      );

      const footer = getFooter(el);
      await footer.updateComplete;

      typeInto(getInput(el), 'Will fail');
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

      typeInto(getInput(el), 'Retry me');
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

    it('ignores a retry event when the message has no id', async () => {
      const insertSpy = vi.spyOn(el.yaloMessageRepository, 'insertMessage');
      const replaceSpy = vi.spyOn(
        el.chatMessageRepository,
        'replaceChatMessage'
      );

      dispatchFromList(
        el,
        'yalo-chat-retry-message',
        ChatMessage.text({
          role: 'USER',
          timestamp: new Date(),
          content: 'no id',
        })
      );

      await new Promise((resolve) => setTimeout(resolve, 30));
      expect(insertSpy).not.toHaveBeenCalled();
      expect(replaceSpy).not.toHaveBeenCalled();
    });

    it('does not retry remotely when replacing locally for retry fails', async () => {
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Err(new Error('network down'))
      );

      const footer = getFooter(el);
      await footer.updateComplete;
      typeInto(getInput(el), 'fails to retry');
      await footer.updateComplete;
      getSendButton(el).click();

      await vi.waitUntil(
        () => getMessageList(el).chatMessages[0]?.status === 'ERROR'
      );
      const errored = getMessageList(el).chatMessages[0];

      const errorSpy = vi.spyOn(el.logger, 'error');
      vi.spyOn(
        el.chatMessageRepository,
        'replaceChatMessage'
      ).mockResolvedValue(new Err(new Error('replace fail')));
      const insertSpy = vi
        .spyOn(el.yaloMessageRepository, 'insertMessage')
        .mockClear();

      dispatchFromList(el, 'yalo-chat-retry-message', errored);

      await vi.waitUntil(() =>
        errorSpy.mock.calls.some(
          (c) => c[0] === 'Unable to update message for retry'
        )
      );
      expect(insertSpy).not.toHaveBeenCalled();
    });

    it('logs an error when persisting the ERROR status fails', async () => {
      const errorSpy = vi.spyOn(el.logger, 'error');
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Err(new Error('network down'))
      );
      vi.spyOn(
        el.chatMessageRepository,
        'replaceChatMessage'
      ).mockResolvedValue(new Err(new Error('replace fail')));

      const footer = getFooter(el);
      await footer.updateComplete;
      typeInto(getInput(el), 'cannot mark errored');
      await footer.updateComplete;
      getSendButton(el).click();

      await vi.waitUntil(() =>
        errorSpy.mock.calls.some(
          (c) => c[0] === 'Unable to persist error status locally'
        )
      );
      expect(getMessageList(el).chatMessages[0]).toMatchObject({
        content: 'cannot mark errored',
        status: 'IN_PROGRESS',
      });
    });

    it('keeps the message in ERROR when retry fails again', async () => {
      const insertSpy = vi
        .spyOn(el.yaloMessageRepository, 'insertMessage')
        .mockResolvedValue(new Err(new Error('still down')));

      const footer = getFooter(el);
      await footer.updateComplete;

      typeInto(getInput(el), 'Stays errored');
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
    it('shows a scrollbar when content exceeds the max height', async () => {
      el.open = true;
      await el.updateComplete;

      const footer = getFooter(el);
      await footer.updateComplete;

      const input = getInput(el);
      typeInto(
        input,
        'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6'
      );

      expect(input.scrollHeight).toBeGreaterThan(input.clientHeight);
    });

    it('grows the input height when long text is entered', async () => {
      el.open = true;
      await el.updateComplete;

      const footer = getFooter(el);
      await footer.updateComplete;

      const input = getInput(el);
      const initialHeight = input.scrollHeight;

      typeInto(input, 'Line 1\nLine 2\nLine 3');

      expect(input.scrollHeight).toBeGreaterThan(initialHeight);
    });

    it('shrinks back to a single line after sending', async () => {
      el.open = true;
      await el.updateComplete;

      const footer = getFooter(el);
      await footer.updateComplete;

      const input = getInput(el);
      const initialHeight = input.scrollHeight;
      typeInto(input, 'Line 1\nLine 2\nLine 3');
      const expandedHeight = input.scrollHeight;
      expect(expandedHeight).toBeGreaterThan(initialHeight);

      getSendButton(el).click();
      await footer.updateComplete;

      expect(input).toMatchObject({
        textContent: '',
        scrollHeight: initialHeight,
      });
    });
  });

  describe('sending voice messages', () => {
    const buildVoiceMessage = (): ChatMessage =>
      ChatMessage.voice({
        role: 'USER',
        timestamp: new Date(),
        fileName: 'voice-1.webm',
        amplitudes: [1, 2, 3],
        duration: 1,
        blob: new Blob(['audio'], { type: 'audio/webm' }),
        mediaType: 'audio/webm',
      });

    it('persists the voice message locally and keeps it in progress on success', async () => {
      const voice = buildVoiceMessage();
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Ok(voice)
      );

      dispatchFromFooter(el, 'yalo-chat-send-voice-message', {
        message: voice,
        blob: voice.blob,
      });

      await vi.waitUntil(() => getMessageList(el).chatMessages.length > 0);
      expect(getMessageList(el).chatMessages[0]).toMatchObject({
        type: 'voice',
        fileName: 'voice-1.webm',
        status: 'IN_PROGRESS',
      });
    });

    it('marks the voice message as ERROR when remote insert fails', async () => {
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Err(new Error('upload failed'))
      );
      const voice = buildVoiceMessage();

      dispatchFromFooter(el, 'yalo-chat-send-voice-message', {
        message: voice,
        blob: voice.blob,
      });

      await vi.waitUntil(
        () => getMessageList(el).chatMessages[0]?.status === 'ERROR'
      );
      expect(getMessageList(el).chatMessages[0]).toMatchObject({
        type: 'voice',
        status: 'ERROR',
      });
    });

    it('flips isWriting to true after a successful send', async () => {
      const voice = buildVoiceMessage();
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Ok(voice)
      );

      dispatchFromFooter(el, 'yalo-chat-send-voice-message', {
        message: voice,
        blob: voice.blob,
      });

      await vi.waitUntil(() => getMessageList(el).isWriting === true);
    });

    it('does not add the voice message when local insert fails', async () => {
      const errorSpy = vi.spyOn(el.logger, 'error');
      vi.spyOn(
        el.chatMessageRepository,
        'insertChatMessage'
      ).mockResolvedValue(new Err(new Error('db full')));
      const remoteSpy = vi.spyOn(el.yaloMessageRepository, 'insertMessage');
      const voice = buildVoiceMessage();

      dispatchFromFooter(el, 'yalo-chat-send-voice-message', {
        message: voice,
        blob: voice.blob,
      });

      await vi.waitUntil(() =>
        errorSpy.mock.calls.some(
          (c) => c[0] === 'Unable to insert voice message locally'
        )
      );
      expect(remoteSpy).not.toHaveBeenCalled();
      expect(getMessageList(el).chatMessages).toHaveLength(0);
    });
  });

  describe('sending image messages', () => {
    const buildImageMessage = (): ChatMessage =>
      ChatMessage.image({
        role: 'USER',
        timestamp: new Date(),
        fileName: 'photo.png',
        mediaType: 'image/png',
        blob: new Blob(['img'], { type: 'image/png' }),
      });

    it('persists an image message and keeps it in progress on success', async () => {
      const image = buildImageMessage();
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Ok(image)
      );

      dispatchFromFooter(el, 'yalo-chat-send-image-message', {
        message: image,
        file: new File([image.blob!], image.fileName!, {
          type: image.mediaType,
        }),
      });

      await vi.waitUntil(() => getMessageList(el).chatMessages.length > 0);
      expect(getMessageList(el).chatMessages[0]).toMatchObject({
        type: 'image',
        fileName: 'photo.png',
        status: 'IN_PROGRESS',
      });
    });

    it('marks an image message as ERROR when remote insert fails', async () => {
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Err(new Error('upload failed'))
      );
      const image = buildImageMessage();

      dispatchFromFooter(el, 'yalo-chat-send-image-message', {
        message: image,
        file: new File([image.blob!], image.fileName!, {
          type: image.mediaType,
        }),
      });

      await vi.waitUntil(
        () => getMessageList(el).chatMessages[0]?.status === 'ERROR'
      );
      expect(getMessageList(el).chatMessages[0]).toMatchObject({
        type: 'image',
        status: 'ERROR',
      });
    });

    it('does not add the image message when local insert fails', async () => {
      const errorSpy = vi.spyOn(el.logger, 'error');
      vi.spyOn(
        el.chatMessageRepository,
        'insertChatMessage'
      ).mockResolvedValue(new Err(new Error('db full')));
      const remoteSpy = vi.spyOn(el.yaloMessageRepository, 'insertMessage');
      const image = buildImageMessage();

      dispatchFromFooter(el, 'yalo-chat-send-image-message', {
        message: image,
        file: new File([image.blob!], image.fileName!, {
          type: image.mediaType,
        }),
      });

      await vi.waitUntil(() =>
        errorSpy.mock.calls.some(
          (c) => c[0] === 'Unable to insert image message locally'
        )
      );
      expect(remoteSpy).not.toHaveBeenCalled();
      expect(getMessageList(el).chatMessages).toHaveLength(0);
    });
  });

  describe('sending attachment messages', () => {
    const buildAttachmentMessage = (): ChatMessage =>
      ChatMessage.attachment({
        role: 'USER',
        timestamp: new Date(),
        fileName: 'doc.pdf',
        mediaType: 'application/pdf',
        blob: new Blob(['pdf'], { type: 'application/pdf' }),
      });

    it('persists an attachment message and keeps it in progress on success', async () => {
      const attachment = buildAttachmentMessage();
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Ok(attachment)
      );

      dispatchFromFooter(el, 'yalo-chat-send-attachment-message', {
        message: attachment,
        file: new File([attachment.blob!], attachment.fileName!, {
          type: attachment.mediaType,
        }),
      });

      await vi.waitUntil(() => getMessageList(el).chatMessages.length > 0);
      expect(getMessageList(el).chatMessages[0]).toMatchObject({
        type: 'attachment',
        fileName: 'doc.pdf',
        status: 'IN_PROGRESS',
      });
    });

    it('marks an attachment message as ERROR when remote insert fails', async () => {
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Err(new Error('upload failed'))
      );
      const attachment = buildAttachmentMessage();

      dispatchFromFooter(el, 'yalo-chat-send-attachment-message', {
        message: attachment,
        file: new File([attachment.blob!], attachment.fileName!, {
          type: attachment.mediaType,
        }),
      });

      await vi.waitUntil(
        () => getMessageList(el).chatMessages[0]?.status === 'ERROR'
      );
      expect(getMessageList(el).chatMessages[0]).toMatchObject({
        type: 'attachment',
        status: 'ERROR',
      });
    });

    it('does not add the attachment message when local insert fails', async () => {
      const errorSpy = vi.spyOn(el.logger, 'error');
      vi.spyOn(
        el.chatMessageRepository,
        'insertChatMessage'
      ).mockResolvedValue(new Err(new Error('db full')));
      const remoteSpy = vi.spyOn(el.yaloMessageRepository, 'insertMessage');
      const attachment = buildAttachmentMessage();

      dispatchFromFooter(el, 'yalo-chat-send-attachment-message', {
        message: attachment,
        file: new File([attachment.blob!], attachment.fileName!, {
          type: attachment.mediaType,
        }),
      });

      await vi.waitUntil(() =>
        errorSpy.mock.calls.some(
          (c) => c[0] === 'Unable to insert attachment message locally'
        )
      );
      expect(remoteSpy).not.toHaveBeenCalled();
      expect(getMessageList(el).chatMessages).toHaveLength(0);
    });
  });

  describe('product quantity updates', () => {
    const seedProductMessage = async (
      product: Product
    ): Promise<{ id: number }> => {
      const message = ChatMessage.product({
        role: 'AGENT',
        timestamp: new Date(),
        products: [product],
      });
      vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
        new Ok(message)
      );
      dispatchFromFooter(el, 'yalo-chat-send-text-message', message);
      await vi.waitUntil(
        () => getMessageList(el).chatMessages[0]?.products?.[0]?.sku === product.sku
      );
      const id = getMessageList(el).chatMessages[0].id;
      if (id === undefined) {
        throw new Error('expected seeded message to have an id');
      }
      return { id };
    };

    it('increments unitsAdded and forwards a positive delta to addToCart', async () => {
      const seeded = await seedProductMessage(
        new Product({
          sku: 'sku-1',
          name: 'Soda',
          price: 1,
          unitName: 'unit',
        })
      );
      const addToCart = vi
        .spyOn(el.yaloMessageRepository, 'addToCart')
        .mockResolvedValue(new Ok(undefined));

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: seeded.id,
        sku: 'sku-1',
        unitType: 'unit',
        value: 3,
      });

      await vi.waitUntil(() => addToCart.mock.calls.length > 0);
      expect(addToCart).toHaveBeenCalledWith('sku-1', 'unit', 3);
      expect(getMessageList(el).chatMessages[0].products[0]).toMatchObject({
        sku: 'sku-1',
        unitsAdded: 3,
      });
    });

    it('routes addToCart through a registered command when present', async () => {
      const seeded = await seedProductMessage(
        new Product({
          sku: 'sku-2',
          name: 'Snack',
          price: 2,
          unitName: 'unit',
        })
      );
      const callback = vi.fn();
      el.commands.set('addToCart', callback);
      const addToCart = vi
        .spyOn(el.yaloMessageRepository, 'addToCart')
        .mockResolvedValue(new Ok(undefined));

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: seeded.id,
        sku: 'sku-2',
        unitType: 'unit',
        value: 2,
      });

      await vi.waitUntil(() => callback.mock.calls.length > 0);
      expect(callback).toHaveBeenCalledWith({
        sku: 'sku-2',
        quantity: 2,
        unitType: 'unit',
      });
      expect(addToCart).not.toHaveBeenCalled();
    });

    it('forwards a negative delta to removeFromCart', async () => {
      const seeded = await seedProductMessage(
        new Product({
          sku: 'sku-3',
          name: 'Item',
          price: 3,
          unitName: 'unit',
          unitsAdded: 5,
        })
      );
      const removeFromCart = vi
        .spyOn(el.yaloMessageRepository, 'removeFromCart')
        .mockResolvedValue(new Ok(undefined));

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: seeded.id,
        sku: 'sku-3',
        unitType: 'unit',
        value: 2,
      });

      await vi.waitUntil(() => removeFromCart.mock.calls.length > 0);
      expect(removeFromCart).toHaveBeenCalledWith('sku-3', 'unit', 3);
      expect(getMessageList(el).chatMessages[0].products[0]).toMatchObject({
        unitsAdded: 2,
      });
    });

    it('routes removeFromCart through a registered command when present', async () => {
      const seeded = await seedProductMessage(
        new Product({
          sku: 'sku-3b',
          name: 'Item',
          price: 3,
          unitName: 'unit',
          unitsAdded: 4,
        })
      );
      const callback = vi.fn();
      el.commands.set('removeFromCart', callback);
      const removeFromCart = vi
        .spyOn(el.yaloMessageRepository, 'removeFromCart')
        .mockResolvedValue(new Ok(undefined));

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: seeded.id,
        sku: 'sku-3b',
        unitType: 'unit',
        value: 1,
      });

      await vi.waitUntil(() => callback.mock.calls.length > 0);
      expect(callback).toHaveBeenCalledWith({
        sku: 'sku-3b',
        quantity: 3,
        unitType: 'unit',
      });
      expect(removeFromCart).not.toHaveBeenCalled();
    });

    it('rolls over subunits into whole units when value exceeds subunits per unit', async () => {
      const seeded = await seedProductMessage(
        new Product({
          sku: 'sku-4',
          name: 'Pack',
          price: 4,
          unitName: 'pack',
          subunitName: 'piece',
          subunits: 6,
        })
      );
      vi.spyOn(el.yaloMessageRepository, 'addToCart').mockResolvedValue(
        new Ok(undefined)
      );

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: seeded.id,
        sku: 'sku-4',
        unitType: 'subunit',
        value: 14,
      });

      await vi.waitUntil(
        () => getMessageList(el).chatMessages[0].products[0].unitsAdded === 2
      );
      expect(getMessageList(el).chatMessages[0].products[0]).toMatchObject({
        unitsAdded: 2,
        subunitsAdded: 2,
      });
    });

    it('clamps negative inputs to zero', async () => {
      const seeded = await seedProductMessage(
        new Product({
          sku: 'sku-5',
          name: 'Thing',
          price: 5,
          unitName: 'unit',
          unitsAdded: 2,
        })
      );
      const removeFromCart = vi
        .spyOn(el.yaloMessageRepository, 'removeFromCart')
        .mockResolvedValue(new Ok(undefined));

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: seeded.id,
        sku: 'sku-5',
        unitType: 'unit',
        value: -7,
      });

      await vi.waitUntil(() => removeFromCart.mock.calls.length > 0);
      expect(getMessageList(el).chatMessages[0].products[0]).toMatchObject({
        unitsAdded: 0,
      });
      expect(removeFromCart).toHaveBeenCalledWith('sku-5', 'unit', 2);
    });

    it('is a no-op when the message id is unknown', async () => {
      await seedProductMessage(
        new Product({
          sku: 'sku-6',
          name: 'Other',
          price: 6,
          unitName: 'unit',
        })
      );
      const addToCart = vi
        .spyOn(el.yaloMessageRepository, 'addToCart')
        .mockResolvedValue(new Ok(undefined));

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: 99999,
        sku: 'sku-6',
        unitType: 'unit',
        value: 1,
      });

      await new Promise((resolve) => setTimeout(resolve, 30));
      expect(addToCart).not.toHaveBeenCalled();
    });

    it('does not send a cart command when replacing the message fails', async () => {
      const seeded = await seedProductMessage(
        new Product({
          sku: 'sku-7',
          name: 'Item',
          price: 7,
          unitName: 'unit',
        })
      );
      const errorSpy = vi.spyOn(el.logger, 'error');
      vi.spyOn(
        el.chatMessageRepository,
        'replaceChatMessage'
      ).mockResolvedValue(new Err(new Error('replace fail')));
      const addToCart = vi.spyOn(el.yaloMessageRepository, 'addToCart');

      dispatchFromList(el, 'yalo-chat-product-quantity-change', {
        messageId: seeded.id,
        sku: 'sku-7',
        unitType: 'unit',
        value: 4,
      });

      await vi.waitUntil(() =>
        errorSpy.mock.calls.some(
          (c) => c[0] === 'Unable to update product quantity'
        )
      );
      expect(addToCart).not.toHaveBeenCalled();
      expect(getMessageList(el).chatMessages[0].products[0]).toMatchObject({
        unitsAdded: 0,
      });
    });
  });
});

describe('YaloChatWindow initial fetch failure', () => {
  afterEach(async () => {
    document.body.innerHTML = '';
    vi.restoreAllMocks();
    await clearDb();
  });

  it('logs an error and renders an empty list when the initial fetch fails', async () => {
    vi.spyOn(
      ChatMessageRepositoryLocal.prototype,
      'getChatMessagePageDesc'
    ).mockResolvedValue(new Err(new Error('db down')));

    const el = document.createElement('yalo-chat-window') as YaloChatWindow;
    el.config = baseConfig;
    const errorSpy = vi.spyOn(el.logger, 'error');
    document.body.appendChild(el);
    await vi.waitUntil(() => el.yaloMessageRepository !== undefined);

    expect(errorSpy).toHaveBeenCalledWith('Unable to fetch messages');
    expect(getMessageList(el).chatMessages).toHaveLength(0);
  });
});

describe('YaloChatWindow incoming messages', () => {
  let el: YaloChatWindow;
  let subscribeCallback: PollCallback | undefined;
  let unsubscribeSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(async () => {
    subscribeCallback = undefined;
    vi.spyOn(
      YaloMessageRepositoryRemote.prototype,
      'subscribeToMessages'
    ).mockImplementation(function (
      this: YaloMessageRepositoryRemote,
      cb: PollCallback
    ) {
      subscribeCallback = cb;
    });
    unsubscribeSpy = vi
      .spyOn(YaloMessageRepositoryRemote.prototype, 'unsubscribeMessages')
      .mockReturnValue();
    el = await createElement();
  });

  afterEach(async () => {
    document.body.innerHTML = '';
    vi.restoreAllMocks();
    await clearDb();
  });

  it('prepends an incoming message to the list', async () => {
    expect(subscribeCallback).toBeDefined();
    const incoming = ChatMessage.text({
      role: 'AGENT',
      timestamp: new Date(),
      content: 'Hello from agent',
    });

    subscribeCallback!([incoming]);

    await vi.waitUntil(
      () => getMessageList(el).chatMessages[0]?.content === 'Hello from agent'
    );
    expect(getMessageList(el).chatMessages[0]).toMatchObject({
      content: 'Hello from agent',
      role: 'AGENT',
    });
  });

  it('clears isWriting when incoming messages arrive', async () => {
    vi.spyOn(el.yaloMessageRepository, 'insertMessage').mockResolvedValue(
      new Ok(
        ChatMessage.text({
          role: 'USER',
          timestamp: new Date(),
          content: 'hi',
        })
      )
    );
    dispatchFromFooter(
      el,
      'yalo-chat-send-text-message',
      ChatMessage.text({
        role: 'USER',
        timestamp: new Date(),
        content: 'hi',
      })
    );

    await vi.waitUntil(() => getMessageList(el).isWriting === true);

    subscribeCallback!([
      ChatMessage.text({
        role: 'AGENT',
        timestamp: new Date(),
        content: 'reply',
      }),
    ]);

    await vi.waitUntil(() => getMessageList(el).isWriting === false);
  });

  it('forwards a chat-status message to the header without adding it to the list', async () => {
    const status = ChatMessage.chatStatus({
      timestamp: new Date(),
      content: 'Agent is typing',
      wiId: 'status-1',
    });

    subscribeCallback!([status]);

    await vi.waitUntil(
      () => getHeader(el).statusMessage === 'Agent is typing'
    );
    expect(getMessageList(el).chatMessages).toHaveLength(0);
  });

  it('clears the header status when an empty chat-status arrives', async () => {
    subscribeCallback!([
      ChatMessage.chatStatus({
        timestamp: new Date(),
        content: 'Agent is typing',
      }),
    ]);
    await vi.waitUntil(
      () => getHeader(el).statusMessage === 'Agent is typing'
    );

    subscribeCallback!([
      ChatMessage.chatStatus({ timestamp: new Date(), content: '' }),
    ]);

    await vi.waitUntil(() => getHeader(el).statusMessage === '');
  });

  it('uses the last chat-status when multiple arrive in the same batch', async () => {
    subscribeCallback!([
      ChatMessage.chatStatus({ timestamp: new Date(), content: 'first' }),
      ChatMessage.chatStatus({ timestamp: new Date(), content: 'second' }),
    ]);

    await vi.waitUntil(() => getHeader(el).statusMessage === 'second');
  });

  it('still prepends regular messages when the batch also contains a chat-status', async () => {
    subscribeCallback!([
      ChatMessage.chatStatus({
        timestamp: new Date(),
        content: 'Agent is typing',
      }),
      ChatMessage.text({
        role: 'AGENT',
        timestamp: new Date(),
        content: 'And here is the reply',
      }),
    ]);

    await vi.waitUntil(
      () => getMessageList(el).chatMessages[0]?.content === 'And here is the reply'
    );
    expect(getHeader(el).statusMessage).toBe('Agent is typing');
    expect(getMessageList(el).chatMessages).toHaveLength(1);
  });

  it('unsubscribes when the element is removed from the DOM', () => {
    unsubscribeSpy.mockClear();
    el.remove();
    expect(unsubscribeSpy).toHaveBeenCalled();
  });
});

describe('YaloChatWindow pagination', () => {
  let el: YaloChatWindow;
  let pageSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(async () => {
    pageSpy = vi
      .spyOn(ChatMessageRepositoryLocal.prototype, 'getChatMessagePageDesc')
      .mockImplementation(async (cursor: number | null) => {
      if (cursor === null) {
        return new Ok({
          data: [
            ChatMessage.text({
              id: 1,
              role: 'USER',
              timestamp: new Date(2026, 0, 1),
              content: 'first',
            }),
          ],
          pageInfo: { cursor: undefined, nextCursor: 1, pageSize: 500 },
        });
      }
      return new Ok({
        data: [
          ChatMessage.text({
            id: 2,
            role: 'USER',
            timestamp: new Date(2025, 0, 1),
            content: 'second',
          }),
        ],
        pageInfo: { cursor: 1, nextCursor: undefined, pageSize: 500 },
      });
    });
    el = await createElement();
  });

  afterEach(async () => {
    document.body.innerHTML = '';
    vi.restoreAllMocks();
    await clearDb();
  });

  it('appends the next page when fetch-next-page is dispatched', async () => {
    await vi.waitUntil(() => getMessageList(el).chatMessages.length === 1);

    dispatchFromList(el, 'yalo-chat-fetch-next-page');

    await vi.waitUntil(() => getMessageList(el).chatMessages.length === 2);
    expect(getMessageList(el).chatMessages.map((m) => m.content)).toEqual([
      'first',
      'second',
    ]);
  });

  it('does not call the repository when there is no next cursor', async () => {
    dispatchFromList(el, 'yalo-chat-fetch-next-page');
    await vi.waitUntil(() => getMessageList(el).chatMessages.length === 2);

    pageSpy.mockClear();
    dispatchFromList(el, 'yalo-chat-fetch-next-page');
    await new Promise((resolve) => setTimeout(resolve, 30));

    expect(pageSpy).not.toHaveBeenCalled();
  });

  it('logs an error when the next page fetch fails', async () => {
    const errorSpy = vi.spyOn(el.logger, 'error');
    vi.spyOn(
      el.chatMessageRepository,
      'getChatMessagePageDesc'
    ).mockResolvedValueOnce(new Err(new Error('db down')));

    dispatchFromList(el, 'yalo-chat-fetch-next-page');

    await vi.waitUntil(() => errorSpy.mock.calls.length > 0);
    expect(errorSpy).toHaveBeenCalledWith('Unable to fetch next message page');
  });
});

describe('YaloChatWindow guidance card on first open', () => {
  afterEach(async () => {
    document.body.innerHTML = '';
    vi.restoreAllMocks();
    await clearDb();
  });

  const createWith = async (
    config: Partial<typeof baseConfig> & { openContext?: string } = {}
  ): Promise<YaloChatWindow> => {
    const window = document.createElement('yalo-chat-window') as YaloChatWindow;
    window.config = { ...baseConfig, ...config };
    document.body.appendChild(window);
    await vi.waitUntil(() => window.yaloMessageRepository !== undefined);
    return window;
  };

  it('requests guidance cards on first open when there are no messages', async () => {
    const window = await createWith({ openContext: 'product-page' });
    const requestSpy = vi
      .spyOn(window.yaloMessageRepository, 'requestGuidanceCard')
      .mockResolvedValue(new Ok(undefined));

    window.open = true;
    await window.updateComplete;

    await vi.waitUntil(() => requestSpy.mock.calls.length > 0);
    expect(requestSpy).toHaveBeenCalledWith('chat-target', 'product-page');
  });

  it('uses openContext set on the element when config.openContext is missing', async () => {
    const window = await createWith();
    window.openContext = 'home-page';
    const requestSpy = vi
      .spyOn(window.yaloMessageRepository, 'requestGuidanceCard')
      .mockResolvedValue(new Ok(undefined));

    window.open = true;
    await window.updateComplete;

    await vi.waitUntil(() => requestSpy.mock.calls.length > 0);
    expect(requestSpy).toHaveBeenCalledWith('chat-target', 'home-page');
  });

  it('does not request guidance cards when there is at least one stored message', async () => {
    vi.spyOn(
      ChatMessageRepositoryLocal.prototype,
      'getChatMessagePageDesc'
    ).mockResolvedValue(
      new Ok({
        data: [
          ChatMessage.text({
            id: 1,
            role: 'USER',
            timestamp: new Date(),
            content: 'old',
          }),
        ],
        pageInfo: { cursor: undefined, nextCursor: undefined, pageSize: 500 },
      })
    );
    const window = await createWith();
    const requestSpy = vi
      .spyOn(window.yaloMessageRepository, 'requestGuidanceCard')
      .mockResolvedValue(new Ok(undefined));

    window.open = true;
    await window.updateComplete;

    await new Promise((resolve) => setTimeout(resolve, 30));
    expect(requestSpy).not.toHaveBeenCalled();
  });

  it('requests guidance cards only once across multiple opens', async () => {
    const window = await createWith();
    const requestSpy = vi
      .spyOn(window.yaloMessageRepository, 'requestGuidanceCard')
      .mockResolvedValue(new Ok(undefined));

    window.open = true;
    await window.updateComplete;
    await vi.waitUntil(() => requestSpy.mock.calls.length === 1);

    window.open = false;
    await window.updateComplete;
    window.open = true;
    await window.updateComplete;
    await new Promise((resolve) => setTimeout(resolve, 30));

    expect(requestSpy).toHaveBeenCalledTimes(1);
  });

  it('does not request guidance cards while the chat stays closed', async () => {
    const window = await createWith();
    const requestSpy = vi
      .spyOn(window.yaloMessageRepository, 'requestGuidanceCard')
      .mockResolvedValue(new Ok(undefined));

    await new Promise((resolve) => setTimeout(resolve, 30));
    expect(requestSpy).not.toHaveBeenCalled();
  });

  it('logs an error when the guidance card request fails', async () => {
    const window = await createWith();
    const errorSpy = vi.spyOn(window.logger, 'error');
    vi.spyOn(
      window.yaloMessageRepository,
      'requestGuidanceCard'
    ).mockResolvedValue(new Err(new Error('socket closed')));

    window.open = true;
    await window.updateComplete;

    await vi.waitUntil(() =>
      errorSpy.mock.calls.some(
        (c) => c[0] === 'Unable to request guidance cards'
      )
    );
  });
});
