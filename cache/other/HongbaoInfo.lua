local HongbaoInfo = class("HongbaoInfo")

HongbaoInfo.TAG = "HongbaoInfo"

function HongbaoInfo:ctor() 
    self:init()
end

function HongbaoInfo:init() 
    self.firstChargeInfo = {}
end

function HongbaoInfo:saveConfig(model)
end

--查询首充红包消息
function HongbaoInfo:queryFirstRecharge( callback )
    GameNet:send({cmd = CMD.QUERY_FIRST_RECHARGE, callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        local m = rsp.model
        local firstChargeInfo = {}
        firstChargeInfo.bet_gold = Cache.packetInfo:getProMoney(m.bet_gold)
        firstChargeInfo.wait_get_reward = Cache.packetInfo:getProMoney(m.wait_get_reward)
        firstChargeInfo.already_get_reward = Cache.packetInfo:getProMoney(m.already_get_reward)
        firstChargeInfo.is_recharge = m.is_recharge
        firstChargeInfo.total_not_get = Cache.packetInfo:getProMoney(m.total_not_get)
        callback(firstChargeInfo)
    end})
end

function HongbaoInfo:getFirstRecharge(callback)
    GameNet:send({cmd = CMD.GET_FIRST_RECHARGE, callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        local m = rsp.model
        local firstChargeInfo = {}
        firstChargeInfo.bet_gold = Cache.packetInfo:getProMoney(m.bet_gold)
        firstChargeInfo.wait_get_reward = Cache.packetInfo:getProMoney(m.wait_get_reward)
        firstChargeInfo.already_get_reward = Cache.packetInfo:getProMoney(m.already_get_reward)
        firstChargeInfo.get_reward_this_time = Cache.packetInfo:getProMoney(m.get_reward_this_time)
        firstChargeInfo.first_recharge_flag = m.first_recharge_flag
        firstChargeInfo.total_not_get = Cache.packetInfo:getProMoney(m.total_not_get)
        callback(firstChargeInfo)
    end})
end

return HongbaoInfo