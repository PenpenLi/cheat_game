local GameController = class("GameController", qf.controller)
GameController.TAG = "GameController"
GameController.inputOverTimeTag = 1567

local gameView = import(".GameView")

GameController.giveCardAnimationTime = 2
GameController.loadingDelayTime = 0.2

function GameController:ctor(parameters)
    self.super.ctor(self)
end

function GameController:initModuleEvent()
    --游戏逻辑相关
    self:addModuleEvent(BRNN_ET.BR_QUERY_BANKER_LIST_CLICK, handler(self,self.queryBankerListReq))

    self:addModuleEvent(BRNN_ET.UPDATE_DELAR_INFO, handler(self,self.updateDelarNum))
    self:addModuleEvent(BRNN_ET.GET_DELAR_INFO_IN_DESK, handler(self, self.queryDelarListInfoReq))

    self:addModuleEvent(BRNN_ET.BR_QUERY_RECENT_TREND_CLICK, handler(self,self.queryRecentTrendReq))
    self:addModuleEvent(BRNN_ET.BR_QUERY_RECENT_TREND_UPDATE_DESK, handler(self, self.queryRecentTrendReqInDesk))
    self:addModuleEvent(BRNN_ET.BR_QUERY_PLAYER_LIST_CLICK, handler(self,self.queryPlayerListReq))
    self:addModuleEvent(BRNN_ET.BR_CLICK_POOL, handler(self,self.processBrPoolBet))    ---百人场下注
    self:addModuleEvent(BRNN_ET.BR_NET_EVENT_GAME_OVER, handler(self,self.brGameOverNotify))    ---百人场结局通知
    self:addModuleEvent(BRNN_ET.BR_NET_EVENT_BET_START, handler(self,self.brBetStartNotify))    ---百人场下注时间
    self:addModuleEvent(BRNN_ET.BR_SEATDOWN_REQ, handler(self,self.brSitdownReq))    ---百人场坐下请求
    self:addModuleEvent(BRNN_ET.BR_NET_SIT_DOWN_EVT,handler(self,self.brprocessSitdownEvt))

    self:addModuleEvent(BRNN_ET.BR_SEATUP_REQ, handler(self,self.brSitupReq))    ---百人场站起请求
    self:addModuleEvent(BRNN_ET.BR_DELARLIST_SHOW, handler(self,self.brShowDelarList))    ---显示百人场上庄列表
    self:addModuleEvent(BRNN_ET.BR_DELAR_REQ, handler(self,self.brBeDelarRequest))    --百人场上庄
    self:addModuleEvent(BRNN_ET.BR_DELAR_EXIT_REQ, handler(self,self.brQuitDelarRequest))    --百人场退庄
    self:addModuleEvent(BRNN_ET.BR_NET_BANKER_CHANGE,handler(self,self.brprocessDelarSitdownEvt))
    self:addModuleEvent(BRNN_ET.BR_NET_OPEN_SHARE_CARDS_EVT,handler(self,self.brprocessOpenSharedCardsEvt))
    self:addModuleEvent(BRNN_ET.BR_NET_EXIT_RESPONSE_EVT,handler(self,self.brprocessExitGameEvt))
    self:addModuleEvent(BRNN_ET.BR_NET_EVENT_BANKER_EXIT,handler(self,self.brprocessDelarExitGameEvt))
    self:addModuleEvent(BRNN_ET.NET_BR_FOLLOW_BET_EVT,handler(self,self.brprocessFllowEvt))
    self:addModuleEvent(ET.BR_JIFEN_EVT,handler(self,self.brShowJiFen))--百人场显示积分
    self:addModuleEvent(BRNN_ET.GAME_BRNN_SHOW_MENU,handler(self,self.showBrnnMenu))   
    self:addModuleEvent(BRNN_ET.GAME_BRNN_HIDE_MENU,handler(self,self.hideBrnnMenu))   
    self:addModuleEvent(BRNN_ET.GAME_BRNN_EXIT_EVENT,handler(self,self.exitBrCall))
    self:addModuleEvent(BRNN_ET.BR_UNFIRE, handler(self, self.unfire))
    self:addModuleEvent(BRNN_ET.BR_WINMONEY, handler(self, self.winMoney))
    self:addModuleEvent(BRNN_ET.USER_LEAVE_SEAT_EVENT, handler(self, self.brprocessUserLeaveSeat))

    --其他事件
    self:addModuleEvent(ET.GAME_SHOW_USER_INFO, handler(self,self.processUserInfoShow))
    self:addModuleEvent(BRNN_ET.GAME_REFRESH_ADDBTN,handler(self,self.refreshAddBtn))
    self:addModuleEvent(ET.EVENT_USER_CHIPS_CHANGE, handler(self,self.userChipsChangedNotify))   ---服务端通知更改筹码
    -- self:addModuleEvent(ET.NET_EVENT_OTHER_GOLD_CHANGE,handler(self,self.processGameChangeOtherGoldEvt))

    self:addModuleEvent(BRNN_ET.BR_NET_EVENT_DESK_CHAT,handler(self,self.brprocessGameChatEvt))

    --断网通知
    self:addModuleEvent(ET.NET_DISCONNECT_NOTIFY, handler(self, self.processNetDisconnect))
