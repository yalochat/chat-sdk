// Copyright (c) Yalochat, Inc. All rights reserved.

// Client -> Channel commands
export const ChatCommands = [
  'updateCartProduct',
  'clearCart',
  'goToCart',
] as const;

export type ChatCommand = (typeof ChatCommands)[number];

// The callback can be synchronous or return a promise. The SDK waits for it
// to settle before marking the triggering action as done.
export type ChatCommandCallback = (payload: unknown) => void | Promise<void>;
