local HeadMaskShopView = class("HeadMaskShopView", CommonWidget.PopupWindow)

HeadMaskShopView.TAG = "HeadMaskShopView"

function HeadMaskShopView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.headMaskShopJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.HeadMaskShopView, child=self.root})
end

function HeadMaskShopView:init(parameters)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "headMaskBagBtn",       path = "pannel/head_img/mask_bag_btn", handler = defaultHandler},
        {name = "closeBtn",             path = "pannel/close_btn", handler = defaultHandler},
        {name = "shopContentList",      path = "pannel/content_pannel/content_list_view"},
        {name = "headMaskItem",         path = "mask_item"},
        {name = "buyPannel",            path = "buy"},
        {name = "buyPannelCloseBtn",         path = "buy/buy_pannel/close_btn", handler = defaultHandler},
        {name = "commitBtn",                 path = "buy/buy_pannel/commit_btn", handler = defaultHandler},
        {name = "markLb",                    path = "buy/buy_pannel/mark_lb"},
        {name = "headMaskShowImage",         path = "buy/buy_pannel/head_mask_show"},
        {name = "numFrame",                  path = "buy/buy_pannel/num_pannel/num_frame"},
        {name = "addNumBtn",              path = "buy/buy_pannel/num_pannel/add_btn", handler = defaultHandler},
        {name = "reduceNumBtn",              path = "buy/buy_pannel/num_pannel/reduce_btn", handler = defaultHandler},
        {name = "numLb",              path = "buy/buy_pannel/num_pannel/num_lb"},
        {name = "loadingTxt",              path = "pannel/content_pannel/loadingTxt"}
    }

    Util:bindUI(self, self.root, uiTbl)
    if FULLSCREENADAPTIVE then
        self.root:setContentSize(cc.size(self.root:getContentSize().width + self.winSize.width-1920,self.root:getContentSize().height))
        self.buyPannel:setContentSize(cc.size(self.root:getContentSize().width + self.winSize.width-1920,self.root:getContentSize().height))
    end
    self:initData()
end

function HeadMaskShopView:initData( ... )
    self.chooseNum = 1
    self.chooseHeadMaskId = 0
    self.loadingTxt:setVisible(true)
    GameNet:send({cmd = CMD.GET_HEAD_MASK_CONFIG, body = {uin = Cache.user.uin}, callback = function (rsp)
        if rsp.ret ~= 0 then
            return
        end
        self.loadingTxt:setVisible(false)
        Cache.headMaskInfo:saveHeadMaskListConfig(rsp.model)
        if not tolua.isnull(self) then
            self:refreshHeadMaskContent()
        end
    end})
    
    self:updateBuyCountFrame()
end

function HeadMaskShopView:refreshHeadMaskContent(data)
    self.shopContentList:setItemsMargin(100)
    for i,v in ipairs(Cache.headMaskInfo.headMaskList) do
        local headMaskItem = self.headMaskItem:clone()
        headMaskItem:setVisible(true)
        self:updateItem(headMaskItem, v)
        self.shopContentList:insertCustomItem(headMaskItem, #self.shopContentList:getItems())
    end
end

function HeadMaskShopView:updateBuyCountFrame( ... )
    local data = Cache.headMaskInfo.headMaskList[self.chooseHeadMaskId]
    if not data then return end
    local goldNumLb = self.headMaskShowImage:getChildByName("gold_num")
    self.headMaskShowImage:loadTexture(string.format(GameRes.headMaskImage, data.number, 1), ccui.TextureResType.plistType)
    self.markLb:setString(string.format(GameTxt.head_mask_shop_mark_txt, Util:getFormatString(data.gold), Cache.packetInfo:getShowUnit(), data.days))
    goldNumLb:setString(Util:getFormatString(data.gold) .. "\n" .. data.days .. GameTxt.TimerUnitStr[4])
end

function HeadMaskShopView:resetInfo()
    self.chooseNum = 1
    self.numLb:setString(self.chooseNum)
end

function HeadMaskShopView:updateItem(itemNode, data)
    if not itemNode or not data then return end
    local maskImage = itemNode:getChildByName("head_mask_show_image")
    local maskName = itemNode:getChildByName("head_mask_name")
    local goldLb = maskImage:getChildByName("gold_num_lb")
    local buyBtn = itemNode:getChildByName("item_buy_btn")
    maskImage:loadTexture(string.format(GameRes.headMaskImage, data.number, 1), ccui.TextureResType.plistType)
    maskName:setString(data.name)
    goldLb:setString(Util:getFormatString(data.gold) .. "\n" .. data.days .. GameTxt.TimerUnitStr[4])
    addButtonEvent(buyBtn, function ()
        if not Cache.user:isBindPhone() then
            qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 4})
            return
        end
        self.chooseHeadMaskId = data.number
        self:showBuyPannel()
    end)
end

function HeadMaskShopView:showBuyPannel( ... )
    self.buyPannel:setVisible(true)
    self:updateBuyCountFrame()
    self:resetInfo()
end

function HeadMaskShopView:updateChooseNum(count)
    if not count then return end
    self.chooseNum = tonumber(self.numLb:getString())
    self.chooseNum = self.chooseNum + count
    if self.chooseNum <= 0 then
        self.chooseNum = 1
    end
    if self.chooseNum > 10 then
        self.chooseNum = 10
    end
    self.numLb:setText(self.chooseNum)
end

--[[
    optional int32 uin = 1; 
    optional int64 gold = 2; // 购买单个头像框所需金币,免费为0
    optional int32 number = 3; // 头像框编号
    optional int32 amount = 4; // 购买头像框个数
]]
function HeadMaskShopView:requestBuyAction( ... )
    if self.chooseNum == 0 then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.head_mask_buy_error_txt})
        return
    end
    local data = Cache.headMaskInfo.headMaskList[self.chooseHeadMaskId]
    local body = {
        uin = Cache.user.uin,
        gold = data.gold,
        number = data.number,
        amount = self.chooseNum
    }
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.string_show_14})
    GameNet:send({cmd = CMD.BUY_HEAD_MASK, body = body, callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else
            qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin})
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.head_mask_buy_success_txt, Util:getFormatString(data.gold*self.chooseNum) .. Cache.packetInfo:getShowUnit())})
            self:resetInfo()
        end
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
    end})
end

function HeadMaskShopView:onButtonEvent(sender)
    if sender.name == "headMaskBagBtn" then
        self:showHeadMaskBag()
    elseif sender.name == "closeBtn" then
        self:close()
    elseif sender.name == "buyPannelCloseBtn" then
        self.buyPannel:setVisible(false)
    elseif sender.name == "commitBtn" then
        self:requestBuyAction()
    elseif sender.name == "addNumBtn" then
        self:updateChooseNum(1)
    elseif sender.name == "reduceNumBtn" then
        self:updateChooseNum(-1)
    end
end

function HeadMaskShopView:showHeadMaskBag( ... )
    self:close()
    qf.event:dispatchEvent(ET.HEAD_MASK_BAG)
end

function HeadMaskShopView:getRoot() 
    return LayerManager.PopupLayer
end

return HeadMaskShopView