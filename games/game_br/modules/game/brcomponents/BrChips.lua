local BrChip = class("BrChip") 

BrChip.TAG = "BrChip"
local ChipCls = require("src.common.Chip")
BrChip.defaultColor = cc.c3b(255,255,255)--cc.c3b(251,205,0)--cc.c3b(0,255,96)
BrChip.beautyColor = cc.c3b(255,0,0)

--筹码所对应的值
local valueT = {1,10,50,100,300,500,1000,5000}

function BrChip:init()
    --logd("内存前"..cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    if self.chipsPool ~= nil then return end
    self.chipsPool = {}


    self.cacheColorTbl = {} --根据筹码值迅速找到对应颜色缓冲表
    self.tbChipsValue = {}

    --按照颜色进行缓存 当服务器发送来对应的下注列表时再按照数值进行分配
    local cacheNum = 100
    local colorArr = BrConstants.ColorIndex
    self.colorChipPools = {}
    for idx, v in ipairs(colorArr) do
        self.colorChipPools[v] = {}
        for i = 1, cacheNum do
            local chip = self:create(v)
            self.colorChipPools[i] = chip
            chip:setVisible(false)
        end
    end


    --logd("内存后"..cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

function BrChip:getChip(value)
    if self.chipsPool == nil or self.chipsPool[value] == nil or next(self.chipsPool[value]) == nil then 
        return self:create(value) 
    end
    local chip = self.chipsPool[value][#self.chipsPool[value]]
    self.chipsPool[value][#self.chipsPool[value]] = nil
    chip:removeFromParent(true)
    return chip
end

function BrChip:putChip(chip)
    local value = chip.value
    local pool = self.chipsPool[chip.value]
    chip.isBeSign = false
    chip:setVisible(false)
    self.chipsPool[chip.value] = self.chipsPool[chip.value] or {}
    self.chipsPool[chip.value][#self.chipsPool[chip.value] + 1] = chip
end



function BrChip:create(value)
    local chip
    local scale = BrConstants.chipInPoolScale
    local fontScale = Cache.packetInfo:isRealGold() and BrConstants.chipFntScale_RealGold or BrConstants.chipFntScale_Gold
    if type(value) == "string" then --传送进来的是颜色 值的意义不大
        chip = ChipCls.new({color = CHIPCOLOR[value], number = 0, scale = scale, fontScale = fontScale}) 
    else
        chip = ChipCls.new({color = self.cacheColorTbl[value], number = value, scale = scale, fontScale = fontScale})
    end
    chip:retain()
    chip.value = value

    self._rightChips = self._rightChips or {}
    self._rightChips[#self._rightChips+1] = chip
    return chip 
end

function BrChip:createT(value)
    local chips = {}
    --从大到小删除筹码
    local valueT = self.tbChipsValue
    
    if value >= valueT[1] then
        for i = #valueT, 1, -1 do
            local v = valueT[i]
            if value >= v then
                local num = math.floor(value / v)
                for j = 1, num do
                    chips[#chips+1] = self:getChip(v)
                end
                value = value - num * v
            end
        end
    end
	
    return chips
end

--保持接口不变 扩充新的函数
function BrChip:fly(delay,chip,from,to,cb)
    self:flyWithSpeed(delay,chip,from,to,0.0005,cb)
end

function BrChip:flyWithSpeed(delay,chip,from,to,speed,cb)
    self:_fly(delay, chip, from, to, cb, speed, false)
end

function BrChip:flyWithFixedTime(delay,chip,from,to,time,cb)
    self:_fly(delay, chip, from, to, cb, time, true)
end

--飞筹码的私有函数
function BrChip:_fly(delay,chip,from,to,cb,speed,isfixed)
    --当isfixed 为true时
    --则飞行时间是直接使用speed 否则飞行时间与距离相关为ds* speed
    if chip == nil or from == nil or to == nil then return end
    local rota = math.random(0,60)-30
    chip:setPosition(from)
    chip:setLocalZOrder(10)
    chip:setRotation(rota)
    local dx = math.abs(from.x - to.x)
    local dy = math.abs(from.y - to.y)
    local ds = math.abs(math.sqrt(dx*dx+dy*dy))
    local p1 = cc.p(from.x < to.x and from.x + 0.25*dx or from.x - 0.25*dx,from.y < to.y and from.y + dy*0.8 or from.y - dy*0.8)
    local p2 = cc.p(from.x < to.x and to.x - 0.25*dx or to.x + 0.25*dx,to.y < to.y and to.y - dy*0.8 or to.y + dy*0.8)
    
    local time
    if isfixed then
        time = speed
    else
        time = speed * ds
    end
    chip:runAction(cc.Sequence:create(
        cc.CallFunc:create(function() 
            chip:setVisible(true)
        end),
        cc.DelayTime:create(delay),
        -- cc.EaseSineOut:create(cc.BezierTo:create(ds*0.0005,{from,p1,to,p2})), --曲线
        cc.MoveTo:create(time, to),  --直线
        cc.CallFunc:create(function()
            self:putChip(chip)
            MusicPlayer:playChipEffect()
            if cb then cb() end
        end)
    ))
end


function BrChip:getTempPosition(from,to,value)
    local x1,x2,y1,y2 = from.x,to.x,from.y,to.y
    local x,y = math.abs(x1-x2),math.abs(y1-y2)
    local temp = y1 >= y2 and math.abs(y1-y2)*0.1*x/y or -math.abs(y1-y2)*0.1*x/y
    local value1 = x1 >= x2 and 1-value or value
    local value2 = y1 >= y2 and 1-value or value
    return cc.p((x1+x2)*value1,(y1+y2)*value2)
end

function BrChip:release()
    if self._rightChips == nil then return end
    for k , v in pairs(self._rightChips) do
        v:release()
        self._rightChips[k] = nil
        --logd("正在释放k-->"..k,self.TAG)
    end
    self.chipsPool = nil
    self._rightChips = nil
end

function BrChip:getIndex(value)
    for k, v in pairs(self._varTable1) do
        if value >= v then
            return k
        end
    end
end

--收到服务器的下注列表进行重新分配处理 以数值为键 筹码列表为值
function BrChip:updatePoolCacheChips()
    --默认从小到大
    local chipList = Cache.brdesk.addChipList
    local colorArr = BrConstants.ColorIndex
    if self.colorChipPools == nil then
        return
    end
    self.chipsPool = {}
    self.tbChipsValue = {}

    for i,v in ipairs(chipList) do
        local colorKey = colorArr[i]
        local chipArr = self.colorChipPools[colorKey]
        self.chipsPool[v] = chipArr
        for _, chip in ipairs(chipArr) do
            chip:getChildByName("number"):setString(v)
            chip.value = v
        end
        self.cacheColorTbl[v] = CHIPCOLOR[colorKey]
        self.tbChipsValue[i] = v
    end


    self.colorChipPools = nil
end

BrChipManager = BrChip