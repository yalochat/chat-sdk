// Copyright (c) Yalochat, Inc. All rights reserved.

import type {
  ChatMessage,
  MessageButton,
} from '@domain/models/chat-message/chat-message';

// Detail of the yalo-chat-message-button-selected event, sent when the person
// clicks a postback button. The button is an item of message.buttons.
export type MessageButtonSelected = {
  message: ChatMessage;
  button: MessageButton;
};
