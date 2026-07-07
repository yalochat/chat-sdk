// Copyright (c) Yalochat, Inc. All rights reserved.

// Detail of the yalo-chat-product-add-to-cart event. The handler assigns
// `completed` synchronously while the event is dispatched so the emitting
// component can await the cart update and clear its loading state. It
// resolves to true only when the cart update went through.
export type AddToCart = {
  messageId: number;
  sku: string;
  completed?: Promise<boolean>;
};
