--
-- Author: Ö£ÌÎ
-- Date: 2015-10-31 10:03:55
--

local device = cc.Application:getInstance():getTargetPlatform()
local require2 = require

local _split = function (input, delimiter)
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

local tmp, tmp1, tmp2, key, hash1
local _source_hash = {}

local getListData = function ( ... )
    if device == cc.PLATFORM_OS_IPHONE or device == cc.PLATFORM_OS_IPAD then
        -- print("更新路径"..QNative:shareInstance():getUpdatePath())
        local ot, nt = 'list.txt', QNative:shareInstance():getUpdatePath() .. 'list.txt'
        local data = cc.FileUtils:getInstance():getDataFromFile(ot)
        local file = io.open(nt, "w+b")
        if file then
            file:write(data)
            io.close(file)
        end
        
        for line in io.lines(nt) do
            tmp = _split(line, "|")
            tmp1 = _split(tmp[1], ".")
            tmp2 = _split(tmp[2], ".")
            hash1 = _source_hash

            for i = 1, #tmp1 do
                hash1[tmp1[i]] = hash1[tmp1[i]] or {_fixed = tmp2[i]}
                hash1 = hash1[tmp1[i]]
            end
        end
    end
end


local _getFile = function ( filename )
    tmp = _split(filename, ".")

    tmp1 = ""
    hash1 = _source_hash
    for i = 1, #tmp do
        key = tmp[i]
        if not hash1[key] then
            for k, v in pairs(hash1) do
                if v._fixed == tmp[i] then
                    key = k
                    break
                end
            end
        end
        tmp2 = hash1[key] and hash1[key]._fixed or tmp[i]
        tmp1 = tmp1 .. (#tmp1 > 1 and "." or "") .. tmp2
        hash1 = hash1[key] or {}
    end
    -- print("原名称<-->" .. filename .. "  混淆后的名称=  " .. tmp1)
    return tmp1
end

function require( filename )
    
    -- if device == cc.PLATFORM_OS_IPHONE or device == cc.PLATFORM_OS_IPAD then
    --     if not hash1 or #hash1 == 0 then 
    --         getListData()
    --     end
    --     return require2(_getFile(filename))
    -- end
    return require2(filename)
end

require "Cocos2d"

local HotUpdateEntry = {}

function HotUpdateEntry.setLuaSearchPath( ... )
    local _srcPath = QNative:shareInstance():getUpdatePath() .. "/"
    package.path = _srcPath .. ";" .. package.path
    local resolutionType = cc.ResolutionPolicy.SHOW_ALL

    if device == cc.PLATFORM_OS_IPHONE then
        local luaoc = require "luaoc"
        local ok,ret = luaoc.callStaticMethod("LuaMutual","syyy_getIfScreenFrame")
        if ret == 1 then
            resolutionType = cc.ResolutionPolicy.FIXED_HEIGHT
        end
    elseif device == cc.PLATFORM_OS_IPAD then
         resolutionType = cc.ResolutionPolicy.EXACT_FIT
    elseif device == cc.PLATFORM_OS_ANDROID then
        local luaj = require "luaj"
        local sigs = "()I"
        local ok,ret = luaj.callStaticMethod("com/qufan/texas/util/Util","isAllScreenDevice",nil,sigs)
        if ok and ret == 1 then
            resolutionType = cc.ResolutionPolicy.FIXED_HEIGHT 
            FULLSCREENADAPTIVE = true            
        end
    elseif device == cc.PLATFORM_OS_WINDOWS then
        -- pc端测试
        -- 全面屏测试 begin   
        cc.Director:getInstance():getOpenGLView():setFrameSize(2436/2,1125/2)     
        resolutionType = cc.ResolutionPolicy.FIXED_HEIGHT
        FULLSCREENADAPTIVE = true
        --全面屏测试 end

        -- cc.Director:getInstance():getOpenGLView():setFrameSize(1920/3,1080/3)
    end
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1920, 1080, resolutionType)
    
end

function HotUpdateEntry.cleanLuaCache( ... )
    for k, _ in pairs(package.loaded) do
        if string.find(k, "src.") then
            package.loaded[k] = nil 
            package.preload[k] = nil 
        end
    end
end

function HotUpdateEntry.enterUpdate( ... )
	HotUpdateEntry.setLuaSearchPath()
	HotUpdateEntry.cleanLuaCache()
    if ENVIROMENT_TYPE == 2 then
        cc.Director:getInstance():getConsole():listenOnTCP(58369)
    else
        local HotUpdateMainGlobal = require("src.update.HotUpdateMain")
    	HotUpdateMainGlobal:main()
    end

end

function os.rmdir(path)
    if true then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode")
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

local function printError(msg)
    print("LUA ERROR: ")
    local list = Split(msg, "\n");
	for i = 1, #list do
		print(list[i])
	end
    print("\n")
end

function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    printTraceback()
    printError(msg)
    if qf.device.platform ~= "windows" then
        Scheduler:delayCall(0.01,function( ... )
            if not cc.Director:getInstance():getRunningScene() or cc.Director:getInstance():getRunningScene():getChildrenCount()<=1 then 
                os.rmdir(QNative:shareInstance():getUpdatePath().. "/")
                HotUpdateEntry.enterUpdate()
            end
        end)
    end
    if game ~= nil and game.uploadError ~= nil then game.uploadError(tostring(msg).."\n"..string.format(debug.traceback())) end
    print("----------------------------------------")
    return msg
end

local status, msg = xpcall(HotUpdateEntry.enterUpdate, __G__TRACKBACK__)
if not status then
    error(msg)
end
