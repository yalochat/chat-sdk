// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  chatMessageCopyWith,
  chatMessageText,
  MessageRole,
  MessageStatus,
  MessageType,
  type ChatMessage,
} from '../domain/chat-message.js';
import type { ChatEvent } from '../domain/chat-event.js';
import type { ChatMessageRepository } from '../data/repositories/chat-message/chat-message-repository.js';
import type { YaloMessageRepository } from '../data/repositories/yalo-message/yalo-message-repository.js';
import type { ImageRepository } from '../data/repositories/image/image-repository.js';
import type { PageDirection } from '../common/page.js';
import { DEFAULT_PAGE_SIZE } from '../common/page.js';

export type ChatStatus =
  | 'initial'
  | 'success'
  | 'failure'
  | 'offline'
  | 'failedMessageSent'
  | 'failedRecordMessage'
  | 'failedToReceiveMessage'
  | 'failedToUpdateMessage';

export interface ChatState {
  messages: ChatMessage[];
  userMessage: string;
  isConnected: boolean;
  isLoading: boolean;
  isSystemTypingMessage: boolean;
  chatTitle: string;
  chatStatus: ChatStatus;
  chatStatusText: string;
  quickReplies: string[];
  cursor: number | undefined;
  hasMore: boolean;
}

export function initialChatState(): ChatState {
  return {
    messages: [],
    userMessage: '',
    isConnected: false,
    isLoading: false,
    isSystemTypingMessage: false,
    chatTitle: '',
    chatStatus: 'initial',
    chatStatusText: '',
    quickReplies: [],
    cursor: undefined,
    hasMore: true,
  };
}

export interface ChatDependencies {
  chatMessageRepository: ChatMessageRepository;
  yaloMessageRepository: YaloMessageRepository;
  imageRepository: ImageRepository;
  pageSize?: number;
  name?: string;
}

/** Replaces Flutter's MessagesBloc. Emits 'change' CustomEvent with ChatState detail. */
export class ChatStore extends EventTarget {
  private _state: ChatState;
  private readonly _pageSize: number;
  private _unsubscribeMessage?: () => void;
  private _unsubscribeEvent?: () => void;

  constructor(private readonly deps: ChatDependencies) {
    super();
    this._state = initialChatState();
    this._pageSize = deps.pageSize ?? DEFAULT_PAGE_SIZE;
    if (deps.name) {
      this._state = { ...this._state, chatTitle: deps.name };
    }
  }

  get state(): Readonly<ChatState> {
    return this._state;
  }

  /** Initialize: load first page + subscribe to incoming messages and events. */
  async initialize(): Promise<void> {
    await this.loadMessages('initial');
    this.subscribeToMessages();
    this.subscribeToEvents();
  }

  private setState(patch: Partial<ChatState>): void {
    this._state = { ...this._state, ...patch };
    this.dispatchEvent(new CustomEvent('change', { detail: this._state }));
  }

  async loadMessages(direction: PageDirection): Promise<void> {
    if (this._state.isLoading) return;
    if (direction !== 'initial' && !this._state.hasMore) return;

    this.setState({ isLoading: true });
    const cursor = direction === 'initial' ? undefined : this._state.cursor;
    const result = await this.deps.chatMessageRepository.getChatMessagePageDesc(cursor, this._pageSize);

    if (result.ok) {
      const { data, pageInfo } = result.value;
      const existing = direction === 'initial' ? [] : this._state.messages;
      // Messages from IDB are newest-first; we keep them in that order for rendering
      this.setState({
        messages: [...existing, ...data],
        isLoading: false,
        cursor: pageInfo.nextCursor,
        hasMore: pageInfo.nextCursor !== undefined,
        chatStatus: 'success',
      });
    } else {
      this.setState({ isLoading: false, chatStatus: 'failure' });
    }
  }

  private subscribeToMessages(): void {
    this._unsubscribeMessage = this.deps.yaloMessageRepository.onMessage(async (msg) => {
      const insertResult = await this.deps.chatMessageRepository.insertChatMessage(msg);
      if (insertResult.ok) {
        const newMsg = insertResult.value;
        this.setState({
          messages: [newMsg, ...this._state.messages],
          isSystemTypingMessage: false,
          quickReplies: newMsg.quickReplies,
        });
      } else {
        this.setState({ chatStatus: 'failedToReceiveMessage' });
      }
    });
  }

  private subscribeToEvents(): void {
    this._unsubscribeEvent = this.deps.yaloMessageRepository.onEvent((event: ChatEvent) => {
      if (event.type === 'typingStart') {
        this.setState({ isSystemTypingMessage: true, chatStatusText: event.statusText });
      } else {
        this.setState({ isSystemTypingMessage: false, chatStatusText: '' });
      }
    });
  }

