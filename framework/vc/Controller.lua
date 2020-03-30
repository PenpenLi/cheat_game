local Controller = class("Controller")

local M = Controller
M.TAG = "Controller"

M.cache = {}

function M:ctor()
    self.view = nil
    self._module_event = {}
	self:initGlobalEvent()
end

--[[ 全局事件，不销毁]]
function M:initGlobalEvent()
    loge(" you muse overite this method !",self.TAG)
end


--[[ 控制器 事件 ，根据view的消亡而消失 ]]
function M:initModuleEvent()
    logw(" -- empty initModuleEvent -- ", self.TAG)
end


function M:removeModuleEvent()
    logw(" -- empty removeModuleEvent -- ", self.TAG)
end

function M:initView()
    loge("you must overite this method !",self.TAG)
end

function M:hide()
	self.view:setVisible(false)
end

function M:remove()
	if self.view and tolua.isnull(self.view) == false then
	   local with_bg = self.view:existBackground()
	   self.view:removeFromParent(true)
	   self.view = nil
	   self:_clearModuleEvent()
	   self:removeModuleEvent()
	   if with_bg then
	       PopupManager:checkRemoveBackground()
	   end
	end
end

function M:show(paras)
    if not self.view then 
        self.view = self:initView(paras)
        self.view.from = paras
        self:initModuleEvent()
    else 
        self.view:setVisible(true)
        self:initModuleEvent()
    end
end

function M:getView(paras)
    if not self.view then 
	   self.view = self:initView(paras)
	   self.view.from = paras
       self._module_event = {}
       self:initModuleEvent()
	   
	   if not self.view then 
	       loge("can not get view ",self.TAG)
	   else
	       
	   end
	end
	
	return self.view
end

function M:addModuleEvent(eventName, cb)
    qf.event:addEvent(eventName, cb)
    self._module_event[#self._module_event + 1] = eventName
end

function M:_clearModuleEvent()
    if self._module_event  == nil  then
        return
    end

    for i = 1, #self._module_event do
        local eventName = self._module_event[i]
        if eventName then qf.event:removeEvent(eventName) end
    end
    self._module_event = {}
end

function M:getPreviousModuleName()
    if self.view ~= nil and self.view.from ~= nil then
        return self.view.from.name
    end
end

return M