local KangameView      = class("KangameView", qf.view)
local Kanuser          = import(".components.kanuser.Kanuser")
local Kanmyself        = import(".components.kanuser.Kanmyself")
local Gameanimation = import(".components.animation.Kangameanimation") 
local GameAnimationConfig = import(".components.animation.KananimationConfig")
local ChatAnimationConfig = import(".components.animation.AnimationConfig")
local Chat = require("src.common.Chat")
local calcObject     = import(".components.calc")

KangameView.TAG ="KangameView"

KangameView.Back_panel = 233 --退出panel
KangameView.Back_btn   = 234 --退出
KangameView.Change_btn = 235 --换房
KangameView.Back       = 3   --退出打开
KangameView.Handle_panel     = 95 
KangameView.Minefont   = 237 
KangameView.Minefont_panel   = 238 
KangameView.Xiafen_panel     = 319
KangameView.Calc_panel       = 138
KangameView.You_niu          = 162
KangameView.Wu_niu           = 164
KangameView.Chat_btn         = 49
KangameView.Wuhua            = 501
KangameView.Wuxiao           = 505
KangameView.Sizha            = 509
KangameView.StartAgainPanel  = 516
KangameView.StartAgainBtn    = 520
KangameView.Paixing_panel    = 603
KangameView.Paixing_btn      = 602
KangameView.Btn_shop         = 631

KangameView.WINNUM=0

KangameView.Tips = 18000

function KangameView:ctor(parameters)
    self.super.ctor(self,parameters)
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_INGAME_POS)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:initPublicModule()
    self:initChatUI()
    self:initButtonEvents()
    self:initAnimation()
    self:initTouchEvent()
    self:fullScreenAdaptive()
    if Util:checkWifiNetPackage() then
        self:refreshNetStrength()
    else
        self:showDeviceStatus()
    end
	self:chageDeskInfo(Cache.kanconfig:getRoom(parameters.roomid))
end

function KangameView:initChatUI()
    print("initChatUI XXXXXXXXXX")
    local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    self._chat = Chat.new({view=self, ChatCmd = CMD.CHAT})
    self:addChild(self._chat, 5)
    self.chat_txt_layer = self._chat:getChatTxtLayer()
    self:addChild(self.chat_txt_layer, 4)

    --聊天
    self.btn_chat = Chat.getChatBtn()
    self:addChild(self.btn_chat)
    self.btn_chat:setPosition(cc.p(1790, 63))
    self.btn_chat:setLocalZOrder(3)
    -- self.shop
    addButtonEvent(self.btn_chat,function ( )
		-- body
		if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击炸金花聊天") end
        -- print("123123")
        
        -- local myUin = Cache.user.uin
        -- local user = Cache.lhdDesk:getUserByUin(myUin)
        if not Cache.kandesk:checkMeDown() then
        --无座 且自己不是庄家
        -- if (user and user.seatid == -1) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.chat_pangguan_txt})
            return 
        end
		self._chat:show()
		-- if FULLSCREENADAPTIVE then
		-- 	self._chat:setPositionX(-(self.winSize.width -1920)/2)
		-- end
	end)
		-- self._chat:show()
    if FULLSCREENADAPTIVE then
        -- Util:setPosOffset(self.Chat, {x = 420,y = 0})
        Util:setPosOffset(self._chat, {x = self.winSize.width/2-1920/2, y = 0})
        -- self.btn_shop:setPositionX(self.btn_shop:getPositionX()+(self.winSize.width/2-1920/2))
        Util:setPosOffset(self.btn_chat, {x =self.winSize.width/2-1920/2, y = 0})
        -- self.btn_chat:setPosition(cc.p(1822, 63))
    end
end

--显示电池电量和时间
function KangameView:showDeviceStatus( ... )
    -- body
    self.deviceStatus = CommonWidget.DeviceStatus.new({layer = self._device_layer})
    self.deviceStatus:startDeviceStatusMonitor()    --开始检测设备状态(电池电量, 网络信号)
end

function KangameView:fullScreenAdaptive( ... )
    -- body
    if FULLSCREENADAPTIVE then
        self:setPositionX(self.winSize.width/2-1920/2)
        self.btn_shop:setPositionX(self.btn_shop:getPositionX()+(self.winSize.width/2-1920/2))
        -- if self._chat then
        --     self._chat:setPositionX(self._chat:getPositionX()-(self.winSize.width/2-1920/2))
        -- end
        if self.gameChestPop then 
            self.gameChestPop:setPositionX(self.gameChestPop:getPositionX()+(self.winSize.width/2-1920/2))
        end
        self.paixing_panel:setPositionX(self.paixing_panel:getPositionX()-(self.winSize.width/2-1920/2))
        self.back:setPositionX(self.back:getPositionX()-(self.winSize.width/2-1920/2))
        self.back_panel:setPositionX(self.back_panel:getPositionX()-(self.winSize.width/2-1920/2))
        self._device_layer:setPositionX(self._device_layer:getPositionX()-(self.winSize.width/2-1920/2))
        self.deskIDTxt:setPositionX(self.deskIDTxt:getPositionX()+(self.winSize.width/2-1920/2))
    end
end

function KangameView:chageDeskInfo( room )
    -- body
    -- if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
    --     self.deskinfobg:setVisible(false)
    -- end
    if room == nil then
        return
    end
    self.roomid = room.room_level
    self.deskinfobg:setVisible(true)
    ccui.Helper:seekWidgetByName(self.root,"difen"):setString(Niuniu_GameTxt.hall_limt_txt_2 .. Util:getFormatString(Cache.packetInfo:getProMoney(room.base_chip)) .. Cache.packetInfo:getShowUnit())
    self.limit_gold = Cache.kanconfig:getLimitMoney(room.room_level)
    -- dump
    Cache.kanconfig:setCurDeskInfo(room)
    ccui.Helper:seekWidgetByName(self.root,"douniu_bg"):loadTexture(Cache.kanconfig:getUIResource(Cache.kanconfig.UI_DESK))
    local uiTipRes = Cache.kanconfig:getUIResource(Cache.kanconfig.UI_TIP)
    self.notice_panel:setBackGroundImage(uiTipRes, 1)
    Util:getChildEx(self.root, "chupai_notice_panel"):setBackGroundImage(uiTipRes, 1)
    self.startTimeBg:getChildByName("starttime"):setFntFile(Cache.kanconfig:getUIResource(Cache.kanconfig.UI_TIPFNT))
    self.startTimeBg:getChildByName("Image_161"):loadTexture(Cache.kanconfig:getUIResource(Cache.kanconfig.UI_STARTIMG))
    self.startTimeBg:loadTexture(Cache.kanconfig:getUIResource(Cache.kanconfig.UI_STARTIMGBG))
    self.deskinfobg:setOpacity(0)
    self.deskinfobg:setCascadeOpacityEnabled(false)

    local digitalfnt = Cache.kanconfig:getUIResource(Cache.kanconfig.UI_DIGITALFNT)
    Util:getChildEx(self.root, "start_panel/font_panel/font"):setFntFile(digitalfnt)
    Util:getChildEx(self.root, "chupai_notice_panel/notice"):setFntFile(digitalfnt)
    self.notice_panel:getChildByName("notice"):setFntFile(digitalfnt)
    self.notice_panel:getChildByName("time"):setFntFile(digitalfnt)
    Util:getChildEx(self.root, "calc_panel"):setBackGroundImage(Cache.kanconfig:getUIResource(Cache.kanconfig.UI_DNNUMDI), 1)
end

function KangameView:DESKINFO_CLOSE()
    -- self.deskinfobg:setVisible(false)
end

--关闭撮合
function KangameView:CHUOHE_CLOSE()
    local font = self:getChildByName(KangameView.Tips)
    if font then
        font:removeFromParent()
    end
end

--enter
function KangameView:enter()
    -- MusicPlayer:setBgMusic(Niuniu_Games_res.all_music.LOB_BG)
    MusicPlayer:backgroundSineIn()
    -- qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="show",type="nohandle"})
    Util:loadAnim(GameAnimationConfig, true)
end

--初始化动画类
function KangameView:initAnimation()
    self.animation_layout  =  cc.Layer:create()
    Util:setLayerToCenter(self.animation_layout)
    self:addChild(self.animation_layout)
    self.animation_layout:setZOrder(101)
    self.Gameanimation     =  Gameanimation.new({view=self,node=self.animation_layout})  --初始化动画    
end

function KangameView:initPublicModule()--无论什么场次，都需要初始化的模块
	self._users             = {}                                                                     --其他用户panel
	self._myself            = nil                                                                    --玩家自己的panel
    self.root               = ccs.GUIReader:getInstance():widgetFromJsonFile(Niuniu_Games_res.Kan_pai_room)
    self:addChild(self.root)
    ccui.Helper:seekWidgetByName(self.root,"user_first"):setVisible(false)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "back_panel",        path = "quit",                     handler = nil},
        {name = "back_btn",          path = "quit/quit",                handler = nil},
        {name = "ruleBtn",           path = "quit/wanfa",               handler = defaultHandler},
        {name = "safeBox_btn",           path = "quit/safebox",               handler = defaultHandler},
        {name = "paixing_btn",       path = "quit/paixing",             handler = defaultHandler},
        {name = "back",              path = "btn_more",                 handler = nil},
        {name = "handle_panel",      path = "handle_panel",             handler = nil},
        {name = "notice_panel",      path = "notice_panel_0",             handler = nil},
        {name = "xiafen_panel",      path = "xiafen_panel",             handler = nil},
        {name = "calc_panel",        path = "calc_panel",               handler = nil},
        {name = "you_niu",           path = "mine_card_panel/you_niu",  handler = nil},
        {name = "wu_niu",            path = "mine_card_panel/mei_niu",  handler = nil},
        {name = "wuhua",             path = "mine_card_panel/wuhua",    handler = nil},
        {name = "wuxiao",            path = "mine_card_panel/wuxiao",   handler = nil},
        {name = "sizha",             path = "mine_card_panel/sizha",    handler = nil},
        {name = "startAgainPanel",   path = "start_panel",              handler = nil},
        {name = "startAgainBtn",     path = "start_panel/start",        handler = nil},
        {name = "paixing_panel",     path = "paixing",                  handler = nil},
        {name = "btn_shop",          path = "btn_shop",                 handler = defaultHandler},
        {name = "deskinfobg",        path = "deskinfobg",               handler = nil},
        {name = "_device_layer",     path = "_device_layer",            handler = nil},
        {name = "startTimeBg",       path = "starttimebg",              handler = nil},
        -- {name = "btn_chat",          path = "mine_info/btn_chat",       handler = defaultHandler},
        {name = "startTime",         path = "starttimebg/starttime"      },
        {name = "standup_btn",       path = "quit/standup",             handler = defaultHandler},
        -- {name = "chat_layer",       path = "chat_layer",             handler = nil},
    }

    Util:bindUI(self, self.root, uiTbl)
    print(" -------------------- root ------------------")
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then 
        self.btn_shop:setVisible(false)
    end
    -- self.chat_layer:setLocalZOrder(4)
