local GameController = class("GameController",qf.controller)
GameController.TAG = "GameController"

local loga = print


GameController.xuepingId=nil
local gameView = import(".GameView")

function GameController:ctor(parameters)
    self.super.ctor(self)
    self.winSize = cc.Director:getInstance():getWinSize()
end


function GameController:remove()
    self.super.remove(self)
    Cache.DeskAssemble:clearGameType()  --清除游戏类型
    qf.event:dispatchEvent(ET.REMOVE_GIFTCAR_ANI) --删除小车入场动画
    if self.xuepingId ~= nil then
        MusicPlayer:_stopEffect(self.xuepingId)
        self.xuepingId=nil
    end
    MusicPlayer:setBgMusic()
    MusicPlayer:stopBackGround()
    MusicPlayer:backgroundSineIn()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"zjhgame")
end

function GameController:initView(parameters)
    if self.view then
        return
    end

    print("初始化 炸金花 initview")
    Cache.desk.is_play = 1
    Cache.DeskAssemble:setGameType(GAME_ZJH)
    MusicPlayer:stopBackGround()
    MusicPlayer:setBgMusic(GameRes.all_music.GMAE_COMMON_BGM)
    MusicPlayer:playMusic(GameRes.all_music.GMAE_COMMON_BGM, true)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"zjhgame")
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_POS)
    local view = gameView.new(parameters)
    return view
end


function GameController:initGlobalEvent()
    qf.event:addEvent(Zjh_ET.KAN_NET_INPUT_REQ,handler(self,self.KAN_NET_INPUT_REQ))
end

function GameController:noGoldCheck( ... )
    if self.view then
        self.view:noGoldCheck()
    end
end


function GameController:initModuleEvent()
    if not self.view then
        return
    end

    self:addModuleEvent(Zjh_ET.ENTER_ROOM,handler(self,self.enterRoomsuc))
    self:addModuleEvent(Zjh_ET.QUIT_ROOM,handler(self,self.quitRoom))
    self:addModuleEvent(Zjh_ET.GAME_START,handler(self,self.gameStart))--游戏开始
    self:addModuleEvent(Zjh_ET.PLAYER_SEND_CARD,handler(self,self.sendCard))--发牌
    self:addModuleEvent(Zjh_ET.DESK_SHOW_INFO,handler(self,self.showDeskInfo))--显示桌面信息
    self:addModuleEvent(Zjh_ET.PLAYER_DIU_CHIP,handler(self,self.diuChip))--丢筹码
    self:addModuleEvent(Zjh_ET.USER_HANDLE_TURN,handler(self,self.userHandleTurn))--下一个到谁操作
    self:addModuleEvent(Zjh_ET.USER_FOLD,handler(self,self.userFold))--弃牌
    self:addModuleEvent(Zjh_ET.USER_RAISE,handler(self,self.userRaise))
    self:addModuleEvent(Zjh_ET.USER_CHECK,handler(self,self.userCheck))--看牌
    self:addModuleEvent(Zjh_ET.USER_COMPARE,handler(self,self.userCompare))
    self:addModuleEvent(Zjh_ET.HIDE_ZHEZHAO,handler(self,self.unmaskLayer))
    self:addModuleEvent(Zjh_ET.GAME_END,handler(self,self.gameEnd))
    self:addModuleEvent(Zjh_ET.LIGHT_CARD,handler(self,self.lightCard))
--    self:addModuleEvent(Zjh_ET.FIRE,handler(self,self.fireFuc))
--    self:addModuleEvent(Zjh_ET.UNFIRE,handler(self,self.unfire))
    self:addModuleEvent(ET.NET_CHAT_NOTICE_EVT,handler(self,self.chat))
    -- self:addModuleEvent(Zjh_ET.DASHANG_RSP,handler(self,self.DASHANG_RSP))
    -- self:addModuleEvent(Zjh_ET.BEAUTYNPCSPEAK,handler(self,self.BeautyNpcSpeak))--美女进入荷官说话
    self:addModuleEvent(Zjh_ET.USER_HANDLE_TURN_NOTIMER,handler(self,self.userHandleTurnNoTimer))
    self:addModuleEvent(Zjh_ET.PLAYER_SHOW_ROUND_CHIPS,handler(self,self.showChipAndGold))
    self:addModuleEvent(Zjh_ET.USER_COMPARE_ALL,handler(self,self.userCompareAll))
    self:addModuleEvent(Zjh_ET.CHUOHE_CLOSE,handler(self,self.CHUOHE_CLOSE))
