import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chat_flutter_sdk_platform_interface.dart';

/// An implementation of [ChatFlutterSdkPlatform] that uses method channels.
class MethodChannelChatFlutterSdk extends ChatFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('chat_flutter_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
