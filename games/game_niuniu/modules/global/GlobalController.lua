local GlobalController = class("GlobalController",qf.controller)
GlobalController.TAG = "GlobalController"

local globalView = import(".GlobalView")



function GlobalController:ctor(parameters)
	self.super.ctor(self)
end

function GlobalController:initModuleEvent()
     --显示用户信息
    self:addModuleEvent(Niuniu_ET.GAME_SHOW_USER_INFO, handler(self,self.processUserInfoShow))
end

function GlobalController:removeModuleEvent()

end

function GlobalController:initGlobalEvent() 
   qf.event:addEvent(Niuniu_ET.GAME_QUIT_KICK,handler(self,self.processHandlegamequit))
   qf.event:addEvent(Niuniu_ET.RE_QUIT,handler(self,self.reQuitRoom))
   qf.event:addEvent(Niuniu_ET.SEND_LOGIN_PRO,handler(self,self.SEND_LOGIN_PRO))
   qf.event:addEvent(Niuniu_ET.CHANGE_TABLE,handler(self,self.CHANGE_TABLE))
   qf.event:addEvent(Niuniu_ET.NO_GOLD,handler(self,self.NO_GOLD))

end


function GlobalController:NO_GOLD(paras)
    -- body
    qf.event:dispatchEvent(ET.MESSAGE_BOX, 
    {
        desc = GameTxt.no_gold_tips, 
        cbOk = function ( ... )

            qf.event:dispatchEvent(ET.SHOP)
        end
    })
end

function GlobalController:CHANGE_TABLE()
    -- body
    local cache_desk = Cache.DeskAssemble:getCache()
    local deskid = checkint(cache_desk.deskid)
    local roomid = checkint(cache_desk.roomid)

    local paras = {
                    uin    = Cache.user.uin,
                    room_id=roomid,
                    desk_id=deskid 
            }

    GameNet:send({cmd=Niuniu_CMD.CHANGE_TABLE,body=paras,timeout=5,callback=function(rsp)
            loga("rsp.retrsp.retrsp.retrsp.retrsp.retrsp.retrsp.ret:"..rsp.ret)
            qf.event:dispatchEvent(Niuniu_ET.CHUOHE_CLOSE)
            if rsp.ret == 36 then
                --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end

            if rsp.ret ~= 0 then    
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                -- ModuleManager:removeExistView()
                -- ModuleManager.niuniuhall:show()

                local openErji
                if roomid >=30101 and  roomid <=30200 then
                    openErji = "kanpai"
                end
                
                ModuleManager.niuniuhall:openErji({kind=openErji})
                -- qf.event:dispatchEvent(Niuniu_ET.NO_GOLD,{roomid=roomid})
                return
            end

            Cache.kandesk:clear()

            local game_type = Cache.DeskAssemble:getGameType()
            if  game_type == GAME_NIU_KAN then
                ModuleManager:removeExistView()
                ModuleManager.login:remove()
                ModuleManager.kancontroller:show()
            end

            --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})

    end})
end

function GlobalController:processUserInfoShow(paras)
    if self.view == nil then return end
    if paras == nil or paras.uin == nil then return end


    if paras.uin == Cache.user.uin then
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{uin=Cache.user.uin,localinfo=paras.localinfo})
    else
        local user
        if paras.type then
            user = Cache.kandesk:getUserByUin(paras.uin)
        else
            user = Cache.kandesk:getUserByUin(paras.uin)
        end
        
        if user ~= nil then
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{
                uin = paras.uin,
                type = JDC_MATCHE_TYPE, 
                hide_enabled = true, 
                hide_nick = Util:showUserName(paras.nick or user.nick),
                localinfo = paras.localinfo
            })
        end
    end 
end


--换桌
function GlobalController:SEND_LOGIN_PRO()
  -- body
    local cache_desk = Cache.DeskAssemble:getCache()
    local deskid = checkint(cache_desk.deskid)
    local roomid = checkint(cache_desk.roomid)

    local event_id

    local Config 
    local limit 

    if roomid >=30101 and  roomid <=30200 then
        Config      = Cache.kanconfig.bull_classic_room
        event_id    = Niuniu_ET.KAN_NET_INPUT_REQ
        limit    = Cache.kanconfig.classic_limitest
    end

    if Cache.user.gold < Cache.packetInfo:getProMoney(limit) then qf.event:dispatchEvent(Niuniu_ET.NO_GOLD,{roomid = roomid})  return end

    if Cache.user.gold >= Cache.packetInfo:getProMoney(Config[roomid].enter_limit_low)  and Cache.user.gold <= Cache.packetInfo:getProMoney(Config[roomid].enter_limit_high)  then
        qf.event:dispatchEvent(event_id,{roomid = roomid,deskid=deskid})
    else
        qf.event:dispatchEvent(event_id,{roomid = roomid,deskid=0,enter_source=101})
    end
end


function GlobalController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_HIDE,"niuniuglobal")
    local view = globalView.new()
    return view
end

--长时间没操作被提出
function GlobalController:processHandlegamequit(paras)
    self:showWinningStreak()
    if paras.method == "show" then --展示被踢了界面
        self.view:showGamequit(paras)
    elseif paras.method == "hide" then --隐藏被踢了界面
        self.view:hideGamequit()
    end
end

function GlobalController:showWinningStreak()
    -- body
    if Cache.kandesk.WINTYPE>0 then
        if Cache.kandesk.WINTYPE==1 then
            qf.platform:umengStatistics({umeng_key="Three_wins"})--点击上报
        elseif Cache.kandesk.WINTYPE==2 then
            qf.platform:umengStatistics({umeng_key="Five_wins"})--点击上报
        else 
            qf.platform:umengStatistics({umeng_key="Ten_wins"})--点击上报
        end
        qf.event:dispatchEvent(ET.GLOBAL_HANDLE_WINNINGSTREAK,{method="show",winnum=Cache.kandesk.WINTYPE})
    end
    Cache.kandesk.WINTYPE=0
    Cache.kandesk.WINNUM=0
end

--请求退出房间
function GlobalController:reQuitRoom(paras)
    if paras then
        Cache.user.guidetochat = paras.guideToChat
    end
	GameNet:send({cmd=CMD.EXIT,body={deskid=Cache.kandesk.deskid} , callback = function (rsp)
        if rsp.ret == 0 then
            -- 【注意】这里只是防止出现异常情况导致的退出失败
            if paras and paras.quitByUserFore then
                ModuleManager.kancontroller:KAN_SELF_QUIT({quitByUserFore = true})
            end
        end
    end})
end

return GlobalController