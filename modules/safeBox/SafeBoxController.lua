
local SafeBoxController = class("SafeBoxController",qf.controller)

SafeBoxController.TAG = "SafeBoxController"
local acitivityView = import(".SafeBoxView")

function SafeBoxController:ctor(parameters)
    self.super.ctor(self)
end


function SafeBoxController:initModuleEvent()
end

function SafeBoxController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function SafeBoxController:initGlobalEvent()
    
end

function SafeBoxController:initGame()
	
end

function SafeBoxController:initView(parameters)
    --流程稍稍做变动，等socket消息返回成功了再创建UI
    local body = {}
    --dump(body, "reqResetPwd req ")
    --GameNet:send({cmd=CMD.SAFE_QUERY_MONEY,body=body,timeout=nil,callback=function(rsp)
    --    loga("reqResetPwd rsp "..rsp.ret)
    --    if rsp.ret ~= 0 then
    --    else
            local prop = {}
            prop.id = PopupManager.POPUPVIEW.safeBox
            prop.style = PopupManager.BG_STYLE.BLUR
            prop.initParam = {["safe_gold"] = 1, ["free_gold"] = 2}--rsp.model
            local view = acitivityView.new(prop)
            return view   
    --    end
    --end})
end


return SafeBoxController