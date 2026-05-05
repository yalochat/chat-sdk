// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Product } from '../product/product';

export const MessageRoles = ['USER', 'AGENT'] as const;
export type MessageRole = (typeof MessageRoles)[number];

export const MessageButtonTypes = ['reply', 'postback', 'link'] as const;
export type MessageButtonType = (typeof MessageButtonTypes)[number];

export type MessageButton = {
  readonly text: string;
  readonly type: MessageButtonType;
  readonly url?: string;
};

export const MessageTypes = [
  'text',
  'image',
  'voice',
  'product',
  'productCarousel',
  'promotion',
  'video',
  'attachment',
  'unknown',
] as const;
export type MessageType = (typeof MessageTypes)[number];

export const MessageStatuses = [
  'DELIVERED',
  'READ',
  'ERROR',
  'SENT',
  'IN_PROGRESS',
] as const;
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
  readonly byteCount?: number;
  readonly mediaType?: string;
  readonly blob?: Blob;
  readonly header?: string;
  readonly footer?: string;
  readonly buttons: MessageButton[];
  readonly products: Product[];
  readonly expand: boolean;

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
    byteCount?: number;
    mediaType?: string;
    blob?: Blob;
    header?: string;
    footer?: string;
    buttons?: MessageButton[];
    products?: Product[];
    expand?: boolean;
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
    this.byteCount = params.byteCount;
    this.mediaType = params.mediaType;
    this.blob = params.blob;
    this.header = params.header;
    this.footer = params.footer;
    this.buttons = params.buttons ?? [];
    this.products = params.products ?? [];
    this.expand = params.expand ?? false;
  }

  static text(params: {
    role: MessageRole;
    timestamp: Date;
    content: string;
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    header?: string;
    footer?: string;
    buttons?: MessageButton[];
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
    byteCount?: number;
    mediaType?: string;
    blob?: Blob;
    header?: string;
    footer?: string;
    buttons?: MessageButton[];
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
    byteCount?: number;
    mediaType?: string;
    blob?: Blob;
    header?: string;
    footer?: string;
    buttons?: MessageButton[];
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'image' });
  }

  static video(params: {
    role: MessageRole;
    timestamp: Date;
    fileName: string;
    duration: number;
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    content?: string;
    byteCount?: number;
    mediaType?: string;
    blob?: Blob;
    header?: string;
    footer?: string;
    buttons?: MessageButton[];
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'video' });
  }

  static attachment(params: {
    role: MessageRole;
    timestamp: Date;
    fileName: string;
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    content?: string;
    byteCount?: number;
    mediaType?: string;
    blob?: Blob;
    header?: string;
    footer?: string;
    buttons?: MessageButton[];
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'attachment' });
  }

  static product(params: {
    role: MessageRole;
    timestamp: Date;
    products: Product[];
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    expand?: boolean;
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'product' });
  }

  static carousel(params: {
    role: MessageRole;
    timestamp: Date;
    products: Product[];
    id?: number;
    wiId?: string;
    status?: MessageStatus;
    expand?: boolean;
  }): ChatMessage {
    return new ChatMessage({ ...params, type: 'productCarousel' });
  }
}
