
local ChangePwdController = class("ChangePwdController",qf.controller)

ChangePwdController.TAG = "ChangePwdController"
local changePwdView = import(".ChangePwdView")

function ChangePwdController:ctor(parameters)
    self.super.ctor(self)
end


function ChangePwdController:initModuleEvent()
end

function ChangePwdController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function ChangePwdController:initGlobalEvent()
    
end

function ChangePwdController:initGame()
	
end

function ChangePwdController:initView(parameters)
    local prop = {}
    prop.id = PopupManager.POPUPVIEW.ChangePwd
    prop.style = PopupManager.BG_STYLE.BLUR
    --prop.initParam = {["safe_gold"] = 1, ["free_gold"] = 2}--rsp.model
    local view = changePwdView.new(prop)
    return view   
end


return ChangePwdController