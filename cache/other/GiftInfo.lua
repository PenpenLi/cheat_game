local GiftInfo = class("GiftInfo")

GiftInfo.TAG = "GiftInfo"

function GiftInfo:ctor() 
    self:init()
end

function GiftInfo:init() 

end
function GiftInfo:saveConfig(model)
	self.giftlist ={}
    for i=1 ,model.gifts:len() do
        local data = model.gifts:get(i)
        local info = {
                            id      = data.id,--礼物id
                            name    = data.name, --礼物名称
                            num     = data.num,--礼物数量
                            price   = data.price,--礼物价格
                            remain  = data.remain, --剩余天数
                            category= data.category + 1 --物品类型从0开始索引
                      }
        if not self.giftlist[info.category] then
            self.giftlist[info.category] = {}
        end
        table.insert(self.giftlist[info.category],#self.giftlist[info.category]+1,info)
	end
end
--是拥有一个礼物
function GiftInfo:hasGift(gift_id)
    for k,v in pairs(self.giftlist) do
        for k2,v2 in pairs(v) do
            if v2.id == gift_id then return true end
        end
    end
    return false
end

function GiftInfo:getGiftPriceById(gift_id)
    for k,v in pairs(self.giftlist) do
        for k2,v2 in pairs(v) do
            if v2.id == gift_id then 
                return v2.price
            end
        end
    end
    return nil
end

function GiftInfo:saveReceiveRecord(model)
    self.myReceiveGiftRecord={} 
    local info = 
    { 
    timestamp= 1446017764,
    uin= 470,
    nick= "baixjx",
    gift_id= 2,
    gift_name="gift.name.2",
    return_sum= 8000,
    mes="和哈哈哈哈哈哈和",
    rebated=false
  }
 -- table.insert(self.myReceiveGiftRecord,#self.myReceiveGiftRecord+1,info)
   
    for i=1 ,model.records:len() do
          local data = model.records:get(i)
          logd("index:.."..i)
            logd("data:.."..pb.tostring(data))
            self.myReceiveGiftRecord[i] = {}

            self.myReceiveGiftRecord[i].timestamp  = data.timestamp--礼物id
            self.myReceiveGiftRecord[i].uin  = data.uin --
            self.myReceiveGiftRecord[i].nick   = data.nick--
            self.myReceiveGiftRecord[i].gift_id   = data.gift_id--
            self.myReceiveGiftRecord[i].gift_name  = data.gift_name --
            self.myReceiveGiftRecord[i].return_sum= data.return_sum 
            self.myReceiveGiftRecord[i].mes=data.words or ""
            self.myReceiveGiftRecord[i].rebated=data.returned or false 
            self.myReceiveGiftRecord[i].uuid=data.uuid or false 
            self.myReceiveGiftRecord[i].gender=data.gender or 1
            self.myReceiveGiftRecord[i].portrait=data.portrait
    end
    
  
end

return GiftInfo