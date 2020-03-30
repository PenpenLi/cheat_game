-- 日志管理工具类类

local LogUtil = class("LogUtil")

local logDirName = "log"

function LogUtil:ctor()
    print ("___________日志所在的文件夹位置：" .. self:getLogDirPath())
end

-- 保存日志到本地
function LogUtil:saveLogToFile(logTxt)
    if SAVE_LOG == false or type(logTxt) ~= 'string' then return end
	if logTxt == nil or logTxt == "" then return end
	local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local sec = string.format("%02d", date.sec)
    local currentTime = date.year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" ..min .. ":" ..sec
	local flag = self:logFileOperate(self:getFileName(), "[ " .. currentTime .. " ]  " .. logTxt .. "\n")
	return flag
end

function LogUtil:logFileOperate(fileName, content)
    if qf and qf.platform then
        qf.platform:uploadError({content=content,debug="1"})
    else
    	local file = assert(io.open(fileName, 'a+'))
    	if file then
            if file:write(content) == nil then return false end
            io.close(file)
            return true
        else
            return false
        end
    end
end

-- 获取日志文件名
function LogUtil:getFileName()
	local dirPath = self:getLogDirPath()
	local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local timeStr = date.year .. "-" .. month .. "-" .. day
	local fileName = dirPath .. timeStr .. ".txt"
    if not CCFileUtils:sharedFileUtils():isFileExist(fileName) then
        self:removeOldTxt()
    end
	return fileName
end

-- 获取和创建文件夹
function LogUtil:getLogDirPath()	
	-- 获得文件保存路径
	local writeblePath = cc.FileUtils:getInstance():getWritablePath() .. logDirName
	if not CCFileUtils:sharedFileUtils():isFileExist(writeblePath) then
	    lfs.mkdir(writeblePath)
    end
    
    return writeblePath .. "/"
end

--只保存最近的5个log日志
function LogUtil:removeOldTxt( ... )
    local writeblePath = cc.FileUtils:getInstance():getWritablePath() .. logDirName
    local txtTabel = {}
    for file in lfs.dir(writeblePath) do
        if file ~="." and file ~=".." then
            table.insert(txtTabel,writeblePath.."/"..file)
        end
    end
    if #txtTabel>4 then
        os.remove(txtTabel[1])
    end
end

return LogUtil