// Copyright (c) Yalochat, Inc. All rights reserved.
import { describe, expect, it, jest } from '@jest/globals';
import NativeYaloChat from '../NativeYaloChat';
import { YaloChatClient } from '../index';

const client = new YaloChatClient({
  channelId: 'channel',
  organizationId: 'organization',
  channelName: 'Support',
});

describe('YaloChatClient', () => {
  it('asks the native SDK to clear the messages with its config', async () => {
    await client.clearMessages();

    expect(NativeYaloChat.clearMessages).toHaveBeenCalledWith(
      JSON.stringify(client.config)
    );
  });

  it('asks the native SDK to log out with its config', async () => {
    await client.logout();

    expect(NativeYaloChat.logout).toHaveBeenCalledWith(
      JSON.stringify(client.config)
    );
  });

  it('passes on a failure from the native SDK', async () => {
    jest
      .mocked(NativeYaloChat.logout)
      .mockRejectedValueOnce(new Error('storage failed'));

    await expect(client.logout()).rejects.toThrow('storage failed');
  });
});
