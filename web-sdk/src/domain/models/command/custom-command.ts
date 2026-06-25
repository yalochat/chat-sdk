// Copyright (c) Yalochat, Inc. All rights reserved.

// Channel -> Client custom commands.
//
// The channel can ask the client to run a named command by sending a custom
// command request. The host registers a handler per command id. The handler
// receives the request payload and returns the response payload. Throwing (or
// rejecting) reports the command as failed back to the channel.
export type CustomCommandHandler = (
  payload: string
) => string | void | Promise<string | void>;

// Outcome reported back to the channel for a custom command request.
export type CustomCommandStatus = 'success' | 'error';

// A custom command request received from the channel.
export interface CustomCommandInvocation {
  commandId: string;
  payload: string;
  // Echoed back on the response so the channel can correlate it.
  correlationId: string;
}
