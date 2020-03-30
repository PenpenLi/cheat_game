local BrGameView = class("BrGameView", qf.view)

local IButton = import(".components.IButton")
local DeviceStatus = import(".components.DeviceStatus")
local BrUser = import(".brcomponents.BrUser")
local BrChipsPool = import(".brcomponents.BrChipsPool")
local BrMyself = import(".brcomponents.BrMyself")
local BrDelar = import(".brcomponents.BrDelar")
local BrAddBtn = import(".brcomponents.BrAddBtn")
local BrMenu = import(".brcomponents.BrMenu")

local BrDelarList = import(".brcomponents.BrDelarList")
local BrHistory = import(".brcomponents.BrHistory")
local BrPerson = import(".brcomponents.BrPerson")
local BrHelp = import(".brcomponents.BrHelp")
local BrResult = import(".brcomponents.BrResult")

-- local Chat = import(".components.Chat")
local Chat = require("src.common.Chat")
local Gameanimation = import(".components.animation.Gameanimation")
local GameAnimationConfig = import(".components.animation.AnimationConfig")

BrGameView.TAG = "BrGameView"
BrGameView.poolZ = 5
BrGameView.MENU_ZORDER = 22
BrGameView.TOUCH_ZORDER = 19
BrGameView.TAG_BR_HISTORY = 20001
BrGameView.TAG_BR_HELP = 20002
BrGameView.TAG_BR_DELAR_LIST = 20003
BrGameView.TAG_BR_PERSON = 20004
BrGameView.LOADDINGZ = 10
BrGameView.TAG_CHIP_ACTION = 100

function BrGameView:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    Cache.DeskAssemble:setGameType(BRC_MATCHE_TYPE)  --游戏类型设置为百人场
    self:init()
    self.super.ctor(self, paras)
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_INGAME_POS)
end

function BrGameView:init()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(BrRes.brGameJson)
    self:addChild(self.gui)
    self:initAnimation()
    self:initUser()
    self:initPools()
    self:initDeviceStatus()
    self:initChat()
    self:initBtnTouch()
    self:forceAdjust()
    self:initTouchEvent()
    -- self:refreshHongBaoBtn()
    self:refreshNetStrength()
    if not Cache.packetInfo:isShangjiaBao() then
        self:refreshNoMoneyTip()
    end
    self:initChatUI()
end

