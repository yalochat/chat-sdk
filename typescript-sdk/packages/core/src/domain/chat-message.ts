// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Product } from './product.js';

export enum MessageRole {
  User = 'USER',
  Assistant = 'AGENT',
}

export enum MessageType {
  Text = 'text',
  Image = 'image',
  Voice = 'voice',
  Product = 'product',
  ProductCarousel = 'productCarousel',
  Promotion = 'promotion',
  QuickReply = 'quickReply',
  Unknown = 'unknown',
}

export enum MessageStatus {
  Delivered = 'DELIVERED',
  Read = 'READ',
  Error = 'ERROR',
  Sent = 'SENT',
  InProgress = 'IN_PROGRESS',
}

export interface ChatMessage {
  /** Local DB auto-increment id (undefined before first save) */
  id?: number;
  /** Workflow-interpreter message id */
  wiId?: string;
  role: MessageRole;
  content: string;
  type: MessageType;
  status: MessageStatus;
  /** Unix epoch milliseconds */
  timestamp: number;
  /** File path or URL for image/audio */
  fileName?: string;
  /** Audio waveform amplitudes (preview) */
  amplitudes?: number[];
  /** Audio duration in milliseconds */
  duration?: number;
  products: Product[];
  /** UI-only: expanded carousel state (not persisted) */
  expand: boolean;
  quickReplies: string[];
}

// ── Named constructors ──────────────────────────────────────────────────────

export function chatMessageText(opts: {
  id?: number;
  wiId?: string;
  role: MessageRole;
  timestamp: number;
  status?: MessageStatus;
  content: string;
  quickReplies?: string[];
}): ChatMessage {
  return {
    id: opts.id,
    wiId: opts.wiId,
    role: opts.role,
    content: opts.content,
    type: MessageType.Text,
    status: opts.status ?? MessageStatus.InProgress,
    timestamp: opts.timestamp,
    products: [],
    expand: false,
    quickReplies: opts.quickReplies ?? [],
  };
}

export function chatMessageVoice(opts: {
  id?: number;
  wiId?: string;
  role: MessageRole;
  timestamp: number;
  status?: MessageStatus;
  fileName: string;
  amplitudes: number[];
  duration: number;
  quickReplies?: string[];
}): ChatMessage {
  return {
    id: opts.id,
    wiId: opts.wiId,
    role: opts.role,
    content: '',
    type: MessageType.Voice,
    status: opts.status ?? MessageStatus.InProgress,
    timestamp: opts.timestamp,
    fileName: opts.fileName,
    amplitudes: opts.amplitudes,
    duration: opts.duration,
    products: [],
    expand: false,
    quickReplies: opts.quickReplies ?? [],
  };
}

export function chatMessageImage(opts: {
  id?: number;
  wiId?: string;
  role: MessageRole;
  timestamp: number;
  fileName: string;
  status?: MessageStatus;
  content?: string;
  quickReplies?: string[];
}): ChatMessage {
  return {
    id: opts.id,
    wiId: opts.wiId,
    role: opts.role,
    content: opts.content ?? '',
    type: MessageType.Image,
    status: opts.status ?? MessageStatus.InProgress,
    timestamp: opts.timestamp,
    fileName: opts.fileName,
    products: [],
    expand: false,
    quickReplies: opts.quickReplies ?? [],
  };
}

export function chatMessageProduct(opts: {
  id?: number;
  wiId?: string;
  role: MessageRole;
  timestamp: number;
  status?: MessageStatus;
  products?: Product[];
  expand?: boolean;
  quickReplies?: string[];
}): ChatMessage {
  return {
    id: opts.id,
    wiId: opts.wiId,
    role: opts.role,
    content: '',
    type: MessageType.Product,
    status: opts.status ?? MessageStatus.InProgress,
    timestamp: opts.timestamp,
    fileName: '',
    products: opts.products ?? [],
    expand: opts.expand ?? false,
    quickReplies: opts.quickReplies ?? [],
  };
}

export function chatMessageCarousel(opts: {
  id?: number;
  wiId?: string;
  role: MessageRole;
  timestamp: number;
  status?: MessageStatus;
  products?: Product[];
  expand?: boolean;
  quickReplies?: string[];
}): ChatMessage {
  return {
    id: opts.id,
    wiId: opts.wiId,
    role: opts.role,
    content: '',
    type: MessageType.ProductCarousel,
    status: opts.status ?? MessageStatus.InProgress,
    timestamp: opts.timestamp,
    fileName: '',
    products: opts.products ?? [],
    expand: opts.expand ?? false,
    quickReplies: opts.quickReplies ?? [],
  };
}

export function chatMessageCopyWith(msg: ChatMessage, patch: Partial<ChatMessage>): ChatMessage {
  return { ...msg, ...patch };
}
