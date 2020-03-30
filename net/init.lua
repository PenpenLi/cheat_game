

local net = import(".Net")
local chatNet = import(".chatservice.ChatService")
require "src.net.FerryConstants"

--[[--
GameNet:send({
uid=1,
body = bitarray or json,
cb= function(paras) end  -- handler(self,self.someMethod)
asyn=ture,
timeout=2
})
]]

GameNet = net.new()
ChatServer = chatNet.new()

-- 设置为5秒
ferry.ScriptFerry:getInstance():setConnectTimeout(5)

ferry.ScriptFerry:getInstance():addEventCallback(
    function(event)
        local box = event:getBox()
        local what = event:getWhat()
        
        if (event:getWhat() == ferry.EventType.open) then
            GameNet:onConnect()
        elseif (event:getWhat() == ferry.EventType.close) then
            GameNet:onDisconnect()
        elseif (event:getWhat() == ferry.EventType.error) then
            GameNet:onConnectError()
        elseif (event:getWhat() == ferry.EventType.timeout) then
            GameNet:onConnectError()
        elseif(event:getWhat() == ferry.EventType.recv) then
            GameNet:onMsg(event:getBox())
        end
    end , nil
)