function BrGameView:initChatUI()
	self.Chat = Chat.getChatBtn()
    self.Chat:setVisible(Util:isHasReviewed())
    self:addChild(self.Chat)
    -- self.Chat:setLocalZOrder(12)
    self._chat = Chat.new({view=self,chat_list=true,ChatCmd=BR_CMD.CMD_BR_USER_DESK_CHAT_V2})
    self:addChild(self._chat, 3)
    self.chat_txt_layer = self._chat:getChatTxtLayer()
    self:addChild(self.chat_txt_layer, 2)

    --聊天
	self.Chat:setPosition(cc.p(1633, 65))
	addButtonEvent(self.Chat,function ( )
		-- body
		-- if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击炸金花聊天") end
        -- print("123123")
        -- local myUin = Cache.user.uin
        -- local user = Cache.brdesk.br_user[myUin]
        -- --无座 且自己不是庄家
        -- if (user and user.seatid == -1) and self.delar and self.delar.uin ~= myUin then
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

function BrGameView:release()
    
    if BrChipManager then
        BrChipManager:release()
    end
    self:hideMenu()
    if self._chat ~= nil and self._chat:isVisible() then
        -- self._chat:close()
    end
end

function BrGameView:initAnimation()
    
    self.animationLayout = self.gui:getChildByName("aniLayer")
    self.animationLayout:setZOrder(10)
    self.Gameanimation  =  Gameanimation.new({view=self,node=self.animationLayout})  --初始化动画
end

function BrGameView:initUser()
    self.chipsUser = {}--下注用户
    self._rightUsers = {}
    self.myself = BrMyself.new({node = self.gui:getChildByName("myself_panel")})
    self.delar = BrDelar.new({node = self.gui:getChildByName("delar_panel")})
    for i = 1 , 6 do
        self._rightUsers[i] = BrUser.new({node = self.gui:getChildByName("user_panel_"..i),index = i})
        self.chipsUser["seat_user"..i] = self._rightUsers[i]
    end
    self.chipsUser.myself = self.myself
    self.chipsUser.delar = self.delar
    self.chipsUser.other = self.gui:getChildByName("bnt_person")
end

function BrGameView:getBetUserByUin(uin)
    --无座玩家
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

---初始化黑红梅方
function BrGameView:initPools()
    
    self._rightPools = {}
    local parent = ccui.Helper:seekWidgetByName(self.gui,"pan_container")
    for i = 1 ,4 do
        local _panel = ccui.Helper:seekWidgetByName(self.gui,"chips_panel_"..i)
        self._rightPools[i] = BrChipsPool.new({node = _panel, index = i,parent = parent})
    end
    self.startBetImg = ccui.Helper:seekWidgetByName(self.gui,"begin_bet")
end

---初始化几个按钮
function BrGameView:initBtnTouch()
    
    self:initGameShop()
    self._panContainer = ccui.Helper:seekWidgetByName(self.gui, "pan_container")
    self._addP = BrAddBtn.new({node = self.gui:getChildByName("add_chips_panel")})
    
    --初始化对应的menuItem
    -- self.gui:getChildByName("menu_img"):setVisible(false)
    -- self.gui:getChildByName("bnt_menu"):loadTextures(GameRes.menuImg, GameRes.menuImg, "")
    self:bindMenuBox()
    

    -- self.bnt_chat = IButton.new({node = self.gui:getChildByName("bnt_chat")})
    -- self.bnt_chat:setVisible(false) --qf3屏蔽
    -- self.gui:getChildByName("chat_img"):setVisible(false) --qf3屏蔽
    self.bnt_person = IButton.new({node = self.gui:getChildByName("bnt_person")})
    self.bnt_person:setTouchEnabled(true)
    self.bnt_history = IButton.new({node = self.gui:getChildByName("bnt_history")})

    -- self.bnt_chat:setCallback(function() 
    --     qf.event:dispatchEvent(ET.GAME_SHOW_CHAT)
    -- end)
    self.bnt_person:setCallback(function() 
        self:showBrPerson()
    end)
    self.bnt_history:setCallback(function() 
        self:showBrHistory()
    end)

    self.btn_rule = ccui.Helper:seekWidgetByName(self.gui, "rule_btn")
    addButtonEvent(self.btn_rule, function ()
        qf.event:dispatchEvent(ET.GAMERULE, {GameType = Cache.DeskAssemble:getGameType()})
    end)
    self.btn_rule:setVisible(false)
end

function BrGameView:bindMenuBox()    
    local panelBox = self.gui:getChildByName("Panel_box")
    panelBox:setVisible(false)
    addButtonEvent(self.gui:getChildByName("bnt_menu"), function ()
        panelBox:setVisible(true)
    end)

    addButtonEvent(self.gui, function ()
        panelBox:setVisible(false)
    end)

    addButtonEvent(panelBox:getChildByName("btn_Back"), function ()
        qf.event:dispatchEvent(BR_ET.GAME_BR_EXIT_EVENT)
    end)

    
    Util:enlargeBtnClickArea(panelBox:getChildByName("btn_Back"), {x = 1.4, y = 2})

    addButtonEvent(panelBox:getChildByName("btn_Set"), function ()
        qf.event:dispatchEvent(ET.SETTING)
    end)
    addButtonEvent(panelBox:getChildByName("btn_Bank"), function ()
        qf.event:dispatchEvent(ET.SAFE_BOX)
    end)
    addButtonEvent(panelBox:getChildByName("btn_Up"), function ()
        local myUin = Cache.user.uin
        if self.delar.uin == myUin then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = BrTXT.br_delar_stand_error_tips})
            return
        end
        local bSit = self:checkSomeoneSitDown(myUin)
        if bSit then
            if Cache.brdesk.bCanLeave then
                qf.event:dispatchEvent(BR_ET.BR_SEATUP_REQ, {uin = myUin})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = BrTXT.br_ingame})
            end
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = BrTXT.br_stand_tips})
        end
    end)

    addButtonEvent(panelBox:getChildByName("btn_Help"), function ()
        qf.event:dispatchEvent(ET.GAMERULE, {GameType = Cache.DeskAssemble:getGameType()})   
    end)

    addButtonEvent(panelBox:getChildByName("Panel_Out"), function ()
        panelBox:setVisible(false)
    end)
end

---开牌
function BrGameView:giveCards()
    Cache.brdesk.bCanLeave = false
    self.gui:getChildByName("time_layer"):setVisible(false)
    local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
    local delay = 1
    local reverseTime = 0
    self.delar:reverseCards(delay+reverseTime)
    for i = 1 ,4 do
        self._rightPools[i]:reverseCards((i+1)*delay+reverseTime)
    end
    self:delayRun(6*delay+reverseTime + 1, function ()
        qf.event:dispatchEvent(BR_ET.BR_QUERY_RECENT_TREND_UPDATE_DESK)
    end)
end

-- 发牌
function BrGameView:pushCards()
    Cache.brdesk.bCanLeave = false
    self.gui:getChildByName("time_layer"):setVisible(false)
    local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
    local delay = 0
    self.delar:giveCards(delay,0.05,dpoint)
    for i = 1 ,4 do
        self._rightPools[i]:giveCards((i+1)*delay,0.05,dpoint)
    end
    
    self:ready(true)
    self.gui:getChildByName("time_layer"):setVisible(false)

    self:delayRun(1.5, function ( ... )
        self:betTime()
    end)

    self:delayRun(2, function ()
        self:stopDelayRun(1005)
        self.gui:getChildByName("time_layer"):setVisible(true)
        self:timeCountDown({time = Cache.brdesk.bet_time,status = 2})
    end)
end

--[[]]
function BrGameView:delayRun(time,cb,tag)
    
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function () if cb then cb() end end))
    if tag then action:setTag(tag) end
    self:runAction(action)
end

