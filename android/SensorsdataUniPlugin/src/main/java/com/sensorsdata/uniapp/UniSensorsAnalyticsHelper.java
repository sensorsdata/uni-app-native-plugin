package com.sensorsdata.uniapp;

import static com.sensorsdata.uniapp.UniSensorsAnalyticsModule.LOG_TAG;

import android.content.Context;
import android.util.Log;

import com.alibaba.fastjson.JSONObject;
import com.sensorsdata.analytics.android.sdk.SAConfigOptions;
import com.sensorsdata.analytics.android.sdk.SensorsDataAPI;
import com.sensorsdata.uniapp.property.PluginVersionInterceptor;
import com.sensorsdata.uniapp.property.UniSAGlobalPropertyPlugin;
import com.sensorsdata.uniapp.property.UniPropertyManager;
import com.sensorsdata.uniapp.util.JSONUtils;
import com.sensorsdata.uniapp.util.VersionUtils;

public class UniSensorsAnalyticsHelper {

    public static void initSDK(Context context, JSONObject jsonConfig) {
        SAConfigOptions configOptions = null;
        boolean enableNetworkRequest = true;
        int session = 30000;
        try {
            if (jsonConfig != null) {
                String serverUrl = jsonConfig.getString("server_url");
                configOptions = new SAConfigOptions(serverUrl);
                configOptions.enableLog(JSONUtils.optObject(jsonConfig, "show_log", Boolean.class, false));
                JSONObject globalProperties = jsonConfig.getJSONObject("global_properties");
                if (globalProperties != null && !globalProperties.isEmpty() && VersionUtils.checkSAVersion("6.4.3")) {
                    configOptions.registerPropertyPlugin(new UniSAGlobalPropertyPlugin(JSONUtils.convertToJSONObject(globalProperties)));
                }
                JSONObject appConfig = jsonConfig.getJSONObject("app");
                if (appConfig != null) {
                    configOptions.setRemoteConfigUrl(appConfig.getString("remote_config_url"))
                            .setAutoTrackEventType(JSONUtils.optObject(appConfig, "auto_track", Integer.class, 0))
                            .setFlushInterval(JSONUtils.optObject(appConfig, "flush_interval", Integer.class, 15000))
                            .setFlushBulkSize(JSONUtils.optObject(appConfig, "flush_bulkSize", Integer.class, 100))
                            .setNetworkTypePolicy(JSONUtils.optObject(appConfig, "flush_network_policy", Integer.class, SensorsDataAPI.NetworkType.TYPE_ALL))
                            .enableAutoAddChannelCallbackEvent(appConfig.getBooleanValue("add_channel_callback_event"))
                            .enableEncrypt(appConfig.getBooleanValue("encrypt"));
                    boolean enableJavaScriptBridge = appConfig.getBooleanValue("javascript_bridge");
                    if (JSONUtils.optObject(appConfig, "track_crash", Boolean.class, false)) {
                        configOptions.enableTrackAppCrash();
                    }
                    JSONObject androidConfig = appConfig.getJSONObject("android");
                    if (androidConfig != null) {
                        session = JSONUtils.optObject(androidConfig, "session_interval_time", Integer.class, 30000);
                        configOptions.setMaxCacheSize(JSONUtils.optObject(androidConfig, "max_cache_size", Integer.class, 32) * 1024 * 1024);
                        enableNetworkRequest = JSONUtils.optObject(androidConfig, "request_network", Boolean.class, true);
                        if (androidConfig.getBooleanValue("mp_process_flush")) {
                            configOptions.enableSubProcessFlushData();
                        }
                        if (enableJavaScriptBridge) {
                            configOptions.enableJavaScriptBridge(androidConfig.getBooleanValue("support_jellybean"));
                        }
                    } else {
                        if (enableJavaScriptBridge) {
                            configOptions.enableJavaScriptBridge(false);
                        }
                    }
                }
            }
        } catch (Exception e) {
            Log.i(LOG_TAG, "Parse SAConfigOption Exception");
        }
        if (configOptions == null) {
            configOptions = new SAConfigOptions("");
        }
        UniPropertyManager.addInterceptor(new PluginVersionInterceptor());
        SensorsDataAPI.startWithConfigOptions(context, configOptions);
        SensorsDataAPI.sharedInstance().setSessionIntervalTime(session);
        SensorsDataAPI.sharedInstance().enableNetworkRequest(enableNetworkRequest);
        Log.i(LOG_TAG, "SensorsAnalytics SDK init success!");
    }
}
