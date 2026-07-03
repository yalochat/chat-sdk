// Copyright (c) Yalochat, Inc. All rights reserved.

// Ids of the client -> channel commands the chat can trigger. Registering a
// callback for one of these ids runs it instead of the built-in remote call.
// These ids are reserved: any other id registered through registerCommand
// handles the matching channel -> client custom command request.
abstract final class ChatCommand {
  static const String updateCartProduct = 'updateCartProduct';
  static const String clearCart = 'clearCart';
  static const String goToCart = 'goToCart';
}

typedef ChatCommandCallback = void Function(dynamic payload);
