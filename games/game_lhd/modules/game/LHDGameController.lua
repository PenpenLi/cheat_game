local LHDGameController = class("LHDGameController", qf.controller)

LHDGameController.TAG = "LHDGameController"

local gameView = import(".LHDGameView")

LHDGameController.loadingDelayTime = 0.2

function LHDGameController:ctor()
    LHDGameController.super.ctor(self)
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    self.loadWinRank = false --设置限制，每局只请求一次盈利榜
    self:loadCmdList()
end

function LHDGameController:initView(parameters)
    self:initModuleEventAfterReady()
    self:setBgMusic()
    qf.event:dispatchEvent(ET.CHANGE_BORADCAST_DELAYTIME,{time = 0})
    qf.event:dispatchEvent(ET.MODULE_SHOW,"game_lhd")
    local view = gameView.new(parameters)
    return view
end

function LHDGameController:setBgMusic( ... )
    MusicPlayer:stopBackGround()
    MusicPlayer:setBgMusic(GameRes.all_music.GMAE_COMMON_BGM)
    MusicPlayer:playMusic(GameRes.all_music.GMAE_COMMON_BGM, true)
end

--加载命令字
function LHDGameController:loadCmdList()
    self.cmd_list = {
        BANKER_LIST_REQ = CMD.LHD_QUERY_BANKER_LIST --请求上庄列表
        , RECENT_TREND_REQ = CMD.LHD_QUERY_RECENT_TREND --请求走势信息
        , PLAYER_LIST_REQ = CMD.LHD_QUERY_PLAYER_LIST --请求无座玩家列表
        , GAME_FOLLOW_REQ = CMD.LHD_GAME_FOLLOW_BET --下注
        , GAME_EXIT_REQ = CMD.LHD_GAME_EXIT_DESK --退桌
        , SIT_DOWN_REQ = CMD.LHD_GAME_USER_SIT_DOWN --坐下
        , BANKER_APPLY_REQ = CMD.LHD_USER_BANKER_APPLY --请求上庄
        , BANKER_EXIT_REQ = CMD.LHD_USER_BANKER_EXIT --下庄
        , SIT_UP_REQ = CMD.LHD_GAME_USER_SIT_UP --站起
        -- , CHAT_REQ = CMD.LHD_USER_DESK_CHAT
    }
end

--全局事件
function LHDGameController:initGlobalEvent()
    --进桌请求.    
    qf.event:addEvent(LHD_ET.NET_LHD_INPUT_REQ, function(paras)
    	if self.view then self.view:stopAllActions() end
        Util:delayRun(self.loadingDelayTime,function ()
            qf.event:dispatchEvent(ET.CHANGE_BORADCAST_DELAYTIME,{time = 5})
            GameNet:send({cmd=CMD.LHD_USER_ENTER_DESK, body=paras,
                timeout = 10,
                wait = true,
                callback=function(rsp)
                loga("rsp.retrsp.retrsp.retrsp.ret"..rsp.ret)
                    if rsp.ret ~= 0 and rsp.ret then
                        if rsp.ret == NET_WORK_ERROR.TIMEOUT then --重试多1次
                            if self.tryCount == nil then
                                self.tryCount = 1
                            else
                                self.tryCount = self.tryCount + 1
                            end
                            if self.tryCount < 2 then--再发一次进桌
                                qf.event:dispatchEvent(LHD_ET.NET_LHD_INPUT_REQ,paras)
                                return 
                            end
                        end
                        --用户未登陆
                        if rsp.ret == 14 then
                            qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                            return
                        end

                        self.tryCount = nil
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret] or string.format(GameTxt.input_roomerror_tips, rsp.ret)})
                        self:closeAndReturn()
                    end
                end
            })
        end)
    end)
    --操作: 退出游戏
    qf.event:addEvent(LHD_ET.LHD_EXIT_REQ, handler(self, self.processExitToOther))

    --请求赢钱排行榜信息
    qf.event:addEvent(LHD_ET.LHD_EVENT_RANK_WIN, handler(self,self.queryWinRankInfoReq))
end

