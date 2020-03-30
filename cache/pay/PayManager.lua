--[[
    支付管理
]]
local PayManager = class("PayManager")

PayManager.TAG = "PayManager"

--支付方式
PAYMETHOD_APPSTORE = 501
PAYMETHOD_ZHIFUBAO = 39
PAYMETHOD_WINXIN = 40
PAYMETHOD_BANK = 38
PAYMETHOD_QQ = 44

local ProductInfo = import(".ProductInfo")

function PayManager:ctor()
    self.product_info = ProductInfo.new()
end

function PayManager:getAppStoreProductInfo( ... )
	return self.product_info:getProductInfo()
end

function PayManager:updateAppStoreProductInfo(data)
	self.product_info:updateProductInfo(data)
end

return PayManager 