import(".res.GameRes")
import(".res.GameTxt")
import(".res.GameConstants")
import(".core.Event")
import(".core.cmd")
import(".net.ETAdapter").new()
import(".net.PBAdapter").new()

GameConstants = require("src.modules.common.widget.GameConstants").new()

local BrNiuniuCtrl    = import(".modules.game.GameController")
local BrnnHallCtrl = import(".modules.hall.HallController")
local BrniuniuInfo = import(".desk.BrniuniuInfo")
local Desk = import(".desk.BrniuniuDesk")

ModuleManager.brniuniugame         = BrNiuniuCtrl.new()
ModuleManager.BrnnHall   		   = BrnnHallCtrl.new()
Cache.BrniuniuDesk = Desk.new()
Cache.BrniuniuInfo = BrniuniuInfo.new()
