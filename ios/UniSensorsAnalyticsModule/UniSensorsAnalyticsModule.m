//
// UniSensorsAnalyticsModule.m
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

#import "UniSensorsAnalyticsModule.h"
#if __has_include(<SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>)
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#else
#import "SensorsAnalyticsSDK.h"
#endif
#import <SensorsFocus/SensorsFocus.h>

static NSString *const kSAUniPluginVersion = @"app_uniapp:0.1.0";
static NSString *const kSAUniPluginVersionKey = @"$lib_plugin_version";

static NSString *kSFPlanIdKey = @"planId";
static NSString *kSFTypeKey = @"type";
static NSString *kSFCampaignContentKey = @"content";
static NSString *kSFErrorKey = @"error";
static NSString *kSFActionKey = @"action";
static NSString *kSFActionValueKey = @"value";
static NSString *kSFActionExtraKey = @"extra";

@interface UniSensorsAnalyticsModule () <SensorsFocusPopupDelegate, SensorsFocusCampaignDelegate>

@end

@implementation UniSensorsAnalyticsModule

- (NSDictionary *)appendPluginVersion:(NSDictionary *)properties {
    if (![properties isKindOfClass:NSDictionary.class]) {
        properties = [NSDictionary dictionary];
    }

    if (properties[kSAUniPluginVersionKey]) {
        return properties;
    }
    __block NSMutableDictionary *newProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
        newProperties[kSAUniPluginVersionKey] = @[kSAUniPluginVersion];
    });
    return newProperties ?: properties;
}

- (void)performSelectorWithImplementation:(void(^)(void))implementation {
    @try {
        implementation();
    } @catch (NSException *exception) {
        NSLog(@"\n ❌ [UniSensorsAnalyticsModule Exception] \n [Exception Message]: %@ \n [CallStackSymbols]: %@ ", exception, [exception callStackSymbols]);
    }
}

#pragma mark - track
WX_EXPORT_METHOD(@selector(track:properties:))
/**
 * 调用 track 接口，追踪一个带有属性的事件
 *
 * @param eventName 事件的名称
 * @param properties 事件的属性
 */
- (void)track:(NSString *)eventName properties:(NSDictionary *)properties {
    if (![eventName isKindOfClass:NSString.class]) {
        NSLog(@" ❌ [UniSensorsAnalyticsModule Error] Event name[%@] not valid", eventName);
        return;
    }
    [self performSelectorWithImplementation:^{
        NSDictionary *eventProps = [self appendPluginVersion:properties];
        [[SensorsAnalyticsSDK sharedInstance] track:eventName withProperties:eventProps];
    }];
}

WX_EXPORT_METHOD(@selector(trackAppInstall:))
/**
 * 记录 $AppInstall 事件，用于在 App 首次启动时追踪渠道来源，并设置追踪渠道事件的属性。
 * 这是 Sensors Analytics 进阶功能，请参考文档 https://sensorsdata.cn/manual/track_installation.html
 *
 * @param properties : object
 */
- (void)trackAppInstall:(NSDictionary *)properties {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] trackInstallation:@"$AppInstall" withProperties:properties];
    }];
}

WX_EXPORT_METHOD(@selector(identify:))
/**
 * 设置当前用户的 distinctId。一般情况下，如果是一个注册用户，则应该使用注册系统内
 * 的 user_id，如果是个未注册用户，则可以选择一个不会重复的匿名 ID，如设备 ID 等，如果
 * 客户没有调用 identify，则使用 SDK 自动生成的匿名 ID
 *
 * @param distinctId 当前用户的 distinctId，仅接受数字、下划线和大小写字母 : string
 */
- (void)identify:(NSString *)distinctId {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] identify:distinctId];
    }];
}

WX_EXPORT_METHOD(@selector(login:))
/**
 * 登录，设置当前用户的 loginId
 *
 * @param loginId 当前用户的 loginId，不能为空，且长度不能大于 255 : string
 */