--Moudle.sng:show()后处理的消息
function LHDGameController:initModuleEvent()
    --[[
        加入一个很关键的标识desk_init_success, 用来记录牌桌是否初始化成功. 
        当收到了我自己的进桌消息后，初始化牌桌相关的一些数据和界面，desk_init_success将设为true.
        如果在收到我自己的进桌消息前，收到了并处理其他消息，相当于牌桌数据和界面没有初始化的时候就进行了其他逻辑处理，必然出现异常
    ]]
    self.desk_init_success = false
    --通知: 进桌
    self:addModuleEvent(LHD_ET.LHD_NET_INPUT_GAME_EVT,handler(self, self.handlerInputGameNtf))
    --断网通知
    self:addModuleEvent(ET.NET_DISCONNECT_NOTIFY, handler(self, self.processNetDisconnect))
    
end

--界面初始化完成后处理的事件
function LHDGameController:initModuleEventAfterReady()
    --打开上庄列表弹窗
    self:addModuleEvent(LHD_ET.BR_DELARLIST_SHOW, handler(self,self.handlerShowDelarList))
    
    --请求上庄列表
    self:addModuleEvent(LHD_ET.BR_QUERY_BANKER_LIST_CLICK, handler(self,self.queryBankerListReq))
    --请求上庄
    self:addModuleEvent(LHD_ET.BR_DELAR_REQ, handler(self,self.handlerBeDelarRequest))
    --请求下庄
    self:addModuleEvent(LHD_ET.BR_DELAR_EXIT_REQ, handler(self,self.handlerQuitDelarRequest))
    --请求走势信息
    self:addModuleEvent(LHD_ET.BR_QUERY_RECENT_TREND_CLICK, handler(self,self.queryRecentTrendReq))
    --请求无座玩家列表
    self:addModuleEvent(LHD_ET.BR_QUERY_PLAYER_LIST_CLICK, handler(self,self.queryPlayerListReq))
    --请求下注
    self:addModuleEvent(LHD_ET.NET_FOLLOW_REQ, handler(self,self.handlerFollowReq))
    --请求坐下
    self:addModuleEvent(LHD_ET.NET_AUTO_SIT_DOWN_REQ, handler(self,self.handlerSitdownReq))
    --请求站起
    self:addModuleEvent(LHD_ET.NET_AUTO_SIT_UP_REQ, handler(self,self.handlerSitupReq))
    --显示积分
    self:addModuleEvent(ET.BR_JIFEN_EVT,handler(self,self.handlerShowJiFen))
    --点击退出按钮
    self:addModuleEvent(LHD_ET.GAME_LHD_EXIT_EVENT,handler(self,self.handlerExitCall))
    --打开玩家个人信息
    self:addModuleEvent(LHD_ET.GAME_SHOW_USER_INFO, handler(self,self.handlerShowUserInfo))
    --隐身状态更改广播
    --self:addModuleEvent(LHD_ET.PROFILE_CHANGE_BRGAME_EVT, handler(self, self.processProfileChanged))

    --以下是服务器主动下发事件
    --结局通知 CMD:3018
    self:addModuleEvent(LHD_ET.BR_NET_EVENT_GAME_OVER, handler(self,self.handlerGameOverNtf))
    --可以开始下注通知 CMD:3017
    self:addModuleEvent(LHD_ET.BR_NET_EVENT_BET_START, handler(self,self.handlerBetStartNtf))
    --坐下通知 CMD:3013
    self:addModuleEvent(LHD_ET.BR_NET_SIT_DOWN_EVT,handler(self,self.handlerProcessSitdownNtf))
    --站起通知 CMD:3241
    self:addModuleEvent(LHD_ET.BR_NET_SIT_UP_EVT,handler(self,self.handlerProcessSitupNtf))
    --上庄通知 CMD:3012
    self:addModuleEvent(LHD_ET.BR_NET_BANKER_CHANGE,handler(self,self.handlerProcessDelarSitdownNtf))
    --发牌通知 CMD:3016
    self:addModuleEvent(LHD_ET.BR_NET_OPEN_SHARE_CARDS_EVT,handler(self,self.handlerOpenSharedCardsNtf))
    --离桌通知 CMD:3010
    self:addModuleEvent(LHD_ET.BR_NET_EXIT_RESPONSE_EVT,handler(self,self.handlerExitGameNtf))
    --下庄通知 CMD:3021
    self:addModuleEvent(LHD_ET.BR_NET_EVENT_BANKER_EXIT,handler(self,self.handlerDelarLeaveNtf))
    --下注通知 CMD:3011
    self:addModuleEvent(LHD_ET.NET_BR_FOLLOW_BET_EVT,handler(self,self.handlerFllowNtf))
    --用户筹码变动通知 CMD:191
    self:addModuleEvent(ET.EVENT_USER_CHIPS_CHANGE, handler(self,self.handlerChipsChangedNtf))
    --停止下注阶段
    self:addModuleEvent(LHD_ET.LHD_EVENT_NO_BET_NTF, handler(self, self.handlerStopBetNtf))
    --刷新按钮
    self:addModuleEvent(LHD_ET.GAME_REFRESH_ADDBTN,handler(self,self.refreshAddBtn))
    --聊天
    self:addModuleEvent(LHD_ET.LHD_EVENT_DESK_CHAT,handler(self,self.chat))
    -- self:addModuleEvent(LHD_ET.LHD_WINMONEY, handler(self, self.winMoney))
