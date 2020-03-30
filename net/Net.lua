
local adapter = import(".ETAdapter")
local pbadapter = import(".PBAdapter")
local Net = class("Net")

Net.TAG = "NET-UTIL"

local OPTIONAL_VAL = 1    --数值(optional int32,string...)
local OPTIONAL_MSG = 2    --结构(optional message)
local REPEATED_VAL = 3    --数值数组(repeated int32,string...)
local REPEATED_MSG = 4    --结构数组(repeated message)

function Net:ctor()

    --pb.import("texas_net.proto")

    self._ada = adapter.new()
    self._pbad = pbadapter.new()

    -- 每个address尝试连接几次
    self.tryTimesPerAddress = 3

    self.time_pause_net = 0 --游戏切入后台，网络被暂停的时间

    -- 连接失败的次数
    self.connectTryTimes = 0
    -- 地址列表
    self.addressList = {}
    -- 连接时间
    self.connectTime = 0
end

function Net:start(addressList)
    self.addressList = addressList
    -- 清除
    self.connectTryTimes = 0

    self:connect()
end

function Net:connect()
    if self:isConnected() then
        return true
    end
    if self.addressList == nil or #self.addressList == 0 then
        -- 内容为空
        return nil
    end

    -- lua 索引要+1的
    local addressIndex = math.floor(self.connectTryTimes / self.tryTimesPerAddress) + 1

    if addressIndex > #self.addressList then
        -- 说明已经超过最后的address了，要重新获取了
        return nil
    end

    -- 累加一次
    self.connectTryTimes = self.connectTryTimes + 1

    local address = self.addressList[addressIndex]
    local addressIP = Util:getDesDecryptString(address[1])
    local port = tonumber(Util:getDesDecryptString(address[2]))
    logd("connectTryTimes: " .. tostring(self.connectTryTimes), self.TAG)
    logd("addressIndex: " .. tostring(addressIndex) .. ", host: " .. addressIP .. ", port: " .. port , self.TAG)

    ferry.ScriptFerry:getInstance():init(addressIP, port)
    if not ferry.ScriptFerry:getInstance():isRunning() then
        ferry.ScriptFerry:getInstance():start()
    else
        ferry.ScriptFerry:getInstance():connect()
    end

    return address
end

function Net:clearTryTimesForCurrentAddress()
    -- 将针对当前地址的错误次数清零
    -- 当连接成功的时候，调用这个函数
    
    -- logd("connectTryTimes before: " .. tostring(self.connectTryTimes), self.TAG)
    self.connectTryTimes = math.floor(self.connectTryTimes / self.tryTimesPerAddress) * self.tryTimesPerAddress
    -- logd("connectTryTimes after: " .. tostring(self.connectTryTimes), self.TAG)
end

--[[--

]]
function Net:onMsg(paras)
    self._ada:praseMsg(self:unpackBox(paras))
end


--[[--
cmd = number
body = table
callback = function () end
timeout=0.5
penetrate=true
hanlder=nil
若有回调则不调用onmessage
否则传给onmessage
若发送的单向事件，不填回调，penetrate为false即可

wait  界面是否显示等待
txt 界面显示等待的文字
]]

function Net:send(paras)

    if paras.cmd == nil  then
        loge(" send cmd error  , args #1 cannot nil" , self.TAG)
    end

    local timeout = paras.timeout or 20
    local callback = paras.callback or nil
    local handler = paras.handler or nil
    local body = paras.body or nil
    local box = self:packBox({method="req",cmd=paras.cmd,body=body})
    if box == nil then
        return
    end
    local wait = paras.wait or false
    local txt = paras.txt or GameTxt.loadingGame

    if wait == true then qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=txt}) end
    ferry.ScriptFerry:getInstance():send(box,
        function(event)
            if wait == true then
                Util:delayRun(0.3, function ()
                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true}) 
                end)
            end
            if event:getWhat() == ferry.EventType.timeout or event:getWhat() == ferry.EventType.error then
                logd("  --- ferry.EventType.timeout or ferry.EventType.error --- ")
                if callback then callback({ret=NET_WORK_ERROR.TIMEOUT}) end
                logd("  --- call back ----- ")
            elseif event:getWhat() == ferry.EventType.recv then
                if (event:getBox() and callback) then
                    local unpackparas = self:unpackBox(event:getBox())
                    if unpackparas ~= nil then callback(unpackparas)
                    else logd(" error on reiv body " , self.TAG)
                    end
                end
            else
            --loge("----- unkown error ------ ")
            end
        end
        ,timeout,handler)
end

