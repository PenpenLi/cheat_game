------------------------
--因为无法重启游戏，lua栈也无法重置
--故启动游戏时先必须加载更新模块部分
--更新完之后，再调用game.startup
------------------------
---- game 常量配置，热更新不会变


--[[内置程序资源版本号，若要打出最新的apk，请务必更改为]]
NOW_RES_VERSION = 0

DEV_SIZE = {w=1920 ,h=1080}
CACHE_DIR = QNative:shareInstance():getCachePath().."/"
UPDATE_DIR = QNative:shareInstance():getUpdatePath().."/"
PERSIS_DIR = cc.FileUtils:getInstance():getWritablePath() .."persis/"
ANDROID_CLASS_NAME="com/qufan/texas/util/Util"
OBJC_CLASS_NAME="LuaMutual"
BASE_VERSION_KEY = SKEY.BASE_VERSION
RES_VERSION_KEY =  SKEY.RES_VERSION


local HotUpdate = class("HotUpdate") 
function HotUpdate:ctor()
	self:init()
end


function HotUpdate:init()
	require("src.game")
	game.startup()
end

game = game or {}

game.mkdir = function ( dir ) -- 创建文件夹
	QNative:shareInstance():mkdir(dir)
	loga(" ---- mkdir --"..dir)
end

game.rmdir = function ( dir ) -- 删除文件夹
	local target = cc.Application:getInstance():getTargetPlatform()

	if target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then  -- c++端写的目录操作，ios端无效，故ios端需要另外处理
		local args={path=dir}
		local luaoc = require ("luaoc")
		luaoc.callStaticMethod(OBJC_CLASS_NAME,"syyy_removeDir",args)
	else QNative:shareInstance():rmdir(dir) end
end


game.getHotUpdateInfo = function ()
	local target = cc.Application:getInstance():getTargetPlatform()
	if target == cc.PLATFORM_OS_ANDROID then
		local luaj = require ("luaj")
	    local sigs = "()Ljava/lang/String;"
	    local ok,ret = luaj.callStaticMethod(ANDROID_CLASS_NAME,"getHotUpdateInfo",nil,sigs)
	    loga(ret)
	    if ok == true then return require("json").decode(ret) end
	elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
		
	elseif target == cc.PLATFORM_OS_WINDOWS then

	end
	return {baseversion=110,pkgname="com.qufan.ddz",chid="CN_MAIN"}
end

game.beforeInit = function ()
    -- game.rmdir(CACHE_DIR)
    game.mkdir(CACHE_DIR) -- 重建缓存目录
    game.mkdir(PERSIS_DIR)-- 持久目录
    game.mkdir(UPDATE_DIR)-- 建更新目录
    game.setLocalVersion()
end


game.setLocalVersion = function ()
	
	local hi = game.getHotUpdateInfo()
    local resversion  = cc.UserDefault:getInstance():getIntegerForKey(RES_VERSION_KEY)
    loga(resversion)

    --[[若程序内置版本号大于本地记录的说明是新的apk]]
    if NOW_RES_VERSION > resversion then -- 
    	loga(" ---- 重置资源版本号 ,删除以前的资源----- ")
        cc.UserDefault:getInstance():setIntegerForKey(RES_VERSION_KEY,NOW_RES_VERSION) --设置资源版本号
        cc.UserDefault:getInstance():setIntegerForKey(BASE_VERSION_KEY,hi.baseversion) --设置程序版本
        cc.UserDefault:getInstance():flush()
        game.rmdir(UPDATE_DIR.."res")
        game.rmdir(UPDATE_DIR.."src")
    else
    	
    end
end

game.beforeInit()


local hu = HotUpdate.new()
