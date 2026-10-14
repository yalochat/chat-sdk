// Copyright (c) Yalochat, Inc. All rights reserved.
import type { YaloChatClientConfig } from './YaloChatClientConfig';

/**
 * Runs a command the channel asked for. It receives the request payload and
 * returns the payload sent back. Throwing (or rejecting) reports the command
 * as failed.
 */
export type CommandHandler = (
  payload: string
) => string | void | Promise<string | void>;

/** The way into the SDK. Creating one costs nothing until a `Chat` shows it. */
export class YaloChatClient {
  readonly config: YaloChatClientConfig;
  private readonly commands = new Map<string, CommandHandler>();
  private commandIds: string[] = [];
  private readonly listeners = new Set<() => void>();

  constructor(config: YaloChatClientConfig) {
    this.config = config;
  }

  /**
   * Runs `handler` whenever the channel asks for `command` while a chat is
   * open. Registering the same command again replaces its handler.
   */
  registerCommand(command: string, handler: CommandHandler): void {
    this.commands.set(command, handler);
    this.commandIds = [...this.commands.keys()];
    for (const listener of this.listeners) {
      listener();
    }
  }

  /** @internal */
  commandHandler(command: string): CommandHandler | undefined {
    return this.commands.get(command);
  }

  /** @internal */
  registeredCommands = (): string[] => this.commandIds;

  /** @internal */
  subscribeToCommands = (listener: () => void): (() => void) => {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  };
}
