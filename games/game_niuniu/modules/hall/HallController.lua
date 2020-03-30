local HallController = class("HallController",qf.controller)
HallController.TAG = "HallController"

local hallView = import(".HallView")


function HallController:ctor(parameters)
    self.super.ctor(self)
end

function HallController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"niuniuhall")
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_POS)
    local view = hallView.new(parameters)
    return view
end


function HallController:initGlobalEvent( ... )
    -- body
    qf.event:addEvent(Niuniu_ET.QUICKSTARTCLICK,handler(self,self.quick_startClick))
    qf.event:addEvent(Niuniu_ET.ENTERGAMECLICK,handler(self,self.enterGame))
end

function HallController:initModuleEvent()
	self:addModuleEvent(ET.NET_CHANGEGOLD_EVT,handler(self,self.processGameChangeGoldEvt))
end


function HallController:removeModuleEvent()
	qf.event:removeEvent(ET.NET_CHANGEGOLD_EVT)
end

function HallController:quick_startClick(paras)
    -- body
    ModuleManager.niuniuhall:getView():setPosition(-19200,0)
    if self.view then
        self.view:quick_startClick(paras)
    else
        self.view:quick_startClick(paras)
    end
end

function HallController:enterGame(paras)
    -- body
    ModuleManager.niuniuhall:getView():setPosition(-19200,0)
    if self.view then
        self.view:enterGame(paras)
    else
        self.view:enterGame(paras)
    end
end

--金币更改
function HallController:processGameChangeGoldEvt(rsp)
	-- body
	if rsp.model == nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.gold) --rsp.gold当前版本，金币与法币1：1
    elseif rsp.model ~= nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.model.gold) --rsp.model.gold
    end
	self.view:processGameChangeGoldEvt()
end

--打开二级界面
function HallController:openErji(parameters)
    -- body
    if self.view and tolua.isnull(self.view) == false then
        self.view:openErji(parameters)    
    end
end


return HallController