function BrGameView:stopDelayRun(tag)
    
    if self:getActionByTag(tag) then self:stopActionByTag(tag) end
end

function BrGameView:ready(bCloudCard)
    Cache.brdesk.bCanLeave = true
    self.gui:getChildByName("time_layer"):setVisible(true)
    self.delar:ready(bCloudCard)
    for k ,v in pairs(self._rightPools) do
         v:ready(bCloudCard)
    end
    Cache.brdesk.br_all_chips = {} --百人场下注的总数
    Cache.brdesk.br_my_chips = {}--自己下的注
    self._addP:smartChoice()
    self:removeRightPoolWinAni()
end

function BrGameView:chipsFallBack(index,value)
    
    local pool = self._rightPools[index]
    pool:chipsFallBack(value)
end

---下注动画
--self.view.brGameView:chipsToPool({user = user,value = m.op_user.bet_chips,index = m.op_user.br.section})
function BrGameView:chipsToPool(paras)
    
    if paras == nil then return end
    local pool = self._rightPools[paras.index]
    local u = self.chipsUser[paras.user]
    if pool == nil or u == nil then return end
    local from 
    if "other" == paras.user then 
        from = cc.p(u:getPositionX(),u:getPositionY())
        if "other" == paras.user and not paras.nobet then
            self:jumpActionForBet(u,1)
        end
    else
        if u.uin == Cache.user.uin then 
            if not paras.nobet then
                -- 下注，不是结算的时候
                self.myself:bet()
                u:bet()
                self:jumpActionForBet(u)
            end
            -- self._addP:smartChoice()
            
        end
        from = u:getChipsPosition()
        -- self._addP:updateBtnsStatus(Cache.brdesk.br_user[Cache.user.uin].chips)
        if u.uin ~= Cache.user.uin then 
            u:bet()
            if paras.user ~= "delar" and not paras.nobet then
                self:jumpActionForBet(u)
            end
        end

    end
    if paras.no_action ~= true then
        pool:chipsToPool({from = from,value = paras.value,myself = paras.ismyself,noanimation = paras.noanimation,notadd = paras.notadd})
    end
end

---筹码下注时的弹跳动画
function BrGameView:jumpActionForBet(u,atype)
    
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

---筹码飞向玩家动画
function BrGameView:chipsToUser(paras)
    
    if paras == nil then return end
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
                --此处修改自己的筹码值
                self.myself:bet()
                u:bet()
            end
        end
        to = u:getChipsPosition()
        -- self._addP:updateBtnsStatus(Cache.brdesk.br_user[Cache.user.uin].chips)
        -- self._addP:smartChoice()
        if u.uin ~= Cache.user.uin then 
            u:bet()
        end
    end
    pool:chipsToUser({to = to,value = paras.value,all = paras.all, cb=cb})
end
-- 筹码飞动
function BrGameView:chipFly( paras )
    
    local chips = BrChipManager:createT(paras.value)
    for k, chip in pairs(chips) do
        self._panContainer:addChild(chip, 2)
        chip:setPosition(cc.p(paras.from.x, paras.from.y))
        local delay = (k - 1 )*0.02
        delay = delay >= 0.25 and 0.25 or delay
        BrChipManager:fly(delay, chip, paras.from, paras.to)
    end
end

---倒计时
function BrGameView:timeCountDown(paras)
    local timeLayer = self.gui:getChildByName("time_layer")
    local timeCount = timeLayer:getChildByName("time_txt")
    local markTxt = timeLayer:getChildByName("mark_txt")
    timeCount:stopAllActions()
    if paras == nil then timeCount:setString(" ") timeLayer:setVisible(false) self:restTime() return end
    local getStatuxTxt = function (status, time)
        local txt = BrTXT.br_state[status]
        if status == 1 then
            if time > 6 and paras.init then
                return txt[2]
            else
                return txt[1]
            end
        else
            return txt
        end
    end

    local refreshPosition = function (time_layer)
        local mark_txt = time_layer:getChildByName("mark_txt")
        local time_txt = time_layer:getChildByName("time_txt")
        local sec_txt = time_layer:getChildByName("sec_txt")

        local _width = mark_txt:getContentSize().width
        local _posX = mark_txt:getPositionX()
        local time_difX = 10
        local sec_difX = 5
        local timeX = _posX + _width + time_difX
        local timeWidth = time_txt:getContentSize().width
        local secX = timeX + timeWidth + sec_difX
        time_txt:setPositionX(timeX)
        sec_txt:setPositionX(secX)
    end
    local time = paras.time 
    local statusTxt = getStatuxTxt(paras.status, time)
    if statusTxt == nil or time == nil then  timeCount:setString(" ") timeLayer:setVisible(false) return end
    time = time < 0 and 0 or time
    time = paras.status == 2 and time -3 or time
    time = paras.status == 1 and time -1 or time
    statusTxt = getStatuxTxt(paras.status, time)
    markTxt:setString(statusTxt)
    timeCount:setString(time < 0 and "0" or time)
    refreshPosition(timeLayer)
    timeCount:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                if time <= 0 then 
                    timeCount:stopAllActions()
                    if paras.status == 2 then
                        self:restTime()
                    end
                    return
                end
                time = time - 1
                if time < 0 then
                    timeLayer:setVisible(false)
                end
                -- local statusTxt = getStatuxTxt(paras.status, time)
                -- markTxt:setString(statusTxt)
                timeCount:setString(time)
                refreshPosition(timeLayer)
            end)
        )
    ))
    if paras.status == 1 then
        self:restTime()
    elseif paras.status == 2 then
        self:betTime()
    end
