// Copyright (c) Yalochat, Inc. All rights reserved.
import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import { act, fireEvent, render, screen } from '@testing-library/react-native';
import { Chat, YaloChatClient } from '../index';
import { Commands } from '../YaloChatViewNativeComponent';

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

describe('Chat commands', () => {
  const resolveCommand = jest.spyOn(Commands, 'resolveCommand');

  beforeEach(() => {
    resolveCommand.mockReset();
  });

  function commandClient(): YaloChatClient {
    return new YaloChatClient({
      channelId: 'channel',
      organizationId: 'organization',
      channelName: 'Support',
    });
  }

  async function askForCommand(command: string, payload = '') {
    const chat = screen.getByTestId('chat');
    await fireEvent(chat, 'command', {
      nativeEvent: { requestId: 'r-1', command, payload },
    });
  }

  it('tells the native chat which commands are registered', async () => {
    const commands = commandClient();
    commands.registerCommand('getStore', () => 'store');
    await render(<Chat client={commands} testID="chat" />);

    expect(screen.getByTestId('chat').props.commands).toEqual(['getStore']);
  });

  it('tells the native chat about a command registered after it is shown', async () => {
    const commands = commandClient();
    await render(<Chat client={commands} testID="chat" />);

    await act(() => commands.registerCommand('getStore', () => 'store'));

    expect(screen.getByTestId('chat').props.commands).toEqual(['getStore']);
  });

  it('answers with what the handler returned', async () => {
    const commands = commandClient();
    commands.registerCommand('getStore', async (payload) => `store ${payload}`);
    await render(<Chat client={commands} testID="chat" />);

    await askForCommand('getStore', '42');

    expect(resolveCommand).toHaveBeenCalledWith(
      expect.anything(),
      'r-1',
      true,
      'store 42'
    );
  });

  it('answers with an empty payload when the handler returns nothing', async () => {
    const commands = commandClient();
    commands.registerCommand('track', () => {});
    await render(<Chat client={commands} testID="chat" />);

    await askForCommand('track');

    expect(resolveCommand).toHaveBeenCalledWith(
      expect.anything(),
      'r-1',
      true,
      ''
    );
  });

  it('reports a command whose handler throws as failed', async () => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
    const commands = commandClient();
    commands.registerCommand('getStore', () => {
      throw new Error('closed');
    });
    await render(<Chat client={commands} testID="chat" />);

    await askForCommand('getStore');

    expect(resolveCommand).toHaveBeenCalledWith(
      expect.anything(),
      'r-1',
      false,
      ''
    );
  });

  it('reports a command nobody registered as failed', async () => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
    await render(<Chat client={commandClient()} testID="chat" />);

    await askForCommand('getStore');

    expect(resolveCommand).toHaveBeenCalledWith(
      expect.anything(),
      'r-1',
      false,
      ''
    );
  });
});

describe('Chat cart commands', () => {
  const resolveCommand = jest.spyOn(Commands, 'resolveCommand');

  beforeEach(() => {
    resolveCommand.mockReset();
  });

  async function askForCommand(command: string, payload: string) {
    await fireEvent(screen.getByTestId('chat'), 'command', {
      nativeEvent: { requestId: 'r-1', command, payload },
    });
  }

  it('hands getCart the request and answers with the cart as JSON', async () => {
    const cart = new YaloChatClient(client.config);
    const getCart = jest.fn(async () => ({
      products: [],
      pageInfo: { pageSize: 20, nextCursor: 'page-2' },
    }));
    cart.registerCommand('getCart', getCart);
    await render(<Chat client={cart} testID="chat" />);

    await askForCommand('getCart', '{"cursor":"page-1","pageSize":20}');

    expect(getCart).toHaveBeenCalledWith({ cursor: 'page-1', pageSize: 20 });
    const answer = resolveCommand.mock.calls[0]?.[3] as string;
    expect(JSON.parse(answer)).toEqual({
      products: [],
      pageInfo: { pageSize: 20, nextCursor: 'page-2' },
    });
  });

  it('hands updateCartProduct the change and answers with an empty payload', async () => {
    const cart = new YaloChatClient(client.config);
    const updateCartProduct = jest.fn(() => {});
    cart.registerCommand('updateCartProduct', updateCartProduct);
    await render(<Chat client={cart} testID="chat" />);

    await askForCommand('updateCartProduct', '{"sku":"WATER-1L","units":2}');

    expect(updateCartProduct).toHaveBeenCalledWith({
      sku: 'WATER-1L',
      units: 2,
    });
    expect(resolveCommand).toHaveBeenCalledWith(
      expect.anything(),
      'r-1',
      true,
      ''
    );
  });
});
