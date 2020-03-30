--[[
--热更新
--]]
GAME_INSTALL_LIST  = GAME_INSTALL_LIST or {}
GAME_INSTALL_TABLE = GAME_INSTALL_TABLE or {}
GAMES              = {"game_hall", "game_niuniu", "game_zjh", "game_lhd","game_zhajinniu","game_br","game_brnn","game_ddz"}
--{"game_texas","game_tbz","game_xiaoxiaole", "game_solitaire","game_fruitmachine"}

local HotUpdateMain = {}

require "json"
require("src.config.init")
require("src.framework.init")
require("src.res.GameRes")
require("src.common.init")
require("src.platform.init")
require("src.core.Event")
require("src.music.MusicPlayer") --音乐
require("src.config.HotUpdateGames")
local GlobalPromit = require("src.modules.global.components.GlobalPromit")
local HotUpdateHelper = require("src.update.HotUpdateHelper")
local HotUpdatePackageHelper = require("src.update.HotUpdatePackageHelper")
local TAG_GLOBAL_PROMIT = 1001

local m_instance
local function new( o )
    o = o or {}
    setmetatable(o, {__index=HotUpdateMain})
    return o
end
local function getInstance( ... )
    if not m_instance then
        m_instance = new()
        m_instance:init()
    end
    return m_instance
end

function HotUpdateMain:init( ... )
    self.gameHelper={}
    self.helper = HotUpdateHelper.getInstance()
    self.packageHelper = HotUpdatePackageHelper.getInstance()
    self.helper:init({callback=handler(self, self.handlerDownload)})
end
function HotUpdateMain.getInstance( ... )
    return getInstance()
end

function HotUpdateMain:initUI( ... )
    self.win_size = cc.Director:getInstance():getWinSize()
    self.scene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self.scene)
    else
        cc.Director:getInstance():runWithScene(self.scene)
    end
    self.layer = cc.Layer:create()
    self.layer:setTouchEnabled(true)
    self.scene:addChild(self.layer)
    --开始下载
    self:registerScriptHandler()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.hotUpdateJson)
    self.layer:addChild(self.root)

    self.pan_all = self.root:getChildByName("pan_all")
    self.pan_progress = ccui.Helper:seekWidgetByName(self.root, "pan_progress")
    --进度提示
    self.pan_progress_tip = self.pan_progress:getChildByName("pan_txt")
    --进入游戏提示
    self.lbl_enter_game = self.pan_progress:getChildByName("txt_enter_game")
    --进度条背景
    self.img_progress_bg = self.pan_progress:getChildByName("img_progress_bg")
    --进度条Bar
    self.bar_progress = self.pan_progress:getChildByName("bar_progress")
    --具体的下载大小
    self.lbl_percect = self.pan_progress_tip:getChildByName("lbl_perfect")
    --叠加背景
    self.bgImg= ccui.Helper:seekWidgetByName(self.root,"bg")
    --美女
    self.Beauty= ccui.Helper:seekWidgetByName(self.root,"beauty")
    self.pan_progress:setVisible(false)

    self:initLoadding()

    -- self:initAnimate()
    -- self:updateReview()
end

function HotUpdateMain:updateReview()
    if not self.is_review then
        self.Beauty:setVisible(false)
        self.bgImg:loadTexture(GameRes.loading_review_bg)
        -- if self.bueatyAnimate then 
        --     self.pan_all:removeChild(self.bueatyAnimate)
        --     self.bueatyAnimate=nil
        -- end
    end
end

function HotUpdateMain:showToolsTips(msg)
    -- body
    if self.toolTips then return end
    self.toolTips = require("src.modules.common.widget.toolTip").new()
    self.toolTips:removeCloseTouch()
    self.toolTips:setTipsText(msg)
    self.layer:addChild(self.toolTips,2)
    if self.toolsTipsSch then
        Scheduler:unschedule(self.toolsTipsSch)
        self.toolsTipsSch=nil
    end
    self.toolsTipsSch =  Scheduler:scheduler(60,function( ... )
        self.helper:init({callback=handler(self, self.handlerDownload)})
    end)
end
function HotUpdateMain:removeToolsTips( ... )
    -- body
    if not self.toolTips then return end
    self.toolTips:removeFromParent()
    self.toolTips=nil
    if self.toolsTipsSch then
        Scheduler:unschedule(self.toolsTipsSch)
        self.toolsTipsSch=nil
    end
