local Jackpot = class("Jackpot")

Jackpot.reward_cardtype = {9, 8, 7}      --至尊牌型奖牌型
Jackpot.accident_cardtype = {8, 7, 20}   --至尊失手奖牌型

function Jackpot:ctor() 
    --self:test()
end

function Jackpot:updateRecord(which, model)
    self.my_record = {}
    self.all_record = {}
    self.my_br_record = {}
    self.all_br_record = {}
    if model == nil then return end

    if which == 1 then
        self:_updateRecord(model)
    elseif which == 2 then
        self:_updateBrRecord(model)
    end
end

function Jackpot:_updateRecord( model )
    --本人中奖记录
    self.my_record = {}
    self.my_record.hited_times = model.hited_times or 0
    self.my_record.total_amount = model.total_amount or 0
    --所有人中奖记录
    self.all_record = {}
    if model.records ~= nil then
        for i = 1 , model.records:len() do
            local record = model.records:get(i)
            local index = #self.all_record + 1
            self.all_record[index] = {}
            self.all_record[index].uin = record.uin
            self.all_record[index].nick = record.nick
            self.all_record[index].sex = record.sex
            self.all_record[index].amount = record.amount
            self.all_record[index].timestamp = record.timestamp
            self.all_record[index].portrait = record.portrait
            self.all_record[index].cards = {}
            if record.cards ~= nil then
                for j = 1 , record.cards:len() do
                    self.all_record[index].cards[j] = record.cards:get(j)
                end
            end
        end
    end

    --按时间排序
    table.sort(self.all_record,function (a,b)
        return a.timestamp > b.timestamp
    end)
end

function Jackpot:_updateBrRecord( model )
    --本人中奖记录
    self.my_br_record = {}
    self.my_br_record.hited_times = model.hited_times or 0
    self.my_br_record.total_amount = model.total_amount or 0
    --所有人中奖记录
    self.all_br_record = {}
    if model.records ~= nil then
        for i = 1 , model.records:len() do
            local record = model.records:get(i)
            local index = #self.all_br_record + 1
            self.all_br_record[index] = {}
            self.all_br_record[index].uin = record.uin
            self.all_br_record[index].nick = record.nick
            self.all_br_record[index].sex = record.sex
            self.all_br_record[index].amount = record.amount
            self.all_br_record[index].timestamp = record.timestamp
            self.all_br_record[index].portrait = record.portrait
            self.all_br_record[index].cards = {}
            if record.cards ~= nil then
                for j = 1 , record.cards:len() do
                    self.all_br_record[index].cards[j] = record.cards:get(j)
                end
            end
        end
    end
    --按时间排序
    table.sort(self.all_br_record,function (a,b)
        return a.timestamp > b.timestamp
    end)
end

--获取我的记录
function Jackpot:getMyRecord(which)
    if which == 1 then
        return self.my_record.hited_times, self.my_record.total_amount
    elseif which == 2 then
        return self.my_br_record.hited_times, self.my_br_record.total_amount
    else
        return 0, 0
    end
end

--获取全部记录条数
function Jackpot:getAllRecordNum(which)
    if which == 1 then
        return #self.all_record
    elseif which == 2 then
        return #self.all_br_record
    else
        return 0
    end
end

--获取单条记录
function Jackpot:getOneRecordByIndex(which, index)
    if (index < 1) or (index > self:getAllRecordNum(which)) then return nil end
    if which == 1 then
        return self.all_record[index]
    elseif which == 2 then
        return self.all_br_record[index]
    else
        return nil
    end
end

return Jackpot