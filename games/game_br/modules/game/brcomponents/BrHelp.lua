local BrHelp = class("BrHelp", CommonWidget.PopupWindow)

BrHelp.TAG = "BrHelp"

function BrHelp:ctor()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(BrRes.brHelpJson)
    self:init()
    self.super.ctor(self, {id = PopupManager.POPUPWINDOW.brHelper, child = self.root})
end

function BrHelp:init()
    Util:registerKeyReleased({self=self, cb = function( sender )
        self:close()
    end})
    addButtonEvent(self.root:getChildByName("close_btn"), function ()
        self:close()
    end)
end

function BrHelp:show()
    logd("do something here")
    self.super.show(self)
end

return BrHelp