// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { YaloChatWindow } from './yalo-chat-window';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ChangeQuantity } from '@domain/models/chat-events/change-quantity';
import type { PageInfo } from '@domain/common/page';
import { ChatMessageRepositoryLocal } from '@data/repositories/chat-message/chat-message-repository-local';
import { YaloMessageRepositoryRemote } from '@data/repositories/yalo-message/yalo-message-repository-remote';
import { YaloMessageAuthServiceRemote } from '@data/services/yalo-message/yalo-message-auth-service-remote';
import { YaloMessageServiceWebSocket } from '@data/services/yalo-message/yalo-message-service-websocket';
import { TokenRepositoryLocal } from '@data/repositories/token/token-repository-local';
import { YaloMediaServiceRemote } from '@data/services/yalo-media/yalo-media-service-remote';
import { Product } from '@domain/models/product/product';

export default class YaloChatWindowController implements ReactiveController {
  host: YaloChatWindow;

  chatMessages: Array<ChatMessage> = [];

  pageInfo?: PageInfo = undefined;

  isLoadingMessages: boolean = false;

  isWriting: boolean = false;

  chatStatusText: string = '';

  private readonly _messagePageSize = 500;
  private readonly _writingTimeoutMs = 30000;
  private _writingTimeout?: ReturnType<typeof setTimeout>;
  private _guidanceCardRequested = false;
  private _messagesLoaded = false;

  private readonly _DB_VERSION = 2;

  private get _dbName(): string {
    const { organizationId, channelId, userId } = this.host.config;
    return `YaloChatMessages-${organizationId}-${channelId}-${userId ?? 'anonymous'}`;
  }

