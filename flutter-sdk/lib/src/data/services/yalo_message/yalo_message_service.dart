// Copyright (c) Yalochat, Inc. All rights reserved.

// Service abstraction that receives yalo messages from yalo's workflow
// interpreter adapter and sends outbound messages. Implementations differ by
// transport protocol (HTTPS polling, websocket).
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';

abstract class YaloMessageService {
  /// Streams incoming messages as they arrive from the transport.
  Stream<PollMessageItem> messages();

  /// Sends an SdkMessage through the transport.
  Future<Result<Unit>> sendSdkMessage(SdkMessage request);

  /// Pauses receiving (e.g. app backgrounded).
  void pause();

  /// Resumes receiving after a pause (e.g. app foregrounded).
  void resume();

  /// Frees transport resources.
  void dispose();
}
