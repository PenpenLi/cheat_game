local MainView = class("MainView", qf.view)
MainView.TAG = "MainView"

-- local Gallery = require("src.modules.beauty.components.Gallery") --美女相册

MainView.BNT_NUMBER_BG_TAG = 747
MainView.BNT_NUMBER_NUMBER_TAG = 748 
MainView.LIST_VIEW_INIT_NUM = 4

local AnimationConfig = import(".config.AnimationConfig")
function MainView:ctor(parameters)
    self.super.ctor(self, parameters)
    self:init(parameters)
end

function MainView:getRoot() 
    return LayerManager.MainLayer 
end 

function MainView:initWithRootFromJson()
    return GameRes.mainViewJson
end

function MainView:init(parameters)
    self.bnt = {}
    self.upAreaBtns = {}--上面的
    self.item_num = 0
    self.winSize = cc.Director:getInstance():getWinSize()

    if FULLSCREENADAPTIVE then
        self:initFullScreenAdaptive()
    end
    self:initUI()
    self:initAnimate()
    self:initGames()
    self:enterMainView()
    self:initTouchEvent({clickOnlyTop = true})
    qf.event:dispatchEvent(ET.BG_CLOSE)
    qf.event:dispatchEvent(ET.NET_USER_TASKLIST_REQ)
end

function MainView:initFullScreenAdaptive()
    local dx = (cc.Director:getInstance():getWinSize().width-1920)/2

    for k, v in pairs(self.root:getChildren()) do
        Util:setPosOffset(v, {x = dx})
        
    end
end

function MainView:initUI()
    local shopHandler = {
        function (sender)
            self:onButtonEvent(sender)
        end, 
        function (sender)
            sender:setScale(1.1)
        end,
        nil,
        function (sender)
            sender:setScale(1.0)
        end
    }

    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "playerP",           path = "Panel_user_info",                  handler = nil},
        {name = "playerIcon",        path = "Panel_user_info/Image_head_frame", handler = defaultHandler},
        {name = "playerNickTxt",     path = "Panel_user_info/Label_name",       handler = nil},               
        {name = "playerIdTxt",       path = "Panel_user_info/Label_id",         handler = nil},
        {name = "goldImag",          path = "Panel_user_info/gold_bg",          handler = defaultHandler},
        {name = "bindBtn",          path = "Panel_user_info/Btn_bindPhone",          handler = defaultHandler},
        

        {name = "playerBg",          path = "Panel_top/Image_title",             handler = defaultHandler},
        {name = "playerGoldBg",      path = "Panel_top/Panel_gold",             handler = defaultHandler},
        {name = "gold_buy_mark_img", path = "Panel_top/Panel_gold/Image_plus",  handler = defaultHandler},
        {name = "playerGoldTxt",     path = "Panel_top/Panel_gold/Label_gold",  handler = defaultHandler},
        {name = "image_gold",        path = "Panel_top/Panel_gold/Image_gold",  handler = defaultHandler},

        {name = "shopBtn",          path = "Panel_bottom/Button_shop",          handler = shopHandler},
        {name = "safeBox",          path = "Panel_bottom/Button_bank",          handler = defaultHandler},
        {name = "exchangeBtn",      path = "Panel_bottom/Button_exchange",      handler = defaultHandler},
        {name = "activeBtn",        path = "Panel_bottom/Button_active",        handler = defaultHandler},
        {name = "settingBtn",       path = "Panel_bottom/Button_set",           handler = defaultHandler},
        {name = "mailBtn",          path = "Panel_bottom/Button_mail",          handler = defaultHandler},

        {name = "gameslistP",       path = "ListView_game",                     handler = nil},
        {name = "downloadBtn",      path = "PageView_9/Panel_12/Image_11/copyBtn",  handler = defaultHandler},
        {name = "arrowBtn",         path = "Panel_top/Panel_arrow",                       handler = defaultHandler},

        {name = "activityPannel",   path = "Panel_left_up",                      handler = defaultHandler},
        {name = "wanfaBtn",         path = "Panel_left_up/Button_wanfa",         handler = defaultHandler},
        {name = "customerBtn",      path = "Panel_left_up/Button_customer",      handler = defaultHandler},
        {name = "retMoneyBtn",      path = "Panel_left_up/Button_RetMoney",      handler = defaultHandler},
        {name = "hongBaoBtn",       path = "Panel_left_up/Button_Hongbao",   handler = defaultHandler},
        {name = "luckBtn",          path = "Panel_left_up/Button_Luck",          handler = defaultHandler},
        {name = "agencyBtn",        path = "Panel_left_up/Button_Agency",        handler = defaultHandler},

        {name = "slidePage",        path = "PageView_9",                        },
        {name = "slidePic",         path = "PageView_9/Panel_12/Image_11",       },
        {name = "dicate",           path = "dicate",       }
    }

    Util:bindUI(self, self.root, uiTbl)
    self.arrowBtn:setVisible(false)
    
    if FULLSCREENADAPTIVE then
        local offset = self.winSize.width-1920
        self.gameslistP:setContentSize(cc.size(1433 + offset, 750))
        Util:setPosOffset(self.playerBg, {x= -offset/2, y = 0})
        Util:setPosOffset(self.playerGoldBg, {x= -offset/2, y = 0})
        Util:setPosOffset(self.playerP, {x= -offset/2, y = 0})
        Util:setPosOffset(self.slidePage, {x= -offset/4, y = 0})
        Util:setPosOffset(self.dicate, {x= -offset/4, y = 0})
        Util:setPosOffset(self.activityPannel, {x= offset/2, y = 0})
        Util:setPosOffset(self.exchangeBtn, {x= offset/2, y = 0})
        Util:setPosOffset(self.shopBtn, {x= offset/2, y = 0})

        Util:setPosOffset(self.settingBtn, {x= -offset/2 + Util:adaptScreenNumber(20), y = 0})
        Util:setPosOffset(self.safeBox, {x= -offset/2 + Util:adaptScreenNumber(60), y = 0})
        Util:setPosOffset(self.mailBtn, {x= -offset/2 + Util:adaptScreenNumber(100), y = 0})
        Util:setPosOffset(self.activeBtn, {x= -offset/2 + Util:adaptScreenNumber(140), y = 0})

        Util:setPosOffset(self.gameslistP, {x= -94, y = -25})
    else
        self.gameslistP:setContentSize(cc.size(1433, 750))
        Util:setPosOffset(self.gameslistP, {x= 6, y = -25})
    end

    self.playerP.pos = cc.p(self.playerP:getPositionX(), self.playerP:getPositionY())
    self.gameslistP.pos = cc.p(self.gameslistP:getPositionX(), self.gameslistP:getPositionY())
    self:setRedHint(self.mailBtn, Cache.mailInfo:checkNewMail())
    self.downloadBtn:setVisible(false)
    self.wanfaBtn:setVisible(false)
    self:showSlideImage()

    self:initMoveAbleBtnPos()
    --暂且是 从右往左 一次是 首充红包
    self:refreshHongBaoBtn()
    self:refreshBindRewardBtn()
    self:refreshAgencyBtn()