- (void)login:(NSString *)loginId {
    [self performSelectorWithImplementation:^{
        NSDictionary *eventProps = [self appendPluginVersion:nil];
        [[SensorsAnalyticsSDK sharedInstance] login:loginId withProperties:eventProps];
    }];
}

WX_EXPORT_METHOD(@selector(logout))
/**
 * 注销，清空当前用户的 loginId
 */
- (void)logout {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] logout];
    }];
}

WX_EXPORT_METHOD(@selector(flush))
- (void)flush {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] flush];
    }];
}

#pragma mark - super properties
WX_EXPORT_METHOD(@selector(registerSuperProperties:))
/**
 * 注册所有事件都有的公共属性
 * @param properties 事件公共属性 ： object
 */
- (void)registerSuperProperties:(NSDictionary *)properties {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:properties];
    }];
}

WX_EXPORT_METHOD(@selector(unregisterSuperProperty:))
/**
 * 删除事件公共属性
 *
 * @param propertyName 事件属性名称 : string
 */
- (void)unregisterSuperProperty:(NSString *)propertyName {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] unregisterSuperProperty:propertyName];
    }];
}

WX_EXPORT_METHOD(@selector(clearSuperProperties))
/**
 * 删除所有事件公共属性
 */
- (void)clearSuperProperties {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] clearSuperProperties];
    }];
}

#pragma mark - Profile
WX_EXPORT_METHOD(@selector(profileSet:))
/**
 * 设置用户的一个或多个 Profile。
 * Profile 如果存在，则覆盖；否则，新创建。
 *
 * @param values 属性列表 : object
 */
- (void)profileSet:(NSDictionary *)values {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] set:values];
    }];
}

WX_EXPORT_METHOD(@selector(profileSetOnce:))
/**
 * 首次设置用户的一个或多个 Profile。
 * 与 profileSet 接口不同的是，如果之前存在，则忽略，否则，新创建
 *
 * @param values 属性列表 : object
 */
- (void)profileSetOnce:(NSDictionary *)values {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] setOnce:values];
    }];
}

WX_EXPORT_METHOD(@selector(profileIncrement:))
/**
 * @abstract
 * 给多个数值类型的 Profile 增加数值
 *
 * @discussion
 * values 中，key 是 NSString ，value 是 NSNumber
 *
 * @param values 属性列表: object
 */
- (void)profileIncrement:(NSDictionary *)values {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] increment:values];
    }];
}

WX_EXPORT_METHOD(@selector(profileAppend:))
/**
 * 给一个列表类型的 Profile 增加一个或多个元素
 *
 * @param values 新增的元素集合 : Array<string|number>
 */
- (void)profileAppend:(NSDictionary *)values {
    [self performSelectorWithImplementation:^{
        for (NSString *key in values.allKeys) {
            [[SensorsAnalyticsSDK sharedInstance] append:key by:values[key]];
        }
    }];
}

WX_EXPORT_METHOD(@selector(profileUnset:))
/**
 * 删除用户的一个 Profile
 *
 * @param key 属性名称 : string
 */
- (void)profileUnset:(NSString *)key {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] unset:key];
    }];
}

WX_EXPORT_METHOD(@selector(profileDelete))
/**
 * 删除用户所有 Profile
 */
- (void)profileDelete {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] deleteUser];
    }];
}

#pragma mark - SDK config
WX_EXPORT_METHOD(@selector(setServerUrl:))
/**
 * 设置当前 serverUrl
 *
 * @param serverUrl 当前 serverUrl : string
 */
- (void)setServerUrl:(NSString *)serverUrl {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] setServerUrl:serverUrl];
    }];
}

WX_EXPORT_METHOD(@selector(enableLog:))
/**
 * 设置是否开启 log
 *
 * @param enableLog : boolean
 */
- (void)enableLog:(BOOL)enableLog {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] enableLog:enableLog];
    }];
}

