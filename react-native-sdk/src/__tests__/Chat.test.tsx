// Copyright (c) Yalochat, Inc. All rights reserved.
import { describe, expect, it, jest } from '@jest/globals';
import { fireEvent, render, screen } from '@testing-library/react-native';
import { Chat, YaloChatClient } from '../index';

const client = new YaloChatClient({
  channelId: 'channel',
  organizationId: 'organization',
  channelName: 'Support',
  sessionMode: 'perContext',
  openContext: { sku: '123' },
});

describe('Chat', () => {
  it('hands the client config to the native chat', async () => {
    await render(<Chat client={client} testID="chat" />);

    const chat = screen.getByTestId('chat');
    expect(JSON.parse(chat.props.config)).toEqual(client.config);
  });

  it('hands the theme to the native chat', async () => {
    await render(
      <Chat client={client} theme={{ inputShape: 8 }} testID="chat" />
    );

    const chat = screen.getByTestId('chat');
    expect(JSON.parse(chat.props.theme)).toMatchObject({
      inputShape: { topStart: 8 },
    });
  });

  it('hides the back button when there is no onBack', async () => {
    await render(<Chat client={client} testID="chat" />);

    const chat = screen.getByTestId('chat');
    expect(chat.props.showsBackButton).toBe(false);
    await fireEvent(chat, 'back');
  });

  it('calls onBack when the back button is pressed', async () => {
    const onBack = jest.fn();
    await render(<Chat client={client} onBack={onBack} testID="chat" />);

    const chat = screen.getByTestId('chat');
    expect(chat.props.showsBackButton).toBe(true);
    await fireEvent(chat, 'back');
    expect(onBack).toHaveBeenCalledTimes(1);
  });
});
