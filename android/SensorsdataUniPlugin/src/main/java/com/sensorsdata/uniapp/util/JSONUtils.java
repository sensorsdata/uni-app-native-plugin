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

package com.sensorsdata.uniapp.util;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;
import java.util.Set;

public class JSONUtils {

    public static JSONObject convertToJSONObject(com.alibaba.fastjson.JSONObject fastJson) throws JSONException {
        if (fastJson == null) {
            return null;
        }
        return new JSONObject(fastJson.toJSONString());
    }

    public static com.alibaba.fastjson.JSONObject convertToFastJson(JSONObject JSONObject) {
        if (JSONObject == null) {
            return null;
        }
        return com.alibaba.fastjson.JSONObject.parseObject(JSONObject.toString());
    }

    public static Map convertToMap(com.alibaba.fastjson.JSONObject fastJson) {
        if (fastJson == null) {
            return null;
        }
        Map<String, Object> map = com.alibaba.fastjson.JSONObject.parseObject(fastJson.toString());
        for (Object value : map.values()) {
            if (!(value instanceof Number)) {
                return null;
            }
        }
        return map;
    }

    public static Set convertToSet(com.alibaba.fastjson.JSONArray fastJson) {
        if (fastJson == null) {
            return null;
        }
        return JSON.parseObject(fastJson.toString(), new TypeReference<Set<String>>() {
        });
    }
}
