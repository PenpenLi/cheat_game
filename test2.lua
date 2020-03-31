module("test", package.seeall);
--[[
    更改device_id这个值会将对应的游客登陆产生游客 改变
    platform.lua中
    
]]--
--onKeyPressed

print("enter in test")
function test:onKeyPressed(code, event)
    -- print("asfdasdf")
    -- print("zxcvzxcv asdfasdf qwerqwer")
    require2("src.common.Util")
    require2("src.res.GameRes")
    require2("src.res.cn.GameTxt")

    -- if not ModuleManager then
    --     self:startup()
    -- end
    if (cc.KeyCode.KEY_F2 == code) then
        self:testCheatDebug()
    elseif (cc.KeyCode.KEY_F3 == code) then --测试gameUI功能
        -- self:testCoroutine()
        
        if self.mmid ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mmid)
            self.mmid = nil
        end
        require2("src.test")
    elseif (cc.KeyCode.KEY_F4 == code) then
        -- print("fffffffffffffffff 44444444444444")
        self:testNNGame()
    elseif (cc.KeyCode.KEY_Q == code) then --测试gameUI功能
        -- body
        self:testSettingLayer()
    elseif (cc.KeyCode.KEY_W == code) then --测试gameUI功能
        self:goToLoginLayer()
    elseif (cc.KeyCode.KEY_E == code) then --测试登陆界面ui
        -- testLoginFunc()
    elseif (cc.KeyCode.KEY_F3 == code) then --暂无

    elseif (cc.KeyCode.KEY_F4 == code) then --重连游戏
        self:testShopReview()
        -- testEnterGame()
    elseif (cc.KeyCode.KEY_F5 == code) then --登陆界面
        -- testLoginRoom()
    elseif (cc.KeyCode.KEY_F6 == code) then --登陆界面
        -- reconnectLoginRoom()
    elseif (cc.KeyCode.KEY_P == code) then --解散
        -- self:testAutoDismiss()
    elseif (cc.KeyCode.KEY_B == code) then
        self:backToBackGround()
        -- testBackLobby()
    elseif (cc.KeyCode.KEY_C == code) then --加入房间
        -- testJoinRoom()
    elseif (cc.KeyCode.KEY_V == code) then --创建房间
        -- self:testCreateRoom()
    elseif (cc.KeyCode.KEY_A == code) then --房间一键准备
        -- self:testPrepare()
    elseif (cc.KeyCode.KEY_R == code) then --一键注册
        -- self:autoRegister()
    elseif (cc.KeyCode.KEY_O == code) then --清空资源
        -- self:clearRecordLog()    
    elseif (cc.KeyCode.KEY_L == code) then --清空资源
        self:showLog()
--        self:showDebugView()
    elseif (cc.KeyCode.KEY_Y == code) then --测试函数
        self:test2Func()
    elseif (cc.KeyCode.KEY_Z == code) then --测试大厅中的单独UI功能
        self:testLayer()
    elseif (cc.KeyCode.KEY_S == code) then --初始化操作
    elseif (cc.KeyCode.KEY_G == code) then --进入某个游戏
        -- ModuleManager:removeExistView()
        -- self:testLogin()
        self:testMainGame()
        -- self:testLHDGame()
        -- self:testBRGame()
        -- self:testZJNGame()
        -- self:testNNGame()
        -- self:testZJHGame()
        -- self:testDDZGame()
        -- self:testBRNNGame()
        -- self:testBJLGame()
        -- self:testZJHHallView()
        -- cc.Director:getInstance():endToLua()
        -- self:testGlobalView()
        self:backToBackGround()
    end
end

function test:testCheatDebug3( ... )
    local schedEntry
    local scheduler = cc.Director:getInstance():getScheduler()
    schedEntry = scheduler:scheduleScriptFunc(
        function ()
            if LayerManager and LayerManager.Global then
                scheduler:unscheduleScriptEntry(schedEntry)
                self:testCheatDebug2()
            end
        end,
    1, false)
end

function test:initMainLoop( ... )
    self.mmid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
        if FetchConsoleCmd then
            local string = FetchConsoleCmd()
            if string then
                local cmd = loadstring(string)
                if cmd  then
                    xpcall(cmd, __G__TRACKBACK__)
                end
            end
        end
    end, 1, false)
end

local function unLoadPackage(tbl)
    for i, v in ipairs(tbl) do
        package.loaded[v] = nil
    end    
end

function require2( ... )
    package.loaded[...] = nil
    return require(...)
end

_G.require2 = require2
local accTbl = {
    {"QQQ001", "111111"},
    {"QQQ002", "111111"},
    {"QQQ003", "111111"},
    {"QQQ004", "111111"},
    -- {"QQQ005", "111111"},
    -- {"QQQ006", "111111"},
}


function loadPackages()
    require("src.config.init") --常量
    require("src.framework.init") -- 加载框架'
    require("src.core.Event") -- 加载事件部分
    require("src.core.LayerManager") -- 加载层管理
    require("src.common.init")
    require("src.platform.init")
    require("src.net.init")
    require("src.modules.PopupManager")
    require("src.modules.common.init") --ui通用接口
    require("src.modules.ModuleManager") --//加载模块
    require("src.music.MusicPlayer")--音乐
    require("src.config.HotUpdateGames")
    require("src.res.GameRes")
end

local C_Director = cc.Director:getInstance()
local C_WinSize = cc.Director:getInstance():getWinSize()
function test:init()
    local function onKeyCallback(code, event)
        self:onKeyPressed(code, event)
    end
    self.logPath = cc.FileUtils:getInstance():getWritablePath() .. "log/"
    self.logFileName = "log.txt"
    self._backGround = "show"
    local keyListener = cc.EventListenerKeyboard:create()
    keyListener:registerScriptHandler(onKeyCallback, cc.Handler.EVENT_KEYBOARD_RELEASED)


    local eventDispatcher = C_Director:getEventDispatcher()
    eventDispatcher:removeEventListenersForType(cc.EVENT_KEYBOARD);
    eventDispatcher:addEventListenerWithFixedPriority(keyListener, 1)

    -- self:initRecPrint()
    -- self:initPrint()
    -- self:initScheduleOnceFunc()
    -- self:beginScheduleTest()
    -- self:initRecordStr()
    self:initTRACKBACK()
    self:initMainLoop()
    -- self:onKeyPressed()
    self:testCheatDebug3()
    -- _G.G_IS_SHOW_DEPRECATED = false
end

function test:recordLog(...)
    local arg = {...}
    local str = ""
    local num = table.getn(arg)
    for i = 1, num do
        if i == num then
            str = string.format("%s%s", str, tostring(arg[i]))
        else
            str = string.format("%s %s", str, tostring(arg[i]))
        end
    end
    -- self._str
    self:writeFile(string.format("%s\n", str), self.logPath .. self.logFileName, "a")
end

function test:clearCache()
    self._cache = {}
end

function test:recordCache( ... )
    local arg = {...}
    local str = ""
    local num = table.getn(arg)
    for i = 1, num do
        if i == num then
            str = string.format("%s%s", str, tostring(arg[i]))
        else
            str = string.format("%s %s", str, tostring(arg[i]))
        end
    end
    self._cache[#self._cache + 1] = str
end

function test:initPrint()
    local _print = _G.print
    self._print = print
    local path = self.logPath
    local filepath = self.logPath .. self.logFileName
    lfs.mkdir(path)
    os.remove(filepath)
    io.writefile(filepath, "", "wb")
    _G.print = function (...)
         _print(...)
        self:recordLog(...)
    end
end

function test:initRecPrint()
    local _print = _G.print
    _G.print = function ( ... )
        _print(...)
        self:recordCache(...)
    end
end

function test:initTRACKBACK()
    _G.__G__TRACKBACK__ = function (msg)
        local errMsg = "----------------------------------------\n"
        local idx = string.find(msg, "...\"",1,true)
        if idx and idx ~= -1 then
            local infoTbl = debug.getinfo(2)
            if infoTbl then
                local a, b = string.find(msg, infoTbl.short_src, 1, true)
                msg = string.sub(msg, 1, a) .. infoTbl.source .. string.sub(msg, b, -1)
            end
        end
        errMsg = errMsg .. "LUA ERROR: " .. tostring(msg) .. "\n"
        local listTbl = printTraceback(nil, true)
        errMsg = errMsg .. table.concat( listTbl, "\n")
        errMsg = errMsg .. "\n----------------------------------------"
        print(errMsg)
        return msg
    end
end

function test:initRecordStr()
    local recordStr = {}
    for i = 1, 10 do
        recordStr[#recordStr + 1] = ""
    end
    self._recordStr = recordStr
end

function test:startup()
    loadPackages()
    local gameScene = require("src.core.GameScene").new()
    LayerManager:init(gameScene) -- init base layer and view event
    PopupManager:init()
    ModuleManager:init()
    for k, v in pairs(GAME_INSTALL_LIST) do
        local uniqName = v
        if v == "game_zhajinniu" then
            uniqName = "game_niuniu"
        end
        require("src.games." .. uniqName .. ".init")
    end
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    ModuleManager.global:show()
    -- ModuleManager.login:show()
    for k, v in pairs(GameRes.preLoadingImg)do
        cc.Director:getInstance():getTextureCache():addImageAsync(v, function() end)
    end

    local userData = loadUserCache()
    for k, v in pairs(userData) do
        Cache.user[k] = v
    end
    -- Cache.user = loadUserCache()
    Cache.Config.bull_zjh_room = {mount = 0}
    Cache.Config.bull_classic_room = {mount = 0}
    Cache.Config.bull_fry_room = {mount = 0}
    -- Cache.Config.bull_zjh_room = {}
end

local nullFunc = function ()
    -- print("nullFunc")
    return false
end

function test:showDebugView()
    local scene = C_Director:getRunningScene()
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 50))
    scene:addChild(colorLayer)
    local btn = ccui.Button:create()
    dump(btn:getContentSize())
    dump(btn:getSize())
    dump(btn:getPosition3D())
    btn:setTitleText("ABC")
    btn:setContentSize(cc.size(100, 100))
    btn:setSize(cc.size(100, 100))
    btn:setPosition(cc.p(100, 100))
    btn:setTitleFontSize(30)
    dump(btn:getContentSize())
    dump(btn:getSize())
    dump(btn:getPosition3D())
    colorLayer:addChild(btn)
    local scrollview = ccui.ScrollView:create()
    scrollview:setContentSize(cc.size(display.height, display.width/2))
    scrollview:setPosition(cc.p(100, 100))
    colorLayer:addChild(scrollview)
end
local function filter_spec_chars(s)
    
end


function test:test2Func()
    -- print("judge in game", ModuleManager:judegeIsIngameWithBorad())
    -- print("qwerqwerqwer", ModuleManager.__moduleTable["brniuniugame"])
    -- print("qwerqwer", ModuleManager:judgeIsInNormalGame())
    -- print("qwerqwerqwer", ModuleManager.__moduleTable["brniuniugame"])

    -- local t1 = socket.gettime()
    -- performWithDelay(LayerManager.Global, function ( ... )
    --     local t2 = socket.gettime()
    --     print(t2, t1, t2-t1)
    -- end, 1)    

    -- print(">>>>>", string.format("%.1f%%", 0))
    -- print("test2Func")
    -- for k, v in pairs( ModuleManager.__moduleTable ) do
    --     if v then
    --         print(k)
    --     end
        -- print( k, v )
    -- end    
        -- self.__moduleTable["game"] 
        -- or self.__moduleTable["texasbrgame"]
        -- or self.__moduleTable["brniuniugame"]
        -- or self.__moduleTable["sng"]
        -- or self.__moduleTable["texasgame"]
        -- or self.__moduleTable["game_zjh"]
        -- or self.__moduleTable["game_niuniu"]
        -- or self.__moduleTable["game_zjn"]
        -- or self.__moduleTable["DDZgame"]
        -- or self.__moduleTable["game_lhd"] 
    --游戏内不接受世界广播

    -- ModuleManager
    -- print(os.time())
    -- print(string.format("%d%%", checknumber(5)))
    -- print(string.format("2.提现收取金额的%d%支付通道手续费, 且账号内至少保留10元。", checknumber(5)))
    -- local paras = {uin = checknumber(Cache.user.uin), phone = "18620999580", device_id = "12010"}
    -- GameNet:send({cmd = 254,body = paras, callback = function(rsp)
    --     print("qwerqwer")
    -- end})

    -- qf.event:dispatchEvent(ET.MESSAGE_BOX, 
    -- {
    --     desc = "当前金币XXXX", 
    --     cbOk = function ( ... )
    --         print("xzcvzxcv")
    --         -- qf.event:dispatchEvent(ET.SHOP) --这里需要加一个弹窗提示
    --     end
    -- })
    -- self:writeFile("G:/a.txt", "123123")
    -- local view = ModuleManager.texasbrgame:getView()
    -- view:test()

    -- function trim(str)
    --     -- return (string.gsub(str, "\s+", ""))
    --     return (string.gsub(str, "%s+", ""))
    -- end
    -- local str = "⁂ € ™ ↑ → ↓ ⇝ √ ∞ ░ ▲ ▶我们"
    -- print(filter_spec_chars(str))

    -- print(trim("    asjdhf 爱上对方 好 asdhjfk   "))

    -- print("qwreqwer")
    -- GameNet:send({cmd = CMD.GET_MAIL_INFO,callback = function(rsp)
    --     print("rpsret ", rsp.ret)
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end
    --     printRspModel(rsp.model)
    -- end})

    -- GameNet:send({cmd=CMD.USER_INFO,body={mail_id=checknumber(paras.mailID)},callback = function (rsp)
    --     -- body
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end
    --     print("删除成功")
    -- end})

    -- require("src.games.game_hall.init")
    -- ModuleManager:removeExistView()
    -- local mainview = require2("src.games.game_hall.modules.main.MainView")
    -- local mainctrl = require2("src.games.game_hall.modules.main.MainController")
    -- TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW1 = true
    -- if ModuleManager and ModuleManager.gameshall then
    --     ModuleManager.gameshall:remove()
    -- end
    -- ModuleManager.gameshall = mainctrl:new()
    -- ModuleManager.gameshall:show()

    -- local sid = false
    -- print(type(sid))
    -- print(type(sid) == "number")
    -- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
    -- for i = 100, 1, -1 do
    --     print("zxvcasdf")
    -- end
    -- print(math.floor(3/1.3))
    -- cc.Director:getInstance():setDisplayStats(true)

    -- local function testSort(a,b)
    --     return tonumber(a.start_time)> tonumber(b.start_time)
    -- end
    local tbl = {2,3,4,1,5}
    table.remove(tbl, 1)
    dump(tbl)
    local mailList = {
        {rd = 0, id = 5},
        {rd = 1, id = 6},
        {rd = 0, id = 7},
        {rd = 1, id = 8},
        {rd = 0, id = 9},
    }
    table.sort(mailList, function (a, b)
        if a.rd == b.rd then
            return a.id > b.id
        else
            return a.rd < b.rd
        end
    end)

    dump(mailList)

    -- dump(tbl)
    --     for i = 5, 1, -1 do
    --         print(i)
    --     end
