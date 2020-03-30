local GameView = class("GameView", qf.view)

local Chat          = require("src.common.Chat")
local IButton = import(".components.IButton")
local BrnnUser = import(".gamecomponents.BrnnUser")
local BrnnChipsPool = import(".gamecomponents.BrnnChipsPool")
local BrnnMyself = import(".gamecomponents.BrnnMyself")
local BrnnDelar = import(".gamecomponents.BrnnDelar")
local BrnnAddBtn = import(".gamecomponents.BrnnAddBtn")
local BrnnMenu = import(".gamecomponents.BrnnMenu")

local BrnnDelarList = import(".gamecomponents.BrnnDelarList")
local BrnnHistory = import(".gamecomponents.BrnnHistory")
local BrnnPerson = import(".gamecomponents.BrnnPerson")

local Gameanimation = import(".components.animation.Gameanimation")
local GameAnimationConfig = import(".components.animation.AnimationConfig")

GameView.TAG = "BrnnGameView"
GameView.poolZ = 5
GameView.MENU_ZORDER = 22
GameView.TOUCH_ZORDER = 19
GameView.TAG_BR_HISTORY = 20001
GameView.TAG_BR_HELP = 20002
GameView.TAG_BR_DELAR_LIST = 20003
GameView.TAG_BR_PERSON = 20004
GameView.LOADDINGZ = 10
GameView.TAG_CHIP_ACTION = 100

function GameView:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    Cache.DeskAssemble:setGameType(BRNN_MATCHE_TYPE)  --游戏类型设置为百人场
    self:init()
    self:setRoomType()
    self.super.ctor(self, paras)
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_INGAME_POS)
end

function GameView:init()

    if Cache.BrniuniuDesk:getRoomType() == 14 then
        self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(BrniuniuRes.brGame3Json)
    else
        self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(BrniuniuRes.brGameJson)
    end
    self:addChild(self.gui)
    self:initAnimation()
    self:initUser()
    self:initPools()
    self:initBtnTouch()
    self:forceAdjust()
    self:initTouchEvent()
    self:refreshNetStrength()
    self:refreshNoMoneyTip()
    self:initChatUI()
    --self:initReview()
end

function GameView:initReview( ... )
    if Util:isHasReviewed() then return end
    self.shopBtn:setVisible(false)
end

function GameView:release()
    
    if BrnnChipManager then
        BrnnChipManager:release()
    end
    self:hideMenu()
end

function GameView:initAnimation()
    
    self.animationLayout = self.gui:getChildByName("aniLayer")
    self.animationLayout:setZOrder(10)
    self.Gameanimation  =  Gameanimation.new({view=self,node=self.animationLayout})  --初始化动画
end

function GameView:setRoomType( ... )
    local roomType = self.gui:getChildByName("room_type")
    local roomTypeString = Cache.BrniuniuDesk:getRoomType() == 14 and BrniuniuTXT.brnn_hall_type_txt_3 or BrniuniuTXT.brnn_hall_type_txt_10
    roomType:setString(roomTypeString)
    roomType:setVisible(false)
    local bg = self.gui:getChildByName("bg")
    local roomFlag = Cache.BrniuniuDesk:getRoomType() == 14 and 3 or 2
    local bgName = string.format(BrniuniuRes.table_bg_img, 2)
    if Cache.BrniuniuDesk:getRoomType() == 14 then
        bgName = string.format(BrniuniuRes.table_bg_img, 1)
    end

    bg:loadTexture(bgName)
    for i = 1 , 4 do
        self.gui:getChildByName("chips_panel"):getChildByName("chips_bg_" .. i):loadTexture(string.format(BrniuniuRes.table_pool_bg_img, roomFlag, i))
    end
end

function GameView:initUser()
    self.chipsUser = {}--下注用户
    self._rightUsers = {}
    self.myself = BrnnMyself.new({node = self.gui:getChildByName("myself_panel")})
    self.delar = BrnnDelar.new({node = self.gui:getChildByName("delar_panel")})
    for i = 1 , 6 do
        self._rightUsers[i] = BrnnUser.new({node = self.gui:getChildByName("user_panel_"..i),index = i})
        self.chipsUser["seat_user"..i] = self._rightUsers[i]
    end
    self.chipsUser.myself = self.myself
    self.chipsUser.delar = self.delar
    self.chipsUser.other = self.gui:getChildByName("bnt_person")
end

function GameView:getBetUserByUin(uin)
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
function GameView:initPools()
    
    self._rightPools = {}
    local parent = ccui.Helper:seekWidgetByName(self.gui,"pan_container")
    for i = 1 ,4 do
        local _panel = ccui.Helper:seekWidgetByName(self.gui,"chips_panel_"..i)
        self._rightPools[i] = BrnnChipsPool.new({node = _panel, index = i,parent = parent})
    end
    self.startBetImg = ccui.Helper:seekWidgetByName(self.gui,"begin_bet")
end