end

---休息时间
function BrGameView:restTime()
    if self.betTimeAniEndStart then
        return
    end
    
    self.beginBetTime = false
    for k, v in pairs(self._rightPools) do
        v.clickMask:setVisible(false)
        v.isBetTime = false
    end
    -- 结束下注动画
    self:betTimeAnimation(false)
    MusicPlayer:playMyEffectGames(BrRes,"STOP_BET")
end

---下注时间
function BrGameView:betTime()
    if self.betTimeAniStart then
        return
    end
    self.beginBetTime = true
    if self.delar.uin == Cache.user.uin then return end
    performWithDelay(self, function ( ... )
        if self.beginBetTime then
            for k, v in pairs(self._rightPools) do
                v.isBetTime = true
                v:betTime()
            end
        end
    end, 2)
    -- 开始下注动画
    self:betTimeAnimation(true)
    MusicPlayer:playMyEffectGames(BrRes,"START_BET")
end

-- 开始下注动画
function BrGameView:betTimeAnimation(isBet)
    if isBet then
        self.betTimeAniStart = true
    else
        self.betTimeAniEndStart = true
    end

    self:playBetEfx(isBet)
    performWithDelay(self, function ( ... )
        if isBet then
            self.betTimeAniStart = false
        else
            self.betTimeAniEndStart = false
        end
    end, 2)
end

function BrGameView:showBrHistory()
    local brHistory = BrHistory.new()
    brHistory:show()
end

-- 更新牌内趋势
function BrGameView:updateBrHistoryInDesk()
    for k, v in pairs(self._rightPools) do
        v:updateTrend()
    end
    qf.event:dispatchEvent(BR_ET.BR_QUERY_RECENT_TREND_CLICK)
end

-- 弹出走势pop
function BrGameView:updateBrHistory()
    
    local brHistory = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.brHistory)
    if brHistory ~= nil then
        brHistory:update()
    end
end

function BrGameView:clearSeat(uin)
    
    if uin == nil then return end
    for _,user in pairs(self.chipsUser) do
        if user.uin == uin and user.isSeat then
            user:leave()
            return
        end
    end
end

function BrGameView:showBrHelp()
    
    local brHelper = BrHelp.new()
    brHelper:show()
end

function BrGameView:showDelarList(isExit)

    local brDelarList = BrDelarList.new(isExit)
    brDelarList:show()
end

function BrGameView:updateDelarListInDesk()
    self:updateDelarList()
    self.delar:updateWaitDelar()
end

function BrGameView:updateDelarList()
    
    local brDelarList = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.brDelarList)
    if brDelarList then
        brDelarList:update()
    end
end

function BrGameView:showBrPerson()
    qf.event:dispatchEvent(BR_ET.BR_QUERY_PLAYER_LIST_CLICK)
    local brPerson = BrPerson.new()
    brPerson:show()
end

function BrGameView:updateBrPerson()
    local brPerson = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.brPerson)
    if brPerson then
        brPerson:update()
    end
end

---进桌初始化
function BrGameView:updateByInput()
    self._addP:initBtns()
    self:ready()
    BrChipManager:updatePoolCacheChips()

    self:timeCountDown({time = Cache.brdesk.br_info.time_remain,status = Cache.brdesk.br_info.stage, init = true})
    
    if Cache.brdesk.br_info.stage == 2 then
        -- 发牌
        local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
        self.delar:showCards(delay,0.05,dpoint)
        for i = 1 ,4 do
            self._rightPools[i]:showCards(0,0.05,dpoint)
            self._rightPools[i].isBetTime = true
            self._rightPools[i]:betTime()
        end
    end
    
    self._addP:updateBtnsStatus(Cache.brdesk.br_user[Cache.user.uin].chips) 
    self._addP:smartChoice()
            
    self.myself:updateInfo()
    for uin, v in pairs(Cache.brdesk.br_user) do
        if v.seatid ~= nil and v.seatid > 0 then
            self:someoneSitdown(uin)
        end
    end
    
    self:delarSitdown()
    for index,section in pairs(Cache.brdesk.br_chips_count) do
        for k,count in pairs(section) do
            for i = 1,count.count do
                self:chipsToPool({user = "other",value = Cache.packetInfo:getProMoney(count.chips), index = index,noanimation = true})
            end
        end
    end
    
    for k, v in pairs(Cache.brdesk.br_my_bets) do
        self._rightPools[k]:setMyselfChips(Cache.packetInfo:getProMoney(v))
    end

    qf.event:dispatchEvent(BR_ET.GET_DELAR_INFO_IN_DESK)
    self.delar:updateDelarRuler()
    self:showBaoDelarAnimation()
    qf.event:dispatchEvent(BR_ET.BR_QUERY_RECENT_TREND_UPDATE_DESK)
    qf.event:dispatchEvent(BR_ET.GET_DELAR_INFO)
    
