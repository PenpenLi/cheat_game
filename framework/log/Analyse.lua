-- 日志管理工具类类

local Analyse = class(" Analyse")

local logDirName = "Log"
local logFileName = "UserAnalyseLog"

function Analyse:ctor()
    local logDirPath = self:getUserAnalyseLogDirPath()
    self.uploadTask = nil
    print ("___________用户分析日志所在的文件夹位置：" .. logDirPath)
end

function Analyse:init( ... )
    if not LOCAL_USER_LOG then return end
    self:stopUploadTask()
    --开始时间检测
    self.lastSaveTime = os.time()
    --先上传一次，把剩余的处理掉
    self:upLoadLogToServer()
    --两分钟处理一次
    self.uploadTask = Scheduler:scheduler(2*60,function ()
        self:upLoadLogToServer()
    end)
end

--停止上传任务
function Analyse:stopUploadTask( ... )
    if self.uploadTask then
        Scheduler:unschedule(self.uploadTask)
    end
end

--上传日志到服务器
function Analyse:upLoadLogToServer()
    -- 如果没有连接网络
    if not qf.platform:isEnabledWifi() and not qf.platform:isEnabledWifi() then
        return
    end
    
    --获取所有内容
    local logContent = cc.FileUtils:getInstance():getDataFromFile(self:getFilePath())
    if logContent and logContent ~= "" then
        print("======================日志上传中..")
        if game and game.uploadError then
            game.uploadError(logContent)
            --清除文件内容
            io.writefile(self:getFilePath(), "", "w+")
        end
    end
end

-- 保存日志到本地
function Analyse:saveUserViewLogToFile(logTxt, filePath)
    if not LOCAL_USER_LOG then return end
    if type(logTxt) ~= 'string' then return end
	if logTxt == nil or logTxt == "" then return end
    if not Cache.user.uin then return end
    local timestamp = os.time()
	local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local sec = string.format("%02d", date.sec)
    local currentTime = date.year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" ..min .. ":" ..sec
	local flag = self:logFileOperate(self:getFilePath(), "[uin：" .. Cache.user.uin .. "]" .. "[UserAnalyseLog][ 用户展示页面-->>" .. currentTime .. " ]  " .. filePath .. "    " .. logTxt .. "\n")
    if flag then
        self.lastSaveTime = timestamp
    end
    print(flag)
	return flag
end

-- 日志写入文件
function Analyse:logFileOperate(filePath, content)
	local file = assert(io.open(filePath, 'a+'))
	if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

-- 获取用户分析日志文件名
function Analyse:getFilePath()
    local dirPath = self:getUserAnalyseLogDirPath()
    local logFileName = dirPath .. logFileName .. ".txt"
	return logFileName
end

-- 获取和创建文件夹
function Analyse:getUserAnalyseLogDirPath()	
	-- 获得文件保存路径
	local writeblePath = cc.FileUtils:getInstance():getWritablePath() .. logDirName
	if not CCFileUtils:sharedFileUtils():isFileExist(writeblePath) then
	    lfs.mkdir(writeblePath)
    end
    
    return writeblePath .. "/"
end

AnalyseTools = Analyse:new()