--    self:addModuleEvent(Zjh_ET.RECONNECT_FIRE,handler(self,self.RECONNECT_FIRE))
    --坐下失败
    self:addModuleEvent(Zjh_ET.SITDOWN, handler(self, self.sitDown))
    --自动坐下
    self:addModuleEvent(Zjh_ET.AUTO_SIT_WAIT_NUM_NTF, handler(self, self.autoSitWaitNum))
    --站起
    self:addModuleEvent(Zjh_ET.STANDUP, handler(self, self.standUp))
    self:addModuleEvent(ET.NET_CHANGEGOLD_EVT,handler(self,self.processGameChangeGoldEvt))
    self:addModuleEvent(ET.NET_EVENT_OTHER_GOLD_CHANGE,handler(self,self.processGameChangeOtherGoldEvt))
    --断网通知
    self:addModuleEvent(ET.NET_DISCONNECT_NOTIFY, handler(self, self.processNetDisconnect))
    --旁观列表
    -- self:addModuleEvent(Zjh_ET.LOOKUPLIST, handler(self, self.updateLookupList))
    --聊天红点
    -- self:addModuleEvent(Zjh_ET.CHATPOINT, handler(self, self.updateChatPoint))
    self:addModuleEvent(Zjh_ET.KICK_ADJUST,handler(self,self.gameQuitKick))
end

-- function GameController:updateChatPoint( ... )
--     -- body
--     self.view:updateChatPoint()
-- end

-- function GameController:updateLookupList( paras )
--     -- body
--     if Cache.zjhdesk.view_table == 1 then
--         Cache.zjhdesk:updateCacheByLookupList(paras.model)
--         self.view:updateLookupList()
--     end
-- end

function GameController:removeModuleEvent()
    qf.event:removeEvent(Zjh_ET.ENTER_ROOM)
    qf.event:removeEvent(Zjh_ET.QUIT_ROOM)
    qf.event:removeEvent(Zjh_ET.GAME_START)
    qf.event:removeEvent(Zjh_ET.PLAYER_SEND_CARD)
    qf.event:removeEvent(Zjh_ET.DESK_SHOW_INFO)
    qf.event:removeEvent(Zjh_ET.PLAYER_DIU_CHIP)
    qf.event:removeEvent(Zjh_ET.USER_HANDLE_TURN)
    qf.event:removeEvent(Zjh_ET.USER_FOLD)
    qf.event:removeEvent(Zjh_ET.USER_RAISE)
    qf.event:removeEvent(Zjh_ET.USER_CHECK)
    qf.event:removeEvent(Zjh_ET.USER_COMPARE)
    qf.event:removeEvent(Zjh_ET.HIDE_ZHEZHAO)
    qf.event:removeEvent(Zjh_ET.GAME_END)
    qf.event:removeEvent(Zjh_ET.LIGHT_CARD)
    qf.event:removeEvent(Zjh_ET.FIRE)
    qf.event:removeEvent(Zjh_ET.CHUOHE_CLOSE)
    qf.event:removeEvent(Zjh_ET.RECONNECT_FIRE)
    qf.event:removeEvent(ET.NET_CHANGEGOLD_EVT)
    qf.event:removeEvent(ET.UPDATE_PAY_LIBAO)
    qf.event:removeEvent(Zjh_ET.BEAUTYNPCSPEAK)
end

