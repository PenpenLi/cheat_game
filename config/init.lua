local tbl = package.loaded

--由于这个函数是第一个重新require的函数 所以在此处做相对应的卸载操作
--unpackageTbl 里面是不会被重新加载的文件名
local cnt = 0
local unpackageTbl = {
	"src.update.HotUpdateEntry",
	"src.update.HotUpdateGameHelper",
	"src.update.HotUpdateGamePkgHelper",
	"src.update.HotUpdateHelper",
	"src.update.HotUpdateMain",
	"src.update.HotUpdatePackageHelper",
	"src.config.init",
	"src.platform"
}

local clearTbl = {}

for k, v in pairs(tbl) do
	cnt = cnt +1
	if v then
		local bUnPackageClear = true
		for i, v2 in ipairs(unpackageTbl) do
			local idx = string.find(k, v2)
			if idx and idx ~= -1 then
				bUnPackageClear = false
				break
			end
		end

		if bUnPackageClear then
			local idx = string.find(k , "src.")
			if idx and idx ~= -1 then
				clearTbl[#clearTbl + 1] = k
			end
		end
	end
end

for i, v in ipairs(clearTbl) do
	package.loaded[v] = nil 
end

require("src.config.StorageKey")    --轻量级存储key. 调用UserDefault相关接口时使用到
require("src.config.CMD")	--命令字
require("src.config.SomeConfig")    --定义服务器地址
require("src.config.Constants")     --定义全局通用的常量