end

function KangameView:onButtonEvent(sender)
    print(sender.name)
    -- body
    if sender.name == "ruleBtn" then
        self.ruleBtn:getParent():setVisible(false)
        qf.event:dispatchEvent(ET.GAMERULE, {GameType = Cache.DeskAssemble:getGameType()})        
    elseif sender.name == "paixing_btn" then
        self:showPaixing()
    elseif sender.name == "btn_shop" then
        qf.event:dispatchEvent(ET.SHOP)
    -- elseif sender.name == "btn_chat" then
    --     self._chat:show()
    elseif sender.name == "standup_btn" then
        self:doStandBtnFunc()
    elseif sender.name == "safeBox_btn" then
        qf.event:dispatchEvent(ET.SAFE_BOX, {inGame = true})
    end
end

function KangameView:doStandBtnFunc()
    self.back_panel:setVisible(false)
    print("isGameOvering >>>>>", self.isGameOvering)
    --游戏中 true

    --自己 动画 游戏
    --游戏状态正在进行中 自己状态也在游戏中
    --游戏结算中 且 但是自己在结算状态中
    if Cache.kandesk:checkGameRunning() and (not Cache.kandesk:checkMeReady()) then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=Niuniu_GameTxt.niu_txt_1})
    elseif self.isGameOvering and Cache.kandesk._result_info[Cache.user.uin] and Cache.kandesk._result_info[Cache.user.uin].win_money then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=Niuniu_GameTxt.niu_txt_1})
    else
        GameNet:send({
            cmd=Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_UP_REQ,body={
                uin=Cache.user.uin,
                desk_id=Cache.kandesk.deskid
            }
        })
    end
end

function KangameView:setStandUpEnable(bEnable)
    if bEnable then
        self.standup_btn:setOpacity(255)
        self.standup_btn:setTouchEnabled(true)
    else
        self.standup_btn:setOpacity(100)
        self.standup_btn:setTouchEnabled(false)
    end
end

function KangameView:refreshStandUpBtn()
    --自己在座位上的时候 才可以点击站起
    print(self._users[Cache.user.uin])
    print("uin >>>>>>>>>>>", Cache.user.uin)
    if self._users[Cache.user.uin] then
        self:setStandUpEnable(true)
    else
        self:setStandUpEnable(false)
    end
end

function KangameView:showPaixing()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击抢庄牛牛牌型") end
    self.back_panel:setVisible(false)
    self.paixing_panel:setVisible(true)
    self.paixing_panel:setLocalZOrder(6)
    self.root:setTouchEnabled(true)
    ccui.Helper:seekWidgetByName(self.root,"douniu_bg"):setTouchEnabled(true)
end

function KangameView:showDesk()
    -- body
    self.paixing_panel:setVisible(false)
    self.back_panel:setVisible(false)
    self.root:setTouchEnabled(false)
    ccui.Helper:seekWidgetByName(self.root,"douniu_bg"):setTouchEnabled(false)
end

function KangameView:initButtonEvents()
	-- body
    --牌型介绍

    self.root.noEffect = true
    addButtonEvent(self.root,function ( ... )
        self:showDesk()
    end)

    ccui.Helper:seekWidgetByName(self.root,"douniu_bg").noEffect = true
    addButtonEvent(ccui.Helper:seekWidgetByName(self.root,"douniu_bg"),function ( ... )
        self:showDesk()
    end)

	--退出按钮
    addButtonEvent(self.back_btn,function ()
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击抢庄牛牛退出") end
        -- body
        if Cache.kandesk:checkGameRunning() and (not Cache.kandesk:checkMeReady()) and Cache.kandesk:checkMeDown()  then
            qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="show",type="kanmyselfquit"})
        else
            -- 连续两局不操作的情况下 服务器会先发送退出桌子通知 然后点击退出按钮的时候 
            if self._myself and self._myself._outRoomId  then
                Scheduler:unschedule(self._myself._outRoomId)
                self._myself._outRoomId = nil
                self._myself:outRoomWithGameNotGoing()
            else
                 qf.event:dispatchEvent(Niuniu_ET.RE_QUIT, {quitByUserFore = true})
            end
        end

        if tolua.isnull(self) == false then
            self.back_panel:setVisible(false)
        end
    end)
    self.back_panel:setLocalZOrder(6)
    Util:enlargeBtnClickArea(self.back_btn, {x = 1.4, y = 2})
    
    Util:registerKeyReleased({self = self,cb = function ()
        -- body
        if Cache.kandesk:checkGameRunning() and not Cache.kandesk:checkMeReady() then
            qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="show",type="kanmyselfquit"})
        else
            qf.event:dispatchEvent(Niuniu_ET.RE_QUIT)
        end
        self.back_panel:setVisible(false)
    end})


    --打开backpanel
     addButtonEvent(self.back,function ()
        -- body
        if  self.back_panel:isVisible() then
            self.back_panel:setVisible(false)
        else
            self.back_panel:setVisible(true)
            self.paixing_panel:setVisible(false)
            -- loga("Cache.kandesk.status  "..Cache.kandesk.status.."   "..Cache.kandesk._player_info[Cache.user.uin].status)
            -- if Cache.kandesk.status and Cache.kandesk:checkGameRunning() and Cache.kandesk._player_info[Cache.user.uin] and (not Cache.kandesk:checkMeReady())  then
            --     self.change_btn:setOpacity(130)
            --     self.change_btn:setTouchEnabled(false)
            -- --由于出现_player_info clear 后可能不在桌子内
            -- elseif Cache.kandesk._player_info[Cache.user.uin] == nil then
            --     self.change_btn:setOpacity(130)
            --     self.change_btn:setTouchEnabled(false)
            -- else
            --     self.change_btn:setOpacity(500)
            --     self.change_btn:setTouchEnabled(true)
            --     addButtonEvent(self.change_btn,function ( ... )
            --         if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then 
            --             game.uploadError(" 点击抢庄牛牛换桌") 
            --         end

            --         -- body
            --         if (not Cache.kandesk:checkGameRunning()) or (Cache.kandesk:checkMeReady()) then
            --             self:loadingCuoHe()
            --             qf.event:dispatchEvent(Niuniu_ET.CHANGE_TABLE)
            --         else
            --             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Niuniu_GameTxt.Gameing})
            --         end
            --     end)
            -- end

            self:refreshStandUpBtn()
            self.root:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(self.root,"douniu_bg"):setTouchEnabled(true)
        end
        if self.paixing_btn then
            self.paixing_btn:setVisible(true)
        end
    end)

    --聊天
    -- self.btn_chat.noEffect = true
    -- self.btn_chat:setVisible(true)

    if not Util:isHasReviewed() then
        self.btn_chat:setVisible(false)
    end

    self.sitdownLayer = ccui.Helper:seekWidgetByName(self.root,"sitdownLayer")

    local currentTime = socket.gettime()
    for i = 0, 4 do
        local btn = self.sitdownLayer:getChildByName("sitDown" .. i)
        btn:setTouchEnabled(true)
        btn:setEnabled(true)
        addButtonEvent(btn, function ( ... )
            if Cache.kandesk:checkMeDown() then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = Niuniu_GameTxt.niu_txt_2})
                return
            end
            -- fix bug 服务器主动将用户踢出时的bug
            local userinfo = self._users[Cache.user.uin]
            if userinfo and userinfo._info and userinfo._info.quit == 1 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = Niuniu_GameTxt.niu_txt_2})
                return
            end

            if self.limit_gold then
                if Cache.user.gold < self.limit_gold then
                    if not Cache.packetInfo:isShangjiaBao() then
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = string.format(GameTxt.string_room_limit_3, Util:getFormatString(self.limit_gold), Cache.packetInfo:getShowUnit())})
                    else
                        qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = string.format(Util:getReviewStatus() and GameTxt.string_room_limit_5 or GameTxt.string_room_limit_4, Util:getFormatString(self.limit_gold), Cache.packetInfo:getShowUnit()), confirmCallBack = function ( ... )
                            -- 发退桌
                            if Util:getReviewStatus() then
                                qf.event:dispatchEvent(ET.SHOP)
                            else
                                qf.event:dispatchEvent(Niuniu_ET.RE_QUIT, {guideToChat = true})
                            end
                        end})
                    end
                    
                    return
                end
            end

            if self:overLimitCheck() then
                return
            end

            --1s钟 限制一次点击
            local lasttime = socket.gettime()
            if lasttime - currentTime > 1 then
                currentTime = lasttime
                GameNet:send({cmd=Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_SEAT_REQ,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid}})
            end
        end)
    end

    self.deskIDTxt  =ccui.Helper:seekWidgetByName(self.root, "deskIDTxt")
end

--当用户进场的时候或者坐下的时候 将所有上一局
function KangameView:clearLastViewStatus()
    if self._lastsIdList and type(self._lastsIdList) == "table" then
        for i, v in ipairs(self._lastsIdList) do
            Scheduler:unschedule(v)
        end
        self._lastsIdList = {}
    end
    --删除所有的牌与动画效果
end

function KangameView:noGoldcheck( ... )
    -- 判断用户钱够不够
    if not Cache.packetInfo:isShangjiaBao() then return end
    if Cache.user.gold < self.limit_gold then
        qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = string.format(Util:getReviewStatus() and GameTxt.string_room_limit_5 or GameTxt.string_room_limit_4, Util:getFormatString(self.limit_gold), Cache.packetInfo:getShowUnit()), confirmCallBack = function ( ... )
            -- 发退桌
            if Util:getReviewStatus() then
                qf.event:dispatchEvent(ET.SHOP)
            else
                qf.event:dispatchEvent(Niuniu_ET.RE_QUIT, {guideToChat = true})
            end
        end})
    end
