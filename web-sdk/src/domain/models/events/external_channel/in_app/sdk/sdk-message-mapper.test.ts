// Copyright (c) Yalochat, Inc. All rights reserved.

import { describe, expect, it } from 'vitest';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import {
  MessageRole as ProtoMessageRole,
  MessageStatus as ProtoMessageStatus,
  ResponseStatus,
} from './sdk_message';
import type { SdkMessage as SdkMessageType } from './sdk_message';
import {
  mapProtoRole,
  mapProtoStatus,
  sdkMessageToChatMessage,
} from './sdk-message-mapper';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const NOW = new Date('2026-03-17T00:00:00.000Z');

function baseEnvelope(
  overrides: Partial<SdkMessageType> = {}
): SdkMessageType {
  return {
    correlationId: 'corr-1',
    timestamp: NOW,
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// mapProtoRole
// ---------------------------------------------------------------------------

describe('mapProtoRole', () => {
  it('maps MESSAGE_ROLE_USER to USER', () => {
    expect(mapProtoRole(ProtoMessageRole.MESSAGE_ROLE_USER)).toBe('USER');
  });

  it('maps MESSAGE_ROLE_AGENT to AGENT', () => {
    expect(mapProtoRole(ProtoMessageRole.MESSAGE_ROLE_AGENT)).toBe('AGENT');
  });

  it('returns null for MESSAGE_ROLE_UNSPECIFIED', () => {
    expect(mapProtoRole(ProtoMessageRole.MESSAGE_ROLE_UNSPECIFIED)).toBeNull();
  });

  it('returns null for UNRECOGNIZED', () => {
    expect(mapProtoRole(ProtoMessageRole.UNRECOGNIZED)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// mapProtoStatus
// ---------------------------------------------------------------------------

describe('mapProtoStatus', () => {
  it('maps DELIVERED', () => {
    expect(mapProtoStatus(ProtoMessageStatus.MESSAGE_STATUS_DELIVERED)).toBe(
      'DELIVERED'
    );
  });

  it('maps READ', () => {
    expect(mapProtoStatus(ProtoMessageStatus.MESSAGE_STATUS_READ)).toBe('READ');
  });

  it('maps ERROR', () => {
    expect(mapProtoStatus(ProtoMessageStatus.MESSAGE_STATUS_ERROR)).toBe(
      'ERROR'
    );
  });

  it('maps SENT', () => {
    expect(mapProtoStatus(ProtoMessageStatus.MESSAGE_STATUS_SENT)).toBe('SENT');
  });

  it('maps IN_PROGRESS', () => {
    expect(mapProtoStatus(ProtoMessageStatus.MESSAGE_STATUS_IN_PROGRESS)).toBe(
      'IN_PROGRESS'
    );
  });

  it('returns null for UNSPECIFIED', () => {
    expect(
      mapProtoStatus(ProtoMessageStatus.MESSAGE_STATUS_UNSPECIFIED)
    ).toBeNull();
  });

  it('returns null for UNRECOGNIZED', () => {
    expect(mapProtoStatus(ProtoMessageStatus.UNRECOGNIZED)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// sdkMessageToChatMessage — TextMessageRequest
// ---------------------------------------------------------------------------

describe('sdkMessageToChatMessage — TextMessageRequest', () => {
  it('converts a user text request to a ChatMessage', () => {
    const msg = baseEnvelope({
      textMessageRequest: {
        timestamp: NOW,
        content: {
          messageId: 'msg-1',
          timestamp: NOW,
          text: 'Hello',
          status: ProtoMessageStatus.MESSAGE_STATUS_SENT,
          role: ProtoMessageRole.MESSAGE_ROLE_USER,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result).toBeInstanceOf(ChatMessage);
    expect(result?.type).toBe('text');
    expect(result?.role).toBe('USER');
    expect(result?.content).toBe('Hello');
    expect(result?.status).toBe('SENT');
    expect(result?.timestamp).toEqual(NOW);
    expect(result?.wiId).toBe('msg-1');
  });

  it('converts an agent text request to a ChatMessage', () => {
    const msg = baseEnvelope({
      textMessageRequest: {
        timestamp: NOW,
        content: {
          timestamp: NOW,
          text: 'Hi there',
          status: ProtoMessageStatus.MESSAGE_STATUS_DELIVERED,
          role: ProtoMessageRole.MESSAGE_ROLE_AGENT,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result?.role).toBe('AGENT');
    expect(result?.content).toBe('Hi there');
    expect(result?.status).toBe('DELIVERED');
  });

  it('falls back to correlationId as wiId when messageId is absent', () => {
    const msg = baseEnvelope({
      correlationId: 'corr-fallback',
      textMessageRequest: {
        timestamp: NOW,
        content: {
          timestamp: NOW,
          text: 'No messageId',
          status: ProtoMessageStatus.MESSAGE_STATUS_IN_PROGRESS,
          role: ProtoMessageRole.MESSAGE_ROLE_USER,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result?.wiId).toBe('corr-fallback');
  });

  it('defaults status to IN_PROGRESS when proto status maps to null', () => {
    const msg = baseEnvelope({
      textMessageRequest: {
        timestamp: NOW,
        content: {
          timestamp: NOW,
          text: 'Unknown status',
          status: ProtoMessageStatus.MESSAGE_STATUS_UNSPECIFIED,
          role: ProtoMessageRole.MESSAGE_ROLE_USER,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result?.status).toBe('IN_PROGRESS');
  });

  it('returns null when content is missing', () => {
    const msg = baseEnvelope({
      textMessageRequest: {
        timestamp: NOW,
        // content intentionally omitted
      } as SdkMessageType['textMessageRequest'],
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });

  it('returns null when content timestamp is missing', () => {
    const msg = baseEnvelope({
      textMessageRequest: {
        timestamp: NOW,
        content: {
          timestamp: undefined as unknown as Date,
          text: 'No ts',
          status: ProtoMessageStatus.MESSAGE_STATUS_SENT,
          role: ProtoMessageRole.MESSAGE_ROLE_USER,
        },
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });

  it('returns null when role is unrecognised', () => {
    const msg = baseEnvelope({
      textMessageRequest: {
        timestamp: NOW,
        content: {
          timestamp: NOW,
          text: 'Bad role',
          status: ProtoMessageStatus.MESSAGE_STATUS_SENT,
          role: ProtoMessageRole.MESSAGE_ROLE_UNSPECIFIED,
        },
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// sdkMessageToChatMessage — VoiceMessageRequest
// ---------------------------------------------------------------------------

describe('sdkMessageToChatMessage — VoiceMessageRequest', () => {
  it('converts a voice request to a ChatMessage', () => {
    const msg = baseEnvelope({
      voiceMessageRequest: {
        timestamp: NOW,
        quickReplies: [],
        content: {
          messageId: 'voice-1',
          timestamp: NOW,
          mediaUrl: 'https://cdn.example.com/audio.ogg',
          amplitudesPreview: [0.1, 0.5, 0.9],
          duration: 3.5,
          mediaType: 'audio/ogg',
          status: ProtoMessageStatus.MESSAGE_STATUS_DELIVERED,
          role: ProtoMessageRole.MESSAGE_ROLE_USER,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result).toBeInstanceOf(ChatMessage);
    expect(result?.type).toBe('voice');
    expect(result?.role).toBe('USER');
    expect(result?.fileName).toBe('https://cdn.example.com/audio.ogg');
    expect(result?.amplitudes).toEqual([0.1, 0.5, 0.9]);
    expect(result?.duration).toBe(3.5);
    expect(result?.status).toBe('DELIVERED');
    expect(result?.wiId).toBe('voice-1');
  });

  it('includes quickReplies from the envelope', () => {
    const msg = baseEnvelope({
      voiceMessageRequest: {
        timestamp: NOW,
        quickReplies: ['Yes', 'No'],
        content: {
          timestamp: NOW,
          mediaUrl: 'https://cdn.example.com/audio.ogg',
          amplitudesPreview: [],
          duration: 1,
          mediaType: 'audio/ogg',
          status: ProtoMessageStatus.MESSAGE_STATUS_SENT,
          role: ProtoMessageRole.MESSAGE_ROLE_AGENT,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result?.quickReplies).toEqual(['Yes', 'No']);
  });

  it('returns null when content is missing', () => {
    const msg = baseEnvelope({
      voiceMessageRequest: {
        timestamp: NOW,
        quickReplies: [],
      } as SdkMessageType['voiceMessageRequest'],
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// sdkMessageToChatMessage — ImageMessageRequest
// ---------------------------------------------------------------------------

describe('sdkMessageToChatMessage — ImageMessageRequest', () => {
  it('converts an image request to a ChatMessage', () => {
    const msg = baseEnvelope({
      imageMessageRequest: {
        timestamp: NOW,
        quickReplies: [],
        content: {
          messageId: 'img-1',
          timestamp: NOW,
          mediaUrl: 'https://cdn.example.com/photo.jpg',
          mediaType: 'image/jpeg',
          status: ProtoMessageStatus.MESSAGE_STATUS_READ,
          role: ProtoMessageRole.MESSAGE_ROLE_AGENT,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result).toBeInstanceOf(ChatMessage);
    expect(result?.type).toBe('image');
    expect(result?.role).toBe('AGENT');
    expect(result?.fileName).toBe('https://cdn.example.com/photo.jpg');
    expect(result?.status).toBe('READ');
    expect(result?.wiId).toBe('img-1');
  });

  it('includes optional caption text', () => {
    const msg = baseEnvelope({
      imageMessageRequest: {
        timestamp: NOW,
        quickReplies: [],
        content: {
          timestamp: NOW,
          mediaUrl: 'https://cdn.example.com/photo.jpg',
          text: 'Caption here',
          mediaType: 'image/jpeg',
          status: ProtoMessageStatus.MESSAGE_STATUS_DELIVERED,
          role: ProtoMessageRole.MESSAGE_ROLE_USER,
        },
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result?.content).toBe('Caption here');
  });

  it('returns null when content is missing', () => {
    const msg = baseEnvelope({
      imageMessageRequest: {
        timestamp: NOW,
        quickReplies: [],
      } as SdkMessageType['imageMessageRequest'],
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// sdkMessageToChatMessage — PromotionMessageRequest
// ---------------------------------------------------------------------------

describe('sdkMessageToChatMessage — PromotionMessageRequest', () => {
  it('converts a promotion push to a ChatMessage', () => {
    const msg = baseEnvelope({
      promotionMessageRequest: {
        promotionId: 'promo-1',
        title: '10% off',
        gain: '10%',
        description: 'Enjoy your discount',
        imageUrl: 'https://cdn.example.com/promo.jpg',
        footer: 'Valid until end of month',
        timestamp: NOW,
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result).toBeInstanceOf(ChatMessage);
    expect(result?.type).toBe('promotion');
    expect(result?.role).toBe('AGENT');
    expect(result?.content).toBe('Enjoy your discount');
    expect(result?.status).toBe('DELIVERED');
    expect(result?.timestamp).toEqual(NOW);
  });

  it('returns null when timestamp is missing', () => {
    const msg = baseEnvelope({
      promotionMessageRequest: {
        promotionId: 'promo-2',
        title: 'Title',
        gain: '5%',
        description: 'Desc',
        imageUrl: '',
        footer: '',
        timestamp: undefined as unknown as Date,
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// sdkMessageToChatMessage — ProductMessageRequest
// ---------------------------------------------------------------------------

describe('sdkMessageToChatMessage — ProductMessageRequest', () => {
  it('maps vertical orientation to product type', () => {
    const msg = baseEnvelope({
      productMessageRequest: {
        products: [],
        orientation: 1, // ORIENTATION_VERTICAL
        timestamp: NOW,
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result?.type).toBe('product');
    expect(result?.role).toBe('AGENT');
    expect(result?.status).toBe('DELIVERED');
  });

  it('maps horizontal orientation to productCarousel type', () => {
    const msg = baseEnvelope({
      productMessageRequest: {
        products: [],
        orientation: 2, // ORIENTATION_HORIZONTAL
        timestamp: NOW,
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result?.type).toBe('productCarousel');
  });

  it('returns null when timestamp is missing', () => {
    const msg = baseEnvelope({
      productMessageRequest: {
        products: [],
        orientation: 1,
        timestamp: undefined as unknown as Date,
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// sdkMessageToChatMessage — GuidanceCardResponse
// ---------------------------------------------------------------------------

describe('sdkMessageToChatMessage — GuidanceCardResponse', () => {
  it('converts a guidance card response to a quickReply ChatMessage', () => {
    const msg = baseEnvelope({
      guidanceCardResponse: {
        status: ResponseStatus.RESPONSE_STATUS_SUCCESS,
        timestamp: NOW,
        guidanceTitle: 'Need help?',
        guidanceDescription: 'Pick an option below',
        guidanceCards: ['Option A', 'Option B', 'Option C'],
      },
    });

    const result = sdkMessageToChatMessage(msg);
    expect(result).toBeInstanceOf(ChatMessage);
    expect(result?.type).toBe('quickReply');
    expect(result?.role).toBe('AGENT');
    expect(result?.content).toBe('Pick an option below');
    expect(result?.quickReplies).toEqual(['Option A', 'Option B', 'Option C']);
    expect(result?.status).toBe('DELIVERED');
  });

  it('returns null when timestamp is missing', () => {
    const msg = baseEnvelope({
      guidanceCardResponse: {
        status: ResponseStatus.RESPONSE_STATUS_SUCCESS,
        timestamp: undefined as unknown as Date,
        guidanceTitle: '',
        guidanceDescription: '',
        guidanceCards: [],
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// sdkMessageToChatMessage — control messages (no ChatMessage produced)
// ---------------------------------------------------------------------------

describe('sdkMessageToChatMessage — control messages return null', () => {
  it('returns null for an empty envelope', () => {
    expect(sdkMessageToChatMessage(baseEnvelope())).toBeNull();
  });

  it('returns null for a TextMessageResponse (acknowledgement only)', () => {
    const msg = baseEnvelope({
      textMessageResponse: {
        status: ResponseStatus.RESPONSE_STATUS_SUCCESS,
        timestamp: NOW,
        messageId: 'ack-1',
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });

  it('returns null for a MessageReceiptRequest', () => {
    const msg = baseEnvelope({
      messageReceiptRequest: {
        status: ProtoMessageStatus.MESSAGE_STATUS_READ,
        messageId: 'msg-5',
        timestamp: NOW,
        quickReplies: [],
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });

  it('returns null for an AddToCartRequest', () => {
    const msg = baseEnvelope({
      addToCartRequest: {
        sku: 'SKU-001',
        quantity: 2,
        timestamp: NOW,
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });

  it('returns null for a ChatStatusRequest', () => {
    const msg = baseEnvelope({
      chatStatusRequest: {
        status: 'agent_typing',
        timestamp: NOW,
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });

  it('returns null for a CustomActionRequest', () => {
    const msg = baseEnvelope({
      customActionRequest: {
        actionId: 'scroll_top',
        payload: '{}',
        timestamp: NOW,
      },
    });

    expect(sdkMessageToChatMessage(msg)).toBeNull();
  });
});
