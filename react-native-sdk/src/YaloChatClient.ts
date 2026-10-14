// Copyright (c) Yalochat, Inc. All rights reserved.
import type { YaloChatClientConfig } from './YaloChatClientConfig';

/** The way into the SDK. Creating one costs nothing until a `Chat` shows it. */
export class YaloChatClient {
  readonly config: YaloChatClientConfig;

  constructor(config: YaloChatClientConfig) {
    this.config = config;
  }
}
