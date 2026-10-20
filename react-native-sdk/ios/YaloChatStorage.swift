// Copyright (c) Yalochat, Inc. All rights reserved.
import Foundation
import YaloChatSDK

/// What the JavaScript client asks of the SDK outside of a chat on screen.
@objc(YaloChatStorage)
public final class YaloChatStorage: NSObject {
  /// Calls `completion` with false when `config` cannot be read.
  @objc public static func clearMessages(_ config: String, completion: @escaping @Sendable (Bool) -> Void) {
    run(config, completion) { client in
      await client.clearMessages()
    }
  }

  /// Calls `completion` with false when `config` cannot be read.
  @objc public static func logout(_ config: String, completion: @escaping @Sendable (Bool) -> Void) {
    run(config, completion) { client in
      await client.logout()
    }
  }

  private static func run(
    _ json: String,
    _ completion: @escaping @Sendable (Bool) -> Void,
    _ action: @escaping @Sendable (YaloChatClient) async -> Void
  ) {
    guard let config = clientConfig(of: json) else {
      completion(false)
      return
    }
    let client: YaloChatClient = YaloChatClient(config: config)
    Task {
      await action(client)
      completion(true)
    }
  }
}
