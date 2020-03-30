
local LHDGameView = class("LHDGameView", qf.view)

local IButton = import(".components.IButton")
local LHDDelar = import(".lhdcomponents.LHDDelar")
local LHDChipsPool = import(".lhdcomponents.LHDChipsPool")
local LHDAddBtn = import(".lhdcomponents.LHDAddBtn")
local LHDGameEnd = import(".lhdcomponents.LHDGameEnd")
local LHDHistory = import(".lhdcomponents.LHDHistory")
local LHDDelarList = import(".lhdcomponents.LHDDelarList")
local LHDMyself = import(".lhdcomponents.LHDMyself")
local LHDUser = import(".lhdcomponents.LHDUser")
local LHDPerson = import(".lhdcomponents.LHDPerson")
local LHDAniConfig=  import("src.games.game_lhd.modules.game.lhdcomponents.animation.LHDAnimationConfig")
local UserDisplay = import(".components.user.UserDisplay")
local Chat = require("src.common.Chat")


LHDGameView.TAG = "LHDGameView"
LHDGameView.TOUCH_ZORDER = 19
LHDGameView.LOADDINGZ = 10
LHDGameView.TAG_CHIP_ACTION = 100

function LHDGameView:ctor(paras)
	paras = paras or {}
    paras.game_type = LHD_MATCHE_TYPE
    self.winSize = cc.Director:getInstance():getWinSize()
    self.game_type = paras and paras.game_type or BRC_MATCHE_TYPE
    Cache.DeskAssemble:setGameType(self.game_type)
    self:init()
    LHDGameView.super.ctor(self, paras)
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_INGAME_POS)
    -- self:initTouchEvent()
end

function LHDGameView:init()
    self:initSpriteFrame()
    self.deskCache = Cache.DeskAssemble:getCache()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(LHD_Games_res.brGameJson)
    self:addChild(self.gui)
    self:initResultTopPannel()
    self:initTipsPanel()
    self:initUser()
    self:initDelar()
    self:initPools()
    self:initChipsPoolTouch()
    self:initBtnTouch()
    --self:initTouchEvent()
    self:initLHDView()
    -- self:refreshHongBaoBtn()
    self:refreshNetStrength()
    if not Cache.packetInfo:isShangjiaBao() then
        self:refreshNoMoneyTip()
    end
    self:initChatUI()

end

function LHDGameView:initSpriteFrame( ... )
    cc.SpriteFrameCache:getInstance():addSpriteFrames(LHD_Games_res.lhd_game_plist, LHD_Games_res.lhd_game_png)
end

function LHDGameView:initUser()
    self.chipsUser = {}--下注用户
    self._rightUsers = {}
    self.myself = LHDMyself.new({node = self.gui:getChildByName("lhd_myself_panel")})
    self.myself:setVisible(true)
    for i = 1 , 6 do
        self._rightUsers[i] = LHDUser.new({node = self.gui:getChildByName("user_panel_"..i),index = i})
        self.chipsUser["seat_user"..i] = self._rightUsers[i]
    end
    self.chipsUser.myself = self.myself
    self.chipsUser.realself = self.myself
    self.chipsUser.other = self.gui:getChildByName("bnt_person")
end

function LHDGameView:initResultTopPannel( ... )
    self.resultTopPannel = LHDGameEnd.new({node = self.gui:getChildByName("show_result_pannel")})
end

function LHDGameView:initTipsPanel()
    self.tips_panel = self.resultTopPannel:getChildByName("tips_panel")
    self.time_panel = self.tips_panel:getChildByName("time_panel")
    self.startBetImg = self.gui:getChildByName("begin_bet")
    self:playTopLHAnimation()
end

function LHDGameView:initDelar()
    self.delar_panel = self.gui:getChildByName("lhd_delar_panel")
	self.delar = LHDDelar.new({node = self.delar_panel})
    self.chipsUser.delar = self.delar
end

function LHDGameView:initPools()
	self._rightPools = {}
    local parent = ccui.Helper:seekWidgetByName(self.gui,"pan_container")
    for i = 1 ,3 do
        local _panel = ccui.Helper:seekWidgetByName(self.gui,"lhd_chips_panel_"..i)
        _panel:setVisible(true)
        self._rightPools[i] = LHDChipsPool.new({node = _panel, index = i,parent = parent})
    end
end

function LHDGameView:initTouchEvent()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local layer = cc.Layer:create()
    local parent = ccui.Helper:seekWidgetByName(self.gui,"pan_container")
    local zOrder = parent:getLocalZOrder()
    parent:addChild(layer, self.TOUCH_ZORDER)

    self._touchData = {}

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(function (touch,event)
        self._touchData = {}
        self._touchData.pos = touch:getLocation()
        self._touchData.time = os.time()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)

    listener1:registerScriptHandler(function (touch,event)
        local diffx = touch:getLocation().x - self._touchData.pos.x
        local diffy = touch:getLocation().y - self._touchData.pos.y
        local difft = os.time() - self._touchData.time
        local mindis = 120
        local maxtime = 2
        if diffy <-mindis and difft < maxtime then
            -- 之前这里是小喇叭的逻辑，删除
        end
    end,cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer)
end

function LHDGameView:initLHDView()
    local bg = self.gui:getChildByName("bg")

    local add_chips_panel = self.gui:getChildByName("add_chips_panel")
    local left = Display.cx/2+20
    add_chips_panel:setLocalZOrder(2)
    ccui.Helper:seekWidgetByName(self.gui,"time_img"):setVisible(false)
end


---初始化几个按钮
function LHDGameView:initBtnTouch()
    self._panContainer = ccui.Helper:seekWidgetByName(self.gui, "pan_container")
    self._addP = LHDAddBtn.new({node = self.gui:getChildByName("add_chips_panel")})
    self.bnt_person = IButton.new({node = self.gui:getChildByName("bnt_person")})
    self.bnt_history = IButton.new({node = self.gui:getChildByName("bnt_history"), keep = true})
    
    self.bnt_person:setCallback(function() 
        self:showPerson()
    end)
    self.bnt_history:setCallback(function() 
        self:showHistory()
    end)

    local btn_back = self.gui:getChildByName("btn_back")
    btn_back:loadTextures(GameRes.menuImg, GameRes.menuImg, "")


	local btn_help = self.gui:getChildByName("btn_help")
    local btn_shop = self.gui:getChildByName("btn_shop")
	btn_back:setVisible(true)
	btn_help:setVisible(false)
    btn_shop:setVisible(true)
    self:bindMenuBox()
    addButtonEvent(btn_help,function ( sender )
        self:showHelpView()
    end)
    addButtonEvent(btn_shop,function ( sender )
        self:showShopView()
    end)