function Net:unpackBox(box)
    local ret = nil
    ret = {}
    ret.cmd = box:getCmd()
    ret.ret = box:getRet()
    if #box:getBody() == 0 then return ret end

    local flag = box:getFlag()
    local body = nil
    if flag == 1 then
        local mm = pb.new(self._pbad:getSignPBName())
        pb.parseFromString(mm,box:getBody())

        local needSign = UNITY_PAY_SECRET..mm.body
        function getHex(var)
            local ret = string.format("%X", var)
            if #ret == 1 then return "0"..ret
            else return ret end
        end

        local sign2 = QNative:shareInstance():md5(needSign)
        if mm.sign == sign2 then
            body = mm.body
        else
        end
    else
        body = box:getBody()
    end

    local pname = self._pbad:findPBNameByCmd({method="rsp",cmd=box:getCmd()})
    if pname == nil or body == nil then
        return nil
    end

    local model = pb.new(pname)
    loga("pname ".. pname)
    pb.parseFromString(model,body)
    ret.model = model

    return ret
end

function Net:getDataBySignedBody( signedbody, cmd )
    local needSign = UNITY_PAY_SECRET .. signedbody.body
    function getHex(var)
        local ret = string.format("%X", var)
        if #ret == 1 then return "0"..ret
        else return ret end
    end

    local body = nil
    local sign2
    if qf.device.platform == "android" and Util:checkNotUpdatePackage() then
        local b64 = ""
        for i=1,#needSign do b64 = b64..getHex(string.byte(needSign,i)) end
        sign2= QNative:shareInstance():md5WithBase64(b64)
    else
        sign2 = QNative:shareInstance():md5(needSign)
    end
    if signedbody.sign == sign2 then
        body = signedbody.body
    else
        return nil
    end

    local pname = self._pbad:findPBNameByCmd({method="rsp",cmd=cmd})
    if pname == nil then return nil end
    local model = pb.new(pname)
    pb.parseFromString(model, body)
    return {model=model}
end

function Net:getDataType(m)
    if type(m) == "table" then
        if m[1] ~= nil then
            if type(m[1]) == "table" then
                return REPEATED_MSG
            else
                return REPEATED_VAL
            end
        else
            return OPTIONAL_MSG
        end
    else
        return OPTIONAL_VAL
    end
end

function Net:packBox(msg)

    local box = ferry.ScriptFerry:getInstance():createBox()
    box:setCmd(msg.cmd)
    if msg.body == nil then
        return box
    end

    local pname = self._pbad:findPBNameByCmd({method=msg.method,cmd=msg.cmd})
    logd(" use ".. pname .. " pack body ~ cmd=" .. msg.cmd)
    loga(" use ".. pname .. " pack body ~ cmd=" .. msg.cmd)
    local function _pack(_m,_t)
        for k, v in pairs(_t) do
            local data_type = self:getDataType(v)
            if data_type == OPTIONAL_MSG then
                _pack(_m[k], v)
            elseif data_type == REPEATED_MSG then
                for key, value in pairs(v) do
                    _pack(_m[k]:add(), value)
                end
            elseif data_type == OPTIONAL_VAL then
                _m[k] = v
            elseif data_type == REPEATED_VAL then
                for key, value in pairs(v) do
                    _m[k]:add(value)
                end
            end
        end
    end

    local model = pb.new(pname)
    if not model then
        return
    end

    _pack(model,msg.body)

    local stringbuf = pb.serializeToString(model)
    box:setBody(stringbuf)

    return box
end

function Net:onConnect(beReconnect)
    if self.reRegCid then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.reRegCid)
        self.reRegCid = nil
    end

    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove",hard=true})
    qf.event:dispatchEvent(ET.LOGIN_NET_GOTO_LOGIN)

    if not beReconnect then
        self.bConnected = true
    end
    self.cancellation = false--在这里要把注销开关关掉

    -- 清除错误次数
    self:clearTryTimesForCurrentAddress()

    NetDelayTool:startHeartBeatTimeOutCheck()
end

function Net:reReg(once)
    --校正 reReg 与 onConnect 可能同时被调用 造成两次重连的可能性
    NetDelayTool:stop()
    if self.reRegCid == nil then
        self.reRegCid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            self:onConnect(true)
            if once then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.reRegCid)
                self.reRegCid = nil
            end
        end,2,false)
    end
end

-- 建立长连接有效性状态更新
function Net:updateConnectTime()
    local currentTimeString = self.connectTime == 0 and Util:getDigitalTime2(os.time()) or Util:getDigitalTime2(self.connectTime)
    print(string.format("【当前时间：%s】=======updateConnectTime========== 上一次连接的时间lastTime = %s", currentTimeString, Util:getDigitalTime2(os.time())))
    self.connectTime = os.time()
end

function Net:getConnectTime( ... )
    return self.connectTime
end

function Net:disconnect(paras)
    self.bConnected = false
    self.cancellation = paras ~= nil and paras.is_cancellation or false
    self.bConnected = false
    ferry.ScriptFerry:getInstance():disconnect()
end