end

function GameController:removeModuleEvent()
    --调用 self:addModuleEvent添加的事件, 在模块remove时将自动移除
end

function GameController:initGlobalEvent()
    logd(" GameController initGlobalEvent --",self.TAG)
    ----正常进入游戏 , 检查人数是否已经满了 
    qf.event:addEvent(BRNN_ET.NET_BR_BULL_INPUT_REQ, function(paras)
        if self.view then self.view:stopAllActions() end
        Util:delayRun(self.loadingDelayTime,function ()
            qf.event:dispatchEvent(ET.CHANGE_BORADCAST_DELAYTIME,{time = 5})
            local roomType = paras.roomType
            local cmd = roomType == 14 and BRNN_CMD.CMD_BR_USER_ENTER_DESK_V2 or BRNN_CMD.CMD_BR_USER_ENTER_DESK_V10
            GameNet:send({cmd = cmd, body={roomid = paras.roomid},
                timeout = 10,
                wait = true,
                callback=function(rsp)
                    if rsp.ret ~= 0 and rsp.ret then
                        if rsp.ret == NET_WORK_ERROR.TIMEOUT then --重试多1次
                            if self.tryCount == nil then
                                self.tryCount = 1
                            else
                                self.tryCount = self.tryCount + 1
                            end
                            if self.tryCount < 2 then--再发一次进桌
                                qf.event:dispatchEvent(BRNN_ET.NET_BR_BULL_INPUT_REQ,{roomid = paras.roomid})
                                return 
                            end
                        end
                        --用户未登陆
                        if rsp.ret == 14 then
                            -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                            qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                            return
                        end
                        self.tryCount = nil
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret] or string.format(GameTxt.input_roomerror_tips, rsp.ret)})
                        self:closeAndReturn()
                        --qf.event:dispatchEvent(ET.BR_EXIT_REQ, {send=true})
                    end
                end
            })
        end)
    end)
    --百人场进桌
    qf.event:addEvent(BRNN_ET.BR_NET_INPUT_GAME_EVT,handler(self,self.brprocessInputGameEvt))
    --退桌操作处理
    qf.event:addEvent(BRNN_ET.BR_EXIT_REQ, handler(self,self.processExitToOther)) 
end

--[[--百人场进桌]]
function GameController:brprocessInputGameEvt(parameters)
    -- logd(pb.tostring(parameters.model))
    Cache.user.meIndex = -1
    Cache.BrniuniuDesk:updateCacheByBrInput(parameters.model)
    Cache.BrniuniuDesk:updateBrInfo(parameters.model.br)

    if self.view == nil then return end
    --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
    if parameters.model.op_uin == Cache.user.uin then 
        self.view:updateByInput()
        if not Cache.packetInfo:isShangjiaBao() then
            if not Cache.BrniuniuDesk:checkXiaZhu() then
                qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP)
            end
        end
    end
end