end

function LHDGameView:bindMenuBox()
    local panelBox = self.gui:getChildByName("Panel_box")
    panelBox:setVisible(false)
    addButtonEvent(self.gui:getChildByName("btn_back"), function ()
        panelBox:setVisible(true)
    end)

    addButtonEvent(panelBox:getChildByName("btnBack"), function ()
        qf.event:dispatchEvent(LHD_ET.GAME_LHD_EXIT_EVENT)
    end)

    addButtonEvent(panelBox:getChildByName("btnSet"), function ()
        qf.event:dispatchEvent(ET.SETTING)
    end)
    addButtonEvent(panelBox:getChildByName("btnBank"), function ()
        qf.event:dispatchEvent(ET.SAFE_BOX, {inGame = true})
    end)

    addButtonEvent(panelBox:getChildByName("btnUp"), function ()
        local myUin = Cache.user.uin
        local delar = self.deskCache:getDelar()
        if delar.uin == myUin then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = LHD_Games_txt.br_delar_stand_error_tips})
            return
        end
        local bSit = self:checkSomeoneSitDown(myUin)
        if bSit then
            qf.event:dispatchEvent(LHD_ET.NET_AUTO_SIT_UP_REQ, {uin = myUin})
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = LHD_Games_txt.br_stand_tips})
        end
    end)
    if panelBox:getChildByName("btnHelp") then
        addButtonEvent(panelBox:getChildByName("btnHelp"), function ( ... )
            self:showHelpView()
        end)
    end
    
    addButtonEvent(panelBox:getChildByName("Panel_Out"), function ()
        panelBox:setVisible(false)
    end)
    
    -- local btnName = {"btnBack", "btnSet", "btnBank", "btnUp"}
    -- for i, v in ipairs(btnName) do
    --     panelBox:getChildByName(v):setTouchEnabled(true)
    --     panelBox:getChildByName(v):setEnabled(true)        
    -- end
end

function LHDGameView:chipsToPool(paras)
    if paras == nil then return end
    local pool = self._rightPools[paras.index]
    local u = self.chipsUser[paras.user]
    if pool == nil or u == nil then return end
    local from 
    if "other" == paras.user then 
        from = cc.p(u:getPositionX(),u:getPositionY())
        if not paras.nobet then
            self:jumpActionForBet(u,1)
        end
    else
        local user_data = self.deskCache:getUserByUin(Cache.user.uin)
        if u.uin == Cache.user.uin then 
            --自己钱没了也不要下注了
            local user = self.deskCache:getUserByUin(Cache.user.uin)
            loga("my chip = "..user.chips.." bet = "..paras.value)

            --如果是自己手动点击的话，因为我点击之前的我手上的筹码多于选中的筹码，但是服务器返回之后，手上的筹码更新了，这个时候手上筹码比选中的
            --筹码小，所以会出现bug 这里加个ismyself 表示这里不经过判断至于其他的情形默认不变
            if paras.ismyself then
            else
                if tonumber(user.chips) < tonumber(paras.value) then
                    --refresh自己的ui
                    self.myself:bet()
                    u:bet()
                    return
                end            
            end

            if not paras.nobet then
                -- 下注，不是结算的时候
                self.myself:bet()
                u:bet()
                --u:_setGold(user.chips - paras.value)
                self:jumpActionForBet(u)
            end
            self._addP:smartChoice()
        end
        from = u:getChipsPosition()
        self._addP:updateBtnsStatus(user_data.chips)
        self._addP:smartChoice()
        if u.uin ~= Cache.user.uin then 
            u:bet()
            if paras.user ~= "delar" and not paras.nobet then
                self:jumpActionForBet(u)
            end
        end
    end
    
    if paras.no_action ~= true then
        pool:chipsToPool({from = from,value = paras.value,myself = paras.ismyself,noanimation = paras.noanimation,notadd = paras.notadd,odds = paras.odds})
    end

	if paras == nil or not paras.is_bet then return end
    if self.deskCache.stage == 2 then--下注时间
        self:showLimitChips()
    end
end

--显示可下注金额
function LHDGameView:showLimitChips()
	self.deskCache._limit_chips = {}
	local delar = self.deskCache:getDelar()
    if delar and delar.chips then
        local _delarChips = Cache.packetInfo:getProMoney(delar.chips)
        local _all_chips = self.deskCache._all_chips
	    for i=1, 3 do
	    	_all_chips[i] = _all_chips[i] or 0
	    end
	    for k,v in pairs(self._rightPools) do
		    local limit_bet_num = 0
		    if k == 1 then
		        -- limit_bet_num = _delarChips+_all_chips[2]+_all_chips[3]-_all_chips[1]
                limit_bet_num = _delarChips+_all_chips[2]+_all_chips[3]
		    elseif k == 2 then
                -- limit_bet_num = _delarChips+_all_chips[1]+_all_chips[3]-_all_chips[2]
		    	limit_bet_num = _delarChips+_all_chips[1]+_all_chips[3]
            elseif k == 3 then
		    	limit_bet_num = (_delarChips+(_all_chips[1]+_all_chips[2]))/8
		    end
	    	v:setLimitChipsNum(math.floor(limit_bet_num)>=0 and math.floor(limit_bet_num) or 0)
	    	self.deskCache._limit_chips[k] = limit_bet_num
	    end
	end
end

--[[]]
function LHDGameView:delayRun(time,cb,tag)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function () if cb then cb() end end))
    if tag then action:setTag(tag) end
    self:runAction(action)
end

function LHDGameView:stopDelayRun(tag)
    if self:getActionByTag(tag) then self:stopActionByTag(tag) end
end

-- 1s后发牌 3s后开始下注
function LHDGameView:sendCard( ... )
    -- body
    --显示开始下注动画
    logi("=============发牌==============")
    self.time_panel:setVisible(false)
    self:stopPlayTimeCountAnimation()
    self.resultTopPannel:resetCard()

    --发牌
    self:delayRun(1, function ( ... )
        self.resultTopPannel:sendCard(true,function ( ... )
            
        end)
    end)

    -- 3s后显示开始下注
    self:delayRun(3,function ( ... )
        logi("=============开始下注==============")
        self:ready(true)
    end)
end

function LHDGameView:ready(showTimeCount)
    if showTimeCount then
        self.time_panel:setVisible(true)
        self:showTimeCountAnimation()
        ccui.Helper:seekWidgetByName(self.gui,"time_img"):setVisible(true)
    end
    
    self.delar:ready()
    for k ,v in pairs(self._rightPools) do
         v:ready()
    end
    self.deskCache:updateCanBeBet(true)
    self.deskCache._all_chips = {} --百人场下注的总数
    self.deskCache._my_chips = {}--自己下的注
    local user_data = self.deskCache:getUserByUin(Cache.user.uin)
    self._addP:updateBtnsStatus(user_data.chips)
    self._addP:smartChoice()