end

--初始化loadding
function HotUpdateMain:initLoadding( ... )
    self.img_loadding_bg = cc.Sprite:create(GameRes.login_bg)
    local fullscreenX =  FULLSCREENADAPTIVE and -(self.win_size.width/2-1920/2) or 0
    self.img_loadding_bg:setPosition(fullscreenX+self.win_size.width/2, self.img_loadding_bg:getContentSize().height/2)
    if FULLSCREENADAPTIVE then
        self.img_loadding_bg:setScaleX(1.5)
    end
    self.pan_all:addChild(self.img_loadding_bg,3)

    self.img_loadding = cc.Sprite:create()
    self.img_loadding:setAnchorPoint(cc.p(0, 0))
    self.pan_all:addChild(self.img_loadding,3)

    local statusTxt = cc.LabelTTF:create(GameTxt.login002, GameRes.font1, 40)
    self.img_loadding:addChild(statusTxt)
    statusTxt:setAnchorPoint(cc.p(0,0))

    local spr = cc.Sprite:create()
    self.img_loadding:addChild(spr)

    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.login_plist, GameRes.login_png)
    local frames = Display:newFrames("login_%d.png", 1, 4)
    local ani = Display:newAnimation(frames, 0.7)

    local seq = cc.RepeatForever:create(cc.Animate:create(ani))
    spr:runAction(seq)

    spr:setPosition(statusTxt:getContentSize().width + LOGIN_LOADING_ARMATURE_WIDTH/2, statusTxt:getContentSize().height/2)
    self.img_loadding:setPosition(fullscreenX+self.win_size.width/2 - LOGIN_LOADING_ARMATURE_WIDTH/2 - statusTxt:getContentSize().width/2,106)
end

function HotUpdateMain:hideLoadding( ... )
    if not self.img_loadding_bg or not self.img_loadding then return end
    self.img_loadding_bg:setVisible(false)
    self.img_loadding:setVisible(false)
end

function HotUpdateMain:registerScriptHandler( ... )
    -- 绑定Node事件
    local function onNodeEvent(eventName)
        if eventName == "enter" then
            self:onEnter()
        elseif eventName == "exit" then
        end
    end
    self.layer:registerScriptHandler(onNodeEvent)
end
function HotUpdateMain:onEnter( ... )
    loga("HotUpdateMain:onEnter")
    self.helper:startDownload({load_type=0})
end
--开始更新文件
function HotUpdateMain:startDownloadUpdateFile( ... )
    if not self.install then
        local is_review = 0 ~= Util:binaryAnd(tonumber(Util:getDesDecryptString(TB_SERVER_INFO.modules)), TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
        self.is_review = is_review
        if self.is_review then
            self.img_progress_bg:setVisible(true)
            self.bar_progress:setVisible(true)
            self.pan_progress:setVisible(true)
        end
        if self.img_loadding and tolua.isnull(self.img_loadding) == false then
            self.img_loadding:setVisible(true)
        end
        if self.img_loadding_bg and tolua.isnull(self.img_loadding_bg) == false then
            self.img_loadding_bg:setVisible(true)
        end
        self:updateProgress()
    else
        if self.isGetTotalSize then return end
        --self.installProgress(self.current_count,self.current_total_count)
    end
    self.helper:startDownload({load_type=2})
end
--更新进度条
function HotUpdateMain:updateProgress( ... )
    if self.lbl_percect == nil or tolua.isnull(self.lbl_percect) == true then
        return
    end
    self.current_count = self.current_count > self.current_total_count and self.current_total_count or self.current_count

    local percent = self.current_count*100/self.current_total_count
    percent = percent > 100 and 100 or percent

    -- self.lbl_percect:setString(string.format("(%dk/%dk)", self.current_count, self.current_total_count))
    self:updateProgressByPercent(percent)
end

function HotUpdateMain:updateProgressByPercent(percent, bPackageUpdate)
    if percent < 0 then percent = 0 end
    if percent >= 0 then self:hideLoadding() end

    self.pan_progress_tip:setVisible(true)
    self.img_progress_bg:setVisible(true)
    self.bar_progress:setVisible(true)
    self.pan_progress:setVisible(true)
    self.lbl_percect:setString(string.format(GameTxt.hot_loading_txt, percent))
    self.lbl_percect:setVisible(true)
    self.bar_progress:setPercent(percent)
    self.lbl_enter_game:setVisible(false)
    --如果是整包更新、下一步就是解压文件
    if percent >= 100 and bPackageUpdate then
        self.lbl_percect:stopAllActions()
        self.lbl_percect:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.05),
            cc.CallFunc:create(function ()
                self.lbl_percect:setString(GameTxt.hot_update_string_15)
            end)
        ))
    end