--站起
function GameController:standUp(paras)
    print("服务器通知 》》》》》》》》》》》》》》》》 standUp")
    printRspModel(paras.model)
    local et = paras.model.error_type
    -- body
    if ((et == 0) or (et == 1)) then
        -- 您长时间未操作，已站起。
        if ((et == 1) and (paras.model.uin == Cache.user.uin)) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "您长时间未操作，已站起。"})
        end
        
        if paras.model.uin == Cache.user.uin then
            qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP, {showTxt = GameTxt.showInsufficientTxt})
        end

        self.view:standUpShowCard(paras.model.uin)
        Cache.zjhdesk:updateCacheByStandUp(paras.model)
        self.view:standUp(paras.model.uin)
    else
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Zjh_GameTxt.stand_fail_up})
    end
end

--坐下失败
function GameController:autoSitWaitNum(paras)
    -- body
    Cache.zjhdesk:updateCacheByAutoSitWaitNum(paras.model)
    -- self.view:autoSitWaitNum()
end

--自动坐下
function GameController:sitDown(paras)
    print("服务器通知 坐下》》》》》》》》》》》》》》》》 standUp")

    printRspModel(paras.model)
    print(">>>>>>error_type!!!", error_type)
    print("自动坐下")

    Cache.zjhdesk:updateCacheBySitDown(paras.model)
    if paras.model.error_type~=1 then
        self.view:sitDown(paras.model.uin)
    else
        print(">>>>>>>>>>>>> uin ", paras.model.uin)
        print("Cahce.user.uin ", Cache.user.uin)
        if paras.model.uin == Cache.user.uin then
            print("++++++++++++++++ 》》》》》》》》》》》》》》》》》")
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "坐下失败"})
        end
    end
    -- self.view:autoSitWaitNum()
end

--金币更改
function GameController:processGameChangeGoldEvt(rsp)
    -- body
    loga("金币更改"..os.date("%c"))
    print("服务器通知 》》》》》》》》》》》》》》》》 金币更改")
    if rsp.model == nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.gold) --rsp.gold 当前版本，金币与法币1：1
    elseif rsp.model ~= nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.model.gold) --rsp.model.gold
    end

    if self.view == nil then return end
    if Cache.zjhdesk._player_info[Cache.user.uin] and self.view._users[Cache.user.uin] then
        Cache.zjhdesk._player_info[Cache.user.uin].gold = Cache.packetInfo:getCProMoney(Cache.user.gold)
        self.view._users[Cache.user.uin]:showChipAndGold()
    end
end

--金币更改
function GameController:processGameChangeOtherGoldEvt(rsp)
    print("服务器通知 》》》》》》》》》》》》》》》》 他人金币更改")
    -- body
    loga("他人金币更改"..os.date("%c"))
    if self.view == nil then return end

    if rsp.model and rsp.model.uin and Cache.zjhdesk._player_info[rsp.model.uin] and self.view._users[rsp.model.uin] then
        Cache.zjhdesk._player_info[rsp.model.uin].gold = rsp.model.gold
        self.view._users[rsp.model.uin]:showChipAndGold()
    end
    if rsp.model.uin==Cache.user.uin then
        --Cache.user.gold=rsp.model.gold
        Cache.user.gold=Cache.packetInfo:getProMoney(rsp.model.gold)
        loga(Cache.user.gold)
    end
end

--全场比牌
function GameController:userCompareAll(paras)
    if self.view == nil then return end
    self.view:removeTimer()
    print("服务端通知   》》》》》》》》》》》》》》 全场比牌操作 。。。。")
    Cache.zjhdesk:updateCacheByCompareNoLimit(paras.model)
    if Cache.zjhdesk.allcom >= 0 then
        self.view:showTips(Zjh_GameTxt.Game_compare_all)
        Scheduler:delayCall(2,function ()
            -- body
            if self and tolua.isnull(self.view) == false then
                 self.view:userComp(Cache.zjhdesk.win_uin,Cache.zjhdesk.lost_uin)
            end
        end)
        
    end
end