end

function test:testMainGame()
    self:_testGame("game_hall", "gameshall", "init")
end

function test:testSMainGame()
    self:_testGame("game_shall", "sgameshall", "init")
end

function test:testLHDGame()
    self:_testGame("game_lhd", "lhdgame", "init")
end

function test:reloadLHD()
    self:_testGame("game_lhd", "lhdgame", "init", true)
end

function test:testBRGame()
    self:_testGame("game_br", "texasbrgame", "init")
end

--这个是抢庄牛牛
function test:testNNGame()
    self:_testGame("game_niuniu", "kancontroller", "init")
end

function test:testBRNNGame()
    self:_testGame("game_brnn", "brniuniugame", "init")
end

function test:reloadBRNNGame()
    self:_testGame("game_brnn", "brniuniugame", "init", true)
end

function test:reloadBRGame()
    self:_testGame("game_br", "texasbrgame", "init", true)
end



function test:reloadNNGame()
    self:unloadGames("game_niuniu")
    require("src.games." .. "game_niuniu" .. "." .. "init")
end

--这个是扎金牛
function test:testZJNGame()
    self:_testGame("game_zhajinniu", "zhajinniugame", "init")
end

function test:testZJNGame2()
    ModuleManager.zhajinniugame.view:test()
end

--水果机
function test:testFruitMachine()
    self:_testGame("game_fruitmachine", "fruitMachineGame", "init")
end

--消消乐
function test:testXiaoxiaole()
    if LayerManager.XiaoXiaoLeLayer then
        for i, v in ipairs(LayerManager.XiaoXiaoLeLayer:getChildren()) do
            v:removeFromParent(true)
        end
    end
    if ModuleManager and ModuleManager.xiaoXiaoLeGame then
        ModuleManager.xiaoXiaoLeGame.view = nil
    end
    self:_testGame("game_xiaoxiaole", "xiaoXiaoLeGame", "init")
    -- self:testArmature2()
end

function test:testSolitaire()
    -- body
    -- if LayerManager.SolitaireLayer then
    --     for i, v in ipairs(LayerManager.SolitaireLayer:getChildren()) do
    --         v:removeFromParent(true)
    --     end
    -- end
    -- if ModuleManager and ModuleManager.solitaireGame then
    --     ModuleManager.solitaireGame.view = nil
    -- end

    if LayerManager.SolitaireLayer then
        for i, v in ipairs(LayerManager.SolitaireLayer:getChildren()) do
            v:removeFromParent(true)
        end
    end
    if ModuleManager and ModuleManager.solitaireGame then
        ModuleManager.solitaireGame.view = nil
    end
    self:_testGame("game_solitaire", "solitaireGame", "init")

end

--扎金花单人
function test:testZJHGame()
    self:_testGame("game_zjh", "zjhgame", "init")
end

function test:reloadZJH()
    self:_testGame("game_zjh", "zjhgame", "init", true)
end



function test:reloadNiuNiu()
    local arr = Cache.kanconfig.bull_classic_room_arr
    dump(arr)
    self:_testGame("game_niuniu", "kancontroller", "init", true)
    Cache.kanconfig.bull_classic_room_arr = arr
    dump(Cache.kanconfig)
end

--斗地主单人
function test:testDDZGame()
    self:_testGame("game_ddz", "DDZgame", "init")
end

--百家乐
function test:testBJLGame()
    ModuleManager:removeExistView()
    self:_testGame("game_bjl", "bjlgame", "init")
end

function test:testDDZGame2()
    ModuleManager.DDZgame:test()
end


function test:_testGame(path, controller, initPath, bReload)
    if bReload then
        if ModuleManager[controller].view then
            print("当前的 RELOAD VIEW 依然存在 请退到大厅后 再进行reload")
            self:testMainGame()
            Util:runOnce(0.1, function ( ... )
                self:_testGame(path, controller, initPath, true)
            end)
            return 
        end
    end

    if bReload then
    else
        ModuleManager:removeExistView()
    end
    if ModuleManager[controller] then
        ModuleManager[controller]:remove()
    end
    self:unloadGames(path)
    print("asfdasdrqwerzxcv")
    require("src.games." .. path .. "." .. initPath)
    print("zxcvasdfqwer")
    if bReload then
    else
        ModuleManager[controller]:show()
        print(">>>>>>>>>", ModuleManager[controller].view)
        print(">>>>>>>>>", ModuleManager[controller].view.test)
        if ModuleManager[controller].view and ModuleManager[controller].view.test then
            ModuleManager[controller].view:test()
        end
    end
end



--为了避免影响 先remove掉以前的layer 然后在增加下一个
function test:testLayer()
    if ModuleManager and ModuleManager.bindCard then
        ModuleManager.bindCard:remove()
    end

    require2("src.modules.bindCard.BindCardView")--绑卡
    local bindCardModel = require2("src.modules.bindCard.BindCardController")--绑卡
    ModuleManager.bindCard = bindCardModel:new()
    local ctrl = ModuleManager.bindCard
    ctrl:show()
    ctrl.view:showWithType(2)
end

function test:testSmallSettingLayer()
    require2("src.modules.common.SmallSettingView")--绑卡
    local view = require2("src.modules.common.SmallSettingView")--绑卡
    view:show()
end

function test:testSafeBoxLayer()
    local SafeBox = require2("src.modules.safeBox.ReviewSafeBoxView")--绑卡
    local SafeBoxView = SafeBox.new(paras)
    SafeBoxView:show(paras)
end

function test:testDownloadImg()
    -- dump(qf.platform:getRegInfo())
    -- print(RESOURCE_HOST_NAME)

    dump(Cache.Config.banner_pic)
    local hall = ModuleManager.gameshall
    local view = hall:getView()
    -- Cache.Config.banner_pic[2] = clone(Cache.Config.banner_pic[1])
    -- Cache.Config.banner_pic[3] = clone(Cache.Config.banner_pic[1])
 
    local len = #Cache.Config.banner_pic
    local picList = view.slidePage:getChildren()
    local picLen = #picList
    for i = 1, len - picLen do
        local picTemp = picList[1]:clone()
        view.slidePage:addPage(picTemp)
    end
    picList = view.slidePage:getChildren()
    picLen = #picList
    local cb = function (node, args)
        node:setTouchEnabled(true)
        addButtonEvent(node, function ( ... )
            print(args.copy_url)
        end)
        local imgUrl = args.pic_path
        qf.downloader:execute(imgUrl, 10,
            function(path)
                if imgUrl == nil then return end
                node:loadTexture(path)
            end,
            function()
            end,
            function()
            end
        )
    end
    for i, v in ipairs( picList ) do
        local node = v:getChildByName("Image_11")
        cb(node, Cache.Config.banner_pic[i])
    end

    view.slidePage:stopAllActions()
    view.slidePage:getCurPageIndex()
    schedule(view.slidePage, function ()
        local curPage = view.slidePage:getCurPageIndex()
        print(curPage)
        if curPage == picLen-1 then
            view.slidePage:scrollToPage(0)
        else
            view.slidePage:scrollToPage(curPage + 1)
        end
    end, 2)


    -- local function pageViewEvent(sender, eventType)  
    --     -- print(eventType)
    --     if eventType == ccui.PageViewEventType.turning then  
    --         local pageView = sender
    --         print("qwercxvasdf")
    --         -- local pageInfo = string.format("page %d " , pageView:getCurPageIndex() + 1)  
    --         -- logd(" ---  pageViewEvent ---",pageInfo) 
            
    --         -- if pageView:getCurPageIndex()==3 then
    --         --     ccui.Helper:seekWidgetByName(self.beginnersGuide,"btn_go_new"):setVisible(true)
    --         --     ccui.Helper:seekWidgetByName(self.beginnersGuide,"btn_go_game"):setVisible(true)
    --         -- else  
    --         --     ccui.Helper:seekWidgetByName(self.beginnersGuide,"btn_go_new"):setVisible(false)
    --         --     ccui.Helper:seekWidgetByName(self.beginnersGuide,"btn_go_game"):setVisible(false)
            
    --         -- end
             
    --         -- if  pageView:getCurPageIndex()==1 then
    --         --     self:pateTwoAction()
    --         -- else
    --         --     self:resetPageTwo()
    --         -- end
    --     end  
    -- end



    -- addButtonEvent(view.slidePage, 
    --     function() end, 
    --     function() print("qwerxczvwrzxvc") end
    -- )

    -- view.slidePage:setIndicatorEnabled(true) 
    -- view.slidePage:addEventListener(pageViewEvent)


end



function test:testOldActivityLayer()
    if ModuleManager and ModuleManager.activity then
        ModuleManager.activity:remove()
    end
    require2("src.modules.activity.ActivityView")--绑卡
    local model = require2("src.modules.activity.ActivityController")--绑卡
    ModuleManager.activity = model:new()
    local ctrl = ModuleManager.activity
    ctrl:show()
    ctrl.view:enterCoustomFinish()
end

function test:testGlobalView()
    qf.event:dispatchEvent(ET.GLOBAL_HANDLE_PROMIT,{body = {type = 1,des = "123412341234"},type = 1}) --测试温馨提示
    -- qf.event:dispatchEvent(ET.INSTALL_GAME_POP, {size = 123, unit="M", name = "123123", method = "show"}) --测试下载提示
    -- qf.event:dispatchEvent(ET.MESSAGE_BOX, {desc = GameTxt.no_gold_tips})
end

function test:testMessageBoxLayer()
    local MessageBox = require2("src.modules.common.messageBox.ReviewMessageBoxView")
    local parasDownLoad = {
            richDesc = {
                {desc = "扎金花", color = cc.c3b(241, 204, 80)},
                {desc = "需要下载，请在wifi环境下进行下载，是否进行下载？", color = cc.c3b(102, 147, 225)}
            }
        }
        
    local paras = {}
    local MessageBoxView = MessageBox.new(parasDownLoad)
    MessageBoxView:show(parasDownLoad)

end


function test:testBindCardLayer() --测试绑定银行卡
    local BindCard = require2("src.modules.common.bindCard.BindCardView")
    local BindCardView = BindCard.new()
    BindCardView:show()
    BindCardView:test()
end

function test:testMainTainView() --测试维护公告
    local Maintain = require2("src.modules.common.MainTainView")
    local paras =  {desc = "爱上的看法合适的发生的发哈世界的繁华卡水电费杰卡斯地方黑金卡水电费和卡就是的发生地方哈精神科大夫哈市地方", begintime = "123123", endtime = "123123"}
    local view = Maintain.new(paras)
    view:show()
    -- qf.event:dispatchEvent(ET.MAIN_TAIN, {desc = "爱上的看法合适的发生的发哈世界的繁华卡水电费杰卡斯地方黑金卡水电费和卡就是的发生地方哈精神科大夫哈市地方", begintime = "123123", endtime = "123123"})
end

-- function test:testBindCardLayer2() --测试绑定银行卡2
--     local layer = self:_testLayer("src.modules.common.bindCard.BindCardView")
--     layer:showWithType(2)
-- end

function test:testMailView() --测试绑定银行卡2
    local str = [==[
            测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2测试绑定银行卡2
    ]==]
    Cache.mailInfo._mailList = {
        {time = 0, notiTxt = "123123", content = str}
    }
    self:_testLayer4("src.modules.common.ReviewMailView")
end

function test:testGuideView()
    self:_testLayer4("src.modules.common.GuideView")
end

function test:testDebugView()
    self:_testLayer4("src.modules.common.DebugView")
end

function test:testExchangeView()
    local Exchange = require2("src.modules.exchange.exchangeView")
    local ExchangeView = Exchange.new(paras)
    -- -- ExchangeView:show()
    -- local body = {}
    -- body.uin = Cache.user.uin
    -- body.bind_type = 1 --1 = 银行卡

    -- GameNet:send({cmd=CMD.GET_BINDING_CONFIG,body=body,timeout=nil,callback=function(rsp)
    --     loga("updateBankPanel rsp "..rsp.ret)
    --     if rsp.ret ~= 0 then
    --     else
    --         print("XZCVVVVVVVVVVVV")
            -- printRspModel(rsp.model)
            -- dump(paras)
            -- ExchangeView:showBankPanel(rsp)
            ExchangeView:show()
    --     end
    -- end})
    -- self:_testLayer4("src.modules.exchange.exchangeView")
end

function test:testUnlessView()
    self:_testLayer4("src.modules.global.components.FirstGame")
end