--关闭牌桌界面并返回上级模块
function GameController:closeAndReturn()
    if self.view ~= nil then
        self:remove()
        qf.event:dispatchEvent(ET.CLOSE_BEAUTY_GALLERY)--返回关闭美女发图预览
        if Cache.user.guidetochat then
            ModuleManager.BrnnHall:remove()
            ModuleManager.gameshall:initModuleEvent()
            ModuleManager.gameshall:show({toChat = Cache.user.guidetochat})
            ModuleManager.gameshall:showReturnHallAni()
        else
            ModuleManager.BrnnHall:show()
        end
    end
end

--退桌操作. paras.send, 是否退出界面同时向服务器发送请求
function GameController:processExitToOther(paras)
    local send = (paras == nil or paras.send == nil) and true or paras.send
    if send then
        local cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_GAME_EXIT_DESK_V2 or BRNN_CMD.CMD_BR_GAME_EXIT_DESK_V10
        GameNet:send({
            cmd=cmd,body={},callback=function (rsp)
                 if rsp ~= nil  then 
                    if rsp.ret == 0 then
                        self:closeAndReturn()
                    else
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
                    end
                    if paras and paras.callback then
                      paras.callback(rsp.ret)
                    end
               end
            end
        })
    else
        self:closeAndReturn()
    end
end

--[[--百人场服务端通知 某人坐下了]]
function GameController:brprocessSitdownEvt(parameters)
    if self.view == nil then return end
    local m = parameters.model
    Cache.BrniuniuDesk:updateBrSitUser(m)
    self.view:someoneSitdown(m.op_uin)
    if m.op_uin ~= Cache.user.uin then MusicPlayer:playMyEffect("TASK_FINISH") end
    --百人场不支持vip隐身，如果已经开启了隐身需要提示不支持
    if m.op_uin == Cache.user.uin and Cache.BrniuniuDesk:judegeBrIsHiding(m.op_uin) == true then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=GameTxt.vip_hiding_br_tip})
    end
end

--[[--百人场服务端通知 某人离座了]]
function GameController:brprocessUserLeaveSeat(rsp)
    if self.view == nil then return end
    local m = rsp.model
    Cache.BrniuniuDesk:updateBrSitUserBySomeoneLeave(m)
    self.view:someoneLeaveSeat(m.uin)
end

function GameController:unfire()
    if self.view == nil then return end
    if self.view.firAnimationLayout == nil then
        self.view:initFireAnimation()
    end
    
    local all_fire = self.view.firAnimationLayout:getChildByName("all_fire")
    if all_fire  then
        all_fire:removeFromParent()
    end
end

function GameController:winMoney(paras)
    if self.view == nil then return end
    -- print("zxcvxzcvasdfqwer")
    self.view:playWinmoney(paras)
end


--[[--百人场服务端通知上庄]]
function GameController:brprocessDelarSitdownEvt(parameters)
    if self.view == nil then return end
    local m = parameters.model
    loga("百人牛牛上庄通知" .. pb.tostring(m))
    self.view:someoneStand(m.op_uin)
    Cache.BrniuniuDesk:updateBrSitDelar(m)
    self.view:delarSitdown()
    self.view:updateDelarListInDesk()
end

--[[--百人场发牌]]
function GameController:brprocessOpenSharedCardsEvt(parameters)
    if self.view == nil then return end
    local m = parameters.model
    Cache.BrniuniuDesk:updateBrnnShareCards(m)
    self.view:giveCards()
end

--[[--百人场服务端通知 某个用户站起]]
function GameController:brprocessExitGameEvt(paras)
    if self.view == nil then return end
    local m = paras.model
    logd(pb.tostring(m))
    self.view:someoneStand(m.op_user.uin)
    if m.op_user.uin == Cache.user.uin then
        self.view:hideChat()
    end
end

--[[--百人场服务端通知 有人下庄]]
function GameController:brprocessDelarExitGameEvt(paras)
    if self.view == nil then return end
    local m = paras.model
    loga( "百人牛牛下庄通知" .. pb.tostring(m))
    self.view:delarlLeave()
    if Cache.BrniuniuDesk.br_delar.uin == Cache.user.uin then
        self.view:hideChat()
    end
end