end

--整包更新
function HotUpdateMain:downPackgeResult(errorCode)
    -- cc.ASSETSMANAGER_CREATE_FILE  = 0
    -- cc.ASSETSMANAGER_NETWORK = 1
    -- cc.ASSETSMANAGER_NO_NEW_VERSION = 2
    -- cc.ASSETSMANAGER_UNCOMPRESS     = 3
    
    local mesgTips = {
        [0] = GameTxt.hot_update_string_12,
        [1] = GameTxt.hot_update_string_13,
        [3] = GameTxt.hot_update_string_14,
    }

    --更新整包失败

    if errorCode and errorCode ~= -1 and errorCode ~= cc.ASSETSMANAGER_NO_NEW_VERSION then
        loga("【HotUpdateMain】 downPackgeResult error" .. mesgTips[errorCode])
        self.bar_progress:setPercent(0)
        self.lbl_percect:setString(mesgTips[errorCode])
        self:startUpdateResource()
        return
    end
    self:_setReourceViewCode()
    self.lbl_percect:setString(GameTxt.hot_update_string_16)
    self:finalEnterGame()
end

--[[
name = "result", load_type=type --完成了第几步
name = "progress", count=n --下载更新文件，count当前下载了多少
--]]
function HotUpdateMain:handlerDownload( args )
    local name = args.name
    if name == "progress" then --下载更新文件的过程
        self.current_count = args.count

        if not self.install then
            self:updateProgress()
        else
            -- self.installProgress(self.current_count,self.current_total_count)
        end
    elseif name == "result" then --某个阶段完成
        self:downloadFinish(args.load_type)
        if args.load_type == 0 then 
            self:removeToolsTips()
        end
    elseif name == "stopSocket" then
        self:showToolsTips(args.msg and args.msg or "")
    end
end
--某个阶段下载完成
function HotUpdateMain:downloadFinish( load_type, args )
    if load_type == 0 then --配置下载完成
        --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "配置下载完成"})
        self:downloadConfigListSuccess()
    elseif load_type == 1 then --md5文件下载完成
        self:downloadMd5FileSuccess()
        --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "md5文件下载完成"})
    elseif load_type == 2 then --更新文件下载完成
        if not self.install  then
            self.helper:setDownloadFinish(true) --下载完成
            --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "更新文件下载完成 enterGame"})
            self:enterGame()
        else
            --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "更新文件下载完成 install"})
            local data
            if not io.exists(self.helper.update_md5_path) then
                data = cc.FileUtils:getInstance():getDataFromFile(self.helper.md5_path)
            else
                data = cc.FileUtils:getInstance():getDataFromFile(self.helper.update_md5_path)
            end
            STRING_UPDATE_FILE_MD5 = QNative:shareInstance():md5(data)

            self.helper:copyDirectory(self.helper.temp_update_folder, self.helper.update_folder)
            self.installed()
            self.install= nil
        end
    end
end

