// Copyright (c) Yalochat, Inc. All rights reserved.

import { createLogger } from '../../../log/logger';
import type { IYaloChatClient } from "./yalo-chat-client.interface";


export interface YaloChatClientConfig {
  channelId: string;
  organizationId: string;
};

export default class YaloChatClient implements IYaloChatClient {

  private readonly logger = createLogger('YaloChatClient');
  private config: YaloChatClientConfig;

  constructor(config: YaloChatClientConfig) {
    this.config = config;
    this.logger.debug('Initialized with config', this.config);
  }

  init(): void {
    throw new Error("Method not implemented.");
  }

  open(): void {
    throw new Error("Method not implemented.");
  }

  close(): void {
    throw new Error("Method not implemented.");
  }


}