end

function LHDGameView:updateByInput()
    qf.event:dispatchEvent(LHD_ET.BR_QUERY_RECENT_TREND_CLICK)
    self._addP:initBtns()
    
    --进桌这里有点特殊，需要处理空闲时间、和下注时间
    --如果服务器是下注时间
    if self.deskCache.stage == 2 then
        --刚好是
        if self.deskCache.time_remain == self.deskCache:getServerBetTime() then
            self:sendCard()
            -- 3s后开始下注
            self:delayRun(3, function ( ... )
                self:ready(true)
            end)
        end

        -- 已经是在下注时间内
        if self.deskCache.time_remain < self.deskCache:getServerBetTime() then
            self.resultTopPannel:sendCard(false)
            if self.deskCache.time_remain <= self.deskCache:getClientBetTime() then
                self:ready(true)
            else
                self:delayRun(self.deskCache.time_remain - self.deskCache:getClientBetTime(), function ( ... )
                    self:ready(true)
                end)
            end
        end
    else
        self.time_panel:setVisible(false)
        self:stopPlayTimeCountAnimation()
        self:ready(true)
    end
    self:timeCountDown({time = self.deskCache.time_remain,status = self.deskCache.stage,init=true})
    local user_data = self.deskCache:getUserByUin(Cache.user.uin)
    self._addP:initBtnsStatus()
    self._addP:updateBtnsStatus(user_data.chips)
    self._addP:smartChoice()
    self.myself:updateInfo()
    local user_list = self.deskCache:getUserList()
    for uin, v in pairs(user_list) do
        if v.seatid ~= nil and v.seatid > 0 then
            self:someoneSitdown(uin)
        end
    end
    self:delarSitdown()
    local total_chips = self.deskCache:getTotalChips()
    for index,section in pairs(total_chips) do       
        for k,count in pairs(section) do
            for i = 1,count.count do
                self:chipsToPool({user = "other",value = count.chips,index = index,noanimation = true})
            end
        end
    end
    local my_bets = self.deskCache:getMyBets()
    for k, v in pairs(my_bets) do
        self._rightPools[k]:setMyselfChips(v)
    end

    if self.deskCache.stage == 2 then
        self:showLimitChips()
        self:initChipsPoolTouch()
    end
end

--龙虎斗
--客户端 龙虎斗特效时间->发牌时间->下注时间->存在一定的空隙->停止下注->结算时间->空闲时间
--服务器 开始时间  结算时间
---结算
function LHDGameView:updateByOver(delayTime)
    local long = self.deskCache:getLhdCardsByCardId(1)
    local hu = self.deskCache:getLhdCardsByCardId(2)

    --龙虎 结果此时未知 处理刚进来的状态 这个时候还原不了牌桌列表
    -- 所以此时就用服务器告知的时间来进行倒计时状态表示 请耐心等待下一局
    if long == nil or hu == nil then
        local time_remain = self.deskCache.time_remain - delayTime
        self.time_panel:setVisible(true)
        self:showTimeCountAnimation()
        --显示空闲时间
        self:timeCountDown({time = time_remain, status = 1})
        return
    end

    --时间长度
    --开牌动画时间 -> 筹码分发时间 -> 空闲时间
    --总时间 = 结算总时间 + 空闲时间
    --总时间
    local totalTime = self.deskCache.time_remain - delayTime
    --空闲时间
    local restTime = 6
    --结算总时间
    local accTime = totalTime - restTime

    --结算总时间 = 开牌动画时间 + 筹码分发时间
    --开牌动画时间
    local openCardTime = 3
    --筹码分发时间
    local chipSendTime = accTime - openCardTime


    --时间点
    --筹码分发时间点 -> 空闲时间点 -> 龙虎斗开始时间点
    --筹码开始分发时间点
    local chipSendTimePoint = openCardTime
    --空闲时间点
    local restTimePoint = accTime
    --下一次开始的时间点
    -- 重新开始前 0.5s 进行龙虎斗开始动画
    local reStartTimePoint = totalTime - 1



    --收到结算通知后 服务器会告知客户端 多少秒后会进行下一场开局
    --此时客户端要先进行结算然后空闲时间等待 所以要先预留时间给空闲时间
    --结算时间
    logi(">>>>>>>>>>>>> remain time 结算时间：>>>>>>>>>>>>>", accTime)
    logi("==============停止下注时间==============" ..self.deskCache.time_remain)
    --显示结果、开牌等
    --开牌动画 开始
    self:showGameEnd()

    ccui.Helper:seekWidgetByName(self.gui,"time_img"):setVisible(true)
    self.time_panel:setVisible(true)
    self:showTimeCountAnimation()
    --正在结算
    self:timeCountDown({time = accTime, status = 4})
    self:removeTouchEventListener()

	self:delayRun(chipSendTimePoint, function()
        logi("开牌动画 结束 开始进行结算")
        logi("=================结算开始============")
        --为防止开和时筹码不能完美分配，先分割大筹码
        local win_card_id = self.deskCache:getLhdWinCardId()
        if win_card_id == 3 then
            logi("=================开和分割筹码============")
            self:gameOverSplitPool()
        end

        self:gameOverAnimation(chipSendTime) 
        --如果走势图存在则刷新走势图
        if not tolua.isnull(self.lhdHistory) then
            self.lhdHistory:refreshLuDan()
        end
    end)

    -- 结算后 开始进行空闲时间的倒计时
    -- 隔开一秒进行倒计时操作
    self:delayRun(restTimePoint, function( ... )
        logi("=================结算完成============")
        logi("==========开始显示 空闲时间倒计时==========")
        --加了停止下注要把文本显示
        self.time_panel:setVisible(true)
        self:showTimeCountAnimation()
        --显示空闲时间
        self:timeCountDown({time = restTime-1, status = 1})
        self:updateUsersResult()
    --统一处理
        self.resultTopPannel:resetCard()
        PopupManager:downwardAllPopup()
    end)

    --龙虎斗pk动画弹出
    self:delayRun(reStartTimePoint, function ( ... )
        logi("=========空闲倒计时结束 播放龙虎斗开始动画=====")
        logi("==================等待下注=====================")
        self:showPKAnimation()
    end)
end

