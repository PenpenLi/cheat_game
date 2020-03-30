local HeadMaskBagView = class("HeadMaskBagView", CommonWidget.PopupWindow)

HeadMaskBagView.TAG = "HeadMaskBagView"

function HeadMaskBagView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.headMaskBagJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.HeadMaskBagView, child=self.root})
end

function HeadMaskBagView:init(parameters)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "closeBtn",                path = "pannel/close_btn", handler = defaultHandler},
        {name = "maskBagContentList",      path = "pannel/content_pannel/content_list_view"},
        {name = "loadingTxt",              path = "pannel/content_pannel/loadingTxt"},
        {name = "headMaskBagItem",         path = "mask_bag_item"}
    }

    Util:bindUI(self, self.root, uiTbl)
    if FULLSCREENADAPTIVE then
        self.root:setContentSize(cc.size(self.root:getContentSize().width + self.winSize.width-1920,self.root:getContentSize().height))
    end
    self:initData()
end

function HeadMaskBagView:initData( ... )
    qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin})
    self.loadingTxt:setVisible(true)
    GameNet:send({cmd = CMD.GET_HEAD_MASK_CONFIG, body = {uin = Cache.user.uin}, callback = function (rsp)
        if rsp.ret ~= 0 then
            return
        end
        self.loadingTxt:setVisible(false)
        Cache.headMaskInfo:saveHeadMaskListConfig(rsp.model)
        if not tolua.isnull(self) then
            self:refreshHeadMaskBagContent()
        end
    end})
end

function HeadMaskBagView:refreshHeadMaskBagContent( ... )
    self.maskBagContentList:setItemsMargin(100)
    self.maskBagContentList:removeAllItems()
    for i,v in ipairs(Cache.headMaskInfo.headMaskList) do
        local maskBagItem = self.headMaskBagItem:clone()
        maskBagItem:setVisible(true)
        maskBagItem.tag = v.number
        self:updateItem(maskBagItem, v, index)
        self.maskBagContentList:insertCustomItem(maskBagItem, #self.maskBagContentList:getItems())
    end
end

function HeadMaskBagView:updateItem(itemNode, data, index)
    if not itemNode or not data then return end
    local myHeadMaskItemInfo = Cache.headMaskInfo.userHeadMaskList[data.number]
    local maskImage = itemNode:getChildByName("head_mask_show_image")
    local maskName = itemNode:getChildByName("head_mask_name")
    local goldLb = maskImage:getChildByName("gold_num_lb")
    local maskStatus = itemNode:getChildByName("head_mask_status")
    local maskUserBtn = itemNode:getChildByName("head_mask_user_btn")
    maskImage:loadTexture(string.format(GameRes.headMaskImage, data.number, data.bCloud),ccui.TextureResType.plistType)
    local statusCode = 2 --默认未购买
    if data.number == Cache.user.number and data.bCloud == 1 then
        statusCode = 1 -- 使用中
    end

    if data.bCloud == 1 and data.number ~= Cache.user.number then
        statusCode = 0
    end
    maskStatus:setString(GameTxt.use_status[statusCode])
    maskName:setString(data.name)
    maskStatus:setColor(statusCode == 2 and cc.c3b(255,255,255) or cc.c3b(241,217,88))
    if data.bCloud == 1 then
        goldLb:setString(Util:getFormatString(data.gold) .. "\n" .. math.ceil(myHeadMaskItemInfo.left_time/60/60/24) .. GameTxt.TimerUnitStr[4])
    else
        goldLb:setString(Util:getFormatString(data.gold) .. "\n" .. data.days .. GameTxt.TimerUnitStr[4])
    end

    if data.bCloud == 1 then
        maskImage:getLayoutParameter():setMargin({left = 0, right = 0, top = 167, bottom = 0})
        goldLb:setPositionY(maskImage:getContentSize().height/2)
    else
        maskImage:getLayoutParameter():setMargin({left = 0, right = 0, top = 183, bottom = 0})
        goldLb:setPositionY(maskImage:getContentSize().height/2 + 12)
    end
    maskStatus:setVisible(statusCode == 2)
    maskUserBtn:setVisible(statusCode ~= 2)
    maskUserBtn:setBright(data.number ~= Cache.user.number)
    maskUserBtn:setTouchEnabled(data.number ~= Cache.user.number)
    if data.number == Cache.user.number then
        maskUserBtn:getChildByName("Image_17"):loadTexture(string.format(GameRes.headMaskUseStatus, 1), ccui.TextureResType.plistType)
    else
        maskUserBtn:getChildByName("Image_17"):loadTexture(string.format(GameRes.headMaskUseStatus, 0), ccui.TextureResType.plistType)
    end
    addButtonEvent(maskUserBtn, function ()
        self:selectHeadMask(data, itemNode)
    end)
end

function HeadMaskBagView:updateSelectItem(data, itemNode)
    self:refreshHeadMaskBagContent()
end

function HeadMaskBagView:selectHeadMask(data, itemNode)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.string_show_16})
    GameNet:send({cmd = CMD.USER_CHOOSE_HAED_MASK, body = {uin = Cache.user.uin, number = data.number}, callback = function (rsp)
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else
            Cache.user.number = data.number
            qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin})
            self:updateSelectItem(data, itemNode)
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.head_mask_user_success_txt})
        end
    end})
end

function HeadMaskBagView:onButtonEvent(sender)
    if sender.name == "closeBtn" then
        self:close()
    end
end

function HeadMaskBagView:getRoot() 
    return LayerManager.PopupLayer
end

return HeadMaskBagView