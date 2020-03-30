local AgencyView = class("AgencyView", CommonWidget.PopupWindow)
AgencyView.TAG = "AgencyView"

local limitCoinLen = 6

local IMG_CONFIG = {
    WX = 1,
    QQ = 2
}

--保证每次打开都会重新请求邮件信息
function AgencyView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.agencyJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.agencyView, child=self.root})
end

function AgencyView:init( parameters )
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "agencyPanel",          path = "Panel_ageny"},
        {name = "closeBtn",          path = "Panel_ageny/Button_close", handler = defaultHandler},
        {name = "bindBtn",          path = "Panel_ageny/Button_bind", handler = defaultHandler},
        {name = "wxBtn1",    path = "Panel_ageny/Panel_info/wxBtn1", handler = defaultHandler},
        {name = "wxBtn2",          path = "Panel_ageny/Panel_info/wxBtn2", handler = defaultHandler},
        {name = "head",          path = "Panel_ageny/Panel_info/Image_head",  handler = defaultHandler},
        {name = "desc",        path = "Panel_ageny/Panel_info/Label_30", handler = defaultHandler},
        {name = "panelBox",        path = "Panel_ageny/Panel_info", handler = defaultHandler},

        {name = "invitePanel",          path = "Panel_invite"},
        {name = "icloseBtn",          path = "Panel_invite/Button_close",  handler = defaultHandler},
        {name = "ibindBtn",          path = "Panel_invite/Button_bind",  handler = defaultHandler},
        {name = "iframe",    path = "Panel_invite/diFrame"},
    }

    Util:bindUI(self, self.root, uiTbl)
    Util:enlargeCloseBtnClickArea(self.closeBtn)
    Util:enlargeCloseBtnClickArea(self.icloseBtn)
    -- self.ibindBtn:setVisible(false)
    self.bindBtn:setVisible(false)
    self:initInviteView()
    self:initAgencyView()
    self._paras = parameters
    if Cache.agencyInfo:checkBindAgency() or Cache.user:isProxy() then --绑定了邀请码 或者 是代理的情况展示联系代理页面
        self:showAgencyPanel(self._paras)
    else -- 未绑定 显示填写邀请码页面
        self:showInivtePanel()
    end
end

function AgencyView:onButtonEvent(sender)
    -- print(sender.name)
    if sender.name == "closeBtn" then
        self:close()
    elseif sender.name == "icloseBtn" then
        self:close()
        -- self:showAgencyPanel()
    elseif sender.name == "bindBtn" then
        self:showInivtePanel()
    elseif sender.name == "ibindBtn" then --绑定
        self:bindNumber()
    elseif sender.name == "wxBtn1" or sender.name == "wxBtn2" then
        local txt = sender:getChildByName("Txt"):getString()
        qf.platform:copyTxt({txt = txt})
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_agency_3})
    end
end

function AgencyView:bindNumber( ... )
    local txt = self.inputEditBox:getText()
    if string.len(txt) ~= limitCoinLen then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_agency_2})
        return
    end

    Cache.agencyInfo:requestBindAgency({procode = txt}, function ( ... )
        Cache.agencyInfo:setBindAgencyStatus(txt)
        if self._paras and self._paras.from == "LuckBtn" then --点击好运来页面的情况下 应该 弹出好运来的页面
            local cb = self._paras.cb
            if type(cb) == "function" then
                cb()
            end 
            self:close()
        else
            Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
                self:showAgencyPanel(data)
            end)
        end
        qf.event:dispatchEvent(ET.REFRESH_LUCK_BTN)
    end)

end

function AgencyView:showAgencyPanel(data)
    self.agencyPanel:setVisible(true)
    self.invitePanel:setVisible(false)
    self:refreshAgencyView(data)
end

function AgencyView:showInivtePanel()
    self.agencyPanel:setVisible(false)
    self.invitePanel:setVisible(true)
    self:refreshInviteView()
end

