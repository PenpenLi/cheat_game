--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--此文件针对于 一些cocos 已有的函数进行重写或者添加新的功能


--
local function logOnGUIReader()
    local TAG = "uiReadr"
    local _widgetFromJsonFile = ccs.GUIReader:getInstance().widgetFromJsonFile
    local widgetFromJsonFile =  function  (_, jsonName)
        -- print(string.format("%s: %s", TAG, jsonName))
        return _widgetFromJsonFile(_, jsonName)
    end
    ccs.GUIReader:getInstance().widgetFromJsonFile = widgetFromJsonFile
end

if qf.device.platform == "windows" then
    logOnGUIReader()
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = { }
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

printTraceback = function (message, bRet)
    if message then
        print(message)
    end
    local tbackStr = debug.traceback()
	local list = Split(tbackStr, "\n");
    for i = 1, #list do
        local v = list[i]
        local idx = string.find(v, ".\"",1,true)
        if idx and idx ~= -1 then
            local infoTbl = debug.getinfo(i-1)
            if infoTbl then
                local a, b = string.find(list[i], infoTbl.short_src, 1, true)
                list[i] = string.sub(list[i], 1, a) .. infoTbl.source .. string.sub(list[i], b, -1)
            end
        end
    end
    if bRet == true then
        return list
    end
    for i = 1, #list do
		print(list[i])
	end
end

printRspModel = function (model, message)
    if message then
        print(message)
    end
    if type(model) == "userdata" then
        print(pb.tostring(model))
    else
        print(model, "model is nil or false")
    end
end

__dump = function (M)
    for k, v in pairs(M) do
        if string.find(v, ".json") then
        else
            print(k, v)
        end
    end
end

--改造Lua的debug.traceback()，让其显示栈上所有的局部变量
function tracebackex(_level)
    local ret = ""
    local level = 2
    _level = _level or 4
    ret = ret .. "stack traceback:\n"
    while true do
        --get stack info
        local info = debug.getinfo(level, "Sln")
        if level > _level then break end
        if not info then break end
        if info.what == "C" then                -- C function
            ret = ret .. tostring(level) .. "\tC function\n"
        else           -- Lua function
            ret = ret .. string.format("\t[%s]:%d in function `%s`\n", info.short_src, info.currentline, info.name or "")
        end
        --get local vars
        local i = 1
        while true do
            local name, value = debug.getlocal(level, i)
            if not name then break end
            ret = ret .. "\t\t" .. name .. " =\t" .. tostringex(value, 3) .. "\n"
            i = i + 1
        end
        level = level + 1
    end
    return ret
end
 
function tostringex(v, len)
    if len == nil then len = 0 end

    local pre = string.rep('\t', len)
    local ret = ""

    if type(v) == "table" then
        if len > 5 then return "\t{ ... }" end
        local t = ""
        for k, v1 in pairs(v) do
            t = t .. "\n\t" .. pre .. tostring(k) .. ":"
            t = t .. tostringex(v1, len + 1)
        end
        if t == "" then
            ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"
        else
            if len > 0 then
                ret = ret .. "\t(" .. tostring(v) .. ")\n"
            end
            ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"
        end
    else
        ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"
    end
    return ret
end
--endregion
