// Copyright (c) Yalochat, Inc. All rights reserved.

import type { PropertyValues, ReactiveController } from 'lit';
import type ChatMessageList from './chat-message-list';

export default class ChatMessageListController implements ReactiveController {
  host: ChatMessageList;

  intersectionObserver?: IntersectionObserver;

  // Negative scroll threshold since the flow direction will be
  // column-reversed
  private readonly _scrollThreshold = -500.0;

  constructor(host: ChatMessageList) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  hostUpdated(): void {
    if (!this.intersectionObserver) {
      const intersectionOptions: IntersectionObserverInit = {
        root: this.host.messageList,
        rootMargin: '10px',
        threshold: 1.0,
      };

      this.intersectionObserver = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting) {
          this.host.dispatchEvent(new Event('yalo-chat-fetch-next-page'));
        }
      }, intersectionOptions);

      this.intersectionObserver.observe(this.host.loader);
      this.host.messageList.scrollTop = 0;
    }
  }

  calculateScroll(changedProperties: PropertyValues<typeof this.host>) {
    if (!changedProperties.has('chatMessages')) return;

    const messageList = this.host.messageList;

    if (messageList.scrollTop > this._scrollThreshold) {
      messageList.scrollTop = 0;
      return;
    }
  }

  highlightLinks(text: string): string {
    return text.replace(/(?<!\]\()https?:\/\/[^\s)]+/g, '[$&]($&)');
  }

  hostDisconnected() {
    this.intersectionObserver?.disconnect();
  }
}
