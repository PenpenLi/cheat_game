local M = class("NetDelayTool")

function M:ctor()
    self.heartCallBackCheckTime = 10
    self.heartBeatTimeoutCid = nil
    self.arrayDelay = {}
    self.sumDelay =  0
    self.lastNetInfo = {}
end

--开始计算延时
function M:init()
    self.arrayDelay = {}
    self.sid = 0
    self.sumDelay =  0
    self:stopHeartBeatTimeOutCheck()
    self:sendOneTest()
    local device = cc.Application:getInstance():getTargetPlatform()
    if device == cc.PLATFORM_OS_ANDROID and Util:checkWifiNetPackage() then
        qf.platform:setNetReceiverLuaCB({cb = function (jsonStr)
            local netInfo = qf.json.decode(jsonStr)
            self.lastNetInfo = netInfo
            qf.event:dispatchEvent(ET.REFRESH_NET_STRENGTH,  {netInfo = netInfo})
        end})
    end
end

function M:startHeartBeatTimeOutCheck( ... )
    self:stopHeartBeatTimeOutCheck()
    self.heartBeatTimeOutCid = Scheduler:delayCall(self.heartCallBackCheckTime, function ( ... )
        self:sendOneTest()
    end, true)
end

--[[
    关闭超时心跳检测
]]
function M:stopHeartBeatTimeOutCheck( ... )
    if self.heartBeatTimeOutCid then
        Scheduler:unschedule(self.heartBeatTimeOutCid)
        self.heartBeatTimeOutCid = nil
    end
end

function M:sendOneTest()
    if not self.sid then return end
    local sendTime = socket.gettime()
    self.sid = self.sid + 1
    GameNet:send({cmd = CMD.TEST_CONNECTION, callback = function (rsp)
        logi("rsp ret >>>", rsp.ret)
        local recvTime = socket.gettime()
        logi("收到recv test", self.sid, recvTime)
        self:update(recvTime, sendTime)
    end})
    self:startHeartBeatTimeOutCheck()
end

function M:update(recvTime, sendTime)
    logi("recvTime", recvTime)
    logi("sendTime", sendTime)
    local difftime = recvTime - sendTime
    local showDelayTime = math.ceil(difftime * 1000)
    logi("difftime>>>>>", difftime)
    logi("showDelayTime >>>>>>>>>>", showDelayTime .. "ms")
    self.arrayDelay[#self.arrayDelay+1] = showDelayTime
    self.sumDelay  = self.sumDelay + showDelayTime
    logi("平均延时", self.sumDelay /(#self.arrayDelay) .. "ms")
    self.lastShowDelayTime = showDelayTime
    qf.event:dispatchEvent(ET.REFRESH_NET_STRENGTH, {delayTime = showDelayTime})
end

--停止计算延时
function M:stop()
     self:stopHeartBeatTimeOutCheck()
end

function M:getLastShowDelayTime()
    return self.lastShowDelayTime
end

function M:getLastNetInfo()
    return self.lastNetInfo
end

NetDelayTool = M.new()