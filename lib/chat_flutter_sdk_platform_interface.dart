import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chat_flutter_sdk_method_channel.dart';

abstract class ChatFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a ChatFlutterSdkPlatform.
  ChatFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChatFlutterSdkPlatform _instance = MethodChannelChatFlutterSdk();

  /// The default instance of [ChatFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelChatFlutterSdk].
  static ChatFlutterSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ChatFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(ChatFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
