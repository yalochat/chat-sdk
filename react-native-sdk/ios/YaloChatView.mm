// Copyright (c) Yalochat, Inc. All rights reserved.
#ifdef RCT_NEW_ARCH_ENABLED
#import "YaloChatView.h"

#import <react/renderer/components/YaloChatViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/YaloChatViewSpec/EventEmitters.h>
#import <react/renderer/components/YaloChatViewSpec/Props.h>
#import <react/renderer/components/YaloChatViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

#if __has_include(<YaloChatReactNativeSdk/YaloChatReactNativeSdk-Swift.h>)
#import <YaloChatReactNativeSdk/YaloChatReactNativeSdk-Swift.h>
#else
#import "YaloChatReactNativeSdk-Swift.h"
#endif

using namespace facebook::react;

@interface YaloChatView () <RCTYaloChatViewViewProtocol>
@end

@implementation YaloChatView {
  YaloChatHostView *_chat;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<YaloChatViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const YaloChatViewProps>();
    _props = defaultProps;

    _chat = [[YaloChatHostView alloc] initWithFrame:frame];
    __weak YaloChatView *weakSelf = self;
    _chat.onBack = ^{
      [weakSelf emitBack];
    };
    _chat.onCommand = ^(NSString *requestId, NSString *command, NSString *payload) {
      [weakSelf emitCommand:requestId command:command payload:payload];
    };
    self.contentView = _chat;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldChatProps = *std::static_pointer_cast<YaloChatViewProps const>(_props);
  const auto &newChatProps = *std::static_pointer_cast<YaloChatViewProps const>(props);

  if (oldChatProps.theme != newChatProps.theme) {
    [_chat setTheme:[NSString stringWithUTF8String:newChatProps.theme.c_str()]];
  }
  if (oldChatProps.showsBackButton != newChatProps.showsBackButton) {
    [_chat setShowsBackButton:newChatProps.showsBackButton];
  }
  if (oldChatProps.commands != newChatProps.commands) {
    NSMutableArray<NSString *> *commands = [NSMutableArray arrayWithCapacity:newChatProps.commands.size()];
    for (const auto &command : newChatProps.commands) {
      [commands addObject:[NSString stringWithUTF8String:command.c_str()]];
    }
    [_chat setCommands:commands];
  }
  if (oldChatProps.config != newChatProps.config) {
    [_chat setConfig:[NSString stringWithUTF8String:newChatProps.config.c_str()]];
  }

  [super updateProps:props oldProps:oldProps];
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTYaloChatViewHandleCommand(self, commandName, args);
}

- (void)resolveCommand:(NSString *)requestId succeeded:(BOOL)succeeded payload:(NSString *)payload
{
  [_chat resolveCommand:requestId succeeded:succeeded payload:payload];
}

- (void)emitCommand:(NSString *)requestId command:(NSString *)command payload:(NSString *)payload
{
  if (!_eventEmitter) {
    [_chat resolveCommand:requestId succeeded:NO payload:@""];
    return;
  }
  std::static_pointer_cast<YaloChatViewEventEmitter const>(_eventEmitter)
      ->onCommand({
          .requestId = std::string([requestId UTF8String]),
          .command = std::string([command UTF8String]),
          .payload = std::string([payload UTF8String]),
      });
}

- (void)emitBack
{
  if (_eventEmitter) {
    std::static_pointer_cast<YaloChatViewEventEmitter const>(_eventEmitter)->onBack({});
  }
}

@end

Class<RCTComponentViewProtocol> YaloChatViewCls(void)
{
  return YaloChatView.class;
}

#endif
