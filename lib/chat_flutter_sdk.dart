
import 'chat_flutter_sdk_platform_interface.dart';

class ChatFlutterSdk {
  Future<String?> getPlatformVersion() {
    return ChatFlutterSdkPlatform.instance.getPlatformVersion();
  }
}