function HotUpdateMain:startUpdateResource( ... )
    local is_review = 0 ~= Util:binaryAnd(tonumber(Util:getDesDecryptString(TB_SERVER_INFO.modules)), TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    --先判断整包更新、优先更新
    --【兼容】 470以上才可以整包更新
    local differet_zip_path = Util:getDesDecryptString(self.helper.config_list.differet_zip_path)
    if differet_zip_path and differet_zip_path ~= "" and tonumber(GAME_VERSION_CODE) >= 470 then
        -- 整包下载
        self:updateNormal()
    else
        self:updateNormal()
    end
end

function HotUpdateMain:startCommonResourcePackageUpdate( ... )
    -- 整包下载
    if self.helper.config_list.patch.version_addr and self.helper.config_list.patch.version_addr ~= "" then
        self.packageHelper:init({progresscb = handler(self, self.updateProgressByPercent), resultcb = handler(self, self.downPackgeResult)})
        self:hideLoadding()
        self.packageHelper:downloadPackageTask({
            zipurl = Util:getDesDecryptString(self.helper.config_list.differet_zip_path),
            versionurl = Util:getDesDecryptString(self.helper.config_list.patch.version_addr),
            path = QNative:shareInstance():getUpdatePath()
        })
    else
        self:updateNormal()
    end
end

--下载配置文件成功
function HotUpdateMain:downloadConfigListSuccess( ... )
    --检查是否需要大版本更新或停服提示
    local is_need_full, configlist = self.helper:checkFullDoseUpdate()
    configlist = self.helper.config_list
    local must_update_flag = tonumber(Util:getDesDecryptString(configlist.must_update_flag))
    if must_update_flag == 1 then
        self:tipForPackageAlert(configlist)
        return
    end

    local nextLogicFunc = function (isNeedFull, cBack, configlist)
        if isNeedFull then --需要提示
            callback = function ()
                if qf.device.platform == "ios" then
                    qf.platform:exitApplication()
                else
                    cc.Director:getInstance():endToLua()
                end
            end
            self:tipWithMainTain({configlist=configlist, callback=cBack})
        else
            self:startUpdateResource()
        end
    end

    if configlist.ios_download_url ~= "" then
        local ios_download_type = tonumber(Util:getDesDecryptString(configlist.ios_download_type))
        if ios_download_type and ios_download_type > 0 then
            self:tipForAppStorePackageAlert(configlist, function ( ... )
                nextLogicFunc(is_need_full, callback, configlist)
            end)
            return
        end
    end
    nextLogicFunc(is_need_full, callback, configlist)
end

function HotUpdateMain:updateNormal( ... )
    --检查增量更新的方式，是否需要更新
    local hot_type = self.helper:getHotUpdateType()

    loga("____HotUpdateMain:downloadConfigListSuccess"..hot_type)

    if hot_type == 1 or hot_type == 2 or hot_type == 3 then

        self:hideLoadding()
        self.helper:startDownload({load_type=1})
        self.lbl_enter_game:setString(GameTxt.hot_update_string_17)
        self.lbl_enter_game:setVisible(true)
        self.pan_progress:setVisible(true)
        self.img_progress_bg:setVisible(false)
        self.bar_progress:setVisible(false)
        self.pan_progress_tip:setVisible(false)
    else
        if not self.install  then
            --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "不需要更新 enterGame"})
            self:enterGame()
        else
            if self.installed then
                self.installed()
            end
        end
    end
end

--大版本更新或停服提示
function HotUpdateMain:tipWithFullDose( args )
    local content = args.content
    local function _callback( _type )
        if 2 ~= tonumber(Util:getDesDecryptString(content.pkg_status)) then --不是强制更新要把提示界面移除
            self.layer:removeChildByTag(TAG_GLOBAL_PROMIT, true)
        end
        if 1 == tonumber(Util:getDesDecryptString(content.server_status)) then --停服
            Util:runForever(60, function( ... )
                self.helper:onDownloadFail()
            end)
            return
        end

        if _type == 1 then --更新大版本不用热更新
            qf.platform:updateGame({url= Util:getDesDecryptString(content.pkg_url)})
            if 1 == content.pkg_status then --建议更新大版本，进入游戏

                self:enterGame()
            else --强制更新，停留在此界面
            end
        else --不更新大版本，需要热更新
            if args.callback then
                args.callback()
            end
        end
    end

    content.updateGame = _callback
    local promit = GlobalPromit.new(content)
    promit:setPosition(self.win_size.width/2, self.win_size.height/2)

    self.layer:addChild(promit, 1, TAG_GLOBAL_PROMIT)
end

function HotUpdateMain:tipForAppStorePackageAlert(configlist, cb)
    if self.layer:getChildByTag(TAG_GLOBAL_PROMIT) then
        self.layer:removeChildByTag(TAG_GLOBAL_PROMIT)
    end
    local desc = tonumber(Util:getDesDecryptString(configlist.ios_download_type)) == 2 and GameTxt.to_update_content_txt_1 or GameTxt.to_update_content_txt_2
    local args = {desc = desc, data = configlist, typeStr = "updateAppStorePackage", callback = function (paras)
        if paras.status == "confirm" then
            --跳转到强制更新页面
            local url = Util:getDesDecryptString(configlist.ios_download_url)
            loga("【HotUpdateMain】 上架包 appstore 强更下载地址 = " .. url)
            if url ~= "" then
                qf.platform:showSchemeUrl({url = url, cb = function ()
                    
                end})
                if qf.device.platform == "ios" then
                    qf.platform:exitApplication()
                end
            end
        end
        if paras.status == "ignore" then
            if cb then
                cb()
            end
        end
    end}
    local promit = GlobalPromit.new(args)
    promit:setPosition(self.win_size.width/2, self.win_size.height/2)

    self.layer:addChild(promit, 1, TAG_GLOBAL_PROMIT)