function test:_testLayer4(path, paras)
    local view = require2(path)
    local _view = view.new(paras)
    _view:show(paras)
end

--1. 对root 节点进行全删除
--2. 对root 节点进行查找指定节点 然后进行自删除
--3. 对root 节点进行查找指定节点 然后调用对应的节点方法 进行删除
function test:_testLayer(path)
    ModuleManager:removeExistView()
    local moduleLayer = require2(path)
    local root = moduleLayer:getRoot()
    --只是简单的去掉而已 不调用对应节点的关闭方法
    for i, v in ipairs(root:getChildren()) do
        if v.__cname == moduleLayer.__cname then
            v:removeFromParent(true)
        end
    end
    local moduleView = moduleLayer.new()
    return moduleView
end

function test:_testLayer2(path)
    local moduleLayer =  require2(path)
    local root = moduleLayer:getRoot()
    root:removeAllChildren()
    local moduleView = moduleLayer.new()
    return moduleView
end

function test:_testLayer3(path, closefunc)
    local moduleLayer =  require2(path)
    local root = moduleLayer:getRoot()
    --只是简单的去掉而已 不调用对应节点的关闭方法
    for i, v in ipairs(root:getChildren()) do
        if v.__cname == moduleLayer.__cname then
            if closefunc then
                v[closefunc]()
            else
                if v.super.__cname == "View" then
                    v:removeFromParent(true)
                elseif v.super.__cname == "PopupWindow" then
                    v:close()
                end      
            end
        end
    end
    local moduleView = moduleLayer.new()
    return moduleView
end

function  test:testChangePwdLayer( ... )
    CommonWidget.ComboList = require2("src.modules.common.widget.comboList")
    local ChangePwd = require2("src.modules.common.changePwd.ReviewChangePwdView")
    local paras = {actType = 1, showType = 6}
    local changePwdView = ChangePwd.new(paras)
    changePwdView:show(paras)
end

function  test:goToLoginLayer()
    print("goToLoginLauer>>>>>")
    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    cc.UserDefault:getInstance():setStringForKey("loginBody", "")
    cc.UserDefault:getInstance():flush()
    qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)

    -- PopupManager:removeAllPopup()
    -- ModuleManager:removeByCancellation()
    -- game.cancellationLogin()
end

function test:testAgreementLayer() --测试协议页面
    -- local layer = require2("src.modules.common.agreement.NewAgreementView")
    -- local layerView = layer.new()
    -- layerView:show()

    qf.event:dispatchEvent(ET.AGREEMENT, {cb = function ()
        -- self.root:setVisible(true)
    end})

end

function test:testAcitivityLayer() --测试活动页面
    -- print("testAcitivityLayer")
    -- GameNet:send({cmd = CMD.NEW_GONGGAO,callback = function(rsp)
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end
    --     Cache.activityInfo:refreshNoticeData(rsp.model)
    -- end})

    -- GameNet:send({cmd = CMD.ALL_ACTIVITY,callback = function(rsp)
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end
    --     Cache.activityInfo:refreshData(rsp.model)
    --     ModuleManager:removeExistView()
    --     local NewAcitivy = require2("src.modules.common.activity.NewActivityView")
    --     local NewAcitivyView = NewAcitivy.new(paras)
    --     NewAcitivyView:show()
    -- end})
        local NewAcitivy = require2("src.modules.common.activity.ReviewNewActivityView")
        local NewAcitivyView = NewAcitivy.new(paras)
        NewAcitivyView:show()
end

function test:testBREndGameLayer()
    ModuleManager:removeExistView()
    require2("src.games.game_br.init")
    require2("src.games.game_br.modules.game.BrGameView")
    require2("src.games.game_br.modules.game.BrGameController")
    local brResult = require2("src.games.game_br.modules.game.brcomponents.BrResult")
    local resultLayer = brResult.new()
    resultLayer:setName("brResult")
    if LayerManager.PopupLayer:getChildByName("brResult") then
        LayerManager.PopupLayer:removeChildByName("brResult")
    end
    LayerManager.PopupLayer:addChild(resultLayer)
end

function test:testLHDEndGameLayer()
    ModuleManager:removeExistView()
    require2("src.games.game_lhd.init")
    require2("src.games.game_lhd.modules.game.LHDGameView")
    require2("src.games.game_lhd.modules.game.LHDGameController")
    local brResult = require2("src.games.game_lhd.modules.game.lhdcomponents.LHDGameEnd")

    if LayerManager.GameLayer:getChildByName("lhdResult") then
        LayerManager.GameLayer:removeChildByName("lhdResult")
    end
    local resultLayer = brResult.new()
    resultLayer:setName("lhdResult")
    resultLayer:test()
end


function test:testGlobalViewTest()
    -- ModuleManager.global:remove()
    require2("src.modules.global.GlobalView")
    ModuleManager.global = require2("src.modules.global.GlobalController")
    ModuleManager.global:show()
    ModuleManager.global:getView():boradcastInit()
    ModuleManager.global:getView():showBoradcastTxt({})
end

function test:testPaomadengTest()
    require2("src.modules.global.GlobalView")
    ModuleManager.global = require2("src.modules.global.GlobalController")
    ModuleManager.global:show()
    -- broadcastPos = {x = 0, y = -150}
    -- qf.event:dispatchEvent(ET.SETBROADCAST,broadcastPos)

    ModuleManager.global:getView():boradcastInit()
    -- ModuleManager.global:getView():showBoradcastTxt({new_content  = "qweqwer", contents = true})
    ModuleManager.global:getView():showBoradcastTxt({level = 400, content  = "qweqwer", nick = "WERQWER"})
    -- qf.event:dispatchEvent(ET.SETBROADCAST,{x=0,y=-30})
    -- local broadcastPos = {x = 50, y = -200} 
end

function test:testGlobalToast()
    qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = "1212sfsfd"})
end

function test:testProto()
    -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "123123123123"})
    local body = {}
    local key = "bg+t%je3i0wd=9%@p@=-miicg&1!%4#n"
    body.phone = "18620999580"
    body.code = "1231"
    body.zone = "86"
    body.sign = QNative:shareInstance():md5(key.."|"..body.phone.."|"..body.code.."|"..body.zone)
    body.new_password = "2323412"
    GameNet:send({cmd=CMD.SAFE_CHANGE_PASSWORD,body=body,timeout=nil,callback=function(rsp)
        loga("changed safeBox pwd rsp "..rsp.ret)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "设置安全密码失败"})
        else
            -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "设置安全密码成功"})
        end
    end})
end

function test:testArmature()

    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(XXLRes.greatEfx)
    local turnicon = ccs.Armature:create("duihuan")
    self.exchangeBtn:addChild(turnicon, 0)
    turnicon:setPosition(self.shopBtn:getContentSize().width * 0.5, self.shopBtn:getContentSize().height * 0.5)
    turnicon:getAnimation():playWithIndex(0)

    -- LayerManager.PopupLayer:addChild(resultLayer)
end
function test:testArmature2()
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    local res = "game_xiaoxiaole/armature_anim/great/great.ExportJson"
    armatureDataManager:addArmatureFileInfo(res)
    local name = "great"
    local face = ccs.Armature:create(name)
    face:getAnimation():playWithIndex(0)
    LayerManager.XiaoXiaoLeLayer:addChild(face)
    -- ModuleManager
end

function test:testPersonView( ... )
    -- CommonWidget.ComboList = require2("src.modules.common.widget.comboList")
    local layer = require2("src.modules.personal.ReviewPersonalView")
    local layerView = layer.new()
    layerView:show()
    layerView:test()
end

function test:testCustomerServices( ... )
    local CustomerServiceChatView = require2("src.modules.customerservice.CustomerServiceChat")
    local CustomerServiceChat = CustomerServiceChatView.new(paras)
    CustomerServiceChat:show()
end

function test:testAgencyAlertView( ... )
    local AgencyAlert = require2("src.modules.customerservice.AgencyAlert")
    local AgencyAlert = AgencyAlert.new({data = {
        textInfo = {
            msg = "测试文本大师的卡萨丁静安寺大剧盛典阿世纪大厦"
        },
        proxy_data_id = 0
    }})
    AgencyAlert:show()
end

function test:testOverRoomMaxLimit( ... )
    qf.event:dispatchEvent(ET.OVER_ROOM_MAX_LIMIT, {confirmCallBack = function ( ... )
        qf.event:dispatchEvent(ET.QUICK_START_GAME)
    end})
end

function test:testShopLayer() --测试协议页面
    -- local layer = self:_testLayer("src.modules.shop.ShopView")

    -- ModuleManager:removeExistView()
    local layer = require2("src.modules.shop.ReviewShopView")
    local layerView = layer.new()
    layerView:show()
end

function test:testShopReview()
    local view = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newShop)
    if view then
        view:refreshView()
    end
end

function test:testCustomLayer() --测试协议页面
    -- ModuleManager:removeExistView()
    local layer = require2("src.modules.custom.CustomView")
    local layerView = layer.new()
    layerView:show()
end


function test:testDDZSettingLayer() --测试协议页面
    -- local layer = self:_testLayer("src.games.game_ddz.modules.game.components.DDZSetting")
    print("zxcvzxcv")
    local ChangePwd = require2("src.games.game_ddz.modules.game.components.DDZSetting")
    -- local paras = {actType = 1, showType = 6}
    local changePwdView = ChangePwd.new(paras)
    changePwdView:show(paras)
end

function test:testRuleLayer()
    local ChangePwd = require2("src.modules.common.GameRuleView")
    local paras = {GameType = GAME_DDZ}
    local changePwdView = ChangePwd.new(paras)
    changePwdView:show(paras)
end

function test:testSettingLayer()
    -- ModuleManager:removeExistView()
    local layer = require2("src.modules.setting.ReviewSettingView")
    local layerView = layer.new()
    layerView:show()
end

function test:testNiuNiuHallView()
    print("qwerqqwer123412")
    require2("src.res.GameRes")
    -- LayerManager.Global:setVisible(false)
    ModuleManager:removeExistView()
    self:_testGame("game_niuniu", "niuniuhall", "init")
end

function test:testZJHHallView()
    print("qwerqqwer123412")
    require2("src.res.GameRes")
    -- LayerManager.Global:setVisible(false)
    ModuleManager.zjhhall:remove()
    self:_testGame("game_zjh", "zjhhall", "init")
end

function testJson()
    local tbl = {a = 1, b = 2}
    for i = 1, 300 do
        tbl[i] = i 
    end
    local jStr = json.encode(tbl)
    io.writefile("jsontest.json", jStr)
end

local function checkLuaFile(fname)
    return string.find(fname, ".lua")
end

