import(".res.GameRes")
import(".res.GameTxt")
import(".res.GameConstants")
import(".core.Event")
import(".core.cmd")
import(".net.ETAdapter").new()
import(".net.PBAdapter").new()

GameConstants = require("src.modules.common.widget.GameConstants").new()

local brgameModule    = import(".modules.game.BrGameController")
local BrDesk = import(".desk.BrDesk")
local BrInfo = import(".desk.BrInfo")

ModuleManager.texasbrgame         = brgameModule.new()
Cache.brdesk = BrDesk.new()
Cache.brinfo = BrInfo.new()