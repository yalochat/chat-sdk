// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { YaloChatWindow } from './yalo-chat-window';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { PageInfo } from '@domain/common/page';

export default class YaloChatWindowController implements ReactiveController {
  host: YaloChatWindow;

  chatMessages: Array<ChatMessage> = [];

  pageInfo?: PageInfo = undefined;

  isLoadingMessages: boolean = false;

  isWriting: boolean = false;

  private readonly _messagePageSize = 500;
  private readonly _writingTimeoutMs = 30000;
  private _writingTimeout?: ReturnType<typeof setTimeout>;

  constructor(host: YaloChatWindow) {
    this.host = host;
    this.host.addController(this);
  }

  async sendTextMessage(e: CustomEvent) {
    const textMessage = e.detail as ChatMessage;

    const localResult =
      await this.host.chatMessageRepository.insertChatMessage(textMessage);

    if (localResult.ok) {
      this.host.logger.debug('Message inserted successfully');
      this.chatMessages = [localResult.value, ...this.chatMessages];
      this.host.requestUpdate();
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

    const yaloResult =
      await this.host.yaloMessageRepository.insertMessage(textMessage);
    if (!yaloResult.ok) {
      this.host.logger.error('Unable to send message to Yalo', {
        error: yaloResult.error,
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

  async hostConnected() {
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

  hostDisconnected() {
    clearTimeout(this._writingTimeout);
    this.host.yaloMessageRepository.unsubscribeMessages();
  }
}
