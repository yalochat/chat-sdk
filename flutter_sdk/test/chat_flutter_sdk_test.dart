import 'package:flutter_test/flutter_test.dart';
import 'package:chat_flutter_sdk/chat_flutter_sdk.dart';
import 'package:chat_flutter_sdk/chat_flutter_sdk_platform_interface.dart';
import 'package:chat_flutter_sdk/chat_flutter_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChatFlutterSdkPlatform
    with MockPlatformInterfaceMixin
    implements ChatFlutterSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ChatFlutterSdkPlatform initialPlatform = ChatFlutterSdkPlatform.instance;

  test('$MethodChannelChatFlutterSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChatFlutterSdk>());
  });

  test('getPlatformVersion', () async {
    ChatFlutterSdk chatFlutterSdkPlugin = ChatFlutterSdk();
    MockChatFlutterSdkPlatform fakePlatform = MockChatFlutterSdkPlatform();
    ChatFlutterSdkPlatform.instance = fakePlatform;

    expect(await chatFlutterSdkPlugin.getPlatformVersion(), '42');
  });
}
