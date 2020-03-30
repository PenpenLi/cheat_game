--[[
--热更新下载帮助类:负责下载
--]]


local function splitString(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == '') then return false end
    local pos, arr = 0, {}
    -- for each divider found
        for st, sp in function() return string.find(input, delimiter, pos, true) end do
table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

local HotUpdateHelper = {}-- class("HotUpdateHelper")
local m_instance
local function new(o)
    o = o or {}
    setmetatable(o, {__index = HotUpdateHelper})
    return o
end
local function getInstance(...)
    if not m_instance then
        m_instance = new()
    end
    return m_instance
end

function HotUpdateHelper.getInstance(...)
    return getInstance()
end

-- 拆分并创建文件夹
-- t 1临时文件夹 2更新文件
function HotUpdateHelper:splitDir(path, t)
    local split = string.split(path, "/")
    local prefix = self.update_folder
    if t == 1 then
        prefix = self.temp_update_folder
    end
    for i = 1, #split - 1 do
        prefix = prefix .. split[i] .. "/"
        self:createDir(prefix)
    end
end
function HotUpdateHelper:createDir(path)
    lfs.mkdir(path)
end
function HotUpdateHelper:copyDirectory(_src, _dest)
    local function _copy(_src, _dest)
        local ret, files, iter = pcall(lfs.dir, _src)
        if ret then
            for entry in files, iter do
                if entry ~= "." and entry ~= ".." then
                    local _srcDir = _src .. entry
                    local _destDir = _dest .. entry
                    local attr = lfs.attributes(_srcDir, "mode")
                    if attr == "directory" then
                        _copy(_srcDir .. "/", _destDir .. "/")
                    else
                        if io.exists(_destDir) then
                            os.remove(_destDir)
                        end
                        os.rename(_srcDir, _destDir)
                    end
                end
            end
            lfs.rmdir(_src)
        end
    end
    _copy(_src, _dest)
end
-- 遍历一个文件夹并返回所有的文件
function HotUpdateHelper:dfsDirectory(path)
    local _tbFiles = {}
    local function _dfs(path, prefix)
        local ret, files, iter = pcall(lfs.dir, path)
        if ret then
            for entry in files, iter do
                if entry ~= "." and entry ~= ".." then
                    local _dir = path .. entry
                    local _p = prefix .. entry
                    local attr = lfs.attributes(_dir, "mode")
                    if attr == "directory" then
                        _dfs(_dir .. "/", _p .. "/")
                    else
                        table.insert(_tbFiles, _p)
                    end
                end
            end
        end
    end
    _dfs(path, "")
    return _tbFiles
end

function HotUpdateHelper:init(args)
    self.callback = args.callback
    self.current_url = "" --当前下载的url
    self.load_type = -1 --当前下载的阶段 0下载配置列表 1下载md5配置文件 2下载更新文件
    
    self.current_count = 0 --当前下载的文件个数
    self.current_total_count = 0 --当前下载的总文件个数
    
    self.current_byte_count = 0 --当前下载的文件大小
    self.current_total_byte = 0 --当前下载阶段的总大小
    
    self.handler_http_req = nil --XMLHttpRequest的句柄
    self.handler_scheduler = nil --下载请求的schduler
    self.config_list = {} --下载的配置列表
    
    self.will_load_list = {} --将要下载的文件列表：[i] [1]md5 [2]文件名 [3]大小
    
    self:setDownloadFinish(false) --热更新是否完成
    
    self.md5_path = "md5.txt" --原始md5列表配置文件
    --更新用的文件变量
    self.update_folder = QNative:shareInstance():getUpdatePath() .. "/" --更新的文件夹路径
    self.update_md5_path = self.update_folder .. "md5.txt" --更新的md5列表配置文件
    --更新用的临时变量
    self.temp_update_folder = cc.FileUtils:getInstance():getWritablePath() .. "download/" -- 更新用的临时文件夹
    self.temp_update_md5_path = self.temp_update_folder .. "md5.txt" --更新MD5列表配置文件的临时文件
end