--断网通知
function GameController:processNetDisconnect(paras)
    loga("断网通知"..os.date("%c"))
    qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)--删除快捷聊天
    qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)--删除互动表情
end

--断线重连点火
function GameController:RECONNECT_FIRE()
    if self.view == nil then return end
    local paras = {}
    --MusicPlayer:playMusic(Zjh_Games_res.all_music.XUEPING,true)
    print("RECONNECT_FIRE 断线重连点火 。。。。")
    print("服务器通知 》》》》》》》》》》》》》》》》 断线重连点火")
    loga("Cache.zjhdesk.rush_uinCache.zjhdesk.rush_uinCache.zjhdesk.rush_uinCache.zjhdesk.rush_uinCache.zjhdesk.rush_uin:"..Cache.zjhdesk.rush_uin)
    paras.uin  = Cache.zjhdesk.rush_uin
    if not self.view._users[Cache.zjhdesk.rush_uin] then return end
    if self.xuepingId==nil then
        self.xuepingId=MusicPlayer:_playEffect(Zjh_Games_res.all_music.XUEPING,true)
    end
    self.view:fire(paras)
end


--开始
function  GameController:showStart()
    if self.view == nil then return end
    Cache.zjhdesk.status = -1
    self.view:setStartBtnVis(true)
    self.view:showTips(Zjh_GameTxt.Game_has_quit)
    self.view:showStart()
    self.view:showALLSitDownStatus(false)
end

function GameController:CHUOHE_CLOSE()
    if self.view == nil then return end
    print("关闭撮合中 CHUOHE_CLOSE 。。。。。。。。。。。。")
    -- body
    self.view:CHUOHE_CLOSE()
end


function GameController:unfire(paras)
    loga("火拼结束GameController:unfire"..os.date("%c"))
    if self.view == nil then return end
    -- body
    --MusicPlayer:stopMusic(true)
    print("unfire 熄火 。。。。。。。。。。。。。。。。。")
    if self.xuepingId ~= nil then
        MusicPlayer:_stopEffect(self.xuepingId)
        self.xuepingId=nil
    end
    --------------
    if not self.view.animation_layout then
        self.view:initAnimation()
    end
    ---------------
    local kuang_fire = self.view.animation_layout:getChildByName("kuang_fire")
    if kuang_fire  then
        kuang_fire:removeFromParent()
    end

    local all_fire = self.view.animation_layout:getChildByName("all_fire")
    if all_fire  then
        all_fire:removeFromParent()
    end

end

--聊天
function  GameController:chat(paras)
    if not true then  return end
    if self.view == nil then return end
    print("chat 聊天 。。。。。。。。。。。。。。。。。")
    Cache.zjhdesk:updateCacheByChat(paras.model)
    self.view:chat(paras.model)
end


function GameController:fireFuc(paras)
    loga("火拼GameController:fireFuc"..os.date("%c"))
    if self.view == nil then return end
    -- body
    if paras.model.entry_type ~= 0 then qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = paras.model.error_msg})  return end
    self.view:removeTimer()
    -- MusicPlayer:playMyEffectGames(Zjh_Games_res,"DIU_CHIPS")
    MusicPlayer:playMyEffectGames(Zjh_Games_res,"XUEPING_"..self:getSexByCache(paras.model.uin))
    -- MusicPlayer:playMusic(Zjh_Games_res.all_music.XUEPING,true)
    if self.xuepingId==nil then
        self.xuepingId=MusicPlayer:_playEffect(Zjh_Games_res.all_music.XUEPING,true)
    end
    Cache.zjhdesk:updateCacheByUserFire(paras.model)

    self.view:userRaise(paras.model)
    self.view:fire(paras.model)

    qf.event:dispatchEvent(Zjh_ET.USER_HANDLE_TURN)

    qf.event:dispatchEvent(Zjh_ET.DESK_SHOW_INFO)

end


--显示玩家下注数量
function GameController:showChipAndGold(model)
    print("显示玩家下注数量 showChipAndGold 。。。。。。。。。。。。。")
    local user = model.user
    user:showChipAndGold()
