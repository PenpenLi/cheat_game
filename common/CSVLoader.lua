local CSVLoader = class("CSVLoader")
 
local data = nil
local fileData = nil
 
local function splist(str,reps)
    local result = {}
    string.gsub(str, '[^' .. reps ..']+', function(w) table.insert(result, w) end ) 
    return result
end
 
function CSVLoader:create(filePath)
    fileData = cc.FileUtils:getInstance():getStringFromFile(filePath)
    local lineStr = splist(fileData, '\n\r')
    local keys = splist(lineStr[1], ",")
    data = {}
    for i,v in ipairs(lineStr) do
        if i >= 2 then
            local va = splist(v, ",")
            local tempData = {}
            for j,b in ipairs(va) do
                if keys[j] then
                    tempData[keys[j]] = b
                else
                    tempData = nil
                    break
                end
            end
            data[#data + 1] = tempData
        end
    end
end
 
function CSVLoader:getData(key,value)
    for i,v in ipairs(data) do
        for x,y in pairs(v) do
            if x == key and y == value then
            	return v
            end
        end
    end
end

function CSVLoader:getAllData( ... )
    return data
end
 
function CSVLoader:print()
	if data then
        for i,v in ipairs(data) do
            for x,y in pairs(v) do
                print(x .. " : " .. y)
            end
        end
	end
end

CSVTool = CSVLoader:new()