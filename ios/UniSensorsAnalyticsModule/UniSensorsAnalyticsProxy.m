//
// UniSensorsAnalyticsProxy.m
// UniSensorsAnalyticsModule
//
// Created by 彭远洋 on 2021/1/12.
// Copyright © 2021 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "UniSensorsAnalyticsProxy.h"
#if __has_include(<SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>)
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#else
#import "SensorsAnalyticsSDK.h"
#endif

static NSString *kSAPluginName = @"Sensorsdata-UniPlugin-App";
static NSString *kSAServerUrlKey = @"serverUrl";
static NSString *kSAAutoTrackEventTypeKey = @"autoTrackEventType";
static NSString *kSAMaxCacheSizeKey = @"maxCacheSize";
static NSString *kSAEnableLogKey = @"enableLog";
static NSString *kSAEnableEncryptKey = @"enableEncrypt";
static NSString *kSAEnableJavaScriptBridgeKey = @"enableJavaScriptBridge";

@implementation UniSensorsAnalyticsProxy

#pragma mark - proxy method
- (nullable NSString *)objectForInfoDictionaryKey:(NSString *)key {
    if (!key.length) {
        return nil;
    }
    NSDictionary *analytics = [[NSBundle mainBundle] objectForInfoDictionaryKey:kSAPluginName];
    return analytics[key];
}

- (void)startWithLaunchOptions:(NSDictionary *)launchOptions {
    NSString *serverUrl = [self objectForInfoDictionaryKey:kSAServerUrlKey];
    NSInteger autoTrackEventType = [[self objectForInfoDictionaryKey:kSAAutoTrackEventTypeKey] integerValue];
    NSInteger maxCacheSize = [[self objectForInfoDictionaryKey:kSAMaxCacheSizeKey] integerValue];
    BOOL enableLog = [[self objectForInfoDictionaryKey:kSAEnableLogKey] isEqualToString:@"true"];
    BOOL enableEncrypt = [[self objectForInfoDictionaryKey:kSAEnableEncryptKey] isEqualToString:@"true"];
    BOOL enableJavaScriptBridge = [[self objectForInfoDictionaryKey:kSAEnableJavaScriptBridgeKey] isEqualToString:@"true"];
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:serverUrl launchOptions:launchOptions];
    options.autoTrackEventType = autoTrackEventType;
    options.maxCacheSize = maxCacheSize;
    options.enableLog = enableLog;
    options.enableEncrypt = enableEncrypt;
    options.enableJavaScriptBridge = enableJavaScriptBridge;
    [SensorsAnalyticsSDK startWithConfigOptions:options];
}

#pragma mark - uni-app plugin lifeCycle
-(void)onCreateUniPlugin {
    NSLog(@"[uni-app SensorsAnalyticsModule] initialize sucess !!!");
}

- (BOOL)application:(UIApplication *_Nullable)application didFinishLaunchingWithOptions:(NSDictionary *_Nullable)launchOptions {
    [self startWithLaunchOptions:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *_Nullable)application handleOpenURL:(NSURL *_Nullable)url {
    return [[SensorsAnalyticsSDK sharedInstance] handleSchemeUrl:url];
}

- (BOOL)application:(UIApplication *_Nullable)application openURL:(NSURL *_Nullable)url sourceApplication:(NSString *_Nullable)sourceApplication annotation:(id _Nonnull )annotation {
    return [[SensorsAnalyticsSDK sharedInstance] handleSchemeUrl:url];
}

- (BOOL)application:(UIApplication *_Nullable)app openURL:(NSURL *_Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *_Nullable)options {
    return [[SensorsAnalyticsSDK sharedInstance] handleSchemeUrl:url];
}

- (BOOL)application:(UIApplication *_Nullable)application continueUserActivity:(NSUserActivity *_Nullable)userActivity restorationHandler:(void(^_Nullable)(NSArray * __nullable restorableObjects))restorationHandler {
    return [[SensorsAnalyticsSDK sharedInstance] handleSchemeUrl:userActivity.webpageURL];
}

@end