end

function HotUpdateMain:tipForPackageAlert(configlist)
    if self.layer:getChildByTag(TAG_GLOBAL_PROMIT) then
        self.layer:removeChildByTag(TAG_GLOBAL_PROMIT)
    end

    local dealPackageUrl = function (url)
        local finalUrl = url
        if string.ends(finalUrl, ".plist") then
            finalUrl = string.format("itms-services://?action=download-manifest&url=%s", finalUrl)
        end
        return  finalUrl
    end

    local args = {desc = GameTxt.to_update_content_txt, typeStr = "updatePackage", callback = function ()
        --跳转到强制更新页面
        local url = dealPackageUrl(Util:getDesDecryptString(configlist.must_update_url))
        loga("【HotUpdateMain】 强更下载地址 = " .. url)
        if url ~= "" then
            qf.platform:showSchemeUrl({url = url, cb = function ()
                
            end})
            if qf.device.platform == "ios" then
                qf.platform:exitApplication()
            else
                cc.Director:getInstance():endToLua()
            end
        end
    end}
    local promit = GlobalPromit.new(args)
    promit:setPosition(self.win_size.width/2, self.win_size.height/2)

    self.layer:addChild(promit, 1, TAG_GLOBAL_PROMIT)
end

function HotUpdateMain:tipWithMainTain(args)
    args = args or {}
    args.typeStr = "maintain"
    local promit = GlobalPromit.new(args)
    promit:setPosition(self.win_size.width/2, self.win_size.height/2)

    self.layer:addChild(promit, 1, TAG_GLOBAL_PROMIT)
end

--增量更新提示
function HotUpdateMain:tipWithDeltaUpdate( args )
    local content = args.content
    local function _callback( _type ) 
        self.layer:removeChildByTag(TAG_GLOBAL_PROMIT, true)
        if _type == 1 then
            self:consureDeltaUpdate()
        else
            if self.img_loadding then
                self.img_loadding:setVisible(true)
                self.img_loadding_bg:setVisible(true)
            end
            self:cancelDeltaUpdate()
        end
    end
    content.updateGame = _callback
    local promit = GlobalPromit.new(content)
    promit:setPosition(self.win_size.width/2, self.win_size.height/2)
    self.layer:addChild(promit, 1, TAG_GLOBAL_PROMIT)
end
--在提示弹窗中取消增量更新
function HotUpdateMain:cancelDeltaUpdate( ... )
    if qf.platform:isEnabledWifi() then --wifi下后台更新
        self:downloadInback()
    else
        self:enterGame()
    end
end
--确认要进行增量更新
function HotUpdateMain:consureDeltaUpdate( ... )
    self:startDownloadUpdateFile()
end
--下载配置文件成功
function HotUpdateMain:downloadMd5FileSuccess( ... )
    local count = self.helper:getLastedFileCount() --获取剩余要更新文件数量
    local hot_type = self.helper:getHotUpdateType()
    if count == 0 or hot_type == 0 then --没有需要更新的文件或不需要更新
        self.helper:setDownloadFinish(true) --下载完成
        self:enterGame()
    elseif hot_type==1 or hot_type==2 then
        local is_need_tip = true
        local total_byte = self.helper:getLastedTotalByte()
        if hot_type == 2 then --强制更新
            is_need_tip = false
        else
            if total_byte < 2048 then
                is_need_tip = false
            end
        end

        self.current_total_count = total_byte
        self.current_count = 0

        

        if is_need_tip and not self.install then --需要提示用户有热更新
            local content = {
                ["type"] = 0
                , pkg_status = 1
                , des = string.format(GameTxt.hot_update_string_7, total_byte/1024)
            }
            self:tipWithDeltaUpdate({content=content})
        else
            self:startDownloadUpdateFile()
        end
    else
        local total_byte = self.helper:getLastedTotalByte()
        self.current_total_count = total_byte
        self.current_count = 0

        if hot_type == 2 then --强制更新
            self:startDownloadUpdateFile()
        else
            self:downloadInback({load_type=2})
        end
    end