WX_EXPORT_METHOD(@selector(setFlushNetworkPolicy:))
/**
 * @platform Android & iOS
 *
 * 设置 flush 时网络发送策略，默认 3G、4G、WI-FI 环境下都会尝试 flush
 * TYPE_NONE = 0;//NULL
 * TYPE_2G = 1;//2G
 * TYPE_3G = 1 << 1;//3G 2
 * TYPE_4G = 1 << 2;//4G 4
 * TYPE_WIFI = 1 << 3;//WIFI 8
 * TYPE_5G = 1 << 4;//5G 16
 * TYPE_ALL = 0xFF;//ALL 255
 * 例：若需要开启 4G 5G 发送数据，则需要设置 4 + 16 = 20
 *
 * @param flushNetworkPolicy int 网络类型
 */
- (void)setFlushNetworkPolicy:(NSNumber *)flushNetworkPolicy {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] setFlushNetworkPolicy:flushNetworkPolicy.integerValue];
    }];
#pragma clang diagnostic pop
}

WX_EXPORT_METHOD(@selector(setFlushInterval:))
/**
 * @platform Android & iOS
 * 设置两次数据发送的最小时间间隔
 *
 * @param flushInterval 时间间隔，单位毫秒 : number
 */
- (void)setFlushInterval:(NSNumber *)flushInterval {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] setFlushInterval:flushInterval.unsignedLongLongValue];
    }];
#pragma clang diagnostic pop
}

WX_EXPORT_METHOD(@selector(setFlushBulkSize:))
/**
 * @platform Android & iOS
 * 设置本地缓存日志的最大条目数，最小 50 条
 *
 * @param flushBulkSize 缓存数目 : number
 */
- (void)setFlushBulkSize:(NSNumber *)flushBulkSize {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] setFlushBulkSize:flushBulkSize.unsignedLongLongValue];
    }];
#pragma clang diagnostic pop
}

WX_EXPORT_METHOD_SYNC(@selector(getFlushInterval))
/**
*  @platform Android & iOS
*  获取两次数据发送的最小时间间隔
*  默认值 15 * 1000 毫秒
*  @return 返回时间间隔，单位毫秒 : number
*/
- (NSNumber *)getFlushInterval {
    __block UInt64 flushInterval = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        flushInterval = [[SensorsAnalyticsSDK sharedInstance] flushInterval];
    }];
#pragma clang diagnostic pop
    return @(flushInterval);
}

WX_EXPORT_METHOD_SYNC(@selector(getFlushBulkSize))
/**
 * @platform Android & iOS
 * 本地缓存的最大事件数目，当累积日志量达到阈值时发送数据
 * 默认值为 100 条
 *
 * @return 本地缓存的最大事件数目 : number
 */
- (NSNumber *)getFlushBulkSize {
    __block UInt64 flushBulkSize = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        flushBulkSize = [[SensorsAnalyticsSDK sharedInstance] flushBulkSize];
    }];
#pragma clang diagnostic pop
    return @(flushBulkSize);
}

WX_EXPORT_METHOD_SYNC(@selector(getPresetProperties))
/**
 * 返回预置属性
 *
 * @return 预置属性 : object
 */
- (NSDictionary *)getPresetProperties {
    __block NSDictionary *preset = nil;
    [self performSelectorWithImplementation:^{
        preset = [[SensorsAnalyticsSDK sharedInstance] getPresetProperties];
    }];
    return preset;
}

WX_EXPORT_METHOD(@selector(initSDK:))
/*
 server_url:’数据接收地址‘,
 show_log:true,//是否开启日志
 app:{
     remote_config_url:""
     flush_interval:1000,
     flush_bulkSize:100,
     flush_network_policy:30,
     auto_track: 3, // 1 应用启动， 2 应用退出，3 应用启动和退出（位运算）
     encrypt:true,  //是否开启加密
     add_channel_callback_event:false,//是否开启渠道事件
     javascript_bridge:true, // H5 打通功能
     android:{
         support_jellybean:false //H5 打通是否支持 Android 16 及以下版本
         session_interval_time:15000,
         request_network:true,
         max_cache_size:最大缓存量   ,// 默认 32MB，最小 16MB
         mp_process_flush:true,//使用小程序 SDK 时，小程序进程是否可发送数据
     },
     ios:{
         max_cache_size: 10000,//最大缓存条数，默认 10000 条
     }
 }
 */

