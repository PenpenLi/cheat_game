import(".core.cmd")
import(".res.GameRes")
import(".res.GameTxt")
import(".core.Event")
import(".common.Display")


import(".net.ETAdapter").new()
import(".net.PBAdapter").new()


local niuniuglobal   = import(".modules.global.GlobalController")
local niuniuhall     = import(".modules.hall.HallController")


local kancontroller  = import(".modules.game.KangameController")
local kandesk        = import(".cache.Kandesk")
local kanconfig 	 = import(".cache.KanConfig")
Cache.kandesk    	= kandesk.new()
Cache.kanconfig 	= kanconfig.new()

if Cache.Config:getConfigModel() then
	Cache.kanconfig:saveKanConfig(Cache.Config:getConfigModel())
end

ModuleManager.niuniuglobal = niuniuglobal.new()
ModuleManager.niuniuhall   = niuniuhall.new()
ModuleManager.kancontroller = kancontroller.new()

ModuleManager.niuniuglobal:show()