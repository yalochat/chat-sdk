// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';

// Detail of the yalo-chat-product-confirmation-clicked event. The handler
// assigns `completed` synchronously while the event is dispatched so the
// emitting component can await the confirmation and clear its loading state.
// It resolves to true only when the confirmation went through.
export type ProductConfirmationClicked = {
  message: ChatMessage;
  completed?: Promise<boolean>;
};
