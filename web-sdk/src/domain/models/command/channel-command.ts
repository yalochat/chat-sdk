// Copyright (c) Yalochat, Inc. All rights reserved.

import type {
  GetCartRequest,
  PageInfo,
  Product,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

// Command id the channel sends in a CustomCommandRequest. Any string is
// accepted; the listed ids are surfaced as editor autocomplete hints. The
// `string & {}` intersection keeps the literal members from collapsing into
// `string` (which would drop the hints).
export type CustomCommandId = 'getCart' | (string & {});

// Handler the host registers for a custom command, keyed by the command id the
// channel sends in a CustomCommandRequest. The handler receives the request
// payload and returns the response payload the SDK sends back (filling in the
// status, timestamp and correlation id). Throwing (or rejecting) reports the
// command as failed to the channel.
export type CustomCommandHandler = (
  payload: string
) => string | void | Promise<string | void>;

// Products the host returns for a `getCart` request, plus optional pagination
// metadata for the page. The SDK wraps this into the GetCartResponse it sends
// back to the channel, filling in the status, timestamp and correlation id.
export interface GetCartResult {
  products: Product[];
  pageInfo?: PageInfo;
}

// Handler the host registers for the typed `getCart` request the channel sends
// as a GetCartRequest. It receives the request (cursor and page size) and
// returns the page of cart products. Throwing (or rejecting) reports the
// request as failed to the channel.
export type GetCartHandler = (
  request: GetCartRequest
) => GetCartResult | Promise<GetCartResult>;

// A registered channel-to-client handler: either a string custom command or
// the typed `getCart` handler.
export type ChannelCommandHandler = CustomCommandHandler | GetCartHandler;

// Map of channel command ids to their handlers. `getCart` is typed as the
// GetCartHandler; every other id is a string CustomCommandHandler.
export interface ChannelCommandHandlerMap {
  getCart?: GetCartHandler;
  [commandId: string]: ChannelCommandHandler | undefined;
}

// Outcome reported back to the channel for a command request.
export type CommandResponseStatus = 'success' | 'error';