end

function LHDGameController:removeModuleEvent()
    qf.event:removeEvent(ET.NET_CHAT_NOTICE_EVT)
    -- qf.event:removeEvent(LHD_ET.LHD_NET_INPUT_GAME_EVT)
    -- qf.event:removeEvent(LHD_ET.BR_NET_EVENT_GAME_OVER)
    -- qf.event:removeEvent(LHD_ET.BR_NET_EVENT_BET_START)
    -- qf.event:removeEvent(LHD_ET.BR_NET_SIT_DOWN_EVT)
    -- qf.event:removeEvent(LHD_ET.BR_NET_BANKER_CHANGE)
    -- qf.event:removeEvent(LHD_ET.BR_NET_OPEN_SHARE_CARDS_EVT)
    -- qf.event:removeEvent(LHD_ET.BR_NET_EXIT_RESPONSE_EVT)
    -- qf.event:removeEvent(LHD_ET.BR_NET_EVENT_BANKER_EXIT)
    -- qf.event:removeEvent(LHD_ET.NET_BR_FOLLOW_BET_EVT)
    -- qf.event:removeEvent(LHD_ET.LHD_EVENT_NO_BET_NTF)
    -- qf.event:removeEvent(LHD_ET.LHD_NET_UPDATE_TIME_EVT)
end

--[[--龙虎斗进桌]]
function LHDGameController:handlerInputGameNtf( args )
    Cache.user.meIndex = -1
    self.deskCache:updateCacheByInput(args.model)
    logi("===========>>>>>>>handlerInputGameNtf" .. pb.tostring(args.model))
    if self.view == nil then return end
    if args.model.op_uin == Cache.user.uin then
        self.desk_init_success = true
        self:initModuleEventAfterReady()
        Cache.lhdinfo:updateChipList(args.model)
        Cache.lhdDesk:setShangZhuangLimit(args.model)
        self.view:updatePoolCacheChips()
        self.view:updateByInput()
        local _delar = self.deskCache:getDelar()
        local bool = (_delar and _delar.uin) and true or false
        if not Cache.lhdDesk:checkXiaZhu() then
            qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP)
        end
    end
end


--龙虎斗断网处理
function LHDGameController:processNetDisconnect(paras)
    qf.event:dispatchEvent(LHD_ET.LHD_EXIT_REQ, {send=false})
end

--[[--龙虎斗场发牌]]
function LHDGameController:handlerOpenSharedCardsNtf(parameters)

    if self.view == nil then return end
    local m = parameters.model
    self.deskCache:updateShareCards(m)
end