end


function GameController:lightCard(paras)
    loga("服务端通知 》》》》》》》》》》》》》 亮牌GameController:lightCard"..os.date("%c"))
    if self.view == nil then return end
    MusicPlayer:playMyEffectGames(Zjh_Games_res,"LIANGPAI")
    Cache.zjhdesk:updateCacheByLightcard(paras.model)
    self.view:lightCard(paras.model)
end

--game over
function GameController:gameEnd(paras)
    loga("服务端通知 》》》》》》》》》》》》》 游戏结束GameController:gameEnd"..os.date("%c"))
    if self.view == nil then return end
    MusicPlayer:playMyEffectGames(Zjh_Games_res,"COLLECT")
    qf.event:dispatchEvent(Zjh_ET.UNFIRE)
    Cache.zjhdesk:updateCacheByGameover(paras.model)
    self.view:removeTimer()
    self.view:gameEnd()
    
    self._time_clear = Scheduler:delayCall(Cache.zjhdesk.start_time-3,function()
        if Cache.zjhdesk.status==0 then
            Cache.zjhdesk:refresh()
            if self and tolua.isnull(self.view) == false then
                self.view:clear()
            end
        end
        qf.event:dispatchEvent(Zjh_ET.DESK_SHOW_INFO)
    end)

end

--delete遮罩
function GameController:unmaskLayer()
    print("delete 遮罩 。。。。。。。。。。。。。。。")
    if self.view == nil then return end
    self.view:unmaskLayer()
end

--用户比牌
function GameController:userCompare(paras)
    loga("服务端通知  用户比牌GameController:userCompare"..os.date("%c"))
    if self.view == nil then return end
    if self:getSexByCache(paras.model.uin) == 0 then
        MusicPlayer:playMyEffectGames(Zjh_Games_res,"BIPAI_"..self:getSexByCache(paras.model.uin).."_"..math.random(1,2))
    else
        MusicPlayer:playMyEffectGames(Zjh_Games_res,"BIPAI_"..self:getSexByCache(paras.model.uin))
    end
    
    self.view:removeTimer()
    Cache.zjhdesk:updateCacheByUsercompare(paras.model)

    local timer = 0
    if paras.model.user_pay_real_money > 0 then
        timer = 0.5
        self.view:userCompare(paras.model)
    end

    Scheduler:delayCall(timer,function ( ... )
        if self and tolua.isnull(self.view) == false then
            -- body
            if Cache.zjhdesk.iscompare then
                self.view:userComp(Cache.zjhdesk.win_uin,Cache.zjhdesk.lost_uin)
            else
                self.view:reconnectUsers()
            end
        end
    end)
    qf.event:dispatchEvent(Zjh_ET.USER_HANDLE_TURN)
    qf.event:dispatchEvent(Zjh_ET.DESK_SHOW_INFO)
end


--用户看牌
function GameController:userCheck(paras)
    loga("服务端通知 》》》》》》》》》》》 用户看牌GameController:userCheck"..os.date("%c"))
    if self.view == nil then return end
    MusicPlayer:playMyEffectGames(Zjh_Games_res,"KANPAI_"..self:getSexByCache(paras.model.uin))
    Cache.zjhdesk:updateCacheByUsercheck(paras.model)
    self.view:userCheck(paras.model)
end


--用户加注 用户跟注
function GameController:userRaise(paras)
    if self.view == nil then return end
    self.view:removeTimer()
    if Cache.zjhdesk.now_chips == Cache.packetInfo:getProMoney(paras.model.call_money) then
        MusicPlayer:playMyEffectGames(Zjh_Games_res,"CALL_"..self:getSexByCache(paras.model.uin).."_"..math.random(1,3))
    elseif Cache.zjhdesk.now_chips < Cache.packetInfo:getProMoney(paras.model.call_money) then
        MusicPlayer:playMyEffectGames(Zjh_Games_res,"JIAZHU_"..self:getSexByCache(paras.model.uin).."_"..math.random(1,4))
        self.view:showAddBetImg(paras.model)
    end
    Cache.zjhdesk:updateCacheByUserraisecall(paras.model)
    self.view:userRaise(paras.model)
    qf.event:dispatchEvent(Zjh_ET.USER_HANDLE_TURN)
    qf.event:dispatchEvent(Zjh_ET.DESK_SHOW_INFO)