end

function BrGameView:delayRun(time,cb)
    
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end
function BrGameView:showJiFen(score)
    
    -- if score == nil then return end
    -- self.myself:showJiFen(score)
end

function BrGameView:refreshAddBtn()
    self._addP:smartChoice()
end

---结算
function BrGameView:updateByOver()
    self:timeCountDown({time = Cache.brdesk.br_info.time_remain,status = 1})
    self:delayRun(5,function ()
        qf.event:dispatchEvent(BR_ET.BR_UNFIRE)
    end)
    local dt = 2
    self:delayRun(4 + dt,function() self:gameOverAnimation() end) -- 结算动画   7s
    
    --结算之后显示通杀或者通赔
    self:delayRun(5.5 + dt,function () self:gameShowSpecialResultAnimation() end) --通杀或者通赔动画
    self:delayRun(9 + dt,function()
        self:showBaoDelarAnimation()
    end)
    --展示每个玩家输赢
    self:delayRun(10 + dt, function ()
        self:updateUsersResult()
    end)
    --游戏准备开始
    self:delayRun(11 + dt,function()
        self:ready() end,
    1005)
end

--头像上飘金币
function BrGameView:updateUsersResult(bShow)
    local bJoinThisTurn = false --当前自己是否参加了这局游戏
    for k,v in pairs(Cache.brdesk.br_sit_users) do
        local winChips = Cache.brdesk.br_totle_result[k]
        --不输不赢、庄家
        if winChips and winChips ~= 0 and checkint(k) > 1010 and k ~= -1 then
            local user = self._rightUsers[v.seatid]
            if user then
                user:winMoneyFly({chips = Cache.packetInfo:getProMoney(winChips), uin = k})
            end
            if k == Cache.user.uin then
                self.myself:winMoneyFly({chips = Cache.packetInfo:getProMoney(winChips)})
                bJoinThisTurn = true
            end
        end
    end
    --播放delar
    local dealer_win_chips = Cache.brdesk.br_totle_result[Cache.brdesk.br_delar.uin]
    if dealer_win_chips ~= 0 then
        self.delar:winMoneyFly({chips =Cache.packetInfo:getProMoney(dealer_win_chips)})
    end

    if bJoinThisTurn then
        qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP, {showTxt = GameTxt.showInsufficientTxt})
    end
end

---结算界面
function BrGameView:showBrResult(cb)
    
    if Cache.brdesk.self_result == nil then return end--or next(Cache.brdesk.self_result) == nil then return end
    self._panContainer:addChild(BrResult.new({callBack = cb}), 21)
    if next(Cache.brdesk.self_result) == nil then
        self:updateMyResult(false)
    else
        self:updateMyResult(true)
    end
end

-- 结算通杀、通赔
function BrGameView:gameShowSpecialResultAnimation()
    
    -- if Cache.brdesk.self_result == nil or next(Cache.brdesk.self_result) == nil then return end
    local tp, ts = Cache.brdesk:getGameResultForSpecial()
    local animationConfig = nil
    if tp == 1 then
        animationConfig = GameAnimationConfig.TP
    end
    if ts == 1 then
        animationConfig = GameAnimationConfig.TS
    end
    if animationConfig == nil then return end
    local config = {
        anim = animationConfig,
        scale = 2,
        position = {x = self.animationLayout:getContentSize().width/2, y = self.animationLayout:getContentSize().height/2},
        index = animationConfig.index
    }
    self.Gameanimation:play(config)
end

function BrGameView:initFireAnimation()
    
    if self.firAnimationLayout == nil then
        self.firAnimationLayout  =  cc.Layer:create()
        self:addChild(self.firAnimationLayout)
        self.firAnimationLayout:setZOrder(101)
        self.fireGameanimation     =  Gameanimation.new({view=self,node=self.firAnimationLayout})  --初始化动画
    end
end

--爆庄动画
function BrGameView:showBaoDelarAnimation()
    self:initFireAnimation()
    if  Cache.brdesk.is_blow_up ~= 1 then
        return
    end
    local fire = self.firAnimationLayout:getChildByName("all_fire")
    if fire ~= nil then
        return
    end
    self.fireGameanimation:play({anim = GameAnimationConfig.BAO,scale = 2, index = GameAnimationConfig.BAO.index})
    self:delayRun(0.2, function ()
        qf.event:dispatchEvent(BR_ET.BR_UNFIRE)
        self.fireGameanimation:play({anim = GameAnimationConfig.ALLFIRE,scale = 2,name = "all_fire",forever = 1})
    end)
end

