--[[牌局记录]]
local GamesRecord = class("GamesRecord")

function GamesRecord:ctor()
    self.record_list = {}
    self.record_details = {}
end
--------------牌局记录------------
--更新牌局记录
function GamesRecord:updateRecordByInput(model)
    self.record_list = {}
    if model == nil then return end
    logd("牌局记录:\n"..pb.tostring(model))
    for i = 1 , model.record_list:len() do
        local record = model.record_list:get(i)
        self.record_list[i] = {}
        self.record_list[i].record_id = record.round_id         --牌局id
        self.record_list[i].timestamp = record.timestamp        --时间戳
        self.record_list[i].description = record.group_name     --牌局描述
        if Cache.texasConfig:isCustomizeRoom(record.room_id) == false then
            self.record_list[i].description = self.record_list[i].description .. "(" .. string.format(GameTxt.games_record_desk_player_num, record.seat_limit) .. ")"
        end
        self.record_list[i].small_blind = record.small_blind    --小盲
        self.record_list[i].big_blind = record.big_blind        --大盲
        self.record_list[i].must_spend = record.must_spend      --前注(必下)
        self.record_list[i].desk_id = record.desk_id            --牌桌id
        self.record_list[i].win_chips = record.win_chips        --赢取筹码
        self.record_list[i].cards = {}                          --手牌
        for j = 1, record.hold_cards:len() do
            self.record_list[i].cards[j] = record.hold_cards:get(j)
        end
    end
end

--获取牌局记录条数
function GamesRecord:getRecordCount()
    return #self.record_list
end

--通过排序index获取牌局记录
function GamesRecord:getRecordByIndex(index)
    return self.record_list[index]
end

--通过记录ID获取牌局记录
function GamesRecord:getRecordByRecordId(record_id)
    for i = 1, #self.record_list do
        local record = self.record_list[i]
        if record.record_id == record_id then
            return record
        end
    end
    return nil
end

--排序:按时间
function GamesRecord:sortRecordByTime()
    table.sort(self.record_list, function(a, b)
        return a.timestamp > b.timestamp
    end)
end
--排序:按盈利
function GamesRecord:sortRecordByWinchips()
    table.sort(self.record_list, function(a, b)
        return a.win_chips > b.win_chips
    end)
end

--------------记录详情------------
--更新记录详情
function GamesRecord:updateDetailsByInput(record_id, model)
    self.record_details[record_id] = {}
    self.record_details[record_id].share_cards = {}
    self.record_details[record_id].user_details = {}
    if record_id == nil or model == nil then return end
    logd("牌局详情: \n"..pb.tostring(model))
    
    local share_cards_save = false
    for i = 1, model.record_list:len() do
        local record = model.record_list:get(i)
        if share_cards_save == false then
            for j = 1, record.share_cards:len() do
                self.record_details[record_id].share_cards[j] = record.share_cards:get(j)       --公共牌
            end
            share_cards_save = true
        end
        self.record_details[record_id].user_details[i] = {}
        self.record_details[record_id].user_details[i].uin = record.uin     --uin
        self.record_details[record_id].user_details[i].nick = record.nick   --昵称
        self.record_details[record_id].user_details[i].sex = record.sex     --性别
        self.record_details[record_id].user_details[i].portrait = record.portrait       --头像
        self.record_details[record_id].user_details[i].give_up = (record.status ~= 0)   --是否弃牌/离桌/站起
        self.record_details[record_id].user_details[i].win_chips = record.win_chips     --盈利
        self.record_details[record_id].user_details[i].is_dealer = record.is_dealer     --是否是庄家
        self.record_details[record_id].user_details[i].hold_cards = {}                  --手牌
        for j = 1, record.hold_cards:len() do
            self.record_details[record_id].user_details[i].hold_cards[j] = record.hold_cards:get(j)
        end
        self.record_details[record_id].user_details[i].max_cards = {}                   --最大牌型
        for j = 1, record.max_cards:len() do
            self.record_details[record_id].user_details[i].max_cards[j] = record.max_cards:get(j)
        end
    end
end

--根据记录ID获取记录详情
function GamesRecord:getDetailByRecordId(record_id)
    if self.record_details == nil then return nil end
    return self.record_details[record_id]
end


return GamesRecord