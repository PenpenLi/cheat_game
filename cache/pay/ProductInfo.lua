--[[
    appStore金币购买
]]

local ProductInfo = class("ProductInfo")

function ProductInfo:ctor()
    self.iapProductInfo = {}
end

function ProductInfo:getProductInfo( ... )
    loga(">>>>>ProductInfo:getProductInfo = " .. GAME_CHANNEL_NAME)
    if string.find(GAME_CHANNEL_NAME, "IOS") ~= nil then
        return clone(self.iapProductInfo)
    end
    return {}
end

--[[
    optional string name = 1; // 商品ID，唯一的 (proxy_item_id)
    optional int32 type = 2; // 商品类型 0购买金币1购买物品2购买钻石
    optional int32 currency = 3; // 用金币或者钻石去兑换 0:用金币兑换1:用钻石兑换2:用毛爷爷兑换
    optional int64 price = 4; // 价格 (cost)
    optional int64 amount = 5; // 可以兑换到的数量 (show_count)
    optional int32 label = 6; // 标签类型, 0: 无标签；1:推荐；2:热销
    optional int32 gift_id = 7; // 礼物ID
    optional string item_id = 8; // item_id (item_id)
]]
function ProductInfo:updateAppStoreProductInfo(model)
    if not model then return end
    if not model.recharge_list then return end
    local itemList = model.recharge_list
    self.iapProductInfo = {}
    local allFinishFirst = true
    for i=1, model.recharge_list:len() do
        local itemConf = model.recharge_list:get(i)
        local itemTable = {}
        itemTable.proxy_item_id = itemConf.name
        itemTable.cost = itemConf.cost
        itemTable.showCount = itemConf.show_count
        itemTable.item_id = itemConf.name_id
        itemTable.name_desc = itemTable.showCount .. GameTxt.shop_currency_gold
        itemTable.paymethod = PAYMETHOD_APPSTORE
        itemTable.currency = "CNY"
        itemTable.firstBuyStatus = itemConf.store_first_recharge
        table.insert(self.iapProductInfo, itemTable)
        if itemTable.firstBuyStatus == 1 then
            allFinishFirst = false
        end
    end
    -- 如果所有的都买完了，那么大厅就不展示了
    if allFinishFirst == true then
        Cache.user.store_first_recharge = 0
    end
    qf.event:dispatchEvent(ET.FRESH_HALL_SHOP_FIRST)
    table.sort(self.iapProductInfo, function (a, b)
        return tonumber(a.cost) < tonumber(b.cost)
    end)
end

function ProductInfo:updateAppStoreProductFirstBuyStatus(callback)
    GameNet:send({cmd = CMD.QUERY_USER_APPSTORE_FIRST, body={uin = Cache.user.uin}, callback = function (rsp)
        if rsp.ret ~= 0 then
            return
        end

        if rsp.model then
            self:updateAppStoreProductInfo(rsp.model)
            if callback and type(callback) == "function" then
                callback(self.iapProductInfo)
            end
        end
    end})
end

return ProductInfo 