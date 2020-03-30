local MammonInfo = class("MammonInfo")

MammonInfo.TAG = "MammonInfo"


function MammonInfo:ctor() 
    self:init()
end

--财神爷的倒计时 由这里进行记录 防止其他地方进行销毁
function MammonInfo:init() 
    self.cur_mammon_info = nil
    self.rest_time = nil
end

function MammonInfo:saveConfig(model)
    if model == nil then
        return
    end

    self.cur_mammon_info = {
        flag = model.flag,
        left = model.left_time
    }
    self.rest_time = self.cur_mammon_info.left
end

-- // 260 # 请求：用户购买财神爷
-- message UserBuyMammonReq{
-- optional int32 uin = 1;
-- optional int32 gold = 2;
-- }

-- // 261 # 请求：用户购买财神爷
-- message UserBuyMammonRsp{
-- optional int32 uin = 1;
-- optional int32 gold = 2;
-- optional bool ret = 3;  //是否成功 0 成功 1.输入的金币过少 2、金额不足 3、系统异常，请重试
-- optional int32 left_time = 4;   //剩余时间
-- }

function MammonInfo:requestBuyMammon(args, cb)
    GameNet:send({cmd=CMD.REQ_BUY_MAMMON, body={uin=uin, gold=Cache.packetInfo:getCProMoney(args.gold)},callback = function (rsp)
        -- body
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end

        local model = rsp.model
        local data = {}
        data.ret = model.ret
        data.ltime = model.left_time
        cb(data)
    end})
end


-- //262 # 请求：用户查询财神爷信息
-- message UserGetMammonInfoReq{
-- optional int32 uin = 1;
-- }

-- //263 # 返回：用户查询财神爷信息
-- message UserGetMammonInfoRsp{
-- optional int32 uin = 1;
-- optional bool flag = 2; //自己是否有财神爷道具
-- optional int32 left_time = 3;   //财神爷道具剩余时间
-- optional int32 min_money = 4;   //最低购买财神爷道具的金币
-- optional int32 remain_money = 5;    //最低剩余金币    
-- }

function MammonInfo:requestGetMammonInfo(args, cb)
    GameNet:send({cmd=CMD.REQ_MAMMON_INFO, body={uin=args.uin},callback = function (rsp)
        -- body
        if rsp.ret ~= 0 then
            if args.noPop == true then
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
            return
        end
        local attr = {
            "uin", "flag", "left_time", "min_money", "remain_money"
        }

        local model = rsp.model
        --printRspModel(model)
        local data = {}
        for i, v in ipairs(attr) do
            data[v] = model[v]
        end
        data["min_money"] = Cache.packetInfo:getProMoney(data["min_money"])
        data["remain_money"] = Cache.packetInfo:getProMoney(data["remain_money"])
        cb(data)
    end})
end

function MammonInfo:clear( ... )
    self:init()
end


return MammonInfo