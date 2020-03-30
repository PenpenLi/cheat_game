local PacketInfo = class("PacketInfo")

PacketInfo.TAG = "PacketInfo"


function PacketInfo:ctor() 
    self:init()
end

--财神爷的倒计时 由这里进行记录 防止其他地方进行销毁
function PacketInfo:init() 
    self.cur_packet_info = nil
end

function PacketInfo:saveConfig(model)
    if model == nil then
        return
    end
    if model.package_type == nil or model.gold_proportion == nil or model.decimal_point == nil then
        return 
    end
    self.cur_packet_info = {
        pType = model.package_type,
        gPro = model.gold_proportion,
        dPnt = model.decimal_point
    }
    cc.UserDefault:getInstance():setIntegerForKey("package_type",  model.package_type);
    cc.UserDefault:getInstance():setIntegerForKey("gold_proportion", model.gold_proportion);
    cc.UserDefault:getInstance():setIntegerForKey("decimal_point", model.decimal_point);
    cc.UserDefault:getInstance():flush()
    if self.cur_packet_info.gPro == 0 then
        self.cur_packet_info.gPro = 1
    end
end

local ptypeConstants = {
    SJB = 1, -- 上架包
    PPB = 2, -- 品牌包
    B2B = 3  -- B2B包
}

-- 存在cur_packet_info 突然变为nil的情况 但是
-- 不知道是为什么所以采取本地存取的方式来进行特殊处理
-- 如果cur_packet_info 为nil的情况下 使用本地存储的东
-- 西重新赋值
function PacketInfo:recoverPacketInfo()
    if self.cur_packet_info == nil 
        or self.cur_packet_info.pType == nil
        or self.cur_packet_info.gPro == nil
        or self.cur_packet_info.dPnt == nil then
        self.cur_packet_info = {
            pType = cc.UserDefault:getInstance():getIntegerForKey("package_type", 0),
            gPro = cc.UserDefault:getInstance():getIntegerForKey("gold_proportion", 0),
            dPnt = cc.UserDefault:getInstance():getIntegerForKey("decimal_point", 0)
        }
    end
end


function PacketInfo:isShangjiaBao( ... )
    self:recoverPacketInfo()
    if self.cur_packet_info and self.cur_packet_info.pType then
        return self.cur_packet_info.pType == ptypeConstants.SJB
    end
    return false
end

function PacketInfo:isPinPaiBao()
    self:recoverPacketInfo()
    if self.cur_packet_info and self.cur_packet_info.pType then
        return self.cur_packet_info.pType == ptypeConstants.PPB
    end
    return false
end

function PacketInfo:isB2BBao()
    self:recoverPacketInfo()
    if self.cur_packet_info and self.cur_packet_info.pType then
        return self.cur_packet_info.pType == ptypeConstants.B2B
    end
    return false
end

function PacketInfo:getGoldProportion()
    self:recoverPacketInfo()
    if self.cur_packet_info and self.cur_packet_info.gPro then
        return self.cur_packet_info.gPro
    end
end

function PacketInfo:getDecimalPoint()
    self:recoverPacketInfo()
    if self.cur_packet_info and self.cur_packet_info.dPnt then
        return self.cur_packet_info.dPnt
    end
end

--根据服务器发送的金币 直接得到 客户端应该展示的金币
function PacketInfo:getProMoney(money)
    if money == nil then
        printTraceback("money == nil")
    end
    money = checknumber(money)
    self:recoverPacketInfo()    
    if self.cur_packet_info then
        return money / self.cur_packet_info.gPro
    end
end

--根据客户端的金币 发送给服务端的金币 要乘以这个服务端发送的比率
function PacketInfo:getCProMoney(money)
    if money == nil then
        printTraceback("money == nil")
    end
    money = checknumber(money)
    self:recoverPacketInfo()
    if self.cur_packet_info then
        return money * self.cur_packet_info.gPro
    else
        return money
    end
end

--真金和金币兑换
function PacketInfo:getGoldByRealGod(gold)
    return gold *30000
end

--判断是真金还是金币
function PacketInfo:getShowUnit( ... )
    if self:isRealGold() then
        return "元"
    end
    return "金币"
end

--判断是不是真金
function PacketInfo:isRealGold( ... )
    local gPro = self:getGoldProportion()
    return gPro/30000 == 1
end

function PacketInfo:getGoldImg()
    return GameRes.gold_new_img
end

return PacketInfo