--百人场通知某个用户跟注了
function GameController:brprocessFllowEvt(paras)
    -- loga("百人场下注通知-->"..pb.tostring(paras.model),self.TAG)
    local m = paras.model
    Cache.BrniuniuDesk:updateByBrFllow(m)
    if self.view == nil then return end
    
    for i = 1 ,m.bet_info:len() do
        local allInfo = m.bet_info:get(i)
        local uin = allInfo.uin
        local user = self.view:getBetUserByUin(uin)
        
        local counter = Cache.BrniuniuDesk.br_user[uin].counter
        
        for index,chipsInfo in pairs(counter) do
            for chips,count in pairs(chipsInfo) do
                for k = 1, count do
                    if (uin == Cache.user.uin and m.bet_type ~= 1) or uin ~= Cache.user.uin then
                        local delay = user == "other" and math.random(1, 3)*3/10 or 0.15*(i-1) 
                        self.view:delayRun(
                            0.15*(i- 1) ,
                            function() 
                                self.view:chipsToPool({user = user,value = Cache.packetInfo:getProMoney(chips),index = index,no_action = uin == Cache.user.uin})
                        end)
                    end
                end
            end
        end
    end
    -- self:memoryCollect()
end

function GameController:memoryCollect()
    if collectgarbage("count") > 350000 then
        loga(string.format("内存占用已接近临界值：%s", collectgarbage("count")))
        collectgarbage("collect")
        loga("内存清理成功")
    end
end

function GameController:getBrnnUserByCache(uin)
    if self.view == nil or uin == nil or self.view.chipsUser == nil then return nil,nil end
    local user = self.view:getBetUserByUin(uin)
    return self.view.chipsUser[user],user
end

function GameController:processUserInfoShow(paras)
    if self.view == nil then return end
    if paras == nil or paras.uin == nil then return end
    qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{uin = paras.uin, type = BRNN_MATCHE_TYPE, defaultImg = paras.defaultImg, showGold = paras.showGold, showGoldTxt = paras.showGoldTxt or ""})
end

function GameController:brShowJiFen(paras)
    if paras == nil or paras.score == nil or self.view == nil then return end
    self.view:showJiFen(paras.score)
end

function GameController:showBrnnMenu()
    if self.view then
        self.view:showMenu()
    end
end

function GameController:hideBrnnMenu()
    if self.view then
        self.view:hideMenu()
    end
end

function GameController:showBaoDelarAnimation()
    if self.view then
        self.view:showBaoDelarAnimation()
    end
end

function GameController:exitBrCall(paras)
    if self.view then
        if paras then
            Cache.user.guidetochat = paras.guidetochat
        end
        self.view:exitBrCall()
    end
end

function GameController:userChipsChangedNotify(rsp)
    if self.view then 
        self.view:someChipsChange(rsp.model)
        if not Cache.packetInfo:isShangjiaBao() then
            qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP)
        end
    end
end

function GameController:queryDelarListReq(cb)
    local _cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_QUERY_BANKER_LIST_V2 or BRNN_CMD.CMD_BR_QUERY_BANKER_LIST_V10
    GameNet:send({cmd = _cmd, callback = function(rsp)
        if rsp.ret == 0 then 
            if self.view == nil then return end
            Cache.BrniuniuInfo:updateDelarList(rsp.model)
            if cb then
                cb()
            end
        end
    end})
end

-- 庒家数量变化推送
function GameController:updateDelarNum(rsp)
    if self.view == nil then return end
    Cache.BrniuniuInfo:updateDelarList(rsp.model)
    self.view:updateDelarListInDesk()
end

function GameController:queryDelarListInfoReq( ... )
    self:queryDelarListReq(function ()
        if self.view == nil then return end
        self.view:updateDelarListInDesk()
    end)
end

-- 获取庄家信息rsp
function GameController:queryBankerListReq()
    self:queryDelarListReq(function ()
        self.view:updateDelarList()
    end)
end

function GameController:queryRecentTrend(cb)
    local _cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_QUERY_RECENT_TREND_V2 or BRNN_CMD.CMD_BR_QUERY_RECENT_TREND_V10
    GameNet:send({cmd = _cmd, callback = function(rsp)
        if rsp.ret == 0 then 
            if self.view == nil then return end

            Cache.BrniuniuInfo:updateHistory(rsp.model)
            if cb then
                cb()
            end
        end
    end})
end

