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

import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;
import com.sensorsdata.analytics.android.sdk.SALog;
import com.sensorsdata.analytics.android.sdk.util.TimeUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class JSONUtils {

    public static JSONObject convertToJSONObject(com.alibaba.fastjson.JSONObject fastJson) {
        try {
            return new JSONObject(fastJson.toJSONString());
        } catch (Exception ignored) {
        }
        return null;
    }

    public static com.alibaba.fastjson.JSONObject convertToFastJson(JSONObject JSONObject) {
        try {
            return com.alibaba.fastjson.JSONObject.parseObject(JSONObject.toString());
        } catch (Exception ignored) {
        }
        return null;
    }

    public static Map convertToMap(com.alibaba.fastjson.JSONObject fastJson) {
        if (fastJson != null) {
            try {
                Map<String, Object> map = com.alibaba.fastjson.JSONObject.parseObject(fastJson.toString());
                for (Object value : map.values()) {
                    if (!(value instanceof Number)) {
                        return null;
                    }
                }
                return map;
            } catch (Exception ignored) {
            }
        }
        return null;

    }

    public static Set convertToSet(com.alibaba.fastjson.JSONArray fastJson) {
        if (fastJson != null) {
            try {
                return JSON.parseObject(fastJson.toString(), new TypeReference<Set<String>>() {
                });
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    public static <T> T optObject(com.alibaba.fastjson.JSONObject object, String key, Class<T> clazz, T defaultValue) {
        try {
            T value = object.getObject(key, clazz);
            if (value == null) {
                value = defaultValue;
            }
            return value;
        } catch (Exception ignored) {

        }
        return defaultValue;
    }

    /**
     * merge source JSONObject to dest JSONObject
     *
     * @param source
     * @param dest
     */
    public static void mergeJSONObject(final JSONObject source, JSONObject dest) {
        try {
            if (source == null) {
                return;
            }
            Iterator<String> sourceIterator = source.keys();
            while (sourceIterator.hasNext()) {
                String key = sourceIterator.next();
                Object value = source.get(key);
                if (value instanceof Date && !"$time".equals(key)) {
                    dest.put(key, TimeUtils.formatDate((Date) value, Locale.CHINA));
                } else {
                    dest.put(key, value);
                }
            }
        } catch (Exception ex) {
            SALog.printStackTrace(ex);
        }
    }

    /**
     * 合并、去重公共属性
     *
     * @param source 新加入或者优先级高的属性
     * @param dest 本地缓存或者优先级低的属性，如果有重复会删除该属性
     * @return 合并后的属性
     */
    public static JSONObject mergeSuperJSONObject(JSONObject source, JSONObject dest) {
        if (source == null) {
            source = new JSONObject();
        }
        if (dest == null) {
            return source;
        }

        try {
            Iterator<String> sourceIterator = source.keys();
            while (sourceIterator.hasNext()) {
                String key = sourceIterator.next();
                Iterator<String> destIterator = dest.keys();
                while (destIterator.hasNext()) {
                    String destKey = destIterator.next();
                    if (!TextUtils.isEmpty(key) && key.equalsIgnoreCase(destKey)) {
                        destIterator.remove();
                    }
                }
            }
            //重新遍历赋值，如果在同一次遍历中赋值会导致同一个 json 中大小写不一样的 key 被删除
            mergeJSONObject(source, dest);
        } catch (Exception ex) {
            SALog.printStackTrace(ex);
        }
        return dest;
    }
}