---初始化几个按钮
function GameView:initBtnTouch()
    
    self:initGameShop()
    self._panContainer = ccui.Helper:seekWidgetByName(self.gui, "pan_container")
    self._addP = BrnnAddBtn.new({node = self.gui:getChildByName("add_chips_panel")})
    
    --初始化对应的menuItem
    self:bindMenuBox()
    
    self.bnt_person = IButton.new({node = self.gui:getChildByName("bnt_person")})
    self.bnt_person:setTouchEnabled(true)
    self.bnt_history = IButton.new({node = self.gui:getChildByName("bnt_history")})

    self.bnt_person:setCallback(function() 
        self:showBrnnPerson()
    end)
    self.bnt_history:setCallback(function() 
        self:showBrnnHistory()
    end)
    
    self.btn_rule = ccui.Helper:seekWidgetByName(self.gui, "rule_btn")
    addButtonEvent(self.btn_rule, function ()
        qf.event:dispatchEvent(ET.GAMERULE, {GameType = Cache.DeskAssemble:getGameType()})
    end)
    self.btn_rule:setVisible(false)
end

function GameView:bindMenuBox()
    
    local panelBox = self.gui:getChildByName("Panel_box")
    panelBox:setVisible(false)
    addButtonEvent(self.gui:getChildByName("bnt_menu"), function ()
        panelBox:setVisible(true)
    end)
    
    addButtonEvent(panelBox:getChildByName("btn_Back"), function ()
        qf.event:dispatchEvent(BRNN_ET.GAME_BRNN_EXIT_EVENT)
    end)

    addButtonEvent(panelBox:getChildByName("btn_Set"), function ()
        qf.event:dispatchEvent(ET.SETTING)
    end)
    addButtonEvent(panelBox:getChildByName("btn_Bank"), function ()
        qf.event:dispatchEvent(ET.SAFE_BOX, {inGame = true})
    end)
    addButtonEvent(panelBox:getChildByName("btn_Up"), function ()
        local myUin = Cache.user.uin
        if self.delar.uin == myUin then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = BrniuniuTXT.brnn_delar_stand_error_tips})
            return
        end
        local bSit = self:checkSomeoneSitDown(myUin)
        if bSit then
            if Cache.BrniuniuDesk.bCanLeave then
                qf.event:dispatchEvent(BRNN_ET.BR_SEATUP_REQ, {uin = myUin})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = BrniuniuTXT.brnn_ingame})
            end
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = BrniuniuTXT.brnn_stand_tips})
        end

    end)
    
    addButtonEvent(panelBox:getChildByName("btn_Help"), function ()
        qf.event:dispatchEvent(ET.GAMERULE, {GameType = Cache.DeskAssemble:getGameType()})   
    end)

    addButtonEvent(panelBox:getChildByName("Panel_Out"), function ()
        panelBox:setVisible(false)
    end)

    Util:enlargeBtnClickArea(panelBox:getChildByName("btn_Back"), {x = 1.4, y = 2.2})
    Util:enlargeBtnClickArea(panelBox:getChildByName("btn_Set"), {x = 1.4, y = 2.2})
    Util:enlargeBtnClickArea(panelBox:getChildByName("btn_Bank"), {x = 1.4, y = 2.2})
    Util:enlargeBtnClickArea(panelBox:getChildByName("btn_Up"), {x = 1.4, y = 2.2})
    Util:enlargeBtnClickArea(panelBox:getChildByName("btn_Help"), {x = 1.4, y = 2.2})
end

---开牌
function GameView:giveCards()
    Cache.BrniuniuDesk.bCanLeave = false
    self.gui:getChildByName("time_layer"):setVisible(false)
    -- self:restTime()
    local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
    local delay = 1
    local reverseTime = 0
    self.delar:reverseCards(delay+reverseTime)
    for i = 1 ,4 do
        self._rightPools[i]:reverseCards((i+1)*delay+reverseTime)
    end
    self:delayRun(6*delay+reverseTime + 1, function ()
        qf.event:dispatchEvent(BRNN_ET.BR_QUERY_RECENT_TREND_UPDATE_DESK)
    end)
end

-- 发牌
function GameView:pushCards()
    Cache.BrniuniuDesk.bCanLeave = false
    self.gui:getChildByName("time_layer"):setVisible(false)
    local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
    local delay = 0
    self.delar:giveCards(delay,0.05,dpoint)
    for i = 1 ,4 do
        self._rightPools[i]:giveCards((i+1)*delay,0.05,dpoint)
    end

    self:ready(true)
    self.gui:getChildByName("time_layer"):setVisible(false)

    self:delayRun(1.1, function ( ... )
        self:betTime()
    end)

    self:delayRun(2, function ()
        self.gui:getChildByName("time_layer"):setVisible(true)
        self:timeCountDown({time = Cache.BrniuniuDesk.bet_time,status = 2})
    end)
end

--[[]]
function GameView:delayRun(time,cb,tag)
    
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function () if cb then cb() end end))
    if tag then action:setTag(tag) end
    self:runAction(action)