--开始下载
function HotUpdateHelper:startDownload(args)
    self.load_type = args.load_type
    self.handler_http_req = cc.XMLHttpRequest:new()
     
    --拉取配置文件会快很多
    if self.load_type == 0 then
        self.handler_http_req.timeout = 20
    else
        self.handler_http_req.timeout = 30
    end
    
    -- 因为用XMLHttpRequest自己的timeout回调判断不出来status，404和超时都是0
    local function innerOnTimeout ()
        self:abortDownload()
        self:onDownloadFail()
    end

    if self.load_type == 0 then --对getserveralloc的地址进行一个容灾处理 超过三次就使用指定json中的domain_name
        --最开始要重置
        if self.timeoutCnt == nil then
            Cache.Config:setDomainName("")
        end
        self.timeoutCnt = self.timeoutCnt or 0
    end

    self.handler_scheduler = Util:runOnce(self.handler_http_req.timeout, function(...)
        self:abortDownload()
        print("【HotUpdateHelper】 handler_http_req.timeout?")
        self:onDownloadFail()
    end)
    
    local func = function(event)
        Util:stopRun(self.handler_scheduler)
        self.handler_scheduler = nil
        self:onReadyStateChange(event)
    end
    self.handler_http_req:registerScriptHandler(func)
    
    local response_type = ""
    local url
    if self.load_type == 0 then -- 配置文件
        response_type = cc.XMLHTTPREQUEST_RESPONSE_JSON
        url = Util:getRequestConfigURL()
    elseif self.load_type == 1 then -- MD5文件
        response_type = cc.XMLHTTPREQUEST_RESPONSE_BLOB
        url = Util:getDesDecryptString(self.config_list.patch.patch_file_list)
    elseif self.load_type == 2 then -- 更新文件
        response_type = cc.XMLHTTPREQUEST_RESPONSE_BLOB
        url = Util:getDesDecryptString(self.config_list.patch.patch_url_prefix) .. self.will_load_list[1][2]
        for k, v in pairs(GAMES) do
            local idx = string.find(self.will_load_list[1][2], v .. "/")
            -- game_hall排除
            if idx and idx ~= -1 and v ~= "game_hall" then
                local gamepkgConfig = Cache.Config:getSubGameUpdatePkgConfig(v)
                url = gamepkgConfig and gamepkgConfig["patch_url_prefix"] .. self.will_load_list[1][2] or ""
                break
            end
        end
    end
    print("【HotUpdateHelper】 HotUpdateHelper下载链接=" .. url)

    if url == "" then
        self.handler_http_req:abort()
        self.handler_http_req = nil
        return
    end
    self.handler_http_req:open("GET", url)
    self.handler_http_req.responseType = response_type
    self.handler_http_req:send()
end
--中断下载
function HotUpdateHelper:abortDownload(...)
    if self.handler_http_req then
        self.handler_http_req:abort()
        self.handler_http_req = nil
    end
end
--下载失败，延迟1s下载
function HotUpdateHelper:onDownloadFail(...)
    Util:runOnce(1.0, function(...)
        self:startDownload({load_type = self.load_type})
        --超过三次使用的是备用选项
        if self.load_type == 0 then            
            self.timeoutCnt = self.timeoutCnt + 1
            if self.timeoutCnt >= 1 then 
                Util:getBackUpJson()
            end
        end
    end)
end

--继续当前下载
function HotUpdateHelper:onDownloadContinue(...)
    self:startDownload({load_type = self.load_type})
end

--下载回调
function HotUpdateHelper:onReadyStateChange(event)
    print("【HotUpdateHelper】>>>>HotUpdateHelper:onReadyStateChange status = " .. self.handler_http_req.status)
    --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "onReadyStateChange status = "..self.handler_http_req.status.." load_type = "..self.load_type})
    if self.handler_http_req.status == 200 then
        if self.load_type == 0 then
            self:onDownloadConfigListSuccess()
        elseif self.load_type == 1 then
            self:onDownloadMd5FileSuccess()
        elseif self.load_type == 2 then
            self:onDownloadUpdateFileSuccess()
        end
    else
        self:onDownloadFail()
    end
end

