local KangameController = class("KangameController",qf.controller)
KangameController.TAG = "KangameController"


local gameView = import(".KangameView")


function KangameController:ctor(parameters)
    self.super.ctor(self)
    self.winSize = cc.Director:getInstance():getWinSize()
end


function KangameController:initView(parameters)
    Cache.DeskAssemble:setGameType(GAME_NIU_KAN) 
    MusicPlayer:stopBackGround()
    MusicPlayer:setBgMusic(GameRes.all_music.GMAE_COMMON_BGM)
    MusicPlayer:playMusic(GameRes.all_music.GMAE_COMMON_BGM, true)

    qf.event:dispatchEvent(ET.MODULE_SHOW,"kancontroller")
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_POS)

    local view = gameView.new(parameters)
    return view
end

function KangameController:initGlobalEvent()
	qf.event:addEvent(Niuniu_ET.KAN_ENTER_ROOM,handler(self,self.enterRoomsuc))
	qf.event:addEvent(Niuniu_ET.KAN_NET_INPUT_REQ,handler(self,self.KAN_NET_INPUT_REQ))
end

function KangameController:initModuleEvent()
    self:addModuleEvent(Niuniu_ET.KAN_QUIT,handler(self,self.KAN_QUIT))
    self:addModuleEvent(Niuniu_ET.KAN_GAME_START,handler(self,self.KAN_GAME_START))
    self:addModuleEvent(Niuniu_ET.KAN_USER_QIANG,handler(self,self.KAN_USER_QIANG))
    self:addModuleEvent(Niuniu_ET.KAN_ZHUANG,handler(self,self.KAN_ZHUANG))
    self:addModuleEvent(Niuniu_ET.USER_BASE,handler(self,self.USER_BASE))
    self:addModuleEvent(Niuniu_ET.USER_LAST_CARD,handler(self,self.USER_LAST_CARD))
    self:addModuleEvent(Niuniu_ET.SEND_CARD,handler(self,self.SEND_CARD))
    self:addModuleEvent(Niuniu_ET.KAN_GAME_OVER,handler(self,self.KAN_GAME_OVER))
    self:addModuleEvent(Niuniu_ET.KAN_UPDATE_USER,handler(self,self.KAN_UPDATE_USER))
    self:addModuleEvent(ET.NET_CHAT_NOTICE_EVT,handler(self,self.chat))
    self:addModuleEvent(Niuniu_ET.KAN_SELF_QUIT,handler(self,self.KAN_SELF_QUIT))

    --牌桌内任务更新
    -- self:addModuleEvent(ET.NET_DESK_TASK_EVT,handler(self,self.deskTaskRefreshNotify))
    self:addModuleEvent(Niuniu_ET.KAN_CALC_NOTICE,handler(self,self.KAN_CALC_NOTICE))
    self:addModuleEvent(ET.NET_CHANGEGOLD_EVT,handler(self,self.processGameChangeGoldEvt))
    self:addModuleEvent(Niuniu_ET.CHUOHE_CLOSE,handler(self,self.CHUOHE_CLOSE))
    self:addModuleEvent(Niuniu_ET.DESKINFO_CLOSE,handler(self,self.DESKINFO_CLOSE))
    --礼物通知
    -- self:addModuleEvent(ET.NET_RECEIVE_GIFT_EVT,handler(self,self.processReceiveGift))
    --有人发送加好友请求
    -- self:addModuleEvent(ET.NET_DESK_ASK_FEIEND_EVT,handler(self,self.processReceiveAskFriend))
    --发送加好友请求反馈
    -- self:addModuleEvent(ET.NET_DESK_ASK_FRIENDTIPS_EVT,handler(self,self.processReceiveFriendTips))
    --其他人金币变化
    self:addModuleEvent(ET.NET_EVENT_OTHER_GOLD_CHANGE,function(rsp)
        -- body
        if rsp.model and rsp.model.uin and Cache.kandesk._player_info[rsp.model.uin] then
            Cache.kandesk._player_info[rsp.model.uin].gold = rsp.model.gold
            if self.view._users[rsp.model.uin] then
                self.view._users[rsp.model.uin]:updateUserInfo()
            end
        end

        if rsp.model.uin==Cache.user.uin then
            Cache.user.gold=Cache.packetInfo:getProMoney(rsp.model.gold)
        end
    end)

    --站起
    self:addModuleEvent(Niuniu_ET.STANDUP, handler(self, self.standUp))
    --坐下失败
    self:addModuleEvent(Niuniu_ET.SITDOWN, handler(self, self.sitDown))