function LHDGameView:updateUsersResult( ... )
    local bJoinThisTurn = false --当前自己是否参加了这局游戏
    for k,v in pairs(Cache.lhdDesk._user) do
        local winChips = Cache.lhdDesk.lhd_total_result[k]
        --不输不赢、庄家
        if winChips and winChips ~= 0 and checkint(k) > 1010 and k ~= -1 then
            local user = self._rightUsers[v.seatid]
            if user then
                user:showSelfResult({chips = Cache.packetInfo:getProMoney(winChips), uin = k})
            end
            if k == Cache.user.uin then
                self.myself:showSelfResult({chips = Cache.packetInfo:getProMoney(winChips)})
                qf.event:dispatchEvent(LHD_ET.GAME_REFRESH_ADDBTN)
                bJoinThisTurn = true
            end
        end
    end
    if bJoinThisTurn then
        qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP, {showTxt = GameTxt.showInsufficientTxt})
    end
end

function LHDGameView:exitCall(paras)
    if self.delar.uin == Cache.user.uin then 
        return qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_delar_exit_tips})
    end
    qf.event:dispatchEvent(LHD_ET.LHD_EXIT_REQ, {send=true, guideToChat = paras and paras.guidetochat or false})
end

function LHDGameView:showGameEnd()
    PopupManager:upwardAllPopup()   --收起弹框
    MusicPlayer:playMyEffect("BTN")

    self.resultTopPannel:show(function (winCard)
        --表示哪个牌桌胜利了
        self:chipsPoolShowWinResult(winCard)
        for k,v in pairs(self._rightPools) do
            v:clearLimitChipsNum()
        end
    end)
end

function LHDGameView:showPKAnimation( ... )
    ccui.Helper:seekWidgetByName(self.gui,"time_img"):setVisible(false)
    self.time_panel:setVisible(false)
    self:stopPlayTimeCountAnimation()
    local animName = "PKAnimation"
    self:hidePKAnimation()



    local movementcb = function (arm, mmType, mmID)
        if mmType == ccs.MovementEventType.complete then
            arm:removeFromParent(true)
        end
    end


    Util:playAnimation({
        anim = LHDAniConfig.PK,
        name = animName,
        position = cc.p(self.gui:getContentSize().width/2,self.gui:getContentSize().height/2),
        node = self.gui,
        movementcb = movementcb,
        order = 10
    })
end

function LHDGameView:hidePKAnimation( ... )
    local animName = "PKAnimation"
    if self.gui:getChildByName(animName) then
        self.gui:removeChildByName(animName)
    end
end

function LHDGameView:hideChat( ... )
    if self._chat then
        self._chat:hide()
    end
end

---下注时间
function LHDGameView:betTime()
    if self.deskCache.stage == 2 and self.deskCache.time_remain < self.deskCache:getServerBetTime() - 1 then
        return
    end
    if self.betTimeAniStart then
        return
    end
    self.deskCache:updateCanBeBet(true)
	self:showLimitChips()
    if self.delar.uin == Cache.user.uin then return end
    for k, v in pairs(self._rightPools) do
        v:betTime()
        v:clearLastCache()
    end
    logi("==========>>>>>>>下注时间")
    self.resultTopPannel:sendCard(false)
    self:initChipsPoolTouch()
    self:showTimeCountAnimation()
    -- 开始下注动画
    self:betTimeAnimation(true)
    MusicPlayer:playMyEffectGames(LHD_Games_res,"START_BET")
end

function LHDGameView:betTimeAnimation(isBet)
    -- body
    -- local flag = isBet == true and 1 or 0
    -- self.startBetImg:loadTexture(string.format(LHD_Games_res.lhd_bet_time_img, flag) , ccui.TextureResType.plistType)
    -- self.startBetImg:setVisible(true)
    -- self.startBetImg:setScale(0.8)
    -- self.betTimeAniStart = true
    -- self.startBetImg:runAction(cc.Sequence:create(
    --     cc.DelayTime:create(isBet == true and 0 or 1),
    --     cc.EaseSineOut:create(cc.Spawn:create(
    --         cc.ScaleTo:create(0.25, 1.3),
    --         cc.FadeIn:create(0.25)
    --     )),
    --     cc.DelayTime:create(0.6),
    --     cc.EaseSineIn:create(cc.Spawn:create(
    --         cc.ScaleTo:create(0.1, 0.8),
    --         cc.FadeOut:create(0.1)
    --     )),
    --     cc.CallFunc:create(function ( ... )
    --        self.betTimeAniStart = false
    --     end)
    -- ))
    self:playBetEfx(isBet)
end

function LHDGameView:initChipsPoolTouch( ... )
    logi("============>>>>>>>>>LHDGameView:initChipsPoolTouch 触摸开始")
    self.canTouchFlag = true
    self.chips_pool_bg = self.gui:getChildByName("chips_pool_bg")
    self.chips_pool_bg:setTouchEnabled(true)
    --fix bug 调用此函数多次会造成 点击会造成多次下注现象
    if self.touch_listener then
        return
    end

    local layer = cc.Layer:create()
    self:addChild(layer, self.TOUCH_ZORDER)

    --点触事件
    self.touch_listener = cc.EventListenerTouchOneByOne:create()
    self.touch_listener:setSwallowTouches(false)
    self.touch_listener:registerScriptHandler(function(touch,event)

        return self.canTouchFlag
    end,cc.Handler.EVENT_TOUCH_BEGAN)

    self.touch_listener:registerScriptHandler(function(touch,event)
        print("zxcvzxcv chat vis >>>>>", self._chat:isVisible())
        if self._chat:isVisible() then
            return
        end
        --将触摸点转化为节点下位置
        local touchPos = self.chips_pool_bg:convertTouchToNodeSpaceAR(touch)
        if cc.rectContainsPoint(self.chips_pool_bg:getBoundingBox(),touch:getLocation()) then
            --中间线宽度
            local lineMargin = 10
            --和的区域
            local heCenterPos = cc.p(0, self.chips_pool_bg:getContentSize().height/2)
            local r_offset = 35
            local r = self.chips_pool_bg:getContentSize().height/2 + r_offset

            local y_abs = touchPos.y > 0 and touchPos.y + math.abs(heCenterPos.y) or math.abs(heCenterPos.y) - math.abs(touchPos.y)
            local distance = math.sqrt(math.pow(math.abs(touchPos.x)- heCenterPos.x,2) + math.pow(y_abs,2))
            local poolIndex = 0
            if distance < r then
                poolIndex = 3
            else
                if touchPos.x < -lineMargin then
                    poolIndex = 1
                end
                if touchPos.x > lineMargin then
                    poolIndex = 2
                end
            end
            if poolIndex > 0 and self.deskCache.stage == 2 and self.deskCache:getCanBetStatus() then
                loga("============>>>>>>>>>LHDGameView:initChipsPoolTouch 点击下注")
                self._rightPools[poolIndex]:betAction()
            end
        end
    end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.touch_listener, layer)
end

