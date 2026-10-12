// Copyright (c) Yalochat, Inc. All rights reserved.
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
  if (oldChatProps.config != newChatProps.config) {
    [_chat setConfig:[NSString stringWithUTF8String:newChatProps.config.c_str()]];
  }

  [super updateProps:props oldProps:oldProps];
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
