# 神策 uni-app-native SDK 使用文档

## 使用说明

### 适用范围
本插件适用于 Android & iOS进行数据采集。

### 引入方式
```js
const sensors = uni.requireNativePlugin('Sensorsdata-UniPlugin-App');
```

## 2.2. API

### initSDK

方法说明：初始化 SDK

|参数| 类型  |说明 |是否必选| 
 |----|----|----| ---- |
|initSDK| object|  初始化 SDK| 是 |


**代码示例**:
```js
    sensors.initSDK({
        server_url:'数据接收地址',
        show_log:false,//是否开启日志
        global_properties:{},//全局属性，object 类型
        app:{// Android & iOS 初始化配置
            remote_config_url:"",
            flush_interval:15000,//两次数据发送的最小时间间隔，单位毫秒
            flush_bulkSize:100,//设置本地缓存日志的最大条目数，最小 50 条， 默认 100 条
            flush_network_policy:30, //设置 flush 时网络发送策略
            auto_track:0,  // 1 应用启动， 2 应用退出，3 应用启动和退出 默认 0
            encrypt:false,  //是否开启加密
            track_crash:false, // 是否采集 AppCrash 事件
            add_channel_callback_event:false,//是否开启渠道事件
            javascript_bridge:false, // WebView 打通功能
            android:{//Android 特有配置
                session_interval_time:30000,
                request_network:true,
                max_cache_size:32,     // 默认 32MB，最小 16MB
                mp_process_flush:false,//使用小程序 SDK 时，小程序进程是否可发送数据
            },
            ios:{//iOS 特有配置
                max_cache_size: 10000, //最大缓存条数，默认 10000 条
            }
        }
    });
```
### track

方法说明：代码埋点方法，调用该接口采集自定义事件

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|eventName| String| 事件名称 |是|
|para| Object| 自定义属性 |否|

**代码示例**:
```js
 sensors.track("eventName",{key : "value"}); 
```

### trackViewScreen

方法说明：触发页面浏览事件

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|url| String| 页面名称/path称 |是|
|properties| Object| 事件属性|否|

**代码示例**:
```js
 sensors.trackViewScreen("/new/detail",{key1:"value1",key2:"value2"}); 
```

### trackTimerStart

方法说明：初始化事件的计时器，计时单位：秒
返回：交叉计时事件 Id

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|eventName| String| 事件名称 |是|

**代码示例**:
```js
 sensors.trackTimerStart("detail");  
```

### trackTimerPause

方法说明：暂停事件计时器

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|eventName| String| 事件名称/交叉计时 Id |是|

**代码示例**:
```js
 sensors.trackTimerPause("detail");  
```
### trackTimerResume

方法说明：恢复事件计时器

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|eventName| String| 事件名称/交叉计时 Id |是|

**代码示例**:
```js
 sensors.trackTimerResume("detail");  
```
### trackTimerEnd

方法说明：停止事件计时器，触发事件

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|eventName| String| 事件名称/交叉计时 Id |是|

**代码示例**:
```js
 sensors.trackTimerEnd("detail");  
```
### removeTimer

方法说明：移除特定事件计时器

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|eventName| String| 事件名称/交叉计时 Id |是|

**代码示例**:
```js
 sensors.removeTimer("detail");  
```


### clearTrackTimer

方法说明：清除所有事件计时器

**代码示例**:
```js
 sensors.clearTrackTimer();  
```



### setServerUrl

方法说明：设置数据上报地址

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|serverUrl| String| 数据上报地址 |是|
**代码示例**:
```js
 sensors.serverUrl("数据接收地址"); 
```

### enableLog

方法说明：设置是否开启 log

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|enable| boolean| 是否开启日志址 |是|
```js
 sensors.enableLog(true)
```


### getPresetProperties

方法说明：返回预置属性
返回类型：object

```js
 var presetProperties = sensors.getPresetProperties(true)
```

### setFlushInterval
方法说明：设置两次数据发送的最小时间间隔，单位毫秒

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|interval| number| 是否开启日志址 |是|

```js
 sensors.setFlushInterval(30000); 
```

### getFlushInterval

方法说明：返回两次数据发送的最小时间间隔，单位毫秒
返回类型：number
```js
 var interval = sensors.getFlushInterval(); 
```


### setFlushBulkSize
方法说明：设置本地缓存日志的最大条目数，最小 50 条， 默认 100 条。

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|bulkSize| number| 是否开启日志址 |是|