end

function KangameView:overLimitCheck( ... )
    if not Cache.packetInfo:isShangjiaBao() then return false end
    local limitMin, limitMax = Cache.kanconfig:getLimitMinAndMax(self.roomid)
    if Cache.user.gold > limitMax then
        self:showOverLimitPop()
        return true
    end
    return false
end

function KangameView:showOverLimitPop( ... )
    qf.event:dispatchEvent(ET.OVER_ROOM_MAX_LIMIT, {confirmCallBack = function ( ... )
        local roomid = Cache.kanconfig:getAvailableRoom()
        qf.event:dispatchEvent(ET.QUICK_START_GAME, {
            type = QUICKGAME_TYPE.QUICKMATCH,
            roomid = roomid
        })
    end , cancleCallBack = function ( ... )
        -- 【注意】 因为是超上限，所以直接退出桌子
        ModuleManager.kancontroller:outRoomWithGameNotGoing()
    end})
end

--用户自己进场
function KangameView:enterDesk(parameters)
    if parameters.op_uin == Cache.user.uin then
        if not Cache.kandesk.ISINPUTREQ then
            Cache.kandesk.ISINPUTREQ=false
            Cache.kandesk.WINNUM=0
        end
        self:initXiaFenBtns()
        Cache.kandesk:clearChat()--清除聊天记录
        self:clearLastViewStatus()
        for k,v in pairs(Cache.kandesk._player_info) do
            if  k == Cache.user.uin  then
                Cache.kandesk._player_info[k].draw = 1
                local info_node = ccui.Helper:seekWidgetByName(self.root,"mine_info")
                self._myself    = Kanmyself.new({node = info_node,view=self,uin=Cache.user.uin})
                self._myself:show(0.2)
                if Util:isHasReviewed() then
                    self.btn_chat:setVisible(true)
                end
                
                self._users[k]  = self._myself
            else
                Cache.kandesk._player_info[k].draw = 1
                local user_node    = self:getUserPanel(v.seatid)
                user_node:setVisible(true)
                local user         = Kanuser.new({node = user_node,uin=k,view=self})
                self._users[k]     = user
                user:show(0.2)
            end

            self._users[k]:updateGiftBtn(Cache.kandesk._player_info[k].decoration,true)--初始化挂件
        end
        self:reconnect()
        self:noGoldcheck()
    else
        if Cache.kandesk._player_info[parameters.op_uin] == nil then
            return
        end

        --结算时 不清除 等待结算动画完毕
        if Cache.kandesk.status ~= 5 then 
            local tid  = 0 
            local opPlayerinfo = Cache.kandesk._player_info[parameters.op_uin]
            for k,v in pairs(Cache.kandesk._player_info) do
                if k ~= parameters.op_uin then
                    if opPlayerinfo and v.seatid == opPlayerinfo.seatid then
                        tid = k
                        break
                    end
                end
            end

            if tid ~=0 and self._users[tid] then
                self._users[tid]:clear()
            end

            if self._users[parameters.op_uin] ~= nil then
                self._users[parameters.op_uin]:clearQuit()
            end

            Cache.kandesk._player_info[parameters.op_uin].draw = 1
            local user_node    = self:getUserPanel(Cache.kandesk._player_info[parameters.op_uin].seatid)
            user_node:setVisible(true)

            local user         = Kanuser.new({node = user_node,uin=parameters.op_uin,view=self})
            self._users[parameters.op_uin]     = user
            user:show(0.2)
        end
    end

    if self.showCurrentSitDownStatus then
        self:showCurrentSitDownStatus()
    end

    if Cache.kandesk.left_time >0 and not Cache.kandesk:checkGameRunning() then
        self:timeCount(4,Cache.kandesk.left_time)
    end

    self:showCurrentWaitingStatus()

    --判断是需要等玩家加入
    if Cache.kandesk:checkNeedPlayerJoin() then
        self:showTips(Niuniu_GameTxt.Waiting)
    else
        if not Cache.kandesk:checkGameRunning() then
            self:showTips("")
        end
    end

    self.deskIDTxt:setString(parameters.show_desk_id .. Niuniu_GameTxt.niu_txt_3)
end

--判断是否需要断线重连
function KangameView:reconnect()
    -- body
    if Cache.kandesk:checkGameRunning() then
        for k,v in pairs(self._users) do
            if Cache.kandesk._player_info[k].draw == 1  then
                v:reconnect()
            end
        end
    end 
end

function KangameView:showTips(word, time)
    local panel = self.root:getChildByName("notice_panel_0")

    local myfont = panel:getChildByName("notice") --文字
    myfont:setString(word)    

    local mytime = panel:getChildByName("time") --时间
    time = time or ""
    mytime:setString(time)

    --没有文字的情况下 全部隐藏
    if word == "" then
        panel:setVisible(false)
        myfont:setVisible(false)
        mytime:setVisible(false)
        return
    end


    --设置位置
    local psize = panel:getContentSize()
    local myfontSize = myfont:getContentSize()
    local mytimeSize = mytime:getContentSize()
    local x= ((psize.width) - (mytimeSize.width + myfontSize.width)) / 2

    myfont:setPositionX(x)
    mytime:setPositionX(x + myfontSize.width)

    panel:setVisible(true)
    panel:setOpacity(200)
    myfont:setVisible(true)
    if mytime == "" then
        mytime:setVisible(false)
    else
        mytime:setVisible(true)
    end
end

--获得对应seat的用户节点
function KangameView:getUserPanel(seat)
    local meIndex = Cache.kandesk:getMeIndex()
    local cut = seat - meIndex
    if cut < 0 then
        cut = 5+cut
    end

    local name = "user_info"
    -- print(" ----------------  四个用户")
    if cut == 1 then
        name = "user_fourth"
    end

    if cut == 2 then
        name = "user_third"
    end

    if cut == 3 then
        name = "user_sencod"
    end

    if cut == 4 then
        name = "user_first"
    end 

    local node = self.root:getChildByName(name)    
    return node,cut
end


function KangameView:getRoot()
    return LayerManager.GameLayer
end

--游戏开始
function KangameView:KAN_GAME_START()
    -- body
    self:clear()
    self.startTimeBg:setVisible(false)

    local panel  = self.root:getChildByName("chupai_notice_panel")
    panel:setVisible(false)
    -- panel:setLocalZOrder(8)
    MusicPlayer:playMyEffectGames(Niuniu_Games_res,"START")
    self.Gameanimation:play({anim=GameAnimationConfig.START})

    local table_s = {}
    for k ,v in pairs(self._users) do
        if v ~= nil then
            local tmp = {}
            tmp['key'] = k
            tmp['index'] = v._index

            table.insert(table_s,tmp)
            v:updateUserInfo()
            v:setWaitingStartVis(false)
        end
    end

	if self.showCurrentSitDownStatus then
		self:showCurrentSitDownStatus()
	end


    table.sort(table_s,function ( a,b )
        -- body
        return a.index < b.index
    end)

    local bReady = Cache.kandesk:checkMeReady()
    local bDown = Cache.kandesk:checkMeDown()
    Scheduler:delayCall(2,function ()
        -- body
        if tolua.isnull(self) == true then
            return
        end

        --检测到自己已经坐下了 并且自己不处于USER_STATE_READY状态
        print(bDown, "Down Ready >>>>>>>>>>>>>>>", bReady)

        if bDown and (not bReady) then
            if self._users[Cache.user.uin] then
                self._users[Cache.user.uin]:sendCardAnim()
            end
        end

        -- if not Cache.kandesk:checkMeReady() then
        --     if self._users[Cache.user.uin] then
        --         self._users[Cache.user.uin]:sendCardAnim()
        --     end
        -- end

        local mytime = 0.4
        local i = 0

        for k ,v in pairs(table_s) do
            local key = v.key
            local item = self._users[key]
            if Cache.kandesk._player_info[key] then
                Cache.kandesk._player_info[key].draw  =  1 --标示已经绘制了牌桌的信息了
                if key ~= Cache.user.uin and not Cache.kandesk:checkUserReady(key) then
                    timer = i*0.25 + mytime
                    Scheduler:delayCall(timer,function()
                        print("发送初始牌 。。。。 消息 。。。。。 uin",  key, "  对应的时间点", socket.gettime())
                        if tolua.isnull(item) == false then
                            item:sendCardAnim()
                        end
                    end)
                    i = i +1
                end
            end
            
        end
    end)

    Scheduler:delayCall(4,function ( ... )
        print("显示抢庄按钮 》》》》》》》》》》》》》》》》》》", socket.gettime())
        if bDown and (not bReady) then
            if tolua.isnull(self) == false then
                self:showQiangBase()
                -- grab_time -5 原因是 5s 是用来进行动画播放 发牌等操作的时间
                self:timeCount(1,Cache.kandesk.grab_time - 5)
            end
        end
    end)

    self.back_panel:setVisible(false)
end


--显示抢庄倍数按钮
function KangameView:showQiangBase()
    if self._users[Cache.user.uin] == nil then
        return
    end

    if self._users[Cache.user.uin]:checkQiang() then --已经抢了庄 就不再显示了
        return
    end

    self.handle_panel:setVisible(true)

    for j=1,4 do
        local base    = ccui.Helper:seekWidgetByName(self.handle_panel,"btn_base_"..tostring(j))
        base:setBright(false)
        base:setTouchEnabled(false)
        local content = ccui.Helper:seekWidgetByName(base,"content")
        content:setFntFile(Niuniu_Games_res.DARD_FNT)
    end

    local i = 1
    for k,v in pairs(Cache.kandesk.grab_score) do

        local base    = ccui.Helper:seekWidgetByName(self.handle_panel,"btn_base_"..tostring(i))
        base:setBright(true)
        base:setTouchEnabled(true)
        local content = ccui.Helper:seekWidgetByName(base,"content")
        content:setString(tostring(v).."b")
        content:setFntFile(Niuniu_Games_res.LIGHT_FNT)

        addButtonEvent(base,function ( ... )
            print("抢庄 >>>>>>>>" .. "call_times " .. v .. " time: " .. socket.gettime().." uin >>>>>" .. Cache.user.uin)
            -- body
            GameNet:send({cmd=Niuniu_CMD.USER_RE_QIANG,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid,call_times=v}})
        end)
        i = i + 1
    end

    local base    = ccui.Helper:seekWidgetByName(self.handle_panel,"btn_buqiang")
    addButtonEvent(base,function ( ... )
        -- body
        GameNet:send({cmd=Niuniu_CMD.USER_RE_QIANG,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid,call_times=0}})
    end)
    if self._myself and tolua.isnull(self._myself) == false then
        self._myself:checkShowCard()
    end