---结算动画 7s
function BrGameView:gameOverAnimation()
    print("gameOverAnimation !!!!")
    local function getOtherChips(info,k,i,uin)
        local value
        if uin == - 1 then
            value = Cache.brdesk.other_result[k].chips
        else
            value = info.chips
        end
        return value
    end
    for k,v in ipairs(Cache.brdesk.br_result) do
        local count = 0
        local last = v[#v]
        for i ,info in ipairs(v) do
            local uin = info.uin
            local user = self:getBetUserByUin(uin)
            if user == "delar" then
                if info.odds > 0 then
                    -- print("info.odds >>>>>>>>>>>>> ------------")
                    self:delayRun(4,function() 
                        -- 庄家吐注
                        -- print("info.odds >>>>>>>>>>>>> ------------ZXCVZXCVZXCVZXCV")
                        self:chipsToPool({user = "delar",value = math.abs(Cache.packetInfo:getProMoney(info.chips)),index = k})
                        self:removeRightPoolWinAni()
                    end)
                else
                    -- print("info.odds <<<<<<<<<<<<<< +++++++++++++")
                    self:delayRun(2,function() 
                        -- print("info.odds >>>>>>>>>>>>> +++++++++++++ ZXCVZXCVZXCVZXCV")
                        -- 庄家收注  因为扣了手续费，但是庄家是全部收，所以value没啥用
                        self:chipsToUser({user = "delar",value = Cache.packetInfo:getProMoney(count),index = k,all = true})
                        self:removeRightPoolWinAni()
                    end)
                end
            else
                if info.odds < 0 then--庄家赢
                    local value = getOtherChips(info,k,i,uin)
                    self:chipsToPool({user = user,value = math.abs(Cache.packetInfo:getProMoney(value)),index = k, nobet=true})
                elseif info.odds > 0 then--玩家赢
                    local value = getOtherChips(info,k,i,uin)
                    local all = last.uin == uin
                    --如果最后一个人value是空的，那么倒数第一个就可以全部收走
                    if i == #v -1 then
                        if getOtherChips(v[#v],k,i+1,v[#v].uin) == 0 then
                            all = true
                        end
                    end
                    --玩家收注 因为扣了手续费，但是扣了手续费，所以要加回来，不然匹配不到
                    self:delayRun(5+0.01*i,function()
                        self:chipsToUser({user = user,value = math.abs(Cache.packetInfo:getProMoney(value)),index = k,all = all})
                    end)
                end
            end
        end
        self._rightPools[k]:showResult(Cache.user.uin == self.delar.uin)
    end

    if Cache.brdesk.br_delar.uin ~= Cache.user.uin then
        self.chipsUser["myself"]:refreshGold(Cache.brdesk.br_user[Cache.user.uin].chips)
    end
end

--上庄
function BrGameView:delarSitdown()

    local someone = Cache.brdesk.br_delar
    if someone.uin == nil then return end
    if someone.uin == Cache.user.uin then 
        self.chipsUser.myself = self.delar
        self._addP:setVisible(false)

        self:restTime()
    else

        self._addP:setVisible(true)

        self._addP:updateBtnsStatus(Cache.brdesk.br_user[Cache.user.uin].chips)

        self._addP:smartChoice()
    end

    self.delar:seatDown()
    if checkint(someone.uin) >= 1000 and checkint(someone.uin) <= 1010 then
        return
    end
    local animationConfig = GameAnimationConfig.DELAR
    local config = {
        anim = animationConfig,
        scale = 2,
        position = {x = self.animationLayout:getContentSize().width/2, y = self.animationLayout:getContentSize().height/2},
        index = animationConfig.index
    }
    self.Gameanimation:play(config)
end

--下庄
function BrGameView:delarlLeave()
    
    local someone = Cache.brdesk.br_delar
    if someone.uin == Cache.user.uin then 
        self.chipsUser.myself = self.myself
        self._addP:setVisible(true)
        self._addP:updateBtnsStatus(Cache.brdesk.br_user[Cache.user.uin].chips)
        self._addP:smartChoice()
    end
    self.delar:leave()
end

function BrGameView:someoneStand(uin)
    
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then 
            return v:leave()
        end
    end
end

function BrGameView:someoneSitdown(uin)
    
    self:clearSeat(uin)
    local someone = Cache.brdesk.br_user[uin]
    local right = self._rightUsers[someone.seatid]
    if right == nil then return end
    if someone.uin == Cache.user.uin then
        self.chipsUser.myself = right
    end
    right:seatDown(someone)
end

function BrGameView:checkSomeoneSitDown(uin)
    
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then 
            return true
        end
    end
    return false
end


function BrGameView:someoneLeaveSeat(uin)
    
    if uin == nil then return end
    self:someoneStand(uin)
    if uin == Cache.user.uin then
        self.chipsUser.myself = self.myself
    end
end

function BrGameView:forceAdjust () 
    
    if FORCE_ADJUST_GAME == false then return end

    local function _update(node,scale,offsetx) 
        node:setScale(scale)
        node:runAction(cc.MoveBy:create(0,cc.p(offsetx,0)))
    end
    
    local function _getS(v) return v - v*(GAME_RADIO - GAME_DEAFULT_RADIO) end
    local function _getX(v) return v + v*(GAME_RADIO - GAME_DEAFULT_RADIO)*10 end
    
    local ds1 = _getS(0.85)
    local dofx = _getX(120)
    --_update(ccui.Helper:seekWidgetByName(self.gui,"chips_panel"),ds1,0)
end


function BrGameView:someChipsChange(model)
    if model == nil then return end
    local u = self:getBetUserByUin(model.uin)
    if u == nil then return end
    local user = self.chipsUser[u]

    if user.uin == Cache.user.uin then
        self.myself:_setGold(model.chips)
        -- self._addP:smartChoice()
    end

    if u == "myself" then
    elseif u == "delar" then
        user:setGold(model.chips)    
    else
        user:setGoldTxt(model.chips)
    end

    --fix 没有更新庄家位置与坐下玩家的金币
    for k, v in pairs(self._rightUsers) do
        if v.uin == model.uin then
            v:setGoldTxt(model.chips)
        end
    end

    if model.uin == self.delar.uin then
        self.delar:setGold(model.chips)
    end

end

function BrGameView:initTouchEvent()
    
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

        if self._menu then
            listener1:setSwallowTouches(true)
        end
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)

    listener1:registerScriptHandler(function (touch,event)
        local diffx = touch:getLocation().x - self._touchData.pos.x
        local diffy = touch:getLocation().y - self._touchData.pos.y
        local difft = os.time() - self._touchData.time
        local mindis = 120
        local maxtime = 2
        if diffy <-mindis and difft < maxtime then
            --之前这里是小喇叭的逻辑，删除
        end

        if self._menu then
            listener1:setSwallowTouches(false)
            if not (cc.rectContainsPoint(self._menu:getBoundingBox(), self._touchData.pos)) then
                self:hideMenu()
            end
        end
    end,cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer)
end

function BrGameView:setHeadIcon(paras)
    
    local uin = paras.uin
    if uin == Cache.user.uin then
        self.myself:udpateHeadIcon(paras.type)
    end
    if uin == self.delar.uin then
        self.delar:udpateHeadIcon(paras.type)
    end
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then
            v:udpateHeadIcon(paras.type)
            break
        end
    end
end
function BrGameView:getContainer( ... )
    
    return self._panContainer
end

function BrGameView:initGameShop()
    self.shopBtn = self.gui:getChildByName("shop_car")
    addButtonEvent(self.shopBtn, function ()
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击百人场商城") end
        local data = {ref = UserActionPos.ROOM_SHOP_CAR
                , type=PAY_CONST.BOOKMARK_ROOM.DIAMOND
                , supply = 1,niuniu=1
                , gold = 10000,
                supply=false
            }
        Scheduler:delayCall(0.08,function ( ... )
            -- body
            qf.platform:umengStatistics({umeng_key = "BR_Shopping_Btn"})--点击上报
            qf.event:dispatchEvent(ET.SHOP)
        end)
    end)
end

function BrGameView:refreshHongBaoBtn()
    self.shopBtn:setVisible(Cache.user.first_recharge_flag == 0)
    if Cache.user.first_recharge_flag == 1 then
        local pos = self.shopBtn:getPosition3D()
        Util:addHongBaoBtn(self, pos)
    elseif Cache.user.first_recharge_flag == 0 then
        Util:removeHongBaoBtn(self)
    end
end

function BrGameView:refreshNetStrength(paras)
    local diffX = 0
    Util:addNetStrengthFlag(self.gui, cc.p(170 - diffX,1045), paras)
end

--得到当前需要下注至少的money
function BrGameView:getNeedMoney()
    local leastMoney = GameConstants.LEAST_MONEY
    local user = Cache.brdesk.br_user[Cache.user.uin]
    if user then
        local chip = Cache.packetInfo:getProMoney(user.chips)
        return leastMoney - chip
    end
end

function BrGameView:refreshNoMoneyTip(paras)
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

function BrGameView:initMenu()
    
    --左上角菜单按钮
    addButtonEvent(self.bnt_menu, function ( sender )
        --qf.event:dispatchEvent(BR_ET.GAME_BR_SHOW_MENU)
        loga("左上角菜单按钮")
        qf.event:dispatchEvent(BR_ET.GAME_BR_EXIT_EVENT)
    end)
    --创建menu
    self._menu = BrMenu.new({cb = function() self:hideMenu() end})    --动态创建menu
    self._menu:setAnchorPoint(0, 0)
    self._menu:setPosition(30, self.winSize.height)
    self._menu:setVisible(false)
    self._panContainer:addChild(self._menu, self.MENU_ZORDER)
end
function BrGameView:showMenu()
    
    if not self._menu then
        self:initMenu()
    end
    self._menu:show()
    self.bnt_menu:setTouchEnabled(false)
end

function BrGameView:hideMenu()
    
    if self._menu then
        self._menu:removeFromParent()
        self._menu = nil
        self.bnt_menu:setTouchEnabled(true)
    end
end
function BrGameView:exitBrCall()
    
    if self.delar.uin == Cache.user.uin then 
        return qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.br_delar_exit_tips})
    end
    if Cache.brdesk.br_my_chips then
        local myAddChips = 0
        for k , v in pairs(Cache.brdesk.br_my_chips) do
            myAddChips = myAddChips + v
        end
        if myAddChips > 0 then
            return qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = BrTXT.br_delar_exit_tips})
        end
    end
    
    qf.event:dispatchEvent(BR_ET.BR_EXIT_REQ, {send=true})
