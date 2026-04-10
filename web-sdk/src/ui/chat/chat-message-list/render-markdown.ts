// Copyright (c) Yalochat, Inc. All rights reserved.

import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import snarkdown from 'snarkdown';
import dompurify from 'dompurify';

function highlightLinks(text: string): string {
  return text.replace(/(?<!\]\()https?:\/\/[^\s)]+/g, '[$&]($&)');
}

export function renderMarkdown(text: string) {
  return unsafeHTML(dompurify.sanitize(snarkdown(highlightLinks(text))));
}