end


--用户弃牌
function GameController:userFold(paras)
    if self.view == nil then return end
    local playerinfo = Cache.zjhdesk._player_info
    local uin = paras.model.uin
    -- print("uin >>>>>>>>>>>>>>>>>", uin)
    --当前仅当这个玩家在玩牌中的时候才进行弃牌通知
    -- print("playerinfo status", playerinfo[uin].status)
    if playerinfo[uin] and (playerinfo[uin].status == UserStatus.USER_STATE_INGAME) then
        if self:getSexByCache(paras.model.uin) == 0 then
            MusicPlayer:playMyEffectGames(Zjh_Games_res,"QIPAI_"..self:getSexByCache(paras.model.uin).."_"..math.random(1,3))
        else
            MusicPlayer:playMyEffectGames(Zjh_Games_res,"QIPAI_"..self:getSexByCache(paras.model.uin))
        end
        if paras.model.uin == Cache.zjhdesk.next_uin  and Cache.zjhdesk.next_uin > 0 then
            self.view:removeTimer()
            Cache.zjhdesk:updateCacheByUserflod(paras.model)
            qf.event:dispatchEvent(Zjh_ET.USER_HANDLE_TURN)
        else
            Cache.zjhdesk:updateCacheByUserflod(paras.model)
        end

        self.view:userFold(paras.model)
        qf.event:dispatchEvent(Zjh_ET.DESK_SHOW_INFO)
    end
end


--玩家丢筹码
function GameController:diuChip(model)
    local user = model.user
    local chip 
    if model.chip == nil then
        chip = Cache.zjhdesk._player_info[user._uin].call_money
        local rate = 1
        if  Cache.zjhdesk._player_info[user._uin].look == 1 then
            rate = 2
        end
        if chip==nil then return end
        chip = chip * rate
        model.chip = chip
    end
    
    model.base = Cache.zjhdesk.base_chip
    model.node = user
    user:diuChip(model)
end


--显示桌子的信息
function GameController:showDeskInfo()
    -- body
    if self.view == nil then return end
    self.view:showDeskInfo()
end


--牌局开始
function GameController:gameStart(paras)
    printRspModel(paras.model)
    if self.view == nil then return end
    Cache.zjhdesk:refresh()
    self.view:clear()
    qf.event:dispatchEvent(ET.CHEST_START_TIME_BOX_TIMER)
    
    Cache.zjhdesk:updateCacheByGamestart(paras.model)
    self.view:gameStart(paras.model)
    qf.event:dispatchEvent(Zjh_ET.DESK_SHOW_INFO)
end