--检查是否需要大版本更新
function HotUpdateHelper:checkFullDoseUpdate(callback)
    -- pkg_status =0无需更新大版本 =1建议更新 =2强制更新大版本
    -- server_status =0正常运行 =1停服
    local server_status = checkint(Util:getDesDecryptString(self.config_list.server_status))
    local pkg_status = checkint(Util:getDesDecryptString(self.config_list.pkg_status))
    local is_review = 0 ~= Util:binaryAnd(tonumber(Util:getDesDecryptString(self.config_list.modules)), TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    if not is_review then
        pkg_status = 0
    end
    if server_status == 0 and pkg_status == 0 then --没有停服，不需要大版本更新
        return false
    end
    
    return true, self.config_list
end

--获取要更新的文件数量
function HotUpdateHelper:getLastedFileCount(...)
    return self.will_load_list and #self.will_load_list or 0
end

--获取热更新方式 0不需要更新 1建议更新 2强制更新 3静默更新
function HotUpdateHelper:getHotUpdateType(...)
    local patch = self.config_list.patch
    if qf.device.platform == "windows" then
        return 0
    end
    return checkint(patch and tonumber(Util:getDesDecryptString(patch.patch_status_2)) or 0)
end

--获取当前还需要下载的文件大小kb
function HotUpdateHelper:getLastedTotalByte(...)
    return self.current_total_byte or 0
end

--下载配置文件成功
function HotUpdateHelper:onDownloadConfigListSuccess(...)
    local response = self.handler_http_req.response

    xpcall(
        function()
            self.config_list = json.decode(response)
        end,
        function() 
            print("【HotUpdateHelper】 decode error")
            self.config_list = nil
        end
    )
    Cache.Config:updateServerAllocConfig(self.config_list)

    if not self.config_list or tonumber(Util:getDesDecryptString(self.config_list.ret)) ~= 0 then --配置文件更新失败
        self:onDownloadFail()
    else
        TB_SERVER_INFO = clone(self.config_list)
        --如果config_list.domain_name 不为空字符串 则重新请求提换
        local domainName = Util:getDesDecryptString(self.config_list.domain_name)
        if Cache.Config:getDomainName() == "" and domainName ~= "" then
            Cache.Config:setDomainName(domainName)
            self:abortDownload()
            self:onDownloadFail()
            return
        end

        if self.config_list.hall_show_list then
            GAMES = string.split(Util:getDesDecryptString(self.config_list.hall_show_list),"|")
        end
        --服务器状态 0-正常 1-停服或者服务器不可用
        if tonumber(Util:getDesDecryptString(self.config_list.patch_status)) == 1 then
            self.callback({name = "stopSocket", msg = Util:getDesDecryptString(self.config_list.server_notice)})
            return
        end
        self.callback({name = "result", load_type = self.load_type})
    end
end

-- 比对md5列表文件
-- 列举要更新的文件
function HotUpdateHelper:compareMd5ListFile(...)
    self.will_load_list = {}
    self.current_total_byte = 0
    self.current_total_count = 0
    self.current_count = 0
    self.current_byte_count = 0

    local bWithCommon = tonumber(GAME_VERSION_CODE) < 470
    
    --文件已经下载过了
    local tb_loaded_md5 = {}
    
    --先获取已经下载过的文件
    local tb_loaded = self:dfsDirectory(self.temp_update_folder)
    if #tb_loaded > 0 then
        for line, v in ipairs(tb_loaded) do
            tb_loaded_md5[v] = true
        end
    end
    
    -- 已经下载的MD5
    local current_md5_list = self:readMd5ListFile(0)
    -- 最新下载的MD5
    local lasted_md5_list = self:readMd5ListFile(1)

    -- 重建加载表
    local tb_current_md5 = {}

    for line, v in ipairs(current_md5_list) do
        tb_current_md5[v[2]] = v
    end
    for line, v in ipairs(lasted_md5_list) do
        if tb_loaded_md5[v[2]] then
            
        elseif not tb_current_md5[v[2]] or v[1] ~= tb_current_md5[v[2]][1] then
            local flag = bWithCommon
            if self.uniq then
                if string.find(v[2], self.uniq) == nil then
                    flag = false
                end
            end
            --不下载zip包
            -- if string.find(v[2], ".zip") ~= nil then
            --     flag = false
            -- end
            if not bWithCommon then
                for kk, vv in pairs(GAMES) do
                    if GAME_INSTALL_TABLE[vv] then
                        if string.find(v[2], vv .. "/") ~= nil then
                            flag = true
                            break
                        end
                    end
                end
            end

            if flag then
                table.insert(self.will_load_list, {v[1], v[2], v[3]})
                self.current_total_byte = self.current_total_byte + v[3]
                self.current_total_count = self.current_total_count + 1
            end
        end
    end
    self.current_total_byte = math.floor(self.current_total_byte / 1024)
    return self.current_total_byte
end

--读取md5列表文件
--param: _type=0当前MD5 _type=1最新的md5
function HotUpdateHelper:readMd5ListFile(_type)
    local md5_file 
    local ret = {}
    
    if _type == 0 then
        if not io.exists(self.update_md5_path) then
            local data = cc.FileUtils:getInstance():getDataFromFile(self.md5_path)
            if data then
                -- 2019-10-10 Jo 防止这时候热更文件夹没有创建，导致写入不成功
                if not io.exists(self.update_folder) then
                    self:createDir(self.update_folder)
                end
                io.writefile(self.update_md5_path, data, "wb")
            end
        end
        md5_file = self.update_md5_path
    else
        md5_file = self.temp_update_md5_path
    end
    
    for line in io.lines(md5_file) do
        local infos = string.split(line, "|")
        --防止有些md5内容有空格之类的
        if #infos == 3 then
            table.insert(ret, infos)
        end
    end
    
    return ret
end

--下载md5文件成功
function HotUpdateHelper:onDownloadMd5FileSuccess(...)
    self.temp_update_folder = self.temp_update_folder .. Util:getDesDecryptString(self.config_list.patch.patch_md5sum) .. "/"
    self:createDir(self.temp_update_folder)
    self.temp_update_md5_path = self.temp_update_folder .. "md5.txt"
    local data = self.handler_http_req.response
    local filter_str
    filter_str = self:filterNoInstallGames(data)
    io.writefile(self.temp_update_md5_path, filter_str, "wb")
    local totalByte = self:compareMd5ListFile()
    print("【HotUpdateHelper】 ===========onDownloadMd5FileSuccess==>>>>> totalByte = " .. totalByte)
    self.callback({name = "result", load_type = self.load_type})
end

--下载更新文件成功
function HotUpdateHelper:onDownloadUpdateFileSuccess(...)
    local response = self.handler_http_req.response
    
    self.current_count = self.current_count + 1
    self.current_byte_count = self.current_byte_count + self.will_load_list[1][3]
    
    self:splitDir(self.will_load_list[1][2], 1)
    self:splitDir(self.will_load_list[1][2], 2)
    
    local path = self.temp_update_folder .. self.will_load_list[1][2]
    if io.writefile(path, response, "wb") then
        table.remove(self.will_load_list, 1)
    end
    
    local count = math.ceil(self.current_byte_count / 1024)
    self.callback({name = "progress", count = count})
    
    if self.current_count == self.current_total_count then --已经更新完成
        self:setDownloadFinish(true) --下载完成
        self.callback({name = "result", load_type = self.load_type})
    else --继续下载
        self:onDownloadContinue()
    end
end

--将要进入游戏，做一些准备工作
function HotUpdateHelper:willEnterGame(...)
    local data
    if not io.exists(self.update_md5_path) then
        data = cc.FileUtils:getInstance():getDataFromFile(self.md5_path)
    else
        data = cc.FileUtils:getInstance():getDataFromFile(self.update_md5_path)
    end
    STRING_UPDATE_FILE_MD5 = QNative:shareInstance():md5(data)
    TB_SERVER_INFO = clone(self.config_list)
    
    --更新完成了才拷贝资源
    if self:isDownloadFinish() then
        self:workFinish()
    end
end

function HotUpdateHelper:workFinish(...)
    -- 把更新的文件从临时文件夹copy到更新文件夹
    self:copyDirectory(self.temp_update_folder, self.update_folder)
    self:abortDownload()
end

--重置callback
function HotUpdateHelper:resetCallback(...)
    self.callback = function(args)
    end
end

--热更新下载是否完成
function HotUpdateHelper:setDownloadFinish(is)
    self.is_download_finish = is
end

function HotUpdateHelper:isDownloadFinish(...)
    return self.is_download_finish
end

function HotUpdateHelper:createUpdateFolder(...)
    --更新时使用的临时文件夹
    self:createDir(self.temp_update_folder)
    --更新到的文件夹
    self:createDir(self.update_folder)
end

--设置资源搜索目录
function HotUpdateHelper:setResSearchPath(...)
    cc.FileUtils:getInstance():addSearchPath(self.update_folder .. "/res/")
    cc.FileUtils:getInstance():addSearchPath(self.update_folder .. "/res/" .. GAME_LANG)
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/" .. GAME_LANG) 
    cc.FileUtils:getInstance():addSearchPath("assets/res/")
    cc.FileUtils:getInstance():addSearchPath("assets/res/" .. GAME_LANG)
end

local function checkOverInstallByChannelName()
    local oldChannelName = cc.UserDefault:getInstance():getStringForKey(SKEY.OLD_CHANNEL_NAME, "null")
    if oldChannelName == "null" then --表明第一次安装
        cc.UserDefault:getInstance():setStringForKey(SKEY.OLD_CHANNEL_NAME, GAME_CHANNEL_NAME)
        cc.UserDefault:getInstance():flush()
    else
        if oldChannelName ~= GAME_CHANNEL_NAME then --表明覆盖安装
            cc.UserDefault:getInstance():setStringForKey(SKEY.OLD_CHANNEL_NAME, GAME_CHANNEL_NAME)
            return true
        end
    end
    return false
end

function HotUpdateHelper:getGameList()
    -- body
    GAME_INSTALL_LIST = cc.UserDefault:getInstance():getStringForKey(SKEY.GAME_INSTALL_LIST, "null")

    --覆蓋安裝（那就如果是新版本，那麼需要丟棄）
    local oldAppVersion = cc.UserDefault:getInstance():getStringForKey(SKEY.REVIEW_STATUS, "null")
    local oldAppVersionTable = string.split(oldAppVersion, ":")
    if #oldAppVersionTable == 2 then
        oldAppVersion = oldAppVersionTable[1]
    end
    local bOverInstall = false
    print("【HotUpdateHelper】 oldAppVersion = " .. oldAppVersion)
    print("【HotUpdateHelper】 GAME_VERSION_CODE = " .. GAME_VERSION_CODE)
    if tonumber(oldAppVersion) ~= tonumber(GAME_VERSION_CODE) then
        bOverInstall = true
        cc.UserDefault:getInstance():setStringForKey(SKEY.SERVER_ALLOC_INFO, "null")
        cc.UserDefault:getInstance():flush()
    end
    
    if checkOverInstallByChannelName() then
        bOverInstall = true
        cc.UserDefault:getInstance():setStringForKey(SKEY.SERVER_ALLOC_INFO, "null")
        cc.UserDefault:getInstance():flush()
    end

    --如果是覆蓋安裝，那麼需要清除之前的回归到初始，不能回退
    if GAME_INSTALL_LIST == "null" or type(json.decode(GAME_INSTALL_LIST))~= 'table' or bOverInstall then
        local device = cc.Application:getInstance():getTargetPlatform()
        -- if device == cc.PLATFORM_OS_WINDOWS then
            -- GAME_INSTALL_LIST = {"game_hall", "game_niuniu", "game_zjh", "game_lhd","game_zhajinniu","game_br","game_brnn","game_ddz"}
        -- else
        --     GAME_INSTALL_LIST = {"game_hall","game_br","game_lhd","game_brnn"}
        -- end
        GAME_INSTALL_LIST = {"game_hall","game_niuniu","game_brnn","game_br","game_lhd","game_zjh"}
        -- GAME_INSTALL_LIST = {"game_hall","game_brnn","game_niuniu"}
        cc.UserDefault:getInstance():setStringForKey(SKEY.GAME_INSTALL_LIST, json.encode(GAME_INSTALL_LIST))
        cc.UserDefault:getInstance():flush()
    else
        GAME_INSTALL_LIST = json.decode(GAME_INSTALL_LIST)
    end
    
    for k, v in pairs(GAME_INSTALL_LIST) do
        GAME_INSTALL_TABLE[v] = 1
    end
end

--过滤掉不需要的游戏代码
--[[
    1.热更界面主要热更新
        (1)差异更新：
        通用代码、子游戏代码
    2.不包括子游戏zip整包
]]--
function HotUpdateHelper:filterNoInstallGames(response)
    local arr = splitString(response, "\r\n")
    local str 
    local flag
    for k, v in pairs(arr) do
        flag = false
        for kk, vv in pairs(GAMES) do
            -- 如果没有安装的话，就过滤掉，等待gameHelper下载
            if  not GAME_INSTALL_TABLE[vv] then
                -- 包括子包zip
                if string.find(v, vv .. "/") ~= nil then
                    flag = true
                    break
                end
            end
        end
        --2019-08-15
        --防止每次更新都拉取md5文件所以要将.zip的记录依然写到里面去
         

        --子游戏所有zip不在这里更新
        if string.find(v, ".zip") ~= nil then
            -- print("子游戏zip ======>>>>> " .. v)
            flag = true
        end
        
        if flag == false then
            str = str and str .. "\r\n" .. v or v
        end
    end
    
    return str
end

return HotUpdateHelper