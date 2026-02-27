// Copyright (c) Yalochat, Inc. All rights reserved.

/** A single message object nested in a YaloFetchMessagesResponse */
export interface YaloMessage {
  text: string;
  role: string;
}

/** Response item returned by GET /messages */
export interface YaloFetchMessagesResponse {
  id: string;
  message: YaloMessage;
  /** ISO 8601 date string */
  date: string;
  user_id: string;
  status: string;
}

/** Inner content of a text message request */
export interface YaloTextMessage {
  /** Unix epoch seconds */
  timestamp: number;
  text: string;
  status: string;
  role: string;
}

/** Body sent to POST /inbound_messages */
export interface YaloTextMessageRequest {
  /** Unix epoch seconds */
  timestamp: number;
  content: YaloTextMessage;
}
