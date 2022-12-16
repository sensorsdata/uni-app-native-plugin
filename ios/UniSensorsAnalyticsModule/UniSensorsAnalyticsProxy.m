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

@interface UniSensorsAnalyticsProxy ()

@end

@implementation UniSensorsAnalyticsProxy


#pragma mark - uni-app plugin lifeCycle
-(void)onCreateUniPlugin {
    NSLog(@"[uni-app SensorsAnalyticsModule] initialize sucess !!!");
}

- (BOOL)application:(UIApplication *_Nullable)application didFinishLaunchingWithOptions:(NSDictionary *_Nullable)launchOptions {
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


- (BOOL)handleSchemeUrl:(NSURL *)url {
    if ([SensorsFocus handleOpenURL:url]) {
        return YES;
    }
    return [[SensorsAnalyticsSDK sharedInstance] handleSchemeUrl:url];
}

@end
