/*
 * Created by chenru on 2021/01/12.
 * Copyright 2015－2021 Sensors Data Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.sensorsdata.uniapp;

import android.text.TextUtils;
import android.util.Log;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.sensorsdata.analytics.android.sdk.SensorsDataAPI;
import com.sensorsdata.analytics.android.sdk.SensorsDataAPIEmptyImplementation;
import com.sensorsdata.sf.core.SFConfigOptions;
import com.sensorsdata.sf.core.SensorsFocusAPI;
import com.sensorsdata.sf.core.entity.SFCampaign;
import com.sensorsdata.sf.ui.listener.SensorsFocusCampaignListener;
import com.sensorsdata.uniapp.property.UniPropertyManager;
import com.sensorsdata.uniapp.sf.UniCampaignListener;
import com.sensorsdata.uniapp.sf.UniPopupListener;
import com.sensorsdata.uniapp.util.JSONUtils;

import java.util.Map;

import io.dcloud.feature.uniapp.annotation.UniJSMethod;
import io.dcloud.feature.uniapp.bridge.UniJSCallback;
import io.dcloud.feature.uniapp.common.UniDestroyableModule;

public class UniSensorsAnalyticsModule extends UniDestroyableModule {

    public static final String VERSION = "0.1.9";

    private static final String MODULE_NAME = "UniSensorsAnalyticsModule";
    public static final String LOG_TAG = "SA.UniModule";

    /**
     * 调用 track 接口，追踪一个带有属性的事件
     *
     * @param eventName 事件的名称
     * @param properties 事件的属性
     */
    @UniJSMethod()
    public void track(String eventName, JSONObject properties) {
        try {
            SensorsDataAPI.sharedInstance().track(eventName, UniPropertyManager.mergeProperty(JSONUtils.convertToJSONObject(properties)));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 调用 trackViewScreen 接口，触发页面浏览事件
     *
     * @param url url
     * @param properties 事件的属性
     */
    @UniJSMethod()
    public void trackViewScreen(String url, JSONObject properties) {
        try {
            SensorsDataAPI.sharedInstance().trackViewScreen(url, UniPropertyManager.mergeProperty(JSONUtils.convertToJSONObject(properties)));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 设置当前 serverUrl
     *
     * @param serverUrl 当前 serverUrl
     */
    @UniJSMethod()
    public void setServerUrl(String serverUrl) {
        try {
            SensorsDataAPI.sharedInstance().setServerUrl(serverUrl);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 设置是否开启 log
     *
     * @param enable boolean
     */
    @UniJSMethod()
    public void enableLog(boolean enable) {
        try {
            SensorsDataAPI.sharedInstance().enableLog(enable);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 返回预置属性
     *
     * @return JSONObject 预置属性
     */
    @UniJSMethod(uiThread = false)
    public JSONObject getPresetProperties() {
        try {
            return JSONUtils.convertToFastJson(SensorsDataAPI.sharedInstance().getPresetProperties());
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return null;
    }

    /**
     * 设置两次数据发送的最小时间间隔
     *
     * @param flushInterval 时间间隔，单位毫秒
     */
    @UniJSMethod()
    public void setFlushInterval(int flushInterval) {
        try {
            SensorsDataAPI.sharedInstance().setFlushInterval(flushInterval);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 两次数据发送的最小时间间隔，单位毫秒
     * 默认值为 15 * 1000 毫秒
     * 在每次调用 track、signUp 以及 profileSet 等接口的时候，都会检查如下条件，以判断是否向服务器上传数据:
     * 1. 是否是 WIFI/3G/4G 网络条件
     * 2. 是否满足发送条件之一:
     * 1) 与上次发送的时间间隔是否大于 flushInterval
     * 2) 本地缓存日志数目是否大于 flushBulkSize
     * 如果满足这两个条件，则向服务器发送一次数据；如果不满足，则把数据加入到队列中，等待下次检查时把整个队列的内
     * 容一并发送。需要注意的是，为了避免占用过多存储，队列最多只缓存 20MB 数据。
     *
     * @return 返回时间间隔，单位毫秒
     */
    @UniJSMethod(uiThread = false)
    public int getFlushInterval() {
        try {
            return SensorsDataAPI.sharedInstance().getFlushInterval();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return -1;
    }

    /**
     * 设置本地缓存日志的最大条目数，最小 50 条
     *
     * @param flushBulkSize 缓存数目
     */
    @UniJSMethod()
    public void setFlushBulkSize(int flushBulkSize) {
        try {
            SensorsDataAPI.sharedInstance().setFlushBulkSize(flushBulkSize);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 返回本地缓存日志的最大条目数
     * 默认值为 100 条
     * 在每次调用 track、signUp 以及 profileSet 等接口的时候，都会检查如下条件，以判断是否向服务器上传数据:
     * 1. 是否是 WIFI/3G/4G 网络条件
     * 2. 是否满足发送条件之一:
     * 1) 与上次发送的时间间隔是否大于 flushInterval
     * 2) 本地缓存日志数目是否大于 flushBulkSize
     * 如果满足这两个条件，则向服务器发送一次数据；如果不满足，则把数据加入到队列中，等待下次检查时把整个队列的内
     * 容一并发送。需要注意的是，为了避免占用过多存储，队列最多只缓存 32MB 数据。
     *
     * @return 返回本地缓存日志的最大条目数
     */
    @UniJSMethod(uiThread = false)
    public int getFlushBulkSize() {
        try {
            return SensorsDataAPI.sharedInstance().getFlushBulkSize();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return -1;
    }

    /**
     * 设置 App 切换到后台与下次事件的事件间隔
     * 默认值为 30*1000 毫秒
     * 若 App 在后台超过设定事件，则认为当前 Session 结束，发送 $AppEnd 事件
     *
     * @return 返回设置的 SessionIntervalTime ，默认是 30s
     */
    @UniJSMethod(uiThread = false)
    public int getSessionIntervalTime() {
        try {
            return SensorsDataAPI.sharedInstance().getSessionIntervalTime();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return 30000;
    }

    /**
     * 设置 App 切换到后台与下次事件的事件间隔
     * 默认值为 30*1000 毫秒
     * 若 App 在后台超过设定事件，则认为当前 Session 结束，发送 $AppEnd 事件
     *
     * @param sessionIntervalTime int Session 时长,单位毫秒
     */
    @UniJSMethod()
    public void setSessionIntervalTime(int sessionIntervalTime) {
        try {
            SensorsDataAPI.sharedInstance().setSessionIntervalTime(sessionIntervalTime);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 注册所有事件都有的公共属性
     *
     * @param superProperties 事件公共属性
     */
    @UniJSMethod()
    public void registerSuperProperties(JSONObject superProperties) {
        try {
            SensorsDataAPI.sharedInstance().registerSuperProperties(JSONUtils.convertToJSONObject(superProperties));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 删除事件公共属性
     *
     * @param superPropertyName 事件属性名称
     */
    @UniJSMethod()
    public void unregisterSuperProperty(String superPropertyName) {
        try {
            SensorsDataAPI.sharedInstance().unregisterSuperProperty(superPropertyName);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 删除所有事件公共属性
     */
    @UniJSMethod()
    public void clearSuperProperties() {
        try {
            SensorsDataAPI.sharedInstance().clearSuperProperties();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 获取当前用户的 distinctId
     *
     * @return 优先返回登录 ID，登录 ID 为空时，返回匿名 ID
     */
    @UniJSMethod(uiThread = false)
    public String getDistinctID() {
        try {
            return SensorsDataAPI.sharedInstance().getDistinctId();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return null;
    }

    /**
     * 获取当前用户的匿名 ID
     * 若调用前未调用 {@link #identify(String)} 设置用户的匿名 ID，SDK 会优先获取 Android ID，
     * 如获取的 Android ID 非法，则调用 {@link java.util.UUID} 随机生成 UUID，作为用户的匿名 ID
     *
     * @return 当前用户的匿名 ID
     */
    @UniJSMethod(uiThread = false)
    public String getAnonymousID() {
        try {
            return SensorsDataAPI.sharedInstance().getAnonymousId();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return null;
    }

    /**
     * 获取当前用户的 loginId
     * 若调用前未调用 {@link #login(String)} 设置用户的 loginId，会返回 null
     *
     * @return 当前用户的 loginId
     */
    @UniJSMethod(uiThread = false)
    public String getLoginID() {
        try {
            return SensorsDataAPI.sharedInstance().getLoginId();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return null;
    }

    /**
     * 设置当前用户的 distinctId。一般情况下，如果是一个注册用户，则应该使用注册系统内
     * 的 user_id，如果是个未注册用户，则可以选择一个不会重复的匿名 ID，如设备 ID 等，如果
     * 客户没有调用 identify，则使用SDK自动生成的匿名 ID
     *
     * @param distinctId 当前用户的 distinctId，仅接受数字、下划线和大小写字母
     */
    @UniJSMethod()
    public void identify(String distinctId) {
        try {
            SensorsDataAPI.sharedInstance().identify(distinctId);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 登录，设置当前用户的 loginId
     *
     * @param loginId 当前用户的 loginId，不能为空，且长度不能大于 255
     */
    @UniJSMethod()
    public void login(String loginId) {
        try {
            SensorsDataAPI.sharedInstance().login(loginId, UniPropertyManager.mergeProperty(null));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 注销，清空当前用户的 loginId
     */
    @UniJSMethod()
    public void logout() {
        try {
            SensorsDataAPI.sharedInstance().logout();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 记录 $AppInstall 事件，用于在 App 首次启动时追踪渠道来源，并设置追踪渠道事件的属性。
     * 这是 Sensors Analytics 进阶功能，请参考文档 https://sensorsdata.cn/manual/track_installation.html
     *
     * @param properties 渠道追踪事件的属性
     */
    @UniJSMethod()
    public void trackAppInstall(JSONObject properties) {
        try {
            SensorsDataAPI.sharedInstance().trackInstallation("$AppInstall", JSONUtils.convertToJSONObject(properties));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 设置 flush 时网络发送策略，默认 3G、4G、WI-FI、5G 环境下都会尝试 flush
     * TYPE_NONE = 0;//NULL
     * TYPE_2G = 1;//2G
     * TYPE_3G = 1 << 1;//3G 2
     * TYPE_4G = 1 << 2;//4G 4
     * TYPE_WIFI = 1 << 3;//WIFI 8
     * TYPE_5G = 1 << 4;//5G 16
     * TYPE_ALL = 0xFF;//ALL 255
     * 例：若需要开启 4G 5G 发送数据，则需要设置 4 + 16 = 20
     *
     * @param networkType int 网络类型
     */
    @UniJSMethod()
    public void setFlushNetworkPolicy(int networkType) {
        try {
            SensorsDataAPI.sharedInstance().setFlushNetworkPolicy(networkType);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 将所有本地缓存的日志发送到 Sensors Analytics.
     */
    @UniJSMethod()
    public void flush() {
        try {
            SensorsDataAPI.sharedInstance().flush();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 开启数据采集
     */
    @UniJSMethod()
    public void enableDataCollect() {

    }

    /**
     * 设置用户的一个或多个 Profile。
     * Profile 如果存在，则覆盖；否则，新创建。
     *
     * @param properties 属性列表
     */
    @UniJSMethod()
    public void profileSet(JSONObject properties) {
        try {
            SensorsDataAPI.sharedInstance().profileSet(JSONUtils.convertToJSONObject(properties));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 首次设置用户的一个或多个 Profile。
     * 与 profileSet 接口不同的是，如果之前存在，则忽略，否则，新创建
     *
     * @param properties 属性列表
     */
    @UniJSMethod()
    public void profileSetOnce(JSONObject properties) {
        try {
            SensorsDataAPI.sharedInstance().profileSetOnce(JSONUtils.convertToJSONObject(properties));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 给一个或多个数值类型的 Profile 增加一个数值。只能对数值型属性进行操作，若该属性
     * 未设置，则添加属性并设置默认值为 0
     *
     * @param properties 一个或多个属性集合
     */
    @UniJSMethod()
    public void profileIncrement(JSONObject properties) {
        try {
            Map maps = JSONUtils.convertToMap(properties);
            if (maps != null) {
                SensorsDataAPI.sharedInstance().profileIncrement(maps);
            }
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 给一个列表类型的 Profile 增加一个或多个元素
     *
     * @param properties 属性信息 {key,value:Array[number]}
     */
    @UniJSMethod()
    public void profileAppend(JSONObject properties) {
        try {
            if (properties != null) {
                for (String key : properties.keySet()) {
                    try {
                        Object value = properties.get(key);
                        if (value instanceof String) {
                            SensorsDataAPI.sharedInstance().profileAppend(key, (String) value);
                        } else if (value instanceof JSONArray) {
                            SensorsDataAPI.sharedInstance().profileAppend(key, JSONUtils.convertToSet((JSONArray) value));
                        }
                    } catch (Exception ignored) {

                    }
                }
            }
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 删除用户的一个 Profile
     *
     * @param property 属性名称
     */
    @UniJSMethod()
    public void profileUnset(String property) {
        try {
            SensorsDataAPI.sharedInstance().profileUnset(property);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 删除用户所有 Profile
     */
    @UniJSMethod()
    public void profileDelete() {
        try {
            SensorsDataAPI.sharedInstance().profileDelete();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 保存用户推送 ID 到用户表
     *
     * @param pushTypeKey 属性名称（例如 jgId）
     * @param pushId 推送 ID
     * 使用 profilePushId("jgId",JPushInterface.getRegistrationID(this))
     */
    @UniJSMethod
    public void profilePushId(String pushTypeKey, String pushId) {
        try {
            SensorsDataAPI.sharedInstance().profilePushId(pushTypeKey, pushId);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 删除用户设置的 pushId
     *
     * @param pushTypeKey 属性名称（例如 jgId）
     */
    @UniJSMethod
    public void profileUnsetPushId(String pushTypeKey) {
        try {
            SensorsDataAPI.sharedInstance().profileUnsetPushId(pushTypeKey);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 初始化事件的计时器，计时单位为秒。
     *
     * @param eventName 事件的名称
     * @return 交叉计时的事件名称
     */
    @UniJSMethod(uiThread = false)
    public String trackTimerStart(String eventName) {
        try {
            return SensorsDataAPI.sharedInstance().trackTimerStart(eventName);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return null;
    }

    /**
     * 暂停事件计时器，计时单位为秒。
     *
     * @param eventName 事件的名称
     */
    @UniJSMethod()
    public void trackTimerPause(String eventName) {
        try {
            SensorsDataAPI.sharedInstance().trackTimerPause(eventName);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 恢复事件计时器，计时单位为秒。
     *
     * @param eventName 事件的名称
     */
    @UniJSMethod()
    public void trackTimerResume(String eventName) {
        try {
            SensorsDataAPI.sharedInstance().trackTimerResume(eventName);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 停止事件计时器
     *
     * @param eventName 事件的名称，或者交叉计算场景时 trackTimerStart 的返回值
     * @param properties 事件的属性
     */
    @UniJSMethod()
    public void trackTimerEnd(String eventName, JSONObject properties) {
        try {
            SensorsDataAPI.sharedInstance().trackTimerEnd(eventName, UniPropertyManager.mergeProperty(JSONUtils.convertToJSONObject(properties)));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 删除事件的计时器
     *
     * @param eventName 事件名称
     */
    @UniJSMethod()
    public void removeTimer(String eventName) {
        try {
            SensorsDataAPI.sharedInstance().removeTimer(eventName);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 清除所有事件计时器
     */
    @UniJSMethod
    public void clearTrackTimer() {
        try {
            SensorsDataAPI.sharedInstance().clearTrackTimer();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 获取事件公共属性
     *
     * @return 当前所有 Super 属性
     */
    @UniJSMethod(uiThread = false)
    public JSONObject getSuperProperties() {
        try {
            return JSONUtils.convertToFastJson(SensorsDataAPI.sharedInstance().getSuperProperties());
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return null;
    }

    /**
     * DeepLink 是否采集设备信息
     *
     * @param enable 是否采集设备信息 true:是 false：否
     */
    @UniJSMethod
    public void enableDeepLinkInstallSource(boolean enable) {
        try {
            SensorsDataAPI.sharedInstance().enableDeepLinkInstallSource(enable);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 记录 $AppDeepLinkLaunch 事件
     *
     * @param deepLinkUrl 唤起应用的 DeepLink 链接
     * @param oaid oaid 非必填
     */
    @UniJSMethod
    public void trackDeepLinkLaunch(String deepLinkUrl, String oaid) {
        try {
            SensorsDataAPI.sharedInstance().trackDeepLinkLaunch(deepLinkUrl, oaid);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 开启/关闭采集屏幕方向
     *
     * @param enable true：开启 false：关闭
     */
    @UniJSMethod
    public void enableTrackScreenOrientation(boolean enable) {
        try {
            SensorsDataAPI.sharedInstance().enableTrackScreenOrientation(enable);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 恢复采集屏幕方向
     */
    @UniJSMethod
    public void resumeTrackScreenOrientation() {
        try {
            SensorsDataAPI.sharedInstance().resumeTrackScreenOrientation();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 停止采集屏幕方向
     */
    @UniJSMethod
    public void stopTrackScreenOrientation() {
        try {
            SensorsDataAPI.sharedInstance().stopTrackScreenOrientation();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    /**
     * 获取当前屏幕方向
     *
     * @return portrait:竖屏 landscape:横屏
     */
    @UniJSMethod(uiThread = false)
    public String getScreenOrientation() {
        try {
            return SensorsDataAPI.sharedInstance().getScreenOrientation();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
        return "";
    }

    /**
     * 注册弹窗成功的回调，预置弹窗和自定义会回调此接口
     *
     * @param callback callback
     */
    @UniJSMethod()
    public void popupLoadSuccess(UniJSCallback callback) {
        UniCampaignListener.loadSuccessJSCallback = callback;
    }

    /**
     * 注册弹窗失败的回调，预置弹窗和自定义会回调此接口
     *
     * @param callback callback
     */
    @UniJSMethod()
    public void popupLoadFailed(UniJSCallback callback) {
        UniCampaignListener.loadFailedJSCallback = callback;
    }

    /**
     * 注册弹窗点击的回调，预置弹窗会回调此接口
     *
     * @param callback callback
     */
    @UniJSMethod()
    public void popupClick(UniJSCallback callback) {
        UniCampaignListener.clickJSCallback = callback;
    }

    /**
     * 注册弹窗点击的回调，预置弹窗会回调此接口
     *
     * @param callback callback
     */
    @UniJSMethod()
    public void popupClose(UniJSCallback callback) {
        UniCampaignListener.closeJSCallback = callback;
    }

    /**
     * 运行弹窗，与初始化的 android_sfo_enable_popup 配合使用
     */
    @UniJSMethod()
    public void enablePopup() {
        try {
            SensorsFocusAPI.sharedInstance().enablePopup();
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    @UniJSMethod
    public void initSDK(JSONObject jsonConfig) {
        if (SensorsDataAPI.sharedInstance() instanceof SensorsDataAPIEmptyImplementation) {
            UniSensorsAnalyticsHelper.initSDK(mWXSDKInstance.getContext(), jsonConfig);
        }
    }

    @UniJSMethod
    public void popupInit(JSONObject jsonConfig) {
        try {
            if (jsonConfig != null) {
                SFConfigOptions sfConfigOptions;
                String sfBaseUrl = jsonConfig.getString("api_base_url");
                if (TextUtils.isEmpty(sfBaseUrl)) {
                    return;
                }
                sfConfigOptions = new SFConfigOptions(sfBaseUrl);
                try {
                    sfConfigOptions.enablePopup(JSONUtils.optObject(jsonConfig, "enable_popup", Boolean.class, true));
                } catch (Exception ignored) {

                }
                UniPopupListener popupListener = null;
                try {
                    Class<SensorsFocusCampaignListener> campaignClass = SensorsFocusCampaignListener.class;
                    campaignClass.getMethod("onCampaignClick", SFCampaign.class);
                } catch (NoSuchMethodException e) {
                    popupListener = new UniPopupListener();
                } catch (Exception ignored){

                }
                SensorsFocusAPI.startWithConfigOptions(mWXSDKInstance.getContext(), sfConfigOptions
                        .setPopupListener(popupListener)
                        .setCampaignListener(new UniCampaignListener()));
            }
            Log.i(LOG_TAG, "SensorsFocus SDK init success!");
        } catch (Exception ignored) {
            Log.i(LOG_TAG, "SensorsFocus SDK init failed!");
        }
    }

    @UniJSMethod
    public void bind(String key, String value) {
        try {
            SensorsDataAPI.sharedInstance().bind(key, value);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    @UniJSMethod
    public void unbind(String key, String value) {
        try {
            SensorsDataAPI.sharedInstance().unbind(key, value);
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }

    @UniJSMethod
    public void loginWithKey(String loginIDKey, String loginId, JSONObject properties) {
        try {
            SensorsDataAPI.sharedInstance().loginWithKey(loginIDKey, loginId, JSONUtils.convertToJSONObject(properties));
        } catch (Exception e) {
            Log.i(LOG_TAG, e.getMessage());
        }
    }
	
	@UniJSMethod
	public void resetAnonymousIdentity(String anonymousId) {
		try {
		    SensorsDataAPI.sharedInstance().resetAnonymousIdentity(anonymousId);
		} catch (Exception e) {
		    Log.i(LOG_TAG, e.getMessage());
		}
	}
	
	@UniJSMethod(uiThread = false)
	public JSONObject getIdentities() {
		try {
		    return JSONUtils.convertToFastJson(SensorsDataAPI.sharedInstance().getIdentities());
		} catch (Exception e) {
		    Log.i(LOG_TAG, e.getMessage());
		}
		return null;
	}

    @Override
    public void destroy() {
    }
}