--刷新代理界面
function AgencyView:refreshAgencyView(data)
    Util:updateUserHead(self.head, data.proxy_portrait, data.sex, {add = false, sq = true, url = true, circle = false})
    local wxBtnList = {self.wxBtn1, self.wxBtn2}
    for i, v in ipairs(data.contactInfo) do
        if v.txt ~= "" and v.txt ~= nil then
            self:refreshWxTxt(wxBtnList[i], {txt = v.txt, cig = v.cig})
        end
    end
    self:refreshDescTxt(data.copy_writing)
end

function AgencyView:refreshWxTxt(wxBtn, v)
    if wxBtn == nil then
        return
    end
    local resName = GameRes.agency_wx_img
    local tipTxt = GameTxt.string_agency_3
    if v.cig == IMG_CONFIG.QQ then
        resName = GameRes.agency_qq_img
        tipTxt = GameTxt.string_agency_4
    end

    wxBtn:getChildByName("icon"):loadTexture(resName)
    local str = v.txt
    local fontSize = 40
    if string.len(str) > 11 then
        fontSize = 34
    end

    local txt = wxBtn:getChildByName("Txt")
    txt:setFontSize(fontSize)
    txt:setString(str)
    addButtonEvent(wxBtn, function ( ... )
        qf.platform:copyTxt({txt = str})
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = tipTxt})
    end)
end

function AgencyView:refreshInviteView( ... )
    self.inputEditBox:setText("")
end

function AgencyView:initAgencyView()

end

function AgencyView:initInviteView()
    local imageSetFrame = self.iframe
    local editBoxCoin = cc.EditBox:create(cc.size(imageSetFrame:getContentSize().width -40, imageSetFrame:getContentSize().height), cc.Scale9Sprite:create())
    editBoxCoin:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxCoin:setFontColor(cc.c3b(30, 74, 130))
    editBoxCoin:setFontName(GameRes.font1)
    imageSetFrame:addChild(editBoxCoin)
    editBoxCoin:setName("coinNum")
    editBoxCoin:setCascadeOpacityEnabled(true)
    editBoxCoin:setFontSize(42)
    editBoxCoin:setPlaceholderFontSize(42)
    editBoxCoin:setPlaceHolder(GameTxt.string_agency_1)
    editBoxCoin:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBoxCoin:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxCoin:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxCoin:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editBoxCoin:setPosition(imageSetFrame:getContentSize().width * 0.5, imageSetFrame:getContentSize().height / 2)
    self.inputEditBox = editBoxCoin
end

function AgencyView:editboxEventHandler( strEventName,sender )

    -- body
    if strEventName == "began" then
        --sender:setText("")   
        -- if sender:getName() == "coinNum" then
        --     self.editCoinNum = ""
        -- end              
    elseif strEventName == "ended" then
    elseif strEventName == "return" then
        if tonumber(sender:getText()) == nil then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_agency_2})
            sender:setText("")
            return
        end
    elseif strEventName == "changed" then
        local num = sender:getText()
        if string.len(num) > limitCoinLen and tonumber(num) ~= nil then
            num = string.sub(num, 1, limitCoinLen)
            sender:setText(num)
        end
    end
end

function AgencyView:refreshDescTxt(desc)
    self.desc:setVisible(false)
    --要求有行间距 则使用richtext来设置,cocos 上面的 uiText无法直接设置行间距
    local lbl_content = ccui.RichText:create()
    lbl_content:ignoreContentAdaptWithSize(false)
    lbl_content:setContentSize(cc.size(780, 300))
    lbl_content:setAnchorPoint(cc.p(0,0))
    lbl_content:setVerticalSpace(20)
    local normalColor = cc.c3b(102, 147, 225)
    local keyColor = cc.c3b(255, 225, 23)
    local richDesc = {
        {desc = desc, color = normalColor}
    }

    for i, v in ipairs(richDesc) do
        local color = v.color
        local desc = v.desc
        local txt = ccui.RichElementText:create(1, color, 255, desc, GameRes.font1, 42)
        lbl_content:pushBackElement(txt)
    end
    self.panelBox:addChild(lbl_content)
    lbl_content:setPosition(cc.p(-160,46))
end

return AgencyView