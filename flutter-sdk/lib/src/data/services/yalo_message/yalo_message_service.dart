// Copyright (c) Yalochat, Inc. All rights reserved.

// Service class that will be in charge of fetching yalo messages
// from yalo's workflow interpreter adapter
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';

abstract class YaloMessageService {
  /// Sends a text message using the provided YaloTextMessageRequest.
  Future<Result<Unit>> sendSdkMessage(SdkMessage request);

  /// Fetches messages since the given "since" timestamp.
  Future<Result<List<PollMessageItem>>> fetchMessages(int since);

  /// Adds a product to the active cart.
  Future<Result<Unit>> addToCart(String sku, double quantity);

  /// Removes a product from the active cart.
  /// If [quantity] is null, the entire SKU line is removed.
  Future<Result<Unit>> removeFromCart(String sku, {double? quantity});

  /// Empties the active cart entirely.
  Future<Result<Unit>> clearCart();

  /// Applies a promotion to the active cart.
  Future<Result<Unit>> addPromotion(String promotionId);
}
