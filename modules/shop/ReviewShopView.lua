local ShopView = class("ShopView", CommonWidget.PopupWindow)

ShopView.TAG = "ShopView"
function ShopView:ctor(args)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewShopJson)
    self:init(args)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.newShop, child=self.root})
end

function ShopView:isAdaptateiPhoneX()
    return true
end

function ShopView:isAdaptateiPhoneX()
    return true
end

function ShopView:setPayOrder(config)
end

function ShopView:init( args )
    local defaultHandler = handler(self, self.onButtonEvent)

    local uiTbl = {
        {name = "closeBtn",     path = "Button_close",  handler = defaultHandler},
        {name = "boxPanel",     path = "Panel_box",  handler = defaultHandler},
    }

    Util:bindUI(self, self.root, uiTbl)
    Cache.PayManager.product_info:updateAppStoreProductFirstBuyStatus(function ()
        self:refreshUI()
    end)
    -- self:refreshUI()
end

function ShopView:onButtonEvent(sender)
    if sender.name == "closeBtn" then
        self:close()
    end
end

function ShopView:payFunc(info)
    local body = {
        paymethod = info.paymethod,
        proxy_item_id = info.proxy_item_id,
        item_id = info.item_id,
        cost = info.cost,
        name_desc = info.name_desc,
        currency = info.currency,
        payType = 0, --商城购买
        ref = UserActionPos.SHOP_REF,
        cb = function (paymethod, paras)
            dump(paras)
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
        end
    }
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.string_show_14})
    qf.platform:allPay(body)
end

function ShopView:refreshView( ... )
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
    self:refreshUI()
end

function ShopView:refreshUI()
    local boxPanel = self.boxPanel
    boxPanel:getChildByName("Label_48"):setVisible(false)
    local productInfo = Cache.PayManager:getAppStoreProductInfo()
    for i = 1, #productInfo do
        local info = productInfo[i]
        local node = boxPanel:getChildByName("ItemPanel_" .. i)
        node:setVisible(info ~= nil)
        if info ~= nil then
            node:getChildByName("price"):setString(info.cost .. GameTxt.money_unit)
            node:getChildByName("gold"):setString(info.name_desc)
            node:getChildByName("tips"):getChildByName("txt"):setString(string.format(GameTxt.string_shop_item_txt8, Util:getFormatString(info.showCount)))
            node:getChildByName("tips"):setVisible(info.firstBuyStatus == 1)
            addButtonEvent(node, function ( ... )
                self:payFunc(info)
            end)
        end
    end
end

function ShopView:refreshButton(id)
end


function ShopView:requestAlipayBill( info )
end

function ShopView:refreshNoAction(chargeInfo)
end

function ShopView:updateUI( chargeId )
end

function ShopView:editboxEventHandler( strEventName,sender )
end

function ShopView:initWithData( args )
end

function ShopView:initClick( ... )
end

-- 当进入动画完成之后再进行数据填充
function ShopView:enterCoustomFinish()
end

function ShopView:updateWithData( args )
end
-- 更新金币、砖石数量
function ShopView:updateMoneyNumber( kind )
end
-- 更新话费劵数量
function ShopView:updateTicketNumber( num )
end
-- 跳转到指定的标签页
function ShopView:jumpToBookmark( bookmark )
end

-- 调整buyCommonView的位置
function ShopView:adjustCommonView( direction )
end

-- 用户行为统计
function ShopView:_statUserAction( ... )
end

--[[退出键]]
function ShopView:backHandler()
    self:close()
end

function ShopView:close()
    self.super.close(self)
    if ModuleManager.shop then
        ModuleManager.shop.view = nil
    end
end

function ShopView:saveAllConfig()
    print("shopView saveConfig .....")
end

return ShopView