end

function MainView:initMoveAbleBtnPos()
    --从左往右的顺序依次是
    -- 客服 周返现 首充红包 绑定代理 联系代理
    self._movePosTbl = {
        [1] = self.customerBtn:getPosition3D(),
        [2] = self.retMoneyBtn:getPosition3D(),
        [3] = self.hongBaoBtn:getPosition3D(),
        [4] = self.luckBtn:getPosition3D(),
        [5] = self.agencyBtn:getPosition3D()
    }
end

function MainView:refreshMoveAbleBtnPos()
    local btnList = {
        self.customerBtn,
        self.retMoneyBtn,
        self.hongBaoBtn,
        self.luckBtn,
        self.agencyBtn
    }
    local cnt = 1
    for i, v in ipairs(btnList) do
        if v:isVisible() then
            v:setPosition3D(self._movePosTbl[cnt])
            cnt = cnt + 1
        end
    end
end

function MainView:refreshAgencyBtn( ... )
    --版本兼容
    self.agencyBtn:setVisible(tonumber(GAME_VERSION_CODE) < 440)

    if Cache.user:isProxy() then
        self.agencyBtn:setVisible(false)
    end
    self:refreshMoveAbleBtnPos()
end

function MainView:refreshBindRewardBtn()
    if Cache.user:isBindPhone() then
        self.bindBtn:setVisible(false)
    end
end

function MainView:refreshHongBaoBtn()
    self.hongBaoBtn:setVisible(Cache.user.first_recharge_flag == 1)
    self:refreshMoveAbleBtnPos()
end

function MainView:refreshLuckBtn( ... )

    local animName = "anim"
    if self.luckBtn:getChildByName(animName) then
        self.luckBtn:removeChildByName(animName)
    end

    --自己是代理
    if Cache.user:isProxy() then
        self.luckBtn:setVisible(false)
    elseif Cache.agencyInfo:checkBindAgency() then --绑定了代理的情况下 直接弹出好运来
        self:initBtnAnimation(self.luckBtn, AnimationConfig.XIA_FEN_DUI_HUAN, {x  = 0, y= -7}, animName)
    else --未绑定代理的情况下 打开好运来 弹出绑定邀请码弹窗
        self:initBtnAnimation(self.luckBtn, AnimationConfig.BIND_DING_DAI_LI, {x  = 0, y= -7}, animName)
    end
    self:refreshMoveAbleBtnPos()
end

function MainView:refreshCustomerBtn( ... )
    if self.customerBtn.bNewMsg == true then
        return
    end
    if self.customerBtn:getChildByName("newMsgAni") then
        self.customerBtn:removeChildByName("newMsgAni")
    end
    local face = self:initBtnAnimation(self.customerBtn, AnimationConfig.NEWMESSAGE, {x  = -130, y= -100}, "newMsgAni")
    self.customerBtn.bNewMsg = true
end

--普通按键相关
function MainView:onButtonEvent(sender)
    if not self.isCantouch then
        return
    end
    if sender.name == "settingBtn" then
        qf.event:dispatchEvent(ET.SETTING)
    elseif sender.name == "shopBtn" then
        self.shopBtn:setScale(1.0)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击大厅商城") end
        qf.event:dispatchEvent(ET.SHOP)

    elseif sender.name == "customBtn" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.hall_txt_3})

    elseif sender.name == "downloadBtn" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.hall_txt_2})
        local share_url = GameTxt.share_url_android
        if qf.platform:getRegInfo().os == "ios" then
            share_url = GameTxt.share_url_ios
        end
        qf.platform:copyTxt({txt = share_url})
    elseif sender.name == "goldImag" or sender.name == "playerGoldBg" or sender.name == "gold_buy_mark_img" 
           or sender.name == "playerGoldTxt" or sender.name == "image_gold" then

        -- 进入商城事件
        local enterShop = function (sender)
            if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then 
                game.uploadError(" 点击大厅头像旁的+进入商城") 
            else
                local bookmarkIndex = sender == goldImag and PAY_CONST.BOOKMARK.GOLD or PAY_CONST.BOOKMARK.DIAMOND
                qf.event:dispatchEvent(ET.SHOP)
                -- qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = bookmarkIndex})
                qf.platform:umengStatistics({umeng_key = "Shopping_Mall"})--点击上报
            end
        end

        enterShop(sender)

    elseif sender.name == "playerIcon" then
        qf.event:dispatchEvent(ET.PERSONAL_INFO)
        qf.platform:umengStatistics({umeng_key = "Personal"})--点击上报
    elseif sender.name == "safeBox" then
        qf.event:dispatchEvent(ET.SAFE_BOX)
        qf.platform:umengStatistics({umeng_key = "SafeBox"})--点击上报
    elseif sender.name == "exchangeBtn" then
        qf.event:dispatchEvent(ET.EXCHANGE)
    elseif sender.name  == "activeBtn" then
            qf.event:dispatchEvent(ET.NEWACITIVY)
    elseif sender.name  == "wanfaBtn" then
            qf.event:dispatchEvent(ET.GAMERULE)        
    elseif sender.name == "mailBtn" then
        local cb = function ()
            qf.event:dispatchEvent(ET.MAIL)
        end
        Cache.mailInfo:requestMailInfo(cb)
    elseif sender.name == "customerBtn" then
        sender.bNewMsg = false
        if self.customerBtn:getChildByName("newMsgAni") then
            self.customerBtn:removeChildByName("newMsgAni")
        end
        qf.event:dispatchEvent(ET.CUSTOM_CHAT,{autoLink = true})
    elseif sender.name == "retMoneyBtn" then
        qf.event:dispatchEvent(ET.RETMONEY)
    elseif sender.name == "hongBaoBtn" then
        qf.event:dispatchEvent(ET.HONGBAO,{bForeShow = true})
    elseif sender.name == "luckBtn" then
        qf.event:dispatchEvent(ET.GOOD_LUCK)
    elseif sender.name == "agencyBtn" then
        qf.event:dispatchEvent(ET.AGENCY)
    elseif sender.name == "bindBtn" then
		qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 6})		
    else
        if sender.name then
            logd(string.format("%s not bind clickistener", sender.name))
        end
    end
