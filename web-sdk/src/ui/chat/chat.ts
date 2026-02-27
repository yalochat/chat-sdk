// Copyright (c) Yalochat, Inc. All rights reserved.

import { css, html, LitElement } from "lit";


export class Chat extends LitElement {

  static style = css`
  .chat-modal {
      background-color: #fff;
  }
  `;


  render() {
    return html`
    <section class="chat-modal">
      test
    </section>
    `;

  }
}