--退桌操作. paras.send, 是否退出界面同时向服务器发送请求
function LHDGameController:processExitToOther(paras)
    local send = (paras == nil or paras.send == nil) and true or paras.send
    if send then
        local cmd = self.cmd_list.GAME_EXIT_REQ
        GameNet:send({
            cmd=cmd,body={deskid=paras.deskid},callback=function (rsp)
            loga("退桌协议"..rsp.ret)
                if rsp ~= nil  then 
                    if rsp.ret == 0 then
                        self:closeAndReturn(paras)
                    else
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
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

--关闭牌桌界面并返回上级模块
function LHDGameController:closeAndReturn()
    if self.view ~= nil then
        self:remove()  
        ModuleManager.lhdgame:remove()
        --ModuleManager.gameshall:initModuleEvent()
        --ModuleManager.lobby:remove()
        ModuleManager.gameshall:show({toChat = Cache.user.guidetochat})
        -- qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
    end
end

--结局通知
function LHDGameController:handlerGameOverNtf(paras)
    loga("handlerGameOverNtf")
    if self.view == nil then return end
    local m = paras.model
    printRspModel(m)
    self.deskCache:updateCacheByGameOver(m)
    local delayTime = 1
    self.view.deskCache:updateCanBeBet(false)
    self.view:delayRun(delayTime, function ( ... )
        self.view:updateByOver(delayTime)
        self.loadWinRank = false
    end)
end

--可以下注通知
function LHDGameController:handlerBetStartNtf(paras)
    loga("handlerBetStartNtf")
    if self.view == nil then return end
    self.deskCache:updateBetTiem(paras.model)
    self.view:sendCard()

    print("=================开始下注时间================" .. self.deskCache.bet_time)
    local bet_time = self.deskCache.bet_time -3
    self.view:delayRun(3, function ( ... )
        self.view:timeCountDown({time = bet_time,status = 2})
    end)
end

--请求上庄列表回调
function LHDGameController:queryBankerListReq()
    loga("queryBankerListReq")
    local _cmd = self.cmd_list.BANKER_LIST_REQ
    GameNet:send({cmd = _cmd, callback = function(rsp)
        if rsp.ret == 0 then 
            if self.view == nil then return end
            Cache.lhdinfo:updateDelarList(rsp.model)
            self.view:updateDelarList()
        end
    end})
end

--请求走势图
function LHDGameController:queryRecentTrendReq()
    loga("queryRecentTrendReq")
    local _cmd = self.cmd_list.RECENT_TREND_REQ
    GameNet:send({cmd = _cmd, callback = function(rsp)
        if rsp.ret == 0 then 
            if self.view == nil then return end
            Cache.lhdinfo:updateHistory(rsp.model)
            self.view:updateHistory()
        end
    end})
end

--请求24小时盈利排行榜
function LHDGameController:queryWinRankInfoReq()
    loga("queryWinRankInfoReq")
    local lhdHistory = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.lhdHistory)
    if not self.loadWinRank then
        self.loadWinRank = true
        GameNet:send({cmd = CMD.LHD_DAY_WIN_INFO, callback = function(rsp)
            loga(rsp.ret)
            if rsp.ret == 0 then
                if self.view == nil then return end
                Cache.lhdinfo:updateRankWin(rsp.model)
                if lhdHistory then
                    lhdHistory:refreshRankWin()
                end
            else
                self.loadWinRank = false
            end
        end})
    else
        if lhdHistory then
            lhdHistory:refreshRankWin()
        end
    end
end

function LHDGameController:remove(parameters)
    --qf.event:dispatchEvent(ET.MODULE_HIDE,"brgame")
    Cache.DeskAssemble:clearGameType()  --清除游戏类型
    self.deskCache:clearCache()           --清除百人场数据缓存
    MusicPlayer:setBgMusic()
    MusicPlayer:stopBackGround()
    -- MusicPlayer:backgroundSineIn()
    qf.event:dispatchEvent(ET.CHANGE_BORADCAST_DELAYTIME,{time = 0})
    if self.view then
        self.view:release()
    end
    LHDGameController.super.remove(self)
    PopupManager:removeAllPopup(parameters)   --移除所有弹窗
    self.desk_init_success = false
    qf.event:dispatchEvent(ET.MODULE_HIDE,"game_lhd")
end

--打开上庄列表弹窗
function LHDGameController:handlerShowDelarList(paras)
    loga("handlerShowDelarList")
    if self.view == nil then return end
    self.view:showDelarList(paras.isExit)
end

--请求上庄
function LHDGameController:handlerBeDelarRequest(paras)
    loga("handlerBeDelarRequest")
    local _cmd = self.cmd_list.BANKER_APPLY_REQ
    GameNet:send({cmd = _cmd, callback = function(rsp)
        qf.event:dispatchEvent(LHD_ET.BR_QUERY_BANKER_LIST_CLICK)
        if rsp.ret == 0 then
        elseif rsp.ret == 3 then
            local minGold = Cache.packetInfo:getProMoney(self.deskCache.min_banker)
            local errorTip = string.format(LHD_Games_txt.br_delar_seatdown_error, Util:getFormatString(minGold), Cache.packetInfo:getShowUnit())
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = errorTip})
            qf.platform:umengStatistics({umeng_key = "EndQuickSaleOpen"})
            --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {gold=50000000, ref=UserActionPos.BR_DEALER_LACK})
            qf.event:dispatchEvent(ET.SHOP)
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end