end

function MainView:setRedHint(sender, bshow)
    if type(sender) == "string" then
        sender = self[sender]
    end
    local redHint = sender:getChildByName("redHint")
    if redHint then
        redHint:setVisible(bshow)
    end

end

--累计登陆
function MainView:NewTotalLodinShow()
    -- body
    local newtotallogin = ccui.Helper:seekWidgetByName(self.root, "newtotallogin")
    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and Cache.user.show_cumulate_login_or_not == 0 then--大转盘
        newtotallogin:setVisible(true)
        table.insert(self.upAreaBtns, newtotallogin)
        local gold = ccui.Helper:seekWidgetByName(newtotallogin, "Image_99")
        gold:setPosition(cc.p(-43 + newtotallogin:getContentSize().width / 2, -16 + newtotallogin:getContentSize().height / 2))
        local newtotalloginicon = ccui.Helper:seekWidgetByName(newtotallogin, "newtotalloginicon")
        local newtotallogindian = ccui.Helper:seekWidgetByName(newtotallogin, "dian")
        newtotalloginicon:stopAllActions()
        for i = 1, 3 do
            local xing = ccui.Helper:seekWidgetByName(newtotalloginicon, "xing" .. i)
            xing:stopAllActions()
            xing:setOpacity(0)
        end
        if Cache.user.cumulate_login_reward == 1 then
            newtotallogindian:setVisible(true)
            newtotalloginicon:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.Spawn:create(
                        cc.EaseBounceOut:create(cc.JumpBy:create(1, cc.p(0, 0), 10, 1)), 
                        cc.Sequence:create(cc.DelayTime:create(0.145), cc.ScaleTo:create(0.05, 1.05, 0.95), cc.ScaleTo:create(0.1, 1, 1))
                    ), 
                    cc.DelayTime:create(0.3), 
                    cc.CallFunc:create(function(...)
                        -- body
                        newtotalloginicon:loadTexture(GameRes.ljdl_main_icon2)
                        for i = 1, 3 do
                            local xing = ccui.Helper:seekWidgetByName(newtotalloginicon, "xing" .. i)
                            xing:runAction(cc.Sequence:create(
                                cc.DelayTime:create(math.random(1, 3) * 0.1), cc.ScaleTo:create(0, 0.1), cc.FadeIn:create(0), 
                                cc.Spawn:create(cc.RotateBy:create(0.8, 60), cc.ScaleTo:create(0.8, 1.2)), 
                            cc.FadeOut:create(0.3)))
                        end
                    end), 
                    cc.DelayTime:create(2.5), 
                    cc.CallFunc:create(function(...)
                        -- body
                        newtotalloginicon:loadTexture(GameRes.ljdl_main_icon1)
                    end)
                )))
            else
                newtotallogindian:setVisible(false)
                newtotalloginicon:loadTexture(GameRes.ljdl_main_icon1)
                for i = 1, 2 do
                    local xing = ccui.Helper:seekWidgetByName(newtotalloginicon, "xing" .. i)
                    xing:setScale(0.1)
                    self:runAction(cc.RepeatForever:create(cc.Sequence:create(
                        cc.CallFunc:create(function(...)
                            -- body
                            xing:runAction(cc.Sequence:create(
                                cc.DelayTime:create(0.3 + (i - 1) * 0.3), cc.ScaleTo:create(0, 0.1), cc.FadeIn:create(0), 
                                cc.Spawn:create(cc.RotateBy:create(0.8, 60), cc.ScaleTo:create(0.8, 1.2)), 
                            cc.FadeOut:create(0.3)))
                        end), 
                        cc.DelayTime:create(4)
                    )))
                end
            end
            newtotallogin:setTouchEnabled(true)
            addButtonEvent(newtotallogin, function(...)
                -- body
                if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击大厅累计登陆按钮") end
                qf.platform:umengStatistics({umeng_key = "page_land"})--点击上报
                qf.event:dispatchEvent(ET.SHOW_NEWTOTALLOGIN)
            end)
        else
            newtotallogin:setVisible(false)
        end
end
    
--初始化游戏图标
function MainView:initGames()
    --集合包
    if Cache.user.game_list_type == 1 then
        self.gameslistP:setVisible(false)
        self:initSingleGame()
    elseif Cache.user.game_list_type == 2 then
        self.gameslistP:setVisible(true)
        self:initGatherGame()
    end
end

