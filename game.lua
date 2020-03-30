
-- v1.0
-- global obj ---
require("src.config.init") --常量
require("src.framework.init") -- 加载框架'
require("src.core.Event") -- 加载事件部分
require("src.core.LayerManager") -- 加载层管理
require("src.common.init")
require("src.platform.init")
-- require("src.cache.init")
require("src.net.init")
require("src.modules.PopupManager")
require("src.modules.common.init") --ui通用接口
require("src.modules.ModuleManager") --//加载模块
require("src.music.MusicPlayer")--音乐
require("src.config.HotUpdateGames")

game = game or {}

game.init = function ()
    
    qf.log:setLogLvl(qf.log.ERROR)
    local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local radio = winSize.height / winSize.width
    
    -- 标准 0.5625
    -- 960*640  0.6666 最短
    -- 480*800 0.6 次短
    -- 若比率大于等于 0.6 则需要缩放部分元素
    
    if radio > 0.5634 then 
        FORCE_ADJUST_GAME = true
        GAME_RADIO = radio
    end
    qf.platform:getRegInfo()
    
    -- 禁止在此处手动给HOST_NAME赋值，如有必要，修改channel或isDebugEnv的值
    
    PF_WINDOWS = qf.device.platform == "windows" -- 检查是否为windows

end

--[[--
    国际化
]]

game.internationalization = function ()
    --local lang = qf.device.language  -- get lang by devices 
    GAME_LANG = qf.platform:getLang()--因为需求的改变而把国际化字段初始化放在这里
    require("src.res.GameRes")
    require("src.res." .. GAME_LANG .. ".GameTxt")
end


game.uploadError = function (parameters)
    -- upload error to server
    local host = HOST_PREFIX .. HOST_NAME .. "/client/exc/record"
    local uin = (Cache.user.uin or 0) .. ""
    local debug = qf.platform:isDebugEnv() == true and "1" or "0"
    local p = {host = host, content = parameters, channel = GAME_CHANNEL_NAME, uid = uin, debug = debug, version = GAME_BASE_VERSION or ""}
    qf.platform:uploadError(p)
end

game.beforeStartUp = function ()
    QNative:shareInstance():registerApplicationActions(function (paras)
        qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT, {type = paras})
    end)
    -- 加载游戏协议
    game.importProtoFile("res/texas_net.proto")
    -- 加载聊天基础协议
    game.importProtoFile("res/im_proto_common.proto")
    -- 加载聊天协议
    game.importProtoFile("res/im_proto_client.proto")
end

game.startup = function ()
    game.beforeStartUp() --创建目录等等
    game.init() -- 
    game.internationalization()
    
    local gameScene = require("src.core.GameScene").new()
    LayerManager:init(gameScene) -- init base layer and view event
    PopupManager:init()
    ModuleManager:init()
    game.initGames()
    
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    game.gotologin()
end

game.cancellationLogin = function()--注销之后登陆
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    cc.UserDefault:getInstance():flush()
    ModuleManager.login:show({showLoginBtnPannel = true})
    --登出一定要退回loginview
    --qf.event:dispatchEvent(ET.LOGIN_NET_GOTO_LOGIN)
end

game.gotologin = function()
    ModuleManager.global:show()
    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.login003})
    ModuleManager.login:show({showLoginBtnPannel = false})
    

    for k, v in pairs(GameRes.preLoadingImg)do
        cc.Director:getInstance():getTextureCache():addImageAsync(v, function() end)
    end
    
end

game.copyFileToLocal = function (relativeFilePath)
    -- 最后那段名字
    local filename = string.sub(relativeFilePath, string.find(relativeFilePath, "[^/]+$", 0))
    local srcFilePath = cc.FileUtils:getInstance():fullPathForFilename(relativeFilePath)
    
    local srcData = cc.FileUtils:getInstance():getDataFromFile(srcFilePath)
    local dstDirectory = cc.FileUtils:getInstance():getWritablePath()
    local dstFilePath = dstDirectory .. filename
    
    local f = assert(io.open(dstFilePath, "wb"))
    f:write(srcData)
    f:close()
    
    return dstDirectory, filename
end

game.importProtoFile = function(protoName)
    -- import proto 文件 for luapb
    local filePath = protoName
    local updatePath = QNative:shareInstance():getUpdatePath() .. "/" .. filePath
    if io.exists(updatePath) then
        filePath = updatePath
    end
    local directory, filename = game.copyFileToLocal(filePath)
    pb.import(filename, directory)
end

game.initGames = function (uniqName)
    for k, v in pairs(GAME_INSTALL_LIST) do
        local loadFlag = false
        if uniqName == v and uniqName then
            loadFlag = true
        end
        if not uniqName then
            loadFlag = true
        end
        if loadFlag then
            xpcall(require("src.games." .. v .. ".init"),function ()
                --加载异常处理 todo
            end)
        end
    end
end
