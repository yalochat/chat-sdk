// Copyright (c) Yalochat, Inc. All rights reserved.
import NativeYaloChat from './NativeYaloChat';
import type { YaloChatClientConfig } from './YaloChatClientConfig';

/**
 * Runs a command the channel asked for. It receives the request payload and
 * returns the payload sent back. Throwing (or rejecting) reports the command
 * as failed.
 */
export type CommandHandler = (
  payload: string
) => string | void | Promise<string | void>;

/** The page of the cart the channel asks for in a `getCart` request. */
export type GetCartRequest = {
  /** The page the channel wants. Left out for the first page. */
  cursor?: string;
  /** The most products the channel wants in the page. */
  pageSize?: number;
};

/** A product in the cart. */
export type CartProduct = {
  sku: string;
  name: string;
  price: number;
  imagesUrl: string[];
  /** Takes precedence over `price` when present. */
  salePrice?: number;
  /** Units contained in one unit, for example bottles inside a case. */
  subunits: number;
  unitStep: number;
  /** ICU message format, for example `{amount, plural, one {case} other {cases}}`. */
  unitName: string;
  subunitName?: string;
  subunitStep: number;
  unitsAdded: number;
  subunitsAdded: number;
};

/** Where a page sits in the cart. */
export type CartPageInfo = {
  pageSize: number;
  cursor?: string;
  /** Left out on the last page. */
  nextCursor?: string;
  /** Left out on the first page. */
  prevCursor?: string;
};

/** The page of the cart a `getCart` handler returns. */
export type GetCartResult = {
  products: CartProduct[];
  /** Leave it out when the cart is not paginated. */
  pageInfo?: CartPageInfo;
};

/** Returns the page of the cart the channel asked for. */
export type GetCartHandler = (
  request: GetCartRequest
) => GetCartResult | Promise<GetCartResult>;

/** The cart change an `updateCartProduct` request asks for. */
export type UpdateCartProductRequest = {
  sku: string;
  /** Units of the product in the cart after the change. */
  units: number;
  /** Subunits after the change. Left out when the product has no subunits. */
  subunits?: number;
};

/** Applies the cart change the channel asked for. */
export type UpdateCartProductHandler = (
  request: UpdateCartProductRequest
) => void | Promise<void>;

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
  registerCommand(command: 'getCart', handler: GetCartHandler): void;
  registerCommand(
    command: 'updateCartProduct',
    handler: UpdateCartProductHandler
  ): void;
  registerCommand(command: string, handler: CommandHandler): void;
  registerCommand(
    command: string,
    handler: CommandHandler | GetCartHandler | UpdateCartProductHandler
  ): void {
    this.commands.set(command, wrapped(command, handler));
    this.commandIds = [...this.commands.keys()];
    for (const listener of this.listeners) {
      listener();
    }
  }

  /**
   * Deletes every message stored on the device, of every conversation,
   * whether a chat is on screen or not. Every chat on screen empties and the
   * channel greets the person again, as in a new conversation.
   */
  clearMessages(): Promise<void> {
    return NativeYaloChat.clearMessages(JSON.stringify(this.config));
  }

  /**
   * Deletes every message and every session stored on the device, for
   * example when the person logs out. Every chat on screen empties, connects
   * again as a new person and the channel greets them.
   */
  logout(): Promise<void> {
    return NativeYaloChat.logout(JSON.stringify(this.config));
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

// The native SDK hands cart requests over as JSON and reads the cart back as
// JSON, so typed handlers are wrapped into string ones.
function wrapped(
  command: string,
  handler: CommandHandler | GetCartHandler | UpdateCartProductHandler
): CommandHandler {
  if (command === 'getCart') {
    const getCart = handler as GetCartHandler;
    return async (payload) =>
      JSON.stringify(await getCart(JSON.parse(payload)));
  }
  if (command === 'updateCartProduct') {
    const updateCartProduct = handler as UpdateCartProductHandler;
    return async (payload) => {
      await updateCartProduct(JSON.parse(payload));
    };
  }
  return handler as CommandHandler;
}