function MainView:initSingleGame()
    -- body
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.gameRoomP:setPosition(cc.p(210, 160))
    end
    self.gameRoomP:removeAllChildren()
    for k, v in pairs(Cache.user.upGameList) do
        if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
            local gameview = ccui.ImageView:create()
            gameview:setTouchEnabled(true)
            gameview:setPositionY(995)
            gameview:loadTexture(string.format(GameRes["MainSigleGame"], v.name, v.status))
            if v.status == "0" then
                addButtonEvent(gameview, function(...)
                    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击大厅单包上面的游戏" .. v.name) end
                    -- body 主大厅里各个子游戏大厅的入口
                    if v.name == "1" then
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "zjhhall"})
                    elseif v.name == "2" then
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "niuniuhall"})
                        ModuleManager.niuniuhall:openErji({kind = "kanpai"})
                    elseif v.name == "3" then
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "zhajinniuhall"})
                        ModuleManager.zhajinniuhall:openErji({kind = "zhajinniu"})
                    elseif v.name == "4" then
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "hall"})
                    elseif v.name == "6" then
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "lhdhall"})
                    end
                end)
            else
                addButtonEvent(gameview, function(...)
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.developing})
                end)
            end
            self.root:addChild(gameview, 2)
            table.insert(self.upAreaBtns, gameview)
        end
    end

    local sigleRoom = Cache.user.downGameList[1]
    for roomlevel = 1, 6 do
        local roominfoList = {}
        if sigleRoom.name == "1" then
            roominfoList = Cache.zhajinhuaconfig.zhajinhua_room_arr[roomlevel]
        elseif sigleRoom.name == "2" then
            roominfoList = Cache.kanconfig.bull_classic_room_arr[roomlevel]
        elseif sigleRoom.name == "3" then
            roominfoList = Cache.zhajinniuconfig.bull_fry_room_arr[roomlevel]
        end
        local room = self.gameRoomItem:clone()
        local roombtn = room:getChildByName("itembtn")
        local roomdifen = roombtn:getChildByName("itemdifen")
        local roomlock = roombtn:getChildByName("lock")
        roomlock:setVisible(roominfoList.disable == 1)
        room:setVisible(true)
        roomdifen:setString("底分" .. roominfoList.base_chip)
        room:setPositionX((roomlevel <= 3 and (roomlevel - 1) or (roomlevel - 4)) * room:getContentSize().width)
        room:setPositionY(self.gameRoomP:getContentSize().height - (roomlevel <= 3 and 1 or 2) * room:getContentSize().height)
        room:setTouchEnabled(true)
        room:setName("room" .. roomlevel)
        self.gameRoomP:addChild(room)
        roombtn:loadTextureNormal(string.format(GameRes["MainSigleRoom"], roomlevel))
        if roominfoList.disable ~= 1 then
            addButtonEvent(roombtn, function(...)
                -- body
                if sigleRoom.name == "1" then
                    qf.event:dispatchEvent(Zjh_ET.ENTERGAMECLICK, {level = roominfoList.room_level})
                elseif sigleRoom.name == "2" then
                    qf.event:dispatchEvent(Niuniu_ET.ENTERGAMECLICK, {level = roominfoList.room_level, kind = 2})
                    ModuleManager.niuniuhall:openErji({kind = "kanpai"})
                elseif sigleRoom.name == "3" then
                    qf.event:dispatchEvent(Niuniu_ET.ENTERGAMECLICK, {level = roominfoList.room_level, kind = 3})
                    ModuleManager.zhajinniuhall:openErji({kind = "zhajinniu"})
                end
                if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击大厅单包下面的游戏" .. sigleRoom.name) end
            end)
        else
            addButtonEvent(roombtn, function(...)
                if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击大厅单包下面的游戏（锁了的游戏）" .. sigleRoom.name) end
                qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.developing})
            end)
        end
    end
end

local getOnlineNum = function (name)
    -- body
    local num = 0
    if name == "game_texas" then
        num = Cache.Config.texas_count
    elseif name == "game_tbz" then
        num = Cache.Config.tbz_count
    elseif name == "game_niuniu" then
        num = Cache.Config.bull_classic_room.mount
    elseif name == "game_zhajinniu" then
        num = Cache.Config.bull_fry_room.mount
    elseif name == "game_zjh" then
        num = Cache.Config.bull_zjh_room.mount
    elseif name == "game_lhd" then
        num = Cache.Config.lhd_player_count
    elseif name == "game_br" then
        num = Cache.Config.br_player_count
    elseif name == "game_ddz" then
        num = Cache.Config.ddz_player_count
    end
    return num
end

