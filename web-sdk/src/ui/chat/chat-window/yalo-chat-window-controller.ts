// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { YaloChatWindow } from './yalo-chat-window';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ChangeQuantity } from '@domain/models/chat-events/change-quantity';
import type { PageInfo } from '@domain/common/page';
import { ChatMessageRepositoryLocal } from '@data/repositories/chat-message/chat-message-repository-local';
import { YaloMessageRepositoryRemote } from '@data/repositories/yalo-message/yalo-message-repository-remote';
import { YaloMessageAuthServiceRemote } from '@data/services/yalo-message/yalo-message-auth-service-remote';
import { TokenRepositoryLocal } from '@data/repositories/token/token-repository-local';
import { YaloMediaServiceRemote } from '@data/services/yalo-media/yalo-media-service-remote';
import { Product } from '@domain/models/product/product';

export default class YaloChatWindowController implements ReactiveController {
  host: YaloChatWindow;

  chatMessages: Array<ChatMessage> = [];

  pageInfo?: PageInfo = undefined;

  isLoadingMessages: boolean = false;

  isWriting: boolean = false;

  private readonly _messagePageSize = 500;
  private readonly _writingTimeoutMs = 30000;
  private _writingTimeout?: ReturnType<typeof setTimeout>;

  private readonly _DB_NAME = 'YaloChatMessages';
  private readonly _DB_VERSION = 2;

