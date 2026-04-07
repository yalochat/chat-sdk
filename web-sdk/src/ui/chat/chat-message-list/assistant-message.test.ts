// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, describe, expect, it } from 'vitest';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import './assistant-message';
import type { AssistantMessage } from './assistant-message';

describe('AssistantMessage', () => {
  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('video message', () => {
    it('renders video-message inside video-bubble for video type', async () => {
      const el = document.createElement(
        'assistant-message'
      ) as AssistantMessage;
      el.message = ChatMessage.video({
        role: 'AGENT',
        timestamp: new Date(),
        fileName: 'test.mp4',
        duration: 10,
      });
      document.body.appendChild(el);
      await el.updateComplete;

      const bubble = el.shadowRoot!.querySelector('.video-bubble');
      expect(bubble).not.toBeNull();

      const videoMsg = bubble!.querySelector('video-message');
      expect(videoMsg).not.toBeNull();
    });

    it('passes message property to video-message component', async () => {
      const message = ChatMessage.video({
        role: 'AGENT',
        timestamp: new Date(),
        fileName: 'test.mp4',
        duration: 10,
        content: 'A caption',
      });
      const el = document.createElement(
        'assistant-message'
      ) as AssistantMessage;
      el.message = message;
      document.body.appendChild(el);
      await el.updateComplete;

      const videoMsg = el.shadowRoot!.querySelector('video-message') as Element;
      expect((videoMsg as unknown as { message: ChatMessage }).message).toBe(
        message
      );
    });
  });
});
