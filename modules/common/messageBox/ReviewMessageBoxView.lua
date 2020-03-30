local _MessageBoxView = import(".MessageBoxView")
local MessageBoxView = class("MessageBoxView", _MessageBoxView)
MessageBoxView.TAG = "MessageBoxView"

function MessageBoxView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewMessageBoxJson)
    
    if self.root:getChildByName("Panel_21") then
        self.root:getChildByName("Panel_21"):setVisible(false)
    end

    self.super.init(self, parameters)

    self.super.super.ctor(self, {id=PopupManager.POPUPWINDOW.messageBox, child=self.root})
    self.root:setScaleX(1)
end

-- function MessageBoxView:init( parameters )
--     -- body
--     self.winSize = cc.Director:getInstance():getWinSize()
--     self.panelBox = ccui.Helper:seekWidgetByName(self.root, "Panel_box")
--     self:initDesc(parameters)
--     self:initButton(parameters)
--     self:setZOrder(9999)
-- end

-- function MessageBoxView:initDesc( paras )
--     -- body
--     local panelInfo = ccui.Helper:seekWidgetByName(self.panelBox, "Panel_info")
--     local txtDesc = ccui.Helper:seekWidgetByName(panelInfo, "Label_desc")

--     if paras.desc then
--         txtDesc:setString(paras.desc)
--     else
--         txtDesc:setString("")
--         self:initRichDesc(paras)
--     end
-- end

-- function MessageBoxView:initRichDesc(paras)
--     local layout = ccui.Helper:seekWidgetByName(self.panelBox, "Panel_info")
--     local layoutSize = layout:getSize()

--     local lbl_content = ccui.RichText:create()

--     lbl_content:ignoreContentAdaptWithSize(false)
--     lbl_content:setContentSize(cc.size(700, 0))
--     lbl_content:setAnchorPoint(cc.p(0.5,0.5))
--     lbl_content:setVerticalSpace(5)
--     local layoutparameter = ccui.RelativeLayoutParameter:create()
--     layoutparameter:setAlign(ccui.RelativeAlign.alignParentTopLeft)
--     layoutparameter:setMargin({left = (layoutSize.width - 700)/2, right = 0, top = 80, bottom = 0})
--     lbl_content:setLayoutParameter(layoutparameter)

--     local fontName = GameRes.font1
--     local richDesc = paras.richDesc
--     for i, v in ipairs(richDesc) do
--         local color = v.color
--         local desc = v.desc

--         local txt = ccui.RichElementText:create(1, color, 255, desc, GameRes.font1, 42)

--         lbl_content:pushBackElement(txt)
--     end

--     layout:addChild(lbl_content)
-- end

-- function MessageBoxView:show( args )
--     -- body
--     self:setVisible(true)
-- end

-- function MessageBoxView:initButton( parameters )
--     -- body
--     addButtonEvent(ccui.Helper:seekWidgetByName(self.panelBox,"Button_ok"),function (sender)
--         if parameters.cbOk then
--             parameters.cbOk()
--         end
--         self:close()
--     end)
--     local closeBtn = ccui.Helper:seekWidgetByName(self.panelBox,"Button_cancel")
--     addButtonEvent(closeBtn,function (sender)
--         if parameters.cbCancel then
--             parameters.cbCancel()
--         end
--         self:close()
--     end)
--     Util:enlargeCloseBtnClickArea(closeBtn)
-- end

return MessageBoxView