end

--开始检测设备状态(电池电量, 网络信号)
function BrGameView:initDeviceStatus()
    
    --百人场暂时不显示电量和信号
        -- self._device_layer = ccui.Helper:seekWidgetByName(self.gui,"device_layer")
        -- if self._device_layer ~= nil then self._device_layer:setVisible(false) end
        -- self._device_layer = ccui.Helper:seekWidgetByName(self,"device_layer")
        -- local deviceStatus = DeviceStatus.new({layer = self._device_layer})
        -- deviceStatus:startDeviceStatusMonitor()	--开始检测设备状态(电池电量, 网络信号)
end

--[[聊天相关 start]]
function BrGameView:initChat()
    
    Cache.chat = {}
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.gameChatPlist, GameRes.gameChat)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.gameChatNoblePlist, GameRes.gameChatNoble)
end
-- function BrGameView:showChat()
    
--     if self._chat == nil then
--         self._chat = Chat.new()
--         self._chat:setVisible(false)
--         self:addChild(self._chat,self.LOADDINGZ)
--     end
--     if self._chat ~= nil then
--         self._chat:show()
--     end
-- end
function BrGameView:hideChat() 
    if self._chat ~= nil then
        self._chat:hide()
    end
end

function BrGameView:chat(model)
    local userName = self:getBetUserByUin(model.op_uin)
    local user = self.chipsUser[userName]
    self._chat:chatProtocol(model, user, self)
    if userName == "myself" then
        self._chat:chatProtocol(model, self.myself, self)
    end
    if userName == "delar" and self.delar.uin == Cache.user.uin then
        self._chat:chatProtocol(model, self.myself, self)
    end
    
    local nick = model.nick
    self._chat:receiveNewMsg({model = model, name = nick, uin = model.op_uin})
