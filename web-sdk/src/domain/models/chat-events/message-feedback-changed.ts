// Copyright (c) Yalochat, Inc. All rights reserved.

import type {
  ChatMessage,
  MessageFeedback,
} from '@domain/models/chat-message/chat-message';

// Detail of the yalo-chat-message-feedback event. An undefined feedback means
// the user cleared their rating.
export type MessageFeedbackChanged = {
  message: ChatMessage;
  feedback?: MessageFeedback;
};