/**
 根据配置初始化 SDK

 @param config 初始化参数
*/
- (void)initSDK:(NSDictionary *)config {
    if (![config isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSString *serverURL = config[@"server_url"];
    if (![serverURL isKindOfClass:[NSString class]]) {
        return;
    }

    // 初始化配置
    SAConfigOptions *configOptions = [[SAConfigOptions alloc] initWithServerURL:serverURL launchOptions:nil];

    NSNumber *enableLog = config[@"show_log"];
    if ([enableLog isKindOfClass:[NSNumber class]]) {
        configOptions.enableLog = [enableLog boolValue];
    }

    /********  App 特有配置解析  ********/
    NSDictionary *appConfig = config[@"app"];
    if (![appConfig isKindOfClass:[NSDictionary class]]) {
        [SensorsAnalyticsSDK startWithConfigOptions:configOptions];
        return;
    }

    // 请求远程配置 URL
    NSString *remoteConfigURL = appConfig[@"remote_config_url"];
    if ([remoteConfigURL isKindOfClass:NSString.class]) {
        configOptions.remoteConfigURL = remoteConfigURL;
    }

    NSNumber *flushInterval = appConfig[@"flush_interval"];
    if ([flushInterval isKindOfClass:[NSNumber class]]) {
        configOptions.flushInterval = [flushInterval integerValue];
    }

    NSNumber *flushBulksize = appConfig[@"flush_bulkSize"];
    if ([flushBulksize isKindOfClass:[NSNumber class]]) {
        configOptions.flushBulkSize = [flushBulksize integerValue];
    }

    NSNumber *networkTypes = appConfig[@"flush_network_policy"];
    if ([networkTypes isKindOfClass:[NSNumber class]]) {
        configOptions.flushNetworkPolicy = [networkTypes integerValue];
    }

    NSNumber *autoTrack = appConfig[@"auto_track"];
    if ([autoTrack isKindOfClass:[NSNumber class]]) {
        configOptions.autoTrackEventType = [autoTrack integerValue];
    }

    NSNumber *enableEncrypt = appConfig[@"encrypt"];
    if ([enableEncrypt isKindOfClass:[NSNumber class]]) {
        configOptions.enableEncrypt = [enableEncrypt boolValue];
    }

    NSNumber *addChannelCallback = appConfig[@"add_channel_callback_event"];
    if ([addChannelCallback isKindOfClass:[NSNumber class]]) {
        configOptions.enableAutoAddChannelCallbackEvent = [addChannelCallback boolValue];
    }

    NSNumber *enableJavascriptBridge = appConfig[@"javascript_bridge"];
    if ([enableJavascriptBridge isKindOfClass:[NSNumber class]]) {
        configOptions.enableJavaScriptBridge = [enableJavascriptBridge boolValue];
    }

    NSDictionary *iOSConfigs = appConfig[@"ios"];
    if ([iOSConfigs isKindOfClass:[NSDictionary class]] && [iOSConfigs[@"max_cache_size"] isKindOfClass:[NSNumber class]]) {
        configOptions.maxCacheSize = [iOSConfigs[@"maxCacheSize"] integerValue];
    }

    // 开启 SDK
    [SensorsAnalyticsSDK startWithConfigOptions:configOptions];
}

#pragma mark - SDK IDS
WX_EXPORT_METHOD_SYNC(@selector(getDistinctID))
/**
 * 获取当前用户的 distinctId
 *
 * @return 优先返回登录 ID，登录 ID 为空时，返回匿名 ID : string
 */
- (NSString *)getDistinctID {
    __block NSString *distinctId;
    [self performSelectorWithImplementation:^{
        distinctId = [[SensorsAnalyticsSDK sharedInstance] distinctId];
    }];
    return distinctId;
}

WX_EXPORT_METHOD_SYNC(@selector(getAnonymousID))
/**
 * 获取当前用户的匿名 ID
 *
 * @return 当前用户的匿名 ID : string
 */
- (NSString *)getAnonymousID {
    __block NSString *anonymousID;
    [self performSelectorWithImplementation:^{
        anonymousID = [[SensorsAnalyticsSDK sharedInstance] anonymousId];
    }];
    return anonymousID;
}

WX_EXPORT_METHOD_SYNC(@selector(getLoginID))
/**
 * 获取当前用户的 loginId
 * 若调用前未调用 {@link #login(String)} 设置用户的 loginId，会返回 null
 *
 * @return 当前用户的 loginId : string
 */
- (NSString *)getLoginID {
    __block NSString *loginID;
    [self performSelectorWithImplementation:^{
        loginID = [[SensorsAnalyticsSDK sharedInstance] loginId];
    }];
    return loginID;
}

#pragma mark - Android Only
WX_EXPORT_METHOD(@selector(setSessionIntervalTime:))
/**
 * @platform Android
 *
 * 设置 App 切换到后台与下次事件的事件间隔
 * 默认值为 30*1000 毫秒
 * 若 App 在后台超过设定事件，则认为当前 Session 结束，发送 $AppEnd 事件
 *
 * @param sessionIntervalTime int Session 时长,单位毫秒 : number
 */
- (void)setSessionIntervalTime:(NSNumber *)sessionIntervalTime {
    //
}

WX_EXPORT_METHOD_SYNC(@selector(getSessionIntervalTime))
/**
 * @platform Android
 *
 * 获取 App 切换到后台与下次事件的事件间隔
 * 默认值为 30*1000 毫秒
 * 若 App 在后台超过设定事件，则认为当前 Session 结束，发送 $AppEnd 事件
 *
 * @return 返回设置的 SessionIntervalTime ，默认是 30s
 */
- (NSNumber *)getSessionIntervalTime {
    return @30000;
}

WX_EXPORT_METHOD(@selector(enableDataCollect))
/**
 * @platform Android
 * 开启数据采集
 */
- (void)enableDataCollect {

}

#pragma mark - Phase Two
WX_EXPORT_METHOD(@selector(removeTimer:))
- (void)removeTimer:(NSString *)eventName {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance removeTimer:eventName];
    }];
}

