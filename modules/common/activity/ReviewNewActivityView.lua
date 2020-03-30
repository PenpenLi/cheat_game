local _NewActiviyView = import(".NewActivityView")
local NewActiviyView = class("NewAcitivyView", _NewActiviyView)

function NewActiviyView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewNewActivityJson)
    if self.root:getChildByName("Panel_21") then
        self.root:getChildByName("Panel_21"):setVisible(false)
    end

    self:init(parameters)
    self.super.super.ctor(self, {id=PopupManager.POPUPWINDOW.newActivity, child=self.root})
end

function NewActiviyView:refreshContentPage(args)
	local scrollView = ccui.Helper:seekWidgetByName(self.contentPage, "ScrollView_61")
    local agreeImage = scrollView:getChildByName("Image_62")
    local noticeTxt = ccui.Helper:seekWidgetByName(self.contentPage, "Label_58_0")
	scrollView:setVisible(false)
	noticeTxt:setVisible(true)
	noticeTxt:setString(args.notice_text)
end

return NewActiviyView