function GameController:quitRoom(paras)
    if self.view == nil then return end
    -- body
    -- print("quitRoom 退出炸金花房间 。。。。。。。。。。。。。。。")
    Cache.zjhdesk.reason=paras.model.reason

    if Cache.zjhdesk.reason ~= 12 and Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 and paras.model.op_user.uin == Cache.user.uin then
        Cache.zjhdesk:updateCacheByUserquit(paras.model)
        Cache.zjhdesk:userQuit(paras.model)
        ModuleManager:removeExistView()
        Cache.zjhdesk:clear()
        if Cache.user.game_list_type==1 and Cache.user.downGameList[1].name=="1" or Cache.user.guidetochat then
            ModuleManager.gameshall:initModuleEvent()
            ModuleManager.gameshall:show({toChat = Cache.user.guidetochat})
            ModuleManager.gameshall:showReturnHallAni()
        else
            ModuleManager.zjhglobal:show()
            ModuleManager.zjhhall:show()
        end
        return
    end 

    if paras.model.op_user.uin == Cache.user.uin and Cache.zjhdesk.reason ~= 5 then
        local time = 1
        for k,v in pairs(Cache.zjhdesk._player_info) do
            if v.showcard==1 then
                time=3
                break
            end
        end

        print("time >>>>>>>>>>>>>>", time)
        print("reasone >>>>>>>>>", Cache.zjhdesk.reason)
        Scheduler:delayCall(time,function ()
            if self and tolua.isnull(self.view) == false then
                Cache.zjhdesk:updateCacheByUserquit(paras.model)
                self.view:quitRoom(paras.model.op_user.uin)
                
                if Cache.zjhdesk.reason == 11 then --站起
                    qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP, {showTxt = GameTxt.showInsufficientTxt})
                -- elseif Cache.zjhdesk.reason == 12 then --
                else
                    Cache.zjhdesk:userQuit(paras.model)
                end

                if paras.model.op_user.uin == Cache.user.uin then
                    --MusicPlayer:stopMusic(true)
                    if self.xuepingId ~= nil then
                        MusicPlayer:_stopEffect(self.xuepingId)
                        self.xuepingId=nil
                    end
                    qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
                    qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)
                    qf.event:dispatchEvent(Zjh_ET.GAME_QUIT_KICK,{method="hide"})
                end                
            end
        end)
    else
        Cache.zjhdesk:updateCacheByUserquit(paras.model)
        self.view:quitRoom(paras.model.op_user.uin)
        Cache.zjhdesk:userQuit(paras.model)

        if paras.model.op_user.uin == Cache.user.uin then
            if self.xuepingId ~= nil then
                MusicPlayer:_stopEffect(self.xuepingId)
                self.xuepingId=nil
            end
            --MusicPlayer:stopMusic(true)
            qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
            qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)
            qf.event:dispatchEvent(Zjh_ET.GAME_QUIT_KICK,{method="hide"})
        end
    end 
end

function GameController:processUserInfoShow(paras)
    if self.view == nil then return end
    if paras == nil or paras.uin == nil then return end

    print("processUserInfoShow 展示某玩家的个人信息 。。。。。。。。。")
    if paras.uin == Cache.user.uin then
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{uin=Cache.user.uin})
    else
        local user
        user = Cache.zjhdesk:getUserByUin(paras.uin)
        
        if user ~= nil then
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{
                uin = paras.uin,
                type = JDC_MATCHE_TYPE, 
                hide_enabled = true, 
                hide_nick = paras.nick or user.nick
            })
        end
    end 
end

--进入房间成功
function GameController:enterRoomsuc(paras)
    print("进入房间成功GameController:enterRoomsuc"..os.date("%c"))
    if self.view == nil then return end
    printRspModel(paras.model)
    --保存桌子信息
    self.view:sitDown(paras.model.op_uin)
    Cache.zjhdesk:updateCacheByInput(paras.model)  --进入房间刷新桌子里所有人的数据
    if paras.model.op_uin==Cache.user.uin then
        PopupManager:removeAllPopup()
        qf.event:dispatchEvent(ET.CLEARLISTPOPUP)
        --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
        local thisroom=Cache.zhajinhuaconfig.zhajinhua_room[Cache.zjhdesk.roomid]
        self.view:chageBgImg(thisroom)
        qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
        -- qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP)
    end
    --绘制桌面
    self.view:enterDesk(paras.model)
    logd("GameController:enterRoomsuc end "..os.clock())
end