-- 初始化集合包
function MainView:initGatherGame(...)
    -- body
    local itemModel = ccui.Layout:create()
    itemModel:setContentSize(cc.size(400, 626))
    self.gameslistP:setItemModel(itemModel)
    self.gameslistP:removeAllChildren(true)
    self.gameslistP:setBounceEnabled(true)

    local i = 1
    local gameButton = {}
    local onlineNumberTxt = {}

    local downGameList = clone(Cache.user.downGameList)
    
    if FULLSCREENADAPTIVE == false then
        --非全面屏采用特殊方案 且游戏是百人炸金花、百人牛牛、龙虎斗、扎金花、 抢庄牛牛（420）
        --非全面屏采用特殊方案 且游戏是抢庄牛牛、扎金花、百人牛牛， 百人扎金花、龙虎斗（420）
        -- 2019-09-25 因为产品改了游戏排序，这里特殊处理下
        local specialGameList = tonumber(GAME_VERSION_CODE) >= 420 and {2,1,11,8,6} or {8,2,11,1,6}
        local flag = true
        for i, v in ipairs(downGameList) do
            if v.name ~= "" then 
                local bfind = table.indexof(specialGameList, checknumber(v.name))
                if not bfind then
                    flag = false
                end
            end
        end

        --炸金牛 3 百家乐 10
        if flag then
            if tonumber(GAME_VERSION_CODE) >= 420 then
                downGameList = {
                    {bPlaceholder = false, name = "2", status = "0"},
                    {bPlaceholder = false, name = "1", status = "0"},
                    {bPlaceholder = false, name = "11", status = "0"},
                    {bPlaceholder = false, name = "8", status = "0"},
                    {bPlaceholder = false, name = "6", status = "0"},
                    {bPlaceholder = false, name = "10", status = "0", bNoAni = true, paras = {tip = GameTxt.hall_txt_4}},
                    {bPlaceholder = false, name = "3", status = "0", bNoAni = true, paras = {tip = GameTxt.hall_txt_5}},
                    {bPlaceholder = true, name = "", status = "0"},
                }
            else
                downGameList = {
                    {bPlaceholder = false, name = "8", status = "0"},
                    {bPlaceholder = false, name = "2", status = "0"},
                    {bPlaceholder = false, name = "11", status = "0"},
                    {bPlaceholder = false, name = "1", status = "0"},
                    {bPlaceholder = false, name = "6", status = "0"},
                    {bPlaceholder = true, name = "", status = "0"}
                }
            end
        end
    else
        if tonumber(GAME_VERSION_CODE) >= 420 then
            downGameList[4] = {bPlaceholder = false, name = "10", status = "0", bNoAni = true, paras = {tip = GameTxt.hall_txt_4}}
            downGameList[6] ={bPlaceholder = false, name = "3", status = "0", bNoAni = true, paras = {tip = GameTxt.hall_txt_5}}
        end
    end
    for k, v in pairs(downGameList) do
        local gameinfo = GAMES_CONF[tonumber(v.name)]
        if i % 2 ~= 0 then
            self.gameslistP:pushBackDefaultItem()
        end

        local item = self.gameslistP:getItem(math.ceil(i / 2) - 1)
        i = i + 1
        -- 如果是空的游戏占位，也不处理
        if item and gameinfo and not v.bPlaceholder then 
            local num = getOnlineNum(gameinfo.uniq)
            local button = ccui.Button:create(GameRes.hallGameImage[tonumber(v.name)] .. "_xiazai.png", GameRes.hallGameImage[tonumber(v.name)] .. "_xiazai.png")
            button:setAnchorPoint(cc.p(0.5,0.5))
            button:setName(gameinfo.uniq)
            button.imgIdx = tonumber(v.name)
            if i % 2 == 0 then
                button:setPosition(cc.p(item:getContentSize().width / 2, item:getContentSize().height * 0.8))
            else
                button:setPosition(cc.p(item:getContentSize().width / 2, item:getContentSize().height * 0.2 + 10))
            end
            
            if v.bNoAni then
                -- Util:setSpriteGray(button, true)
            else
                self:initGameBtnAnimation(button, gameinfo.uniq, {y = -18})
            end

            item:addChild(button,1)
            --人数底图
            local playerFrame = ccui.ImageView:create("ui/hall/image_player_num_frame.png")
            playerFrame:setAnchorPoint(cc.p(0.5, 0))
            playerFrame:setName("playerFrame")
            playerFrame:setVisible(true)
            playerFrame:setOpacity(0)
            playerFrame:setCascadeOpacityEnabled(false)

            button:addChild(playerFrame)
            Util:setPosOffset(playerFrame, {x = 233, y = 18})


            --下载标志
            -- local downloadFlag = ccui.ImageView:create("ui/hall/download.png")
            -- downloadFlag:setAnchorPoint(cc.p(0.5, 0.5))
            -- downloadFlag:setName("downloadFlag")
            -- downloadFlag:setPosition(cc.p(85, 155))
            -- playerFrame:addChild(downloadFlag)


            -- -- 下载百分比背景
            local percentNumBg = ccui.ImageView:create("ui/hall/percentNumBg.png")
            percentNumBg:setAnchorPoint(cc.p(0.5, 0))
            percentNumBg:setName("downloadTxtBg")
            -- percentNumBg:setPosition(pos)
            button:addChild(percentNumBg)
            Util:setPosOffset(percentNumBg, {x = 243, y=0})

            --下载百分比
            local percentTxt = ccui.Text:create("0%", GameRes.font1, 30)
            percentTxt:setColor(cc.c3b(233, 226, 117))
            percentTxt:setName("percentTxt")
            percentTxt:setPosition(cc.p(75,19))
            percentNumBg:addChild(percentTxt)

            --下载条背景
            local loadingbarbg = ccui.ImageView:create("ui/hall/loadingbar_bg.png")
            loadingbarbg:setAnchorPoint(cc.p(0.5, 0))
            loadingbarbg:setName("loadingbarbg")
            loadingbarbg:setPosition(cc.p(70,35))
            percentNumBg:addChild(loadingbarbg)

            --下载条
            local loadingbar = ccui.LoadingBar:create("ui/hall/loadingbar.png", 0)
            loadingbar:setAnchorPoint(cc.p(0.5, 0))
            loadingbar:setName("loadingbar")
            loadingbar:setPosition(cc.p(70,35))
            percentNumBg:addChild(loadingbar)

            --初始化操作
            -- downloadFlag:setVisible(false)
            percentNumBg:setVisible(false)

            --绑定进入游戏事件
            self:addGameItemEvent(button, gameinfo.uniq, v.paras)
            gameButton[#gameButton + 1] = button
        end
    end

    for i, v in ipairs(gameButton) do
        local gameName = v:getName()
        local installName = gameName
        --目前只存在未安装情况
        if not GAME_INSTALL_TABLE[installName] then         --未安装
            -- ccui.Helper:seekWidgetByName(v, "downloadFlag"):setVisible(true)
        end
    end
    self._gamesButton = gameButton
    self._onlineNumberTxt = onlineNumberTxt
    self:resumeGameDownload()
end



--恢复子游戏下载
function MainView:resumeGameDownload( ... )
    local HotUpdateMainGlobal = require("src.update.HotUpdateMain")
    if HotUpdateMainGlobal.gameHelper then
        for k,v in pairs(HotUpdateMainGlobal.gameHelper) do
            self:preInstallProgress(v.uniq)
            local paras = {uniq=v.uniq,installProgress=self.installProgress,obj=self}
            v:setInstallProgress(paras)
        end
    end
end

function MainView:installGame(uniq)
    self:preInstallProgress(uniq)
    qf.event:dispatchEvent(ET.INSTALL_GAME,{uniq=uniq,installProgress=self.installProgress,obj=self})
end

function MainView:runGame(uniq)
    local uniqTbl = ModuleManager.gameshall:getUniqTable()
    dump(uniq)
    local data = uniqTbl[uniq]
    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = data.mainStr})
    logd("runGameFunc  uniq", uniq)
    if uniq == "game_niuniu" then
        ModuleManager.niuniuhall:openErji({kind = "kanpai"})
    elseif uniq == "game_zhajinniu" then
        ModuleManager.zhajinniuhall:openErji({kind = "zhajinniu"})
    end
end

function MainView:addGameItemEvent(widget, uniq, paras)
    -- print("123123", widget, uniq)
    -- body
    if not widget or not uniq then
        return
    end

    local uniqTbl = ModuleManager.gameshall:getUniqTable()
    if not uniqTbl[uniq] then
        return
    end

    --合并
    local buttonEvent = function (uniq, typeStr)
        if self.click then return end
        self.click = true
        if typeStr == "download" then
            self:installGame(uniq)
        elseif typeStr == "game" then
            local tblStr = uniq
            if GAME_INSTALL_TABLE[tblStr] then
                self:runGame(uniq)
            else
                self:installGame(uniq)
            end
        elseif typeStr == "update" then

        end
        Util:delayRun(0.2, function (...)
            self.click = false
        end)
    end

    if paras and paras.tip then
        addButtonEvent(widget, function()
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = paras.tip})
        end)
        return
    end
    addButtonEvent(widget, function ()
        if GAME_INSTALL_TABLE[uniq] then
            buttonEvent(uniq, "game") --进入游戏
        else
            buttonEvent(uniq, "download") --下载
        end
    end)