function LHDGameView:removeTouchEventListener( ... )
    self.canTouchFlag = false
end

function LHDGameView:showHistory()
    qf.event:dispatchEvent(LHD_ET.BR_QUERY_RECENT_TREND_CLICK)
    self.lhdHistory = LHDHistory.new({})
    self.lhdHistory:show()
end

function LHDGameView:updateHistory()
    --重新获取路单图
    if not tolua.isnull(self.lhdHistory) then
        self.lhdHistory:resetLuDan()
    end
    local trendPannel = self.gui:getChildByName("trend_pannel")
    trendPannel:setVisible(true)
    local total = 10
    local index = 1
    for i = total ,1, -1 do
        local section = Cache.lhdinfo.tab_ludan[i]
        if section then
            trendPannel:getChildByName("trend_item_" .. index):loadTexture(string.format(LHD_Games_res.trend_img_name, section), ccui.TextureResType.plistType)
        end
        index = index + 1
    end
end

function LHDGameView:showHelpView()

    qf.event:dispatchEvent(ET.GAMERULE, {GameType = Cache.DeskAssemble:getGameType()})        
end

--显示商城
function LHDGameView:showShopView( ... )
    qf.platform:umengStatistics({umeng_key = "QuickSale1Open"})
    --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {gold=1000000, ref=UserActionPos.BR_SIT_LACK})
    qf.event:dispatchEvent(ET.SHOP)
end

function LHDGameView:giveCards()

end

function LHDGameView:chipsPoolShowWinResult(index)
    self._rightPools[index]:showVictory()
end

function LHDGameView:resetChipsPool()
    for i, v in ipairs(self._rightPools) do
        v:hideVictory()
    end
end
function LHDGameView:showDelarList(isExit)
    local LHDDelarList = require("src.games.game_lhd.modules.game.lhdcomponents.LHDDelarList")
    local lhdDelarList = LHDDelarList.new(isExit)
    lhdDelarList:show()
end

--给筹码池中的筹码排序
function LHDGameView:sortChipsPool(index)
    local pool = self._rightPools[index]
    pool:sortPoolChips()
end

function LHDGameView:chipsFallBack(index,value)
    local pool = self._rightPools[index]
    pool:chipsFallBack(value)
end

--分割筹码池
function LHDGameView:splitPool(index,value)
    local pool = self._rightPools[index]
    pool:splitPool(value)
end