function Net:onDisconnect(paras)
    if self.cancellation == true then
        return
    end
    self.bConnected = false
    qf.event:dispatchEvent(ET.NET_DISCONNECT_NOTIFY, {})    --断网通知, 需要重新加载的模块需要处理此消息
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT, {method = "update", txt = GameTxt.net004})
    qf.event:dispatchEvent(ET.NET_CLOSE_AND_CLOSE_CHAT_SERVICE) --关闭聊天服
    local _type = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    if VAR_LOGIN_TYPE_NO_LOGIN ~= _type then
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",reConnect = 1 ,txt=GameTxt.reConnect})
    end

    if not ModuleManager:judegeIsInLogin() then
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.reConnect})
    end
    NetDelayTool:stop()
    if not self:connect() then
        if not paras then
            self:onAllAddressFailed()
        end
    end
end

function Net:isConnected()
    return ferry.ScriptFerry:getInstance():isConnected()
end

function Net:delAllRspCbs()
    ferry.ScriptFerry:getInstance():delAllRspCallbacks()
end

function Net:resume()
    self.time_pause_net = checkint(qf.time.getTime()) - self.time_pause_net
    ferry.ScriptFerry:getInstance():resumeSchedule()
end

function Net:pause()
    self.time_pause_net = checkint(qf.time.getTime())
    ferry.ScriptFerry:getInstance():pauseSchedule()
end

function Net:isPause( )
    ferry.ScriptFerry:getInstance():isSchedulePaused()
end

function Net:DelAllEvents()
    ferry.ScriptFerry:getInstance():clearEvents()
end

function Net:clean()
    self:delAllRspCbs()
    self:DelAllEvents()
end

function Net:onSendError(paras)
    logd( "Net:onSendError --" , self.TAG)
end

function Net:onConnectError(paras)
    logd( "Net:onConnectError --" , self.TAG)
    --连接错误就重下获取iplist
    if not self:connect() then
        self:onAllAddressFailed()
    end
end

function Net:onUncauthError(paras)
    logd( "Net:onUncauthError --" , self.TAG)
end

function Net:onAllAddressFailed()
    logd( "Net:onAllAddressFailed --" , self.TAG)

    -- 先不要重连了
    self:disconnect()

    -- TODO 要重新拉取address列表
    -- qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT, {method="show", txt=GameTxt.login002})
    self:requeryAddressList()
end

-- 重新拉取address列表
function Net:requeryAddressList( ... )
    local url = Util:getRequestConfigURL()
    local _queryAddress
    _queryAddress = function ()
        -- 超时定时器
        if self._queryAddressScheduler then
            Util:stopRun(self._queryAddressScheduler)
        end
        -- if self.httpRequest then
        --     self.httpRequest:abort()
        -- end

        self.httpRequest = cc.XMLHttpRequest:new()
        self.httpRequest.tag = getUID() 
        self.httpRequest.timeout = 5
        print("【请求Tag】=====requeryAddressList=== start " .. self.httpRequest.tag)

        local _onResponse, _onTimeOut

        _onTimeOut = function ()
            print("【请求Tag】=====requeryAddressList=== timeout " .. self.httpRequest.tag)
            self.httpRequest:abort()
            -- 下载失败1后重试 
            Util:stopRun(self._queryAddressScheduler)
            self._queryAddressScheduler = Util:runOnce(1, _queryAddress)
        end

        _onResponse = function ( event )
            print("【请求Tag】=====requeryAddressList=== response " .. self.httpRequest.tag .. "   status = " .. self.httpRequest.status)
            if self.httpRequest.status == 200 then
                print(string.format("【当前时间：%s】=======requeryAddressList==========", Util:getDigitalTime2(os.time())))
                local response = self.httpRequest.response
                local responseTable = json.decode(response)
                -- 因为server_alloc 加了限制，所以这里要判断下
                if tonumber(Util:getDesDecryptString(responseTable.ret)) == 0 then
                    TB_SERVER_INFO = json.decode(response)
                    Cache.Config:updateServerAllocConfig(TB_SERVER_INFO)
                    if not self:connect() then
                        print("【GameNet】=======requeryAddressList>>>>>>> 获取到iplist重新连接")
                        self:start(TB_SERVER_INFO.server_list)
                        return
                    end
                    if not self:isConnected() then
                        print("【GameNet】=======requeryAddressList>>>>>>>连接断开了")
                        self:onDisconnect()
                        return
                    end
                else
                    -- 下载失败1.2s后重试 (因为如果是ret = -1，是请求太频繁，延迟一点再试)
                    Util:stopRun(self._queryAddressScheduler)
                    self._queryAddressScheduler = Util:runOnce(1.2, _queryAddress)
                end
            else
                -- 下载失败1s后重试
                Util:stopRun(self._queryAddressScheduler)
                self._queryAddressScheduler = Util:runOnce(1, _queryAddress)
            end
        end

        self._queryAddressScheduler = Util:runOnce(self.httpRequest.timeout, _onTimeOut)
        local func = function ( ... )
            Util:stopRun(self._queryAddressScheduler)
            _onResponse(event)
        end

        self.httpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
        self.httpRequest:registerScriptHandler(func)
        self.httpRequest:open("GET", Util:getRequestConfigURL())
        self.httpRequest:send()
    end
    _queryAddress()
end

return Net