  private _openDb(): Promise<IDBDatabase> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this._DB_NAME, this._DB_VERSION);

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;
        ChatMessageRepositoryLocal.upgrade(db);
        TokenRepositoryLocal.upgrade(db);
      };

      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  constructor(host: YaloChatWindow) {
    this.host = host;
    this.host.addController(this);
  }

  // Method used to create all new dependencies to be injected to all components
  async hostConnected() {
    const db = await this._openDb();
    this.host.chatMessageRepository = new ChatMessageRepositoryLocal(db);

    const authService = new YaloMessageAuthServiceRemote(
      import.meta.env.VITE_YALO_API_BASE_URL,
      this.host.config
    );
    const tokenRepository = new TokenRepositoryLocal(db, authService);
    const mediaService = new YaloMediaServiceRemote(
      import.meta.env.VITE_YALO_API_BASE_URL,
      tokenRepository
    );
    this.host.yaloMessageRepository = new YaloMessageRepositoryRemote(
      import.meta.env.VITE_YALO_API_BASE_URL,
      this.host.config,
      tokenRepository,
      mediaService
    );
    this.host.yaloMediaService = mediaService;
    this.host.logger.debug('Initialized with config', this.host.config);

    const pages = await this.host.chatMessageRepository.getChatMessagePageDesc(
      null, // First page
      this._messagePageSize
    );

    if (pages.ok) {
      this.chatMessages = [...pages.value.data];
      this.pageInfo = pages.value.pageInfo;
      this.host.logger.debug('Fetching messages succeeded', {
        pageInfo: this.pageInfo,
      });
    } else {
      this.host.logger.error('Unable to fetch messages');
    }
    this.host.requestUpdate();

    // Subscribe to incoming message stream
    this.host.yaloMessageRepository.subscribeToMessages(this.onMessageReceived);
  }

  async sendTextMessage(e: CustomEvent) {
    const textMessage = e.detail as ChatMessage;

    const localResult =
      await this.host.chatMessageRepository.insertChatMessage(textMessage);

    if (localResult.ok) {
      this.host.logger.debug('Message inserted successfully');
      this.chatMessages = [localResult.value, ...this.chatMessages];
      this.host.requestUpdate();
      const yaloResult = await this.host.yaloMessageRepository.insertMessage(
        localResult.value
      );
      if (!yaloResult.ok) {
        this.host.logger.error('Unable to send message to Yalo', {
          error: yaloResult.error,
        });
      }
    } else {
      this.host.logger.error('Unable to insert message locally', {
        error: localResult.error,
      });
    }

    this.isWriting = true;
    this.host.requestUpdate();
    this._writingTimeout = setTimeout(() => {
      this.isWriting = false;
      this.host.requestUpdate();
    }, this._writingTimeoutMs);
  }

  async sendVoiceMessage(e: CustomEvent) {
    const { message: voiceMessage } = e.detail as {
      message: ChatMessage;
      blob: Blob;
    };

    const localResult =
      await this.host.chatMessageRepository.insertChatMessage(voiceMessage);

    if (localResult.ok) {
      this.host.logger.debug('Voice message inserted locally');
      this.chatMessages = [localResult.value, ...this.chatMessages];
      this.host.requestUpdate();
      const yaloResult = await this.host.yaloMessageRepository.insertMessage(
        localResult.value
      );
      if (!yaloResult.ok) {
        this.host.logger.error('Unable to send voice message to Yalo', {
          error: yaloResult.error,
        });
      }
    } else {
      this.host.logger.error('Unable to insert voice message locally', {
        error: localResult.error,
      });
    }

    this.isWriting = true;
    this.host.requestUpdate();
    this._writingTimeout = setTimeout(() => {
      this.isWriting = false;
      this.host.requestUpdate();
    }, this._writingTimeoutMs);
  }

  async sendAttachmentMessage(e: CustomEvent) {
    const { message: attachmentMessage } = e.detail as {
      message: ChatMessage;
      file: File;
    };

    const localResult =
      await this.host.chatMessageRepository.insertChatMessage(
        attachmentMessage
      );

    if (localResult.ok) {
      this.host.logger.debug('Attachment message inserted locally');
      this.chatMessages = [localResult.value, ...this.chatMessages];
      this.host.requestUpdate();
      const yaloResult = await this.host.yaloMessageRepository.insertMessage(
        localResult.value
      );
      if (!yaloResult.ok) {
        this.host.logger.error('Unable to send attachment message to Yalo', {
          error: yaloResult.error,
        });
      }
    } else {
      this.host.logger.error('Unable to insert attachment message locally', {
        error: localResult.error,
      });
    }

    this.isWriting = true;
    this.host.requestUpdate();
    this._writingTimeout = setTimeout(() => {
      this.isWriting = false;
      this.host.requestUpdate();
    }, this._writingTimeoutMs);
  }

  async sendImageMessage(e: CustomEvent) {
    const { message: imageMessage } = e.detail as {
      message: ChatMessage;
      file: File;
    };

    const localResult =
      await this.host.chatMessageRepository.insertChatMessage(imageMessage);

    if (localResult.ok) {
      this.host.logger.debug('Image message inserted locally');
      this.chatMessages = [localResult.value, ...this.chatMessages];
      this.host.requestUpdate();
      const yaloResult = await this.host.yaloMessageRepository.insertMessage(
        localResult.value
      );
      if (!yaloResult.ok) {
        this.host.logger.error('Unable to send image message to Yalo', {
          error: yaloResult.error,
        });
      }
    } else {
      this.host.logger.error('Unable to insert image message locally', {
        error: localResult.error,
      });
    }

    this.isWriting = true;
    this.host.requestUpdate();
    this._writingTimeout = setTimeout(() => {
      this.isWriting = false;
      this.host.requestUpdate();
    }, this._writingTimeoutMs);
  }

  async updateProductQuantity(e: CustomEvent) {
    const { messageId, sku, unitType, value } = e.detail as ChangeQuantity;

    const messageIndex = this.chatMessages.findIndex((m) => m.id === messageId);
    if (messageIndex === -1) return;

    const message = this.chatMessages[messageIndex];
    const productIndex = message.products.findIndex((p) => p.sku === sku);
    const product = message.products[productIndex];

    const updatedProducts = [...message.products];
    if (unitType === 'unit') {
      updatedProducts[productIndex] = new Product({
        ...product,
        unitsAdded: Math.max(value, 0),
      });
    } else {
      const subunitsAdded = Math.max(value, 0);
      const extraUnits = Math.floor(subunitsAdded / product.subunits);
      const subunitsMod = subunitsAdded % product.subunits;
      updatedProducts[productIndex] = new Product({
        ...product,
        unitsAdded: product.unitsAdded + extraUnits,
        subunitsAdded: subunitsMod,
      });
    }

    const updatedMessage = new ChatMessage({
      ...message,
      products: updatedProducts,
    });

    const result =
      await this.host.chatMessageRepository.replaceChatMessage(updatedMessage);
    if (result.ok) {
      this.chatMessages = [...this.chatMessages];
      this.chatMessages[messageIndex] = updatedMessage;
      this.host.requestUpdate();
    } else {
      this.host.logger.error('Unable to update product quantity', {
        error: result.error,
      });
    }
  }

  async fetchNextPage() {
    if (this.pageInfo?.nextCursor) {
      this.host.logger.debug('Fetching next messages');
      this.isLoadingMessages = true;
      this.host.requestUpdate();
      const pages =
        await this.host.chatMessageRepository.getChatMessagePageDesc(
          this.pageInfo?.nextCursor,
          this._messagePageSize
        );

      if (pages.ok) {
        this.chatMessages = [...this.chatMessages, ...pages.value.data];
        this.pageInfo = pages.value.pageInfo;
        this.host.logger.debug('Messages fetched successfully');
      } else {
        this.host.logger.error('Unable to fetch next message page');
      }
      this.isLoadingMessages = false;
      this.host.requestUpdate();
    }
  }

  onMessageReceived = async (chatMessages: ChatMessage[]) => {
    clearTimeout(this._writingTimeout);
    this.isWriting = false;
    this.host.logger.debug(`Received ${chatMessages.length} messages`);
    const results = await Promise.all(
      chatMessages.map((message) =>
        this.host.chatMessageRepository.insertChatMessage(message)
      )
    );

    const insertedMessages = results
      .filter((result) => result.ok)
      .map((result) => result.value);
    if (insertedMessages.length > 0) {
      this.chatMessages = [...insertedMessages, ...this.chatMessages];
      this.host.requestUpdate();
    }
  };

  hostDisconnected() {
    clearTimeout(this._writingTimeout);
    this.host.yaloMessageRepository.unsubscribeMessages();
  }
}