```js
 sensors.setFlushBulkSize(200); 
```

### getFlushBulkSize

方法说明：返回本地缓存日志的最大条目数。
返回类型：number
```js
 var bulkSize = sensors.getFlushBulkSize(); 
```

### setSessionIntervalTime
方法说明：设置 App 切换到后台与下次事件的时间间隔，默认值为 30*1000 毫秒， 若 App 在后台超过设定事件，则认为当前 Session 结束，发送 $AppEnd 事件

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|session| number| Session 时长，仅 Android 有效 |是|

```js
 sensors.setSessionIntervalTime(20000); 
```

### getSessionIntervalTime
方法说明：获取 Session 时长。
返回类型：number
```js
 var session = sensors.getSessionIntervalTime(); 
```
### setFlushNetworkPolicy
方法说明：设置 flush 时网络发送策略，默认 3G、4G、WI-FI、5G 环境下都会尝试 flush

|参数 |类型 |说明 |是否必选|
|--|--|--|--|
|networkType| number| 网络类型NONE = 0 2G = 1 3G = 1 << 1（2） 4G = 1 << 2（4） WIFI = 1 << 3（8） 5G = 1 << 4（16） ALL = 0xFF（255） |是|

```js
 sensors.setFlushNetworkPolicy(31); 
```
### identify

方法说明：设置自定义匿名 ID

适用平台：Andorid、iOS、H5、小程序

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|id| String| 匿名 ID| 是|
```js
 sensors.identify("匿名 ID"); 
```


### getAnonymousID

方法说明：获取当前用户的匿名 ID

返回类型：string
```js
 var anonymosID = sensors.getAnonymousID(); 
```

### getDistinctID

方法说明：获取当前用户的 distinctId

返回类型：string

```js
 var distinctID = sensors.getDistinctID(); 
```

### login

方法说明：登录，设置当前用户的登录 ID，触发用户关联事件

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|id| String| 登录 ID| 是 |
```js
 sensors.login("loginID"); 
```
### getLoginID

方法说明：获取当前用户的登录 ID

返回类型：string

```js
 var loginID = sensors.getLoginID(); 
```

### logout

方法说明：注销，清空当前用户的登录 ID
```js
 sensors.logout(); 
```

### loginWithKey

方法说明：登录，设置当前用户的登录 IDKey 和 loginId

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|loginIDKey| String| 登录 ID Key |是  |
|loginID| String| 登录 ID | 是 |

```js
 sensors.loginWithKey("loginIDKey","loginID");
```

### bind

方法说明：绑定业务 ID
*$identity_mobile、$identity_email* 为神策定义业务 key，支持自定义 key

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|key| String| 业务ID Key|是  |
|value| String| 业务 ID | 是 |

```js
 sensors.bind("$identity_mobile","187****8991");
```
### unbind

方法说明：解绑业务 ID

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|key| String| 业务ID Key | 是  |
|value| String| 业务 ID | 是 |

```js
 sensors.unbind("$identity_mobile","187****8991");
```

### getIdentities

方法说明：获取已绑定的业务 ID 列表

返回类型：object

```js
 var identities = sensors.getIdentities();
```

### resetAnonymousIdentity

方法说明： ID-Mapping 3.0 重置匿名 ID，只有在未登录情况下可以使用。

| 参数     | 类型   | 说明           | 是否必选 |
| -------- | ------ | -------------- | -------- |
| identity | String | 新的匿名 Id 值 | 否       |

```js
 sensors.resetAnonymousIdentity("identity"); 
```

### trackAppInstall

方法说明：记录 $AppInstall 事件，用于在 App 首次启动时追踪渠道来源，并设置追踪渠道事件的属性

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|para |Object| 激活事件自定义属性 |否|
```js
 sensors.trackAppInstall(); 
```

### flush

方法说明：将所有本地缓存的日志发送到 SA
```js
 sensors.flush(); 
```

### registerSuperProperties

方法说明：注册事件公共属性

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|para |Object |公共属性 |是|

**代码示例**:
```js
 sensors.registerSuperProperties({key1:"value1",key2 : "value2",}); 
```

###  unregisterSuperProperty

方法说明：删除某些事件公共属性

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|name |string| 需删除的属性名称| 是|

**代码示例**:
```js
 sensors.unregisterSuperProperty("key1"); 
```
###  clearSuperProperties

方法说明：删除事件公共属性

```js
 sensors.clearSuperProperties(); 
```

###  getSuperProperties

