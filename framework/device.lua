
--[[--
提供设备相关属性的查询，以及设备功能的访问
当框架初始完成后，device 模块提供下列属性：
-   device.platform 返回当前运行平台的名字，可用值： ios, android, mac, windows.
-   device.model 返回设备型号，可用值： unknown, iphone, ipad
-   device.language 返回设备当前使用的语言，可用值：
    -   cn：中文
    -   fr：法语
    -   it：意大利语
    -   gr：德语
    -   sp：西班牙语
    -   ru：俄语
    -   jp：日语
    -   en：英语
    -   th: 泰语
-   device.writablePath 返回设备上可以写入数据的首选路径：
]]

local device = {}
device.platform    = "unknown"
device.model       = "unknown"

local sharedApplication = cc.Application:getInstance()
local target = sharedApplication:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    device.platform = "windows"
elseif target == cc.PLATFORM_OS_MAC then
    device.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
    device.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    device.platform = "ios"
    if target == cc.PLATFORM_OS_IPHONE then
        device.model = "iphone"
    else
        device.model = "ipad"
    end
elseif target == cc.PLATFORM_OS_WINRT then
    device.platform = "winrt"
elseif target == cc.PLATFORM_OS_WP8 then
    device.platform = "wp8"
end

local language_ = sharedApplication:getCurrentLanguage()
if language_ == cc.LANGUAGE_CHINESE then
    language_ = "cn"
elseif language_ == cc.LANGUAGE_FRENCH then
    language_ = "fr"
elseif language_ == cc.LANGUAGE_ITALIAN then
    language_ = "it"
elseif language_ == cc.LANGUAGE_GERMAN then
    language_ = "gr"
elseif language_ == cc.LANGUAGE_SPANISH then
    language_ = "sp"
elseif language_ == cc.LANGUAGE_RUSSIAN then
    language_ = "ru"
elseif language_ == cc.LANGUAGE_KOREAN then
    language_ = "kr"
elseif language_ == cc.LANGUAGE_JAPANESE then
    language_ = "jp"
elseif language_ == cc.LANGUAGE_HUNGARIAN then
    language_ = "hu"
elseif language_ == cc.LANGUAGE_PORTUGUESE then
    language_ = "pt"
elseif language_ == cc.LANGUAGE_ARABIC then
    language_ = "ar"
else
    language_ = "en"
end

device.language = language_
device.writablePath = cc.FileUtils:getInstance():getWritablePath()


logi("# device.platform              = " .. device.platform)
logi("# device.model                 = " .. device.model)
logi("# device.language              = " .. device.language)
logi("# device.writablePath          = " .. device.writablePath)
logi("#")

return device
