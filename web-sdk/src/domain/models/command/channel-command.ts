// Copyright (c) Yalochat, Inc. All rights reserved.

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

// Outcome reported back to the channel for a command request.
export type CommandResponseStatus = 'success' | 'error';