  updateUserMessage(text: string): void {
    this.setState({ userMessage: text });
  }

  async sendTextMessage(content: string): Promise<void> {
    const msg = chatMessageText({
      role: MessageRole.User,
      timestamp: Date.now(),
      content,
    });

    const insertResult = await this.deps.chatMessageRepository.insertChatMessage(msg);
    if (!insertResult.ok) {
      this.setState({ chatStatus: 'failedMessageSent' });
      return;
    }

    const inserted = insertResult.value;
    this.setState({
      messages: [inserted, ...this._state.messages],
      userMessage: '',
      quickReplies: [],
    });

    const sendResult = await this.deps.yaloMessageRepository.sendMessage(inserted);
    if (sendResult.ok) {
      const updated = chatMessageCopyWith(inserted, { status: MessageStatus.Sent });
      await this.deps.chatMessageRepository.replaceChatMessage(updated);
      this.setState({
        messages: this._state.messages.map((m) => (m.id === inserted.id ? updated : m)),
      });
    } else {
      const failed = chatMessageCopyWith(inserted, { status: MessageStatus.Error });
      await this.deps.chatMessageRepository.replaceChatMessage(failed);
      this.setState({
        messages: this._state.messages.map((m) => (m.id === inserted.id ? failed : m)),
        chatStatus: 'failedMessageSent',
      });
    }
  }

  async sendImageMessage(fileName: string, content?: string): Promise<void> {
    const { chatMessageImage } = await import('../domain/chat-message.js');
    const msg = chatMessageImage({
      role: MessageRole.User,
      timestamp: Date.now(),
      fileName,
      content,
    });

    const insertResult = await this.deps.chatMessageRepository.insertChatMessage(msg);
    if (!insertResult.ok) {
      this.setState({ chatStatus: 'failedMessageSent' });
      return;
    }
    const inserted = insertResult.value;
    this.setState({ messages: [inserted, ...this._state.messages], quickReplies: [] });

    const sendResult = await this.deps.yaloMessageRepository.sendMessage(inserted);
    if (!sendResult.ok) {
      const failed = chatMessageCopyWith(inserted, { status: MessageStatus.Error });
      await this.deps.chatMessageRepository.replaceChatMessage(failed);
      this.setState({
        messages: this._state.messages.map((m) => (m.id === inserted.id ? failed : m)),
        chatStatus: 'failedMessageSent',
      });
    }
  }

  async sendVoiceMessage(opts: {
    fileName: string;
    amplitudes: number[];
    duration: number;
  }): Promise<void> {
    const { chatMessageVoice } = await import('../domain/chat-message.js');
    const msg = chatMessageVoice({
      role: MessageRole.User,
      timestamp: Date.now(),
      fileName: opts.fileName,
      amplitudes: opts.amplitudes,
      duration: opts.duration,
    });

    const insertResult = await this.deps.chatMessageRepository.insertChatMessage(msg);
    if (!insertResult.ok) {
      this.setState({ chatStatus: 'failedRecordMessage' });
      return;
    }
    const inserted = insertResult.value;
    this.setState({ messages: [inserted, ...this._state.messages], quickReplies: [] });

    const sendResult = await this.deps.yaloMessageRepository.sendMessage(inserted);
    if (!sendResult.ok) {
      const failed = chatMessageCopyWith(inserted, { status: MessageStatus.Error });
      await this.deps.chatMessageRepository.replaceChatMessage(failed);
      this.setState({
        messages: this._state.messages.map((m) => (m.id === inserted.id ? failed : m)),
        chatStatus: 'failedRecordMessage',
      });
    }
  }

  async updateProductQuantity(messageId: number, sku: string, unitsAdded: number, subunitsAdded: number): Promise<void> {
    const msg = this._state.messages.find((m) => m.id === messageId);
    if (!msg) return;

    const updatedProducts = msg.products.map((p) =>
      p.sku === sku ? { ...p, unitsAdded, subunitsAdded } : p,
    );
    const updated = chatMessageCopyWith(msg, { products: updatedProducts });
    await this.deps.chatMessageRepository.replaceChatMessage(updated);
    this.setState({
      messages: this._state.messages.map((m) => (m.id === messageId ? updated : m)),
    });
  }

  toggleMessageExpand(messageId: number): void {
    this.setState({
      messages: this._state.messages.map((m) =>
        m.id === messageId ? chatMessageCopyWith(m, { expand: !m.expand }) : m,
      ),
    });
  }

  clearQuickReplies(): void {
    this.setState({ quickReplies: [] });
  }

  clearMessages(): void {
    this.setState(initialChatState());
  }

  /** Clean up subscriptions and polling. */
  dispose(): void {
    this._unsubscribeMessage?.();
    this._unsubscribeEvent?.();
    this.deps.yaloMessageRepository.dispose();
  }
}
