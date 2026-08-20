// Copyright (c) Yalochat, Inc. All rights reserved.

import type { PropertyValues, ReactiveController } from 'lit';
import type ChatMessageList from './chat-message-list';

export default class ChatMessageListController implements ReactiveController {
  host: ChatMessageList;

  intersectionObserver?: IntersectionObserver;

  // Negative scroll threshold since the flow direction will be
  // column-reversed
  private readonly _scrollThreshold = -500.0;

  // Last scroll position set by this controller. Zero means the list was
  // pinned to the bottom, a negative value means a tall message was aligned
  // by its top edge.
  private _anchoredScrollTop = 0;

  // Whether the user was following the conversation right before the last
  // render. It is measured before the DOM changes because inserting a message
  // into a column-reversed list moves what scrollTop refers to.
  private _wasFollowing = true;

  private _resizeObserver?: ResizeObserver;

  constructor(host: ChatMessageList) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  hostUpdate(): void {
    const messageList = this.host.messageList;
    if (!messageList) {
      return;
    }

    this._wasFollowing =
      messageList.scrollTop > this._scrollThreshold ||
      messageList.scrollTop >= this._anchoredScrollTop - 1;
  }

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
      this.host.messageList.addEventListener('scroll', this._onScroll, {
        passive: true,
      });
      this.host.messageList.scrollTop = 0;
    }
  }

  calculateScroll(changedProperties: PropertyValues<typeof this.host>) {
    if (!changedProperties.has('chatMessages')) {
      return;
    }

    const previous = changedProperties.get('chatMessages');
    const newest = this.host.chatMessages[0];
    // Nothing new at the bottom: either a message was updated in place or an
    // older page was added at the top of the conversation.
    if (!newest || previous?.[0]?.id === newest.id) {
      return;
    }

    // Whatever was being tracked is no longer the newest message.
    this._stopTrackingNewest();

    if (!this._wasFollowing) {
      return;
    }

    const messageList = this.host.messageList;
    messageList.scrollTop = 0;
    this._anchoredScrollTop = 0;

    // A message the user just sent is already known to them, so the bottom is
    // the right place to be. Reopening a conversation that already has history
    // should also land at the bottom, like a chat is expected to open.
    const isReopenedConversation =
      (!previous || previous.length === 0) && this.host.chatMessages.length > 1;
    if (isReopenedConversation || newest.role === 'USER') {
      return;
    }

    const newestElement = messageList.querySelector('.chat-message');
    if (!newestElement) {
      return;
    }

    this._trackNewest(newestElement);
  }

  hostDisconnected() {
    this.intersectionObserver?.disconnect();
    this.host.messageList?.removeEventListener('scroll', this._onScroll);
    this._stopTrackingNewest();
  }

  // The message keeps growing after it is rendered: its own element renders on
  // a later update cycle, inline quick replies expand over an animation and
  // media finishes loading. Following its size keeps the top edge in place
  // through all of that.
  private _trackNewest(element: Element): void {
    this._resizeObserver = new ResizeObserver(() => {
      this._alignNewestToTop(element);
    });
    this._resizeObserver.observe(element);
  }

  private _stopTrackingNewest(): void {
    this._resizeObserver?.disconnect();
    this._resizeObserver = undefined;
  }

  // Reveals the beginning of a message that is taller than the visible area,
  // so the user does not have to scroll up to start reading it.
  private _alignNewestToTop(element: Element): void {
    const messageList = this.host.messageList;
    if (!messageList) {
      return;
    }

    // Negative when the top of the message is clipped above the visible area.
    const offset =
      element.getBoundingClientRect().top -
      messageList.getBoundingClientRect().top;
    if (offset >= 0) {
      return;
    }

    messageList.scrollTop = messageList.scrollTop + offset;
    this._anchoredScrollTop = messageList.scrollTop;
  }

  private _onScroll = (): void => {
    const messageList = this.host.messageList;
    if (!messageList) {
      return;
    }

    // Anything that does not land where this controller left the list comes
    // from the user, who is now in charge of the scroll position.
    if (Math.abs(messageList.scrollTop - this._anchoredScrollTop) > 1) {
      this._stopTrackingNewest();
    }
  };
}
