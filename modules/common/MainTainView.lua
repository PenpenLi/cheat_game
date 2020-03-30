local MainTainView = class("MainTainView", CommonWidget.PopupWindow)

MainTainView.TAG = "MainTainView"

function MainTainView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.maintainViewJson)

    -- if self.root:getChildByName("Panel_21") then
    --     self.root:getChildByName("Panel_21"):setVisible(false)
    -- end

    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.maintainView, child=self.root})
    self.root:setScaleX(1)
end

function MainTainView:init( parameters )
    -- body
    self.winSize = cc.Director:getInstance():getWinSize()
    self.panelBox = ccui.Helper:seekWidgetByName(self.root, "Panel_box")
    parameters = parameters or {desc = ""}
    self:initDesc(parameters)
    self:initButton(parameters)
    self:setZOrder(9999)
end

function MainTainView:initDesc( paras )
    -- body
    local panelInfo = ccui.Helper:seekWidgetByName(self.panelBox, "Panel_info")
    local scrollview = ccui.Helper:seekWidgetByName(panelInfo, "ScrollView_23")
    local contentLabel = cc.LabelTTF:create(paras.desc,GameRes.font1,40,cc.size(1000,0),cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    contentLabel:setColor(cc.c3b(120, 169, 255))
    contentLabel:setAnchorPoint(cc.p(0,0))
    scrollview:addChild(contentLabel)
    local size = contentLabel:getContentSize()
    scrollview:setInnerContainerSize(cc.size(size.width, size.height))
    local ssize = scrollview:getContentSize()
    if ssize.height > size.height then
        contentLabel:setPosition(cc.p(0, ssize.height - size.height))
    end
end

function MainTainView:show( args )
    -- body
    self:setVisible(true)
end

function MainTainView:initButton( parameters )
    local closeBtn = ccui.Helper:seekWidgetByName(self.panelBox,"Button_cancel")
    local okBtn = ccui.Helper:seekWidgetByName(self.panelBox,"Button_ok")
    -- body
    -- addButtonEvent(okBtn,function (sender)
    --     if parameters.cb then
    --         parameters.cb()
    --     end
    --     self:close()
    -- end)

    Util:addButtonScaleAnimFuncWithDScale(okBtn,function (sender)
        if parameters.cb then
            parameters.cb()
        end
        self:close()
    end)
    addButtonEvent(closeBtn,function (sender)
        if parameters.cb then
            parameters.cb()
        end
        self:close()
    end)
end

return MainTainView