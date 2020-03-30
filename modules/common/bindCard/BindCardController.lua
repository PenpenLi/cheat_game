
local BindCardController = class("BindCardController",qf.controller)

BindCardController.TAG = "BindCardController"
local acitivityView = import(".BindCardView")

function BindCardController:ctor(parameters)
    self.super.ctor(self)
end

function BindCardController:initModuleEvent()
end

function BindCardController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function BindCardController:initGlobalEvent()
    
end

function BindCardController:initGame()
	
end

function BindCardController:initView(parameters)
    local prop = {}
    prop.id = PopupManager.POPUPVIEW.BindCard
    prop.style = PopupManager.BG_STYLE.BLUR
    --prop.initParam = {["safe_gold"] = 1, ["free_gold"] = 2}--rsp.model
    local view = acitivityView.new(prop)
    view:setArea(self.area)
    return view   
end


return BindCardController