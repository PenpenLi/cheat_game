local InviteCodeView = class("InviteCodeView", qf.view)

InviteCodeView.TAG = "InviteCodeView"

function InviteCodeView:ctor(parameters)
    self.super.ctor(self,parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.panelInvite = ccui.Helper:seekWidgetByName(self.root, "Panel_invite")
    self.panelInvite:setVisible(true)
    self.warningPanel = ccui.Helper:seekWidgetByName(self.root, "Panel_warning")
    self.warningPanel:setVisible(false)
    self:setZOrder(9999)
    self:initPanelInvite()
end

function InviteCodeView:initPanelInvite( ... )
    -- body
    local imageFrame = ccui.Helper:seekWidgetByName(self.panelInvite,"Image_invite_code")
    local editBoxCode = cc.EditBox:create(cc.size(448, 80), cc.Scale9Sprite:create())
    editBoxCode:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxCode:setFontName(GameRes.font1)
    editBoxCode:setFontColor(cc.c3b(0, 0, 0))
    editBoxCode:setName("inviteCode")
    editBoxCode:setFontSize(40)
    editBoxCode:setPlaceholderFontSize(36)
    editBoxCode:setPlaceHolder(GameTxt.string_login_10)
    editBoxCode:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBoxCode:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imageFrame:addChild(editBoxCode)
    editBoxCode:setPosition(imageFrame:getContentSize().width * 0.5, imageFrame:getContentSize().height / 2)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.panelInvite,"Button_request"),function (sender)
        self:requestByType(1)
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.panelInvite,"Button_pass"),function (sender)
        self:requestByType(2)
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.warningPanel,"Button_request"),function (sender)
        self:requestByType(3)
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.warningPanel,"Button_pass"),function (sender)
        self:requestByType(4)
    end)
end

function InviteCodeView:editboxEventHandler( strEventName,sender )
    -- body
    if strEventName == "began" then
        --sender:setText("")                
    elseif strEventName == "ended" then
                                                      
    elseif strEventName == "return" then
        if sender:getName() == "inviteCode" then
            self.editCode = sender:getText()
        end                                         
    elseif strEventName == "changed" then
                 
    end
end

function InviteCodeView:initWithRootFromJson()
    return GameRes.inviteCode
end

function InviteCodeView:isAdaptateiPhoneX()
    return true
end

--请求操作
function InviteCodeView:requestByType( reqType )
    -- body
    if reqType == 1 then  --确认
        if not self.editCode or self.editCode == ""  then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_10})
            return
        end
        local len = string.len(self.editCode)
        -- if len ~= 4 then
        --     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_invite_1})
        --     return
        -- end
        local i = 1
        while i <= len do
            if string.byte(self.editCode, i) > 127 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_invite_1})
                return
            end
            i = i + 1
        end
        --请求
        -- local body = {}
        -- body.uin = Cache.user.uin
        -- body.code = self.editCode
        -- dump(body, "inviteCode req")
        -- GameNet:send({cmd = CMD.INVITE_CODE,body=body,timeout=nil,callback=function(rsp)
        --     loga("inviteCode rsp "..rsp.ret)
        --     if rsp.ret ~= 0 then
        --         qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_invite_2})
        --     else
        --         --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_invite_3})
        --         if self.preViewCallBack then
        --             self.preViewCallBack()
        --         end
        --         if self.overCallback then
        --             self.overCallback()
        --         end
        --         Cache.user.show_promotion = 0
        --         qf.event:dispatchEvent(ET.MAIN_MOUDLE_VIEW_EXIT,{name="inviteCode",from=self.from.name})
        --     end
        -- end})
        qf.event:dispatchEvent(ET.SET_INVITE,{code = self.editCode})
        --qf.event:dispatchEvent(ET.MAIN_MOUDLE_VIEW_EXIT,{name="inviteCode",from=self.from.name})
        self.panelInvite:setVisible(false)
    elseif reqType == 2 then --跳过
        self.panelInvite:setVisible(false)
        self.warningPanel:setVisible(true)
    elseif reqType == 3 then --确认跳过（填写默认的邀请码）
        --请求
        qf.event:dispatchEvent(ET.SET_INVITE,{code = -1})
        --qf.event:dispatchEvent(ET.MAIN_MOUDLE_VIEW_EXIT,{name="inviteCode",from=self.from.name})
        self.panelInvite:setVisible(false)
    elseif reqType == 4 then --取消跳过
        self.panelInvite:setVisible(true)
        self.warningPanel:setVisible(false)
    end
end

function InviteCodeView:getRoot() 
    return LayerManager.PopupLayer
end

function InviteCodeView:setPreViewCallback( callback )
    -- body
    self.preViewCallBack = callback
end

function InviteCodeView:setOverCallback( callback )
    -- body
    self.overCallback = callback
end

function InviteCodeView:removeSelf( ... )
    -- body
    --qf.event:dispatchEvent(ET.MAIN_MOUDLE_VIEW_EXIT,{name="inviteCode",from=self.from.name})
end

return InviteCodeView