// Copyright (c) Yalochat, Inc. All rights reserved.

import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { MessageRole, MessageStatus } from '@domain/models/chat-message/chat-message';
import {
  MessageRole as ProtoMessageRole,
  MessageStatus as ProtoMessageStatus,
} from './sdk_message';
import type { SdkMessage as SdkMessageType } from './sdk_message';

/**
 * Maps a protobuf MessageRole enum value to the domain MessageRole string union.
 * Returns null when the proto value has no domain equivalent.
 */
export function mapProtoRole(role: ProtoMessageRole): MessageRole | null {
  switch (role) {
    case ProtoMessageRole.MESSAGE_ROLE_USER:
      return 'USER';
    case ProtoMessageRole.MESSAGE_ROLE_AGENT:
      return 'AGENT';
    default:
      return null;
  }
}

/**
 * Maps a protobuf MessageStatus enum value to the domain MessageStatus string union.
 * Returns null when the proto value has no domain equivalent.
 */
export function mapProtoStatus(status: ProtoMessageStatus): MessageStatus | null {
  switch (status) {
    case ProtoMessageStatus.MESSAGE_STATUS_DELIVERED:
      return 'DELIVERED';
    case ProtoMessageStatus.MESSAGE_STATUS_READ:
      return 'READ';
    case ProtoMessageStatus.MESSAGE_STATUS_ERROR:
      return 'ERROR';
    case ProtoMessageStatus.MESSAGE_STATUS_SENT:
      return 'SENT';
    case ProtoMessageStatus.MESSAGE_STATUS_IN_PROGRESS:
      return 'IN_PROGRESS';
    default:
      return null;
  }
}

/**
 * Converts an SdkMessage envelope into a domain ChatMessage.
 *
 * Only payload types that carry a renderable conversation turn produce a
 * ChatMessage. Control messages (receipts, cart ops, status pushes, etc.)
 * return null and should be handled by the caller separately.
 *
 * Returns null when the envelope contains no recognised renderable payload
 * or when required fields (role, timestamp) are missing.
 */
export function sdkMessageToChatMessage(msg: SdkMessageType): ChatMessage | null {
  const correlationId = msg.correlationId || undefined;

  // Text message (bidirectional)
  if (msg.textMessageRequest !== undefined) {
    const content = msg.textMessageRequest.content;
    if (!content || !content.timestamp) return null;
    const role = mapProtoRole(content.role);
    if (!role) return null;
    const status = mapProtoStatus(content.status);
    return ChatMessage.text({
      wiId: content.messageId ?? correlationId,
      role,
      timestamp: content.timestamp,
      content: content.text,
      status: status ?? 'IN_PROGRESS',
    });
  }

  // Voice message (bidirectional)
  if (msg.voiceMessageRequest !== undefined) {
    const content = msg.voiceMessageRequest.content;
    if (!content || !content.timestamp) return null;
    const role = mapProtoRole(content.role);
    if (!role) return null;
    const status = mapProtoStatus(content.status);
    return ChatMessage.voice({
      wiId: content.messageId ?? correlationId,
      role,
      timestamp: content.timestamp,
      fileName: content.mediaUrl,
      amplitudes: content.amplitudesPreview,
      duration: content.duration,
      status: status ?? 'IN_PROGRESS',
      quickReplies: msg.voiceMessageRequest.quickReplies,
    });
  }

  // Image message (bidirectional)
  if (msg.imageMessageRequest !== undefined) {
    const content = msg.imageMessageRequest.content;
    if (!content || !content.timestamp) return null;
    const role = mapProtoRole(content.role);
    if (!role) return null;
    const status = mapProtoStatus(content.status);
    return ChatMessage.image({
      wiId: content.messageId ?? correlationId,
      role,
      timestamp: content.timestamp,
      fileName: content.mediaUrl,
      content: content.text ?? undefined,
      status: status ?? 'IN_PROGRESS',
      quickReplies: msg.imageMessageRequest.quickReplies,
    });
  }

  // Promotion message (channel → client)
  if (msg.promotionMessageRequest !== undefined) {
    const p = msg.promotionMessageRequest;
    if (!p.timestamp) return null;
    return new ChatMessage({
      wiId: correlationId,
      role: 'AGENT',
      type: 'promotion',
      timestamp: p.timestamp,
      content: p.description,
      status: 'DELIVERED',
    });
  }

  // Product message (channel → client)
  if (msg.productMessageRequest !== undefined) {
    const p = msg.productMessageRequest;
    if (!p.timestamp) return null;
    // Horizontal orientation → carousel; vertical → product list
    const type =
      p.orientation === 2 /* ORIENTATION_HORIZONTAL */ ? 'productCarousel' : 'product';
    return new ChatMessage({
      wiId: correlationId,
      role: 'AGENT',
      type,
      timestamp: p.timestamp,
      content: '',
      status: 'DELIVERED',
    });
  }

  // Guidance card (channel → client) — rendered as a quick-reply prompt
  if (msg.guidanceCardResponse !== undefined) {
    const g = msg.guidanceCardResponse;
    if (!g.timestamp) return null;
    return new ChatMessage({
      wiId: correlationId,
      role: 'AGENT',
      type: 'quickReply',
      timestamp: g.timestamp,
      content: g.guidanceDescription,
      status: 'DELIVERED',
      quickReplies: g.guidanceCards,
    });
  }

  return null;
}
