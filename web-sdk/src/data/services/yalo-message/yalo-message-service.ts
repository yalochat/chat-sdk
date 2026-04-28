// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';
import type {
  PollMessageItem,
  SdkMessage,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

export type MessageCallback = (item: PollMessageItem) => void;

export interface YaloMessageService {
  sendMessage(message: SdkMessage): Promise<Result<void>>;
  subscribe(callback: MessageCallback): void;
  unsubscribe(): void;
}
