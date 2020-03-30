
ANDROID_CLASS_NAME="com/qufan/texas/util/Util"
OBJC_CLASS_NAME="LuaMutual"

local pf = import("."..qf.device.platform..".Platform")

qf = qf or {}
qf.platform = pf.new()

GAME_BASE_VERSION = qf.platform:getBaseVersion()
GAME_PAKAGENAME = "com.dianwan.hldwc"
GAME_VERSION_CODE = 1 -- apk版本号
GAME_RESOURCE_CODE = 1 -- 资源版本号
GAME_CHANNEL_NAME = "ADHM_HM000"
qf.platform:getRegInfo()