end


--倒计时
-- ptype
-- 1.请抢庄
-- 2.请选择下分
-- 3.还有人在苦思冥想
-- 4.游戏即将开始
-- 5.请等待其他玩家下分

-- visible 是否可见

function KangameView:timeCount(ptype,time,visible)
    self:untimeCount()

    local word
    if ptype == 1 then
        word = Niuniu_GameTxt.Kan_qiang_zhuang
        time = time + 1
    end

    if ptype == 2 then
        word = Niuniu_GameTxt.Kan_xia_fen
        time = time + 1
    end

    if ptype == 3 then
        word = Niuniu_GameTxt.Kan_had_user
    end

    if ptype == 4 then
        word = Niuniu_GameTxt.Game_starting
    end

    if ptype == 5 then
        word = Niuniu_GameTxt.Kan_xia_fen_deng
        time = time + 1
    end
    --print(" >>>>>>>>>>>>> ptype    ", ptype,"time >>>>>>>>>", time, " word >>>>>>>>>>>> ", word)
    self.word = word
    self._timecount = time
    local function showStartTimeCountDown(ptype, timecnt)
        if ptype == 4 then
            if timecnt>=0 then
                self.startTime:setVisible(false)
                local startTime=self.startTime:clone()
                self.startTimeBg:addChild(startTime)
                startTime:setVisible(true)
                startTime:setString(timecnt)
                startTime:setScale(0.7)
                startTime:runAction(cc.Sequence:create(
                    cc.Spawn:create(cc.ScaleTo:create(0.5,1.6),cc.FadeOut:create(0.5)),
                    cc.CallFunc:create(function( ... )
                        -- body
                        startTime:removeFromParent()
                    end)
                ))
            end
        else
            if timecnt > 0 then
                self:showTips(self.word, timecnt)
            else
                self:showTips("")
            end
        end
    end

    local bfirst = true
    self._timecount_id = Scheduler:scheduler(1,function ( ... )
        if self._timecount == nil or tolua.isnull(self) == true then
            return 
        end
        --print("Show >>>ASdfasdfstart", ptype, self._timecount - 1)
        showStartTimeCountDown(ptype, self._timecount-1)
        if bfirst then
            local bvis = true
            if visible ~= nil then
                bvis = visible
            end
            if ptype == 4 then
                self.startTimeBg:setVisible(bvis)
            else
                self.notice_panel:setVisible(bvis)
                if self._timecount-1 <= 0 then
                    self:showTips("")
                end
            end
            bfirst = false
        end

        if self._timecount <= 0 then
            self:untimeCount()
        end
        self._timecount =self._timecount -1
    end)
end 

--用户退出
function KangameView:KAN_QUIT(model)
    -- body
    local uin = model.op_user.uin
    -- 【注意】 这个是站起状态
    if not self._users[uin] then
        if Cache.user.uin == uin  then
            if Cache.user.guidetochat then
                qf.event:dispatchEvent(Niuniu_ET.DESKINFO_CLOSE)
                Cache.kandesk:clear()
                ModuleManager:removeExistView()
                ModuleManager.gameshall:initModuleEvent()
                ModuleManager.gameshall:show({toChat = true})
                ModuleManager.gameshall:showReturnHallAni()
            else
                ModuleManager:removeExistView()
                qf.event:dispatchEvent(Niuniu_ET.DESKINFO_CLOSE)
                Cache.kandesk:clear()
                ModuleManager.niuniuhall:show()
            end
        end
        return
    end

    if self.root == nil then
        return
    end
    self._users[uin]:quitRoom(model)

    if tolua.isnull(self.root) then
        return
    end

    --判断是需要等玩家加入
    if  Cache.kandesk:checkNeedPlayerJoin() then
        self:showTips(Niuniu_GameTxt.Waiting)
    -- else
    --     self:showTips("")
    end
    if self.showCurrentSitDownStatus then
        self:showCurrentSitDownStatus()
    end
end

--用户抢庄
function KangameView:KAN_USER_QIANG(model)
    -- body
    -- 如果这个用户是自己 就将handle_panel 隐藏掉 并且停止计时操作
    print("用户uin 》》》》》 ", model.uin,  "进行抢庄！！！")

    if self._users[Cache.user.uin] then
        if model.uin == Cache.user.uin then
            self.handle_panel:setVisible(false)
            self:untimeCount()
        end
    end

    if self._users[model.uin] then
        self._users[model.uin]:qiangFuc(model.call_times)
    end
end


--广播用户庄
function KangameView:KAN_ZHUANG()
    self.Gameanimation:init(3)
    print("call_score_time >>>>>>>>>>>>>>>>", Cache.kandesk.call_score_time)
    --如果抢庄的人数大于1人 或者无人抢庄的情况下 就要播放抢庄动画
    if Cache.kandesk.user_grab_list_len >1 then
        print("有人抢庄 。。。。。")
        self._zhuang_count =  0
        self.root:setColor(cc.c3b(150, 150, 150))

        local overQiangZhuangAni = function()
            if self._zhuang_id then
                Scheduler:unschedule(self._zhuang_id)
                self._zhuang_id=nil
            end
            self.root:setColor(Theme.Color.LIGHT)
        end

        self._zhuang_id    =  Scheduler:scheduler(4/(Cache.kandesk.user_grab_list_len*15),function ()
            -- body 
            if self._zhuang_count == nil then
                return
            end

            local less = math.modf(self._zhuang_count%Cache.kandesk.user_grab_list_len)+1
            local uin  = Cache.kandesk.user_grab_list[less]

            if self._users[uin]==nil then return end

            if (self._zhuang_count + 1) / Cache.kandesk.user_grab_list_len > 5 then
                self._users[uin]:showQiangKuang(2)
            else
                self._users[uin]:showQiangKuang(1)
            end
            
            self._zhuang_count = self._zhuang_count + 1

            if self._zhuang_count / Cache.kandesk.user_grab_list_len > 5 then
                overQiangZhuangAni()
            end
        end)

        Scheduler:delayCall(3,function ( ... )
            -- body
            --把抢庄的信息隐藏
            if tolua.isnull(self) == true then
                return
            end

            overQiangZhuangAni()

            if self._users then
                for k,v in pairs(self._users) do
                    if k ~= Cache.kandesk.zhuang_uin then
                        v:hideQiang()
                    end
                end
            end
            print("展示下分按钮")
            Cache.kandesk:printStatus(Cache.user.uin)
            --如果用户不是庄 且自己已经是玩游戏中状态了 就要显示下分panel
            if Cache.user.uin ~= Cache.kandesk.zhuang_uin  and not Cache.kandesk:checkMeReady() then
                self:showXiaFen()
                self:timeCount(2,Cache.kandesk.call_score_time )
            end 
            -- 如果用户是庄
            if Cache.user.uin == Cache.kandesk.zhuang_uin  and not Cache.kandesk:checkMeReady()  then
                self:timeCount(5,Cache.kandesk.call_score_time)
            end
        end)

        Scheduler:delayCall(4,function ( ... )
            if tolua.isnull(self) == true then
                return
            end
            overQiangZhuangAni()
            print("显示庄 。。。。。。。。。。。。")
            self._users[Cache.kandesk.zhuang_uin]:showZhuang()
        end)
    else
        print("无人抢庄 。。。。。")
        for k,v in pairs(self._users) do
            if k ~= Cache.kandesk.zhuang_uin then
                v:hideQiang()
            end
        end
        Cache.kandesk:printStatus(Cache.user.uin)
        if Cache.user.uin ~= Cache.kandesk.zhuang_uin  and not Cache.kandesk:checkMeReady()   then
            self:showXiaFen()
            self:timeCount(2,Cache.kandesk.call_score_time-1 )
        end

        if Cache.user.uin == Cache.kandesk.zhuang_uin  and not Cache.kandesk:checkMeReady() then
            self:timeCount(5,Cache.kandesk.call_score_time )
        end 

        self._users[Cache.kandesk.zhuang_uin]:showQiangKuang(2)
        Util:delayRun(2,function ()
            -- body
            if self._users then
                self._users[Cache.kandesk.zhuang_uin]:showZhuang()
            end
        end)
    end

end

function KangameView:untimeCount()
    -- body
    if self._timecount_id~= nil then
        Scheduler:unschedule(self._timecount_id)
        self._timecount_id = nil
    end
    self.notice_panel:setVisible(false)
    self:showTips("")
    self.startTimeBg:setVisible(false)
end

--[[
    1.最大支持5个
    2.小于五个自动适配，居中
]]
function KangameView:initXiaFenBtns()
    -- 如果已经布局过，那么不需要处理
    if self.xiafen_panel:getChildrenCount() > 0 then
        return
    end
    -- 从config中获取
    local call_score_list = Cache.kanconfig.bull_classic_room[self.roomid].call_score_list
    local baseBtn = self.root:getChildByName("btn_base")
    local btn_margin = 13 -- 按钮之间的距离
    local btnWidth = baseBtn:getContentSize().width
    local pannelWidth = self.xiafen_panel:getContentSize().width
    local btnNum = table.nums(call_score_list)
    local startPosX = (pannelWidth - btnWidth*btnNum - (btnNum - 1) *btn_margin)/2 + btnWidth/2 + 15
    local pos_y = self.xiafen_panel:getContentSize().height/2
    -- 默认都是dark
    for j=0, btnNum - 1 do
        local score = call_score_list[j + 1]
        local base    = baseBtn:clone()
        local content = ccui.Helper:seekWidgetByName(base,"content")
        base:setName("btn_base_" .. j) --设置名称
        base:setTag(score) --设置value
        content:setString(tostring(score).."b")
        base:setVisible(true)
        base:setBright(false)
        base:setTouchEnabled(false)
        base:setPosition(cc.p(startPosX + btnWidth*j + j *btn_margin, pos_y))
        content:setFntFile(Niuniu_Games_res.DARD_FNT)
        self.xiafen_panel:addChild(base)
    end
