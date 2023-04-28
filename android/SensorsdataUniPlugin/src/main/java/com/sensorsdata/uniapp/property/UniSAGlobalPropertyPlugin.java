package com.sensorsdata.uniapp.property;

import com.sensorsdata.analytics.android.sdk.data.persistent.PersistentLoader;
import com.sensorsdata.analytics.android.sdk.plugin.property.SAPropertyPlugin;
import com.sensorsdata.analytics.android.sdk.plugin.property.SAPropertyPluginPriority;
import com.sensorsdata.analytics.android.sdk.plugin.property.beans.SAPropertiesFetcher;
import com.sensorsdata.analytics.android.sdk.plugin.property.beans.SAPropertyFilter;
import com.sensorsdata.uniapp.util.JSONUtils;

import org.json.JSONObject;

public class UniSAGlobalPropertyPlugin extends SAPropertyPlugin {
    private JSONObject mProperties;

    public UniSAGlobalPropertyPlugin(JSONObject globalProperties) {
        mProperties = globalProperties;
    }

    @Override
    public boolean isMatchedWithFilter(SAPropertyFilter filter) {
        return filter.getType().isTrack();
    }

    @Override
    public void properties(SAPropertiesFetcher fetcher) {
        if (mProperties == null || mProperties.length() == 0) {
            return;
        }
        JSONObject properties = PersistentLoader.getInstance().getSuperPropertiesPst().get();
        try {
            JSONUtils.mergeSuperJSONObject(mProperties, properties);
            PersistentLoader.getInstance().getSuperPropertiesPst().commit(properties);
            mProperties = null;
        } catch (Exception ignored) {
        }
    }

    @Override
    public SAPropertyPluginPriority priority() {
        return SAPropertyPluginPriority.LOW;
    }

}