WX_EXPORT_METHOD_SYNC(@selector(trackTimerStart:))
- (NSString *)trackTimerStart:(NSString *)eventName {
    __block NSString *eventId;
    [self performSelectorWithImplementation:^{
        eventId = [SensorsAnalyticsSDK.sharedInstance trackTimerStart:eventName];
    }];
    return eventId;
}

WX_EXPORT_METHOD(@selector(trackTimerPause:))
- (void)trackTimerPause:(NSString *)eventName {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance trackTimerPause:eventName];
    }];
}

WX_EXPORT_METHOD(@selector(trackTimerResume:))
- (void)trackTimerResume:(NSString *)eventName {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance trackTimerResume:eventName];
    }];
}

WX_EXPORT_METHOD(@selector(trackTimerEnd:properties:))
- (void)trackTimerEnd:(NSString *)eventName properties:(NSDictionary *)properties {
    if (![eventName isKindOfClass:NSString.class]) {
        NSLog(@" ❌ [UniSensorsAnalyticsModule Error] Event name[%@] not valid", eventName);
        return;
    }
    [self performSelectorWithImplementation:^{
        NSDictionary *eventProps = [self appendPluginVersion:properties];
        [SensorsAnalyticsSDK.sharedInstance trackTimerEnd:eventName withProperties:eventProps];
    }];
}

WX_EXPORT_METHOD(@selector(clearTrackTimer))
- (void)clearTrackTimer {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance clearTrackTimer];
    }];
}

WX_EXPORT_METHOD(@selector(trackViewScreen:properties:))
- (void)trackViewScreen:(NSString *)url properties:(NSDictionary *)properties {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        NSDictionary *eventProps = [self appendPluginVersion:properties];
        [[SensorsAnalyticsSDK sharedInstance] trackViewScreen:url withProperties:eventProps];
    }];