end

function KangameView:showXiaFen()
    -- body
    print("【KangameView】 显示 下分 panel 开始")

    if self._users[Cache.user.uin] == nil then
        return
    end

    local call_score_list = Cache.kanconfig.bull_classic_room[self.roomid].call_score_list
    self.handle_panel:setVisible(false)
    self.xiafen_panel:setVisible(true)
    for j=0, #call_score_list - 1 do
        local base    = ccui.Helper:seekWidgetByName(self.xiafen_panel,"btn_base_"..tostring(j))
        base:setBright(false)
        base:setTouchEnabled(false)
        local content = ccui.Helper:seekWidgetByName(base,"content")
        content:setFntFile(Niuniu_Games_res.DARD_FNT)
    end

    print("【KangameView】 ====== 叫分倍数 =====")
    local i = 0
    for k,v in pairs(Cache.kandesk.call_score_list) do
        local base    = ccui.Helper:seekWidgetByName(self.xiafen_panel,"btn_base_"..tostring(i))
        base:setBright(true)
        base:setTouchEnabled(true)
        local content = ccui.Helper:seekWidgetByName(base,"content")
        content:setString(tostring(v).."b")
        content:setFntFile(Niuniu_Games_res.LIGHT_FNT)

        addButtonEvent(base,function ( ... )
            -- body
            GameNet:send({cmd=Niuniu_CMD.USER_RE_BASE,body={uin=Cache.user.uin,desk_id=Cache.kandesk.deskid,call_times=v}})
        end)
        i = i + 1
    end

    if self._myself and tolua.isnull(self._myself) == false then
        self._myself:checkShowCard()
    end
end

--用户下分
function KangameView:USER_BASE( model )
    print("用户 uin", model.uin , "下分  +++++++++++++++++++")
    -- body
    if self.root and tolua.isnull(self.root) == false then
        self.root:setColor(Theme.Color.LIGHT)
    end
    if self._users[Cache.user.uin] then
        if model.uin == Cache.user.uin then
            self.xiafen_panel:setVisible(false)
            self:untimeCount()
            self:timeCount(5,self._timecount)
        end
    end

    if self._users[model.uin] then
        self._users[model.uin]:showBase(model.call_times)
    end
end


--最后一张牌
function KangameView:USER_LAST_CARD(ptype,time)
    -- body
    self.xiafen_panel:setVisible(false)
    if self._users and self._users[Cache.user.uin] == nil then
        return
    end
    if not ptype then
        if self._users[Cache.user.uin] then
            self._users[Cache.user.uin]:fiveCard()
        end
    end

    local ptime = time == nil and Cache.kandesk.out_card_time or time
    self:chuPaiTimer({time=ptime})
    self:untimeCount()
    if Cache.kandesk._player_info[Cache.user.uin] then
        if Cache.kandesk._player_info[Cache.user.uin].card_type ~= 0  then
            --四炸
            if Cache.kandesk._player_info[Cache.user.uin].card_type == 15 then
                self.sizha:setVisible(true)
            end
            --五花牛
            if Cache.kandesk._player_info[Cache.user.uin].card_type == 17 then
                self.wuhua:setVisible(true)
            end
            --五小牛
            if Cache.kandesk._player_info[Cache.user.uin].card_type == 18 then
                self.wuxiao:setVisible(true)
            end
            self.calcObject=nil
        else
            self.calc_panel:setVisible(true)
            self._myself:checkShowCard()
            self.calcObject =  calcObject.new({calc=self.calc_panel,cards=self._users[Cache.user.uin]._cards,youniu=self.you_niu,wuniu=self.wu_niu})
        end
    end
end


function KangameView:KAN_CALC_NOTICE( paras )
    -- body
    local word 
    if paras.type == 1 then
        word = Niuniu_GameTxt.Kan_you_niu
    end
    if paras.type== 2 then
        word = Niuniu_GameTxt.Kan_san_zhang
    end
    if paras.type== 3 then
        word = Niuniu_GameTxt.Kan_no_niu
    end
    if paras.type== 4 then
        word = Niuniu_GameTxt.Kan_no_card
    end

    local tag = 100
    local panel  = self.root:getChildByName("chupai_notice_panel")
    local myfont = panel:getChildByName("notice")
    myfont:setString(word)
    local contentsize =  myfont:getSize()
    if panel:getActionByTag(tag) then panel:stopActionByTag(tag) end
    panel:setVisible(true)
    panel:setOpacity(200)

    local fadein = cc.FadeIn:create(0)
    local delay  = cc.DelayTime:create(1.5)
    local fadeout = cc.FadeOut:create(0.3)
    local sq     = cc.Sequence:create(fadein,delay,fadeout)
    sq:setTag(tag)
    panel:runAction(sq)
end



--玩家出牌
function KangameView:SEND_CARD(model)
    if model.uin == Cache.user.uin then
        print("算分 自己出牌")
        if self._users[Cache.user.uin] then
            if self.calcObject and self._users[Cache.user.uin]._cards then
                self.calcObject:resume()
            end
            self:timeCount(3,self._preTimev)
            self:removeTimer()
            -- self:timeCount(3,self._preTimev)
            self.sizha:setVisible(false)
            self.wuhua:setVisible(false)
            self.wuxiao:setVisible(false)
        end
    end

    MusicPlayer:playMyEffectGames(Niuniu_Games_res,"COMPLETE_"..math.random(1,2))
    if self._users and self._users[model.uin] then
        self._users[model.uin]:sendCard(model.card_type)
    end
end


--游戏结束
function KangameView:KAN_GAME_OVER()
    if self.statusTxt then 
        self.statusTxt:removeFromParent()
        self.statusTxt=nil
    end
    --正在结算的标志
    self.isGameOvering = true
    local panel  = self.root:getChildByName("chupai_notice_panel")
    panel:setVisible(false)

    --如果自己已经在游戏中 这个提示要先进行隐藏 如果自己在还没有在牌局中 提示就要显示
    if Cache.kandesk:checkMeReady() then
        -- print("asdfasfdasdfasdfasdf >>>>>>>>>>")
        self:timeCount(4,Cache.kandesk.start_time,true)
    else
        -- print("asdfasfdasdfasdfasdf >>>>>>>>>> 12123123")
        self:timeCount(4,Cache.kandesk.start_time,false)
    end
   
    
    self._lastsIdList = {}

    local i = 0
    for k,v in pairs( Cache.kandesk.rank) do
        local item = self._users[v[1]]
        if Cache.kandesk._player_info[v[1]] then
            if not Cache.kandesk:checkUserReady(v[1]) then
                self._lastsIdList[#self._lastsIdList + 1] = Scheduler:delayCall(i*0.6+1,function ( ... )
                    print("显示牌 。。。。。。")
                    if tolua.isnull(item) == false then
                        item:showCard()
                    end
                end)
                i = i + 1
            end
        end
    end

    local animationPoint = (i+1)*0.6+1 --展示动画的时间点
    local collectPoint = animationPoint + 2.5 --飞金币的时间点
    if not Cache.kandesk:checkMeReady() then 
        local anim, resstr
        if Cache.kandesk._result_info[Cache.user.uin] then
            if Cache.kandesk._result_info[Cache.user.uin].win_money > 0 then
                if uin == Cache.user.uin then
                    Cache.kandesk.WINNUM=Cache.kandesk.WINNUM+1
                    if Cache.kandesk.WINNUM==3 and Cache.kandesk.WINTYPE<1 then Cache.kandesk.WINTYPE=1
                    elseif Cache.kandesk.WINNUM==5 and Cache.kandesk.WINTYPE<2 then Cache.kandesk.WINTYPE=2
                    elseif Cache.kandesk.WINNUM==10 then Cache.kandesk.WINTYPE=3
                    end
                else
                    Cache.kandesk.WINNUM=0
                end
                anim = GameAnimationConfig.WIN
                resstr = "WIN_GAME"
            else
                anim = GameAnimationConfig.LOST
                resstr = "LOST_GAME"
            end

            self._lastsIdList[#self._lastsIdList + 1] = Scheduler:delayCall(animationPoint - 0.5,function ( ... )
            -- body
                if tolua.isnull(self) == false then
                    print("设置提示为true 。。。。。。")
                    self.startTimeBg:setVisible(true)
                end
            end)
            self._lastsIdList[#self._lastsIdList + 1]  = Scheduler:delayCall(animationPoint,function ( ... )
                -- body
                if tolua.isnull(self) == false then
                    print("播放结束动画效果 。。。。。。。。。。。")

                    self.Gameanimation:play({anim=anim,layer=true,scale=2})
                    MusicPlayer:playMyEffectGames(Niuniu_Games_res,resstr)
                end
            end)
        else
            -- self.visible = true
            -- self.startTimeBg:setVisible(true)
        end
    else
        -- self.visible = true
        -- self.startTimeBg:setVisible(true)
    end

    self._lastsIdList[#self._lastsIdList + 1] = Scheduler:delayCall(collectPoint,function ( ... )
        if tolua.isnull(self) == false then
            self:collectGold()
        end
    end)

    local winMoneyFlyPoint = collectPoint + 2
    if self:checkResultStatus() == 0 then --有输有赢 飘分延迟一秒
        winMoneyFlyPoint = winMoneyFlyPoint + 1
    end

    for k,v in pairs(self._users) do
        if not Cache.kandesk:checkUserReady(k) then
            self._lastsIdList[#self._lastsIdList + 1] = Scheduler:delayCall(winMoneyFlyPoint,function ( ... )
                print("飘分动画开始 》》》》》》》》》》》》》》》》》》")
                if tolua.isnull(v) == true or tolua.isnull(self) == true then
                    return
                end
                -- body
                local resultInfo = Cache.kandesk._result_info
                if resultInfo and resultInfo[k] and resultInfo[k].win_money then
                    print("飘分 ", resultInfo[k].win_money)
                    v:winMoneyFly(resultInfo[k].win_money)
                end

                qf.event:dispatchEvent(Niuniu_ET.KAN_UPDATE_USER,{uin=v._uin})
                if k == Cache.user.uin then
                    qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP, {showTxt = GameTxt.showInsufficientTxt})
                end
            end)
        end
    end

    self._lastsIdList[#self._lastsIdList + 1] = Scheduler:delayCall(Cache.kandesk.start_time - 2, function ( ... )
        self.isGameOvering = false
    end)

    self._lastsIdList[#self._lastsIdList + 1] = Scheduler:delayCall(winMoneyFlyPoint + 3,function ( ... )
        print("清空当前场景 》》》》》》》》》", socket.gettime())
        -- body
        if tolua.isnull(self) == false then
            self:clear()
        end
    end)
