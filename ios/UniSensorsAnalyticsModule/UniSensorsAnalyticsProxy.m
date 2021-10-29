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
#import <SensorsFocus/SensorsFocus.h>
#import "UniSensorsAnalyticsModule.h"

static NSString *kSAPluginName = @"Sensorsdata-UniPlugin-App";
static NSString *kSAServerUrlKey = @"serverUrl";
static NSString *kSAAutoTrackEventTypeKey = @"autoTrackEventType";
static NSString *kSAMaxCacheSizeKey = @"maxCacheSize";
static NSString *kSAEnableLogKey = @"enableLog";
static NSString *kSAEnableEncryptKey = @"enableEncrypt";
static NSString *kSAEnableJavaScriptBridgeKey = @"enableJavaScriptBridge";
static NSString *kSARemoteCongUrl = @"remoteConfigUrl";
static NSString *kSAEnableAutoAddChannelCallbackEvent = @"enableAutoAddChannelCallbackEvent";

static NSString *kSFBaseURLKey = @"sfoBaseUrl";
static NSString *kSFPlanIdKey = @"planId";
static NSString *kSFTypeKey = @"type";
static NSString *kSFCampaignContentKey = @"content";
static NSString *kSFErrorKey = @"error";
static NSString *kSFActionKey = @"action";
static NSString *kSFActionValueKey = @"value";
static NSString *kSFActionExtraKey = @"extra";

@interface UniSensorsAnalyticsProxy () <SensorsFocusPopupDelegate, SensorsFocusCampaignDelegate>

@end

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
    // 兼容 Android 配置项 xml 文件中转义的问题，客户填入的内容为 & 为 &amp;
    serverUrl = [serverUrl stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    NSInteger autoTrackEventType = [[self objectForInfoDictionaryKey:kSAAutoTrackEventTypeKey] integerValue];
    NSInteger maxCacheSize = [[self objectForInfoDictionaryKey:kSAMaxCacheSizeKey] integerValue];
    BOOL enableLog = [[self objectForInfoDictionaryKey:kSAEnableLogKey] isEqualToString:@"true"];
    BOOL enableEncrypt = [[self objectForInfoDictionaryKey:kSAEnableEncryptKey] isEqualToString:@"true"];
    BOOL enableJavaScriptBridge = [[self objectForInfoDictionaryKey:kSAEnableJavaScriptBridgeKey] isEqualToString:@"true"];
    BOOL enableAutoAddChannelCallbackEvent = [[self objectForInfoDictionaryKey:kSAEnableAutoAddChannelCallbackEvent] isEqualToString:@"true"];

    NSString *remoteConfigURL = [self objectForInfoDictionaryKey:kSARemoteCongUrl];
    // 兼容 Android 配置项 xml 文件中转义的问题，客户填入的内容为 & 为 &amp;
    remoteConfigURL = [remoteConfigURL stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];

    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:serverUrl launchOptions:launchOptions];
    options.autoTrackEventType = autoTrackEventType;
    options.maxCacheSize = maxCacheSize;
    options.enableLog = enableLog;
    options.enableEncrypt = enableEncrypt;
    options.enableJavaScriptBridge = enableJavaScriptBridge;
    options.remoteConfigURL = remoteConfigURL;
    options.enableAutoAddChannelCallbackEvent = enableAutoAddChannelCallbackEvent;
    [SensorsAnalyticsSDK startWithConfigOptions:options];

    //init SF SDK
    NSString *sfoBaseURL = [self objectForInfoDictionaryKey:kSFBaseURLKey];
    sfoBaseURL = [sfoBaseURL stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
    if (sfoBaseURL.length > 0) {
        SFConfigOptions *sfOptions = [[SFConfigOptions alloc] initWithApiBaseURL:sfoBaseURL];
        sfOptions.popupDelegate = self;
        sfOptions.campaignDelegate = self;
        [SensorsFocus startWithConfigOptions:sfOptions];
    }
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
    return [self handleSchemeUrl:url];
}

- (BOOL)application:(UIApplication *_Nullable)application openURL:(NSURL *_Nullable)url sourceApplication:(NSString *_Nullable)sourceApplication annotation:(id _Nonnull )annotation {
    return [self handleSchemeUrl:url];
}

- (BOOL)application:(UIApplication *_Nullable)app openURL:(NSURL *_Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *_Nullable)options {
    return [self handleSchemeUrl:url];
}

- (BOOL)application:(UIApplication *_Nullable)application continueUserActivity:(NSUserActivity *_Nullable)userActivity restorationHandler:(void(^_Nullable)(NSArray * __nullable restorableObjects))restorationHandler {
    return [self handleSchemeUrl:userActivity.webpageURL];
}

