--[[
    支付方式及钻石购买数据
]]
local DiamondInfo = class("DiamondInfo")

DiamondInfo.TAG = "DiamondInfo"

local DIAMOND = GameTxt.shop_currency_diamond

DiamondInfo.cnApple = {}
DiamondInfo.cn_normal = {}

function DiamondInfo:ctor()
    
end

function DiamondInfo:initDiamondInfo()
    self:initcnApple()
    self:initcnNormal()
    self:initBuyGold()

    self:initDefaultGoodsInfoByChannel()
end
function DiamondInfo:initPayMethods()    
    self.paymethods_app = {}
    if Cache.PayManager.payMethods then
        self:updatePaymethods(Cache.PayManager.payMethods)
    elseif string.find(GAME_CHANNEL_NAME,"CN_IOS_")  ~= nil then
        self:init_paymethods_ios_app()
    else
        self:init_paymethods_android_app()
    end
end

function DiamondInfo:initDefaultGoodsInfoByChannel()
    self.allInfo = self.cn_normal
    if string.find(GAME_CHANNEL_NAME,"CN_IOS_")  ~= nil then
        self.allInfo = #self.newCnApple>0 and self.newCnApple or self.cnApple     --除港台版外其他ios马甲使用这个配置
    elseif IsInTable(GAME_CHANNEL_NAME,GAMES_ANDROID)   then    --CN_NORMAL等渠道原来使用CN_TIANYI配置，现在去掉短信支付 then
        self.allInfo = self.cn_normal
    end
end

--获取钻石购买信息
function DiamondInfo:getDiamondInfo()
    return clone(self.allInfo)
end

--获取金币购买信息
function DiamondInfo:getBuyGoldInfo()
    return clone(self.buyGold)
end

function DiamondInfo:initcnNormal()
    self.cn_normal = {}
    --支付宝
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "60"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_6_60",  item_id = "apl_diamond_6_60",  cost = 6,  old_cost = 6, currency = "CNY", diamond = 60} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "360"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_30_360",   item_id = "apl_diamond_30_360",   cost = 30,   old_cost = 30,   currency = "CNY", diamond = 360  } )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "860"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_68_860",  item_id = "apl_diamond_68_860",  cost = 68,  old_cost = 68,  currency = "CNY", diamond = 860 } )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "1800"..DIAMOND, hot = 1, proxy_item_id = "apl_diamond_128_1800",  item_id = "apl_diamond_128_1800",  cost = 128,  old_cost = 128,  currency = "CNY", diamond = 1800 } )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "5000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_328_5000", item_id = "apl_diamond_328_5000", cost = 328, old_cost = 328, currency = "CNY", diamond = 5000} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "12000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_648_12000", item_id = "apl_diamond_648_12000", cost = 648, old_cost = 648, currency = "CNY", diamond = 12000} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "20000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_1000_20000", item_id = "apl_diamond_1000_20000", cost = 1000, old_cost = 1000, currency = "CNY", diamond = 20000} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "45000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_2000_45000", item_id = "apl_diamond_2000_45000", cost = 2000, old_cost = 2000, currency = "CNY", diamond = 45000} )
    --微信
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "60"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_6_60",  item_id = "apl_diamond_6_60",  cost = 6,  old_cost = 6, currency = "CNY", diamond = 60} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "360"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_30_360",   item_id = "apl_diamond_30_360",   cost = 30,   old_cost = 30,   currency = "CNY", diamond = 360  } )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "860"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_68_860",  item_id = "apl_diamond_68_860",  cost = 68,  old_cost = 68,  currency = "CNY", diamond = 860 } )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "1800"..DIAMOND, hot = 1, proxy_item_id = "apl_diamond_128_1800",  item_id = "apl_diamond_128_1800",  cost = 128,  old_cost = 128,  currency = "CNY", diamond = 1800 } )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "5000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_328_5000", item_id = "apl_diamond_328_5000", cost = 328, old_cost = 328, currency = "CNY", diamond = 5000} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "12000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_648_12000", item_id = "apl_diamond_648_12000", cost = 648, old_cost = 648, currency = "CNY", diamond = 12000} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "20000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_1000_20000", item_id = "apl_diamond_1000_20000", cost = 1000, old_cost = 1000, currency = "CNY", diamond = 20000} )
    table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN,name_desc = "45000"..DIAMOND,hot = 0, proxy_item_id = "apl_diamond_2000_45000", item_id = "apl_diamond_2000_45000", cost = 2000, old_cost = 2000, currency = "CNY", diamond = 45000} )
