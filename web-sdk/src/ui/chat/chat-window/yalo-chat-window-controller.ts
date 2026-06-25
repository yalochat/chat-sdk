// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { YaloChatWindow } from './yalo-chat-window';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ChangeQuantity } from '@domain/models/chat-events/change-quantity';
import type { PageInfo } from '@domain/common/page';
import type {
  CustomCommandRequest,
  SdkMessage,
  SdkMessageAck,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import {
  computeEffectiveAuthUserId,
  computeSessionId,
} from '@common/session';
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
  private readonly _messageAckTimeoutMs = 10000;
  private _writingTimeout?: ReturnType<typeof setTimeout>;
  private _guidanceCardRequested = false;
  private _messagesLoaded = false;
  private _pendingAckTimers = new Map<string, ReturnType<typeof setTimeout>>();

  private static readonly _DB_NAME = 'YaloChatMessages';
  private static readonly _DB_VERSION = 1;

  private _openDb(): Promise<IDBDatabase> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(
        YaloChatWindowController._DB_NAME,
        YaloChatWindowController._DB_VERSION
      );

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

  private _handleEphemeralPageHide = () => {
    const messageRepo = this.host.chatMessageRepository;
    const tokenRepo = this._tokenRepository;
    this.host.yaloMessageRepository.unsubscribeMessages();
    Promise.all([messageRepo.clearSession(), tokenRepo?.clearSession()]).finally(
      () => messageRepo.dispose()
    );
  };

  private _handleVisibilityChange = () => {
    if (document.visibilityState !== 'visible') {
      return;
    }
    if (!this._messagesLoaded) {
      return;
    }
    this._syncFromStorage();
  };

  private async _syncFromStorage(): Promise<void> {
    const result = await this.host.chatMessageRepository.getChatMessagePageDesc(
      null,
      this._messagePageSize
    );
    if (!result.ok) {
      this.host.logger.error('Unable to sync messages from storage', {
        error: result.error,
      });
      return;
    }
    const freshPage = result.value.data;
    const freshIds = new Set(freshPage.map((m) => m.id));
    const older = this.chatMessages.filter((m) => !freshIds.has(m.id));
    this.chatMessages = [...freshPage, ...older];
    this.host.logger.debug('Synced messages from storage', {
      count: this.chatMessages.length,
    });
    this.host.requestUpdate();
  }

  private _tokenRepository?: TokenRepositoryLocal;

  // Method used to create all new dependencies to be injected to all components
  async hostConnected() {
    if (this.host.config.logLevel) {
      this.host.logger.currentLevel = this.host.config.logLevel;
    }
    const ephemeralToken =
      this.host.config.sessionMode === 'ephemeral'
        ? crypto.randomUUID()
        : undefined;
    const sessionId = computeSessionId(this.host.config, ephemeralToken);
    const db = await this._openDb();
    this.host.chatMessageRepository = new ChatMessageRepositoryLocal(
      db,
      sessionId
    );

    const authService = new YaloMessageAuthServiceRemote(
      import.meta.env.VITE_YALO_API_BASE_URL,
      {
        ...this.host.config,
        userId: computeEffectiveAuthUserId(this.host.config, ephemeralToken),
      }
    );
    const tokenRepository = new TokenRepositoryLocal(db, sessionId, authService);
    this._tokenRepository = tokenRepository;

    if (this.host.config.sessionMode === 'ephemeral') {
      await Promise.all([
        this.host.chatMessageRepository.clearSession(),
        tokenRepository.clearSession(),
      ]);
      window.addEventListener('pagehide', this._handleEphemeralPageHide);
    }
    document.addEventListener('visibilitychange', this._handleVisibilityChange);
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
      context ? JSON.stringify(context) : undefined
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
      } else {
        this._trackPendingAck(localResult.value);
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
      } else {
        this._trackPendingAck(localResult.value);
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
      } else {
        this._trackPendingAck(localResult.value);
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
      } else {
        this._trackPendingAck(localResult.value);
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
    } else {
      this._trackPendingAck(retrying);
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

  private async _setMessageStatus(
    message: ChatMessage,
    status: ChatMessage['status']
  ): Promise<void> {
    const updated = new ChatMessage({ ...message, status });
    const result =
      await this.host.chatMessageRepository.replaceChatMessage(updated);
    if (!result.ok) {
      this.host.logger.error('Unable to persist message status locally', {
        error: result.error,
        status,
      });
      return;
    }
    const index = this.chatMessages.findIndex((m) => m.id === updated.id);
    if (index === -1) return;
    this.chatMessages = [...this.chatMessages];
    this.chatMessages[index] = updated;
    this.host.requestUpdate();
  }

  private _markMessageAsError(message: ChatMessage): Promise<void> {
    return this._setMessageStatus(message, 'ERROR');
  }

  private _trackPendingAck(message: ChatMessage): void {
    if (message.id === undefined) {
      return;
    }
    const correlationId = String(message.id);
    const existing = this._pendingAckTimers.get(correlationId);
    if (existing) {
      clearTimeout(existing);
    }
    const timer = setTimeout(() => {
      this._pendingAckTimers.delete(correlationId);
      const current = this.chatMessages.find((m) => m.id === message.id);
      if (!current || current.status === 'ERROR') {
        return;
      }
      this.host.logger.error('Message ack timed out', { correlationId });
      void this._markMessageAsError(current);
    }, this._messageAckTimeoutMs);
    this._pendingAckTimers.set(correlationId, timer);
  }

  private async _handleMessageAck(ack: SdkMessageAck): Promise<void> {
    const correlationId = ack.correlationId;
    const timer = this._pendingAckTimers.get(correlationId);
    if (timer) {
      clearTimeout(timer);
      this._pendingAckTimers.delete(correlationId);
    }
    const messageId = Number(correlationId);
    if (Number.isNaN(messageId)) {
      return;
    }
    const message = this.chatMessages.find((m) => m.id === messageId);
    if (!message || message.status !== 'ERROR') {
      return;
    }
    await this._setMessageStatus(message, 'IN_PROGRESS');
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

  onMessageReceived = async (
    event: ChatMessage[] | SdkMessageAck | SdkMessage
  ) => {
    if (Array.isArray(event)) {
      await this._handleChatMessages(event);
      return;
    }
    if ('type' in event) {
      await this._handleMessageAck(event);
      return;
    }
    await this._handleChannelCommand(event);
  };

  private async _handleChannelCommand(message: SdkMessage): Promise<void> {
    if (message.customCommandRequest) {
      await this._handleCustomCommand(
        message.correlationId,
        message.customCommandRequest
      );
      return;
    }
    this.host.logger.warn('Received unsupported channel command', {
      correlationId: message.correlationId,
    });
  }

  private async _handleCustomCommand(
    correlationId: string,
    request: CustomCommandRequest
  ): Promise<void> {
    const handler = this.host.channelCommands.get(request.commandId);
    if (!handler) {
      this.host.logger.warn('Received unregistered command', {
        commandId: request.commandId,
      });
      return;
    }

    let payload: string;
    try {
      payload = (await handler(request.payload)) ?? '';
    } catch (error) {
      this.host.logger.error('Command handler threw', {
        error,
        commandId: request.commandId,
      });
      await this._sendCustomCommandResponse(correlationId, 'error', '');
      return;
    }

    await this._sendCustomCommandResponse(correlationId, 'success', payload);
  }

  private async _sendCustomCommandResponse(
    correlationId: string,
    status: 'success' | 'error',
    payload: string
  ): Promise<void> {
    const result =
      await this.host.yaloMessageRepository.sendCustomCommandResponse(
        correlationId,
        status,
        payload
      );
    if (!result.ok) {
      this.host.logger.error('Unable to send custom command response', {
        error: result.error,
        correlationId,
      });
    }
  }

  private async _handleChatMessages(
    chatMessages: ChatMessage[]
  ): Promise<void> {
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
  }

  hostDisconnected() {
    clearTimeout(this._writingTimeout);
    for (const timer of this._pendingAckTimers.values()) {
      clearTimeout(timer);
    }
    this._pendingAckTimers.clear();
    window.removeEventListener('pagehide', this._handleEphemeralPageHide);
    document.removeEventListener(
      'visibilitychange',
      this._handleVisibilityChange
    );
    this.host.yaloMessageRepository.unsubscribeMessages();
    this.host.chatMessageRepository.dispose();
  }
}
