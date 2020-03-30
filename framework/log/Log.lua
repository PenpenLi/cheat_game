

local Log = class("Log")

Log.DEBUG = 4;
Log.INFO = 3;
Log.WARN = 2;
Log.ERROR = 1;
Log._defaultlvl = Log.DEBUG;

Log.LEVEL_DESC = {}
Log.LEVEL_DESC[Log.DEBUG] = 'DEBUG'
Log.LEVEL_DESC[Log.INFO] = 'INFO'
Log.LEVEL_DESC[Log.WARN] = 'WARN'
Log.LEVEL_DESC[Log.ERROR] = 'ERROR'

function Log:ctor(args) 

end

function Log:d(msg,tag)
    self:_log(Log.DEBUG, msg, tag)
end

function Log:i(msg,tag)
    self:_log(Log.INFO, msg, tag)
end

function Log:w(msg,tag)
    self:_log(Log.WARN, msg, tag)
end

function Log:e(msg,tag)
    self:_log(Log.ERROR, msg, tag)
end

function Log:adaptLog(msg)
    if ENVIROMENT_TYPE == 1 then 
        return 
    end
    if qf and qf.platform and qf.device.platform == "android" then
        --qf.platform:print_log(msg)
        cc.Director:getInstance():getConsole():log(msg.."\n")
    else
        print(msg)
    end
end

function Log:setLogLvl(parameters)
	if parameters > self.DEBUG and parameters < self.ERROR then 
	   self:e("error on setLogLvl ---" ,"Log")
	   return
	end
	
	self._defaultlvl = parameters
end

function Log:_log(level, fmt, tag)
    -- 外界不能调用
    if (self._defaultlvl < level) then 
        return 
    end

    local record = {
        level=level,
        -- 变化调用层级的话，修改第一个4
        caller=self:trimString(self:splitString(debug.traceback("", 4), "\n")[3]),
        msg=string.format("[%s] %s", tostring(tag), tostring(fmt)),
    }

    print(self:format(record))
end

function Log:splitString(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function Log:trimString(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function Log:format(record)
    -- 可以继承重写
    return string.format("\n%s\n[%s][%s]:\n%s\n%s",
        "/--------------------------------------------------------------------------------",
        Log.LEVEL_DESC[record.level],
        record.caller,
        record.msg,
        "--------------------------------------------------------------------------------/"
    )
end



return Log