end

function MainView:getGameButton(uniq)
    local button 
    for i, v in ipairs(self._gamesButton) do
        if v:getName() == uniq then
            button = v
        end 
    end
    return button
end

function MainView:preInstallProgress(uniq)
    local button = self:getGameButton(uniq)
    if not button then return end
    button:setTouchEnabled(false)
    local downLoadProgress = ccui.Helper:seekWidgetByName(button, "loadingbar")
    local downloadTxt = ccui.Helper:seekWidgetByName(button, "percentTxt")
    local downloadTxtBg = ccui.Helper:seekWidgetByName(button, "downloadTxtBg")
    local playerFrame = ccui.Helper:seekWidgetByName(button, "playerFrame")
    -- local downloadFlag = ccui.Helper:seekWidgetByName(button, "downloadFlag")

    downLoadProgress:setPercent(0)
    button:setOpacity(255)
    button:setCascadeOpacityEnabled(true)
    button:getChildByName("ani"):setVisible(false)
    downloadTxtBg:setVisible(true)
    playerFrame:setVisible(false)
    downloadTxt:setString("0.00%")
    -- downloadFlag:setVisible(false)

end


function MainView:installProgress(uniq,count,total_count)
    if not self.getGameButton then return end
    local button = self:getGameButton(uniq)
    if not button then return end
    --下载游戏回调
    local downLoadProgress = ccui.Helper:seekWidgetByName(button, "loadingbar")
    local downloadTxt = ccui.Helper:seekWidgetByName(button, "percentTxt")
    local downloadTxtBg = ccui.Helper:seekWidgetByName(button, "downloadTxtBg")
    local playerFrame = ccui.Helper:seekWidgetByName(button, "playerFrame")

    local percent = count*100/total_count
    if total_count == 0 then 
        percent = 100
    end
    percent = percent > 100 and 100 or percent
    local bShowLoading = percent < 100
    downloadTxtBg:setVisible(bShowLoading)
    downloadTxt:setString(string.format("%.2f%%", percent))
    downLoadProgress:setPercent(percent)

    if not bShowLoading then --下载完成后恢复
        button:setOpacity(0)
        button:setCascadeOpacityEnabled(false)
        button:getChildByName("ani"):setVisible(true)
        button:setTouchEnabled(true)
        downloadTxtBg:setVisible(false)
        --下载完成后再更新标志
        Util:delayRun(0.05, function ( ... )
            if not tolua.isnull(self) then
                self:initGameBtnFlagAnimation(button, uniq)
            end
        end)
    end
end

-- 进入主界面，初次进入游戏或者返回主界面调用 
function MainView:enterMainView() 
    if Cache.user.last_week_beauty_rank >= 0 and Cache.user.last_week_beauty_rank <= 2 and Cache.user.is_beauty == true then 
        qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER, {name = "beauty", number = (Cache.user.got_beauty_rank_week_reward == false and 1 or 0)})
    end 
    if not Cache.Config._needJoinAni then 
        self:showAnimation()  
        Cache.Config._needJoinAni = true 
    end
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_POS)
end
    
-- 设置个人基本信息
function MainView:updateUserInfo()
    -- 更新信息栏
    local u = Cache.user
    self.playerNickTxt:setString(u.nick)
    self.playerIdTxt:setString("ID:"..Cache.user.uin)
    print(u.gold)
    print("asdfasdf", type(u.gold))
    self.playerGoldTxt:setString(Util:getFormatString(u.gold))
    self:setRedHint(self.mailBtn, Cache.mailInfo:checkNewMail())
end

-- 更新头像
function MainView:updateUserHead()
    self.playerIcon:removeAllChildren()
    loga("user head url = "..Cache.user.portrait)
    Util:updateUserHead(self.playerIcon, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true, scale = 150, circle=true})
end

-- 更新钻石
function MainView:updateUserDiamond()
end

-- 设置界面是否可点击
function MainView:setTouch(isCantouch)
    self.isCantouch = isCantouch
    self.setAllTouch = function(root)
        for k, v in pairs(root:getChildren())do
            if v.setTouchEnabled then
                if v:isTouchEnabled() and not isCantouch then
                    v:setTouchEnabled(isCantouch)
                    v.cansetTouch = true
                elseif v.cansetTouch then
                    v.cansetTouch = nil
                    v:setTouchEnabled(isCantouch)
                end
            end
            self.setAllTouch(v)
        end
    end
    self.setAllTouch(self.root)
end
            
--播放入场动画
function MainView:showAnimation()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW or self.isCantouch == false then return end
    self:setTouch(false)
    self.gameslistP:setPosition(self.gameslistP.pos)
    
    --用户信息
    local positionX = self.playerP.pos.x
    local positionY = self.playerP.pos.y
    local move_back = cc.MoveTo:create(0, cc.p(positionX, positionY + 500))
    self.playerP:runAction(move_back)
    local move_back1 = cc.MoveTo:create(0.5, cc.p(positionX, positionY - 500))
    local ease = cc.EaseExponentialOut:create(move_back1)
    self.playerP:runAction(ease)

    if Cache.user.game_list_type == 2 then--集合包
        --游戏panel
        local positionX = self.gameslistP.pos.x
        local positionY = self.gameslistP.pos.y
        local move_back = cc.MoveTo:create(0, cc.p(positionX + 2000, positionY))
        self.gameslistP:runAction(move_back)
        local move_back1 = cc.MoveTo:create(1, cc.p(positionX - 2000, positionY))
        local ease = cc.EaseExponentialOut:create(move_back1)
        self.gameslistP:runAction(cc.Sequence:create(
                ease,
                cc.CallFunc:create(function ()
                    --游戏列表动画结束
                    self:setTouch(true)
                    --在这里展示新手引导
                    if Util:checkInReviewStatus() then
                        self:showGuideView()
                    end
                end)
            ))
    elseif Cache.user.game_list_type == 1 then--单包
        for i = 1, 6 do
            local gameroom = self.gameRoomP:getChildByName("room" .. i)
            gameroom:setPositionX(1605)
            local pos = cc.p(i <= 3 and ((i - 1) * gameroom:getContentSize().width) or ((i - 4) * gameroom:getContentSize().width), gameroom:getPositionY())
            gameroom:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.15 * (i <= 3 and (i - 1) or (i - 2))), 
                cc.MoveTo:create(0.25, cc.p(pos.x - 30, pos.y)), 
                cc.MoveTo:create(0.03, cc.p(pos.x - 15, pos.y)), 
                cc.MoveTo:create(0.02, cc.p(pos.x - 0, pos.y))
            ))
        end
    end
