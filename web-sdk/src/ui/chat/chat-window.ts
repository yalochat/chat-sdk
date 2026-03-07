// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';

import './chat-header/chat-header.ts';

@customElement('yalo-chat-window')
export class YaloChatWindow extends LitElement {
  static styles = css`
    :host {
      display: none;
      position: fixed;
      bottom: 80px;
      right: 24px;
      z-index: 9999;
      font-family: sans-serif;
    }

    :host([open]) {
      display: block;
    }

    .chat-window {
      width: 360px;
      height: 520px;
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }

    .chat-close-btn:hover {
      background: rgba(255, 255, 255, 0.15);
    }

    .chat-body {
      flex: 1;
      overflow-y: auto;
    }
  `;

  @property()
  open: boolean = false;

  @property()
  config?: YaloChatClientConfig;

  render() {
    return html`
      <div class="chat-window">
        <chat-header>
        </chat-header>
        <div class="chat-body">
          <slot></slot>
        </div>
      </div>
    `;
  }
}