end

function GameView:stopDelayRun(tag)
    if self:getActionByTag(tag) then self:stopActionByTag(tag) end
end

function GameView:ready(bCloudCard)
    Cache.BrniuniuDesk.bCanLeave = true
    self.gui:getChildByName("time_layer"):setVisible(true)
    self.delar:ready(bCloudCard)
    for k ,v in pairs(self._rightPools) do
         v:ready(bCloudCard)
    end
    Cache.BrniuniuDesk.br_all_chips = {} --百人场下注的总数
    Cache.BrniuniuDesk.br_my_chips = {}--自己下的注
    self:removeRightPoolWinAni()
    self._addP:smartChoice()
end

function GameView:chipsFallBack(index,value)
    
    local pool = self._rightPools[index]
    pool:chipsFallBack(value)
end

---下注动画
--self.view.brGameView:chipsToPool({user = user,value = m.op_user.bet_chips,index = m.op_user.br.section})
function GameView:chipsToPool(paras)
    
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
        -- self._addP:updateBtnsStatus(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips)
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
function GameView:jumpActionForBet(u,atype)
    
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
function GameView:chipsToUser(paras)
    
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
                self.myself:bet()
                u:bet()
            end
        end
        to = u:getChipsPosition()
        -- self._addP:updateBtnsStatus(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips)
        -- self._addP:smartChoice()
        if u.uin ~= Cache.user.uin then 
            u:bet()
        end
    end
    pool:chipsToUser({to = to,value = paras.value,all = paras.all, cb=cb})
end
-- 筹码飞动
function GameView:chipFly( paras )
    
    local chips = BrnnChipManager:createT(paras.value)
    for k, chip in pairs(chips) do
        self._panContainer:addChild(chip, 2)
        chip:setPosition(cc.p(paras.from.x, paras.from.y))
        local delay = (k - 1 )*0.02
        delay = delay >= 0.25 and 0.25 or delay
        BrnnChipManager:fly(delay, chip, paras.from, paras.to)
    end
end
---倒计时
--self:timeCountDown({time = 10,status = 1})
function GameView:timeCountDown(paras)
    local timeLayer = self.gui:getChildByName("time_layer")
    local timeCount = timeLayer:getChildByName("time_txt")
    local markTxt = timeLayer:getChildByName("mark_txt")
    timeCount:stopAllActions()
    if paras == nil then timeCount:setString(" ") timeLayer:setVisible(false) self:restTime() return end
    local getStatuxTxt = function (status, time)
        local txt = BrniuniuTXT.br_state[status]
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
function GameView:restTime()
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
    MusicPlayer:playMyEffectGames(BrniuniuRes,"STOP_BET")
end

---下注时间
function GameView:betTime()
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
    MusicPlayer:playMyEffectGames(BrniuniuRes,"START_BET")
end

-- 开始下注动画
function GameView:betTimeAnimation(isBet)
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

function GameView:showBrnnHistory()
    local brHistory = BrnnHistory.new()
    brHistory:show()
end

-- 更新牌内趋势
function GameView:updateBrnnHistoryInDesk()
    for k, v in pairs(self._rightPools) do
        v:updateTrend()
    end
    qf.event:dispatchEvent(BRNN_ET.BR_QUERY_RECENT_TREND_CLICK)
end

-- 弹出走势pop
function GameView:updateBrnnHistory()
    
    local brHistory = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.brHistory)
    if brHistory ~= nil then
        brHistory:update()
    end
end

function GameView:clearSeat(uin)
    
    if uin == nil then return end
    for _,user in pairs(self.chipsUser) do
        if user.uin == uin and user.isSeat then
            user:leave()
            return
        end
    end
end

function GameView:showDelarList(isExit)
    
    local brDelarList = BrnnDelarList.new(isExit)
    brDelarList:show()
end

function GameView:updateDelarListInDesk()
    self:updateDelarList()
    self.delar:updateWaitDelar()
end

function GameView:updateDelarList()
    
    local brDelarList = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.brDelarList)
    if brDelarList then
        brDelarList:update()
    end
end

function GameView:showBrnnPerson()
    
    qf.event:dispatchEvent(BRNN_ET.BR_QUERY_PLAYER_LIST_CLICK)
    local brPerson = BrnnPerson.new()
    brPerson:show()
end
function GameView:updateBrnnPerson()
    
    local brPerson = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.brPerson)
    if brPerson then
        brPerson:update()
    end
end