end

function MainView:showGuideView( ... )
    local device = cc.Application:getInstance():getTargetPlatform()
    if device == cc.PLATFORM_OS_WINDOWS then
        return
    end
    if not Cache.user.guide_to_game or Cache.user.guide_to_game == 0 then
        return
    end
    local uniq = Cache.user.guide_to_game_uniq
    local gameBtn = self:getGameButton(Cache.user.guide_to_game_uniq)
    if not gameBtn then return end
    local dis_y = gameBtn:getPositionY()
    local dis_x = 0
    if FULLSCREENADAPTIVE then
        dis_x = -(cc.Director:getInstance():getWinSize().width-1920)/2
    end
    local posToRoot = cc.p(self.gameslistP:getPositionX() + gameBtn:getPositionX() + gameBtn:getParent():getPositionX() + dis_x, self.gameslistP:getPositionY() + gameBtn:getParent():getPositionY() + dis_y)
    qf.event:dispatchEvent(ET.GUIDE,{cb = function (paras)
        if paras and paras == "pass" then
            qf.event:dispatchEvent(ET.SHOWHALLPOPVIEW)
        end
    end, gameBtnNode = gameBtn, uniq = uniq, btnAni = self:getAnimate(uniq), btnFlagAni = self:getGameFlagAnimation(uniq), pos = posToRoot})
end

--大转盘icon
function MainView:TurnTableIconShow()
end