local function attrdir(path)
    local fileList = {}
    local _attrdir
    _attrdir = function (_path)
        for file in lfs.dir(_path) do
            if file ~= "." and file ~= ".." then
                local f = _path.. '/' ..file
                local attr = lfs.attributes (f)
                if attr.mode == "directory" then
                    _attrdir(f)--如果是目录，则进行递归调用
                else
                    if checkLuaFile(file) then
                        fileList[#fileList + 1] = _path ..  '/' .. file
                    end
                end
            end
        end
    end
    _attrdir(path)
    return fileList
end


function test:unloadGames(path)
    print("unloadGames")
    local filelist = attrdir("../src/games/" .. path)
    print("1234123421341234")
    dump(filelist)
    function require2( ... )
        package.loaded[...] = nil
        return require(...)
    end

    for i, v in ipairs(filelist) do
        local iSrt = string.find(v, "src")
        local filepath = string.sub(v, iSrt, -5)
        filepath = string.gsub(filepath, "/", ".")
        print("filepath >>>>>>>>>>>>>>>>>", filepath)
        package.loaded[filepath] = nil
    end
end

test:init()

function test:readFile(fileName)
    print(">>>>>>>>>>>>>>>>>", fileName)
    local str = ""
    if io.exists(fileName) then
        local file = io.open(fileName, "r")
        for line in file:lines() do  
            str = str..line
        end
        file:close()
    end
    return str
end

function test:writeFile(str, filename, mode)
    local file = io.open(filename, mode or "a")
    file:write(str)
    file:close()
end

-- function writeFile(str, filename, mode)
--     -- if qf.device.platform ==  "windows" then
--     -- end
-- end

function test:autoLogin(loginDel)
    self._loginDel = loginDel
    if cc.PLATFORM_OS_WINDOWS == G_Platform and test._autoLoginFlag then
        local idx = checknumber(test.getCurPlayerAccIdx())
        if idx > #accTbl then
            idx = 1
        elseif idx == 0 then
            idx = 1
        end
        loginDel.studio.EditBox_Acc:setText(accTbl[idx][1])
        loginDel.studio.EditBox_Pwd:setText(accTbl[idx][2])
        if idx >= #accTbl then
            idx = 1
        else
            idx = idx + 1
        end
        test.setCurPlayerAccIdx(idx)
        performWithDelay(loginDel, function ()
            loginDel:doButtonLoginClick()
        end, 0.01)
        test._autoLoginFlag = false
    end
end

function test:showLog()
    if qf.device.platform ==  "windows" then
        self:showLogTxt()
    else
        self:showDebugView()
    end
end

function test:showLogTxt()
    -- local logName = self.logFileName
    -- local file = string.format("%s.txt", logName)
    local file = self.logPath .. self.logFileName
    os.execute("cmd /c" .. file)
end

function test:testChip()
    -- local del  = LayerManager.PopupLayer
    -- local del  = C_Director:getRunningScene()
    local del  = LayerManager.Global
    local codeLayer = del:getChildByName("vertifyCodeLayer")
    if codeLayer and tolua.isnull(codeLayer) == false then
        print("remove codeLayer")
        codeLayer:removeFromParent()
    end
    print("qwerqwerxcvasdfqwer")
    local scene = C_Director:getRunningScene()
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    colorLayer:setContentSize(cc.size(C_WinSize.width, C_WinSize.height))
    colorLayer:setName("vertifyCodeLayer")
    colorLayer:setOpacity(0)
    del:addChild(colorLayer, 9999)
    local chipCls = require2("src.common.Chip")
    local createChip = function (color, i, dy, number)
        number = number or 5000
        local chip = chipCls.new({color = color, number = number})
        chip:setPosition(cc.p(460 + 10 * i,600 + dy))
        colorLayer:addChild(chip)
        chip:setScale(0.5)
    end

    for i = 1, 100 do
        createChip(CHIPCOLOR.RED, i, 50, 100)
        createChip(CHIPCOLOR.BLUE, i, 150, 10)
        createChip(CHIPCOLOR.PURPLE, i, 250, 50)
        createChip(CHIPCOLOR.GREEN, i, 350, 1)
        createChip(CHIPCOLOR.ORANGE, i, 450, 500)
    end

        -- createChip(CHIPCOLOR.RED, 1, 50, 10000)
        -- createChip(CHIPCOLOR.BLUE, 1, 150, 1000)
        -- createChip(CHIPCOLOR.PURPLE, 1, 250, 5000)
        -- createChip(CHIPCOLOR.GREEN, 1, 350, 100)
        -- createChip(CHIPCOLOR.ORANGE, 1, 450, 50000)


    -- local fnt = cc.LabelBMFont:create(300, chipFntPath)
    -- local size = chip:getContentSize()
    -- --1位数
    -- fnt:setPosition(cc.p(size.width/2, size.height/2 + 5))
    -- chip:addChild(fnt)
    -- chip:setScale(0.5)
end

function test:testSkeleteon()
    local del  = LayerManager.Global
    local codeLayer = del:getChildByName("skeletonLayer")
    if codeLayer and tolua.isnull(codeLayer) == false then
        codeLayer:removeFromParent()
    end
    local scene = C_Director:getRunningScene()
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    colorLayer:setContentSize(cc.size(C_WinSize.width, C_WinSize.height))
    colorLayer:setName("vertifyCodeLayer")
    colorLayer:setOpacity(255)
    del:addChild(colorLayer, 9999)

    -- local skeletonNode = sp.SkeletonAnimation:create("share/animation/goblin/goblins.json", "share/animation/goblin/goblins.atlas", 1.5)
    local skeletonNode = sp.SkeletonAnimation:create("share/animation/girl/hlssmheguan.json", "share/animation/girl/hlssmheguan.atlas", 1.5)
    skeletonNode:setAnimation(0, "animation", true)
    skeletonNode:setSkin("default")

    -- skeletonNode:setScale(0.)
    -- local windowSize = cc.Director:getInstance():getWinSize()
    -- skeletonNode:setPosition(cc.p(dlgSize.width / 2, 20))
    -- self._detailDlg:addChild(skeletonNode)

    -- local jsonName = "share/animation/girl/hlssmheguan.json"
    -- local atlasName = "share/animation/girl/hlssmheguan.atlas"

    -- local skeletonNode = sp.SkeletonAnimation:create(jsonName, atlasName, 1.5)
    -- skeletonNode:setAnimation(0, "walk", true)
    -- skeletonNode:setSkin("goblin")
    -- skeletonNode:setScale(0.25)
    local windowSize = cc.Director:getInstance():getWinSize()
    skeletonNode:setPosition(cc.p(windowSize.width / 2, 20))
    colorLayer:addChild(skeletonNode)

end

function test:testVertifyCode()
    -- local del  = LayerManager.PopupLayer
    -- local del  = C_Director:getRunningScene()
    local del  = LayerManager.Global
    local codeLayer = del:getChildByName("vertifyCodeLayer")
    if codeLayer and tolua.isnull(codeLayer) == false then
        print("remove codeLayer")
        codeLayer:removeFromParent()
    end
    print("qwerqwerxcvasdfqwer")
    local scene = C_Director:getRunningScene()
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    colorLayer:setContentSize(cc.size(C_WinSize.width, C_WinSize.height))
    colorLayer:setName("vertifyCodeLayer")
    colorLayer:setOpacity(255)
    del:addChild(colorLayer, 9999)

    local btn = ccui.Button:create("res/cn/ui/global/close.png","","")

    --必须放一个图片上去
    btn:setContentSize(cc.size(100, 100))
    btn:setSize(cc.size(100, 100))
    btn:setPosition(cc.p(C_WinSize.width- 100, C_WinSize.height - 100))
    btn:setTitleFontSize(30)
    btn:setTouchEnabled(true)
    btn:setEnabled(true)
    colorLayer:addChild(btn)
    addButtonEvent(btn, function ()
        local codeLayer = del:getChildByName("vertifyCodeLayer")
        if codeLayer and tolua.isnull(codeLayer) == false then
            codeLayer:removeFromParent()
        end
    end)

    -- local btn = ccui.Button:create("res/cn/ui/chat/chat_send_bt.png","","")

    --必须放一个图片上去
    -- btn:setPosition(cc.p(C_WinSize.width/2, C_WinSize.height/2))
    -- btn:setTouchEnabled(true)
    -- btn:setEnabled(true)
    -- colorLayer:addChild(btn)
    local str = "独步成双一见双雕"
    -- addButtonEvent(btn, function ()
    --     print(#str)
    --     print(Util:UTF8length(str))
    --     dump(string.utf8List(str))
    --     local r = math.random
    --     local list = string.utf8List(str)
    --     for i, v in ipairs(list) do
    --         local text= ccui.Text:create(v, GameRes.font1,50)
    --         text:setRotation(r(0, 360))
    --         text:setColor(cc.c3b(r(0,255), r(0,255), r(0,255)))
    --         colorLayer:addChild(text)
    --         text:setPosition(cc.p(r(100, C_WinSize.width-100), r(100, C_WinSize.height-100)))
    --     end
    -- end)

    local r = math.random
    local rColor = function()
        return cc.c3b(r(0,255), r(0,255), r(0,255))
    end
    local rfColor = function ( ... )
        return cc.c4f(math.random(),math.random(),math.random(),1)
    end
    local rPos = function ()
        return cc.p(r(100, C_WinSize.width-100), r(100, C_WinSize.height-100))
    end
    local list = string.utf8List(str)
    for i, v in ipairs(list) do
        local text= ccui.Text:create(v, GameRes.font1,50)
        text:setRotation(r(0, 360))
        text:setColor(rColor())
        colorLayer:addChild(text)
        text:setPosition(rPos())
        text:setTouchEnabled(true)
        addButtonEvent(text, function ( ... )
            print(">>>>>>>>>>>>>>>", v)
        end)
    end

    --颜色必须用浮点型来使用 不然没有效果
    local drawNode = cc.DrawNode:create();
    drawNode:setPosition(cc.p(0,0))
    drawNode:setAnchorPoint(0,0)
    for i = 1, 10 do
        drawNode:drawSegment(rPos(), rPos(), r(1, 2), rfColor())
        drawNode:drawDot(rPos(), r(3, 5), rfColor())
    end
    colorLayer:addChild(drawNode)

    Util:addNormalTouchEvent(colorLayer, function(method, touch, event)
        if method == "began" then
            return true
        end
    end)
end

local tbl = {
    IsRightTime                = -1,
    _visitorFlag               = true,
    account_bind_status        = 0,
    anti_stealth               = 0,
    cnd_path                   = "cdn2-bullfight.quyifun.com",
    code_money                 = 0,
    contest_credit             = 0,
    cumulate_login_reward      = 0,
    custom_qq                  = "123456789",
    custom_tel                 = "18888888888",
    custom_url                 = "http://bull.firepoker.vip/media/erweima/cus",
    day                        = 4,
    day_reward_end_time        = "",
    day_reward_start_time      = "",
    decoration                 = 0,
    defaultGame                = "game_zjh",
    diamond                    = 0,
    downGameList = {
        {
            name   = "1",
            status = "0"
        },
        {
            name   = "2",
            status = "0"
        },
        {
            name   = "6",
            status = "0"
        },
        {
            name   = "3",
            status = "0"
        },
        {
            name   = "8",
            status = "0"
        }
    },
    down_game_list             = "1:0|2:0|6:0|3:0|8:0",
    event_exit_reason          = 0,
    event_id                   = 0,
    first_recharge_flag        = 1,
    first_recharge_url         = "",
    game_list_type             = 2,
    gift_card_sum              = 0,
    gifts = {
    },
    gold                       = 2464.8,
    hiding                     = 0,
    invite_code                = "@LFR3",
    isFirstgame                = true,
    is_be_collected_player     = false,
    is_beauty                  = false,
    is_bind_phone              = "",
    is_collect_player          = false,
    is_friend                  = false,
    is_new_reg_user            = 0,
    is_new_user                = 1,
    key                        = "pass_dda2e833-718f-4cae-8f9a-f99e513148c8",
    last_week_beauty_rank      = -1,
    left_time                  = -1,
    level                      = 0,
    login_type                 = 1,
    lose                       = 0,
    max_history_cards = {
    },
    max_history_win_chips      = 116400,
    mtt_info = {
    },
    nick                       = "谦虚的丫丫",
    night_reward_end_time      = "",
    night_reward_start_time    = "",
    old_roomid                 = 0,
    online                     = 0,
    play_over_times            = 0,
    play_times                 = 0,
    pokerface                  = 0,
    portrait                   = "IMG4",
    promotion_code             = "",
    reConnect_status           = false,
    remain_time                = 198192,
    remain_times               = 0,
    room_type                  = 0,
    ruju_prob                  = 0,
    safe_password              = 0,
    score                      = 0,
    send_gifts = {
    },
    sex                        = 1,
    show                       = 1,
    show_cumulate_login_or_not = 1,
    show_lucky_wheel_or_not    = 1,
    show_passwd_set            = 0,
    show_promotion             = 0,
    show_rank_or_not           = 3,
    show_third_pay_or_not      = 0,
    sng_info = {
        first_place  = 0,
        match_count  = 0,
        second_place = 0,
        third_place  = 0
    },
    start_time                 = 1543458257,
    tanpai_prob                = 0,
    title                      = "展露头角",
    turn_os_time               = 1543458257,
    uin                        = 1000191,
    upGameList = {
    },
    up_game_list               = "",
    view_times                 = 0,
    vip_days                   = 0,
    vip_level                  = 0,
    win                        = 0,
    win_prob                   = 0,
}
function test:loadUserCache()
    return clone(tbl)
end

--切后台
function test:backToBackGround()
    print("backtoBackGround")
    if self._backGround == "hide" then
        self._backGround = "show"
    else
        self._backGround = "hide"
    end
    --     if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newShop) then
    --     return
    -- end
    qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT,{type=self._backGround})
end

function test:testWaitEvent()
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto(), offset ={x=-400}})
end

function test:testDownloader()
    print("testDownloader !!!")
    local downloaderClass = require2("src.framework.downloader.Downloader")
    local downloader = downloaderClass.new("qwervasdf", 500, 10)
    local imgUrl = "bull.168dw.net/media/banner/banner1552383634"
    print(">>>>>>>>>>>>>>>>>>>>>>>", QNative:shareInstance():md5(imgUrl))
    downloader:execute(imgUrl, 10,
        function(path)
            print(">>>>>>>>>>>", path)
        end,
        function()
        end,
        function()
        end
    )
end

function test:testRetMoneyLayer()
    -- ModuleManager:removeExistView()

    Cache.retmoneyInfo = require2("cache.other.RetMoneyInfo")
    local layer = require2("src.modules.common.RetMoneyView")
    local layerView = layer.new()
    layerView:show()

    -- GameNet:send({cmd = CMD.RET_MONEY, callback = function (rsp)
    --     print("qasdfasdfasd123123f")
    --     print(rsp.ret)
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end

    -- -- optional int32 activity_login_days = 1; // 活动登录天数
    -- -- optional int32 yesterday_profit=2; // 昨日收益
    -- -- optional int32 profit_total = 3; // 累计收益
    -- -- optional int32 wait_draw = 4; // 待兑换
    -- -- optional int32 flow_today = 5; // 今日流水
    -- -- optional float reward_rate = 6; // 奖励系数
    -- -- optional int32 recharge_total = 7; // 总充值金额        
    --     print("qasdfasdfasdf123123")

    --     paras = paras or {}
    --     paras.model = rsp.model
    --     printRspModel(rsp.model)
    --     -- if paras and paras.model then
    --     --     self:resolveData(paras.model)
    --     --     self:refreshRecordViewEx()
    --     -- end
    -- end})

    -- GameNet:send({cmd = CMD.RET_EXCHANGE, callback = function (rsp)
    --     print("qwerqwer", rsp.ret)
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end

    --     paras = paras or {}
    --     paras.model = rsp.model
    --     printRspModel(rsp.model)
    --     -- if paras and paras.model then
    --     --     self:resolveData(paras.model)
    --     --     self:refreshRecordViewEx()
    --     -- end
    -- end})

end

function test:testZipDownloader()
    -- print("testZipDownloader >>>>>>>>>>>>>>>>>>")
    require2("src.common.ZipDownloader")
    -- print(ZD)
end

local tt = function (s)
    s = nil
end 

function test:testHttpRequest3( ... )
    local URL =  "http://104.215.192.114:31200/media/lua_source/IOSHM_HM000/400/50/res/game_common/gameTableHall/game_table_hall.json"

    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    testHttpRequest2()
    -- print("qwerqwer", self.hander_req_1)

    -- self.hander_req_3 = testHttpRequest2()
    -- print("XXXX", self.hander_req_1)



    -- Util:runOnce(0.5, function ( ... )
    --     self.hander_req_2 = testHttpRequest2()
    --     print("XXXX", self.hander_req_1)
    -- end)

    -- self.hander_req_1 = testHttpRequest2()
    -- print("qwerqwer", self.hander_req_1)
end