end

function KangameController:removeModuleEvent()
    qf.event:removeEvent(Niuniu_ET.KAN_QUIT)

    qf.event:removeEvent(Niuniu_ET.KAN_GAME_START)
    qf.event:removeEvent(Niuniu_ET.KAN_USER_QIANG)
    qf.event:removeEvent(Niuniu_ET.KAN_ZHUANG)
    qf.event:removeEvent(Niuniu_ET.USER_BASE)
    qf.event:removeEvent(Niuniu_ET.USER_LAST_CARD)
    qf.event:removeEvent(Niuniu_ET.SEND_CARD)
    qf.event:removeEvent(Niuniu_ET.KAN_GAME_OVER)
    qf.event:removeEvent(Niuniu_ET.KAN_UPDATE_USER)
    qf.event:removeEvent(ET.NET_CHAT_NOTICE_EVT)
    qf.event:removeEvent(Niuniu_ET.KAN_SELF_QUIT)
    -- qf.event:removeEvent(ET.NET_DESK_TASK_EVT)
    qf.event:removeEvent(Niuniu_ET.KAN_CALC_NOTICE)
    qf.event:removeEvent(Niuniu_ET.CHUOHE_CLOSE)
    qf.event:removeEvent(Niuniu_ET.DESKINFO_CLOSE)
    qf.event:removeEvent(ET.NET_CHANGEGOLD_EVT)
    qf.event:removeEvent(ET.UPDATE_PAY_LIBAO)
end

--关闭撮合中
function KangameController:CHUOHE_CLOSE()
    print("CHUOHE_CLOSE 关闭撮合中")
    -- body
    self.view:CHUOHE_CLOSE()
end

function KangameController:DESKINFO_CLOSE()
    print("DESKINFO_CLOSE 牌桌信息隐藏")
    -- body
    self.view:DESKINFO_CLOSE()
end

function KangameController:noGoldCheck( ... )
    if self.view then
        self.view:noGoldcheck()
    end
end

function KangameController:showOverLimitGoldPop( ... )
    if self.view then
        self.view:showOverLimitPop()
    end
end

--金币更改通知
function KangameController:processGameChangeGoldEvt(rsp)
    print("processGameChangeGoldEvt 金币更改通知")
    -- body
    if rsp.model == nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.gold) --rsp.gold 当前版本金币与法币1：1
    elseif rsp.model ~= nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.model.gold) --rsp.model.gold
    end
    if not Cache.kandesk._player_info[Cache.user.uin] then return end
    if not Cache.kandesk._player_info[Cache.user.uin].kick then
        Cache.kandesk._player_info[Cache.user.uin].gold = rsp.model.gold
        self.view._users[Cache.user.uin]:updateUserInfo()
    end
end

--算牌提示
function KangameController:KAN_CALC_NOTICE( paras )
    print("KAN_CALC_NOTICE 算牌提示")
    -- body
    self.view:KAN_CALC_NOTICE(paras)
end

--聊天
function  KangameController:chat(paras)
    print("聊天 CHAT 。。。。。。。。。。。。。。。。")

    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then  return end
    Cache.kandesk:updateCacheByChat(paras.model)
    self.view:chat(paras.model)
end

--退出事件
--[[
    1. 如果是游戏中退出，ret返回的是-1
]]
function KangameController:KAN_SELF_QUIT(paras)
    print("【KangameController】 玩家自己退出 ... ")
    if not self.view then return end
    if self.view._users[Cache.user.uin] then
        self.view._users[Cache.user.uin]:quitRoom({reason=5})
    end
    if paras and paras.quitByUserFore then
        self:outRoomWithGameNotGoing()
    end
    
    qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="hide"})
end

function KangameController:outRoomWithGameNotGoing( ... )
    ModuleManager:removeExistView()
    qf.event:dispatchEvent(Niuniu_ET.DESKINFO_CLOSE)
    Cache.kandesk:clear()
    if Cache.user.game_list_type==1 and Cache.user.downGameList[1].name=="2" then
        ModuleManager.gameshall:initModuleEvent()
        ModuleManager.gameshall:show()
        ModuleManager.gameshall:showReturnHallAni()
    else
        ModuleManager.niuniuhall:show()
        local openErji
        local roomid = Cache.kandesk.roomid
        if roomid >=30101 and  roomid <=30200 then
            openErji = "kanpai"
        end
        ModuleManager.niuniuhall:openErji({kind=openErji})
    end
