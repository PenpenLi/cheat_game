import(".res.GameRes")
import(".res.GameTxt")
import(".res.GameConstants")
import(".core.Event")
import(".core.cmd")
--import(".common.Display")
import(".net.ETAdapter").new()
import(".net.PBAdapter").new()



--local lhdgame     = import(".modules.game.LHDGameController")
local lhddesk     = import(".cache.LHDDesk")
local lhdInfo   = import(".cache.LHDInfo")

Cache.lhdDesk = lhddesk.new()
Cache.lhdinfo = lhdInfo.new()
CommonWidget.Tabs = import(".common.Tabs")
ModuleManager.lhdgame   = import(".modules.game.LHDGameController").new()


--预加载啊
-- ccs.GUIReader:getInstance():widgetFromJsonFile(LHD_Games_res.brGameJson)
--ModuleManager.lhdgame:show()
