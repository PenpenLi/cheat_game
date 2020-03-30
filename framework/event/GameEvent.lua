
local GameEvent = class("GameEvent")

GameEvent.__eventTable = {}
GameEvent.TAG = "GameEvent"

function GameEvent:ctor(parameters)
	--logd(" ----- GameEvent ctor -------- " , self.TAG)
end


--[[--
    添加一个事件
    
]]
function GameEvent:addEvent(eventName,cb)
    self.__eventTable[eventName] = cb
end


--[[--
    删除一个事件
]]
function GameEvent:removeEvent(eventName)
    self.__eventTable[eventName] = nil
end

--[[--
    分发事件  
]]
function GameEvent:dispatchEvent(eventName,paras)
    if type(eventName) == "table" then  -- 判断数组
        for k,v in pairs(eventName) do 
            
            self:_dispatchEvent(v,paras)
        end
    else 
        return self:_dispatchEvent(eventName,paras)
    end
end


function GameEvent:_dispatchEvent(eventName,paras)
    if type(eventName) == "number" then
        if self.__eventTable[eventName] ~= nil then
            --logd(" dispatch event " .. eventName,self.TAG)
            return self.__eventTable[eventName](paras)
        else 
            -- logi(" -- no listener binding to " .. eventName ,self.TAG)
        end
    else 
        -- loge(" -- dispatch event error -- , unkown type",self.TAG)
    end
end

return GameEvent
