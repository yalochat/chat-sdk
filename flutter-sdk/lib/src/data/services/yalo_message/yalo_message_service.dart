// Copyright (c) Yalochat, Inc. All rights reserved.

// Service class that will be in charge of fetching yalo messages
// from yalo's workflow interpreter adapter
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_fetch_messages_response.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message_request.dart';

abstract class YaloMessageService {
  /// Sends a text message using the provided YaloTextMessageRequest.
  Future<Result<Unit>> sendTextMessage(YaloTextMessageRequest request);

  /// Fetches messages since the given "since" timestamp.
  Future<Result<List<YaloFetchMessagesResponse>>> fetchMessages(int since);
}