end

--切换后台进行重连
function KangameController:enterRoomsuc(paras)
    if not self.view then return end
    print(" enterRoomsuc    切换后台进行重连 。。。。。。。。。。")
    -- printRspModel(paras.model)
    self.view:sitDown(paras.model.op_uin)
    Cache.kandesk:updateCacheByInput(paras.model)
    if paras.model.op_uin==Cache.user.uin then
        PopupManager:removeAllPopup()
        qf.event:dispatchEvent(ET.CLEARLISTPOPUP)
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
        loga(Cache.kandesk.roomid)
        local thisroom=Cache.kanconfig.bull_classic_room[Cache.kandesk.roomid]
        self.view:chageDeskInfo(thisroom)
        if test then
            test:clearNNInfo()
        end
    end
    self.view:enterDesk(paras.model)
end

--重连进入游戏
function KangameController:KAN_NET_INPUT_REQ(paras)
    print("KAN_NET_INPUT_REQ     重连进入游戏。。。。。。。")
	-- body
	Cache.kandesk.ISINPUTREQ=true
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
    }
    GameNet:send({cmd=CMD.INPUT,body=paras,wait=true,timeout=5,callback=function(rsp)

        if rsp.ret == 36 then
            --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.OREADY_GAME})
            return
        end
        
        if rsp.ret ~= 0 then   
            if rsp.ret==7 then
                local roomid = nil
              
                roomid = 30101
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
                }

                GameNet:send({cmd=CMD.INPUT,body=paras,timeout=5,callback=function(rsp)
                    
                    local game_conf =  {}

                    if roomid >=30101 and  roomid <=30200 then
                        game_conf = Cache.kanconfig.bull_classic_room
                    end



                    if rsp.ret == 36 then
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.OREADY_GAME})
                        return
                    end
                    if rsp.ret == 3 then    
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.buygooddialog_nomoney})
                        qf.event:dispatchEvent(ET.GLOBAL_SHOW_NEWBILLING,{limit=game_conf[roomid].enter_limit_low,ref=UserActionPos.PRIVATE_ROOM_SIT_LACK})
                        return
                    end
                    if rsp.ret ~= 0 then    
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret] or Niuniu_GameTxt.Kan_jin_fail})
                        return
                    end
                    if rsp.model.room_id >=30101 and  rsp.model.room_id <=30200 then
                        ModuleManager:removeExistView()
                        ModuleManager.login:remove()
                        ModuleManager.kancontroller:show()
                        self._changeci_kind = 2
                    end
                end})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end      
            return
        end
        
        ModuleManager:removeExistView()
		ModuleManager.login:remove()
        ModuleManager.niuniuglobal:show()
		ModuleManager.kancontroller:show({roomid = rsp.model.room_id})
    end})
    if test then
        test:clearNNInfo()
    end
end


--退出房间
function KangameController:KAN_QUIT(paras)
    print("【KangameController】 KAN_QUIT    退出房间 ")
    self.view:KAN_QUIT(paras.model)
    if paras.model.op_user.uin == Cache.user.uin then
        qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="hide"})
    end
end

--游戏开始
function KangameController:KAN_GAME_START(paras)
    print("KAN_GAME_START    游戏开始 。。。。。。。。。。。", socket.gettime())
    qf.event:dispatchEvent(ET.CHEST_START_TIME_BOX_TIMER)
    Cache.kandesk:updateCacheByGameStart(paras.model)
    self.view:KAN_GAME_START()
    print("sadfahskdf g !!!")
    if test then
        print("12312312就是啊上帝发誓")
        test:getNNPro(paras.model)
    end
end


--用户抢庄
function KangameController:KAN_USER_QIANG(paras)
    print("KAN_USER_QIANG    用户抢庄 。。。。。。。。。。。", socket.gettime(), "uin >>>>>>",  paras.model.uin)
    self.view:KAN_USER_QIANG(paras.model)
end


--广播庄
function KangameController:KAN_ZHUANG(paras)
    if not self.view then return end
    print("KAN_ZHUANG    广播庄 。。。。。。。。。。。", socket.gettime())
    Cache.kandesk:updateCacheByZhuang(paras.model)
    self.view:KAN_ZHUANG()
    if test then
        test:KanZhuangDel()
    end
end