function test:testHttpRequest2(name)
    local hander_req_1 = nil
    hander_req_1 = cc.XMLHttpRequest:new()
    hander_req_1.timeout = 5
    local handler_scheduler_1 = Util:runOnce(hander_req_1.timeout, function( ... )
        if hander_req_1 then
            hander_req_1:abort()
            hander_req_1 = nil
        end
    end)

    local func = function(event)
        Util:stopRun(handler_scheduler_1)
        print(string.len(hander_req_1.response))
        io.writefile("testresponse.json", hander_req_1.response, "wb")
    end

    --此处设置如果请求不到就一直重复请求cdn
    hander_req_1:registerScriptHandler(func)
    local response_type = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    hander_req_1.responseType = response_type

    
-- cc.XMLHTTPREQUEST_RESPONSE_STRING = 0
-- cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER = 1
-- cc.XMLHTTPREQUEST_RESPONSE_BLOB   = 2
-- cc.XMLHTTPREQUEST_RESPONSE_DOCUMENT = 3
-- cc.XMLHTTPREQUEST_RESPONSE_JSON = 4

    -- hander_req_1:registerScriptHandler(cb)
    -- local url = "https://gitee.com/yuanwu123/temp/blob/master/README.md"
    local url = "http://104.215.192.114:31200/media/lua_source/ADHM_HM000/400/42/res/cn/ui/activity_layer.json"
    -- local url = "http://104.215.192.114:31200/media/lua_source/IOSHM_HM000/400/50/res/texas_net.proto"
    -- local url = "http://104.215.192.114:31200/media/lua_source/IOSHM_HM000/400/50/src/common/Util.lua"
    hander_req_1:open("GET", url)
    hander_req_1:send()

    -- Util:safeRequestConfigURL(hander_req_1, func)
    -- self[name] = hander_req_1
    -- return hander_req_1
end


function test:testHttpRequest4()
    local xhr = cc.XMLHttpRequest:new() --创建一个请求
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --设置返回数据格式为字符串
    local req = "http://www.baidu.com" --请求地址
    xhr:open("GET", req) --设置请求方式  GET     或者  POST

    local function onReadyStateChange()  --请求响应函数
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then --请求状态已完并且请求已成功
                local statusString = "Http Status Code:"..xhr.statusText
                print("请求返回状态码"..statusString)
                local s = xhr.response --获得返回的内容
                print("返回的数据") 
        end
    end
    xhr:registerScriptHandler(onReadyStateChange) --注册请求响应函数
    xhr:send() --最后发送请求
end

function test:testHttpRequest()
    print("zxcvadfqwer------------")
    self.handler_http_req = nil
    self.handler_http_req = cc.XMLHttpRequest:new()
    self.handler_http_req.timeout = 5
    self.handler_scheduler = Util:runOnce(self.handler_http_req.timeout, function( ... )
        if self.handler_http_req then
            self.handler_http_req:abort()
            self.handler_http_req:release()
            self.handler_http_req = nil
        end
    end)


    local cb = function ( ... )
        self.handler_http_req:open("GET", Util:getRequestConfigURL())
        self.handler_http_req:send()
    end

    self.handler_http_req:registerScriptHandler(function(event)
        print("zxcvasdfqwer", "handler_http_req")
        Util:stopRun(self.handler_scheduler)
        self.handler_scheduler = nil

        self.handler_http_req.status = 404
        if self.handler_http_req.status == 200 then 

        else
            print("zxvasdfqwerasasfd")
            print(self.handler_http_req)
            Util:runOnce(0.1, function( ... )
                self:testHttpRequest()
            end)
        end
        Util:stopRun(self.handler_scheduler)
        self.handler_scheduler = nil
    end)

    -- Util:runOnce(0.01, function( ... )
    --     print(req)
    --     print("xzcvasdfqwer")
    --     cb()
    --     -- req:send()
    -- end)

    response_type = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.handler_http_req.responseType = response_type
    self.handler_http_req:open("GET", Util:getRequestConfigURL())
    self.handler_http_req:send()
end

function test:testChangePortraitOrLandScape()
    print(cc.GLViewProtocol)
    dump(cc.GLViewProtocol)
    local glView = cc.Director:getInstance():getOpenGLView()
    local policy = glView:getResolutionPolicy()
    local designSize = glView:getDesignResolutionSize()

    local frameSize = glView:getFrameSize()
    if true then
        glView:setFrameSize(frameSize.height, frameSize.width)
    end

    glView:setDesignResolutionSize(designSize.width, designSize.height, policy)
    
    -- local x = cc.GLViewProtocol:create()
    -- print(x)
    -- dump(cc.GLViewProtocol:getFrameSize())
    -- print
    -- auto policy = g_eglView->getResolutionPolicy();
    -- auto designSize = g_eglView->getDesignResolutionSize();
    -- if (g_landscape)
    -- {
    --     g_eglView->setFrameSize(g_screenSize.width, g_screenSize.height);
    -- }
    -- else
    -- {
    --     g_eglView->setFrameSize(g_screenSize.height, g_screenSize.width);
    -- }

    -- g_eglView->setDesignResolutionSize(designSize.width, designSize.height, policy);

end

function test:testBindRewardView()
    local layer = require2("src.modules.common.BindRewardView")--绑卡
    local layerView = layer.new()
    layerView:show()
end

function test:testHongBaoView()
    -- ModuleManager:removeExistView()
    local HongBaoView = require2("src.modules.common.HongBaoView")
    -- print("layer >>>>>>>>>>>", layer)
    -- local layerView = layer.new()
    -- layerView:show()

    Cache.hongbaoInfo:queryFirstRecharge(function (data)
        paras = paras or {}
        paras.data = data
        local view = HongBaoView.new(paras)
        view:show()
    end)

end


function test:testCurlDown(filename)
    print(cc.CurlDown)
    local curldown = cc.CurlDown:new()
    local filepath = cc.FileUtils:getInstance():getWritablePath()
    -- local filename = ""
    print(filepath)
    curldown:setFileInfo(filepath, filename, "104.215.192.114:31200/media/lua_source/ADHM_HM000/300/3/game_brnn1558077957/game_brnn.zip")
    curldown:downStart()

    local cb =function (name)
        if name == "progress" then
            local percent = curldown:getFileDownPercent()
            print(percent)
            -- if (percent > 50) then
            --     curldown:stop()
            --     performWithDelay(cc.Director:getInstance():getRunningScene(), function ( ... )
            --         curldown:release()
            --     end, 0.3)
            -- end

        elseif name == "success" then
            print("success!!!")
        end
    end
    curldown:registerScriptCurlDownHandler(cb)

-- curldown:unCompress(filepath, "")
-- "path" = "E:/Project/bull_cocos/texas/runtime/win32/download/"
-- - "zipurl" = "104.215.192.114:31200/media/lua_source/ADHM_HM000/300/3/game_brnn1558077957/game_brnn.zip"

end

function test:testpreLoading()
    -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(GameRes.mainGameBtnAni, function ( ... )
    --     print("success")
    -- end)
end

function test:testExistMainView()
    ModuleManager.gameshall:getView():test2()
end

function test:testAgencyView( ... )

    Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
        local layer = require2("src.modules.common.AgencyView")
        local layerView = layer.new(data)    
        layerView:show()
    end)

end

function test:testLuckView()
    local LuckView = require2("src.modules.common.ReviewLuckView")
    Cache.mammonInfo:requestGetMammonInfo({uin = Cache.user.uin}, function ( paras )
        local view = LuckView.new(paras)
        view:show(paras)
    end)
    -- local view = LuckView.new(paras)
    -- view:show(paras)
end

function test:testScheduler( ... )
    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(
        function ()
            print("66666")
        end,
    1, true)
end
function test:testPOP( ... )
    local root = LayerManager.PopupLayer
    print(root:isVisible())
    Util:lookUpNode(root, function (str, nodename, v)
        print(str, nodename, tolua.type(v), v:isVisible())
    end)
end

function test:testDeskInfo(gameId, cb)
    GameNet:send({cmd = CMD.GET_DESK_LIST_INFO, body = {game_id  = 8}, callback= function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        printRspModel(rsp)
        local model = rsp.model
        printRspModel(model)
        --先存储用户数据
        local mpArr = {}
        for i = 1, model.portrait_list:len() do
            local mplist = model.portrait_list:get(i)    
            local _mplist = {
                uin = mplist.uin,
                portrait = mplist.portrait,
                sex = mplist.sex,
                seat_id = mplist.seat_id,
                desk_id = mplist.desk_id
            }
            mpArr[mplist.desk_id] = _mplist
        end

        local mmData = {}
        for i = 1, model.data:len() do
            local mdata = model.data:get(i)
            local groupLevel = mdata.group
            local mmDesk = {}
            for j = 1, mdata.desks:len() do
                local mdesk = mdata.desks:get(j)
                mmDesk[#mmDesk + 1] = {
                    room_id = mdesk.room_id, --房间ID
                    min_num = mdesk.min_num,
                    max_num = mdesk.max_num, 
                    desk_id = mdesk.desk_id, --桌子ID
                    current_players = mdesk.current_players, --当前玩家数
                    base_chip = mdesk.base_chip, --底注                    
                    show_desk_id = mdesk.show_desk_id,
                    portrait_list = mpArr[desk_id]
                }
            end
            mmData[#mmData + 1] = {
                group = groupLevel, --等级
                desks = mmDesk  --桌子
            }
        end
        if cb then
            cb(mmData)
        end
    end
    })
end

--invite_from 绑定代理为空
function test:testBindInfo( ... )

    -- GameNet:send({cmd = CMD.BIND_AGENCY, body={promotion_code="123456"}, callback = function (rsp)
    --     print("rsp.ret >>>>>>>>>>> ", rsp.ret)
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end
    -- end})

    print("发送消息")
    GameNet:send({cmd = CMD.GET_AGENCY_INFO, callback= function (rsp)
        print("cmd", CMD.GET_AGENCY_INFO)
        print("rspret", rsp.ret)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end

        local attr = {
            "proxy_portrait", "wx_id", "wx_id2", "copy_writing", "sex", "qq_id", "qq_id2"
        }
        local model = rsp.model
        printRspModel(rsp.model)
        local data = {}
        for i, v in ipairs(attr) do
            data[v] = model[v]
        end
        dump(data)
    end
    })

    --UserLoginRsp
    --invite_from
end

function test:testdiv( ... )
    local a = 1
    print(1/nil)
    print(nil/1)
end

function test:check2Signs(content)
    local s1 = string.find(content, "%%")
    print(">>>>s1,", s1)
    if s1 == -1 or s1 == nil then
        return false
    end
    local content2 = string.sub(content, s1+1, -1)
    -- print("content >>>>", content)
    -- print("content2 >>>>", content2)
    local s2 = string.find(content2, "%%")
    if s2 == -1 or s2 == nil then
        return false
    end
    return s1, s1  + s2
end

local specialFormatNumber = function (number, bop)
    local _number = math.abs(number)
    local _numberStr = ""
    if _number >= 10000 then
        _numberStr = _numberStr .. string.formatnumberthousands(_number)
    else
        _numberStr = _numberStr .. _number
    end

    if bop then
        if number > 0 then
            _numberStr = "+" .. _numberStr
        elseif number < 0 then
            _numberStr = "-" .. _numberStr
        elseif number == 0 then
            _numberStr = _numberStr
        end
    end
    return Util:NoRoundedOff(_numberStr, 2)
end

function test:testFunc( ... )

    -- qf.event:dispatchEvent(ET.REFRESH_HONGBAO_BTN)
    -- phone = "123123123123"
    -- zone = "86"
    -- pwd = "3443534"
    -- local cmpIndex = Util:saveUniqueValueByKey("loginPhone", phone)
    -- Util:insertValueByKeyAndIndex("loginPwd", pwd, cmpIndex)
    -- Util:insertValueByKeyAndIndex("loginZone", zone, cmpIndex)
    -- print("test Fun c asfafdsa ")
    -- local winSize = cc.Director:getInstance():getWinSize()
    -- ModuleManager.zjhhall:getView():setPosition(773,0)
    -- ModuleManager.zjhhall:getView():stopAllActions()
    -- if FULLSCREENADAPTIVE then
    --     ModuleManager.zjhhall:getView():runAction(
    --         cc.Sequence:create(
    --             cc.MoveTo:create(0.2,cc.p(winSize.width/2-1920/2,0))
    --     ))
    -- else
    --     ModuleManager.zjhhall:getView():runAction(
    --         cc.Sequence:create(
    --             cc.MoveTo:create(0.2,cc.p(0,0))
    --     ))
    -- end
    -- local body = {}

    -- GameNet:send({cmd=CMD.GET_MAIL_INFO,timeout=nil,callback=function(rsp)
    --     loga("updateBankPanel rsp "..rsp.ret)
    --     if rsp.ret ~= 0 then
    --     else
    --         local mt = rsp.model
    --         print(tolua.type(rsp.model))
    --         local protoTbl = {
    --             {"sys_mail", "arr", {
    --                     "mail_title",
    --                     "mail_text",
    --                     "mail_time",
    --                     "mail_id",
    --                     "reserved",
    --                     "mail_status"
    --                 }
    --             },
    --         }
    --         printRspModel(rsp.model)
    --         local retTbl =  Util:resolveProto(protoTbl, rsp.model)
    --         dump(retTbl)
    --         -- ExchangeView:showBankPanel(rsp)
    --         -- ExchangeView:show()
    --     end
    -- end})


