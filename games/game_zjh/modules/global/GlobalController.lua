local GlobalController = class("GlobalController",qf.controller)
GlobalController.TAG = "GlobalController"

local globalView = import(".GlobalView")



function GlobalController:ctor(parameters)
	self.super.ctor(self)
end

function GlobalController:initModuleEvent()
     --显示用户信息
    self:addModuleEvent(Zjh_ET.GAME_SHOW_USER_INFO, handler(self,self.processUserInfoShow))

end




function GlobalController:removeModuleEvent()
end

function GlobalController:initGlobalEvent() 
   qf.event:addEvent(Zjh_ET.RE_QUIT,handler(self,self.reQuitRoom))
   qf.event:addEvent(Zjh_ET.GAME_QUIT_KICK,handler(self,self.processHandlegamequit))
   qf.event:addEvent(Zjh_ET.GAME_Standup,handler(self,self.processHandlegameStandup))
   qf.event:addEvent(Zjh_ET.NO_GOLD,handler(self,self.NO_GOLD))
   qf.event:addEvent(Zjh_ET.CHANGE_TABLE,handler(self,self.changetable))
   qf.event:addEvent(Zjh_ET.SEND_LOGIN_PRO,handler(self,self.SEND_LOGIN_PRO))
end

function GlobalController:changetable()--换桌
    -- body
    local cache_desk = Cache.DeskAssemble:getCache()
    local deskid = checkint(cache_desk.deskid)
    local roomid = checkint(cache_desk.roomid)
    local Config = Cache.zhajinhuaconfig.zhajinhua_room
    local paras = {
                    uin    = Cache.user.uin,
                    room_id=roomid,
                    desk_id=deskid 
            }
    --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
    GameNet:send({cmd=Zjh_CMD.CHANGE_TABLE,body=paras,timeout=5,callback=function(rsp)
            qf.event:dispatchEvent(Zjh_ET.CHUOHE_CLOSE)
            Cache.zjhdesk:clear()
            if rsp.ret == 36 then
                --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end

            if rsp.ret ~= 0 then
                --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                ModuleManager:removeExistView()
                ModuleManager.zjhhall:show()

                if rsp.ret==3 then
                    qf.event:dispatchEvent(Zjh_ET.NO_GOLD,{roomid=roomid})
                end

                return
            end



            ModuleManager:removeExistView()
            -- ModuleManager.login:remove()
            
            ModuleManager.zjhgame:show({roomid=roomid})            
          
            --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})



    end})
end

function GlobalController:NO_GOLD(paras)
    -- body
    ---------破产现在只跳商城------------
    qf.event:dispatchEvent(ET.MESSAGE_BOX, 
    {
        desc = GameTxt.no_gold_tips, 
        cbOk = function ( ... )
        qf.event:dispatchEvent(ET.SHOP) --这里需要加一个弹窗提示
        end
    })
end

--换桌
function GlobalController:SEND_LOGIN_PRO()
  -- body
    local cache_desk = Cache.DeskAssemble:getCache()
    local deskid = checkint(cache_desk.deskid)
    local roomid = checkint(cache_desk.roomid)



  local paras = {
                    roomid=roomid,
                    src_deskid = 0,
                    dst_desk_id=0,
                    password="",
                    enter_source=1,
                    new_desk=0,
                    just_view=0,
                    name="",
                    must_spend=0,
                    last_time=0,
                    buyin_limit_multi=0,
                    hot_version = GAME_VERSION_CODE,
            }
            --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
            GameNet:send({cmd=CMD.INPUT,body=paras,wait=true,timeout=5,callback=function(rsp)
                if rsp.ret == 36 then
                    --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.OREADY_GAME})
                    return
                end

                if rsp.ret ~= 0 then    
                    return
                end

                local game_type = Cache.DeskAssemble:getGameType()

                if  game_type == GAME_NIU_ZHA then
                    ModuleManager:removeExistView()
                    ModuleManager.niuniugame:show()
                end

                if  game_type == GAME_NIU_KAN then
                    ModuleManager:removeExistView()
                    ModuleManager.login:remove()
                    ModuleManager.kancontroller:show()
                end

                --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})

            end})
end


function GlobalController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_HIDE,"zjhglobal")
    local view = globalView.new()
    return view
end

--长时间没操作被提出
function GlobalController:processHandlegamequit(paras)
    
    if paras.method == "show" then --展示被踢了界面
        self.view:showGamequit(paras)
    elseif paras.method == "hide" then --隐藏被踢了界面
        self.view:hideGamequit()
        if Cache.zjhdesk.WINTYPE>0 then
            if Cache.zjhdesk.WINTYPE==1 then
                qf.platform:umengStatistics({umeng_key="Three_wins"})--点击上报
            elseif Cache.zjhdesk.WINTYPE==2 then
                qf.platform:umengStatistics({umeng_key="Five_wins"})--点击上报
            else 
                qf.platform:umengStatistics({umeng_key="Ten_wins"})--点击上报
            end
            qf.event:dispatchEvent(ET.GLOBAL_HANDLE_WINNINGSTREAK,{method="show",winnum=Cache.zjhdesk.WINTYPE})
        end
        Cache.zjhdesk.WINNUM=0
        Cache.zjhdesk.WINTYPE=0
    end
end

--站起
function GlobalController:processHandlegameStandup(paras)
    
    if paras.method == "show" then --展示被踢了界面
        self.view:showGameStandup(paras)
    elseif paras.method == "hide" then --隐藏被踢了界面
        self.view:hideGameStandup()
    end
end


--请求退出房间
function GlobalController:reQuitRoom()
	GameNet:send({cmd=CMD.EXIT,body={deskid=Cache.zjhdesk.deskid}})
end




function GlobalController:processUserInfoShow(paras)
    if self.view == nil then return end
    if paras == nil or paras.uin == nil then return end
    if paras.uin == Cache.user.uin then
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{uin=Cache.user.uin,localinfo=paras.localinfo})
    else
        local user
        user = Cache.zjhdesk:getUserByUin(paras.uin)
        --if user ~= nil then
            if paras.face then
                qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{
                    uin = paras.uin,
                    type = JDC_MATCHE_TYPE, 
                    hide_enabled = true, 
                    hide_nick = paras.nick or (user and user.nick),
                    face=paras.face,
                    localinfo = paras.localinfo 
                })
            else
                qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{
                    uin = paras.uin,
                    type = JDC_MATCHE_TYPE, 
                    hide_enabled = true, 
                    hide_nick = paras.nick or (user and user.nick),
                    localinfo = paras.localinfo 
                })
            end
        --end
    end 
end


return GlobalController