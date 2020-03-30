--[[
--整包热更新
--]]

local HotUpdatePackageHelper = {}
local m_instance
local function new( o )
    o = o or {}
    setmetatable(o, {__index=HotUpdatePackageHelper})
    return o
end
local function getInstance( ... )
    if not m_instance then
        m_instance = new()
    end
    return m_instance
end

function HotUpdatePackageHelper.getInstance( ... )
    return getInstance()
end

function HotUpdatePackageHelper:init(paras)
    self.progresscb = paras.progresscb
    self.resultcb = paras.resultcb
end

function HotUpdatePackageHelper:downloadPackageTask(paras)
    --如果version和zip都是空
    if not paras.zipurl or not paras.versionurl then
        if self.successcb then
            self.successcb(-1)
        end
    end
    local args = {
        zipurl = paras.zipurl,
        versionurl = paras.versionurl,
        path  = paras.path,
        progresscb = function (percent)
            percent = percent < 0 and 0 or percent
            loga("===整包下载进度： " .. percent)
            if self.progresscb then
                self.progresscb(percent, true)
            end
        end,
        successcb = function ( ... )
            if self.resultcb then
                self.resultcb()
            end
        end,
        errorcb = function ( errorCode)
            if self.resultcb then
                self.resultcb(errorCode)
            end
        end,
    }

    ZD:addTask(args)
end

return HotUpdatePackageHelper