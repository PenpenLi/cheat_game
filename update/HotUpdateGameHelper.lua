--[[
--热更新下载帮助类:负责下载
--]]

--分开md5的数据
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

local HotUpdateGameHelper = class("HotUpdateGameHelper")

function HotUpdateGameHelper:ctor(o)
    
end

-- 拆分并创建文件夹
-- t 1临时文件夹 2更新文件
function HotUpdateGameHelper:splitDir(path, t)
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
function HotUpdateGameHelper:createDir(path)
    lfs.mkdir(path)
end
--复制文件
function HotUpdateGameHelper:copyDirectory(_src, _dest)
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
function HotUpdateGameHelper:dfsDirectory(path)
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
--热更进度
function HotUpdateGameHelper:callback( args )
    local name = args.name
    if name == "progress" then --下载更新文件的过程
        --self.current_count = args.count
        self.installProgress(self.obj,self.uniq,args.count,self.current_total_byte)
    elseif name == "result" then --某个阶段完成
        self:downloadFinish(args.load_type)
    end
end
--重新设置热更的回调方法
function HotUpdateGameHelper:setInstallProgress(args)
    -- body
    if not args.installProgress then return end
    self.installProgress = args.installProgress
    self.obj=args.obj
end

--某个阶段下载完成
function HotUpdateGameHelper:downloadFinish( load_type, args )
    if load_type == 0 then --配置下载完成
        self:startDownload({load_type=1})
    elseif load_type == 1 then --md5文件下载完成
        self:downloadMd5FileSuccess()
    elseif load_type == 2 then --更新文件下载完成
        local data
        if not io.exists(self.update_md5_path) then
            data = cc.FileUtils:getInstance():getDataFromFile(self.md5_path)
        else
            data = cc.FileUtils:getInstance():getDataFromFile(self.update_md5_path)
        end
        STRING_UPDATE_FILE_MD5 = QNative:shareInstance():md5(data)

        loga("===== HotUpdateGameHelper:downloadFinish === ")
        self:copyDirectory(self.temp_update_folder, self.update_folder)
        self:downloadGameFinish()
        if self.finish then
            self.finish(self.uniq)
        end
    end
end