end
--进入游戏之前，把缓存的lua文件全部清除
function HotUpdateMain:cleanLuaCache( ... )
    -- for k, _ in pairs(package.loaded) do
    --     if string.find(k, "src.") then
    --         package.loaded[k] = nil 
    --         package.preload[k] = nil 
    --     end
    -- end
end
--后台下载
function HotUpdateMain:downloadInback( args )
    args = args or {}
    local load_type = args.load_type or 2
    
    self.helper:resetCallback()
    self.helper:startDownload({load_type=load_type})

    self:enterGame()
end

function HotUpdateMain:enterGame( ... )
    if self.helper.config_list.differet_zip_path and self.helper.config_list.differet_zip_path ~= "" and tonumber(GAME_VERSION_CODE) >= 470 then
        self:startCommonResourcePackageUpdate()
    else
        self:finalEnterGame()
    end
end

function HotUpdateMain:finalEnterGame( ... )
    self:cleanLuaCache()

    self.helper:willEnterGame()
    self:setReivewFolder()
    -- 延迟1s进入游戏
    if self.pan_progress_tip then
        self.img_progress_bg:setVisible(false)
        self.bar_progress:setVisible(false)
        self.pan_progress_tip:setVisible(false)
        self.lbl_enter_game:setString(GameTxt.hot_update_string_4)
        self.lbl_enter_game:setVisible(true)
    end
    

    Util:runOnce(1.0, function( ... )
        self:requireLuaAnew()
        self:loadNecessaryMoudleOrGames()
        require "src.main"
    end)
end

