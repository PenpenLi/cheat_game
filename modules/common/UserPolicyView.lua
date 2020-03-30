local UserPolicyView = class("UserPolicyView", CommonWidget.PopupWindow)

UserPolicyView.TAG = "UserPolicyView"

function UserPolicyView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.userPolicyViewJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.userPolicyView, child=self.root})
end

function UserPolicyView:init( parameters )
    -- body
    local closeBtn = ccui.Helper:seekWidgetByName(self.root,"Button_close")
    addButtonEvent(closeBtn,function (sender)
        self:close()
    end)
    self.contentSrc = ccui.Helper:seekWidgetByName(self.root,"content_scrollview")
    self:initShowContentTxt()
end

function UserPolicyView:initShowContentTxt( ... )
    local contentLabel = cc.LabelTTF:create(GameTxt.string_policy_txt, GameRes.font1, 36, cc.size(self.contentSrc:getContentSize().width,0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    contentLabel:setColor(cc.c3b(134, 179, 255))
    contentLabel:setAnchorPoint(cc.p(0,0))
    self.contentSrc:addChild(contentLabel)
    local innerSize = self.contentSrc:getInnerContainerSize()
    local csize = contentLabel:getContentSize()
    --设置滚动区域的长度
    self.contentSrc:setInnerContainerSize(cc.size(innerSize.width, csize.height + 10))
    local _x = (innerSize.width - csize.width)/2
    local _y = 0
    if csize.height < self.contentSrc:getContentSize().height then
    _y = (self.contentSrc:getContentSize().height - csize.height)
    end
    contentLabel:setPosition(cc.p(_x, _y))
end

function UserPolicyView:show( args )
    -- body
    self:setVisible(true)
end


return UserPolicyView