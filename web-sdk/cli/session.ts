// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { PollMessageItem } from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import { chatMessageToSdkMessage } from '@data/repositories/yalo-message/sdk-message-mapper';
import { YaloMessageAuthServiceRemote } from '@data/services/yalo-message/yalo-message-auth-service-remote';
import { YaloMessageServiceHttps } from '@data/services/yalo-message/yalo-message-service-https';
import { HOSTS, type Env } from './config';
import { TokenRepositoryMemory } from './token-repository-memory';

export interface WebchatSessionOptions {
  env: Env;
  channelId: string;
  organizationId: string;
  userId?: string;
}

// One anonymous (or third-party) visitor talking to one channel over the same
// HTTPS polling transport the widget falls back to. Everything below is the
// widget's own code; the CLI only swaps IndexedDB for memory.
export class WebchatSession {
  private readonly _service: YaloMessageServiceHttps;
  private readonly _tokens: TokenRepositoryMemory;

  constructor(options: WebchatSessionOptions) {
    const config: YaloChatClientConfig = {
      channelId: options.channelId,
      organizationId: options.organizationId,
      userId: options.userId,
      channelName: 'cli',
      target: 'cli',
    };
    const host = HOSTS[options.env];
    this._tokens = new TokenRepositoryMemory(
      new YaloMessageAuthServiceRemote(host, config)
    );
    this._service = new YaloMessageServiceHttps(host, config, this._tokens);
  }

  // Authenticates eagerly so a bad channel/org fails before anything is sent.
  async connect(): Promise<Result<string>> {
    return this._tokens.getToken();
  }

  sendText(text: string): Promise<Result<void>> {
    const message = ChatMessage.text({
      role: 'USER',
      status: 'IN_PROGRESS',
      timestamp: new Date(),
      content: text,
      id: Date.now(),
    });
    return this._service.sendMessage(chatMessageToSdkMessage(message));
  }

  // Mirrors YaloMessageRepositoryRemote.requestGuidanceCard: how the widget
  // opens a conversation carrying `openContext`.
  requestGuidanceCard(
    context?: string,
    targetId?: string
  ): Promise<Result<void>> {
    const timestamp = new Date();
    return this._service.sendMessage({
      correlationId: `guidance-card-${Date.now()}`,
      guidanceCardRequest: { timestamp, targetId, context },
      timestamp,
    });
  }

  subscribe(onMessage: (item: PollMessageItem) => void): void {
    this._service.subscribe((event) => {
      if ('message' in event) onMessage(event);
    });
  }

  close(): void {
    this._service.unsubscribe();
  }
}