--只有开和时才可能筹码不能完美分配，分割筹码
function LHDGameView:gameOverSplitPool()
    local function getOtherChips(info,k,i,uin)
        local value
        if uin == - 1 then
            value = self.deskCache.other_result[k].chips
        else
            value = info.chips
        end
        return value
    end

    local tbChipsValue = ChipManager:getChipsValueTable()
    for k,v in pairs(self.deskCache._result) do
        local count = 0
        local last = v[#v]
        self:sortChipsPool(k) --给筹码池中的筹码排序
        for j = 2,#tbChipsValue do
            for i ,info in pairs(v) do
                local uin = info.uin
                local user = self:getBetUserByUin(uin)
                local value = math.abs(getOtherChips(info,k,i,uin))
                if user == "delar" then
                    if info.odds < 0 and info.odds == -0.5 and value > 0 then--庄家赢
                        value = value/2
                        local chip = value%tbChipsValue[j] - value%tbChipsValue[j-1]
                        if chip > 0 then
                            --loge("庄家分割:"..chip)
                            self:splitPool(k, chip)
                        end
                    end
                else
                    if info.odds > 0 and info.odds == 0.5 and value > 0 then--玩家赢
                        local chip = value%tbChipsValue[j] - value%tbChipsValue[j-1]
                        if chip > 0 then
                            --loge("玩家分割:"..chip)
                            self:splitPool(k, chip)
                        end
                    end
                end
            end
        end
    end
end

---结算动画
function LHDGameView:gameOverAnimation(chipTime)
    logi("=================结算动画开始============")
    --chipTime 表示的是整个OverAnimation 所要花时间的总和
    --时间点

    --庄家吐注时间点
    local zhuangSendTimePoint = 2.8

    --庄家收注时间点
    local zhuangReceiveTimePoint = 1

    --用户收注时间点
    local userReceiveTimePoint = 4

    --开和自己胜利更新时间点
    local myWinTimePoint = 2
	--清空牌桌上的胜利标识
    local bResetChipPoolFlag = true
    local function getOtherChips(info,k,i,uin)
        local value
        if uin == - 1 then
            value = self.deskCache.other_result[k].chips
        else
            value = info.chips
        end
        return value
    end

    for k,v in pairs(self.deskCache._result) do
        for i,m in pairs(v) do
            --无座玩家最后发放筹码
            if m.uin == -1 then
                local data = clone(m)
                table.remove(v,i)
                table.insert(v,(#v+1),data)
                break
            end
        end
        local count = 0
        local last = v[#v]
        for i ,info in pairs(v) do
            local uin = info.uin
            local user = self:getBetUserByUin(uin)
            if user == "delar" then
                if info.odds > 0 then
                    if math.abs(info.odds) ~= 0.5 then
                        --庄家吐注,最多分7部分吐出来
                        for j, bets in pairs(v) do
                            local user_bets = self:getBetUserByUin(bets.uin)
                            if user_bets ~= "delar" then
                                self:delayRun(zhuangSendTimePoint,function()
                                    logi("庄家吐注")
                                    self.delar:bet() --刷新庄家筹码
                                    if uin == Cache.user.uin then
                                        self.myself:bet() --如果庄家是自己刷新自己的筹码
                                    end
                                    if k == 3 then
                                        self:chipsToPool({user = "delar",value = math.abs(bets.chips/9*8),index = k, nobet=true, odds=info.odds})
                                    else
                                        self:chipsToPool({user = "delar",value = math.abs(bets.chips/2),index = k, nobet=true, odds=info.odds})
                                    end
                                end)
                            end
                        end
                    end
                else
                    self:delayRun(zhuangReceiveTimePoint,function() 
                        logi("庄家收注")
                        -- 庄家收注
                        if math.abs(info.odds) == 0.5 then
                            --开和，龙虎区域庄家只收一半注
                            self:chipsToUser({user = "delar",value = math.abs(info.chips)/2, index = k})
                        else
                            self:chipsToUser({user = "delar",value = count,index = k,all = true})
                        end
                    end)
                end
            else
                if info.odds < 0 then--庄家赢
                    local value = getOtherChips(info,k,i,uin)
                    self:chipsToPool({user = user,value = math.abs(value),index = k, nobet=true, odds=info.odds})
                elseif info.odds >= 0 then--玩家赢
                    local value = getOtherChips(info,k,i,uin)
                    local to_user_time = userReceiveTimePoint
                    self:delayRun(to_user_time+0.01*i,function()
                        self:chipsToUser({user = user,value = math.abs(value),index = k,all = uin == last.uin})
                        if bResetChipPoolFlag then
                            self:resetChipsPool()
                            bResetChipPoolFlag = false
                        end
                    end)
                    if uin == Cache.user.uin then
                        if info.odds == 0 then
                            --龙虎下注区域在开和的情况下等庄家收注后更新自己可得筹码数,其他情况都是庄家吐注后更新
                            self:delayRun(myWinTimePoint,function()
                                 self._rightPools[k]:setMyselfChips(math.abs(value))
                            end)
                        end
                    end
                end
            end
        end
        self._rightPools[k]:showResult(Cache.user.uin == self.delar.uin)
    end
end

---筹码下注时的弹跳动画
function LHDGameView:jumpActionForBet(u,atype)
    if atype then
        local a = u:getActionByTag(self.TAG_CHIP_ACTION)
        if a then
            if a:isDone() then
                u:runAction(a)
            end
        else
            local action = cc.Sequence:create(cc.MoveBy:create(0.1,cc.p(0,-20))
                ,cc.MoveBy:create(0.1,cc.p(0,20))
                ,cc.MoveBy:create(0.1,cc.p(0,-10))
                ,cc.MoveBy:create(0.1,cc.p(0,10))
                ,cc.MoveBy:create(0.1,cc.p(0,-3))
                ,cc.MoveBy:create(0.1,cc.p(0,3))
                ,cc.DelayTime:create(0.2)
                )
            action:setTag(self.TAG_CHIP_ACTION)
            u:runAction(action)
        end
    else
        x=0
        local a = u:getActionByTag(self.TAG_CHIP_ACTION)
        if a then
            if a:isDone() then
                u:runAction(a)
            end
        else
            local action = cc.Sequence:create(cc.MoveBy:create(0.1,cc.p(0,20))
                ,cc.MoveBy:create(0.1,cc.p(0,-20))
                ,cc.MoveBy:create(0.1,cc.p(0,10))
                ,cc.MoveBy:create(0.1,cc.p(0,-10))
                ,cc.MoveBy:create(0.1,cc.p(0,3))
                ,cc.MoveBy:create(0.1,cc.p(0,-3))
                ,cc.DelayTime:create(0.2)
                )
            action:setTag(self.TAG_CHIP_ACTION)
            u:runAction(action)
        end
    end
end

--显示积分
function LHDGameView:showJiFen(score)
    if score == nil then return end
    self.myself:showJiFen(score)
end

function LHDGameView:release()
    if ChipManager then
        ChipManager:release()
    end
    UserDisplay:removeAllAnimationData()
end

function LHDGameView:someoneStand(uin)
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then 
            if uin == Cache.user.uin then
                self.chipsUser.myself = self.myself
            end
            return v:leave()
        end
    end
end

function LHDGameView:someoneSitdown(uin)
    local someone = self.deskCache:getUserByUin(uin)
    local right = self._rightUsers[someone.seatid]
    if right == nil then return end
    if someone.uin == Cache.user.uin then
        self.chipsUser.myself = right
    end
    right:seatDown(someone)
end

--检查某人是否坐下
function LHDGameView:checkSomeoneSitDown(uin)
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then 
            return true
        end
    end
    return false
end

--上庄
function LHDGameView:delarSitdown()
    local someone = self.deskCache:getDelar()
    if someone.uin == nil then return end 
    if someone.uin == Cache.user.uin then 
        self.chipsUser.myself = self.delar
        self._addP:setVisible(false)
        self:restTime()
    else
        local user_data = self.deskCache:getUserByUin(Cache.user.uin)
        self._addP:setVisible(true)
        -- self._addP:updateBtnsStatus(user_data.chips)
        -- self._addP:smartChoice()
    end
    self.delar:seatDown()
end
--下庄
function LHDGameView:delarlLeave()
    local someone = self.deskCache:getDelar()
    local user_data = self.deskCache:getUserByUin(Cache.user.uin)
    if someone.uin == Cache.user.uin then 
        self.chipsUser.myself = self.myself
        self._addP:setVisible(true)
        -- self._addP:updateBtnsStatus(user_data.chips)
        -- self._addP:smartChoice()
    end
    self.delar:leave()
end

function LHDGameView:getBetUserByUin(uin)
    if uin == -1 then 
        return "other"
    elseif uin == self.delar.uin then
        return "delar" 
    elseif uin == Cache.user.uin then
        return "myself"
    else
        for k, v in pairs(self._rightUsers) do
            if v.uin == uin then return "seat_user"..k end
        end
    end
    return "other"
end

function LHDGameView:getSeatUserByUin(uin)
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then 
            return v
        end
    end
end

-- 进桌和退桌会通知
function LHDGameView:someChipsChange(model)
    if model == nil then return end
    if model.uin == Cache.user.uin then
        self.myself:_setGold(model.chips)
        self._addP:smartChoice()
    end 

    local u = self:getSeatUserByUin(model.uin)
    if u and tolua.isnull(u) == false then
        u:setGold(model.chips)
    end
    local delar = self.deskCache:getDelar()
    if delar.uin == model.uin then
        self.delar:setGold(Cache.packetInfo:getProMoney(model.chips))
    end
end

--停止下注阶段
function LHDGameView:stopBetTime( ... )
    loga("==========服务器告诉我 停止下注============= time = " .. os.time())
    -- 这里是断线重连过来的
    if self.deskCache.stage == 1 then
        return
    end
    self.deskCache:setStage(3)
    local timeCount = self.time_panel
    local timeImg = ccui.Helper:seekWidgetByName(self.gui,"time_img")
    local res = LHD_Games_res["br_game_state_txt_".. self.deskCache.stage]
    timeImg:loadTexture(res, ccui.TextureResType.plistType)
    timeCount:stopAllActions()
    timeCount:setVisible(false)
    timeImg:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function ( ... )
            timeImg:setVisible(false)
        end)
    ))
    
    self:removeTouchEventListener()
    self:restTime()
    self:stopPlayTimeCountAnimation()
    

    if self.betTimeAniStart then
        return
    end
    -- 结束下注动画
    self:betTimeAnimation(false)
    MusicPlayer:playMyEffectGames(LHD_Games_res,"STOP_BET")
end

---倒计时
--self:timeCountDown({time = 10,status = 1})
function LHDGameView:timeCountDown(paras)
    local timeCount = self.time_panel
    local timeImg = ccui.Helper:seekWidgetByName(self.gui,"time_img")
    timeCount:stopAllActions()
    if paras == nil then 
        timeCount:setVisible(false)
        timeImg:setVisible(false)
        self:removeTouchEventListener()
        self:restTime() 
        return 
    end
    local res = LHD_Games_res["br_game_state_txt_"..paras.status]
    local time = paras.time
    
    if res == nil or time == nil then  
        timeCount:setVisible(false)
        timeImg:setVisible(false)
        self:removeTouchEventListener()
        return 
    end
    local updateTimeString = function (inTime)
        if inTime == 0 then
            --如果是下注时间结束，则更新状态
            if self.deskCache.stage == 2 then
                self.deskCache:updateCanBeBet(false)
            end
            self:stopPlayTimeCountAnimation()
            timeCount:setVisible(false)
            self.time_panel:setVisible(false)
            return
        end
        local unitPlace = math.modf(inTime/10)
        local tenPlace = math.fmod(inTime, 10)
        self.time_panel:getChildByName("time_txt_1"):setString(unitPlace)
        self.time_panel:getChildByName("time_txt_1"):setFntFile(inTime <= 5 and LHD_Games_res.time_count_font_1 or LHD_Games_res.time_count_font_0)

        self.time_panel:getChildByName("time_txt_2"):setString(tenPlace)
        self.time_panel:getChildByName("time_txt_2"):setFntFile(inTime <= 5 and LHD_Games_res.time_count_font_1 or LHD_Games_res.time_count_font_0)
    end
    local loadTimeImg = function (img, status, time)
        local res = LHD_Games_res["br_game_state_txt_"..status]
        if status == 1 then
            if time > 6 and paras.init then
                res = LHD_Games_res["br_game_state_txt_5"]
            else
                res = LHD_Games_res["br_game_state_txt_"..status]
            end
        end
        img:loadTexture(res, ccui.TextureResType.plistType)
    end

    -- timeImg:loadTexture(res, ccui.TextureResType.plistType)
    time = time <= 0 and 0 or time
    loadTimeImg(timeImg, paras.status, time)
    updateTimeString(time)
    timeCount:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                if time <= 0 then 
                    timeCount:stopAllActions() 
                    if paras.status == 2 then
                        self:restTime()
                    else
                        self:stopPlayTimeCountAnimation()
                        timeCount:setVisible(false)
                        timeImg:setVisible(false)
                    end
                return  end 
                time = time - 1
                -- loadTimeImg(timeImg, paras.status, time)
                updateTimeString(time)
                if paras.status == 2 and time <= 3 and time > 1 then
                    MusicPlayer:playMyEffect("TIME_WARNING")
                end
            end)
        )
    ))
    if paras.status == 1 then
        self:restTime()
    elseif paras.status == 2 and time <= 15 then
        timeCount:setVisible(true)
        self:betTime()
    end
    self.deskCache:setStage(paras.status)
