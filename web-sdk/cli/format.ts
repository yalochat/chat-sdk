// Copyright (c) Yalochat, Inc. All rights reserved.

import {
  SdkMessage,
  type PollMessageItem,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

// NDJSON line for --json: the raw protojson SdkMessage plus the poll envelope,
// so evals can assert on the exact payload the widget would have rendered.
export function toJsonLine(item: PollMessageItem): string {
  return JSON.stringify({
    id: item.id,
    date: item.date?.toISOString(),
    message: item.message ? SdkMessage.toJSON(item.message) : null,
  });
}

// One human-readable line per message for the default output. Unknown payload
// kinds still print their oneof name, so a new widget never shows up blank.
export function toPrettyLine(item: PollMessageItem): string {
  const json = item.message
    ? (SdkMessage.toJSON(item.message) as Record<string, unknown>)
    : {};
  const kind = Object.keys(json).find(
    (key) => key !== 'correlationId' && key !== 'timestamp'
  );
  if (!kind) return '← (empty)';

  const payload = json[kind] as Record<string, unknown>;
  return `← [${kind}] ${summarize(payload)}`.trimEnd();
}

function summarize(payload: Record<string, unknown>): string {
  const content = payload.content as Record<string, unknown> | undefined;
  const parts: string[] = [];

  const text = content?.text ?? payload.body ?? payload.header;
  if (typeof text === 'string') parts.push(text);

  const buttons = payload.buttons as { text?: string }[] | undefined;
  if (buttons?.length) {
    parts.push(`[${buttons.map((b) => b.text).join(' | ')}]`);
  }

  const products = payload.products as { name?: string }[] | undefined;
  if (products?.length) {
    parts.push(
      `${products.length} products: ${products.map((p) => p.name).join(', ')}`
    );
  }

  if (typeof content?.mediaUrl === 'string') parts.push(content.mediaUrl);
  if (typeof payload.commandId === 'string')
    parts.push(`command=${payload.commandId}`);

  return parts.join(' ');
}