function MainView:showSlideImage() 
    local len = #Cache.Config.banner_pic
    local picList = self.slidePage:getChildren()
    local picLen = #picList
    for i = 1, len - picLen do
        local picTemp = picList[1]:clone()
        self.slidePage:addPage(picTemp)
    end
    picList = self.slidePage:getChildren()
    picLen = #picList

    local maxCnt = 3
    -- local downloadImg
    -- downloadImg = function (imgUrl, node, cnt)
    --     --进行次数限制 最大次数为maxCnt
    --     cnt = cnt or 0
    --     cnt = cnt + 1
    --     if cnt > maxCnt then
    --         return
    --     end
    --     qf.downloader:execute(imgUrl, 10,
    --         function(path)
    --             if not tolua.isnull(self) then
    --                 if imgUrl == nil then return end
    --                 node:loadTexture(path)
    --             end
    --         end,
    --         function()
    --             -- print("img >>>>>>>>>>>>>> failed!!!")
    --             downloadImg(imgUrl, node, cnt)
    --         end,
    --         function()
    --             -- print("img >>>>>>>>>>>>>> timeout!!!")
    --             downloadImg(imgUrl, node, cnt)
    --         end
    --     )
    -- end


    local cb = function (node, args)
        node:setTouchEnabled(true)
        addButtonEvent(node, function ( ... )
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.copy_tips})
            qf.platform:copyTxt({txt = args.copy_url})
        end)
        if args and args.pic_path then
            local imgUrl = args.pic_path
            Util:downloadImg(imgUrl, node, 0, 3)
        end
    end

    for i, v in ipairs( picList ) do
        local node = v:getChildByName("Image_11")
        cb(node, Cache.Config.banner_pic[i])
    end
    
    self.slidePage:stopAllActions()
    self.slidePage:getCurPageIndex()
    schedule(self.slidePage, function ()
        local curPage = self.slidePage:getCurPageIndex()
        if curPage == picLen-1 then
            self.slidePage:scrollToPage(0)
        else
            self.slidePage:scrollToPage(curPage + 1)
        end
    end, 4)

    local _item = self.dicate:getChildByName("item")
    _item:getChildByName("grey"):setVisible(true)
    local posX = _item:getPositionX()
    local diffX = 40
    self._dicatorList = {_item}
    for i = 2, picLen do
        local tempItem = _item:clone()
        self.dicate:addChild(tempItem)
        self._dicatorList[#self._dicatorList + 1] = tempItem
    end
    
    if picLen % 2== 0 then --偶数
        local middleIdx = (picLen+1)/2
        for i = 1, picLen do
            local _x = posX + (i - middleIdx)*diffX
            self._dicatorList[i]:setPositionX(_x)
        end
    else --基数
        local middleIdx = (picLen+1)/2
        for i = 1, picLen do
            local _x = posX +(i-middleIdx)*diffX
            self._dicatorList[i]:setPositionX(_x)
        end
    end
    local function setDicateSelectIdx(idx)
        for i, v in ipairs(self._dicatorList) do
            v:getChildByName("white"):setVisible(i == idx)
            v:getChildByName("grey"):setVisible(i ~= idx)
        end
    end
    setDicateSelectIdx(self.slidePage:getCurPageIndex() + 1)

    self:scheduleUpdateWithPriorityLua(function ()
        local curPage = self.slidePage:getCurPageIndex()+1
        setDicateSelectIdx(curPage)
    end, 0.1)
end

--按钮特效统一管理
function MainView:initAnimate()
    -- body
    self.customerBtn:setLocalZOrder(10)
    self:initBtnAnimation(self.customerBtn, AnimationConfig.KEFU, {x = 0, y= -10})
    self:initBtnAnimation(self.image_gold, AnimationConfig.GOLD)
    self:initBtnAnimation(self.exchangeBtn, AnimationConfig.EXCHANGE, {x  = -25, y= -10})
    self:initBtnAnimation(self.shopBtn, AnimationConfig.SHOP, {x  = 3, y= 2})
    self:initBtnAnimation(self.retMoneyBtn, AnimationConfig.RETMONEY, {x  = 0, y= -10})
    self:initBtnAnimation(self.hongBaoBtn, AnimationConfig.HONGBAO, {x  = 0, y= -6})
    self:initBtnAnimation(self.agencyBtn, AnimationConfig.AGENCY, {x  = 0, y= -7})
    self:initBtnAnimation(self.bindBtn, AnimationConfig.BINDPHONE, {x  = 0, y= -7})
    self:refreshLuckBtn()
end

function MainView:initBtnAnimation(sender, anim, offset, faceName)
    local face = Util:addAnimationToSender(sender, {anim = anim, node = sender, posOffset = offset, forever =true})
    if sender == self.customerBtn then
        local bone = face:getBone("kfzi")
        if bone then
            local renderNode = bone:getDisplayRenderNode()
            renderNode:initWithFile("ui/safebox/kefuAni.png")
        end
    end

    if sender == self.image_gold then
        local renderNode = face:getBone("2jb"):getDisplayRenderNode()
        renderNode:initWithFile(Cache.packetInfo:getGoldImg())
    end

    if faceName then
        face:setName(faceName)
    end

    return face
end

function MainView:getAnimate(name)
    local aniTbl = {
        game_niuniu = AnimationConfig.NIUNIU,
        game_zhajinniu = AnimationConfig.ZHAJINNIU,        
        game_zjh = AnimationConfig.ZJH,
        game_lhd = AnimationConfig.LHD,
        game_br = AnimationConfig.BR,
        game_ddz = AnimationConfig.DDZ,
        game_brnn = AnimationConfig.BRNN,
        game_bjl = AnimationConfig.BJL
    }
    return aniTbl[name]
end

function MainView:getGameFlagAnimation(name)
    local gameAnimationConfig = nil
    --这里从数据层获取判断推荐、热门
    local gameInfo = Cache.user:getGameInfoByUniq(name)
    if not gameInfo then return nil end
    --热门
    if gameInfo.hot == 1 then
        gameAnimationConfig = AnimationConfig.HOT
    end
    --推荐
    if gameInfo.suggest == 1 then
        gameAnimationConfig = AnimationConfig.RECOMMEND
    end

    --这个优先级最高，放到后面
    if not GAME_INSTALL_TABLE[name] then
        gameAnimationConfig = AnimationConfig.UPDATE
    end

    return gameAnimationConfig
end

function MainView:initGameBtnAnimation(sender, uniq, offset)
    --加载主动画
    local anim = self:getAnimate(uniq)
    local face = Util:addAnimationToSender(sender, {anim = anim, node = sender, posOffset = offset, forever =true})
    face:setName("ani")
    self:initGameBtnFlagAnimation(sender, uniq)
end

function MainView:initGameBtnFlagAnimation(sender, uniq)
    --先把之前的清除
    if sender:getChildByName("gameFlag") then
        sender:removeChildByName("gameFlag")
    end

    local flagAniConfig = self:getGameFlagAnimation(uniq)
    --这里增加标志
    if flagAniConfig then
        local face = Util:addAnimationToSender(sender, {anim = flagAniConfig, node = sender, posOffset = {x = -120, y = 100}, scale = 1, forever =true})
        face:setName("gameFlag")
    end
end

function MainView:exit()
    local scheduleName = {
        "guangSchedule",
    }

    for i, v in ipairs(scheduleName) do
        if self[v] then
            Scheduler:unschedule(self[v])
            self[v] = nil
        end
    end
end

function MainView:test()
    self.customerBtn:setVisible(false)
    self:refreshMoveAbleBtnPos()
    -- Util:addHongBaoBtn(self, cc.p(300,800))
    -- local globalPoint = cc.p(1050,450)
    -- local scene = cc.Director:getInstance():getRunningScene()
    -- scene:removeChildByName("imgTest5")
    -- scene:removeChildByName("imgTest2")
    -- scene:removeChildByName("imgTest")
    -- local spr = cc.Sprite:create(GameRes.agency_qq_img)
    -- spr:setName("imgTest")
    -- scene:removeChildByName("imgTest")
    -- scene:addChild(spr, 100)
    -- dump(spr:getAnchorPoint())
    -- spr:setPosition(globalPoint)

    -- local spr2 = cc.Sprite:create(GameRes.agency_wx_img)
    -- spr2:setName("imgTest")
    -- local spr3 = cc.Sprite:create(GameRes.agency_wx_img)
    -- spr3:setName("imgTest2")
    -- local nodePoint = self.settingBtn:convertToNodeSpace(globalPoint)

    -- -- convertToNodeSpaceAR 是在 convertToNodeSpace 减去 所使用的节点的anchorPointInPoints 
    -- -- Vec2 nodePoint = convertToNodeSpace(worldPoint);
    -- -- return nodePoint - _anchorPointInPoints;
    --  -- _anchorPointInPoints = ContentSize() * getAnchorPoint()
    -- local nodePointAr = self.settingBtn:convertToNodeSpaceAR(globalPoint)
    -- self.settingBtn:addChild(spr2)
    -- spr2:runAction(cc.MoveTo:create(1, nodePoint))
    -- dump(spr2:getAnchorPoint())
    -- self.settingBtn:addChild(spr3)
    -- spr3:runAction(cc.MoveTo:create(1, nodePointAr))

    -- local toPoint = Util:convertALocalPosToBLocalPos(self.settingBtn, nodePointAr, self.activeBtn)
    -- -- local toPoint = Util:getWorldSpacePos(self.settingBtn, nodePointAr, true)
    -- local spr5 = cc.Sprite:create(GameRes.agency_qq_img)
    -- self.activeBtn:addChild(spr5)
    -- spr5:runAction(cc.MoveTo:create(1, toPoint))
    -- spr5:setName("imgTest5")
end

function MainView:test2()   
    Util:loadAnim(AnimationConfig, false) 
    -- self:initBtnAnimation(self.customerBtn, AnimationConfig.KEFU, {x = -50, y= -10})
    -- self:initBtnAnimation(self.image_gold, AnimationConfig.GOLD)
    -- self:initBtnAnimation(self.exchangeBtn, AnimationConfig.EXCHANGE, {x  = -25, y= -18})
    -- self:initBtnAnimation(self.shopBtn, AnimationConfig.SHOP, {x  = 3, y= 2})
    -- self:initBtnAnimation(self.retMoneyBtn, AnimationConfig.RETMONEY, {x  = -45, y= -7})
    -- self:initBtnAnimation(self.bindRewardBtn, AnimationConfig.BIND, {x  = -45, y= -7})
    -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(GameRes.mainviewAni, function ( ... )
    --     print("success")
    -- end)
end

return MainView