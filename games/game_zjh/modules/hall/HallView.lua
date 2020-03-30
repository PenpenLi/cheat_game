local BaseHallView = require("src.modules.common.BaseHallView")
local HallView = class("HallView", BaseHallView)
HallView.TAG = "hallView"

function HallView:ctor(parameters)
    self.super.ctor(self, parameters)
    self:init(paras)
end

function HallView:getInRoom(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击炸金花入场"..paras.room_id) end

    local cur_limit_gold = Cache.zhajinhuaconfig:getLimitMoney(paras.room_id)
    if cur_limit_gold == nil then
        print("not find 准入金额！！！")
        return
    end
    
    self.roomid = paras.room_id
    local paras = {
        roomid=paras.room_id,
        src_deskid = 0,
        dst_desk_id=paras.desk_id,
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
    
    Util:delayRun(0.1,function ( ... )
        -- body
        GameNet:send({cmd=CMD.INPUT,body=paras,wait=true,timeout=5,callback=function(rsp)
            if rsp.ret~=0 then
                if tolua.isnull(self) then return end
                self:ifNeedReturnMainView()
            end

            print("rsp >>>>>>>>>>>>>>>>>>>", rsp.ret)
            loga("rsp.retrsp.retrsp.retrsp.retrsp.retrsp.ret:"..rsp.ret)
            local game_conf =  Cache.zhajinhuaconfig.zhajinhua_room
            if rsp.ret == 36 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end

            if rsp.ret == 3 then    
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})

                qf.event:dispatchEvent(ET.GLOBAL_SHOW_NEWBILLING,{limit_low=game_conf[roomid].enter_limit_low,limit=game_conf[self.roomid].payment_recommend,ref=UserActionPos.PRIVATE_ROOM_SIT_LACK})
                return
            end
            --用户未登陆
            if rsp.ret == 14 then
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                return
            end

            -- 桌子不存在，刷新桌子列表
            if rsp.ret == 20 then
                if not tolua.isnull(self) then
                    self:startRefreshDesk()
                end
            end

            if rsp.ret ~= 0 then    
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end
            ModuleManager.zjhhall:remove()
            ModuleManager.gameshall:remove()
            ModuleManager.zjhglobal:show()            
            ModuleManager.zjhgame:show({roomid=roomid})
            if Cache.user.gold < cur_limit_gold then
                if not Cache.packetInfo:isShangjiaBao() then
                    local tip = string.format(GameTxt.string_room_limit_1, Util:getFormatString(cur_limit_gold), Cache.packetInfo:getShowUnit())
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = tip})
                end
            end
        end})
    end)
end

function HallView:ifNeedReturnMainView(roomid)
    if Cache.user.game_list_type == 1 and Cache.user.downGameList[1].name == "3" and self.roomid >= 30001 and self.roomid <= 30100 
        or Cache.user.game_list_type == 1 and Cache.user.downGameList[1].name == "2" and self.roomid >= 30101 and self.roomid <= 30200
        then
        ModuleManager.zjhhall:remove()
        ModuleManager.gameshall:initModuleEvent()
        ModuleManager.gameshall:show()
        ModuleManager.gameshall:showReturnHallAni()
    end
end

function HallView:getTableRes(data)
    local resGameTbl = {
        GameRes.blue_game_table,
        GameRes.red_game_table
    }
    local roominfo = Cache.zhajinhuaconfig:getRoom(data.room_id)
    local colorIdx = roominfo.room_color or GameConstants.ZJH_DESKCOLOR.BLUE
    return resGameTbl[colorIdx]
end

function HallView:getGameType()
    return GAME_ZJH
end

function HallView:refreshOneTable(nodeTbl, data)
    self.super.refreshOneTable(self, nodeTbl, data)
    nodeTbl:getChildByName("difen_txt"):setString(Zjh_GameTxt.hall_limt_txt_2 .. "：" .. Util:getFormatString(data.base_chip))
end

function HallView:getTitleName()
    return "金三顺"
end

function HallView:getGameHallName()
    return "zjhhall"
end

function HallView:getGameid()
    return 8
end

function HallView:getCurLimitGold(paras)
    local limitMin, cur_limit_gold_str = Cache.zhajinhuaconfig:getLimitMoney(paras.room_id)
    return limitMin, cur_limit_gold_str
end

return HallView