  private _openDb(): Promise<IDBDatabase> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this._dbName, this._DB_VERSION);

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;
        ChatMessageRepositoryLocal.upgrade(db);
        TokenRepositoryLocal.upgrade(db);
      };

      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  private _deleteDb(): Promise<void> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.deleteDatabase(this._dbName);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
      request.onblocked = () => resolve();
    });
  }

  constructor(host: YaloChatWindow) {
    this.host = host;
    this.host.addController(this);
  }

  private _handleNonPersistentPageHide = () => {
    this.host.chatMessageRepository.dispose();
    this.host.yaloMessageRepository.unsubscribeMessages();
    indexedDB.deleteDatabase(this._dbName);
  };

  // Method used to create all new dependencies to be injected to all components
  async hostConnected() {
    if (this.host.config.persistent === false) {
      await this._deleteDb();
      window.addEventListener('pagehide', this._handleNonPersistentPageHide);
    }
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
    const messageService = new YaloMessageServiceWebSocket(
      import.meta.env.VITE_YALO_API_BASE_URL,
      tokenRepository
    );
    this.host.yaloMessageRepository = new YaloMessageRepositoryRemote(
      messageService,
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
    this._messagesLoaded = true;
    this.host.requestUpdate();

    // Subscribe to incoming message stream
    this.host.yaloMessageRepository.subscribeToMessages(this.onMessageReceived);

    if (this.host.open) {
      await this.requestGuidanceCardIfEmpty();
    }
  }

  async requestGuidanceCardIfEmpty(): Promise<void> {
    if (this._guidanceCardRequested) {
      return;
    }
    if (!this._messagesLoaded) {
      return;
    }
    if (this.chatMessages.length > 0) {
      return;
    }
    this._guidanceCardRequested = true;
    const context = this.host.openContext ?? this.host.config.openContext;
    const result = await this.host.yaloMessageRepository.requestGuidanceCard(
      this.host.config.target,
      context
    );
    if (!result.ok) {
      this.host.logger.error('Unable to request guidance cards', {
        error: result.error,
      });
    }
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
        await this._markMessageAsError(localResult.value);
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
        await this._markMessageAsError(localResult.value);
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
        await this._markMessageAsError(localResult.value);
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
        await this._markMessageAsError(localResult.value);
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

  async retryMessage(e: CustomEvent) {
    const message = e.detail as ChatMessage;
    if (message.id === undefined) return;

    const retrying = new ChatMessage({ ...message, status: 'IN_PROGRESS' });
    const localResult =
      await this.host.chatMessageRepository.replaceChatMessage(retrying);
    if (!localResult.ok) {
      this.host.logger.error('Unable to update message for retry', {
        error: localResult.error,
      });
      return;
    }

    const index = this.chatMessages.findIndex((m) => m.id === retrying.id);
    if (index !== -1) {
      this.chatMessages = [...this.chatMessages];
      this.chatMessages[index] = retrying;
      this.host.requestUpdate();
    }

    const yaloResult =
      await this.host.yaloMessageRepository.insertMessage(retrying);
    if (!yaloResult.ok) {
      this.host.logger.error('Unable to retry sending message to Yalo', {
        error: yaloResult.error,
      });
      await this._markMessageAsError(retrying);
    }
  }

  async markProductAddedToCart(e: CustomEvent) {
    const { messageId, sku } = e.detail as {
      messageId: number;
      sku: string;
    };

    const messageIndex = this.chatMessages.findIndex((m) => m.id === messageId);
    if (messageIndex === -1) {
      return;
    }
    const message = this.chatMessages[messageIndex];
    const productIndex = message.products.findIndex((p) => p.sku === sku);
    if (productIndex === -1) {
      return;
    }
    const product = message.products[productIndex];

    const updatedProducts = [...message.products];
    updatedProducts[productIndex] = new Product({ ...product, inCart: true });
    const updatedMessage = new ChatMessage({
      ...message,
      products: updatedProducts,
    });

    const result =
      await this.host.chatMessageRepository.replaceChatMessage(updatedMessage);
    if (!result.ok) {
      this.host.logger.error('Unable to persist cart state', {
        error: result.error,
      });
      return;
    }

    this.chatMessages = [...this.chatMessages];
    this.chatMessages[messageIndex] = updatedMessage;
    this.host.requestUpdate();

    const subunits =
      product.subunitsAdded > 0 ? product.subunitsAdded : undefined;
    const updateCartProduct = this.host.commands.get('updateCartProduct');
    if (updateCartProduct) {
      this.host.logger.debug('Executing updateCartProduct command', {
        sku: product.sku,
        units: product.unitsAdded,
        subunits,
      });
      updateCartProduct({
        sku: product.sku,
        units: product.unitsAdded,
        subunits,
      });
      return;
    }

    this.host.logger.debug('Sending updateCartProduct to repository', {
      sku: product.sku,
      units: product.unitsAdded,
      subunits,
    });
    const sendResult = await this.host.yaloMessageRepository.updateCartProduct(
      product.sku,
      product.unitsAdded,
      subunits
    );
    if (!sendResult.ok) {
      this.host.logger.error('Unable to send updateCartProduct', {
        error: sendResult.error,
      });
    }
  }

  async markProductConfirmationClicked(e: CustomEvent) {
    const message = e.detail as ChatMessage;
    if (message.id === undefined) {
      return;
    }
    if (message.status === 'CLICKED') {
      return;
    }

    const clicked = new ChatMessage({ ...message, status: 'CLICKED' });
    const result =
      await this.host.chatMessageRepository.replaceChatMessage(clicked);
    if (!result.ok) {
      this.host.logger.error('Unable to persist clicked status locally', {
        error: result.error,
      });
      return;
    }

    const index = this.chatMessages.findIndex((m) => m.id === clicked.id);
    if (index === -1) {
      return;
    }
    this.chatMessages = [...this.chatMessages];
    this.chatMessages[index] = clicked;
    this.host.requestUpdate();

    const product = clicked.products[0];
    if (!product) {
      return;
    }
    const subunits =
      product.subunitsAdded > 0 ? product.subunitsAdded : undefined;
    const updateCartProduct = this.host.commands.get('updateCartProduct');
    if (updateCartProduct) {
      this.host.logger.debug('Executing updateCartProduct command', {
        sku: product.sku,
        units: product.unitsAdded,
        subunits,
      });
      updateCartProduct({
        sku: product.sku,
        units: product.unitsAdded,
        subunits,
      });
      return;
    }

    this.host.logger.debug('Sending updateCartProduct to repository', {
      sku: product.sku,
      units: product.unitsAdded,
      subunits,
    });
    const sendResult = await this.host.yaloMessageRepository.updateCartProduct(
      product.sku,
      product.unitsAdded,
      subunits
    );
    if (!sendResult.ok) {
      this.host.logger.error('Unable to send updateCartProduct', {
        error: sendResult.error,
      });
    }
  }

  private async _markMessageAsError(message: ChatMessage): Promise<void> {
    const errored = new ChatMessage({ ...message, status: 'ERROR' });
    const result =
      await this.host.chatMessageRepository.replaceChatMessage(errored);
    if (!result.ok) {
      this.host.logger.error('Unable to persist error status locally', {
        error: result.error,
      });
      return;
    }
    const index = this.chatMessages.findIndex((m) => m.id === errored.id);
    if (index === -1) return;
    this.chatMessages = [...this.chatMessages];
    this.chatMessages[index] = errored;
    this.host.requestUpdate();
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
    if (!result.ok) {
      this.host.logger.error('Unable to update product quantity', {
        error: result.error,
      });
      return;
    }

    this.chatMessages = [...this.chatMessages];
    this.chatMessages[messageIndex] = updatedMessage;
    this.host.requestUpdate();
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

    const statusMessages = chatMessages.filter((m) => m.type === 'chat-status');
    const regularMessages = chatMessages.filter(
      (m) => m.type !== 'chat-status'
    );

    if (statusMessages.length > 0) {
      this.chatStatusText = statusMessages[statusMessages.length - 1].content;
      this.host.requestUpdate();
    }

    if (regularMessages.length === 0) return;

    const results = await Promise.all(
      regularMessages.map((message) =>
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
    window.removeEventListener('pagehide', this._handleNonPersistentPageHide);
    this.host.yaloMessageRepository.unsubscribeMessages();
    this.host.chatMessageRepository.dispose();
  }
}