---进桌初始化
function GameView:updateByInput()
    self._addP:initBtns()
    self:ready()
    self:setRoomType()
    BrnnChipManager:updatePoolCacheChips()
    self:timeCountDown({time = Cache.BrniuniuDesk.br_info.time_remain,status = Cache.BrniuniuDesk.br_info.stage, init=true})

    if Cache.BrniuniuDesk.br_info.stage == 2 then
        -- 发牌
        local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
        self.delar:showCards(delay,0.05,dpoint)
        for i = 1 ,4 do
            self._rightPools[i]:showCards(0,0.05,dpoint)
            self._rightPools[i].isBetTime = true
            self._rightPools[i]:betTime()
        end
    end
    
    self._addP:updateBtnsStatus(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips) 
    self._addP:smartChoice()
            
    self.myself:updateInfo()
    for uin, v in pairs(Cache.BrniuniuDesk.br_user) do
        if v.seatid ~= nil and v.seatid > 0 then
            self:someoneSitdown(uin)
        end
    end
    
    self:delarSitdown()
    for index,section in pairs(Cache.BrniuniuDesk.br_chips_count) do
        for k,count in pairs(section) do
            for i = 1,count.count do
                self:chipsToPool({user = "other",value = Cache.packetInfo:getProMoney(count.chips),index = index,noanimation = true})
            end
        end
    end
    
    for k, v in pairs(Cache.BrniuniuDesk.br_my_bets) do
        self._rightPools[k]:setMyselfChips(Cache.packetInfo:getProMoney(v))
    end
        
    self.delar:updateDelarRuler()
    qf.event:dispatchEvent(BRNN_ET.GET_DELAR_INFO_IN_DESK)

    self:showBaoDelarAnimation()
    qf.event:dispatchEvent(BRNN_ET.BR_QUERY_RECENT_TREND_UPDATE_DESK)
    qf.event:dispatchEvent(BRNN_ET.GET_DELAR_INFO)
    
end

function GameView:delayRun(time,cb)
    
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end
function GameView:showJiFen(score)
    
    -- if score == nil then return end
    -- self.myself:showJiFen(score)
end

function GameView:refreshAddBtn()
    self._addP:smartChoice()
end

---结算
function GameView:updateByOver()
    print("updateByOver BrnnGameView ")
    self:timeCountDown({time = Cache.BrniuniuDesk.br_info.time_remain,status = 1})
    self:delayRun(5,function ()
        qf.event:dispatchEvent(BRNN_ET.BR_UNFIRE)
    end)
    local dt = 2
    --游戏结束
    self:delayRun(4 + dt,function() self:gameOverAnimation() end) -- 结算动画   7s

    --结算之后显示通杀或者通赔
    self:delayRun(5.5 + dt,function () self:gameShowSpecialResultAnimation() end) --通杀或者通赔动画

    --检测爆庄特效
    self:delayRun(9 + dt,function()
        self:showBaoDelarAnimation()
    end)
    --展示玩家头像信息
    self:delayRun(10 + dt, function ()
        self:updateUsersResult()
    end)
    --游戏准备中
    self:delayRun(11 + dt,function()
        self:ready() 
    end, 1005)
end

--头像上飘金币
function GameView:updateUsersResult(bShow)
    local bJoinThisTurn = false --当前自己是否参加了这局游戏
    for k,v in pairs(Cache.BrniuniuDesk.br_sit_users) do
        local winChips = Cache.BrniuniuDesk.br_totle_result[k]
        --不输不赢、庄家
        if winChips and winChips ~= 0 and checkint(k) > 2010 and k ~= -1 then
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
    local dealer_win_chips = Cache.BrniuniuDesk.br_totle_result[Cache.BrniuniuDesk.br_delar.uin]
    if dealer_win_chips ~= 0 then
        self.delar:winMoneyFly({chips = Cache.packetInfo:getProMoney(dealer_win_chips)})
    end

    if bJoinThisTurn then
        qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP, {showTxt = GameTxt.showInsufficientTxt})
    end
end

-- 结算通杀、通赔
function GameView:gameShowSpecialResultAnimation()
    
    -- if Cache.BrniuniuDesk.self_result == nil or next(Cache.BrniuniuDesk.self_result) == nil then return end
    local tp, ts = Cache.BrniuniuDesk:getGameResultForSpecial()
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

function GameView:initFireAnimation()
    
    if self.firAnimationLayout == nil then
        self.firAnimationLayout  =  cc.Layer:create()
        self:addChild(self.firAnimationLayout)
        self.firAnimationLayout:setZOrder(101)
        self.fireGameanimation     =  Gameanimation.new({view=self,node=self.firAnimationLayout})  --初始化动画
    end
end

--爆庄动画
function GameView:showBaoDelarAnimation()
    self:initFireAnimation()
    if  Cache.BrniuniuDesk.is_blow_up ~= 1 then
        return
    end
    local fire = self.firAnimationLayout:getChildByName("all_fire")
    if fire ~= nil then
        return
    end
    self.fireGameanimation:play({anim = GameAnimationConfig.BAO,scale = 2, index = GameAnimationConfig.BAO.index})
    self:delayRun(0.2, function ()
        qf.event:dispatchEvent(BRNN_ET.BR_UNFIRE)
        self.fireGameanimation:play({anim = GameAnimationConfig.ALLFIRE,scale = 2,name = "all_fire",forever = 1})
    end)
end

