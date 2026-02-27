// Copyright (c) Yalochat, Inc. All rights reserved.

export type ChatEvent =
  | { type: 'typingStart'; statusText: string }
  | { type: 'typingStop' };

export function typingStart(statusText: string): ChatEvent {
  return { type: 'typingStart', statusText };
}

export function typingStop(): ChatEvent {
  return { type: 'typingStop' };
}
