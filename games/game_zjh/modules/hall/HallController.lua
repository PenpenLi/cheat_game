local HallController = class("HallController",qf.controller)
HallController.TAG = "HallController"

local hallView = import(".HallView")


function HallController:ctor(parameters)

    self.super.ctor(self)
end

function HallController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"zjhhall")
    qf.event:dispatchEvent(ET.SETBROADCAST, GameConstants.BROADCAST_POS)
    qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)--删除快捷聊天
    qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)--删除互动表情
    local view = hallView.new(parameters)
    return view
end

function HallController:initGlobalEvent( ... )
    -- body
    qf.event:addEvent(Zjh_ET.QUICKSTARTCLICK,handler(self,self.quick_startClick))
    qf.event:addEvent(Zjh_ET.ENTERGAMECLICK,handler(self,self.enterGame))
end

function HallController:initModuleEvent()
	self:addModuleEvent(ET.NET_CHANGEGOLD_EVT,handler(self,self.processGameChangeGoldEvt))
    -- self:addModuleEvent(ET.NET_DIAMOND_CHANGE_NIUNIU_HALL,handler(self,self.NET_DIAMOND_CHANGE_NIUNIU_HALL))
end

function HallController:quick_startClick( ... )
    -- body
    ModuleManager.zjhhall:getView():setPosition(-19200,0)
    if self.view then
        self.view:quick_startClick()
    else
        self.view:quick_startClick()
    end
end

function HallController:enterGame( paras )
    -- body
    ModuleManager.zjhhall:getView():setPosition(-19200,0)
    if self.view then
        self.view:enterGame(paras)
    else
        self.view:enterGame(paras)
    end
end

function HallController:removeModuleEvent()
    -- qf.event:removeEvent(ET.NET_DIAMOND_CHANGE_NIUNIU_HALL)
    qf.event:removeEvent(ET.NET_CHANGEGOLD_EVT)
end


--钻石更新
function HallController:NET_DIAMOND_CHANGE_NIUNIU_HALL( )
    -- body
    self.view:updateUserDiamond()
end


--金币更改
function HallController:processGameChangeGoldEvt(rsp)
	-- body
	if rsp.model == nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.gold)--rsp.gold  当前版本金币与法币1：1
    elseif rsp.model ~= nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.model.gold) --rsp.model.gold
    end
	self.view:processGameChangeGoldEvt()

end

return HallController