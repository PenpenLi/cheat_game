
local SettingController = class("SettingController",qf.controller)

SettingController.TAG = "SettingController"
local acitivityView = import(".SettingView")

function SettingController:ctor(parameters)
    self.super.ctor(self)
end


function SettingController:initModuleEvent()
end

function SettingController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function SettingController:initGlobalEvent()
    qf.event:addEvent(ET.QUFAN_LOGIN_CHANGE_PASSWORD,function(paras)
        GameNet:send({cmd=CMD.EVENT_QUFAN_CHANGE_PASSWORD, 
        	body = {old_password = paras.old_password, new_password = paras.new_password}, callback=function(rsp)
            if rsp.ret == 0 then
                if paras.cb then paras.cb() end
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.qufan_login_string_15})
            else
            	qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        end})
    end)
end

function SettingController:initGame()
	
end

function SettingController:initView(parameters)
    local prop = {}
    prop.id = PopupManager.POPUPVIEW.setting
    prop.style = PopupManager.BG_STYLE.BLUR
    local view = acitivityView.new(prop)
    return view
end


return SettingController