--下载配置文件成功
function HotUpdateGameHelper:downloadMd5FileSuccess( ... )
    local count = self.will_load_list and #self.will_load_list or 0 --获取剩余要更新文件数量
    loga("下载的文件数量" .. #self.will_load_list)
    if count == 0 then --没有需要更新的文件或不需要更新
        if self.finish then
            self.finish(self.uniq)
        end
        self.installProgress(self.obj,self.uniq,self.current_byte_count,self.current_total_byte)
        return
    else        
        if self.isGetTotalSize then return end
        self.installProgress(self.obj,self.uniq,self.current_byte_count,self.current_total_byte)
    end
    self:startDownload({load_type=2})
end
--添加游戏的回调和变量
function HotUpdateGameHelper:installGame(para)
    self:init(para)

    self.installProgress      = para.installProgress
    self.finish               = para.finish
    self.getTotalSize = para.getTotalSize
    self.isGetTotalSize = para.isGetTotalSize and true or false
    self.uniq = para.uniq
    self.obj=para.obj

    if Cache.Config.config_list then
        self.load_type = 0
        self:onDownloadConfigListSuccess()
    else
        self:startDownload({load_type=0})
    end
end
--初始化热更时的数据
function HotUpdateGameHelper:init(para)    
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
    
    
    self.md5_path = "md5.txt" --原始md5列表配置文件
    --更新用的文件变量
    self.update_folder = QNative:shareInstance():getUpdatePath() .. "/" --更新的文件夹路径
    self.update_md5_path = self.update_folder .. "md5.txt" --更新的md5列表配置文件
    --更新用的临时变量
    self.temp_update_folder = cc.FileUtils:getInstance():getWritablePath() .. "download/" -- 更新用的临时文件夹
    self.temp_update_md5_path = self.temp_update_folder .. "md5_" .. para.uniq .. ".txt" --更新MD5列表配置文件的临时文件
end

--开始下载
function HotUpdateGameHelper:startDownload(args)
    self.load_type = args.load_type
    self.handler_http_req = cc.XMLHttpRequest:new()
    
    --拉取配置文件会快很多
    if self.load_type == 0 then
        self.handler_http_req.timeout = 20
    else
        self.handler_http_req.timeout = 30
    end
    
    self.handler_scheduler = Util:runOnce(self.handler_http_req.timeout, function(...)
        loga("handler_scheduler")
        self:abortDownload()
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
    end
    loga("HotUpdateGameHelper下载链接=" .. url)
    self.handler_http_req.responseType = response_type

    if self.load_type == 0 then
        Util:safeRequestConfigURL(self.handler_http_req, func)
    else
        self.handler_http_req:open("GET", url)
        self.handler_http_req:send()
    end
end

--中断下载
function HotUpdateGameHelper:abortDownload(...)
    if self.handler_http_req then
        self.handler_http_req:abort()
        self.handler_http_req = nil
    end
end

--下载失败，延迟1s下载
function HotUpdateGameHelper:onDownloadFail(...)
    Util:runOnce(1.0, function(...)
        self:startDownload({load_type = self.load_type})
    end)
end

--继续当前下载
function HotUpdateGameHelper:onDownloadContinue(...)
    self:startDownload({load_type = self.load_type})
end

--下载回调
function HotUpdateGameHelper:onReadyStateChange(event)
    loga("onReadyStateChange status = "..self.handler_http_req.status)
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

--下载配置文件成功
function HotUpdateGameHelper:onDownloadConfigListSuccess(...)
    if Cache.Config.config_list then
        self.config_list = Cache.Config.config_list
    else
        local response = self.handler_http_req.response
        xpcall(
            function()
                self.config_list = json.decode(response)
            end,
            function() 
                print("decode error")
                self.config_list = nil
            end
        )
        Cache.Config:updateServerAllocConfig(self.config_list)
    end

    if not self.config_list or tonumber(Util:getDesDecryptString(self.config_list.ret)) ~= 0 then --配置文件更新失败
        loga(">>>>>>onDownloadConfigListSuccess<<<<<<<< 下载配置文件失败！")
        self:onDownloadFail()
    else
        self:callback({name = "result", load_type = self.load_type})
    end
end

-- 比对md5列表文件
-- 列举要更新的文件
function HotUpdateGameHelper:compareMd5ListFile(...)
    self.will_load_list = {}
    self.current_total_byte = 0
    self.current_total_count = 0
    self.current_count = 0
    self.current_byte_count = 0
    
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
            local flag = true
            if self.uniq then
                if string.find(v[2], self.uniq) == nil then
                    flag = false
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
    loga("热更大小"..self.current_total_byte)
    return self.current_total_byte
end

--读取md5列表文件
--param: _type=0当前MD5 _type=1最新的md5
function HotUpdateGameHelper:readMd5ListFile(_type)
    local md5_file 
    local ret = {}
    
    --已经下载的
    if _type == 0 then
        if not io.exists(self.update_md5_path) then
            local data = cc.FileUtils:getInstance():getDataFromFile(self.md5_path)
            io.writefile(self.update_md5_path, data, "wb")
        end
        md5_file = self.update_md5_path
    --最新下载的
    else
        md5_file = self.temp_update_md5_path
    end
    
    for line in io.lines(md5_file) do
        table.insert(ret, string.split(line, "|"))
    end
    io.close()
    
    return ret
end

--下载md5文件成功
function HotUpdateGameHelper:onDownloadMd5FileSuccess(...)
    loga("======>>>>>onDownloadMd5FileSuccess")
    local data = self.handler_http_req.response
    
    local filter_str
    --根据有没有安装游戏提出 没安装游戏的更新
    filter_str = self:fliterInstallGame(data)
    --每个游戏的temp文件夹都一样。不行。先下载的会清除后面的。
    local gameMD5 = QNative:shareInstance():md5(filter_str)
    self.temp_update_folder = self.temp_update_folder .. gameMD5 .. "/"
    self:createDir(self.temp_update_folder)
    self.temp_update_md5_path = self.temp_update_folder .. "md5_" .. self.uniq .. ".txt"
    
    
    if filter_str then
        io.writefile(self.temp_update_md5_path, filter_str, "wb")

        local totalByte = self:compareMd5ListFile()
        if self.isGetTotalSize == true and self.getTotalSize then
            self:abortDownload()
            if self.finish then
                self.finish(self.uniq)
            end
            self.getTotalSize(totalByte, self.uniq)
            self.isGetTotalSize = nil
            self.getTotalSize = nil
            return
        end
    end
    self:callback({name = "result", load_type = self.load_type})
end

--下载更新文件成功
function HotUpdateGameHelper:onDownloadUpdateFileSuccess(...)
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
    self:callback({name = "progress", count = count})
    loga(self.current_byte_count.."               "..self.current_total_byte)
    if count >= self.current_total_byte then --已经更新完成
        self:callback({name = "result", load_type = self.load_type})
    else --继续下载
        self:onDownloadContinue()
    end
end
--下载完成，将下载的游戏加入当前游戏
function HotUpdateGameHelper:downloadGameFinish( ... )
    local gameMd5File = self.update_folder .. "md5_" .. self.uniq .. ".txt"
    if not io.exists(gameMd5File) then
        loga(">>>>>>downloadGameFinish file not exists<<<<<<<" .. gameMd5File)
    end

    -- Jo 2019-09-12 (应该修改主逻辑，先这么补下)
    --在结尾加入换行符
    --这里主要解决下载子游戏后，重新进来，又会更新的问题
    local updateMd5Data = cc.FileUtils:getInstance():getDataFromFile(self.update_md5_path)
    if updateMd5Data then
        --如果不是以"\r\n"结尾,才加入
        if not string.ends(updateMd5Data, "\r\n") then
            io.writefile(self.update_md5_path, "\r\n", "a+")
        end
    end
    
    local data = cc.FileUtils:getInstance():getDataFromFile(self.update_folder .. "md5_" .. self.uniq .. ".txt")
    io.writefile(self.update_md5_path, data, "a+")
    -- body
    table.insert(GAME_INSTALL_LIST,self.uniq)
    GAME_INSTALL_TABLE[self.uniq] = 1
    cc.UserDefault:getInstance():setStringForKey(SKEY.GAME_INSTALL_LIST ,json.encode(GAME_INSTALL_LIST))
    cc.UserDefault:getInstance():flush();
    local uniqName = self.uniq
    require("src.games." .. uniqName .. ".init")
    
    qf.event:dispatchEvent(ET.INSTALL_GAME_POP,{method="hide"})
end

function HotUpdateGameHelper:createUpdateFolder(...)
    --更新时使用的临时文件夹
    self:createDir(self.temp_update_folder)
    --更新到的文件夹
    self:createDir(self.update_folder)
end


--只安装该游戏的文件
function HotUpdateGameHelper:fliterInstallGame(response)
    local arr = splitString(response, "\r\n")
    local str
    for k, v in pairs(arr) do
        if string.find(v, self.uniq .. "/") ~= nil then
            str = str and str .. "\r\n" .. v or v 
        end
    end
    return str
end

return HotUpdateGameHelper