end

--语音识别
function BrGameView:speechToTextStatusChanged(paras)
    
    if self._chat ~= nil and self._chat:isVisible() then
        self._chat:processSpeechToTextStatusChanged(paras)
    end
end
function BrGameView:speechToTextVolumeChanged(paras)
    if self._chat ~= nil and self._chat:isVisible() then
        self._chat:processSpeechToTextVolumeChanged(paras)
    end
end
--[[聊天相关 end]]

function BrGameView:getRoot()
    return LayerManager.GameLayer
end

function BrGameView:playWinmoney(paras)
    self.Gameanimation:playWinmoney(paras)
end

function BrGameView:removeRightPoolWinAni()
    for i = 1, 4 do
        self._rightPools[i]:removeWinAni()
    end
end

function BrGameView:exit()
    Util:loadAnim(GameAnimationConfig, false, self.Gameanimation)
end

function BrGameView:enter()
    Util:loadAnim(GameAnimationConfig, true, self.Gameanimation)
end

function BrGameView:test() 
    performWithDelay(self, function ( ... )
        Cache.user.first_recharge_flag = 0
        qf.event:dispatchEvent(ET.REFRESH_HONGBAO_BTN)
    end, 1)
    -- self._addP:test() 
    -- self._rightPools[1]:showVictory()
    -- self._addP:test()
    -- performWithDelay(self, function ( ... )
    --     self:removeRightPoolWinAni()
    -- end,4)
    for i = 1, 6 do
        self._rightUsers[i] = BrUser.new({node = self.gui:getChildByName("user_panel_"..i),index = i})
        self._rightUsers[i]:playShowChatMsg(self.chat_txt_layer, "123123")
        self._rightUsers[i]:emoji(1, self._chat.Emoji_index)
    end
    self.myself:playShowChatMsg(self.chat_txt_layer, "123123")
    self.myself:emoji(1, self._chat.Emoji_index)
    self.delar = BrDelar.new({node = self.gui:getChildByName("delar_panel")})
    self.delar:playShowChatMsg(self.chat_txt_layer, "123123")
    self.delar:emoji(1, self._chat.Emoji_index)
    -- self.delar:winMoneyFly({chips = 30000})
    -- self._rightUsers[1]:winMoneyFly({chips = 30000})
    -- self._rightUsers[6]:winMoneyFly({chips = 30000})

    -- self._rightUsers[1].name_str:setVisible(true)
    -- self._rightUsers[1].name_str:setString("qwreqwe")

    -- self.name_str
    -- local nameT = {"name_str","chip_str","seat_down","btn_gift", "img_beauty", "user_bg", "user_head"}
    -- for k, v in pairs(nameT) do
        -- self[v] = self:getChildByName(v)
        -- self[v]:setVisible(true)
    -- end
end

function BrGameView:playBetEfx(isBet)
    local config = require("src.common.HallAnimationConfig")
    if isBet  then
        animationConfig = config.BEGINBET
    else
        animationConfig = config.STOPBET
    end

    if animationConfig == nil then return end
    local config = {
        anim = animationConfig,
        scale = 1,
        position = {x = self.animationLayout:getContentSize().width/2, y = self.animationLayout:getContentSize().height/2},
        index = animationConfig.index
    }
    Util:playAnimation(config, self.Gameanimation)
end

return BrGameView
