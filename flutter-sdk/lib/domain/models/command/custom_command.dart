// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

// Handler the host registers for a custom command, keyed by the command id the
// channel sends in a CustomCommandRequest. The handler receives the request
// payload and returns the response payload the SDK sends back (filling in the
// status, timestamp and correlation id). It may be synchronous or asynchronous.
// Returning null sends an empty payload. Throwing reports the command as failed
// to the channel.
typedef CustomCommandCallback = FutureOr<String?> Function(String payload);
