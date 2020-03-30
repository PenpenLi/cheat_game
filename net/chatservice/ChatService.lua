
--[[
    --聊天服务
]]
local ChatService = class("ChatService") 
local ChatDataPaser = import(".ChatDataParser") 
ChatService.TAG = "ChatService"

ChatService.heartBeatTime = 10 --10秒间隔发心跳
ChatService.reconnectTime = 2  --重连间隔2s
ChatService.heartCallBackCheckTime = 3 -- 心跳超时检测时间
ChatService.loginServerTimeOut = 11 

function ChatService:ctor(paras)
    self.dataPaser = ChatDataPaser.new()
    self:initData(paras)
end

function ChatService:initData(paras)
    self.websocketInstance = nil
    self.heartBeatCid = nil
    self.heartBeatTimeOutCid = nil
    self.loginServerTimeOutCid = nil
    self.dataMonitorEvent = nil
    self.address = nil
    -- 未连接状态
    self.state = -1
    -- 断线重连标志
    self.bNetConnect = false
    self.bReconnectLock = false
end

function ChatService:init(paras)
    self:distroyWebScocket()
    self:initData()
    self:addEventObsever()
end

function ChatService:addEventObsever( ... )
    qf.event:addEvent(ET.NET_CLOSE_AND_CLOSE_CHAT_SERVICE, handler(self, self.closeChatService))
end

function ChatService:getState( ... )
    if not self.websocketInstance then
        self.state = -1
    end
    self.state = self.websocketInstance:getReadyState()
    return self.state
end

-- 开始连接，外部调用
function ChatService:startConnect(address)
    if not address or address == "" then
        return 
    end
    self.address = address
    if self.websocketInstance then
        self:distroyWebScocket()
    end
    self:createWebSocket(address)
end

-- 创建websocket
function ChatService:createWebSocket(address)
    print(" 【ChatService】创建连接 ----  >>>>>")
    self.websocketInstance = cc.WebSocket:create("ws://" .. address)
    if self.websocketInstance then
        self.websocketInstance:registerScriptHandler(handler(self, self.onOpen), cc.WEBSOCKET_OPEN)
        self.websocketInstance:registerScriptHandler(handler(self, self.onOMessage), cc.WEBSOCKET_MESSAGE)
        self.websocketInstance:registerScriptHandler(handler(self, self.onClose), cc.WEBSOCKET_CLOSE)
        self.websocketInstance:registerScriptHandler(handler(self, self.onError), cc.WEBSOCKET_ERROR)
    end
end

--[[
    心跳处理
]]
function ChatService:startHeartBeat( ... )
    if self.heartBeatCid then
        self:stopHeartBeat()
    end

    self.heartBeatCid = Scheduler:delayCall(self.heartBeatTime, function ( ... )
        local pbName = "HeartbeatRequest"
        local heartBeatModel = pb.new(pbName)
        heartBeatModel.time = os.time()
        self:send(pbName, heartBeatModel)
        --心跳超时检测
        self:stopHeartBeatTimeOutCheck()
        self:checkHeartBeatTimeOut()
    end)

end

--[[
    关闭心跳
]]
function ChatService:stopHeartBeat( ... )
    if self.heartBeatCid then
        Scheduler:unschedule(self.heartBeatCid)
        self.heartBeatCid = nil
    end
end

--[[
    1.心跳超时检测
]]
function ChatService:checkHeartBeatTimeOut( ... )
    self.heartBeatTimeOutCid = Scheduler:delayCall(self.heartCallBackCheckTime, function ( ... )
        if self.websocketInstance then
            -- 断线重连
            logi("【ChatService】心跳超时")
            self:reconnect()
        end
    end)
end

function ChatService:stopHeartBeatTimeOutCheck( ... )
    if self.heartBeatTimeOutCid then
        Scheduler:unschedule(self.heartBeatTimeOutCid)
        self.heartBeatTimeOutCid = nil
    end
end

--[[
    1.登录websocket超时检测
]]
function ChatService:checkLoginRspCallBack( ... )
    self.loginServerTimeOutCid = Scheduler:delayCall(self.loginServerTimeOut, function ( ... )
        self:stopLoginRspCheck()
        if self.websocketInstance then
            -- 断线重连
            self:reconnect()
        end
    end)
end

--[[
    关闭登录超时检测
]]
function ChatService:stopLoginRspCheck( ... )
    if self.loginServerTimeOutCid then
        Scheduler:unschedule(self.loginServerTimeOutCid)
        self.loginServerTimeOutCid = nil
    end
end

--[[
    1.登录websocket
]]
function ChatService:loginServer( ... )
    self:sendRequest({
        pbName = "ChatUserLoginReq",
        body = {
            sig = Util:getChatServerSig()
        }
    })
    self:checkLoginRspCallBack()
end