function GameController:queryRecentTrendReqInDesk()
    self:queryRecentTrend(function ()
        self.view:updateBrnnHistoryInDesk()
    end)
end

function GameController:queryRecentTrendReq()
    self:queryRecentTrend(function ()
        self.view:updateBrnnHistory()
    end)
end

function GameController:queryPlayerListReq()
    local _cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_QUERY_PLAYER_LIST_V2 or BRNN_CMD.CMD_BR_QUERY_PLAYER_LIST_V10
    GameNet:send({cmd = _cmd, callback = function(rsp)
        if rsp.ret == 0 then
            if self.view == nil then return end
            Cache.BrniuniuInfo:updateOthers(rsp.model)
            self.view:updateBrnnPerson()
        end
    end})
end

function GameController:processBrPoolBet(paras)
    if self.view == nil then return end
    if paras.value == nil or paras.value == 0 then return end

    local _cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_GAME_FOLLOW_BET_V2 or BRNN_CMD.CMD_BR_GAME_FOLLOW_BET_V10
    GameNet:send({
        cmd=_cmd,body={chips=Cache.packetInfo:getCProMoney(paras.value),section = paras.index},callback=function (rsp)
            if rsp.ret == 0 and self.view then
                self.view:chipsToPool({user = "myself",value = paras.value,index = paras.index,ismyself = true})
            end 

            if rsp.ret ~= 0 and self.view then
                -- self.view:chipsFallBack(paras.index,paras.value)
            end
            if rsp.ret == 5 then
                --自己金币大于等于50  与小于 50 提示不同
                if Cache.BrniuniuDesk.br_user[Cache.user.uin] and Cache.BrniuniuDesk.br_user[Cache.user.uin].chips  >= Cache.BrniuniuDesk.min_bet_carry then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_bet_error3,time = 2})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_bet_error1,time = 2})
                end
            elseif rsp.ret == 25 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.br_bet_error2,time = 2})
            else
                if Cache.Config._errorMsg[rsp.ret] then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
                end
            end
    end
    })
end

function GameController:brGameOverNotify(paras)
    if self.view == nil then return end
    print("百人场 结局通知 ----------------------")
    local m = paras.model
    Cache.BrniuniuDesk:updateByBrOver(m)
    self.view:updateByOver()
end

function GameController:brBetStartNotify(paras)
    if self.view == nil then return end
    print("百人场 开始下注 brBetStartNotify ----------------------")
    Cache.BrniuniuDesk:updateBetTiem(paras.model)
    -- self.view:ready()
    -- self.view:timeCountDown({time = Cache.BrniuniuDesk.bet_time,status = 2})
    self.view:pushCards()
end

function GameController:brSitdownReq(paras)
    local cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_GAME_USER_SIT_DOWN_V2 or BRNN_CMD.CMD_BR_GAME_USER_SIT_DOWN_V10
    GameNet:send({
        cmd=cmd,body={seatid = paras.index},callback=function (rsp)
            if rsp.ret == 0 then
                if self.view == nil then return end
            elseif rsp.ret == 3 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.br_seatdown_error})
                qf.platform:umengStatistics({umeng_key = "BR_Ask_Sitdown_Shopping"})--点击上报
                --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {gold=100000, ref=UserActionPos.BR_SIT_LACK})
                qf.event:dispatchEvent(ET.SHOP)
            elseif rsp.ret == 7 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = BrniuniuTXT.br_sitdown_failed_error})
            elseif rsp.ret == 2015 then
                if not Cache.packetInfo:isShangjiaBao() then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                    return 
                end
                local tips = Util:getReviewStatus() and GameTxt.string_room_limit_7 or GameTxt.string_room_limit_6
                qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = Cache.Config._errorMsg[rsp.ret] .. tips , confirmCallBack = function ( ... )
                    -- 发送退桌
                    if Util:getReviewStatus() then
                        qf.event:dispatchEvent(ET.SHOP)
                    else
                        qf.event:dispatchEvent(BRNN_ET.GAME_BRNN_EXIT_EVENT, {guidetochat = true})
                    end
                end})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        end
    })
end

