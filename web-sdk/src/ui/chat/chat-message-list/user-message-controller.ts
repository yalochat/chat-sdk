// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { UserMessage } from './user-message';

export default class UserMessageController implements ReactiveController {
  host: UserMessage;

  constructor(host: UserMessage) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  get isError(): boolean {
    return this.host.message.status === 'ERROR';
  }

  retryMessage() {
    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-retry-message', {
        detail: this.host.message,
        bubbles: true,
        composed: true,
      })
    );
  }
}