---结算动画 7s
function GameView:gameOverAnimation()
    local function getOtherChips(info,k,i,uin)
        local value
        if uin == - 1 then
            value = Cache.BrniuniuDesk.other_result[k].chips
        else
            value = info.chips
        end
        return value
    end
    for k,v in ipairs(Cache.BrniuniuDesk.br_result) do
        local count = 0
        local last = v[#v]
        for i ,info in ipairs(v) do
        
            local uin = info.uin
            local user = self:getBetUserByUin(uin)
            if user == "delar" then
                if info.odds > 0 then
                    self:delayRun(4,function() 
                        -- 庄家吐注
                        self:chipsToPool({user = "delar",value = math.abs(Cache.packetInfo:getProMoney(info.chips)),index = k})
                        self:removeRightPoolWinAni()
                    end)
                else
                    self:delayRun(2,function() 
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

    if Cache.BrniuniuDesk.br_delar.uin ~= Cache.user.uin then
        self.chipsUser["myself"]:refreshGold(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips)
    end
end

--上庄
function GameView:delarSitdown()

    local someone = Cache.BrniuniuDesk.br_delar
    if someone.uin == nil then return end
    if someone.uin == Cache.user.uin then 
        self.chipsUser.myself = self.delar
        self._addP:setVisible(false)

        self:restTime()
    else

        self._addP:setVisible(true)

        self._addP:updateBtnsStatus(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips)

        self._addP:smartChoice()
    end

    self.delar:seatDown()
    if checkint(someone.uin) >= 2000 and checkint(someone.uin) <= 2010 then
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
function GameView:delarlLeave()
    
    local someone = Cache.BrniuniuDesk.br_delar
    if someone.uin == Cache.user.uin then 
        self.chipsUser.myself = self.myself
        self._addP:setVisible(true)
        self._addP:updateBtnsStatus(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips)
        self._addP:smartChoice()
    end
    self.delar:leave()
end

function GameView:someoneStand(uin)
    
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then 
            return v:leave()
        end
    end
end

function GameView:someoneSitdown(uin)
    
    self:clearSeat(uin)
    local someone = Cache.BrniuniuDesk.br_user[uin]
    local right = self._rightUsers[someone.seatid]
    if right == nil then return end
    if someone.uin == Cache.user.uin then
        self.chipsUser.myself = right
    end
    right:seatDown(someone)
end

function GameView:checkSomeoneSitDown(uin)
    
    for k, v in pairs(self._rightUsers) do
        if v.uin == uin then 
            return true
        end
    end
    return false
end


function GameView:someoneLeaveSeat(uin)
    
    if uin == nil then return end
    self:someoneStand(uin)
    if uin == Cache.user.uin then
        self.chipsUser.myself = self.myself
    end
end

function GameView:forceAdjust () 
    
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


function GameView:someChipsChange(model)
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

function GameView:initTouchEvent()
    
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
            -- 之前这里是小喇叭的逻辑，删除
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

function GameView:setHeadIcon(paras)
    
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
function GameView:getContainer( ... )
    
    return self._panContainer
end

function GameView:initGameShop()
    
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
            --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP, data)
            qf.event:dispatchEvent(ET.SHOP)
        end)
    end)
end

function GameView:initMenu()
    
    --左上角菜单按钮
    addButtonEvent(self.bnt_menu, function ( sender )
        --qf.event:dispatchEvent(BRNN_ET.GAME_BRNN_SHOW_MENU)
        loga("左上角菜单按钮")
        qf.event:dispatchEvent(BRNN_ET.GAME_BRNN_EXIT_EVENT)
    end)
    --创建menu
    self._menu = BrnnMenu.new({cb = function() self:hideMenu() end})    --动态创建menu
    self._menu:setAnchorPoint(0, 0)
    self._menu:setPosition(30, self.winSize.height)
    self._menu:setVisible(false)
    self._panContainer:addChild(self._menu, self.MENU_ZORDER)
end
function GameView:showMenu()
    
    if not self._menu then
        self:initMenu()
    end
    self._menu:show()
    self.bnt_menu:setTouchEnabled(false)
end

function GameView:hideMenu()
    
    if self._menu then
        self._menu:removeFromParent()
        self._menu = nil
        self.bnt_menu:setTouchEnabled(true)
    end
end
function GameView:exitBrCall()
    
    if self.delar.uin == Cache.user.uin then 
        return qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.br_delar_exit_tips})
    end
    if Cache.BrniuniuDesk.br_my_chips then
        local myAddChips = 0
        for k , v in pairs(Cache.BrniuniuDesk.br_my_chips) do
            myAddChips = myAddChips + v
        end
        if myAddChips > 0 then
            return qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = BrniuniuTXT.br_delar_exit_tips})
        end
    end
    
    qf.event:dispatchEvent(BRNN_ET.BR_EXIT_REQ, {send=true})
end

function GameView:getRoot()
    return LayerManager.GameLayer
end

function GameView:playWinmoney(paras)
    self.Gameanimation:playWinmoney(paras)
end