function GameController:brSitupReq(paras)
     local cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_GAME_USER_SIT_UP_V2 or BRNN_CMD.CMD_BR_GAME_USER_SIT_UP_V10
     GameNet:send({
        cmd=cmd,body={uin = paras.uin},callback=function (rsp)
            if rsp.ret == 0 then
                -- logd("站起成功")
            else
                -- logd("站起失败", rsp.ret)
            end
        end
    })
end

function GameController:brShowDelarList(paras)
    if self.view == nil then return end
    self.view:showDelarList(paras.isExit)
end

function GameController:brBeDelarRequest(paras)
    local _cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_USER_BANKER_APPLY_V2 or BRNN_CMD.CMD_BR_USER_BANKER_APPLY_V10
    GameNet:send({cmd = _cmd, callback = function(rsp)
        if rsp.ret == 0 then
            qf.event:dispatchEvent(BRNN_ET.GET_DELAR_INFO_IN_DESK)
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.br_delar_seatdown_success})
        elseif rsp.ret == 1 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.br_delarlist_success})
        elseif rsp.ret == 3 then
            local minGold = Cache.packetInfo:getProMoney(Cache.BrniuniuDesk.min_banker)
            local errorTip = string.format(GameTxt.br_delar_seatdown_error, Util:getFormatString(minGold), Cache.packetInfo:getShowUnit())     
            -- qf.platform:umengStatistics({umeng_key = "BR_Ask_Delar_Shopping"})--点击上报
            if not Cache.packetInfo:isShangjiaBao() then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = errorTip})
                qf.event:dispatchEvent(ET.SHOP)
            else
                local tips = Util:getReviewStatus() and GameTxt.string_room_limit_7 or GameTxt.string_room_limit_6
                qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = errorTip .. tips , confirmCallBack = function ( ... )
                    -- 发送退桌
                    if Util:getReviewStatus() then
                        qf.event:dispatchEvent(ET.SHOP)
                    else
                        qf.event:dispatchEvent(BRNN_ET.GAME_BRNN_EXIT_EVENT, {guidetochat = true})
                    end
                end})
            end
            
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end

function GameController:brQuitDelarRequest(paras)
    local _cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_USER_BANKER_EXIT_V2 or BRNN_CMD.CMD_BR_USER_BANKER_EXIT_V10
    GameNet:send({cmd = _cmd, callback = function(rsp) 
        if rsp.ret == 0 then
            qf.event:dispatchEvent(BRNN_ET.GET_DELAR_INFO_IN_DESK)
        end
    end})
end


--[[聊天相关 start]]
function GameController:brprocessGameChatEvt(paras) 
    logd("== ="..pb.tostring(paras.model),self.TAG)
    if self.view == nil or tolua.isnull(self.view) then return end
    self.view:chat(paras.model)
end

function GameController:refreshAddBtn() 
    if self.view == nil then return end
    self.view:refreshAddBtn()
end

--断网后, 百人场关闭界面
function GameController:processNetDisconnect(paras)
    qf.event:dispatchEvent(BRNN_ET.BR_EXIT_REQ, {send=false})
end

function GameController:initView(parameters)
    MusicPlayer:stopBackGround()
    MusicPlayer:setBgMusic(GameRes.all_music.GMAE_COMMON_BGM)
    MusicPlayer:playMusic(GameRes.all_music.GMAE_COMMON_BGM, true)
    qf.event:dispatchEvent(ET.CHANGE_BORADCAST_DELAYTIME,{time = 0})
    qf.event:dispatchEvent(ET.MODULE_SHOW,"brniuniugame")
    local view = gameView.new(parameters)
    return view
end

function GameController:remove(parameters)
    qf.event:dispatchEvent(ET.MODULE_HIDE,"brniuniugame")
    Cache.DeskAssemble:clearGameType()  --清除游戏类型
    Cache.BrniuniuDesk:clearCache()           --清除百人场数据缓存
    MusicPlayer:setBgMusic()
    MusicPlayer:stopBackGround()
    -- MusicPlayer:backgroundSineIn()
    qf.event:dispatchEvent(ET.CHANGE_BORADCAST_DELAYTIME,{time = 0})
    if self.view then
        self.view:release()
    end
    self.super.remove(self)
    PopupManager:removeAllPopup(parameters)   --移除所有弹窗
end

return GameController
