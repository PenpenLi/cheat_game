local RetMoneyInfo = class("RetMoneyInfo")

RetMoneyInfo.TAG = "RetMoneyInfo"


function RetMoneyInfo:ctor() 
    self:init()
end

--财神爷的倒计时 由这里进行记录 防止其他地方进行销毁
function RetMoneyInfo:init() 

end

-- 请求周返现信息
-- 周返现返回
-- message ReturnProfitRsp{
--     optional int32 activity_login_days = 1; // 活动登录天数
--     optional int32 yesterday_profit=2; // 昨日收益
--     optional int32 profit_total = 3; // 累计收益
--     optional int32 wait_draw = 4; // 待兑换
--     optional int64 flow_today = 5; // 今日流水
--     optional int32 recharge_total = 6; // 用户总充值额
--     optional int32 real_login_days = 7; // 用户实际登录天数
-- }
function RetMoneyInfo:sendRetMoneyReq(cb)
    GameNet:send({cmd = CMD.RET_MONEY, callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end

        local data = self:resolveData(rsp.model)
        if cb then
            cb(data)
        end
    end})
end

--领取奖励
function RetMoneyInfo:sendRetExchangeReq(cb)
    GameNet:send({cmd = CMD.RET_EXCHANGE, callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_retmoney_7})
    end})
end


function RetMoneyInfo:resolveData(model)
    if model == nil then return end
    local items = {
        "activity_login_days", 
        "yesterday_profit", 
        "profit_total", 
        "wait_draw",
        "flow_today",
        "recharge_total",
        "real_login_days",
        "can_draw"
    }
    
    local item = {}
    for k,v in pairs(items) do
        item[v] = model[v]
    end
    return item
end

return RetMoneyInfo