end

--播放倒计时动画
function LHDGameView:showTimeCountAnimation( ... )
    local animName = "timeCountAni"
    self:stopPlayTimeCountAnimation()


    local movementcb = function (arm, mmType, mmID)
        if mmType == ccs.MovementEventType.complete then
            arm:removeFromParent(true)
        end
    end
    
    Util:playAnimation({
        anim = LHDAniConfig.TIMECOUNT,
        name = "timeCountAni",
        position = cc.p(self.tips_panel:getContentSize().width/2,self.tips_panel:getContentSize().height/2),
        node = self.tips_panel,
        movementcb = movementcb
    })

end

--隐藏倒计时动画
function LHDGameView:stopPlayTimeCountAnimation( ... )
    local animName = "timeCountAni"
    if self.tips_panel:getChildByName(animName) then
        self.tips_panel:removeChildByName(animName)
    end
end

---休息时间
function LHDGameView:restTime()
    for k, v in pairs(self._rightPools) do
        v:clearLastCache()
    end
    self:removeTouchEventListener()
end

--播放龙虎粒子动画
function LHDGameView:playTopLHAnimation( ... )
    local animName = "topLHAnimation"
    self:hideTopLHAnimation()

    local movementcb = function (arm, mmType, mmID)
        if mmType == ccs.MovementEventType.complete then
            arm:removeFromParent(true)
        end
    end
    
    Util:playAnimation({
        anim = LHDAniConfig.TOPLH,
        name = animName,
        position = cc.p(self.tips_panel:getContentSize().width/2,self.tips_panel:getContentSize().height/2),
        node = self.tips_panel,
        movementcb = movementcb
    })

end

--隐藏龙虎粒子动画
function LHDGameView:hideTopLHAnimation( ... )
    local animName = "topLHAnimation"
    if self.tips_panel:getChildByName(animName) then
        self.tips_panel:removeChildByName(animName)
    end
end

function LHDGameView:updateBrPerson()
    local LHDPerson = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.brPerson)
    if LHDPerson then
        LHDPerson:update(Cache.lhdinfo)
    end
end

function LHDGameView:showPerson()
    qf.event:dispatchEvent(LHD_ET.BR_QUERY_PLAYER_LIST_CLICK)
    local LHDPerson = LHDPerson.new()
    LHDPerson:show()
end

function LHDGameView:getRoot()
    return LayerManager.GameLayer
end

--获取下注区域的筹码数量
function LHDGameView:getChipsNum(index)
    return self._rightPools[index]:getChipsNum()
end

---筹码飞向玩家动画
function LHDGameView:chipsToUser(paras)
    if paras == nil then return end
    if "jackpot" == paras.user then
        
    else
        local pool = self._rightPools[paras.index]
        local u = self.chipsUser[paras.user]
        if pool == nil or u == nil then return end
        local to
        local cb
        if "other" == paras.user then
            to = cc.p(u:getPositionX(),u:getPositionY())
        else
            if u.uin == Cache.user.uin then 
                cb = function( ... )
                    self.myself:bet(true)
                    u:bet()
                    local user_data = self.deskCache:getUserByUin(Cache.user.uin)
                    self._addP:updateBtnsStatus(user_data.chips)
                    self._addP:smartChoice()
                end
            end
            to = u:getChipsPosition()
            
            if u.uin ~= Cache.user.uin then 
                u:bet()
            end
        end
        pool:chipsToUser({to = to,value = paras.value,all = paras.all, cb=cb})
    end
end
-- 筹码飞动
function LHDGameView:chipFly( paras )
    local chips = ChipManager:createT(paras.value)
    for k, chip in pairs(chips) do
        self._panContainer:addChild(chip, 2)
        chip:setPosition(cc.p(paras.from.x, paras.from.y))
        local delay = (k - 1 )*0.02
        delay = delay >= 0.5 and 0.5 or delay
        ChipManager:fly(delay, chip, paras.from, paras.to)
    end
end

function LHDGameView:updateDelarList()
    local lhdDelarList = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.lhdDelarList)
    if lhdDelarList then
        lhdDelarList:update()
    end
