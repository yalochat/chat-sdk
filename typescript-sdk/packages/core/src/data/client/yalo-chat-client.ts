// Copyright (c) Yalochat, Inc. All rights reserved.

import { err, ok, type Result } from '../../common/result.js';
import type {
  YaloFetchMessagesResponse,
  YaloTextMessageRequest,
} from '../../domain/yalo-message.js';

export interface Action {
  name: string;
  action: () => void;
}

export interface YaloChatClientConfig {
  name: string;
  flowKey: string;
  userToken: string;
  authToken: string;
  chatBaseUrl: string;
}

export class YaloChatClient {
  readonly name: string;
  readonly flowKey: string;
  readonly userToken: string;
  readonly authToken: string;
  readonly chatBaseUrl: string;
  readonly actions: Action[] = [];

  constructor(config: YaloChatClientConfig) {
    this.name = config.name;
    this.flowKey = config.flowKey;
    this.userToken = config.userToken;
    this.authToken = config.authToken;
    this.chatBaseUrl = config.chatBaseUrl;
  }

  registerAction(name: string, action: () => void): void {
    this.actions.push({ name, action });
  }

  /** Sends a text message to the upstream chat service. */
  async sendTextMessage(request: YaloTextMessageRequest): Promise<Result<void>> {
    try {
      const response = await fetch(`${this.chatBaseUrl}/inbound_messages`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-user-id': this.userToken,
          'x-channel-id': this.flowKey,
          authorization: `Bearer ${this.authToken}`,
        },
        body: JSON.stringify(request),
      });

      if (response.ok) {
        return ok(undefined);
      }
      return err(new Error(`Failed to send message: ${response.status}`));
    } catch (e) {
      return err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  /**
   * Fetches messages from the chat service.
   * @param since Unix timestamp in seconds — returns messages since this time
   */
  async fetchMessages(since: number): Promise<Result<YaloFetchMessagesResponse[]>> {
    try {
      const url = new URL(`${this.chatBaseUrl}/messages`);
      url.searchParams.set('since', String(since));

      const response = await fetch(url.toString(), {
        headers: {
          'x-user-id': this.userToken,
          'x-channel-id': this.flowKey,
          authorization: `Bearer ${this.authToken}`,
        },
      });

      if (response.ok) {
        const data = (await response.json()) as YaloFetchMessagesResponse[];
        return ok(data);
      }
      return err(new Error(`Error fetching messages: ${response.status}`));
    } catch (e) {
      return err(e instanceof Error ? e : new Error(String(e)));
    }
  }
}
