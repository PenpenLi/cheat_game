local NewAcitivyView = class("NewAcitivyView", CommonWidget.PopupWindow)
NewAcitivyView.TAG = "NewAcitivyView"
local ViewTAG = {
    Activity = 1,
    Notice = 2
}
local STATUS = {
    Fire = 1,
    Hot = 2,
    Limit = 3,
    New = 4,
    Recommend = 5,
}

function NewAcitivyView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.newActivityJson)
    if self.root:getChildByName("Panel_21") then
        self.root:getChildByName("Panel_21"):setVisible(false)
    end

    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.newActivity, child=self.root})
end

function NewAcitivyView:init( parameters )
    local closeFunc = function ( ... )
        self:close()
    end

    local turnFunc = handler(self, self.changeTab)

    local uiTbl = {
        {name = "closeBtn",             path = "Panel_box/Button_close",                        handler = closeFunc},
        {name = "listview",             path = "Panel_42/ListView_44"},
        {name = "modelItem",             path = "Panel_42/modelItem"},        
        {name = "contentPage",             path = "Panel_42_0"},
    }

    Util:bindUI(self, self.root, uiTbl)
    Util:enlargeCloseBtnClickArea(self.closeBtn)
    self:initLeftTab(self.listview, self.modelItem)
    if #Cache.activityInfo.all_notice > 0 then
        self._itemList[1].cb()
    end
end

function NewAcitivyView:isAdaptateiPhoneX( ... )
    return true
end

function NewAcitivyView:initLeftTab(listview, itemModel)
    listview:setVisible(true)
    listview:setItemModel(itemModel)
    listview:removeAllChildren(true)
    local ox = itemModel:getChildByName("Button_54"):getPositionX()
    local osize = itemModel:getChildByName("Button_54"):getContentSize()
    local itemList = {}
    local data = Cache.activityInfo.all_notice
    
    for i = 1, #data do
        listview:pushBackDefaultItem()
    end
    listview:setBounceEnabled(false)
    local itemlist = listview:getItems()
    for i, v in ipairs(itemlist) do   
        local title = data[i].title
        v:setVisible(true)
        v:getChildByName("Label_31"):setString(title)
        local cb = function ()
            for _, v in ipairs(itemlist) do
                v:getChildByName("Button_54"):setBright(true)
                v:getChildByName("Button_54"):setTouchEnabled(true)
                v:getChildByName("Button_54"):setPositionX(ox)
                v:getChildByName("Button_54"):setContentSize(osize)
            end
            itemlist[i]:getChildByName("Button_54"):setBright(false)
            itemlist[i]:getChildByName("Button_54"):setTouchEnabled(false)
            itemlist[i]:getChildByName("Button_54"):setPositionX(ox + 6.3)
            itemlist[i]:getChildByName("Button_54"):setContentSize(cc.size(osize.width+10, osize.height))
            self:refreshContentPage(data[i])
        end
        --直接把对应的点击事件挂在对应的按钮上  直接调用
        addButtonEvent(v:getChildByName("Button_54"), cb)
        v.cb = cb
    end
    self._itemList = itemlist
    itemModel:setVisible(false)
end

function NewAcitivyView:refreshContentPage(args)
    -- self.contentPage:getChildByName("")
    -- ccui.Helper:seekWidgetByName(self.contentPage, "Label_59"):setString(args.title)
    ccui.Helper:seekWidgetByName(self.contentPage, "Label_58_0"):setString(args.notice_text)
    -- ccui.Helper:seekWidgetByTag(self.contentPage, "Label_58_1"):setString(args.notice_text)
    -- self.contentTitle:setString(args.notice_title or "")
    -- self.contentPage:setString(args.notice_text or "")
    -- -- self.contentTitle:setVisible(true)
    -- self.contentTitle:getParent():setVisible(true)
    -- self.contentPage:setVisible(true)
    -- self.activityBg:setVisible(false)
end

return NewAcitivyView