end
         
function DiamondInfo:initcnApple()
    self.cnApple = {}
    local appstore_product_id = {}

    --各路马甲计费点配置, 按价格从高到低的顺序
    local IMP_PRODUCT_TAB = {
        
        --炸金花火拼版
        ["CN_IOS_HLDWC"] = {
                "com.huiyze.hlzjhe_6_zs_v1",
                "com.huiyze.hlzjhe_30_zs_v1",
                "com.huiyze.hlzjhe_68_zs_v1",
                "com.huiyze.hlzjhe_128_zs_v1",
                "com.huiyze.hlzjhe_328_zs_v1",
                "com.huiyze.hlzjhe_648_zs_v1"
        }
    }

    if not IMP_PRODUCT_TAB[GAME_CHANNEL_NAME] then return end
    
    if IMP_PRODUCT_TAB[GAME_CHANNEL_NAME] then
        appstore_product_id = IMP_PRODUCT_TAB[GAME_CHANNEL_NAME]
    end

    --apple ipa支付
    table.insert(self.cnApple,{paymethod = PAYMETHOD_APPSTORE,name_desc = "60"..DIAMOND, hot = 0, proxy_item_id = "apl_diamond_6_60",  item_id = appstore_product_id[1],  cost = 6,  old_cost = 6, currency = "CNY", diamond = 60} )
    table.insert(self.cnApple,{paymethod = PAYMETHOD_APPSTORE,name_desc = "360"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_30_360",   item_id = appstore_product_id[2],   cost = 30,   old_cost = 30,   currency = "CNY", diamond = 360  } )
    table.insert(self.cnApple,{paymethod = PAYMETHOD_APPSTORE,name_desc = "860"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_68_860",  item_id = appstore_product_id[3],  cost = 68,  old_cost = 68,  currency = "CNY", diamond = 860 } )
    table.insert(self.cnApple,{paymethod = PAYMETHOD_APPSTORE,name_desc = "1800"..DIAMOND, hot = 1, proxy_item_id = "apl_diamond_128_1800",  item_id = appstore_product_id[4],  cost = 128,  old_cost = 128,  currency = "CNY", diamond = 1800 } )
    table.insert(self.cnApple,{paymethod = PAYMETHOD_APPSTORE,name_desc = "5000"..DIAMOND, hot = 0, proxy_item_id = "apl_diamond_328_5000", item_id = appstore_product_id[5], cost = 328, old_cost = 328, currency = "CNY", diamond = 5000} )
    table.insert(self.cnApple,{paymethod = PAYMETHOD_APPSTORE,name_desc = "12000"..DIAMOND, hot = 0, proxy_item_id = "apl_diamond_648_12000", item_id = appstore_product_id[6], cost = 648, old_cost = 648, currency = "CNY", diamond = 12000} )
    --end
end

--钱买金币
function DiamondInfo:initBuyGold( ... )
    -- body
    self.buyGold = {}
    local appstore_product_id={
        "com.huiyze.hlzjhd_12_zs_v1",
        "com.huiyze.hlzjhd_68_zs_v1",
    }
    table.insert(self.buyGold,{paymethod = PAYMETHOD_APPSTORE,name_desc = "120"..DIAMOND, hot = 0, proxy_item_id = "apl_diamond_12_188888",  item_id = appstore_product_id[1],  cost = 12,  old_cost = 12, currency = "CNY", diamond = 120,gold= 188888} )
    table.insert(self.buyGold,{paymethod = PAYMETHOD_APPSTORE,name_desc = "860"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_68_888888",  item_id = appstore_product_id[2],  cost = 68,  old_cost = 68,  currency = "CNY", diamond = 860 ,gold= 888888} )
    table.insert(self.buyGold,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "120"..DIAMOND, hot = 0, proxy_item_id = "apl_diamond_12_188888",  item_id = "apl_diamond_12_188888",  cost = 12,  old_cost = 12, currency = "CNY", diamond = 120,gold= 188888} )
    table.insert(self.buyGold,{paymethod = PAYMETHOD_ZHIFUBAO,name_desc = "860"..DIAMOND, hot = 2, proxy_item_id = "apl_diamond_68_888888",  item_id = "apl_diamond_68_888888",  cost = 68,  old_cost = 68,  currency = "CNY", diamond = 860 ,gold= 888888} )
    table.insert(self.buyGold,{paymethod = PAYMETHOD_WINXIN,name_desc = "120"..DIAMOND, hot = 0, proxy_item_id = "apl_diamond_12_188888",  item_id = "apl_diamond_12_188888",  cost = 12,  old_cost = 12, currency = "CNY", diamond = 120,gold= 188888} )
    table.insert(self.buyGold,{paymethod = PAYMETHOD_WINXIN,name_desc = "860"..DIAMOND, hot = 0, proxy_item_id = "apl_diamond_68_888888",  item_id = "apl_diamond_68_888888",  cost = 68,  old_cost = 68,  currency = "CNY", diamond = 860 ,gold= 888888} )
          
end

function DiamondInfo:updateProduct(item_list)
     -- body
     self:initcnApple()
     self.newCnApple={}
     for i = 1, item_list:len() do
        local item = item_list:get(i)
        if item.type == PAY_CONST.ITEM_TYPE_DIAMOND then
            for k,v in pairs(self.cnApple) do
                if v.cost == item.price then
                    v.hot = item.label 
                    table.insert(self.newCnApple,v)
                end
            end
        end
    end
end 

--每个渠道的支付方式配置
function DiamondInfo:init_paymethods_ios_app()
    self.paymethods_app[1] = PAYMETHOD_APPSTORE

    if not TB_MODULE_BIT.BOL_MODULE_BIT_STORE then
        return
    end

    self.paymethods_app[2] = PAYMETHOD_ZHIFUBAO
    self.paymethods_app[3] = PAYMETHOD_WINXIN
end

function DiamondInfo:updatePaymethods( list )
    self.paymethods_app = {}
    local paymethods = string.split(list,"|")
    if string.find(GAME_CHANNEL_NAME,"CN_IOS_")  ~= nil then
        table.insert(self.paymethods_app,PAYMETHOD_APPSTORE)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_STORE then
            return
        end
        for k,v in pairs(paymethods)do
            if tonumber(v) == 1 then 
                table.insert(self.paymethods_app,PAYMETHOD_WINXIN)
            elseif tonumber(v)==2 then
                table.insert(self.paymethods_app,PAYMETHOD_ZHIFUBAO)
            end
        end
    elseif IsInTable(GAME_CHANNEL_NAME,GAMES_ANDROID)   then    --CN_NORMAL等渠道原来使用CN_TIANYI配置，现在去掉短信支付 then
        if not TB_MODULE_BIT.BOL_MODULE_BIT_STORE then
            return
        end
        for k,v in pairs(paymethods)do
            if tonumber(v) == 1 then 
                table.insert(self.paymethods_app,PAYMETHOD_WINXIN)
            elseif tonumber(v)==2 then
                table.insert(self.paymethods_app,PAYMETHOD_ZHIFUBAO)
            end
        end
    end
end


--每个渠道的支付方式配置
function DiamondInfo:init_paymethods_android_app()
    self.paymethods_app[1] = PAYMETHOD_ZHIFUBAO
    self.paymethods_app[2] = PAYMETHOD_WINXIN
end

function DiamondInfo:getPayMethods(channel_name)
    local paymethods = {}
    paymethods = self.paymethods_app
    return clone(paymethods)
end


return DiamondInfo
