local M = class("Encrypt")

function M:getByte(data, flag)
    local array = {}
    local lens = string.len(data)
    if (flag == false)
    then
        for i=1,lens do
            array[i] = string.byte(data, i)
        end
        return array
    else
        for i=1,lens do
            array[i-1] = string.byte(data, i)
        end
    end
    return array,lens
end

function M:getChars(bytes)
    local array = {}
    for key, val in pairs(bytes) do
        array[key] = string.char(val)
    end
    return array
end

function M:encryptData(data, keys)
    local result = ""
    local dataArr = self:getByte(data, false)
    local keyArr,keyLen = self:getByte(keys, true)
    for index,value in pairs(dataArr) do
        result = result.."@"..tostring((0xFF and value) + (0xFF and keyArr[(index-1) % keyLen]))
    end
    return result
end

function M:decryptData(data, keys)
    local result = ""
    local dataArr = string.newsplit(data, '@')
    local keyArr,keyLen = self:getByte(keys, true)
    for index,value in pairs(dataArr) do
          bytes =  tonumber(value) - (0xFF and keyArr[(index-1) % keyLen])
          result = result..string.char(bytes)
    end
    return result
end

function string.newsplit( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

Encrypt = M.new()