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

static NSString *const kSAUniPluginVersion = @"app_uniapp:0.0.2";
static NSString *const kSAUniPluginVersionKey = @"$lib_plugin_version";

@implementation UniSensorsAnalyticsModule

- (NSDictionary *)appendPluginVersion:(NSDictionary *)properties {
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

#pragma mark - Profile_*
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
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] setFlushNetworkPolicy:flushNetworkPolicy.integerValue];
    }];
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

@end
