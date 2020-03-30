local AgencyInfo = class("AgencyInfo")

AgencyInfo.TAG = "AgencyInfo"


function AgencyInfo:ctor() 
    self:init()
end

function AgencyInfo:init() 
    self.personalInfo = nil
end

function AgencyInfo:saveConfig(agencyInfo)
    self:setBindAgencyStatus(agencyInfo)
end

--检查是否已经绑定了代理
function AgencyInfo:checkBindAgency()
    if self._agencyInfo ==  0 or self._agencyInfo ==  "" then
        return false
    end
    return true
end

-- 更新自己代理信息
function AgencyInfo:updateAngencyPersonalInfo(data)
    if not data then return end
    local agencyData = {}
    agencyData.proxy_portrait = data.proxy_portrait
    agencyData.copy_writing = data.copy_writing
    agencyData.sex = data.sex
    agencyData.contactInfo = {}
    agencyData.uin = data.uin
    agencyData.nick = data.nick
    agencyData.welcome_words = data.welcome_words
    agencyData.sign_words = data.sign_words
    -- 这里处理下获取到代理信息后，重新刷新User
    Cache.user.invite_from = agencyData.uin
    for key,v in pairs(data) do
        local info = {}
        if string.find(key, "wx_id") ~= nil then
            info.cig = 1
        elseif string.find(key, "qq_id") ~= nil then
            info.cig = 2
        end
        if v ~= "" and info.cig then
            info.txt = v
            table.insert(agencyData.contactInfo, info)
        end
    end
    self.personalInfo = agencyData
    return self.personalInfo
end

--[[
    optional string portrait_url = 1;   // 头像url
    optional string service_nick = 2;   // 客服名字
    optional string service_content = 3;    // 活动文案
    optional int32 order_nums = 4;  // 月成交订单数量
    optional string welcome_words = 5;  // 欢迎语
]]
function AgencyInfo:updateServiceInfo(model)
    if not model then return nil end
    local fieldName = {
        "portrait_url",
        "service_nick",
        "service_content",
        "order_nums",
        "welcome_words"
    }
    local serviceInfo = {}
    for _,v in pairs(fieldName) do
        serviceInfo[v] = model[v]
    end
    return serviceInfo
end

function AgencyInfo:getServiceInfoByID(proxy_data_id, cb)
    GameNet:send({cmd = CMD.GET_PROXCY_SERVICE_INFO, body={proxy_id = Cache.user.invite_from, data_id = proxy_data_id}, callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret] or "获取信息失败，请重试！"})
            return
        end
        local data = self:updateServiceInfo(rsp.model)
        data.data_id = proxy_data_id
        if cb and type(cb) == "function" then
            cb(data)
        end
    end})
end

-- 获取自己代理信息
function AgencyInfo:getPersonalInfo( ... )
    return self.personalInfo
end

--设置绑定状态
function AgencyInfo:setBindAgencyStatus(info)
    self._agencyInfo = info
end

-- //707 # 请求：绑定代理
-- message BindProxyReq{
--     optional string promotion_code = 1;
-- }

-- //707 # 返回：绑定代理
-- message BindProxyRsp{

-- }

function AgencyInfo:requestBindAgency(args, cb)
    GameNet:send({cmd = CMD.BIND_AGENCY, body={promotion_code=args.procode}, callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        local data = self:updateAngencyInfo(rsp)
        if type(cb) == "function" then
            cb()
        end
    end})
end

-- //708 # 请求：获取代理信息
-- message QueryProxyListReq{
-- }

-- //708 # 返回：获取代理信息
-- message QueryProxyListRsp{
    -- optional string proxy_portrait = 1;	//代理头像
    -- optional string wx_id = 2;	//微信号
    -- optional string wx_id2 = 3;	//微信号2
    -- optional string copy_writing = 4; //文案
    -- optional int32 sex = 5; //性别
    -- optional string qq_id = 6;	//QQ号
    -- optional string qq_id2 = 7;	//QQ号2
-- }

function AgencyInfo:requestGetAgencyInfo(args, cb)
    GameNet:send({cmd = CMD.GET_AGENCY_INFO, callback= function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        local data = self:updateAngencyInfo(rsp)
        self:setAgencyDetailInfo(data)
        if type(cb) == "function" then
            cb(data)
        end
    end
    })
end

function AgencyInfo:updateAngencyInfo(rsp)
    local attr = {
        "proxy_portrait", "wx_id", "wx_id2", "copy_writing", "sex", "qq_id", "qq_id2", "uin" , "nick", "welcome_words", "sign_words"
    }
    
    local model = rsp.model
    if not model then return end
    local data = {}
    for i, v in ipairs(attr) do
        data[v] = model[v]
    end
    return self:updateAngencyPersonalInfo(data)
end

function AgencyInfo:getAgencyDetailInfo()
    return self._detailAgencyInfo
end

function AgencyInfo:setAgencyDetailInfo(data)
    self._detailAgencyInfo = data
end

--这个请求主要是针对于非代理在游戏中的时候 由后台将此号更改成为了代理
--服务器不主动发 所有由客户端根据错误码来判定此时是否是一个代理
--如果是得到自己是一个代理的情况下
function AgencyInfo:requestGetAgencyInfo2(args, cb)
    GameNet:send({cmd = CMD.GET_AGENCY_INFO, callback= function (rsp)
        --已经是代理了
        if rsp.ret == 2024 then
            Cache.user:setProxy(1)
            self:setBindAgencyStatus(1)
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        else --其他错误码不进行处理
            self:updateAngencyInfo(rsp)
        end
        if type(cb) == "function" then
            cb()
        end
    end
    })
end

return AgencyInfo