--请求下庄
function LHDGameController:handlerQuitDelarRequest(paras)
    loga("handlerQuitDelarRequest")
    local _cmd = self.cmd_list.BANKER_EXIT_REQ
    GameNet:send({cmd = _cmd, callback = function(rsp) 
        qf.event:dispatchEvent(LHD_ET.BR_QUERY_BANKER_LIST_CLICK)
        if rsp.ret == 0 then
            local content = self.deskCache.stage == 2 and LHD_Games_txt.br_delarlist_exit_tip or LHD_Games_txt.br_delarlist_exit_tip2
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=content})
        elseif rsp.ret == -1 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=LHD_Games_txt.br_delarlist_exit_tip3})
        end
    end})
end

--请求无座玩家列表
function LHDGameController:queryPlayerListReq()
    loga("queryPlayerListReq")
    local _cmd = self.cmd_list.PLAYER_LIST_REQ
    GameNet:send({cmd = _cmd, callback = function(rsp)
        if rsp.ret == 0 then 
            if self.view == nil then return end
            Cache.lhdinfo:updateOthers(rsp.model)
            self.view:updateBrPerson()
        end
    end})
end

--下注
function LHDGameController:handlerFollowReq(paras)
    loga("handlerFollowReq")
    if self.view == nil then return end
    if paras.value == nil or paras.value == 0 then return end
    local _cmd = self.cmd_list.GAME_FOLLOW_REQ
    GameNet:send({
        cmd=_cmd,body={chips=paras.value,section = paras.index},callback=function (rsp)
            if rsp.ret == 0 and self.view then
                self.view:chipsToPool({user = "myself",value = Cache.packetInfo:getProMoney(paras.value), index = paras.index, ismyself = true})
            end

            if rsp.ret == 5 then
                local _users = self.deskCache:getUserList()
                --自己金币大于等于50  与小于 50 提示不同
                if _users and _users[Cache.user.uin] and _users[Cache.user.uin].chips >= Cache.lhdDesk.min_bet_carry  then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_bet_error3,time = 2})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_bet_error1,time = 2})
                end
            elseif rsp.ret == 25 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_bet_error2,time = 2})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
    end
    })
end

--请求坐下
function LHDGameController:handlerSitdownReq(paras)
    loga("handlerSitdownReq")

    local cmd = self.cmd_list.SIT_DOWN_REQ
    GameNet:send({
        cmd=cmd,body={seatid = paras.index},callback=function (rsp)
			--预防多次点击坐下位置后，依然弹出商店界面

			local curSitter = self.view._rightUsers[paras.index]
			local curSitIsSeat = curSitter.isSeat
			if curSitIsSeat then return end
	
            if rsp.ret == 0 then
                if self.view == nil then return end
            elseif rsp.ret == 3 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_seatdown_error})
                qf.platform:umengStatistics({umeng_key = "QuickSale1Open"})
                --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {gold=100000, ref=UserActionPos.BR_SIT_LACK})
                qf.event:dispatchEvent(ET.SHOP)
            elseif rsp.ret == 2015 then
                if not Cache.packetInfo:isShangjiaBao() then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                    return 
                end
                local tips = Util:getReviewStatus() and GameTxt.string_room_limit_7 or GameTxt.string_room_limit_6
                qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = Cache.Config._errorMsg[rsp.ret] .. tips, confirmCallBack = function ( ... )
                    -- 发送退桌
                    if Util:getReviewStatus() then
                        qf.event:dispatchEvent(ET.SHOP)
                    else
                        qf.event:dispatchEvent(LHD_ET.GAME_LHD_EXIT_EVENT, {guidetochat = true})
                    end
                end})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        end
    })