--断线重连
function GameController:KAN_NET_INPUT_REQ(paras)
    loga("断线重连 炸金花 GameController:KAN_NET_INPUT_REQ    "..os.date("%c"))
    local paras = {
            roomid=paras.roomid,
            src_deskid = 0,
            dst_desk_id=paras.deskid ~= nil and paras.deskid or 0,
            password="",
            enter_source=paras.enter_source ~= nil and paras.enter_source or 1,
            new_desk=0,
            just_view=0,
            name="",
            must_spend=0,
            last_time=0,
            buyin_limit_multi=0,
            hot_version = GAME_VERSION_CODE,
    }
    GameNet:send({cmd=CMD.INPUT,body=paras,wait=false,timeout=5,callback=function(rsp)
        if rsp.ret ~= 0 then   
            --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
            if rsp.ret~=7 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
            if rsp.ret ==3 then
                qf.event:dispatchEvent(Zjh_ET.CHUOHE_CLOSE)
                qf.event:dispatchEvent(Zjh_ET.NO_GOLD,{roomid=paras.roomid,count=1})
            elseif rsp.ret==5 or rsp.ret==7 then
                local roomid = 30201
                local paras = {
                        roomid=roomid,
                        src_deskid = 0,
                        dst_desk_id=0,
                        password="",
                        enter_source=101,
                        new_desk=0,
                        just_view=0,
                        name="",
                        must_spend=0,
                        last_time=0,
                        buyin_limit_multi=0,
                        hot_version = GAME_VERSION_CODE,
                }

                GameNet:send({cmd=CMD.INPUT,body=paras,timeout=5,callback=function(rsp)
                    local game_conf =   Cache.zhajinhuaconfig.zhajinhua_room
                    if rsp.ret == 36 then
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.OREADY_GAME})
                        return
                    end
                    if rsp.ret == 3 then    
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.buygooddialog_nomoney})
                        qf.event:dispatchEvent(ET.GLOBAL_SHOW_NEWBILLING,{limit_low=game_conf[roomid].enter_limit_low,limit=game_conf[roomid].enter_limit_low,ref=UserActionPos.PRIVATE_ROOM_SIT_LACK})
                        return
                    end
                    if rsp.ret ~= 0 then 
                        loga(Util:getRandomMotto())
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = ache.Config._errorMsg[rsp.ret] or Zjh_GameTxt.Kan_jin_fail})
                        return
                    end
                    ModuleManager:removeExistView()
                    ModuleManager.zjhglobal:show()
                    ModuleManager.zjhgame:show({roomid=paras.roomid})
                    end})
            elseif rsp.ret==7 then
                loga("这货=7")
                qf.event:dispatchEvent(Zjh_ET.QUICKSTARTCLICK)
            end
            return
        end
        --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
        ModuleManager:removeExistView()
        ModuleManager.zjhglobal:show()
        ModuleManager.zjhgame:show({roomid=paras.roomid})
    end})
end



--玩家发牌
function GameController:sendCard(model)
    loga("服务端 》》》》》》》》》》》》》》 玩家发牌GameController:sendCard   。。。。。。。。。。。。。")
    local user = model.user
    user:sendCardAnim()
end



--到了该用户操作了
function GameController:userHandleTurn(paras)
    print("userHandleTurn 到用户操作了 。。。。。。。。。。。。。。")
    if self.view == nil then return end
    local timer = 0
    if paras then
        timer = paras.timer
    end
    self.view:userHandleTurn(timer) 
end


--到了该用户操作了
function GameController:userHandleTurnNoTimer(paras)
    if self.view == nil then return end
    local timer = 0
    if paras then
        timer = paras.timer
    end
    print("服务端通知 》》》》》》》》》》》》》》》》》 到用户操作")
    self.view:userHandleTurnNoTimer(timer) 
end


function GameController:getSexByCache(uin)
    if uin == -1 then return 0 end
    local u = Cache.zjhdesk:getUserByUin(uin)
    if u == nil then return 0 end

    local sex 
    sex = u.sex ==2 and 0 or u.sex
    return sex or 0
end

function GameController:getUserByCache(uin)
    if self.view == nil then return nil ,nil end
    
    uin = uin or -1
    if uin == -1 then return nil,nil end

    local u = Cache.zjhdesk:getUserByUin(uin)
    if u == nil then return nil,nil end
    return self.view:getUser(uin),u
end

function GameController:gameQuitKick()
    -- body
    if self.view then
        loga ("*******************")
        self.view:fullScreenAdaptive()
    end
end

return GameController
