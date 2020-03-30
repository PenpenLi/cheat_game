import(".res.GameRes")
import(".res.GameTxt")
import(".core.Event")
import(".core.cmd")
import(".common.Display")
import(".net.ETAdapter").new()
import(".net.PBAdapter").new()

local zhajinhuaconfig   = import(".cache.Config")
local zjhhall           = import(".modules.hall.HallController")
local zjhgame           = import(".modules.game.GameController")
local zjhdesk           = import(".cache.Zjhdesk")
local zjhglobal         = import(".modules.global.GlobalController")



Cache.zhajinhuaconfig   = zhajinhuaconfig.new()

if Cache.Config:getConfigModel() then
	Cache.zhajinhuaconfig:saveConfig(Cache.Config:getConfigModel())
end


ModuleManager.zjhhall   = zjhhall.new()
ModuleManager.zjhgame   = zjhgame.new()
ModuleManager.zjhglobal = zjhglobal.new()
Cache.zjhdesk           = zjhdesk.new()




ModuleManager.zjhglobal:show()

