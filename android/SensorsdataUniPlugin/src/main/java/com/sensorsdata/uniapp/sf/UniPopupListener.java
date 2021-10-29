/*
 * Created by yuejz on 2021/09/14.
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

package com.sensorsdata.uniapp.sf;

import android.util.Log;

import com.alibaba.fastjson.JSONObject;
import com.sensorsdata.sf.ui.listener.PopupListener;
import com.sensorsdata.sf.ui.view.SensorsFocusActionModel;
import com.sensorsdata.uniapp.util.JSONUtils;

public class UniPopupListener implements PopupListener {
    private static final String LOG_TAG = "SA.PopupListener";

    @Override
    public void onPopupLoadSuccess(String planId) {

    }

    @Override
    public void onPopupLoadFailed(String planId, int errorCode, String errorMessage) {

    }

    @Override
    public void onPopupClick(String planId, SensorsFocusActionModel actionModel) {
        if (UniCampaignListener.clickJSCallback != null) {
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("planId", planId);
                String type = null;
                switch (actionModel) {
                    case OPEN_LINK:
                        type = "openlink";
                        break;
                    case COPY:
                        type = "copy";
                        break;
                    case CLOSE:
                        type = "close";
                        break;
                    case CUSTOMIZE:
                        type = "customize";
                        break;
                }
                jsonObject.put("planId", planId);
                jsonObject.put("type", "preset");
                JSONObject actionJson = new JSONObject();
                actionJson.put("type", type);
                String value = actionModel.getValue();
                if (value == null || "null".equals(value)) {
                    actionJson.put("value", "");
                } else {
                    actionJson.put("value", value);
                }
                actionJson.put("extra", actionModel.getExtra() == null ? new JSONObject() : JSONUtils.convertToFastJson(actionModel.getExtra()));
                jsonObject.put("action", actionJson);
                UniCampaignListener.clickJSCallback.invokeAndKeepAlive(jsonObject);
            } catch (Exception e) {
                Log.i(LOG_TAG, e.getMessage());
            }
        }
    }

    @Override
    public void onPopupClose(String planId) {

    }
}