end

--clear
function KangameView:clear()
    print("KangameView clear 》》》》》》》》》》》》》》》》》》")
    if Cache.kandesk.status ~= 2 then
        Cache.kandesk.status = 1
    end
    local tmp = {}
    for k,v in pairs(self._users) do
        if Cache.kandesk._player_info[k] and self._users[k]._seatid == Cache.kandesk._player_info[k].seatid then
            tmp[k] = 1
            v:clear()
        else
            v:clear()
        end
    end
    
    --判断是需要等玩家加入
    if Cache.kandesk:checkNeedPlayerJoin() then
        self:untimeCount()
        self:showTips(Niuniu_GameTxt.Waiting)
    else
        self:showTips("")
    end

    --显示当前在桌子上新加入的玩家 
    --这个tmp表示的意思是已经在这个桌子上的人
    for k,v in pairs(Cache.kandesk._player_info) do
        if tmp[k] ~= 1 and k ~= Cache.user.uin then
            Cache.kandesk._player_info[k].draw = 1
            local user_node    = self:getUserPanel(v.seatid)
            user_node:setVisible(true)

            local user         = Kanuser.new({node = user_node,uin=k,view=self})
            self._users[k]     = user
            user:show(0.2)
        end
    end
    
    self.xiafen_panel:setVisible(false)
    self.handle_panel:setVisible(false)
    self.calc_panel:setVisible(false)
    if self.showCurrentSitDownStatus then
        self:showCurrentSitDownStatus()
    end
end


--更新用户信息
function KangameView:KAN_UPDATE_USER( paras )
    if self._users[paras.uin] then
        self._users[paras.uin]:updateUserInfo()
    end
    if paras.uin == Cache.user.uin then
    end
end

--chat
function KangameView:chat(model)
    print("聊天用户 uin >>>>>>>>", model.op_uin)
    user = self._users[model.op_uin]
    self._chat:chatProtocol(model, user, self)

    local userData = Cache.kandesk._player_info[model.op_uin]
    if userData then
        local nick = userData.nick or ""
        self._chat:receiveNewMsg({model = model, name = nick, uin = model.op_uin})
    end
end


function KangameView:exit( )
    -- body
    -- MusicPlayer:backgroundSineOut()
    print("kangameView exit!!!")
    Util:loadAnim(GameAnimationConfig, false)
    Scheduler:clearAll()
    Cache.kandesk:clear()
end


function KangameView:checkResultStatus()
    local loseCnt = 0
    local playerCnt = 0
    for k,v in pairs(Cache.kandesk._result_info) do
        if v.win_money < 0 and k ~= Cache.kandesk.zhuang_uin then
            loseCnt = loseCnt + 1
        end
        playerCnt = playerCnt + 1
    end

    if loseCnt == 0 then --其他人没有输钱 就是庄家赔钱了
        return 2 --庄家通陪 
    end

    if playerCnt == loseCnt + 1 then --其他人都输钱了 就是庄家赢钱了
        return 1 --庄家通赢
    end
    return 0 --有赢有陪
end

function KangameView:collectGold()
    print("播放金币动画 。。。。。。。。。。。。。。。。。")
    local status = self:checkResultStatus()

    --庄家赢钱动画
    local winFunc = function ( ... )
        for k,v in pairs(Cache.kandesk._result_info) do
            if v.win_money < 0 and  k ~= Cache.kandesk.zhuang_uin  then
                self:flyGold(k,Cache.kandesk.zhuang_uin)
            end
        end
        MusicPlayer:playMyEffectGames(Niuniu_Games_res,"SHOU")
    end

    --庄家输钱动画
    local loseFunc = function ( ... )
        for k,v in pairs(Cache.kandesk._result_info) do
            if v.win_money > 0 and   k ~= Cache.kandesk.zhuang_uin then
                self:flyGold(Cache.kandesk.zhuang_uin,k)
            end
        end
        MusicPlayer:playMyEffectGames(Niuniu_Games_res,"SHOU")  
    end

    if status == 0 then
        winFunc() --先赢钱
        Scheduler:delayCall(1.5, loseFunc) --后输钱动画
    elseif status == 1 then
        winFunc()        
    elseif status == 2 then
        loseFunc()
    end
end


function KangameView:flyGold(uin,to_uin)
    -- body
    --先去随机金币
    local seat_index
    local to_seat_index
    local node 

    if Cache.kandesk._player_info[uin] == nil then return end

    if uin ~= Cache.user.uin then
        local seat      = Cache.kandesk._player_info[uin].seatid 
        node,seat_index = self:getUserPanel(seat) 
    else
        seat_index = 5
    end

    if Cache.kandesk._player_info[to_uin] == nil then return end

    if to_uin ~= Cache.user.uin then
        local seat      = Cache.kandesk._player_info[to_uin].seatid 
        node,to_seat_index = self:getUserPanel(seat) 
    else
        to_seat_index = 5
    end
    
    if not self._users[uin] or not  self._users[to_uin] then return end

    local cut           = math.abs(seat_index - to_seat_index )
    local start_px      = self._users[uin]:getPositionX()
    local start_py      = self._users[uin]:getPositionY()
    local start_px_icon = self._users[uin].icon:getPositionX()
    local start_py_icon = self._users[uin].icon:getPositionY()
    local end_px_icon   = self._users[to_uin].icon:getPositionX()
    local end_py_icon   = self._users[to_uin].icon:getPositionY()
    local end_px        = self._users[to_uin]:getPositionX()
    local end_py        = self._users[to_uin]:getPositionY()
    local icon_width    = self._users[to_uin].icon:getContentSize().width
    local icon_height   = self._users[to_uin].icon:getContentSize().height
    local cut_x         = end_px -start_px 
    local cut_y         = end_py -start_py 

    local max_length = 1800
    local lenght     = math.sqrt(cut_x*cut_x+cut_y*cut_y)
    local ratio      = lenght/max_length
    local max_time   = 0.4
    local real_time  = 0.4 / ratio

    local gold_num = math.random(40,60)
    gold_num = math.ceil(gold_num)
    for i=1,gold_num do

        local gold  = cc.Sprite:createWithSpriteFrameName(Niuniu_Games_res.gold_coin)

        self:addChild(gold)
        gold:setPosition(start_px+start_px_icon,start_py+start_py_icon)
        gold:setScale(0.7)

        local move       = KangameView:ParabolaTo(0.4,cc.p(gold:getPositionX(),gold:getPositionY()),cc.p(end_px+math.random(-icon_width/3,icon_width/3)+end_px_icon,end_py+math.random(-icon_height/3,icon_height/3)+end_py_icon),math.random(80,100))
        local delay      = cc.DelayTime:create(i*0.007)
        local delay1      = cc.DelayTime:create(0.1)
        local fadeout    = cc.FadeOut:create(0.6)
        local call1      = cc.CallFunc:create(function ()
            if gold then
                gold:removeFromParent()
            end
        end)

        local sq    = cc.Sequence:create(delay,move,delay1,call1)
        gold:runAction(sq)
    end

end

function KangameView:ParabolaTo(t,startPoint,endPoint,height)
    local q1x=startPoint.x+(endPoint.x - startPoint.x)/4.0
    local q1y=startPoint.y+(endPoint.y - startPoint.y)/4.0
    local q2x=startPoint.x+(endPoint.x - startPoint.x)*3/4.0
    local q2y=startPoint.y+(endPoint.y - startPoint.y)*3/4.0

    local q1
    local randomX=math.random(-20,20)
    if q1x*q1y>0 then
        q1=cc.p(q1x-randomX,q1y+height)
        q2=cc.p(q2x-randomX,q2y+height)
    else
        q1=cc.p(q1x+randomX,q1y+height)
        q2=cc.p(q2x+randomX,q2y+height)
    end
    return cc.BezierTo:create(t,{q1,q2,endPoint} )
end

function KangameView:chuPaiTimer(paras)
    print("显示出牌倒计时 。。。。。。。。。。。。。。。。。。。。。。。。")
    if self._timer then 
        self:removeTimer() 
    end

    self.startTag = 9999

    paras = paras or {}
    local costTime = paras.time or 0
    local percent  = 100

    self.defaultCountTimer = costTime

    local timer = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(Niuniu_Games_res.Kan_chupai_timer))
    timer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    timer:setReverseDirection(true)
    -- timer:setScale(0.96)
    timer:setPercentage(percent)
    timer:setTag(self.startTag+2)
    self:addChild(timer,1)
    timer:setPosition(1920/2,Display.cy/2)

   


    local timer1 = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(Niuniu_Games_res.Kan_chupai_timer1))
    timer1:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    -- timer1:setReverseDirection(true)
    -- timer:setScale(0.96)
    timer1:setPercentage(0)
    timer1:setTag(self.startTag+3)




    self:addChild(timer1,1)
    timer1:setPosition(1920/2,Display.cy/2)


    self._num = cc.LabelBMFont:create('+'..tostring(money),Niuniu_Games_res.Kan_chupai_timer_font_green)
    self:addChild(self._num,1)
    self._num:setString(costTime)
    self._num:setPosition(1920/2,Display.cy/2)
    self._num:setTag(self.startTag+4)


    self._timer1 = timer1

    self._timev    = self.defaultCountTimer - 1
    self._preTimev = self.defaultCountTimer  - 1 
    self._timer = timer
    self._timer:setColor(self:getGradualValue())

    self:scheduleUpdateWithPriorityLua(handler(self,self._timeCounterInFrames),0)
end