- (void)application:(UIApplication * _Nullable)application didFailToRegisterForRemoteNotificationsWithError:(NSError * _Nullable)err {

}


- (void)application:(UIApplication * _Nullable)application didReceiveLocalNotification:(UILocalNotification * _Nullable)notification {

}


- (void)application:(UIApplication * _Nullable)application didReceiveRemoteNotification:(NSDictionary * _Nullable)userInfo {

}


- (void)application:(UIApplication * _Nullable)application didReceiveRemoteNotification:(NSDictionary * _Nullable)userInfo fetchCompletionHandler:(void (^ _Nullable)(UIBackgroundFetchResult))completionHandler {

}


- (void)application:(UIApplication * _Nullable)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData * _Nullable)deviceToken {

}


- (void)application:(UIApplication * _Nullable)application handleEventsForBackgroundURLSession:(NSString * _Nonnull)identifier completionHandler:(void (^ _Nullable)(void))completionHandler {

}


- (void)application:(UIApplication * _Nullable)application performActionForShortcutItem:(UIApplicationShortcutItem * _Nullable)shortcutItem completionHandler:(void (^ _Nullable)(BOOL))completionHandler {

}


- (void)applicationDidBecomeActive:(UIApplication * _Nullable)application {

}


- (void)applicationDidEnterBackground:(UIApplication * _Nullable)application {

}


- (void)applicationDidReceiveMemoryWarning:(UIApplication * _Nullable)application {

}


- (void)applicationWillEnterForeground:(UIApplication * _Nullable)application {

}


- (void)applicationWillResignActive:(UIApplication * _Nullable)application {

}


- (void)applicationWillTerminate:(UIApplication * _Nullable)application {

}


//MARK: SensorsFocusPopupDelegate
- (void)popupDidClickWithPlanID:(NSString *)planID action:(SensorsFocusActionModel *)action {
    if (![UniSensorsAnalyticsModule sharedModule].popupClickCallback) {
        return;
    }
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[kSFPlanIdKey] = planID;
    NSString *actionType = nil;
    switch (action.type) {
        case SensorsFocusActionTypeCopy:
            actionType = @"copy";
            break;
        case SensorsFocusActionTypeClose:
            actionType = @"close";
            break;
        case SensorsFocusActionTypeCustomize:
            actionType = @"customize";
            break;
        case SensorsFocusActionTypeOpenlink:
            actionType = @"openlink";
            break;
        default:
            actionType = @"unknown";
            break;
    }
    properties[kSFActionKey] = @{kSFTypeKey: actionType, kSFActionValueKey: action.value ?: @"", kSFActionExtraKey: action.extra ?: [NSDictionary dictionary]};

    [UniSensorsAnalyticsModule sharedModule].popupClickCallback(properties, YES);
}

//MARK: SensorsFocusCampaignDelegate
- (void)campaignDidStart:(SFCampaign *)campaign {
    if (![UniSensorsAnalyticsModule sharedModule].popupLoadSuccessCallback) {
        return;
    }
    NSMutableDictionary *properties = [self propertiesWithCampain:campaign];
    [UniSensorsAnalyticsModule sharedModule].popupLoadSuccessCallback([properties copy], YES);
}

- (void)campaignDidEnd:(SFCampaign *)campaign {
    if (![UniSensorsAnalyticsModule sharedModule].popupCloseCallback) {
        return;
    }
    NSMutableDictionary *properties = [self propertiesWithCampain:campaign];
    [UniSensorsAnalyticsModule sharedModule].popupCloseCallback(properties, YES);
}

- (void)campaignFailed:(SFCampaign *)campaign error:(NSError *)error {
    if (![UniSensorsAnalyticsModule sharedModule].popupLoadFailedCallback) {
        return;
    }
    NSMutableDictionary *properties = [self propertiesWithCampain:campaign];
    properties[kSFErrorKey] = error.localizedDescription;
    [UniSensorsAnalyticsModule sharedModule].popupLoadFailedCallback(properties, YES);
}

- (NSMutableDictionary *)propertiesWithCampain:(SFCampaign *)campaign {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[kSFPlanIdKey] = campaign.planID;
    properties[kSFTypeKey] = campaign.type == SFCampaignTypePreset ? @"preset" : @"customize";
    properties[kSFCampaignContentKey] = campaign.content;
    return properties;
}

- (BOOL)handleSchemeUrl:(NSURL *)url {
    NSString *sfoBaseURL = [self objectForInfoDictionaryKey:kSFBaseURLKey];
    if (sfoBaseURL.length > 0 && [SensorsFocus handleOpenURL:url]) {
        return YES;
    }
    return [[SensorsAnalyticsSDK sharedInstance] handleSchemeUrl:url];
}

@end
