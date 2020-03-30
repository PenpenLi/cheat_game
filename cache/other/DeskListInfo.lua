local DeskListInfo = class("DeskListInfo")

DeskListInfo.TAG = "DeskListInfo"

function DeskListInfo:ctor() 
    self:init()
end

function DeskListInfo:init() 
end

function DeskListInfo:requestDeskListInfo(paras, cb)
    GameNet:send({cmd = CMD.GET_DESK_LIST_INFO, body = {game_id  = paras.game_id}, callback= function (rsp)
        if rsp.ret ~= 0 then
            if cb then
                cb()
            end
            return
        end
        local onlineInfo = {"room_id", "min_num", "max_num", "desk_id", "current_players", "base_chip", "show_desk_id"}
        local groupDetailInfo = {
            {"desks", "arr", onlineInfo}, 
            "group",
            "group_index"
        }

        local portraitinfo = {"uin", "portrait", "sex", "seat_id", "desk_id"}

        local protoTbl = {
            {"data", "arr", groupDetailInfo},
            {"portrait_list", "arr", portraitinfo}
        }

        --解析协议
        local rTbl = Util:resolveProto(protoTbl, rsp.model)

        local mpArr = {}
        for i, v in ipairs(rTbl.portrait_list) do
            if mpArr[v.desk_id] == nil then
                mpArr[v.desk_id] = {}
            end
            table.insert(mpArr[v.desk_id], v)
        end
        local mmData = {}
        for i, v in ipairs(rTbl.data) do
            local mmDesk = {}
            for j, v2 in ipairs(v.desks) do
                local tempV = v2
                tempV.portrait_list = mpArr[tempV.desk_id] or {}
                tempV.base_chip = Cache.packetInfo:getProMoney(tempV.base_chip)
                mmDesk[#mmDesk + 1] = tempV
            end
            mmData[#mmData + 1] = {
                group = v.group,
                group_index = v.group_index,
                desks = mmDesk
            }
        end
        table.sort(mmData, function (a, b)
            return a.group_index < b.group_index
        end)
        if cb then
            cb(mmData)
        end
    end})
end

function DeskListInfo:convertClientData(data)
    --分类排序
    local _data = {}
    for i, v in ipairs(data) do
        for j, v2 in ipairs(v.desks) do
            local temp = v2
            temp.group = v.group
            _data[#_data + 1] = temp
        end
    end
    return _data
end

function DeskListInfo:clear()
end

return DeskListInfo