--    print()
    -- dump(debug.getinfo( 1))
    -- local globalPoint = cc.p(150,450)
    -- local scene = cc.Director:getInstance():getRunningScene()
    -- scene:removeAllChildren()
    -- local spr = cc.Sprite:create(GameRes.agency_wx_img)
    -- scene:removeChildByName("imgTest5")
    -- scene:addChild(spr)
    -- spr:setPosition(globalPoint)
    -- scene:removeChildByName("imgTest2")
    -- scene:removeChildByName("imgTest")
    -- if self.bAdd then
    --     self.bAdd = false
    -- else
    --     self.bAdd = true
    -- end

    -- if self.bAdd then
    --     qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt="请求支付中"})
    -- else
    --     qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
    -- end

    -- Util:getCObejctFunction(CCFileUtils:sharedFileUtils())
    -- local file = io.writefile("asfasd.txt", "", "wb")
    -- printTraceback()
    -- dump(debug.getinfo(1))
    -- performWithDelay(self, )
    -- Scheduler:delayCall(0.2, function ( ... )
    --     cc.Director:getInstance():endToLua()
    -- end)
    -- require2("src.common.CSVLoader")
    -- Cache.Config.phoneCodeConfig = {}
    -- local Tbl = Cache.Config:getPhoneCodeConfig()
    -- print(#Tbl)
    -- for i = 1, 5 do
    --     dump(Tbl[i])
    -- end
    -- cocos2d::Director::getInstance()->end();
    -- print("231231231")
    -- print(string.format("%s --- %s", 123123, 1212312))
    -- if false and (not false) then
        -- print("ZCVXXZCVASDFQWER")
    -- end
    -- print(#zoneCtyTbl)
    -- print(#zoneNumberTbl)
    -- local tbl = {}
    -- for i = 1, #zoneCtyTbl do
    --     tbl[#tbl + 1] = {cty = zoneCtyTbl[i], code = "+" .. zoneNumberTbl[i]}
    -- end
    -- dump(tbl)
    -- for i,v in ipairs(zone) do
    -- end
    -- local str = "sdfasdf123421412341234213"
    -- print(string.sub(str,-4, -1))
    -- local code = "+832"
    -- print(string.sub(code, 2, #code))
    -- local num = 2.345
    -- local s = checknumber(string.format("%.2f", num))
    -- print(s)
    -- GameNet:send({cmd = CMD.GET_MAIL_INFO, callback = function(rsp)
    --     if rsp.ret ~= 0 then
    --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         return
    --     end
    --     printRspModel(rsp.model)
    --     -- -- printRspModel(rsp.model)
    --     -- self:saveConfig(rsp.model)
    --     -- if cb and type(cb) == "function" then
    --     --     cb()
    --     -- end
    -- end})
end


function test:testCommonTipView( ... )
    local CommonTipView = require2("src.modules.global.components.CommonTipView")
    local paras = {content = "  您的账号已%在其他设%备上登录，请确保账号安全，是否要重新登录？"}
    local view = CommonTipView.new(paras)
    if LayerManager.Global:getChildByName("zxcv") then
        LayerManager.Global:removeChildByName("zxcv")
    end

    view:setName("zxcv")
    LayerManager.Global:addChild(view)    
end

function test:testJsonXpcall( ... )
    xpcall(
        function()
            local s = self:testFunc()
        end,
        function() 
            print("sdfas123123fdqwer")
        end
    )
    print("sadfasdfasdf")
end

function test:testfilter()
end

function test:testLogin()
    -- CommonWidget.ComboList = require2("modules.common.widget.comboList")
    CommonWidget.ComboList = require2("src.modules.common.widget.comboList")
    ModuleManager:removeExistView()
    ModuleManager.login:remove()
    require2("src.modules.login.LoginView")
    ModuleManager.login = require2("src.modules.login.LoginController")
    ModuleManager.login:show()
    ModuleManager.login.view:showPanelLayer("LoginTypePannel")
    local view = ModuleManager.login:getView()
    if view and view.test then
        view:test()
    end
end

function test:testCoroutine( ... )
    local view = ModuleManager.niuniuhall:getView()
    if view.test then
        view:test()
    end
end

function test:testGlobalView()
    require2("src.modules.global.GlobalView")
    local ctr = require2("src.modules.global.GlobalController")
    ModuleManager.global = ctr.new()
    ModuleManager.global:getView()
end

function test:testUpdateUserHead()
end

function test:testDeskListInfo()
    local listinfo = require2("src.cache.other.DeskListInfo")
    Cache.deskListInfo = listinfo.new()
    Cache.deskListInfo:requestDeskListInfo({game_id = 7})
end

function test:testCommonWidget()
    CommonWidget.ShaderSprite = require2("src.modules.common.widget.ShaderSprite")
    local csp = CommonWidget.ShaderSprite
    print(csp)
    dump(csp)
    local scene = cc.Director:getInstance():getRunningScene()
    local img = csp.new({path = GameRes.agency_qq_img, outline = {size =4, color = cc.c3b(255,0,0), alpha = 255}, bright = {intensity = 0.5}})
    img:setLocalZOrder(100)
    img:setName("testImg")
    scene:removeChildByName("testImg")
    img:setPosition(cc.p(400,400))
    scene:addChild(img)
end

function test:testConsoleTCP( ... )
    
end

function test:testConsoleCommand()
    cc.Director:getInstance():getConsole():listenOnTCP(5678)
    
    -- local wait_execute_cmd_string = nil
    -- function InsertConsoleCmd(cmd_string)
    --     wait_execute_cmd_string = cmd_string
    -- end

    -- local function ExecuteCmdString(cmd_string)
    --     if cmd_string then
    --         local cmd_func = loadstring(cmd_string)
    --         if cmd_func then
    --             xpcall(cmd_func, __G__TRACKBACK__)
    --         else
    --             cclog("Invalid CMD! %s", cmd_string)
    --         end
    --     end
    -- end


    -- local function executeCmd(handler, cmd_string)
    --     -- print("zxvzxvzxv", cmd_string)
        -- InsertConsoleCmd(cmd_string)
    -- end
    -- self:AddConsoleCommand("lua", "Execute a Lua Command String.", executeCmd)

    -- return cc.Director:getInstance():getConsole():addCommand({name = "lua", help = "Execute a Lua Command String."}, executeCmd)
end

function test:testExcuteCommand()
    -- cc.Director:getInstance():getConsole():listenOnTCP(1234)
end

function test:testCheatDebug2()
    local cnt = 0
    local onTouchBegan = function (pTouch,pEvent)
        local location = pTouch:getLocation()
        local diff = 100
        if ((math.abs(location.x - C_WinSize.width) < diff) and  (math.abs(location.y - C_WinSize.height) < diff)) then
            self:testCheatDebug()
        end
        return false;
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()  --创建一个单点事件监听
    listener1:setSwallowTouches(false)  --是否向下传递
    --注册三个回调监听方法
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local touchPanel = LayerManager.Global
    local eventDispatcher = touchPanel:getEventDispatcher() --事件派发器

    if LayerManager.Global.listener then
        eventDispatcher:removeEventListener(LayerManager.Global.listener)
        LayerManager.Global.listener = nil
    end
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, touchPanel) --分发监听事件
    LayerManager.Global.listener = listener1
end

-- 返回实际的数字
local getRealNumber = function (v)
    if v > 10 then
        return 10
    end
    return v
end


function test:checkFourZha(NNCard)
    -- 四炸
    local isSameCntTbl = {}
    for i = 1, 5 do
        local curValue = NNCard[i].value
        if isSameCntTbl[curValue] then
            isSameCntTbl[curValue] = isSameCntTbl[curValue] + 1
        else
            isSameCntTbl[curValue] = 1
        end
    end
    for k, v in pairs(isSameCntTbl) do
        if v == 4 then
            return true
        end
    end
    return false
end


function test:checkWuhuaNiu(NNCard)
    local cnt = 0
    for i = 1, 5 do
        local curValue = NNCard[i].value
        if curValue > 10 then
            cnt = cnt + 1
        end
    end
    if cnt == 5 then
        print("asfdasdf")
        return true
    end
    return false
end


function test:checkWuXiaoNiu(NNCard)
    local sum = 0
    local bFlag = false
    for i = 1, 5 do
        sum = NNCard[i].value + sum
        if  NNCard[i].value >= 5 then
            bFlag = true
            break
        end
    end
    if (bFlag == false) and (sum < 10) then
        dump(NNCard)
        return true
    end
    return false
end



-- 得到牛牛类型
function test:getNNType(NNCard)

    -- 五小牛
    if self:checkWuXiaoNiu(NNCard) then
        return 13
    end

    -- 五花牛
    if self:checkWuhuaNiu(NNCard) then
        return 12
    end

    --四炸
    if self:checkFourZha(NNCard) then
        return 11
    end

    local sum = 0
    for i = 1, 5 do
        sum = sum + getRealNumber(NNCard[i].value)
    end
    for i = 1, 5 do
        for j = i+1, 5 do
            for k = j+1, 5 do
                local tx = getRealNumber(NNCard[i].value) + getRealNumber(NNCard[j].value) + getRealNumber(NNCard[k].value) 
                if (tx) % 10 == 0 then
                    local value = (sum - tx) % 10
                    if value == 0 then
                        value = 10
                    end
                    return value
                end
            end
        end
    end
    return 0
end

-- 测试nnproAlluser函数
-- function test:testGetNNProAllUser( ... )
--     local userArr = {
--         {1,1,2,3,4},
--         {1,1,2,3,8},
--     }
--     local userUinArr = {
--         Cache.user.uin,
--         20003
--     }
--     self:getNNProAllUser(userArr, userUinArr)
-- end


--获得对应seat的用户节点
function test:getUserPanel(seat)
    local meIndex = Cache.kandesk:getMeIndex()
    local cut = seat - meIndex
    if cut < 0 then
        cut = 5+cut
    end
    return cut
end

function test:compareNNTypeTest()
    local rivalCardArr = {{value = 10, hs = 4}}
    local myCardArr = {{value = 10, hs = 2}}
    local ret = self:compareNNType(rivalCardArr, myCardArr)
end

function test:compareNNType(rivalCardArr, myCardArr)
    local rivalMaxCard, myMaxCard
    local getMaxCard = function (arr)
        local tempMaxCard
        for i, v in ipairs(arr) do
            if tempMaxCard then
                if ((tempMaxCard.value < v.value) or (tempMaxCard.value == v.value and tempMaxCard.hs < v.hs)) then
                    tempMaxCard = v
                end
            else
                tempMaxCard = v
            end
        end
        return tempMaxCard
    end

    local rivalMaxCard = getMaxCard(rivalCardArr)
    local myMaxCard = getMaxCard(myCardArr)
    
    local ret = 1
    if ((rivalMaxCard.value < myMaxCard.value) or (rivalMaxCard.value == myMaxCard.value and rivalMaxCard.hs < myMaxCard.hs)) then
        ret = 0
    end
    return ret
end

-- 得到所有人的牌型并返回
function test:getNNProAllUser(userArr, userUinArr)
    local resNameTbl = {
        "1","2","3","4","5",
        "6","7","8","9","X",
        "A","B","C"
    }
    resNameTbl[0] = "0"
    local otherIndex = 1
    local myUin = Cache.user.uin 
    local popDesc = ""
    local bInDesk = false
    local tempArr = {}
    local cardUin = {}
    local myCardType, myCardArr
    self.nnCardTypeData = {}
    for i, vArr in ipairs(userArr) do
        local uin = userUinArr[i]
        if myUin == uin then
            myCardType = self:getNNType(vArr)
            myCardArr = vArr
            popDesc = resNameTbl[myCardType] .. " " .. popDesc 
            self.nnCardTypeData[uin] = {ct = myCardType}
        end
    end

    for i, vArr in ipairs(userArr) do
        local uin = userUinArr[i]
        if #vArr == 5 then
            if uin ~= myUin then
                local value = self:getNNType(vArr)
                local desc = resNameTbl[value]
                local compareNType
                if value == myCardType then
                    compareNType =  self:compareNNType(vArr, myCardArr)
                end

                if compareNType == 1 then
                    desc = desc .. "[1]"
                elseif compareNType == 0 then
                    desc = desc .. "[0]"
                end
                self.nnCardTypeData[uin] = {ct = value, cnt = compareNType}

                local uData = self.nnData.userArr[uin]
                local seatid =  self:getUserPanel(uData.seatid)
                if uData.bRobet then
                    desc = desc .. "*"
                end
                tempArr[seatid] =desc
            end
            cardUin[uin] = value
        end
    end
    
    for i = 4, 1, -1 do
        if tempArr[i] then
            popDesc = popDesc .. " " .. tempArr[i]
        end
    end

    return popDesc
end

-- 判断自己的牌型是否大于uin2
function test:compareNNTypeByMyUin(uin2)
    local nnCardTypeData = self.nnCardTypeData
    local uin1 = Cache.user.uin
    if nnCardTypeData[uin1].ct == nnCardTypeData[uin2].ct then
        return nnCardTypeData[uin2].cnt == 0
    end
    return nnCardTypeData[uin1].ct > nnCardTypeData[uin2].ct
end

function test:test_checkMyCardIsBiggest( ... )
    self.nnCardTypeData = {
        [23555] = {ct = 0},
        [23876] = {ct = 5},
        [8950882] = {ct = 8},
    }
    print(self:checkMyCardIsBiggest())
end

-- 判断自己的牌型是否最大
function test:checkMyCardIsBiggest()
    local nnCardTypeData = self.nnCardTypeData
    local myUin = Cache.user.uin
    local flag = true

    dump(nnCardTypeData)
    for k, v in pairs(nnCardTypeData) do
        print(flag)
        if (flag) and (k ~= myUin) and (self:compareNNTypeByMyUin(k) == false) then
            flag = false
        end
    end
    return flag
end

function test:KanZhuangDel()
    print("收到服务器发来的广播庄的通知！！！", self.nnData, self.nnCardTypeData)

    if not  self.cheatOn3  then
        print("关闭自动")
        return
    end

    if self.nnData and self.nnCardTypeData then
        print(Cache.kandesk.zhuang_uin, Cache.user.uin)
        if Cache.kandesk.zhuang_uin == Cache.user.uin then --自己是庄不处理
            return
        end

        local big_call_score = -9999
        local small_call_score = 9999
        for k, v in pairs(Cache.kandesk.call_score_list) do
            v = checknumber(v)
            if v > big_call_score then
                big_call_score = v
            end
            if v < small_call_score then
                small_call_score = v
            end
        end

        -- 比庄大 下最大的分
        if self:compareNNTypeByMyUin(Cache.kandesk.zhuang_uin) then
            print("应该最大的下分：", checknumber(big_call_score))
            if big_call_score ~= -9999 then
                -- body
                Util:runOnce(3, function ( ... )
                    GameNet:send({cmd=Niuniu_CMD.USER_RE_BASE,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid,call_times=big_call_score}})
                end)
            end
        else
        -- 比庄大 下最小的分
            -- print("应该最小的下分：", checknumber(small_call_score))
            if small_call_score ~= 9999 then
                -- body
                Util:runOnce(3, function ( ... )
                    GameNet:send({cmd=Niuniu_CMD.USER_RE_BASE,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid,call_times=small_call_score}})
                end)
            end
        end
    end
end

-- 供给nn游戏直接调用的接口
function test:getNNPro(model)
    if not self.cheatOn1 then
        return
    end
    self.nnCardTypeData = nil
    self.nnData = {}
    printRspModel(model)
    if model then
        local userUinArr = {}
        local userCardArr = {}
        local userArr = {}
        local tipDesc = "-"
        for i = 1, model.users:len() do
            local u = model.users:get(i)
            userUinArr[#userUinArr + 1] = u.uin
            userArr[u.uin] = {
                nick = u.nick,
                auto_play = u.auto_play,
                seatid = u.seatid,
                bRobet = string.len(u.uin .. "") < 7
            }
            if userArr[u.uin].bRobet then
                tipDesc = tipDesc .. "*"
            end
            local tempArr = {}
            for j = 1, 5 do
                local card = u.cards:get(j)
                tempArr[#tempArr + 1] = {value = self:getClientCard(card), hs = self:getClientHuaSe(card)}
            end
            userCardArr[#userCardArr + 1] =  tempArr
        end

        dump(userArr)
        if userArr[Cache.user.uin] == nil then
            if self.cheatOn2 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =  tipDesc})
            end
            return
        end
        print("+++++++++ >>>>>>>>>>>>>")

        self.nnData.userCardArr = userCardArr
        self.nnData.userUinArr = userUinArr
        self.nnData.userArr = userArr

        local desc = self:getNNProAllUser(userCardArr, userUinArr)
        print("desc >>>>>>>>>>>", desc)
                
        if desc ~= "" then
            if self.cheatOn2 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =  desc})
            end
        end
        if self.cheatOn3 then
            if self:checkMyCardIsBiggest() then
                print("自己的牌型最大！！！！")
                local big_grab_score = -9999
                for k, v in pairs(Cache.kandesk.grab_score) do
                    v = checknumber(v)
                    if v > big_grab_score then
                        big_grab_score = v
                    end
                end
                print("抢自己能够 最大的庄", big_grab_score)
                if big_grab_score ~= -9999 then
                    Util:runOnce(6, function ( ... )
                        GameNet:send({cmd=Niuniu_CMD.USER_RE_QIANG,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid,call_times=big_grab_score}})
                    end)
                end
            else
                print("自己的牌型不是最大！！！")
                print("不抢庄")
                Util:runOnce(6, function ( ... )
                    GameNet:send({cmd=Niuniu_CMD.USER_RE_QIANG,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid,call_times=0}})
                end)
            end
        end
    end