--用户下分
function KangameController:USER_BASE(paras)
    print("USER_BASE    用户下分。。。。。。。。。 ", socket.gettime(), "uin >>>>>>>>>>>>>>", paras.model.uin)
    self.view:USER_BASE(paras.model)
end

--广播用户最后一张牌
function KangameController:USER_LAST_CARD(paras)
    print("USER_LAST_CARD 下发用户 最后一张牌。。。。。。。。。 ", socket.gettime())
    -- body
    Cache.kandesk:updateCacheByLastCard(paras.model)
    MusicPlayer:playMyEffectGames(Niuniu_Games_res,"COMPLETE_"..math.random(1,2))
    self.view:USER_LAST_CARD()
end


--玩家显示自己的手上的牌（出牌）
function KangameController:SEND_CARD(paras)
    print("SEND_CARD  玩家显示自己手上的牌 最后一张牌。。。。。。。。。 ", socket.gettime())
    self.view:SEND_CARD(paras.model)
end

--游戏结束
function KangameController:KAN_GAME_OVER( paras )
    print("KAN_GAME_OVER  游戏结束 播放结束动画", socket.gettime())
    Cache.kandesk:updateCacheByGameOver(paras.model)
    self.view:KAN_GAME_OVER()
    if test then
        -- body
        test:checkGameOver()
    end
end


--更新用户信息
function KangameController:KAN_UPDATE_USER( paras )
    print("KAN_UPDATE_USER  更新用户信息！！！ uin >>>>>>>", paras.uin)
    self.view:KAN_UPDATE_USER(paras)
end


--重新开始
function KangameController:startAgain()
    print("startAgain 重新开始 ！！！")
    -- body
    if tolua.isnull(self.view) ==  false then
        self.view:startAgain()
    end
end

function KangameController:remove()
    self.super.remove(self)
    Cache.DeskAssemble:clearGameType()  --清除游戏类型
    MusicPlayer:setBgMusic()
    MusicPlayer:stopBackGround()
    MusicPlayer:backgroundSineIn()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"kancontroller")
end

function KangameController:getUserByCache(uin)
    if self.view == nil then return nil ,nil end
    uin = uin or -1
    if uin == -1 then return nil,nil end
    local u = Cache.kandesk:getUserByUin(uin)
    if u == nil then return nil,nil end
    return self.view:getUser(uin),u
end

--站起
function KangameController:standUp(paras)
    local et = paras.model.error_type
    -- body
    if ((et == 0) or (et == 1)) then
        Cache.kandesk:updateCacheByStandUp(paras.model)
        -- 您长时间未操作，已站起。
        if ((et == 1) and (paras.model.uin == Cache.user.uin)) then
            --fix bug 此处进行强制站起操作 由于进行了延时处理 
            --[[
                此时如果用户又立马点击坐下的情况下 服务器实际上会将这名用户当作坐下
                然而 我进行了延时处理 此时可能会发生次序的上的错乱 最终造成这名玩家
                实际上已经坐下
            ]]--
            local time = 6 + Cache.kandesk.playerNum*1
            if self.view and self.view._users[Cache.user.uin] and self.view._users[Cache.user.uin]._info then
                self.view._users[Cache.user.uin]._info.quit=1
            end
            Scheduler:delayCall(time,function () 
                if self.view and self.view._users and self.view._users[Cache.user.uin] == nil then
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Niuniu_GameTxt.niu_txt_5})
                end
                local userinfo = self.view._users[Cache.user.uin]
                if userinfo and userinfo._info and userinfo._info.quit == 1 then
                    self.view:standUp(paras.model.uin)
                end
            end)
        else
            self.view:standUp(paras.model.uin)
        end
    else
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Niuniu_GameTxt.stand_fail_up})
    end
end

--坐下
function KangameController:sitDown(paras)
    print("服务器通知 》》》》》》》》》》》》》》》》 sitDown")
    -- if paras.model.error_type==0 then
    --     Cache.kandesk:updateCacheByStandUp(paras.model)
    --     self.view:standDown(paras.model.uin)
    -- else
    --     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Niuniu_GameTxt.stand_fail_up})
    -- end

    Cache.kandesk:updateCacheBySitDown(paras.model)
    if paras.model.error_type ~= 1 then
        self.view:sitDown(paras.model.uin)
    else
        if paras.model.uin == Cache.user.uin then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Niuniu_GameTxt.niu_txt_4})
        end
    end
end

return KangameController