// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  ChatMessage,
  type MessageButton,
  type MessageButtonType,
} from '@domain/models/chat-message/chat-message';
import {
  ButtonType,
  MessageRole,
  MessageStatus,
  ProductMessageRequest_Orientation,
  type Button as ProtoButton,
  type PollMessageItem,
  type Product as ProtoProduct,
  type SdkMessage,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import { Product } from '@domain/models/product/product';

export function chatMessageToSdkMessage(
  message: ChatMessage,
  mediaId?: string
): SdkMessage {
  const timestamp = new Date();
  const correlationId = message.id?.toString() || '';

  switch (message.type) {
    case 'text':
      return {
        correlationId,
        textMessageRequest: {
          content: {
            timestamp: message.timestamp,
            text: message.content,
            status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
            role: MessageRole.MESSAGE_ROLE_USER,
          },
          timestamp,
          buttons: [],
        },
        timestamp,
      };
    case 'image':
      return {
        correlationId,
        imageMessageRequest: {
          content: {
            timestamp: message.timestamp,
            text: message.content,
            status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
            role: MessageRole.MESSAGE_ROLE_USER,
            mediaUrl: mediaId ?? message.fileName!,
            mediaType: message.mediaType!,
            byteCount: message.byteCount!,
            fileName: message.fileName!,
          },
          timestamp,
          buttons: [],
        },
        timestamp,
      };
    case 'voice':
      return {
        correlationId,
        voiceNoteMessageRequest: {
          content: {
            timestamp: message.timestamp,
            status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
            role: MessageRole.MESSAGE_ROLE_USER,
            mediaUrl: mediaId ?? message.fileName!,
            mediaType: message.mediaType!,
            byteCount: message.byteCount!,
            fileName: message.fileName!,
            amplitudesPreview: message.amplitudes!,
            duration: message.duration!,
          },
          timestamp,
          buttons: [],
        },
        timestamp,
      };
    case 'video':
      return {
        correlationId,
        videoMessageRequest: {
          content: {
            timestamp: message.timestamp,
            text: message.content,
            status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
            role: MessageRole.MESSAGE_ROLE_USER,
            mediaUrl: mediaId ?? message.fileName!,
            mediaType: message.mediaType!,
            byteCount: message.byteCount!,
            fileName: message.fileName!,
            duration: message.duration!,
          },
          timestamp,
          buttons: [],
        },
        timestamp,
      };
    case 'attachment':
      return {
        correlationId,
        attachmentMessageRequest: {
          content: {
            timestamp: message.timestamp,
            text: message.content,
            status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
            role: MessageRole.MESSAGE_ROLE_USER,
            mediaUrl: mediaId ?? message.fileName!,
            mediaType: message.mediaType!,
            byteCount: message.byteCount!,
            fileName: message.fileName!,
          },
          timestamp,
          buttons: [],
        },
        timestamp,
      };
    default:
      throw Error('UnimplementedError');
  }
}

export function pollMessageItemToChatMessage(
  item: PollMessageItem
): ChatMessage | null {
  const timestamp = item.date ?? new Date();
  const msg = item.message;
  if (!msg) return null;

  if (msg.textMessageRequest?.content) {
    return ChatMessage.text({
      role: 'AGENT',
      timestamp,
      content: msg.textMessageRequest.content.text,
      wiId: item.id,
      header: msg.textMessageRequest.header,
      footer: msg.textMessageRequest.footer,
      buttons: toMessageButtons(msg.textMessageRequest.buttons),
    });
  }

  if (msg.imageMessageRequest?.content) {
    const content = msg.imageMessageRequest.content;
    return ChatMessage.image({
      role: 'AGENT',
      timestamp,
      fileName: content.mediaUrl || content.fileName,
      content: content.text ?? '',
      mediaType: content.mediaType,
      byteCount: content.byteCount,
      wiId: item.id,
      header: msg.imageMessageRequest.header,
      footer: msg.imageMessageRequest.footer,
      buttons: toMessageButtons(msg.imageMessageRequest.buttons),
    });
  }

  if (msg.voiceNoteMessageRequest?.content) {
    const content = msg.voiceNoteMessageRequest.content;
    return ChatMessage.voice({
      role: 'AGENT',
      timestamp,
      fileName: content.fileName,
      amplitudes: content.amplitudesPreview,
      duration: content.duration,
      mediaType: content.mediaType,
      byteCount: content.byteCount,
      wiId: item.id,
      header: msg.voiceNoteMessageRequest.header,
      footer: msg.voiceNoteMessageRequest.footer,
      buttons: toMessageButtons(msg.voiceNoteMessageRequest.buttons),
    });
  }

  if (msg.videoMessageRequest?.content) {
    const content = msg.videoMessageRequest.content;
    return ChatMessage.video({
      role: 'AGENT',
      timestamp,
      fileName: content.mediaUrl || content.fileName,
      content: content.text ?? '',
      duration: content.duration,
      mediaType: content.mediaType,
      byteCount: content.byteCount,
      wiId: item.id,
      header: msg.videoMessageRequest.header,
      footer: msg.videoMessageRequest.footer,
      buttons: toMessageButtons(msg.videoMessageRequest.buttons),
    });
  }

  if (msg.attachmentMessageRequest?.content) {
    const content = msg.attachmentMessageRequest.content;
    return ChatMessage.attachment({
      role: 'AGENT',
      timestamp,
      fileName: content.mediaUrl || content.fileName,
      content: content.text ?? '',
      mediaType: content.mediaType,
      byteCount: content.byteCount,
      wiId: item.id,
      header: msg.attachmentMessageRequest.header,
      footer: msg.attachmentMessageRequest.footer,
      buttons: toMessageButtons(msg.attachmentMessageRequest.buttons),
    });
  }

  if (msg.productMessageRequest) {
    const products = msg.productMessageRequest.products.map(toDomainProduct);
    const isCarousel =
      msg.productMessageRequest.orientation ===
      ProductMessageRequest_Orientation.ORIENTATION_HORIZONTAL;
    const factory = isCarousel ? ChatMessage.carousel : ChatMessage.product;
    return factory({
      role: 'AGENT',
      timestamp,
      products,
      wiId: item.id,
    });
  }

  return null;
}

function toMessageButtons(
  buttons: ProtoButton[] | undefined
): MessageButton[] {
  return buttons?.map(toMessageButton) ?? [];
}

function toMessageButton(b: ProtoButton): MessageButton {
  return { text: b.text, type: toMessageButtonType(b.buttonType), url: b.url };
}

function toMessageButtonType(t: ButtonType): MessageButtonType {
  switch (t) {
    case ButtonType.BUTTON_TYPE_LINK:
      return 'link';
    case ButtonType.BUTTON_TYPE_POSTBACK:
      return 'postback';
    case ButtonType.BUTTON_TYPE_REPLY:
    default:
      return 'reply';
  }
}

function toDomainProduct(p: ProtoProduct): Product {
  return new Product({
    sku: p.sku,
    name: p.name,
    price: p.price,
    imagesUrl: p.imagesUrl,
    salePrice: p.salePrice,
    subunits: p.subunits,
    unitStep: p.unitStep,
    unitName: p.unitName,
    subunitName: p.subunitName,
    subunitStep: p.subunitStep,
    unitsAdded: p.unitsAdded,
    subunitsAdded: p.subunitsAdded,
  });
}
