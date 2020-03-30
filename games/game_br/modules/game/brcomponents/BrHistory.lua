local BrHistory = class("BrHistory", CommonWidget.PopupWindow)

BrHistory.TAG = "BrHistory"

function BrHistory:ctor()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(BrRes.brHistoryJson)
    self:init()
    self:initTouch()
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.brHistory, child=self.root})
    if not Cache.packetInfo:isShangjiaBao() then
        Util:addTangKuangEffect(Util:getChildEx(self.root, "titleContent"))
    end
end

function BrHistory:show()
    self:update()
    self.super.show(self)
end

function BrHistory:init()
    self.panel = {}
    for i = 1 , 4 do
        self.panel[i] = self.root:getChildByName("panel_"..i)
    end

    Util:registerKeyReleased({self=self, cb = function( sender )
        self:close()
    end})
end

function BrHistory:initTouch()
    local back = self.root:getChildByName("back_btn")
    addButtonEvent(back,function() 
        self:close()
    end)
    addButtonEvent(self.root,function() 
        self:close()
    end)
end

function BrHistory:update()
    if self.root == nil then return end
    local allinfo = Cache.brinfo.history
    if allinfo == nil then return end
    local index = 1
    for i = #allinfo - 10 + 1, #allinfo do
        local v = allinfo[i]
        if v then
            for key, info in pairs(v) do
                local item = self.panel[info.section]:getChildByName("status_".. index)
                if item then
                    item:loadTexture(info.odds > 0 and BrRes.br_win_word or BrRes.br_loser_word)
                end
            end
            index = index + 1
        end
    end
end

return BrHistory