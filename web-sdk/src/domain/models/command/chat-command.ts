// Copyright (c) Yalochat, Inc. All rights reserved.

// Client -> Channel commands
export const ChatCommands = [
  'updateCartProduct',
  'clearCart',
  'goToCart',
] as const;

export type ChatCommand = (typeof ChatCommands)[number];

export type ChatCommandCallback = (payload: unknown) => void;