function KangameView:getGradualValue()
    local r1 = (self.defaultCountTimer - self._timev)/self.defaultCountTimer
    local r = 0 local g = 0 local b = 0
    if r1 < 0.5 then 
        g = 255 
        r = 2*r1*255  
    end
    if r1 > 0.5 then 
        g = (1-r1)*2*255 
        r =255 
    end
    return cc.c3b(r,g,b)
end


function KangameView:_timeCounterInFrames(dt)
    self._timev = self._timev - dt
    if self._timer == nil then self:removeTimer() return end
    self._timer:setColor(self:getGradualValue())
    self._timer:setPercentage(self._timev*100/self.defaultCountTimer)
    self._timer1:setPercentage(100 -self._timev*100/self.defaultCountTimer)
    local percent = self._timev*100/self.defaultCountTimer
    if self._timev < self._preTimev then 
        self._preTimev = self._preTimev - 1
        self._num:setString(self._preTimev+1)
        if percent < 25  then
            self._num:setFntFile(Niuniu_Games_res.Kan_chupai_timer_font_red)
        end

        if percent < 50 and percent >=25   then
            self._num:setFntFile(Niuniu_Games_res.Kan_chupai_timer_font_yellow)
        end
    end

    if self._timev < 0.000001 then
        self:removeTimer({timeover = true})
    end
end


function KangameView:removeTimer (paras)
    -- logd("移除倒计时"..self.uin,self.TAG)
    -- if paras == nil or paras.overtime == false then self:stopOverTimer() end
    self:unscheduleUpdate()
    if self:getChildByTag(self.startTag+2) then 
        self:removeChildByTag(self.startTag+2)
    end
    if self:getChildByTag(self.startTag+3) then 
        self:removeChildByTag(self.startTag+3)
    end
    if self:getChildByTag(self.startTag+4) then 
        self:removeChildByTag(self.startTag+4)
    end
    self._timer = nil
    self._timer1 = nil
    self._num    = nil
end


function KangameView:startAgain()
    -- body
    -- self.deskinfobg:setVisible(false)
    self.startAgainPanel:setVisible(true)
    addButtonEvent(self.back_btn,function ( ... )
        -- body
        ModuleManager:removeExistView()
        ModuleManager.niuniuhall:show()
        ModuleManager.niuniuhall:openErji({kind="kanpai"})
    end)
    Util:enlargeBtnClickArea(self.back_btn, {x = 1.4, y = 2})
    
    -- self.change_btn:setOpacity(130)
    -- self.change_btn:setTouchEnabled(false)
    addButtonEvent(self.startAgainBtn,function ()
        -- body
        self:loadingCuoHe()
        qf.event:dispatchEvent(Niuniu_ET.SEND_LOGIN_PRO)
    end)

    qf.event:dispatchEvent(ET.CHEST_SHOW_AND_HIDE,{visible=false})

    self:showALLSitDownStatus(false)
end


--正在撮合
function KangameView:loadingCuoHe()
    print("撮合中 。。。。。。。。")
    self:CHUOHE_CLOSE()

    local node =  Niuniu_Display:getCuoheTips(Niuniu_GameTxt.Game_cuohe)
    self:addChild(node)
    local adjustMarginX = 0
    if FULLSCREENADAPTIVE then
        adjustMarginX = -(self.winSize.width - 1920)/2
    end
    node:setPosition(Display.cx/2 + adjustMarginX,Display.cy/2)
    node:setName(KangameView.Tips)
end

-- 获取user
function KangameView:getUser(i) 
    if not i or not self._users then return end
    return self._users[i]
end


function KangameView:showALLSitDownStatus(bvis)
	local layer = self.sitdownLayer
	for i = 0, 4 do
		self:showPlayerSitDownVis(i, bvis)
	end
end

function KangameView:showPlayerSitDownVis(idx, bvis)
    if 0 > idx or idx > 4 then
        idx = 0
    end
	self.sitdownLayer:getChildByName("sitDown" .. idx):setVisible(bvis)
end

function KangameView:showPlayerSitDownVisBySeat(seat, bvis)
    local cut = seat - Cache.kandesk:getMeIndex()
	if cut < 0 then
		cut = 5+cut
    end
	self:showPlayerSitDownVis(cut, bvis)
end