--目前没有把大厅也作为子游戏，所以这边手动增加
function HotUpdateMain:loadNecessaryMoudleOrGames( ... )
    local is_review = 0 ~= Util:binaryAnd(tonumber(Util:getDesDecryptString(TB_SERVER_INFO.modules)), TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    if not is_review then return end
    local necessaryMoudleOrGames = {"game_hall"}
    --游戏部分
    for k,v in pairs(necessaryMoudleOrGames) do
        if not GAME_INSTALL_TABLE[v] and v == "game_hall" then
            table.insert(GAME_INSTALL_LIST,v)
            GAME_INSTALL_TABLE[v] = 1
            cc.UserDefault:getInstance():setStringForKey(SKEY.GAME_INSTALL_LIST ,json.encode(GAME_INSTALL_LIST))
        end
    end
end

function HotUpdateMain:requireLuaAnew( ... )
    -- body
    GAME_LANG = qf.platform:getLang()
    package.loaded["json"] = nil
    package.loaded["src.config.init"] = nil
    package.loaded["src.framework.init"] = nil
    package.loaded["src.res.GameRes"] = nil
    package.loaded["src.common.init"] = nil
    -- package.loaded["src.platform.init"] = nil
    local platform = qf.platform 
    package.loaded["src.core.Event"] = nil
    package.loaded["src.music.MusicPlayer"] = nil
    package.loaded["src.config.HotUpdateGames"] = nil
    package.loaded["src.modules.global.components.GlobalPromit"] = nil
    package.loaded["src.update.HotUpdateHelper"] = nil
    package.loaded["src.res."..GAME_LANG..".GameTxt"] = nil
    package.loaded["src.cache.init"] = nil

    require "json"
    require("src.config.init")
    require("src.framework.init")
    require("src.res.GameRes")
    require("src.common.init")
    -- require("src.platform.init")
    qf.platform = platform
    require("src.core.Event")
    require("src.music.MusicPlayer") --音乐
    require("src.config.HotUpdateGames")
    require("src.modules.global.components.GlobalPromit")
    require("src.update.HotUpdateHelper")
    GAME_LANG = qf.platform:getLang()
    qf.platform:getIfScreenFrame()
    require("src.res."..GAME_LANG..".GameTxt")
    require("src.cache.init")
end

--设置过审目录
function HotUpdateMain:setReivewFolder( ... )
    local is_review = 0 ~= Util:binaryAnd(tonumber(Util:getDesDecryptString(TB_SERVER_INFO.modules)), TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    self.is_review = is_review
    if not self.is_review then
        -- local review_folder = Util:getReivewFolder()
        -- if review_folder then
        --     cc.FileUtils:getInstance():addSearchPath(review_folder,true)
        -- end
    else --充质资源搜索目录
        self:resetResSearchPath()
    end

    --判断并记录当前的过审状态
    local status = cc.UserDefault:getInstance():getStringForKey(SKEY.REVIEW_STATUS,"100:false")
    local array_status = string.split(status,":")
    local version_code = tonumber(qf.platform:getRegInfo().version or 0)

    if checkint(array_status[1]) ~= checkint(version_code) or array_status[2] ~= tostring(is_review) then
        local value = checkint(version_code)..":"..tostring(is_review)
        cc.UserDefault:getInstance():setStringForKey(SKEY.REVIEW_STATUS,value)
        cc.UserDefault:getInstance():flush()
    end
end

--重置资源搜索目录，删除maiden_folder
function HotUpdateMain:resetResSearchPath( ... )
    -- body
    local search_paths = cc.FileUtils:getInstance():getSearchPaths()
    local reivew_folder = Util:getReivewFolder()
    if reivew_folder then
        for k,v in pairs(search_paths) do
            if v==reivew_folder then
                table.remove(search_paths,k)
                break
            end
        end
        cc.FileUtils:getInstance():setSearchPaths(search_paths)
    end
end

function HotUpdateMain:copyFileToLocal(relativeFilePath)
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

function HotUpdateMain:setResourceVersionCode( ... )
    self:copyFileToLocal(self:_getResourceVersionFilePath())
    --判断userdefault
    local currentResourceCode = cc.UserDefault:getInstance():getStringForKey("current-version-codezd", "")
    if currentResourceCode == "" then
        self:_setReourceViewCode()
    end
end

function HotUpdateMain:_getResourceVersionFilePath( ... )
    local filePath = "version"
    local updatePath = QNative:shareInstance():getUpdatePath() .. "/" .. filePath
    if io.exists(updatePath) then
        filePath = updatePath
    end
    return filePath
end

function HotUpdateMain:_setReourceViewCode()
    local versionData = cc.FileUtils:getInstance():getDataFromFile(self:_getResourceVersionFilePath())
    cc.UserDefault:getInstance():setStringForKey("current-version-codezd", versionData)
    cc.UserDefault:getInstance():flush()
    print("【【game】】 HotUpdateMain:_setReourceViewCode currentVersionData ---> " .. versionData)
end

function HotUpdateMain:main( ... )
    loga("HotUpdateMain:main")
    self:setResourceVersionCode()
    GAME_LANG = qf.platform:getLang()
    require("src.res."..GAME_LANG..".GameTxt")
    require("src.cache.init")

    -- if (qf and qf.device and qf.device.platform == "windows") then
        require("src.test2")
    -- end

    -- if ENVIROMENT_TYPE == 1 then
    --     print = function ( ... )
    --     end
    -- end


    qf.platform:getIfScreenFrame()
    self.helper:getGameList()
    self.helper:createUpdateFolder()
    self:setMaidenResSearchPath()
    self.helper:setResSearchPath()
    self:initUI()
end

--检查是否过审是否需要替换热更新界面资源
function HotUpdateMain:setMaidenResSearchPath( ... )
    -- body
    local status = cc.UserDefault:getInstance():getStringForKey(SKEY.REVIEW_STATUS,"100:false")
    local array_status = string.split(status,":")
    local version_code = tonumber(qf.platform:getRegInfo().version or 0)
    if checkint(array_status[1]) ~= checkint(version_code) or array_status[2] == "false" then
        self.is_review = false
        -- local reivew_folder = Util:getReivewFolder()
        -- if reivew_folder then
        --     cc.FileUtils:getInstance():addSearchPath(reivew_folder)
        -- end
    else
        self.is_review = true
    end
end


function HotUpdateMain:installGame(para)
    -- body
    self.helper:getGameList()
    for k,v in pairs(self.gameHelper)do
        if v.uniq == para.uniq then


            v:setInstallProgress(para)
            return
        end
    end
    if para.showProgress then
        return
    end
    local downloadfinish = function (uniq)
        -- body
        for k,v in pairs(self.gameHelper)do
            if v.uniq == uniq then
                v=nil
                table.remove(self.gameHelper,k)
                return
            end
        end
    end
    para.finish = downloadfinish
    para.isPkgDownload = Util:checkAGGameEnable()
    local gameHelper = require("src.update.HotUpdateGamePkgHelper").new()
    gameHelper:installGame(para)
    table.insert(self.gameHelper,gameHelper)
    
end

return HotUpdateMain.getInstance()