#pragma clang diagnostic pop
}

WX_EXPORT_METHOD_SYNC(@selector(getSuperProperties))
- (NSDictionary *)getSuperProperties {
    __block NSDictionary *properties;
    [self performSelectorWithImplementation:^{
        properties = [SensorsAnalyticsSDK.sharedInstance currentSuperProperties];
    }];
    return properties;
}

WX_EXPORT_METHOD(@selector(enableTrackScreenOrientation:))
- (void)enableTrackScreenOrientation:(BOOL)enable {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance enableTrackScreenOrientation:enable];
    }];
}

WX_EXPORT_METHOD(@selector(resumeTrackScreenOrientation))
- (void)resumeTrackScreenOrientation {
    // Android 方法空实现
}

WX_EXPORT_METHOD(@selector(stopTrackScreenOrientation))
- (void)stopTrackScreenOrientation {
    // Android 方法空实现
}

WX_EXPORT_METHOD_SYNC(@selector(getScreenOrientation))
- (NSString *)getScreenOrientation {
    return @"";
}

WX_EXPORT_METHOD(@selector(profilePushId:pushId:))
- (void)profilePushId:(NSString *)pushKey pushId:(NSString *)pushId {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance profilePushKey:pushKey pushId:pushId];
    }];
}

WX_EXPORT_METHOD(@selector(profileUnsetPushId:))
- (void)profileUnsetPushId:(NSString *)pushKey {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance profileUnsetPushKey:pushKey];
    }];
}

WX_EXPORT_METHOD(@selector(enableDeepLinkInstallSource:))
- (void)enableDeepLinkInstallSource:(BOOL)enable {
    // Android 方法空实现
}

WX_EXPORT_METHOD(@selector(trackDeepLinkLaunch:))
- (void)trackDeepLinkLaunch:(NSString *)deeplinkUrl {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance trackDeepLinkLaunchWithURL:deeplinkUrl];
    }];
}

#pragma mark - SF Related
+ (instancetype)sharedModule {
    static UniSensorsAnalyticsModule *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UniSensorsAnalyticsModule alloc] init];
    });
    return sharedInstance;
}


UNI_EXPORT_METHOD(@selector(popupLoadSuccess:))

-(void)popupLoadSuccess:(UniModuleKeepAliveCallback)callback {
    [UniSensorsAnalyticsModule sharedModule].popupLoadSuccessCallback = callback;
}

UNI_EXPORT_METHOD(@selector(popupClose:))

-(void)popupClose:(UniModuleKeepAliveCallback)callback {
    [UniSensorsAnalyticsModule sharedModule].popupCloseCallback = callback;
}

UNI_EXPORT_METHOD(@selector(popupClick:))

-(void)popupClick:(UniModuleKeepAliveCallback)callback {
    [UniSensorsAnalyticsModule sharedModule].popupClickCallback = callback;
}

UNI_EXPORT_METHOD(@selector(popupLoadFailed:))

-(void)popupLoadFailed:(UniModuleKeepAliveCallback)callback {
    [UniSensorsAnalyticsModule sharedModule].popupLoadFailedCallback = callback;
}

UNI_EXPORT_METHOD(@selector(enablePopup:))
//Android 为了处理开屏页弹窗需要，iOS接口保持统一，但不需要实现
-(void)enablePopup:(BOOL)enable {

}

UNI_EXPORT_METHOD(@selector(popupInit:))
- (void)popupInit:(NSDictionary *)popupConfig {
    if (![popupConfig isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSString *sfoBaseURL = popupConfig[@"api_base_url"];
    if (![sfoBaseURL isKindOfClass:[NSString class]]) {
        return;
    }

    SFConfigOptions *sfOptions = [[SFConfigOptions alloc] initWithApiBaseURL:sfoBaseURL];
    sfOptions.popupDelegate = self;
    sfOptions.campaignDelegate = self;
    [SensorsFocus startWithConfigOptions:sfOptions];
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

@end