--显示当前下座位置ui显示
function KangameView:showCurrentSitDownStatus()
    self:showALLSitDownStatus(true)
    local showPlayerIdList = {}
	for k,v in pairs(self._users)do
		local uin = k
		local info = Cache.kandesk._player_info[k]
        if info and info.seatid then --坐下人的 隐藏座位
            self:showPlayerSitDownVisBySeat(info.seatid, false)
            showPlayerIdList[#showPlayerIdList + 1] = info.seatid
        end
    end

    --先隐藏所有玩家
    for i = 0, 4 do
        local node =  self:getUserPanel(i)
        node:setVisible(false)
    end

    --在显示需要显示的玩家
    for i, v in ipairs(showPlayerIdList) do
        local node, cut = self:getUserPanel(v)
        print(v, node:getName())
        if cut == 0 then -- 如果是自己的方向的座位 先判断
            local info = Cache.kandesk._player_info[Cache.user.uin]
            print(">>>>>>>>>>>>>>", info)
            if info and info.seatid then --自己坐下
                -- node:setVisible(false)
            else --不是自己坐下
                node:setVisible(true)
                --将当前
            end
        else
            node:setVisible(true)
        end
    end

    --如果在自己的主观视角里面 结算时 用户依然在座位上的时候 但是服务器通知了离开了座位为了配合动画显示 这里暂时隐藏自己的那张位置
    --后续会再次刷出来
    -- print(">>>>>>>>>>>>>>>>>>>", self._users[Cache.user.uin] ,"   ", self._users[Cache.user.uin]._info ,"   ", self._users[Cache.user.uin]._info.quit)
    if self._users[Cache.user.uin] and self._users[Cache.user.uin]._info and self._users[Cache.user.uin]._info.quit==1 then
        -- print("asdfasdqerw")
        self:showPlayerSitDownVis(0, false)
    end
end

-- function GameView:standUpShowCard(uin)
-- 	-- body
-- 	if  Cache.kandesk.status==1 and Cache.kandesk._player_info[uin] and (Cache.kandesk._player_info[uin].compare_failed or Cache.kandesk._player_info[uin].compare_win) then
-- 		local user={}
-- 		local x,y
-- 		if self._users[uin].user_info_panel then
-- 			x=self._users[uin]:getPositionX()+self._users[uin].user_info_panel:getPositionX()-52
-- 			y=self._users[uin]:getPositionY()+self._users[uin].user_info_panel:getPositionY()-15
-- 		else
-- 			x=self._users[uin]:getPositionX()-52
-- 			y=self._users[uin]:getPositionY()-15
-- 		end 
-- 		user.ifwin=false
-- 		user.gold=self._users[uin]._info.gold
-- 		user.card_type=self._users[uin]._info.card_type
-- 		user.card=self._users[uin]._info.card
-- 		user.x=x
-- 		user.y=y
-- 		table.insert(self.showcardUser,user)
-- 	end
-- end

--站起
function KangameView:standUp(uin)
	print(">>>>>>>>>>>>>>>>> standUp ", uin)
    -- body
    if self._users[uin] == nil then
        return
    end


	if uin ~= Cache.user.uin then
        print("AAAAAAAA XXXXXX")
        self._users[uin]:quitRoom()
    else
		if self._users[uin] then
			self._users[uin]._info.quit=1
			self._users[uin]:clear()
        end
        self._users[uin] = nil
        print("AAAAAAAA XXXXXX BBBBBBBBBB")
        local fadeout    = cc.FadeOut:create(0.2)
        self._myself:runAction(fadeout)
        self._chat:hide()
        self.btn_chat:setVisible(false)
    end

    if self.showCurrentSitDownStatus then
        self:showCurrentSitDownStatus()
    end
    if self.refreshStandUpBtn then
        self:refreshStandUpBtn()
    end
end

--坐下
function KangameView:sitDown(uin)
	-- body
	print("GameView zjh:sitDown begin"..os.clock())
	if uin ~= Cache.user.uin then
    else
        -- print("++++++++++++++++++++++++")
		for k,v in pairs(self._users)do
			if k~=Cache.user.uin then
                -- print("kkkk >>>>>>>>>>>>>", k)
                v:quitRoom()
                v:setOpacity(0)
                self._users[k]=nil
			end
		end
		self._users={}
		if self.standup then
			self.standup_btn:setOpacity(255)
			self.standup_btn:setTouchEnabled(true)
		end
		if self.gameChestPop then
			self.gameChestPop:setVisible(true)
		end
		-- self.kiss:setVisible(false) --打赏关闭
		-- Cache.zjhdesk.is_view=0
		--self.Chat:setVisible(true) --qf3屏蔽
		-- self.sitdown:setVisible(false)
	end
	print("GameView zjh:sitDown end"..os.clock())
end

function KangameView:showCurrentWaitingStatus()
    for k, v in pairs(self._users) do
        local uin = k
        self:refreshWaitingStart(uin)
    end
end

--设置等待开始的刷新
function KangameView:refreshWaitingStart(uin)
    if self._users[uin] then
        self._users[uin]:setWaitingStartVis(false)
    end
    if Cache.kandesk._player_info[uin] and Cache.kandesk._player_info[uin].status == 1020 and
    Cache.kandesk:getUsersNum() ~= 1 and Cache.kandesk:checkGameRunning() 
    then
        if self._users[uin] then
            self._users[uin]:setWaitingStartVis(true)
        end
    end
end

function KangameView:refreshHongBaoBtn()
    self.btn_shop:setVisible(Cache.user.first_recharge_flag == 0)
    if Cache.user.first_recharge_flag == 1 then
        local pos = self.btn_shop:getPosition3D()
        Util:addHongBaoBtn(self, pos)
    elseif Cache.user.first_recharge_flag == 0 then
        Util:removeHongBaoBtn(self)
    end
end


function KangameView:refreshNetStrength(paras)
    local diffX = 0
    if FULLSCREENADAPTIVE then
        diffX = self.winSize.width/2-1920/2
    end
    Util:addNetStrengthFlag(self.root, cc.p(170  - diffX,1045), paras)
end

function KangameView:refreshNoMoneyTip(paras)
    paras = paras or {}
    paras.restMoney = self.limit_gold - Cache.user.gold
    paras.noImgTip = true
    Util:refreshNoMoneyTip(self.root, paras)
end

--设置等待开始的刷新
function KangameView:test()
    -- self.btn_chat:setVisible(true)
    -- self.btn_chat:getParent():setVisible(true)
    -- userList[1] = Kanuser.new({node = self.root:getChildByName("user_info")   ,uin=1,view=self})
    -- userList[1]:test()
    -- if true then
    --     return
    -- end

    Cache.user.meIndex = nil
    Cache.kandesk._player_info = {
        [1] = {
            seatid = 0,
            nick = "1111",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
        [2] = {
            seatid = 1,
            nick = "2222",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 0
        },
        [3] = {
            seatid = 2,
            nick = "3333",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
        [4] = {
            seatid = 3,
            nick = "4444",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
        [5] = {
            seatid = 4,
            nick = "5555",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
    }
    local winMoneyList = {200,-100,-100}
    -- local winMoneyList = {200, 100,-300}
    -- local winMoneyList = {-200, 100, 100}
    Cache.kandesk._result_info = {
        [1] = {
            card_type = 0,
            card = {
                10,10,10,10,10
            },
            win_money = winMoneyList[1],
        },
        [2] = {
            card_type = 0,
            card = {
                10,10,10,10,10
            }, 
            win_money = winMoneyList[2],
        },
        [3] = {
            card_type = 0,
            card = {
                10,10,10,10,10
            }, 
            win_money = winMoneyList[3],
        },
        [4] = {
            card_type = 0,
            card = {
                10,10,10,10,10
            }, 
            win_money = winMoneyList[2],
        },
        [5] = {
            card_type = 0,
            card = {
                10,10,10,10,10
            }, 
            win_money = winMoneyList[3],
        },
    }
    Cache.kandesk.zhuang_uin = 1
    local userList = {}
    userList[1] = Kanuser.new({node = self.root:getChildByName("user_info")   ,uin=1,view=self})
    userList[2] = Kanuser.new({node = self.root:getChildByName("user_first")   ,uin=2,view=self})
    userList[3] = Kanuser.new({node = self.root:getChildByName("user_sencod")   ,uin=3,view=self})
    userList[4] = Kanuser.new({node = self.root:getChildByName("user_third")   ,uin=4,view=self})
    userList[5] = Kanuser.new({node = self.root:getChildByName("user_fourth")   ,uin=5,view=self})
    self._users = {}
    for i,v  in ipairs(userList) do
        v:setVisible(true)
        v:testSetCard()
        self._users[i] = v
    end
    self._users[1]:playShowChatMsg(self.chat_txt_layer, "zxcvzxvc")
    self._users[2]:playShowChatMsg(self.chat_txt_layer, "zxcvzxvc")
    self._users[3]:playShowChatMsg(self.chat_txt_layer, "zxcvzxvc")
    self._users[4]:playShowChatMsg(self.chat_txt_layer, "zxcvzxvc")
    self._users[5]:playShowChatMsg(self.chat_txt_layer, "zxcvzxvc")
    -- self._users[5]:test()
    local info_node = ccui.Helper:seekWidgetByName(self.root,"mine_info")
    self._myself    = Kanmyself.new({node = info_node,view=self,uin=1})
    self._myself:show(0.2)
    -- self._chat:show()
    -- self._chat:refreshRecordPanel({
    --     nick  = "asdfasd",
    --     uin = 1,
    --     newMsg=  "爱说的话饭卡十分恐惧撒"
    -- })
    
    -- self._myself:test()
    -- self._myself:playShowChatMsg(self.chat_txt_layer, "zxcvzxvc")
    if true then
        return
    end
    -- user:showQiangKuang()
    -- user:setVisible(true)
    self:timeCount(3,10)
    -- self:timeCount(4,Cache.kandesk.left_time)
    -- user:winMoneyFly(-50)
    -- self:showTips("请抢庄:%d", 5)
    --正在结算的标志
    -- self.isGameOvering = true
    -- local panel  = self.root:getChildByName("chupai_notice_panel")
    -- panel:setVisible(false)

    --如果自己已经在游戏中 这个提示要先进行隐藏 如果自己在还没有在牌局中 提示就要显示
    -- if Cache.kandesk:checkMeReady() then
    --     self:timeCount(4,Cache.kandesk.start_time,false)
    -- else
    --     self:timeCount(4,Cache.kandesk.start_time,true)
    -- end

    local cnt = 0
    for i, v in ipairs(userList) do
        local item = v
        Scheduler:delayCall(i*0.6+1,function ( ... )
            print("显示牌 。。。。。。")
            if tolua.isnull(item) == false then
                item:showCard()
            end    
        end)
        cnt = cnt + 1
    end
    local showCardPoint =  (cnt+1)*0.6 + 1

    Scheduler:delayCall(showCardPoint,function ( ... )
        -- body
        if tolua.isnull(self) == false then
            print("播放结束动画效果 。。。。。。。。。。。")
            self.Gameanimation:play({anim=GameAnimationConfig.WIN,layer=true,scale=2})
            MusicPlayer:playMyEffectGames(Niuniu_Games_res, "WIN_GAME")
        end
    end)

    local collectPoint = showCardPoint + 2.5
    Scheduler:delayCall(collectPoint,function ( ... )
        if tolua.isnull(self) == false then
            self:testCollectGold()
        end
    end)

    local winMoneyFlyPoint = collectPoint + 2
    local status = self:checkResultStatus()
    if status == 0 then --有赢有赔
        winMoneyFlyPoint = winMoneyFlyPoint + 1
    end

    for k, v in ipairs(self._users) do
        Scheduler:delayCall(winMoneyFlyPoint,function ( ... )
            print("飘分动画开始 》》》》》》》》》》》》》》》》》》")
            if tolua.isnull(v) == true or tolua.isnull(self) == true then
                return
            end
            local resultInfo = Cache.kandesk._result_info
            if resultInfo and resultInfo[k] and resultInfo[k].win_money then
                print("飘分 ", resultInfo[k].win_money)
                v:winMoneyFly(resultInfo[k].win_money)
            end
        end)
    end
end

function KangameView:testCollectGold()
    print("播放金币动画 。。。。。。。。。。。。。。。。。")
    local status = self:checkResultStatus()

    --庄家赢钱动画
    local winFunc = function ( ... )
        for k,v in pairs(Cache.kandesk._result_info) do
            if v.win_money < 0 and  k ~= Cache.kandesk.zhuang_uin  then
                -- print("flyGold 》》》》》》》》》》》》")
                self:testflyGold(k,Cache.kandesk.zhuang_uin)
            end
        end
        MusicPlayer:playMyEffectGames(Niuniu_Games_res,"SHOU")
    end

    --庄家输钱动画
    local loseFunc = function ( ... )
        for k,v in pairs(Cache.kandesk._result_info) do
            if v.win_money > 0 and   k ~= Cache.kandesk.zhuang_uin then
                self:testflyGold(Cache.kandesk.zhuang_uin,k)
            end
        end
        MusicPlayer:playMyEffectGames(Niuniu_Games_res,"SHOU")  
    end

    print("status >>>>>>>>>", status)
    if status == 0 then
        winFunc() --先赢钱
        Scheduler:delayCall(1.5, loseFunc) --后输钱动画
    elseif status == 1 then
        winFunc()        
    elseif status == 2 then
        loseFunc()
    end
end

function KangameView:testflyGold(uin,to_uin)
    -- body
    --先去随机金币
    -- local seat_index
    -- local to_seat_index
    -- local node 

    -- if Cache.kandesk._player_info[uin] == nil then return end

    -- if uin ~= Cache.user.uin then
    --     local seat      = Cache.kandesk._player_info[uin].seatid 
    --     node,seat_index = self:getUserPanel(seat) 
    -- else
    --     seat_index = 5
    -- end

    -- if Cache.kandesk._player_info[to_uin] == nil then return end

    -- if to_uin ~= Cache.user.uin then
    --     local seat      = Cache.kandesk._player_info[to_uin].seatid 
    --     node,to_seat_index = self:getUserPanel(seat) 
    -- else
    --     to_seat_index = 5
    -- end
    
    -- if not self._users[uin] or not  self._users[to_uin] then return end

    -- local cut           = math.abs(seat_index - to_seat_index )
    local start_px      = self._users[uin]:getPositionX()
    local start_py      = self._users[uin]:getPositionY()
    local start_px_icon = self._users[uin].icon:getPositionX()
    local start_py_icon = self._users[uin].icon:getPositionY()
    local end_px_icon   = self._users[to_uin].icon:getPositionX()
    local end_py_icon   = self._users[to_uin].icon:getPositionY()
    local end_px        = self._users[to_uin]:getPositionX()
    local end_py        = self._users[to_uin]:getPositionY()
    local icon_width    = self._users[to_uin].icon:getContentSize().width
    local icon_height   = self._users[to_uin].icon:getContentSize().height
    local cut_x         = end_px -start_px 
    local cut_y         = end_py -start_py 
    local max_length = 1800
    local lenght     = math.sqrt(cut_x*cut_x+cut_y*cut_y)
    local ratio      = lenght/max_length
    local max_time   = 0.4
    local real_time  = 0.4 / ratio

    local gold_num = math.random(40,60)
    gold_num = math.ceil(gold_num)
    for i=1,gold_num do

        local gold  = cc.Sprite:createWithSpriteFrameName(Niuniu_Games_res.gold_coin)
        self:addChild(gold)
        gold:setPosition(start_px+start_px_icon,start_py+start_py_icon)
        gold:setScale(0.7)

        local move       = KangameView:ParabolaTo(0.4,cc.p(gold:getPositionX(),gold:getPositionY()),cc.p(end_px+math.random(-icon_width/3,icon_width/3)+end_px_icon,end_py+math.random(-icon_height/3,icon_height/3)+end_py_icon),math.random(80,100))
        local delay      = cc.DelayTime:create(i*0.007)
        local delay1      = cc.DelayTime:create(0.1)
        local fadeout    = cc.FadeOut:create(0.6)
        local call1      = cc.CallFunc:create(function ()
            if gold then
                gold:removeFromParent()
            end
        end)

        local sq    = cc.Sequence:create(delay,move,delay1,call1)
        gold:runAction(sq)
    end

end

function KangameView:testResult()

end

return KangameView