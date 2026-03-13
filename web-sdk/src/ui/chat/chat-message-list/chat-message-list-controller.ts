// Copyright (c) Yalochat, Inc. All rights reserved.

import type { PropertyValues, ReactiveController } from 'lit';
import type ChatMessageList from './chat-message-list';

export default class ChatMessageListController implements ReactiveController {
  host: ChatMessageList;

  observer?: IntersectionObserver;

  private readonly _scrollActivityThreshold = 25;
  private _scrollHeightBeforeFetch = 0;
  private _scrollTopBeforeFetch = 0;

  constructor(host: ChatMessageList) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  hostUpdated(): void {
    if (!this.observer) {
      const intersectionOptions: IntersectionObserverInit = {
        root: this.host.messageList,
        rootMargin: '10px',
        threshold: 1.0,
      };

      this.observer = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting) {
          this._scrollHeightBeforeFetch = this.host.messageList.scrollHeight;
          this._scrollTopBeforeFetch = this.host.messageList.scrollTop;
          this.host.dispatchEvent(new Event('yalo-chat-fetch-next-page'));
        }
      }, intersectionOptions);

      this.observer.observe(this.host.loader);
    }
  }

  calculateScroll(changedProperties: PropertyValues<typeof this.host>) {
    if (!changedProperties.has('chatMessages')) return;

    const messageList = this.host.messageList;
    const isPagination = this._scrollHeightBeforeFetch > 0;

    if (isPagination) {
      const heightDelta =
        messageList.scrollHeight - this._scrollHeightBeforeFetch;
      messageList.scrollTop = this._scrollTopBeforeFetch + heightDelta;
      return;
    }

    const scrollDistance =
      messageList.scrollHeight -
      messageList.scrollTop -
      messageList.offsetHeight;
    if (scrollDistance < this._scrollActivityThreshold) {
      messageList.scrollTop = messageList.scrollHeight;
    }
  }

  highlightLinks(text: string): string {
    return text.replace(/(https?:\/\/[^\s]+)/g, '[$1]($1)');
  }

  hostDisconnected() {
    this.observer?.disconnect();
  }
}