end

function LHDGameView:refreshAddBtn()
    logi("======================>>>>>>>>>>>refreshAddBtn")
    local user_data = self.deskCache:getUserByUin(Cache.user.uin)
    self._addP:updateBtnsStatus(user_data.chips)
    self._addP:smartChoice()
end

function LHDGameView:updatePoolCacheChips()
    ChipManager:updatePoolCacheChips()
end


function LHDGameView:exit()
    Util:loadAnim(LHDAniConfig, false)
end

function LHDGameView:enter()
    Util:loadAnim(LHDAniConfig, true)
end

function LHDGameView:playBetEfx(isBet)
    local config = require("src.common.HallAnimationConfig")
    if isBet  then
        animationConfig = config.BEGINBET
    else
        animationConfig = config.STOPBET
    end
    Util:playAnimation({
        anim = animationConfig,
        position = cc.p(self.gui:getContentSize().width/2,self.gui:getContentSize().height/2 + 275/4),
        node = self.gui,
        order = 10,
    })
end


-- function LHDGameView:playWinmoney(paras)
--     -- self.Gameanimation:playWinmoney(paras)
-- end

function LHDGameView:refreshHongBaoBtn()
    local shopBtn = self.gui:getChildByName("btn_shop")
    shopBtn:setVisible(Cache.user.first_recharge_flag == 0)
    if Cache.user.first_recharge_flag == 1 then
        local pos = shopBtn:getPosition3D()
        Util:addHongBaoBtn(self, pos)
    elseif Cache.user.first_recharge_flag == 0 then
        Util:removeHongBaoBtn(self)
    end
end

function LHDGameView:refreshNetStrength(paras)
    local diffX = 0
    Util:addNetStrengthFlag(self.gui, cc.p(190 -diffX,1045), paras)
end

--得到当前需要下注至少的money
function LHDGameView:getNeedMoney()
    local leastMoney = GameConstants.LEAST_MONEY
    local user = Cache.lhdDesk:getUserByUin(Cache.user.uin)
    print("user >>>>>>>>>>>", user)
    if user then
        local chip = Cache.packetInfo:getProMoney(user.chips)
        print("chip >>>>>>>>>>>", chip)
        return leastMoney - chip
    end
end

function LHDGameView:refreshNoMoneyTip(paras)
    local needMoney = self:getNeedMoney()
    local showTxt = nil
    if paras then
        showTxt = paras.showTxt
    end
    
    if needMoney then 
        if needMoney > 0 then
            Util:refreshNoMoneyTip(self, {restMoney = GameConstants.LEAST_MONEY, showTxt = showTxt})
        else
            Util:refreshNoMoneyTip(self, {restMoney = 0, showTxt = showTxt})
        end
    end
end

function LHDGameView:initChatUI()
	self.Chat = Chat.getChatBtn()
    if not Util:isHasReviewed() then
        self.Chat:setVisible(false)
    end
    self:addChild(self.Chat)

    self._chat = Chat.new({view=self,ChatCmd=CMD.LHD_USER_DESK_CHAT})
    self:addChild(self._chat, 3)
    self.chat_txt_layer = self._chat:getChatTxtLayer()
    self:addChild(self.chat_txt_layer, 2)

    --聊天
	self.Chat:setPosition(cc.p(1633, 63))
	addButtonEvent(self.Chat,function ( )
        -- body
        -- local myUin = Cache.user.uin
        -- local user = Cache.lhdDesk:getUserByUin(myUin)
        -- --无座 且自己不是庄家
        -- if (user and user.seatid == -1) then
        --     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.chat_shangzuo_txt})
        --     return 
        -- end
        
		self._chat:show()
    end)
    
    if FULLSCREENADAPTIVE then
        Util:setPosOffset(self.Chat, {x = self.winSize.width-1920,y = 0})
        Util:setPosOffset(self._chat, {x = self.winSize.width-1920,y = 0})

    end
end

function LHDGameView:chat(model)
    local userName = self:getBetUserByUin(model.op_uin)
    local user = self.chipsUser[userName]
    self._chat:chatProtocol(model, user, self)
    if userName == "myself" then
        self._chat:chatProtocol(model, self.myself, self)
    end
    
    local nick = model.nick
    self._chat:receiveNewMsg({model = model, name = nick, uin = model.op_uin})
end

function LHDGameView:test( ... )
    self.myself = LHDMyself.new({node = self.gui:getChildByName("lhd_myself_panel")})
    self.myself:setVisible(true)
    for i = 1 , 6 do
        self._rightUsers[i] = LHDUser.new({node = self.gui:getChildByName("user_panel_"..i),index = i})
        self.chipsUser["seat_user"..i] = self._rightUsers[i]
    end
    self:playBetEfx(true)
    -- self.myself = 
    self.myself:showResultAnimation()
    -- self.chips_pool_bg:setTouchEnabled(true)
    -- self.canTouchFlag = true
    -- self:initChipsPoolTouch()
    -- self:initChipsPoolTouch()
    -- self:initChipsPoolTouch()
    -- performWithDelay(self, function ( ... )
    --     self:removeTouchEventListener()
    -- end, 1.0)

    -- performWithDelay(self, function ( ... )
    --     self:initChipsPoolTouch()
    -- end, 3.0)
    -- performWithDelay(self, function ( ... )
    --     logi("qwerqwer", self.touch_listener)
    -- end, 5.0)
    -- logd("??????????????????? test")
    -- self._resTable1 = {
    --         LHD_Games_res.brchips_7,
    --         LHD_Games_res.brchips_6,
    --         LHD_Games_res.brchips_5,
    --         LHD_Games_res.brchips_4,
    --         LHD_Games_res.brchips_3,
    --         LHD_Games_res.brchips_2,
    --         LHD_Games_res.brchips_1,
    -- }
    -- self._varTable1 = tbChipsValueReverse
    -- for i, v in ipairs( self._resTable1) do
    --     local chip = cc.Sprite:createWithSpriteFrame(Display:getFrame(v))
    --     self:addChild(chip)
    --     chip:setLocalZOrder(100)
    --     chip:setPosition(200, 200 + i * 100)
    -- end
    -- self._addP:test()
    -- local LHDPerson = LHDPerson.new()
    -- LHDPerson:show()
    -- logi("zxvczxcvqewrqer ")
    -- self._addP:test()
    -- self._rightPools[3]:showVictory()
    -- self.lhdHistory = LHDHistory.new({})
    -- self.lhdHistory:show()
    -- self.myself:winMoneyFly({chips = 30})
    -- self.myself:showResultAnimation()

    -- self.myself:showSelfResult(300000)    
end

return LHDGameView