function GameView:removeRightPoolWinAni()
    for i = 1, 4 do
        self._rightPools[i]:removeWinAni()
    end
end

function GameView:exit()
    Util:loadAnim(GameAnimationConfig, false, self.Gameanimation)
end

function GameView:enter()
    Util:loadAnim(GameAnimationConfig, true, self.Gameanimation)
end

function GameView:test() 
    for i = 1, 6 do
        self._rightUsers[i] = BrnnUser.new({node = self.gui:getChildByName("user_panel_"..i),index = i})
        self._rightUsers[i]:playShowChatMsg(self.chat_txt_layer, "123132123")
    end
    self.myself:playShowChatMsg(self.chat_txt_layer, "123132123")
    self.delar:playShowChatMsg(self.chat_txt_layer, "123132123")
    -- self._addP:test()
    -- self._rightPools[1]:showVictory()
    -- performWithDelay(self, function ( ... )
    --     self:removeRightPoolWinAni()
    -- end,4)
    -- self.myself:winMoneyFly({chips = 30})
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

    -- Cache.user.meIndex = nil
    -- Cache.kandesk._player_info = {
    --     [1] = {
    --         seatid = 0,
    --         nick = "1111",
    --         chips = 1000,
    --         gold = 30000,
    --         portrait = "IMG2",
    --         sex = 1
    --     },
    --     [2] = {
    --         seatid = 1,
    --         nick = "2222",
    --         chips = 1000,
    --         gold = 30000,
    --         portrait = "IMG2",
    --         sex = 0
    --     },
    --     [3] = {
    --         seatid = 2,
    --         nick = "3333",
    --         chips = 1000,
    --         gold = 30000,
    --         portrait = "IMG2",
    --         sex = 1
    --     },
    -- }
    -- local winMoneyList = {200,-100,-100}
    -- -- local winMoneyList = {200, 100,-300}
    -- -- local winMoneyList = {-200, 100, 100}
    -- Cache.kandesk._result_info = {
    --     [1] = {
    --         card_type = 0,
    --         card = {
    --             10,10,10,10,10
    --         },
    --         win_money = winMoneyList[1],
    --     },
    --     [2] = {
    --         card_type = 0,
    --         card = {
    --             10,10,10,10,10
    --         }, 
    --         win_money = winMoneyList[2],
    --     },
    --     [3] = {
    --         card_type = 0,
    --         card = {
    --             10,10,10,10,10
    --         }, 
    --         win_money = winMoneyList[3],
    --     },
    -- }
    -- Cache.kandesk.zhuang_uin = 1
    self:testResult()
end


function GameView:testResult()
    -- self:testGiveCards()

    local delarUin = 1
    Cache.BrniuniuDesk.br_delar = {
        uin = delarUin,
        cards ={
            [1] = 10,
            [2] = 10,
            [3] = 10,
            [4] = 10,
            [5] = 10,
        },
        card_type = 2
    }
    local myuin = Cache.user.uin
    local chips = Cache.packetInfo:getCProMoney(10)

    --有赔有杀
    -- Cache.BrniuniuDesk.br_result = {
    --     [1] = {{uin = delarUin, odds = -1, chips = chips}, {uin = -1, odds = 1, chips = chips},{uin = myuin, odds = 1, chips = chips}},
    --     [2] = {{uin = delarUin, odds = -1, chips = chips}, {uin = -1, odds = 1, chips = chips},{uin = myuin, odds = 1, chips = chips}},
    --     [3] = {{uin = delarUin, odds = 1, chips = chips}, {uin = -1, odds = -1, chips = chips},{uin = myuin, odds = 1, chips = chips}},
    --     [4] = {{uin = delarUin, odds = 1, chips = chips}, {uin = -1, odds = -1, chips = chips},{uin = myuin, odds = 1, chips = chips}}
    -- }

    --通赔
    Cache.BrniuniuDesk.br_result = {
        [1] = {{uin = delarUin, odds = 1, chips = chips}, {uin = -1, odds = 1, chips = chips},{uin = myuin, odds = 1, chips = chips}},
        [2] = {{uin = delarUin, odds = 1, chips = chips}, {uin = -1, odds = 1, chips = chips},{uin = myuin, odds = 1, chips = chips}},
        [3] = {{uin = delarUin, odds = 1, chips = chips}, {uin = -1, odds = 1, chips = chips},{uin = myuin, odds = 1, chips = chips}},
        [4] = {{uin = delarUin, odds = 1, chips = chips}, {uin = -1, odds = 1, chips = chips},{uin = myuin, odds = 1, chips = chips}}
    }
    Cache.BrniuniuDesk.is_blow_up = 1
    Cache.BrniuniuDesk.br_user[myuin] = {
        chips = 1000
    }
    Cache.BrniuniuDesk.maxOdds = 1
    Cache.BrniuniuDesk.self_result = {
        [1] = {odds = 1, chips = 100},
        [2] = {odds = 1, chips = 100},
        [3] = {odds = 1, chips = 100},
        [4] = {odds = 1, chips = 100}
    }

    Cache.BrniuniuDesk.br_pool = {
        [1] = {cards = {10,10,10,10,10}, card_type = 2},
        [2] = {cards = {10,10,10,10,10}, card_type = 2},
        [3] = {cards = {10,10,10,10,10}, card_type = 2},
        [4] = {cards = {10,10,10,10,10}, card_type = 2},
    }
    Cache.BrniuniuDesk.br_info = {
        time_remain = 10
    }
    Cache.BrniuniuDesk.other_result = {
        [1] = {chips = chips},
        [2] = {chips = chips},
        [3] = {chips = chips},
        [4] = {chips = chips}
    }
    Cache.BrniuniuDesk.br_chips_count = {
        [1] = {section={count = 5, chips = Cache.packetInfo:getCProMoney(50)}},
        [2] = {section={count = 5, chips = Cache.packetInfo:getCProMoney(50)}},
        [3] = {section={count = 5, chips = Cache.packetInfo:getCProMoney(50)}},
        [4] = {section={count = 5, chips = Cache.packetInfo:getCProMoney(50)}}
    }
    Cache.BrniuniuDesk.addChipList = {1,1,1,1,1}
    self._addP:test()
    local chiplist = {10,50,100,500}
    Cache.BrniuniuDesk.addChipList = {}
    for i, v in ipairs(chiplist) do
        Cache.BrniuniuDesk.addChipList[i] =  v
    end
    self.delar.uin = delarUin
    BrnnChipManager:updatePoolCacheChips()

    -- self:testSetChipsToPool()
    -- performWithDelay(self, function()
    --     self:testUpdateByOver()
    -- end, 0.5)
    local testTbl = {
        {0.1, handler(self, self.testGiveCards)},
        {1.5, handler(self, self.testReverseCards)},
        {8.5, handler(self, self.testSetChipsToPool)},
        {12.5, handler(self, self.testUpdateByOver)},
    }
    for i, v in ipairs(testTbl) do
        performWithDelay(self, function()
            v[2]()
        end, v[1])
    end
