local HallController = class("HallController",qf.controller)
HallController.TAG = "HallController"

local hallView = import(".HallView")


function HallController:ctor(parameters)

    self.super.ctor(self)
end

function HallController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"BrnnHall")
    qf.event:dispatchEvent(ET.SETBROADCAST, GameConstants.BROADCAST_POS)
    local view = hallView.new(parameters)
    return view
end

function HallController:initGlobalEvent( ... )
    -- body
    qf.event:addEvent(BRNN_ET.ENTERGAMECLICK,handler(self,self.enterGame))
end

function HallController:initModuleEvent()
	self:addModuleEvent(ET.NET_CHANGEGOLD_EVT,handler(self,self.processGameChangeGoldEvt))
end

function HallController:enterGame( paras )
    -- body
    ModuleManager.BrnnHall:getView():setPosition(-19200,0)
    if self.view then
        self.view:enterGame(paras)
    else
        self.view:enterGame(paras)
    end
end

function HallController:removeModuleEvent()
    qf.event:removeEvent(ET.NET_CHANGEGOLD_EVT)
end

--金币更改
function HallController:processGameChangeGoldEvt(rsp)
	-- body
	if rsp.model == nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.gold)--rsp.gold  当前版本金币与法币1：1
    elseif rsp.model ~= nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.model.gold)--rsp.model.gold
    end
	self.view:processGameChangeGoldEvt()
end

return HallController