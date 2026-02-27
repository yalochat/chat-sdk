// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  chatMessageText,
  chatMessageVoice,
  chatMessageImage,
  chatMessageProduct,
  chatMessageCarousel,
  chatMessageCopyWith,
  MessageRole,
  MessageType,
  MessageStatus,
} from '../domain/chat-message';

const NOW = 1700000000000;

describe('chatMessageText', () => {
  it('creates a text message with defaults', () => {
    const msg = chatMessageText({ role: MessageRole.User, timestamp: NOW, content: 'hello' });
    expect(msg.type).toBe(MessageType.Text);
    expect(msg.content).toBe('hello');
    expect(msg.status).toBe(MessageStatus.InProgress);
    expect(msg.products).toEqual([]);
    expect(msg.quickReplies).toEqual([]);
    expect(msg.expand).toBe(false);
  });
});

describe('chatMessageVoice', () => {
  it('creates a voice message', () => {
    const msg = chatMessageVoice({
      role: MessageRole.User,
      timestamp: NOW,
      fileName: 'audio.webm',
      amplitudes: [0.1, 0.2],
      duration: 3000,
    });
    expect(msg.type).toBe(MessageType.Voice);
    expect(msg.fileName).toBe('audio.webm');
    expect(msg.amplitudes).toEqual([0.1, 0.2]);
    expect(msg.duration).toBe(3000);
  });
});

describe('chatMessageImage', () => {
  it('creates an image message', () => {
    const msg = chatMessageImage({
      role: MessageRole.User,
      timestamp: NOW,
      fileName: 'photo.jpg',
    });
    expect(msg.type).toBe(MessageType.Image);
    expect(msg.fileName).toBe('photo.jpg');
  });
});

describe('chatMessageProduct', () => {
  it('creates a product message', () => {
    const msg = chatMessageProduct({ role: MessageRole.Assistant, timestamp: NOW });
    expect(msg.type).toBe(MessageType.Product);
  });
});

describe('chatMessageCarousel', () => {
  it('creates a carousel message', () => {
    const msg = chatMessageCarousel({ role: MessageRole.Assistant, timestamp: NOW });
    expect(msg.type).toBe(MessageType.ProductCarousel);
  });
});

describe('chatMessageCopyWith', () => {
  it('returns a new message with the patch applied', () => {
    const original = chatMessageText({ role: MessageRole.User, timestamp: NOW, content: 'hello' });
    const updated = chatMessageCopyWith(original, { content: 'world', status: MessageStatus.Sent });
    expect(updated.content).toBe('world');
    expect(updated.status).toBe(MessageStatus.Sent);
    // original is unchanged
    expect(original.content).toBe('hello');
  });
});
