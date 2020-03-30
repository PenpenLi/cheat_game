local M = class("Scheduler")


function M:ctor()
    -- body
    self.id = {}
end

--bsig 为true 不加入记录队列 self.id
function M:delayCall(delay,callback, bsig, ...)
	local schedEntry
	local args = {...}
    schedEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function ()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedEntry)
            callback(self,unpack(args))
        end,
    delay, false)
    if not bsig then
        table.insert(self.id,schedEntry)
    end
    return schedEntry
end



function M:scheduler(tival,callback,...)
    local schedEntry
    local args = {...}
    schedEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function ()
            callback(self,unpack(args))
        end,
    tival, false)

    table.insert(self.id,schedEntry)
    return schedEntry

end

function M:clearAll()
    -- body
    for k,v in pairs(self.id) do
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
    end
end

function M:unschedule(sid)
    if type(sid) == "number" then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
    end
end



Scheduler = M.new()