end

function LHDGameController:handlerSitupReq(paras)
    local cmd = self.cmd_list.SIT_UP_REQ
    GameNet:send({
        --uin
        cmd=cmd,body={uin = paras.uin},callback=function (rsp)
            if rsp.ret == 0 then
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        end
    })
end

--显示积分
function LHDGameController:handlerShowJiFen(paras)
    loga("handlerShowJiFen")
    if not self.view or tolua.isnull(self.view) then return end
    if paras == nil or paras.score == nil then return end
    self.view:showJiFen(paras.score)
end

--显示帮助界面
function LHDGameController:handlerShowHelp()
    loga("handlerShowHelp")
    if not self.view or tolua.isnull(self.view) then return end

    self.view:showHelpView()
end

--点击了退出按钮
function LHDGameController:handlerExitCall(paras)
    loga("handlerExitCall")
    if not self.view or tolua.isnull(self.view) then return end
    if paras then
        Cache.user.guidetochat = paras.guidetochat
    end
    self.view:exitCall(paras)
end

--打开玩家信息
function LHDGameController:handlerShowUserInfo(paras)
    loga("handlerShowUserInfo")
    if not self.view or tolua.isnull(self.view) then return end
    if paras == nil or paras.uin == nil then return end
    qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{uin = paras.uin, type = Cache.DeskAssemble:getGameType(), defaultImg = paras.defaultImg,showGold = paras.showGold,showGoldTxt = paras.showGoldTxt or ""})
end

--玩家信息改变
function LHDGameController:processProfileChanged( model )
    loga("processProfileChanged")
    if not model or not model.uin then return end   
    if self.view == nil then return end

    --更改牌桌上的用户昵称和头像
    self.deskCache:updateProfile(model)
    local user = self.view:getBetUserByUin(model.uin)
    local u = self.view.chipsUser[user]

    if u and not tolua.isnull(u) then
        u:updateHead()
    end

    if model.uin == Cache.user.uin then
        local real_my = self.view.chipsUser.realself
        real_my:updateHead()
    end
end

--[[--百人场服务端通知 某人坐下了]]
function LHDGameController:handlerProcessSitdownNtf(parameters)
    loga("handlerProcessSitdownNtf")
    if self.view == nil then return end
    local m = parameters.model
    loga("handlerProcessSitdownNtf")
    self.deskCache:updateCacheBySeatDown(m)
    self.view:someoneSitdown(m.op_uin)
    if m.op_uin ~= Cache.user.uin then MusicPlayer:playMyEffect("TASK_FINISH") end
end

--[[--百人场服务端通知 某人站起了]]
function LHDGameController:handlerProcessSitupNtf(parameters)
    if self.view == nil then return end
    local m = parameters.model
    self.deskCache:updateCacheBySeatUp(m)
    self.view:someoneStand(m.op_user.uin)
end

--[[--百人场服务端通知上庄]]
function LHDGameController:handlerProcessDelarSitdownNtf(parameters)
    loga("handlerProcessDelarSitdownNtf")
    if self.view == nil then return end
    local m = parameters.model
    self.view:someoneStand(m.op_uin)
    self.deskCache:updateUser(m, true)
    self.view:delarSitdown()
    -- self.view:updateTipsPanelByDelar(true)
end

--[[--百人场服务端通知 某个用户站起]]
function LHDGameController:handlerExitGameNtf(paras)
    loga("handlerExitGameNtf")
    if self.view == nil then return end
    local m = paras.model
    self.view:someoneStand(m.op_user.uin)
    if m.op_user.uin == Cache.user.uin then
        self.view:hideChat()
    end
end

--[[--百人场服务端通知 有人下庄]]
function LHDGameController:handlerDelarLeaveNtf(paras)
    loga("handlerDelarLeaveNtf")
    if self.view == nil then return end
    local m = paras.model
    self.view:delarlLeave()
    
    local someone = self.deskCache:getDelar()
    if someone.uin == Cache.user.uin then
        self.view:hideChat()
    end
    -- self.view:updateTipsPanelByDelar(false)
end