方法说明：获取事件公共属性

```js
 var superProperties = sensors.getSuperProperties(); 
```

### profileSet

方法说明：设置用户属性

| 参数 |类型 |说明 |是否必选|
|--|--|--|--|
| para |Object| 用户属性 |是|

**代码示例**:
```js
 sensors.profileSet({key1:"value1",key2:"value2"}); 
```
### profileSetOnce

方法说明：首次设置用户属性，如果之前存在，则忽略，否则，新创建

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|para| Object| 用户属性| 是|

**代码示例**:
```js
 sensors.profileSetOnce({key1:"value1",key2:"value2"}); 
```

### profileIncrement

方法说明：给一个或多个数值类型的 Profile 增加一个数值。只能对数值型属性进行操作，若该属性未设置，则添加属性并设置默认值为 0

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|para| Object[value:number] |增加数值属性| 是|

**代码示例**:
```js
 sensors.profileIncrement({key1:2,key2:2}); 
```
### profileAppend

方法说明：给一个列表类型的用户属性增加一个元素

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|para| Object{key:[value: array<string> string]}| 增加数值属性| 是|

**代码示例**:
```js
 profileAppend({fruit:["苹果","西瓜"]}) 
 profileAppend({fruit:"西瓜"}) 
```
### profileUnset

方法说明：删除用户的一个用户属性

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|name| string| 属性名称| 是|
```js
 sensors.profileUnset('key1'); 
```

### profilePushId

方法说明：设置用户推送 ID

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|pushKey| string| 属性名 | 是|
|pushId| string| 推送 ID| 是|
```js
 sensors.profilePushId("pushKey","pushId");      
```



### profileUnsetPushId

方法说明：删除用户设置的推送 ID

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|pushKey| string| 用户表属性名称| 是|
```js
 sensors.profileUnsetPushId('pushKey'); 
```


### profileDelete

方法说明：删除用户所有用户属性
```js
 sensors.profileDelete(); 
```




### enableTrackScreenOrientation

方法说明：开启/关闭采集屏幕方向

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|enable| boolean| 是否开启采集屏幕方向，默认 false| 是|
```js
 sensors.enableTrackScreenOrientation(true)
```

### resumeTrackScreenOrientation

方法说明：恢复采集屏幕方向
```js
 sensors.resumeTrackScreenOrientation(); 
```
### stopTrackScreenOrientation

方法说明：停止采集屏幕方向
```js
 sensors.stopTrackScreenOrientation(); 
```
### getScreenOrientation

方法说明：获取屏幕方向
返回：portrait:竖屏，landscape:横屏
```js
 var screenOrientation = sensors.getScreenOrientation(); 
```

### trackDeepLinkLaunch

方法说明：Deeplink 唤起事件

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|deepLinkUrl| string| DeepLink 唤起链接| 是|
|oaid| string| Android OAID，iOS 无需设置| 否|
```js
 sensors.trackDeepLinkLaunch("scheme://host/path","oaid"); 
```


### enableDeepLinkInstallSource

方法说明：DeepLink 是否采集设备信息

|参数 |类型| 说明| 是否必选 |
|--|--|--|--|
|enable| boolean| DeepLink 是否采集设备信息,默认 false| 是|
```js
 sensors.enableDeepLinkInstallSource(true)
```

### popupInit
方法说明：弹窗 SDK 初始化，需在 initSDK 之后调用

```js
sensors.popupInit({
    // SFO 在线服务地址，由 SF 后端提供
    api_base_url: '',
    enable_popup:true,//初始化后是否允许弹窗，若禁止则在需要弹窗时调用 enablePopup  @platform Android
});
```

### 弹窗回调
方法说明：处理弹窗的各回调接口,需在弹窗 SDK 初始化后调用

|回调名称 | 说明|
|--|--|
|popupLoadSuccess| 弹窗展示成功时的回调|
|popupClose| 弹窗关闭时的回调|
|popupClick| 弹窗点击按钮时的回调|
|popupLoadFailed| 弹窗展示失败时的回调|

代码示例
```js
//弹窗展示成功回调
sensors.popupLoadSuccess( (json) => {
    console.log(json);
});
//弹窗点击回调
sensors.popupClick( (json) => {
    console.log(json);
});
//弹窗关闭回调
sensors.popupClose( (json) => {
    console.log(json);
});
// 弹窗加载失败回调
sensors.popupLoadFailed( (json) => {
    console.log(json);
});     
```