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

package com.sensorsdata.uniapp.property;


import com.sensorsdata.uniapp.UniSensorsAnalyticsModule;

import org.json.JSONArray;
import org.json.JSONObject;

public class PluginVersionInterceptor implements UniPropertyManager.Interceptor {

    private static boolean isMergePluginVersion = false;

    public JSONObject proceed(JSONObject properties, boolean isAuto) {
        if (!isMergePluginVersion) {
            if (properties == null) {
                properties = new JSONObject();
            } else if (properties.has("$lib_plugin_version")) {
                return properties;
            }
            try {
                JSONArray array = new JSONArray();
                array.put("app_uniapp:" + UniSensorsAnalyticsModule.VERSION);
                properties.put("$lib_plugin_version", array);
            } catch (Exception ignored) {
                //ignore
            }
            isMergePluginVersion = true;
        }
        return properties;
    }
}