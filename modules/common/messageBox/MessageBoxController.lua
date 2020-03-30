
local MessageBoxController = class("MessageBoxController",qf.controller)

MessageBoxController.TAG = "MessageBoxController"
local acitivityView = import(".MessageBoxView")

function MessageBoxController:ctor(parameters)
    self.super.ctor(self)
  
end


function MessageBoxController:initModuleEvent()
	qf.event:addEvent(ET.SET_INVITE,handler(self,self.processBindInvite))
end

function MessageBoxController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function MessageBoxController:initGlobalEvent()
    
end

function MessageBoxController:initView(parameters)
    local prop = {}
    prop.id = PopupManager.POPUPVIEW.MessageBox
    prop.style = PopupManager.BG_STYLE.BLUR
    --prop.initParam = {["safe_gold"] = 1, ["free_gold"] = 2}--rsp.model
    local view = acitivityView.new(prop)
    return view   
end

return MessageBoxController