end

function GameView:testSetChipsToPool()
    for index,section in pairs(Cache.BrniuniuDesk.br_chips_count) do
        for k,count in pairs(section) do
            for i = 1,count.count do
                self:chipsToPool({user = "other",value = Cache.packetInfo:getProMoney(count.chips),index = index,noanimation = false})
            end
        end
    end
end

function GameView:testGiveCards()
    local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
    local delay = 0
    self.delar:giveCards(delay,0.05,dpoint)
    for i = 1 ,4 do
        self._rightPools[i]:giveCards((i+1)*delay,0.05,dpoint)
    end
    print("testResult >>>>>>>>>>>>>>")
end

function GameView:testReverseCards()
    -- Cache.BrniuniuDesk.bCanLeave = false
    -- self.gui:getChildByName("time_layer"):setVisible(false)
    -- self:restTime()
    local dpoint = cc.p(self.winSize.width*0.5,self.winSize.height*0.7)
    local delay = 1
    local reverseTime = 0
    self.delar:reverseCards(delay+reverseTime)
    for i = 1 ,4 do
        self._rightPools[i]:reverseCards((i+1)*delay+reverseTime)
    end

    -- self:delayRun(6*delay+reverseTime + 1, function ()
    --     -- qf.event:dispatchEvent(BRNN_ET.BR_QUERY_RECENT_TREND_UPDATE_DESK)
    --     self.view:updateDelarListInDesk()
    -- end)
end

function GameView:testUpdateByOver()
    print("updateByOver BrnnGameView ")
    self:timeCountDown({time = Cache.BrniuniuDesk.br_info.time_remain,status = 1})
    -- self:delayRun(5,function ()
    --     qf.event:dispatchEvent(BRNN_ET.BR_UNFIRE)
    -- end)
    -- local dt = 2
    -- --游戏结束
    local overAniPt = 2
    self:delayRun(4+2,function() self:testGameOverAnimation() end) -- 结算动画   7s

    -- --结算之后显示通杀或者通赔
    self:delayRun(5.5 + 2,function () self:gameShowSpecialResultAnimation() end) --通杀或者通赔动画

    --检测爆庄特效
    self:delayRun(9 + 2,function()
        self:showBaoDelarAnimation()
    end)
    -- --展示玩家头像信息
    self:delayRun(10 + 2, function ()
        self:testUpdateUsersResult()
    end)
    -- --游戏准备中
    self:delayRun(11 + 2,function()
        -- self:ready() end,
        qf.event:dispatchEvent(BRNN_ET.BR_UNFIRE)
    end)
end

function GameView:testUpdateUsersResult( ... )
    self.myself:winMoneyFly({chips = 30})
    self.delar:winMoneyFly({chips = 30000})
end

function GameView:playBetEfx(isBet)
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

