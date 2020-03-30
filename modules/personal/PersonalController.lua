
local PersonalController = class("PersonalController",qf.controller)

PersonalController.TAG = "PersonalController"
local PersonalView = import(".PersonalView")

function PersonalController:ctor(parameters)
    self.super.ctor(self)
    self:initModuleEvent()
end


function PersonalController:initModuleEvent()
    qf.event:addEvent(ET.SEARCH_GAME_RECORD,handler(self,self.updateGameRecord))
    qf.event:addEvent(ET.SEARCH_PAY_RECORD,handler(self,self.updatePayRecord))
end

function PersonalController:removeModuleEvent()
    qf.event:removeEvent(ET.SEARCH_GAME_RECORD)
    qf.event:removeEvent(ET.SEARCH_PAY_RECORD)
end

-- 这里注册与服务器相关的的事件，不销毁
function PersonalController:initGlobalEvent()
    
end

function PersonalController:initGame()
	
end

function PersonalController:initView(parameters)
    self.view = PersonalView.new()
    return self.view   
end

function PersonalController:updateGameRecord( paras )
    -- body
    if self.view == nil then return end
    self.view:updateGameRecord(paras.gameType) 
end

function PersonalController:updatePayRecord( paras )
    if self.view == nil then return end
	self.view:updatePayRecord(paras.payType)
end

function PersonalController:remove( ... )
    self.super.remove(self)
    self:removeModuleEvent()
end

return PersonalController