end
-- 根据nncard 得到直接的胜率
function test:testNNProbability(NNCard)
    local cardArr = {}
    local numArr = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
    local pro = {}
    for i = 0, 10 do
        pro[i] = 0
    end
    local resNameTbl = {
        "牛一","牛二","牛三","牛四","牛五",
        "牛六","牛七","牛八","牛九","牛牛",
    }
    resNameTbl[0] = "无牛"
    local bNumArr = {}
    local NNCard = {10, 13, 12, 11}
    local NNIdx = 1
    table.sort(NNCard)
    for _, v in ipairs(numArr) do
        for i = 1, 4 do
            if NNIdx <= 4 and NNCard[NNIdx] == v then
                NNIdx=NNIdx + 1
            else
                cardArr[#cardArr + 1] = v
            end
        end
    end
    for _, v in ipairs(cardArr) do
        local bBreak = false
        NNCard[5] = v 
        local nnTyoe = self:getNNType(NNCard)
        pro[nnTyoe] = pro[nnTyoe] + 1
    end
    for i = 0, 10 do
        print(string.format("%s 的概率： %.2f%%", resNameTbl[i], (pro[i] / 48) * 100))
    end
end

function test:getClientCard(value)
    local i,t = math.modf(value/4)
    i = i + 1
    if i == 14 then i = 1 end
    return i
end

function test:getClientHuaSe(value)
    local c = math.fmod(value,4)
    c = c+1
    local ctable = {1, 2, 3, 4}
    return ctable[c]
end

function test:clearNNInfo( ... )
    self.nnData = nil 
    self.nnCardTypeData = nil
end

function test:checkGameOver()
    if self.nnData and self.nnData.userArr then
        print("checkGameOver!!!")
        local flag = false
        local cnt = 0
        for k, v in pairs(self.nnData.userArr) do
            if v.bRobet then
                flag = true
            end
            cnt = cnt + 1
        end
        if self.cheatOn3 then
            Util:runOnce(4, function ( ... )
                if flag then
                    print("有机器人！！！ 退出牌桌")
                    qf.event:dispatchEvent(Niuniu_ET.RE_QUIT, {quitByUserFore = true})
                else
                    print("没有机器人了， 可以继续玩")
                end
                print("upValue >>>>>>>>", self.upValue)
                if self.upValue and (self.upValue > 0) then
                    if Cache.user.gold >= self.upValue then
                        qf.event:dispatchEvent(Niuniu_ET.RE_QUIT, {quitByUserFore = true})
                    end
                end
                if self.downValue and (self.downValue > 0) then
                    if Cache.user.gold <= self.downValue then
                        qf.event:dispatchEvent(Niuniu_ET.RE_QUIT, {quitByUserFore = true})
                    end
                end
            end)
        end
    end
end

function test:testCheatDebug( ... )
    local color = cc.c4b(0, 0, 0, 255)
    local args = {color = color}
    local colorLayer = self:createGLtestLayer(255, args)


    local lastPos = nil
    local diffX = 0
    Util:addNormalTouchEvent(colorLayer, function ( method, touch, event )
        if method == "began" then
            lastPos = touch:getLocation()
            return true
        elseif method == "move" then
            movedPos = touch:getLocation()
            local tempDiffX = diffX + (movedPos.x - lastPos.x)
            if tempDiffX > 0 then
            else
                for i, v in ipairs(colorLayer:getChildren()) do
                    Util:setPosOffset(v, cc.p(movedPos.x - lastPos.x, 0))
                end
                diffX = tempDiffX
            end
            lastPos = movedPos
        elseif method == "end" then
        end
    end)

    local hideGameFunc = function ( ... )
        for i, v in ipairs(colorLayer:getChildren()) do
            v:setVisible(false)
        end
        colorLayer:getEventDispatcher():removeEventListenersForTarget(colorLayer)
        Util:addNormalTouchEvent(colorLayer, function ( method, touch, event )
            if method == "began" then
                return true
            end

            if method == "end" then
                local location = touch:getLocation()
                dump(location)
                local diff = 100
                if ((math.abs(location.x - C_WinSize.width/2) < diff) and  (math.abs(location.y - C_WinSize.height/2) < diff)) then
                    colorLayer:removeFromParent()
                end
            end
        end)
    end
    local ROW, COL = 7, 10
    local uWidth, uHeight = C_WinSize.width/COL, C_WinSize.height/ROW

    local r = math.random
    local closefunc = function ()
        if colorLayer and tolua.isnull(colorLayer) ==  false then
            colorLayer:removeFromParent()
        end
    end

    local cheatOnNumber = 3
    for i = 1, cheatOnNumber do
        if self["cheatOn" .. i] == nil then
            self["cheatOn" .. i] = true
        end
    end
    local getDebugDesc = function (cheatOnIdx)
        local tbl = {
            {"开启debug", "关闭debug"},
            {"开启提示", "关闭提示"},
            {"开启自动", "关闭自动"},
        }
        local ret = tbl[cheatOnIdx]
        return self["cheatOn" .. cheatOnIdx] and ret[1] or ret[2] 
    end

    local debugFunc = function (cheatOnIdx)
        return function (sender)
            self["cheatOn" .. cheatOnIdx] = not self["cheatOn" .. cheatOnIdx]
            sender:getChildByName("text"):setString(getDebugDesc(cheatOnIdx))
        end
    end

    -- self.cheatUpValue = 0
    -- self.cheatUpValue = 0
    -- 暂时只支持添加56个功能模块
    -- 总共7行8列
    local descTbl = {
        -- 第1行 第1列 描述 功能
        {1,1,"关闭页面", closefunc},
        {1,2,"登陆页面", handler(self, self.testLogin)},
        {1,3,"主大厅", handler(self, self.testMainGame)},
        {1,4,"重载牛牛", handler(self, self.reloadNiuNiu)},
        {1,5,"牛牛测试", handler(self, self.testNNGame)},
        {1,6,"重载龙虎斗", handler(self, self.reloadLHD)},
        {1,7,"龙虎斗测试", handler(self, self.testLHDGame)},
        {1,8,"重载百人炸金花", handler(self, self.reloadBRGame)},
        {1,9,"百人炸金花测试", handler(self, self.testBRGame)},
        {1,10,"重载百人牛牛", handler(self, self.reloadBRNNGame)},
        {1,11,"百人牛牛测试", handler(self, self.testBRNNGame)},
        {1,12,"重载炸金花", handler(self, self.reloadZJH)},
        {1,13,"炸金花测试", handler(self, self.testZJHGame)},

        {2,1,"MessageBox", handler(self, self.testMessageBoxLayer)},
        {2,2,"邮箱页面", handler(self, self.testMailView)},
        {2,3,"个人中心", handler(self, self.testPersonView)},
        {2,4,"客服弹窗页面", handler(self, self.testAgencyAlertView)},
        {2,5,"绑定手机页面", handler(self, self.testChangePwdLayer)},
        {2,6,"规则页面", handler(self, self.testRuleLayer)},
        {2,7,"周返现", handler(self, self.testRetMoneyLayer)},
        {2,8,"头像框背包", handler(self, self.testTxkBagView)},
        {2,9,"头像框购买", handler(self, self.testTxkBuyView)},
        {3,1,getDebugDesc(1), debugFunc(1),true},
        {3,2,getDebugDesc(2), debugFunc(2),true},
        {3,3,getDebugDesc(3), debugFunc(3),true},
        {3,4,"hideGame", hideGameFunc, true},
        {3,5,"设置阈值", handler(self, self.setLimitValue), true},
        {3,6,"播放电影", handler(self, self.inputVideo), true},
        {3,7,"得到文件名", handler(self, self.getFileName), true},
    }

    local key_name = "last_choice"
    local max_num = 5
    local getLastChoiceTbl = function ()
        local jStr = cc.UserDefault:getInstance():getStringForKey(key_name, "")
        local lastTbl = {}
        local tbl = {}
        if jStr ~= "" then
            tbl = json.decode(jStr)
        end
        for _, name in ipairs(tbl) do
            for _, v in ipairs(descTbl) do
                if v[3] == name then
                    lastTbl[#lastTbl + 1] = v
                    break
                end
            end
        end
        return lastTbl
    end

    local saveLastChoiceTbl = function (name) 
        local jStr = cc.UserDefault:getInstance():getStringForKey(key_name, "")
        local lastTbl = {}
        local tbl = {}
        if jStr ~= "" then
            tbl = json.decode(jStr)
        end
        local iFind
        for i, v in ipairs(tbl) do
            if v == name then
                iFind = i
                break
            end
        end

        if iFind then
            table.remove( tbl, iFind)
            table.insert(tbl, 1, name)
        else
            table.insert(tbl, 1, name)
        end
        local jStr = json.encode(tbl)
        cc.UserDefault:getInstance():setStringForKey(key_name, jStr)
    end

    local addBlock = function (v, pos)
        local j, i, txt, func, bNotClose = unpack(v)
        local color = cc.c3b(r(0,255), r(0,255), r(0,255))
        local layout = self:getLayout({size = cc.size(uWidth,uHeight), ap = cc.p(0,0), color = color, pos = pos, func = function (layout)
            if func then
                func(layout)
            end
            if not bNotClose then
                closefunc()
            end            
            saveLastChoiceTbl(txt)
        end, text = txt, ftAdapt = true})
        colorLayer:addChild(layout)
    end
    for _,v in ipairs(descTbl) do
        local j, i, txt, func, bClose = unpack(v)
        addBlock(v, cc.p(uWidth*(i-1), uHeight*(ROW -j))) 
    end

    local LastTbl = getLastChoiceTbl()

    for i, v in ipairs(LastTbl) do
        if i > max_num then
            break
        end
        addBlock(v, cc.p(uWidth*(i-1), 0))
    end
    print("gold >>>>>>>>>>>", Cache.user.gold)

end

function test:createEditBox(argsTbl)
    local tag = argsTbl.tag or -987654 -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    local offset = argsTbl.offset or {x =0, y= 0}
    local fontcolor = argsTbl.fontcolor or cc.c3b(30, 74, 130)
    local fontname = argsTbl.fontname or GameRes.font1
    local name = argsTbl.name or "editbox"
    local posOffset = argsTbl.posOffset or {x =0, y= 0}
    local fontsize = argsTbl.fontsize or 42
    local placeFontsize = argsTbl.placefontsize or 42
    local placeTxt = argsTbl.placeTxt or ""
    local placeHolderColor = argsTbl.holdColor or cc.c3b(204, 204, 204)
    local retType = argsTbl.retType or cc.KEYBOARD_RETURNTYPE_DONE
    local handler = argsTbl.handler
    local iMode = argsTbl.iMode
    local csize = argsTbl.iSize
    local iFlag = argsTbl.iFlag
    local maxlength = argsTbl.maxLen
    local anchorPoint = argsTbl.ap
    local editbox
    if csize then
        editbox = cc.EditBox:create(csize, cc.Scale9Sprite:create())
    end

    editbox:setTag(tag)  
    editbox:setAnchorPoint(anchorPoint)
    editbox:setFontColor(fontcolor)
    editbox:setFontName(fontname)

    editbox:setName(name)
    -- editbox:setCascadeOpacityEnabled(true)
    editbox:setFontSize(fontsize)
    
    editbox:setPlaceholderFontSize(placeFontsize)
    editbox:setPlaceHolder(placeTxt)
    editbox:setPlaceholderFontColor(placeHolderColor)

    -- editbox:setPosition(frame:getContentSize().width * 0.5 + posOffset.x, frame:getContentSize().height * 0.5 + posOffset.y)
    editbox:setReturnType(retType)
    if maxlength then
        editbox:setMaxLength(maxlength)
    end
    if handler then
        editbox:registerScriptEditBoxHandler(handler)
    end

    if iMode then
        editbox:setInputMode(iMode)
    end

    if iFlag then
        editbox:setInputFlag(iFlag)
    end
    
    return editbox
end

function test:setLimitValue()
    local color = cc.c4b(0, 0, 0, 180)
    local args = {color = color}
    local colorLayer = self:createGLtestLayer(255, args)
    local upValueBox =  self:createEditBox({name = "upValue", iSize = cc.size(500, 100), placeTxt = "输入上限值", fontcolor = cc.c3b(255,0,0),ap= cc.p(0,0.5)})
    colorLayer:addChild(upValueBox)
    upValueBox:setPosition3D(cc.p(500,500))

    local upText = ccui.Text:create("上限值：", GameRes.font1, 42)
    upText:setPosition(cc.p(400,500))
    colorLayer:addChild(upText)

    local upText2 = ccui.Text:create("当前上限值：" .. Util:getFormatString(checknumber(self.upValue)), GameRes.font1, 42)
    upText2:setPosition(cc.p(400,400))
    colorLayer:addChild(upText2)
    
    local downValueBox =  self:createEditBox({name = "upValue", iSize = cc.size(500, 100), placeTxt = "输入下限值", fontcolor = cc.c3b(255,0,0),ap= cc.p(0,0.5)})
    colorLayer:addChild(downValueBox)
    downValueBox:setPosition3D(cc.p(500,300))

    local downText = ccui.Text:create("下限值：", GameRes.font1, 42)
    downText:setPosition(cc.p(400,300))
    colorLayer:addChild(downText)

    local downText2 = ccui.Text:create("当前下限值：" .. Util:getFormatString(checknumber(self.downValue)), GameRes.font1, 42)
    downText2:setPosition(cc.p(400,200))
    colorLayer:addChild(downText2)

    Util:addNormalTouchEvent(colorLayer, function ( method, touch, event )
        if method == "began" then
            lastPos = touch:getLocation()
            return true
        end
    end)

    if self.upValue then
        upValueBox:setText(self.upValue)
    end
    
    if self.downValue then
        downValueBox:setText(self.downValue)
    end

    local confirmText = ccui.Text:create("确认修改", GameRes.font1, 80)
    confirmText:setPosition(cc.p(C_WinSize.width - 300,300))
    confirmText:setColor(cc.c3b(255,0,0))
    confirmText:setEnabled(true)
    confirmText:setTouchEnabled(true)
    addButtonEvent(confirmText, function ()
        self.upValue = checknumber(upValueBox:getText())
        self.downValue = checknumber(downValueBox:getText())
        local desc =  string.format("上限值: %s, 下限值： %s", Util:getFormatString(self.upValue), Util:getFormatString(self.downValue))
        qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = desc})
        print(self.upValue, self.downValue)
        if colorLayer and tolua.isnull(colorLayer) == false then
            colorLayer:removeFromParent()
        end
    end)
    colorLayer:addChild(confirmText)
