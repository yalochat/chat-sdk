// Copyright (c) Yalochat, Inc. All rights reserved.

// Client -> Channel commands
enum ChatCommand {
  addToCart,
  removeFromCart,
  clearCart,
  guidanceCard,
  addPromotion,
}

typedef ChatCommandCallback = void Function(dynamic payload);
