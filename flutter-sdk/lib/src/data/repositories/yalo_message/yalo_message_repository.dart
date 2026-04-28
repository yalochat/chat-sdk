// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';

// Yalo message repository load messages from yalo's workflow interpreter
// adapter and translate it to ChatMessage domain model
abstract class YaloMessageRepository {
  // Streams chat messages from yalo's adapter
  Stream<ChatMessage> messages();

  // Stream chat
  Stream<ChatEvent> events();

  // Sends message to yalo's workflow interpreter adapter
  Future<Result<Unit>> sendMessage(ChatMessage chatMessage);

  // Adds a product to the active cart.
  Future<Result<Unit>> addToCart(String sku, double quantity);

  // Removes a product from the active cart.
  // If [quantity] is null, the entire SKU line is removed.
  Future<Result<Unit>> removeFromCart(String sku, {double? quantity});

  // Empties the active cart entirely.
  Future<Result<Unit>> clearCart();

  // Applies a promotion to the active cart.
  Future<Result<Unit>> addPromotion(String promotionId);

  // Pauses polling (e.g. app backgrounded)
  void pause();

  // Resumes polling after a pause (e.g. app foregrounded)
  void resume();

  // Method to free resources
  void dispose();
}
