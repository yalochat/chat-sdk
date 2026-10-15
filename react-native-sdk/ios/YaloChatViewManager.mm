// Copyright (c) Yalochat, Inc. All rights reserved.
#ifndef RCT_NEW_ARCH_ENABLED
#import <React/RCTComponent.h>
#import <React/RCTUIManager.h>
#import <React/RCTViewManager.h>

#if __has_include(<YaloChatReactNativeSdk/YaloChatReactNativeSdk-Swift.h>)
#import <YaloChatReactNativeSdk/YaloChatReactNativeSdk-Swift.h>
#else
#import "YaloChatReactNativeSdk-Swift.h"
#endif

/// The chat on the old architecture, where props and events reach a plain view.
@interface YaloChatLegacyView : UIView

@property (nonatomic, copy) RCTDirectEventBlock onBack;
@property (nonatomic, copy) RCTDirectEventBlock onCommand;

@end

@implementation YaloChatLegacyView {
  YaloChatHostView *_chat;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _chat = [[YaloChatHostView alloc] initWithFrame:self.bounds];
    _chat.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak YaloChatLegacyView *weakSelf = self;
    _chat.onBack = ^{
      [weakSelf emitBack];
    };
    _chat.onCommand = ^(NSString *requestId, NSString *command, NSString *payload) {
      [weakSelf emitCommand:requestId command:command payload:payload];
    };
    [self addSubview:_chat];
  }
  return self;
}

- (void)setConfig:(NSString *)config
{
  [_chat setConfig:config ?: @""];
}

- (void)setTheme:(NSString *)theme
{
  [_chat setTheme:theme ?: @""];
}

- (void)setAvatar:(NSString *)avatar
{
  [_chat setAvatar:avatar ?: @""];
}

- (void)setShowsBackButton:(BOOL)showsBackButton
{
  [_chat setShowsBackButton:showsBackButton];
}

- (void)setCommands:(NSArray<NSString *> *)commands
{
  [_chat setCommands:commands ?: @[]];
}

- (void)resolveCommand:(NSString *)requestId succeeded:(BOOL)succeeded payload:(NSString *)payload
{
  [_chat resolveCommand:requestId succeeded:succeeded payload:payload];
}

- (void)emitCommand:(NSString *)requestId command:(NSString *)command payload:(NSString *)payload
{
  if (!_onCommand) {
    [_chat resolveCommand:requestId succeeded:NO payload:@""];
    return;
  }
  _onCommand(@{@"requestId" : requestId, @"command" : command, @"payload" : payload});
}

- (void)emitBack
{
  if (_onBack) {
    _onBack(@{});
  }
}

@end

@interface YaloChatViewManager : RCTViewManager
@end

@implementation YaloChatViewManager

RCT_EXPORT_MODULE(YaloChatView)

- (UIView *)view
{
  return [[YaloChatLegacyView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(config, NSString)
RCT_EXPORT_VIEW_PROPERTY(theme, NSString)
RCT_EXPORT_VIEW_PROPERTY(avatar, NSString)
RCT_EXPORT_VIEW_PROPERTY(showsBackButton, BOOL)
RCT_EXPORT_VIEW_PROPERTY(commands, NSArray)
RCT_EXPORT_VIEW_PROPERTY(onBack, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCommand, RCTDirectEventBlock)

RCT_EXPORT_METHOD(resolveCommand
                  : (nonnull NSNumber *)reactTag requestId
                  : (NSString *)requestId succeeded
                  : (BOOL)succeeded payload
                  : (NSString *)payload)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    UIView *view = viewRegistry[reactTag];
    if ([view isKindOfClass:[YaloChatLegacyView class]]) {
      [(YaloChatLegacyView *)view resolveCommand:requestId succeeded:succeeded payload:payload];
    }
  }];
}

@end

#endif