end

function test:createGLtestLayer(opa, args)
    local del  = LayerManager.Global
    local codeLayer = del:getChildByName("GLLayer")
    if codeLayer and tolua.isnull(codeLayer) == false then
        codeLayer:removeFromParent()
    end
    del:setLocalZOrder(99009)
    local color = cc.c4b(255, 255, 255, 255)
    if args then
        color = args.color
    end
    local colorLayer = cc.LayerColor:create(color)
    colorLayer:setContentSize(cc.size(C_WinSize.width, C_WinSize.height))
    colorLayer:setName("GLLayer")
    opa = opa or 255
    colorLayer:setOpacity(opa)
    del:addChild(colorLayer, 9999)

    local btn = ccui.Text:create("close", GameRes.font1, 50)
    btn:setPosition(cc.p(C_WinSize.width- 100, C_WinSize.height - 100))
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setColor(cc.c3b(255,255,255))
    colorLayer:addChild(btn)
    addButtonEvent(btn, function ()
        local codeLayer = del:getChildByName("GLLayer")
        if codeLayer and tolua.isnull(codeLayer) == false then
            codeLayer:removeFromParent()
        end
    end)

    return colorLayer
end

-- arr 是用于记录从前100次所取的记录 可以根据这个记录来判断一些东西
function test:calcLHDPro(arr)
    --龙 是 1
    --虎 是 2
    --和 是 3

    local descTbl = {"龙", "虎", "和"}
    -- s 表示出现x的概率
    local func1 = function (s, x)
        local v2 = 0
        -- 距离上一次出现x的间隔
        for i, v in ipairs(arr) do
            if v == x then
                v2 = i
                break
            end
        end
        if v2 == 0 then
            v2 = #arr
        end

        s = 1 - s
        ret = 1
        for i = 1, v2+1 do
            ret = ret * s
        end
        print("第" .. (v2+1) .."次出现" .. descTbl[x] .. "的概率是" .. (1-ret))
        return 1-ret
    end

    local p1 = func1(6/13, 1)
    local p2 = func1(6/13, 2)
    local p3 = func1(1/13, 3)
    local desc = "龙：".. p1 .. " ----- 虎：".. p2 .. " ---- 和：".. p3
    print(desc)
    qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = desc})
end

function test:showLHDPro( ... )
    local arr = Cache.lhdinfo.tab_ludan
    local len =  #arr
    print(">>>>>>> len", len)
    self.long_num = 0
    self.hu_num = 0
    self.he_num = 0

    for i = 1, len do
        local section = arr[i]
        if tonumber(section) == 1 then
            self.long_num  = self.long_num + 1
        end
        if tonumber(section) == 2 then
            self.hu_num  = self.hu_num + 1
        end
        if tonumber(section) == 3 then
            self.he_num  = self.he_num + 1
        end
    end
    local p1 = self.long_num/len
    local p2 = self.hu_num/len
    local p3 = self.he_num/len
    print("long_num >>>>", self.long_num/len)
    print("hu_num >>>>", self.hu_num/len)
    print("he_num >>>>", self.he_num/len)

    local desc = "龙：".. p1 .. " ----- 虎：".. p2 .. " ---- 和：".. p3
    print(desc)
    qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = desc})
    -- self:calcLHDPro(Cache.lhdinfo.tab_ludan)
end

function test:showBRNNPro(arr)
    local pTbl = {0,0,0,0}
    for i, v in ipairs(arr) do
        for key, info in pairs(v) do
            pTbl[info.section] = pTbl[info.section] +  (info.odds > 0 and 1 or 0)
        end
    end
    local len = #arr
    local sTbl = {}
    for i, v in ipairs(pTbl) do
        sTbl[i] = v / len
    end
    local desc = table.concat( sTbl, ", ")
   qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = desc}) 
end

function test:showBRPro(arr)
    local pTbl = {0,0,0,0}
    for i, v in ipairs(arr) do
        for key, info in pairs(v) do
            pTbl[info.section] = pTbl[info.section] +  (info.odds > 0 and 1 or 0)
        end
    end
    local len = #arr
    local sTbl = {}
    for i, v in ipairs(pTbl) do
        sTbl[i] = v / len
    end
    local desc = table.concat( sTbl, ", ")
   qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = desc}) 
end


function test:getLayout(args)
    local size = args.size or cc.size(100,100)
    local color = args.color or cc.c3b(255,0,0)
    local pos = args.pos or cc.p(0,0)
    local ap = args.ap or cc.p(0.5,0.5)  
    local opa = args.opa or 255
    local text = args.text

    local layout = ccui.Layout:create()
    layout:setAnchorPoint(ap)
    layout:setClippingEnabled(false)
    layout:setSize(size)
    layout:setBackGroundColor(color)
    layout:setPosition(pos)
    layout:setBackGroundColorType(LAYOUT_COLOR_SOLID)
    layout:setBackGroundColorOpacity(opa)
    if args and args.func then
        addButtonEvent(layout, function ( ... )
            if args and args.func then
                args.func(layout) 
            end
        end)
        if layout.setEnabled then
            layout:setEnabled(true)
        end
        if layout.setTouchEnabled then
            layout:setTouchEnabled(true)
        end
    end
    if text then
        local fontSize = args.ftSize or 40
        local fontAdapt = args.ftAdapt
        local textUI = ccui.Text:create(text, GameRes.font1, 40)
        textUI:setName("text")
        textUI:setPosition3D(cc.p(size.width/2, size.height/2))
        textUI:setColor(cc.c3b(255-color.r, 255-color.g, 255-color.b))
        layout:addChild(textUI)
        local textSize =textUI:getContentSize()
        -- dump(textSize)
        if fontAdapt then
            local xScale = size.width / textSize.width
            local yScale = size.height / textSize.height
            local scale = xScale < yScale and xScale or yScale
            textUI:setScale(scale)
        end
    end
    return layout
end

function test:getFileName()
    local luaoc = require "luaoc"
    local ok,ret = luaoc.callStaticMethod(OBJC_CLASS_NAME,"syyy_getDocumentsAllFileName", {
        cb =  function (jsonstr)
            print(jsonstr)
            local tbl = json.decode(jsonstr)
            self:showFileNameList(tbl.filename)
        end
    })
    
end

function test:showFileNameList( ... )
    local colorLayer = self:createGLtestLayer(255, {color = cc.c4b(0, 0, 0, 180)})
    local listView = ccui.ListView:create()
    listView:setClippingEnabled(false)
    listView:setBackGroundColor(cc.c3b(255,255,255))
    listView:setDirection(ccui.ListViewDirection.vertical)
    listView:setContentSize(cc.size(C_WinSize.width/2, C_WinSize.height))
    listView:setPosition(cc.p(C_WinSize.width/4, 0))
    listView:setBackGroundColorType(LAYOUT_COLOR_SOLID)
    listView:setBackGroundColorOpacity(122)
    colorLayer:addChild(listView)
    local filelist = {"asdf", "123123123", "qwerq"}
    local r = math.random
    for i = 1, #filelist do
        local color = cc.c3b(r(0,255), r(0,255), r(0,255))
        local filename = filelist[i]
        local layout = self:getLayout({size = cc.size(C_WinSize.width/2,100), color = color, text = filename, ftAdapt = true, func=function ( ... )
            local url = cc.FileUtils:getInstance():getWritablePath() ..  filename
            print("url >>>>>>>>>", url)
            local cb = function ( ... )
            end
            self:playVideo({url = url, blocal = true , cb = cb})
            if colorLayer and tolua.isnull(colorLayer) == false then
                colorLayer:removeFromParent()
            end
        end})
        listView:pushBackCustomItem(layout)
    end
end

function test:playVideo(paras)
    dump(paras)
    local luaoc = require "luaoc"
    local ok,ret = luaoc.callStaticMethod(OBJC_CLASS_NAME,"syyy_showAVPlayer", paras)
    if ok then
        return ret
    else
        return ""
    end
end

function test:inputVideo()
    local color = cc.c4b(0, 0, 0, 180)
    local args = {color = color}
    local colorLayer = self:createGLtestLayer(255, args)
    local upValueBox =  self:createEditBox({fontsize = 50, name = "upValue", iSize = cc.size(500, 100), placeTxt = "输入电影名", fontcolor = cc.c3b(255,0,0),ap= cc.p(0,0.5)})
    colorLayer:addChild(upValueBox)
    upValueBox:setPosition3D(cc.p(500,500))

    local upText = ccui.Text:create("电影名：", GameRes.font1, 50)
    upText:setPosition(cc.p(400,500))
    colorLayer:addChild(upText)

    Util:addNormalTouchEvent(colorLayer, function ( method, touch, event )
        if method == "began" then
            lastPos = touch:getLocation()
            return true
        end
    end)

    local confirmText = ccui.Text:create("确认", GameRes.font1, 80)
    confirmText:setPosition(cc.p(C_WinSize.width - 300,300))
    confirmText:setColor(cc.c3b(255,0,0))
    confirmText:setEnabled(true)
    confirmText:setTouchEnabled(true)
    addButtonEvent(confirmText, function ()
        local videoName = upValueBox:getText()
        local url = cc.FileUtils:getInstance():getWritablePath() ..  videoName
        local cb = function ( ... )
        end
        self:playVideo({url = url, blocal = true , cb = cb})
        if colorLayer and tolua.isnull(colorLayer) == false then
            colorLayer:removeFromParent()
        end
    end)

    colorLayer:addChild(confirmText)
end