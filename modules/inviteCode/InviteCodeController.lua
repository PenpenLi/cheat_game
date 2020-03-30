
local InviteCodeController = class("InviteCodeController",qf.controller)

InviteCodeController.TAG = "InviteCodeController"
local acitivityView = import(".InviteCodeView")

function InviteCodeController:ctor(parameters)
    self.super.ctor(self)
  
end


function InviteCodeController:initModuleEvent()
	qf.event:addEvent(ET.SET_INVITE,handler(self,self.processBindInvite))
end

function InviteCodeController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function InviteCodeController:initGlobalEvent()
    
end

function InviteCodeController:initGame()
	
end

function InviteCodeController:initView(parameters)
    local prop = {}
    prop.id = PopupManager.POPUPVIEW.InviteCode
    prop.style = PopupManager.BG_STYLE.BLUR
    --prop.initParam = {["safe_gold"] = 1, ["free_gold"] = 2}--rsp.model
    local view = acitivityView.new(prop)
    return view   
end

function InviteCodeController:processBindInvite( parameters )
	-- body
	local body = {}
    body.uin = Cache.user.uin
    body.code = parameters.code
    dump(body, "inviteCode req")
    GameNet:send({cmd = CMD.INVITE_CODE,body=body,timeout=nil,callback=function(rsp)
        loga("inviteCode rsp "..rsp.ret)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_invite_2})
            local userState = cc.UserDefault:getInstance():getStringForKey("userState", "")
            self.view.panelInvite:setVisible(true)
        else
            --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_invite_3})
            if self.view.preViewCallBack then
                self.view.preViewCallBack()
            end
            if self.view.overCallback then
                self.view.overCallback()
            end
            Cache.user.show_promotion = 0
            self.view:removeSelf()
        end
    end})
end

return InviteCodeController