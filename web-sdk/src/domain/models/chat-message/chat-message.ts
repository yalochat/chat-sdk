// Copyright (c) Yalochat, Inc. All rights reserved.

export const MessageRoles = ['USER', 'AGENT'] as const;
export type MessageRole = (typeof MessageRoles)[number];

export const MessageTypes = [
  'text',
  'image',
  'voice',
  'product',
  'productCarousel',
  'promotion',
  'quickReply',
  'unknown',
] as const;
export type MessageType = (typeof MessageTypes)[number];

export const MessageStatuses = ['DELIVERED', 'READ', 'ERROR', 'SENT', 'IN_PROGRESS'] as const;
export type MessageStatus = (typeof MessageStatuses)[number];

export class ChatMessage {
  readonly id?: number;
  readonly wiId?: string;
  readonly role: MessageRole;
  readonly content: string;
  readonly type: MessageType;
  readonly status: MessageStatus;
  readonly timestamp: Date;
  readonly fileName?: string;
  readonly amplitudes?: number[];
  readonly duration?: number;
  readonly quickReplies: string[];

  constructor(params: {
    role: MessageRole;
    type: MessageType;
    timestamp: Date;
    id?: number;
    wiId?: string;
    content?: string;
    status?: MessageStatus;
    fileName?: string;
    amplitudes?: number[];
    duration?: number;
    quickReplies?: string[];
  }) {
    this.id = params.id;
    this.wiId = params.wiId;
    this.role = params.role;
    this.type = params.type;
    this.timestamp = params.timestamp;
    this.content = params.content ?? '';
    this.status = params.status ?? 'IN_PROGRESS';
    this.fileName = params.fileName;
    this.amplitudes = params.amplitudes;
    this.duration = params.duration;
    this.quickReplies = params.quickReplies ?? [];
  }

  static text(params: {
    role: MessageRole;
    timestamp: Date;
    content: string;
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    quickReplies?: string[];
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'text' });
  }

  static voice(params: {
    role: MessageRole;
    timestamp: Date;
    fileName: string;
    amplitudes: number[];
    duration: number;
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    quickReplies?: string[];
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'voice' });
  }

  static image(params: {
    role: MessageRole;
    timestamp: Date;
    fileName: string;
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    content?: string;
    quickReplies?: string[];
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'image' });
  }

}