--[[
    1.断线重连
]]
function ChatService:reconnect( ... )
    if self.bReconnectLock then return end
    if self.bNetConnect then
        loge("【ChatService】已经在断线重连了 bNetConnect = true")
        return 
    end

    if self.reconnectCid then
        loge("【ChatService】已经在断线重连了 reconnectCid ~= nil")
        return
    end

    local stopAllCid = function ( ... )
        self:stopHeartBeat()
        self:stopHeartBeatTimeOutCheck()
        self:stopLoginRspCheck()
    end

    stopAllCid()
    
    self.bNetConnect = true
    --断线重连
    self.reconnectCid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        print("【ChatService】断线重连开始 time = " .. os.time())
        stopAllCid()
        self:startConnect(Cache.Config:getChatServerIPAddress())
    end,self.reconnectTime,false)
end

--[[
    1.停止断线重连
]]
function ChatService:stopReconnect( ... )
    if self.reconnectCid then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.reconnectCid)
        self.reconnectCid = nil
    end
end

--[[
    1.pbName 协议名称
    2.body 数据table
    3.callback 回调处理方法
]]
function ChatService:sendRequest(paras)
    if not paras.pbName or paras.pbName == "" then  end
    local model = pb.new(paras.pbName)
    if type(paras.body) == 'table' then
        self.dataPaser:packPB(model, paras.body)
    end
    print("【ChatService】 sendRequest pbName = " .. paras.pbName)
    self:send(paras.pbName, model, paras.callback)
end

function ChatService:send(pbName, bodyBuff, callback)
    local msgStringBuf = self.dataPaser:packMsg(pbName, bodyBuff)
    if self.websocketInstance then
        self.websocketInstance:sendString(msgStringBuf)
    end
end

--[[
    因为聊天业务不多，外部监听数据事件就好了
]]
function ChatService:registerDataCallBackEvent(paras)
    if not paras then return end
    if not paras.callback then return end
    self.dataMonitorEvent = paras.callback
end

function ChatService:unRegisterDataCallBackEvent( ... )
    self.dataMonitorEvent = nil
end

--[[
    普通业务逻辑处理
]]
function ChatService:commonLogicCallBack(rsp)
    if rsp.name == "HeartbeatResponse" then
        --收到心跳的回包消息，清除心跳超时检测
        self:stopHeartBeat()
        self:startHeartBeat()
        self:stopHeartBeatTimeOutCheck()
    elseif rsp.name == "UserLoginRes" then
        --重置
        self:stopHeartBeat()
        self:stopLoginRspCheck()
        self:stopReconnect()
        --登录成功后再处理心跳吧
        if rsp.model.result ~= 0 then
            self:reconnect()
            return
        end
        Cache.cusChatInfo:setProxcyDataId(rsp.model.proxy_data_id)
        --发心跳
        self:startHeartBeat()
    --异地登录
    elseif rsp.name == "NotifyBekicked" then
        loge(string.format("【ChatService】 【%s】 异地登录 ", Util:getDigitalTime2(os.time())))
    else
        --这个数据监听只能是唯一的，没有多个，多个会覆盖
        if self.dataMonitorEvent then
            self.dataMonitorEvent(rsp)
        end
    end
end

--[[
    WebSocket 回调方法
]]
function ChatService:onOpen()
    self.bNetConnect = false
    --这里要发送登录协议
    self:loginServer()
end

function ChatService:onOMessage(data)
    local rspModel = self.dataPaser:unpackMsg(data)
    if not rspModel then return end
    self:commonLogicCallBack(rspModel)
end

function ChatService:onClose()
    self:reconnect()
end

function ChatService:onError()
    self:reconnect()
end

function ChatService:distroyWebScocket( ... )
    if self.websocketInstance then
        self.websocketInstance:unregisterScriptHandler(cc.WEBSOCKET_OPEN)
        self.websocketInstance:unregisterScriptHandler(cc.WEBSOCKET_ERROR)
        self.websocketInstance:unregisterScriptHandler(cc.WEBSOCKET_MESSAGE)
        self.websocketInstance:unregisterScriptHandler(cc.WEBSOCKET_CLOSE)
        self.websocketInstance:close()
        self.websocketInstance = nil
    end
end

-- 手动关闭聊天服
-- 因为和游戏连接相关连，如果游戏连接断开在短线重连，那么先主动断开，然后不断线重连，等待游戏连接成功
function ChatService:closeChatService( ... )
    self.bReconnectLock = true
    -- 如果在断线重连，先断开
    self:stopReconnect()
    -- 关闭心跳超时检测
    self:stopHeartBeatTimeOutCheck()
    -- 关闭心跳
    self:stopHeartBeat()
    -- 关闭登录超时检测
    self:stopLoginRspCheck()
    self:distroyWebScocket()
end

return ChatService