function GameView:testGameOverAnimation()
    local function getOtherChips(info,k,i,uin)
        local value
        if uin == - 1 then
            value = Cache.BrniuniuDesk.other_result[k].chips
        else
            value = info.chips
        end
        return value
    end

    for k,v in ipairs(Cache.BrniuniuDesk.br_result) do
        local count = 0
        local last = v[#v]
        for i ,info in ipairs(v) do
            -- dump(info)
            local uin = info.uin
            local user = self:getBetUserByUin(uin)
            print("user >>>>>", user, "odds >>>", info.odds)
            if user == "delar" then
                if info.odds > 0 then
                    self:delayRun(4,function() 
                        -- 庄家吐注
                        self:chipsToPool({user = "delar",value = math.abs(Cache.packetInfo:getProMoney(info.chips)),index = k})
                        self:removeRightPoolWinAni()
                    end)
                else
                    self:delayRun(2,function() 
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
    -- 由于一开始就已经更新了自己本局最新的筹码数
    -- 如果在某个区域赢了就要刷新自己的筹码显示
    local _chipsThisWin = 0 -- 本局自己赢得筹码数
    local _chipsThisLose = 0
    for i=1, 4 do
        if Cache.BrniuniuDesk.self_result[i] then
            if Cache.BrniuniuDesk.self_result[i].chips > 0 then
                _chipsThisWin = _chipsThisWin + Cache.BrniuniuDesk.self_result[i].chips
            else
                _chipsThisLose = _chipsThisLose + Cache.BrniuniuDesk.self_result[i].chips
            end
        end
    end
    if 0 < _chipsThisWin and 0 > _chipsThisLose then
        self.myself:refreshGold((Cache.BrniuniuDesk.br_user[Cache.user.uin].chips - _chipsThisWin))
        if Cache.BrniuniuDesk.br_delar.uin ~= Cache.user.uin then
            self.chipsUser["myself"]:refreshGold((Cache.BrniuniuDesk.br_user[Cache.user.uin].chips - _chipsThisWin))
        end
    elseif 0 > _chipsThisLose then
        self.myself:refreshGold(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips)
        if Cache.BrniuniuDesk.br_delar.uin ~= Cache.user.uin then
            self.chipsUser["myself"]:refreshGold(Cache.BrniuniuDesk.br_user[Cache.user.uin].chips)
        end
    end
end

function GameView:refreshHongBaoBtn()
    self.shopBtn:setVisible(Cache.user.first_recharge_flag == 0)
    if Cache.user.first_recharge_flag == 1 then
        local pos = self.shopBtn:getPosition3D()
        Util:addHongBaoBtn(self, pos)
    elseif Cache.user.first_recharge_flag == 0 then
        Util:removeHongBaoBtn(self)
    end
end

function GameView:refreshNetStrength(paras)
    paras = paras or {}
    --10倍场 显示的颜色是白色
    if Cache.BrniuniuDesk:getRoomType() ~= 14 then
        paras.showcolor = cc.c3b(255, 255, 255)
    end

    local diffX = 0
    Util:addNetStrengthFlag(self.gui, cc.p(170 - diffX,1045), paras)
end

--得到当前需要下注至少的money
function GameView:getNeedMoney()
    local leastMoney = Cache.BrniuniuDesk:getLeastChipsPloolNum()
    local user = Cache.BrniuniuDesk.br_user[Cache.user.uin]
    if user then
        local chip = Cache.packetInfo:getProMoney(user.chips)
        return leastMoney - chip
    end
end

function GameView:refreshNoMoneyTip(paras)
    local needMoney = self:getNeedMoney()

    local showTxt = nil
    if paras then
        showTxt = paras.showTxt
    end
    if needMoney then 
        if needMoney > 0 then
            Util:refreshNoMoneyTip(self, {restMoney = Cache.BrniuniuDesk:getLeastChipsPloolNum(), showTxt = showTxt})
        else
            Util:refreshNoMoneyTip(self, {restMoney = 0, showTxt = showTxt})
        end
    end
end

function GameView:initChatUI()
	self.Chat = Chat.getChatBtn()
    self.Chat:setVisible(Util:isHasReviewed())
    self:addChild(self.Chat)
    local _cmd = BRNN_CMD.CMD_BR_USER_DESK_CHAT_V10
    if Cache.BrniuniuDesk:getRoomType() == 14 then
        _cmd = BRNN_CMD.CMD_BR_USER_DESK_CHAT_V3
    end

    self._chat = Chat.new({view=self,chat_list=true, ChatCmd=_cmd})
    self:addChild(self._chat, 3)
    self.chat_txt_layer = self._chat:getChatTxtLayer()
    self:addChild(self.chat_txt_layer, 2)

    --聊天
	self.Chat:setPosition(cc.p(1633, 65))
	addButtonEvent(self.Chat,function ( )
        -- body
        -- local myUin = Cache.user.uin
        -- local user = Cache.BrniuniuDesk.br_user[myUin]
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

function GameView:chat(model)
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

function GameView:hideChat()
    if self._chat then
        self._chat:hide()
    end
end

return GameView
