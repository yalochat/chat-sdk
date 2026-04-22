// Copyright (c) Yalochat, Inc. All rights reserved.

// Client -> Channel commands
export const ChatCommands = [
  'addToCart',
  'removeFromCart',
  'clearCart',
  'guidanceCard',
  'addPromotion',
] as const;

export type ChatCommand = (typeof ChatCommands)[number];

export type ChatCommandCallback = (payload: unknown) => void;
