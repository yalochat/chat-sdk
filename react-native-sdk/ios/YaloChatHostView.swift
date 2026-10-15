// Copyright (c) Yalochat, Inc. All rights reserved.
import SwiftUI
import UIKit
import YaloChatSDK

/// Renders the SwiftUI chat for the React Native component, which only speaks Objective-C.
@objc(YaloChatHostView)
public final class YaloChatHostView: UIView {
  @objc public var onBack: (() -> Void)?
  /// Hands a command to JavaScript as its request id, command and payload.
  @objc public var onCommand: ((String, String, String) -> Void)?

  private var client: YaloChatClient?
  private var commands: [String] = []
  // Commands handed to JavaScript, waiting for it to answer.
  private var pendingCommands: [String: CheckedContinuation<String, Error>] = [:]
  private var configKey: String = ""
  private var theme: ChatTheme = ChatTheme()
  private var showsBackButton: Bool = false
  private var avatar: URL?
  private let host: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

  override public init(frame: CGRect) {
    super.init(frame: frame)
    host.view.backgroundColor = .clear
    host.view.frame = bounds
    host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(host.view)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  @objc public func setConfig(_ json: String) {
    configKey = json
    client = clientConfig(of: json).map { config in YaloChatClient(config: config) }
    registerCommands()
    render()
  }

  @objc public func setCommands(_ value: [String]) {
    commands = value
    registerCommands()
  }

  /// Answers a command handed to JavaScript with what its handler returned.
  @objc public func resolveCommand(_ requestId: String, succeeded: Bool, payload: String) {
    guard let continuation = pendingCommands.removeValue(forKey: requestId) else {
      return
    }
    if succeeded {
      continuation.resume(returning: payload)
    } else {
      continuation.resume(throwing: CommandFailedError())
    }
  }

  private func registerCommands() {
    guard let client else {
      return
    }
    for command in commands {
      client.registerCommand(command) { [weak self] payload in
        guard let self else {
          throw CommandFailedError()
        }
        return try await self.runInJavaScript(command: command, payload: payload)
      }
    }
  }

  private func runInJavaScript(command: String, payload: String) async throws -> String {
    guard let onCommand else {
      throw CommandFailedError()
    }
    let requestId: String = UUID().uuidString
    return try await withCheckedThrowingContinuation { continuation in
      pendingCommands[requestId] = continuation
      onCommand(requestId, command, payload)
    }
  }

  @objc public func setTheme(_ json: String) {
    theme = chatTheme(of: json)
    render()
  }

  /// Draws the image at the URL as the avatar, or none when it is empty.
  @objc public func setAvatar(_ value: String) {
    avatar = avatarURL(of: value)
    render()
  }

  @objc public func setShowsBackButton(_ value: Bool) {
    showsBackButton = value
    render()
  }

  // The chat reads the scene phase and the keyboard through its view
  // controller, so it joins whichever one React Native placed it in.
  override public func didMoveToWindow() {
    super.didMoveToWindow()
    if window == nil {
      host.willMove(toParent: nil)
      host.removeFromParent()
      return
    }
    if let parent = parentViewController(), host.parent !== parent {
      parent.addChild(host)
      host.didMove(toParent: parent)
    }
  }

  private func parentViewController() -> UIViewController? {
    var responder: UIResponder? = next
    while let current = responder {
      if let controller = current as? UIViewController {
        return controller
      }
      responder = current.next
    }
    return nil
  }

  private func render() {
    guard let client else {
      host.rootView = AnyView(EmptyView())
      return
    }
    let onBack: (() -> Void)? = showsBackButton ? { [weak self] in self?.onBack?() } : nil
    guard let avatar else {
      host.rootView = AnyView(
        Chat(client: client, theme: theme, onBack: onBack)
          .id(configKey)
      )
      return
    }
    host.rootView = AnyView(
      Chat(client: client, theme: theme, onBack: onBack) {
        AsyncImage(url: avatar) { image in
          image.resizable().scaledToFill()
        } placeholder: {
          Color.clear
        }
        .frame(width: avatarSize, height: avatarSize)
        .clipShape(Circle())
      }
      .id(configKey)
    )
  }
}

private let avatarSize: CGFloat = 40

/// Images bundled in a release build can arrive as a path inside the app.
func avatarURL(of value: String) -> URL? {
  if value.isEmpty {
    return nil
  }
  if let url = URL(string: value), url.scheme != nil {
    return url
  }
  return Bundle.main.bundleURL.appendingPathComponent(value)
}

/// The JavaScript handler for a command threw or was missing.
struct CommandFailedError: Error {}

/// The client config React Native sent, with anything left out at its SDK default.
func clientConfig(of json: String) -> YaloChatClientConfig? {
  guard let values = object(of: json),
        let channelId = values["channelId"] as? String,
        let organizationId = values["organizationId"] as? String,
        let channelName = values["channelName"] as? String
  else {
    return nil
  }
  return YaloChatClientConfig(
    channelId: channelId,
    organizationId: organizationId,
    channelName: channelName,
    userId: values["userId"] as? String,
    quickReplyType: quickReplyType(of: values["quickReplyType"] as? String),
    welcomeMessageType: welcomeMessageType(of: values["welcomeMessageType"] as? String),
    logLevel: logLevel(of: values["logLevel"] as? String),
    openContext: values["openContext"] as? [String: String] ?? [:],
    sessionMode: sessionMode(of: values["sessionMode"] as? String),
    hideWatermark: values["hideWatermark"] as? Bool ?? false,
    hideVoiceButton: values["hideVoiceButton"] as? Bool ?? false,
    hideAttachmentButton: values["hideAttachmentButton"] as? Bool ?? false
  )
}

/// The default theme with whatever React Native set laid over it. Colors and
/// shapes the iOS SDK does not draw yet are left for when it does.
func chatTheme(of json: String) -> ChatTheme {
  var theme = ChatTheme()
  guard let values = object(of: json) else {
    return theme
  }
  let colors: [(String, WritableKeyPath<ChatTheme, Color>)] = [
    ("background", \.background),
    ("headerBackground", \.headerBackground),
    ("onHeaderBackground", \.onHeaderBackground),
    ("footerBackground", \.footerBackground),
    ("onFooterBackground", \.onFooterBackground),
    ("inputBorderColor", \.inputBorderColor),
    ("inputBackground", \.inputBackground),
    ("sendButtonBackground", \.sendButtonBackground),
    ("onSendButtonBackground", \.onSendButtonBackground),
    ("userMessageBackground", \.userMessageBackground),
    ("onUserMessageBackground", \.onUserMessageBackground),
    ("agentMessageBackground", \.agentMessageBackground),
    ("onAgentMessageBackground", \.onAgentMessageBackground),
    ("agentMessageBorderColor", \.agentMessageBorderColor),
    ("typingIndicatorDotColor", \.typingIndicatorDotColor),
    ("quickReplyBackground", \.quickReplyBackground),
    ("onQuickReplyBackground", \.onQuickReplyBackground),
    ("quickReplyBorderColor", \.quickReplyBorderColor),
  ]
  for (key, path) in colors {
    if let argb = values[key] as? NSNumber {
      theme[keyPath: path] = color(of: argb)
    }
  }
  if let padding = values["agentMessagePadding"] as? NSNumber {
    theme.agentMessagePadding = CGFloat(padding.doubleValue)
  }
  let shapes: [(String, WritableKeyPath<ChatTheme, ChatShape>)] = [
    ("inputShape", \.inputShape),
    ("quickReplyShape", \.quickReplyShape),
    ("userMessageShape", \.userMessageShape),
    ("agentMessageShape", \.agentMessageShape),
  ]
  for (key, path) in shapes {
    if let corners = values[key] as? [String: NSNumber] {
      theme[keyPath: path] = shape(of: corners)
    }
  }
  return theme
}

private func object(of json: String) -> [String: Any]? {
  guard let data = json.data(using: .utf8) else {
    return nil
  }
  return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
}

private func color(of argb: NSNumber) -> Color {
  let value = UInt32(truncatingIfNeeded: argb.int64Value)
  return Color(
    .sRGB,
    red: Double((value >> 16) & 0xFF) / 255,
    green: Double((value >> 8) & 0xFF) / 255,
    blue: Double(value & 0xFF) / 255,
    opacity: Double((value >> 24) & 0xFF) / 255
  )
}

private func shape(of corners: [String: NSNumber]) -> ChatShape {
  ChatShape(
    topLeading: CGFloat(corners["topStart"]?.doubleValue ?? 0),
    topTrailing: CGFloat(corners["topEnd"]?.doubleValue ?? 0),
    bottomTrailing: CGFloat(corners["bottomEnd"]?.doubleValue ?? 0),
    bottomLeading: CGFloat(corners["bottomStart"]?.doubleValue ?? 0)
  )
}

private func quickReplyType(of value: String?) -> QuickReplyType {
  switch value {
  case "inline":
    return .inline
  default:
    return .modal
  }
}

private func welcomeMessageType(of value: String?) -> WelcomeMessageType {
  switch value {
  case "verticalQuickReplies":
    return .verticalQuickReplies
  default:
    return .none
  }
}

private func logLevel(of value: String?) -> LogLevel {
  switch value {
  case "debug":
    return .debug
  case "info":
    return .info
  case "error":
    return .error
  case "silent":
    return .silent
  default:
    return .warn
  }
}

private func sessionMode(of value: String?) -> SessionMode {
  switch value {
  case "perContext":
    return .perContext
  case "ephemeral":
    return .ephemeral
  default:
    return .shared
  }
}
