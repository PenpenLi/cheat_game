local BaseHallView = require("src.modules.common.BaseHallView")
local HallView = class("HallView", BaseHallView)
HallView.TAG = "hallView"

function HallView:ctor(parameters)
    self.super.ctor(self, parameters)
    self:init(paras)
end

-- function HallView:getTableRes(data)
--     return GameRes.yellow_game_table
-- end

function HallView:getZhunRuFnt( ... )
    return GameRes.niuniu_hall_fnt
end

function HallView:getTableRes(data)

    local resGameTbl = {
        GameRes.blue_game_table_NN,
        GameRes.yellow_game_table
    }

    local roominfo = Cache.kanconfig:getRoom(data.room_id)
    local colorIdx = roominfo.room_color or GameConstants.NIUNIU_DESKCOLOR.BLUE
    return resGameTbl[colorIdx]
end

function HallView:getInRoom(paras)
    local game_conf = Cache.kanconfig.bull_classic_room_arr
    
    local cur_limit_gold = Cache.kanconfig:getLimitMoney(paras.room_id)
    if cur_limit_gold == nil then
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
            local game_conf =  Cache.kanconfig.bull_classic_room_arr

            if rsp.ret == 36 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end

            if rsp.ret == 3 then    
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end

            -- 用户未登陆
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

            ModuleManager:removeExistView()
            ModuleManager.login:remove()
            ModuleManager.kancontroller:show({roomid = paras.roomid})
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
        ModuleManager.niuniuhall:remove()
        ModuleManager.gameshall:initModuleEvent()
        ModuleManager.gameshall:show()
        ModuleManager.gameshall:showReturnHallAni()
    end
end

function HallView:openErji(parameters) 
    -- if parameters.kind == "kanpai" then
    --     -- self._changeci_kind = 2
    --     -- self.title:loadTexture(GameRes.gameHallTitle_DN,ccui.TextureResType.plistType)
    -- end
    -- self:initChangciInfoNew()
    -- self.buttonQuick:setVisible(true)
    -- Cache.Config:getOnlineNumber(handler(self, self.refreshOnline))
end

function HallView:test()
    local item = {
        base_chip       = 1,
        current_players = 0,
        desk_id         = 13185,
        group           = 1,
        max_num         = 5,
        min_num         = 2,
        orderWeight     = 0,
        room_id         = 30102,
        show_desk_id    = 117022,
        portrait_list = {
        }
    }
    local itemlist = {}
    local timeTbl = {
        8, 23, 8
    }
    return tableRes
end


function HallView:getTitleRes( ... )
    return GameRes.qznnTxt
end

function HallView:getGameType()
    return GAME_NIU_KAN
end

function HallView:refreshOneTable(nodeTbl, data)
    self.super.refreshOneTable(self, nodeTbl, data)
    nodeTbl:getChildByName("difen_txt"):setString(Niuniu_GameTxt.hall_limt_txt_2 .. "：" .. Util:getFormatString(data.base_chip) .. Cache.packetInfo:getShowUnit())
end

function HallView:getGameHallName()
    return "niuniuhall"
end

function HallView:getTitleName( ... )
    return "抢庄牛牛"
end

function HallView:getGameid()
    return 7
end

function HallView:getCurLimitGold(paras)
    local limitMin, cur_limit_gold_str = Cache.kanconfig:getLimitMoney(paras.room_id)
    return limitMin, cur_limit_gold_str
end


return HallView