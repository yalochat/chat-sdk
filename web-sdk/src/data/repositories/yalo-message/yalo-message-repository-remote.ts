// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  PollCallback,
  YaloMessageRepository,
} from './yalo-message-repository';
import {
  MessageRole,
  MessageStatus,
  SdkMessage,
  PollMessageItem,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { YaloMediaService } from '@data/services/yalo-media/yalo-media-service';

interface JwtPayload {
  user_id: string;
}

export class YaloMessageRepositoryRemote implements YaloMessageRepository {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;
  private readonly _tokenRepository: TokenRepository;
  private readonly _mediaService: YaloMediaService;
  private _pollTimeout?: ReturnType<typeof setTimeout>;
  private _seenIds = new Set<string>();
  private _pollInterval = 2000;

  constructor(
    baseUrl: string,
    config: YaloChatClientConfig,
    tokenRepository: TokenRepository,
    mediaService: YaloMediaService
  ) {
    this._baseUrl = baseUrl;
    this._config = config;
    this._tokenRepository = tokenRepository;
    this._mediaService = mediaService;
  }

  private _createSdkMessage(message: ChatMessage, mediaId?: string): SdkMessage {
    const timestamp = new Date();

    let body: SdkMessage | undefined;
    switch (message.type) {
      case 'text':
        body = {
          correlationId: message.id?.toString() || '',
          textMessageRequest: {
            content: {
              timestamp: message.timestamp,
              text: message.content,
              status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
              role: MessageRole.MESSAGE_ROLE_USER,
            },
            timestamp: timestamp,
          },
          timestamp: timestamp,
        };
        break;
      case 'image':
        body = {
          correlationId: message.id?.toString() || '',
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
            timestamp: timestamp,
            quickReplies: [],
          },
          timestamp: timestamp,
        };
        break;
      case 'voice':
        body = {
          correlationId: message.id?.toString() || '',
          voiceMessageRequest: {
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
            timestamp: timestamp,
            quickReplies: [],
          },
          timestamp: timestamp,
        };
        break;
      default:
        throw Error('UnimplementedError');
    }

    return body;
  }

  async insertMessage(message: ChatMessage): Promise<Result<ChatMessage>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);

    try {
      let mediaId: string | undefined;
      if (
        (message.type === 'image' || message.type === 'voice') &&
        message.blob
      ) {
        const file = new File(
          [message.blob],
          message.fileName ?? `media-${Date.now()}`,
          { type: message.mediaType ?? message.blob.type }
        );
        const uploadResult = await this._mediaService.uploadMedia(file);
        if (!uploadResult.ok) return uploadResult;
        mediaId = uploadResult.value.id;
      }

      const body = this._createSdkMessage(message, mediaId);
      const response = await fetch(
        `${this._baseUrl}/webchat/inbound_messages`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-channel-id': this._config.channelId,
            'x-user-id': userId,
            authorization: `Bearer ${token}`,
          },
          body: JSON.stringify(SdkMessage.toJSON(body)),
        }
      );

      if (!response.ok) {
        return new Err(new Error(`insertMessage failed: ${response.status}`));
      }

      return new Ok(message);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  private _translateMessageResponse(
    item: PollMessageItem
  ): ChatMessage | null {
    const timestamp = item.date ?? new Date();
    const msg = item.message!;

    if (msg.textMessageRequest?.content) {
      return ChatMessage.text({
        role: 'AGENT',
        timestamp,
        content: msg.textMessageRequest.content.text,
        wiId: item.id,
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
      });
    }

    if (msg.voiceMessageRequest?.content) {
      const content = msg.voiceMessageRequest.content;
      return ChatMessage.voice({
        role: 'AGENT',
        timestamp,
        fileName: content.fileName,
        amplitudes: content.amplitudesPreview,
        duration: content.duration,
        mediaType: content.mediaType,
        byteCount: content.byteCount,
        wiId: item.id,
      });
    }

    return null;
  }

  subscribeToMessages(callback: PollCallback): void {
    const poll = async () => {
      const authResult = await this._tokenRepository.getToken();
      if (!authResult.ok) return;

      const token = authResult.value;
      const userId = this._decodeUserId(token);

      try {
        const params = new URLSearchParams({
          since: String(Math.floor(Date.now() - 5000)),
        });
        const response = await fetch(
          `${this._baseUrl}/webchat/messages?${params}`,
          {
            method: 'GET',
            headers: {
              authorization: `Bearer ${token}`,
              accept: 'application/json',
              'x-channel-id': this._config.channelId,
              'x-user-id': userId,
            },
          }
        );

        if (!response.ok) return;

        const json = (await response.json()) as Array<unknown>;
        const data = json.map((item) => PollMessageItem.fromJSON(item));

        const newMessages = data
          .filter(
            (item) => !this._seenIds.has(item.id) && item.message != null
          )
          .map((item) => {
            this._seenIds.add(item.id);
            return this._translateMessageResponse(item);
          })
          .filter((msg): msg is ChatMessage => msg !== null);

        if (newMessages.length > 0) callback(newMessages);
      } catch {
        // swallow network errors — next poll will retry
      }

      this._pollTimeout = setTimeout(poll, this._pollInterval);
    };

    poll();
  }

  unsubscribeMessages(): void {
    clearTimeout(this._pollTimeout);
    this._pollTimeout = undefined;
    this._seenIds.clear();
  }

  private _decodeUserId(token: string): string {
    const payload = token.split('.')[1];
    const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
    return (JSON.parse(decoded) as JwtPayload).user_id;
  }
}