--百人场通知某个用户跟注了 服务器每隔一段时间发送而来的通知
function LHDGameController:handlerFllowNtf(paras)
    loga("handlerFllowNtf")
    --logd("百人场下注通知-->"..pb.tostring(paras.model),self.TAG)
    local m = paras.model
    self.deskCache:updateByBrFllow(m)
    self.deskCache:setUpdateByFollowFlag(true)
    if self.view == nil then return end
    local count_chips = 1 --当前玩家该轮下注同一筹码的数量
    local bet_area_chips_num = 0 --下注区域的筹码数量
    for i = 1 ,m.bet_info:len() do
        local allInfo = m.bet_info:get(i)
        local uin = allInfo.uin
        local user = self.view:getBetUserByUin(uin)

        local user_data = self.deskCache:getUserByUin(uin)
        local counter = user_data.counter

        for index,chipsInfo in pairs(counter) do
            for chips,count in pairs(chipsInfo) do
                if (uin == Cache.user.uin and m.bet_type ~= 1) or uin ~= Cache.user.uin then
                    count_chips = 1
                    bet_area_chips_num = self.view:getChipsNum(index)
                    --只对无座玩家有效
                    --当前下注区域超过50个筹码后，对于新下注的筹码进行合并，每10个合成一个大筹码
                    --剩余的筹码数再除以2进行精简

                    if uin == -1 and bet_area_chips_num >= 50 and count >= 10 and chips <= 1000000 then
                        count_chips =math.floor(count/10)*10 + math.floor(math.mod(count,10)/2) + 1
                        for i=1,math.floor(count/10) do
                            local delay = user == "other" and math.random(1, 3)*3/10 or 0.01
                            performWithDelay(self.view, function ( ... )
                                self.view:chipsToPool({user = user,value = Cache.packetInfo:getProMoney(chips*10),index = index,no_action = uin == Cache.user.uin, is_bet = true})
                            end, delay)
                        end
                    end
                    --零头筹码下注
                    for k = count_chips, count do
                        local delay = user == "other" and  math.random(1, 3)*3/10 or 0.01
                        performWithDelay(self.view, function ( ... )
                            self.view:chipsToPool({user = user,value = Cache.packetInfo:getProMoney(chips),index = index,no_action = uin == Cache.user.uin, is_bet = true})
                        end, delay)
                    end
                    
                end
            end
        end
    end
    -- self:memoryCollect()
end

function LHDGameController:memoryCollect()
    if collectgarbage("count") > 350000 then
        loga(string.format("内存占用已接近临界值：%s", collectgarbage("count")))
        collectgarbage("collect")
        loga("内存清理成功")
    end
end

function LHDGameController:getBrUserByCache(uin)
    if not self.view or tolua.isnull(self.view) then return end
    if uin == nil or self.view.chipsUser == nil then return nil,nil end
    local user = self.view:getBetUserByUin(uin)
    return self.view.chipsUser[user],user
end

--用户筹码变动通知
function LHDGameController:handlerChipsChangedNtf(rsp)
    loga("handlerChipsChangedNtf ")
    if self.view then 
        self.view:someChipsChange(rsp.model)
        qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP)
    end
end

--通知停止下注阶段
function LHDGameController:handlerStopBetNtf( args )
    loga("handlerStopBetNtf")
    if not self.view or tolua.isnull(self.view) then return end
    -- 延迟1s，留给飘筹码动画时间
    self.view.deskCache:updateCanBeBet(false)
    self.view:delayRun(1, function ( ... )
        self.view:stopBetTime()
    end)
end

function LHDGameController:hideTopLHAnimation( ... )
    if not self.view or tolua.isnull(self.view) then return end
    self.view:hideTopLHAnimation()
end

function LHDGameController:refreshAddBtn()
    self.view:refreshAddBtn()
end

function LHDGameController:chipsPoolShowWinResult(winIndex)
    self.view:chipsPoolShowWinResult(winIndex)
end

--[[聊天相关 start]]
function LHDGameController:chat(paras) 
    logd("== ="..pb.tostring(paras.model),self.TAG)
    if self.view == nil or tolua.isnull(self.view) then return end
    self.view:chat(paras.model)
end

-- function LHDGameController:winMoney(paras)
--     if self.view == nil then return end
--     self.view:playWinmoney(paras)
-- end

function LHDGameController:test()
    logd("!@#!@#!@#!@#!")
    self.view:test()
end

return LHDGameController