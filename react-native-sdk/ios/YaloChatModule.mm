// Copyright (c) Yalochat, Inc. All rights reserved.
#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <YaloChatViewSpec/YaloChatViewSpec.h>
#endif

#if __has_include(<YaloChatReactNativeSdk/YaloChatReactNativeSdk-Swift.h>)
#import <YaloChatReactNativeSdk/YaloChatReactNativeSdk-Swift.h>
#else
#import "YaloChatReactNativeSdk-Swift.h"
#endif

static NSString *const YaloChatInvalidConfig = @"invalid_config";

static void settle(BOOL done, RCTPromiseResolveBlock resolve, RCTPromiseRejectBlock reject)
{
  if (done) {
    resolve(nil);
  } else {
    reject(YaloChatInvalidConfig, @"The client config could not be read", nil);
  }
}

#ifdef RCT_NEW_ARCH_ENABLED
@interface YaloChatModule : NSObject <NativeYaloChatSpec>
#else
@interface YaloChatModule : NSObject <RCTBridgeModule>
#endif
@end

@implementation YaloChatModule

RCT_EXPORT_MODULE(YaloChat)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_METHOD(clearMessages:(NSString *)config resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  [YaloChatStorage clearMessages:config completion:^(BOOL done) {
    settle(done, resolve, reject);
  }];
}

RCT_EXPORT_METHOD(logout:(NSString *)config resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  [YaloChatStorage logout:config completion:^(BOOL done) {
    settle(done, resolve, reject);
  }];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeYaloChatSpecJSI>(params);
}
#endif

@end
