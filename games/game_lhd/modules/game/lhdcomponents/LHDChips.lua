--飞出去的筹码
local LHDChip = class("LHDChip") 

LHDChip.TAG = "LHDChip"
local ChipCls = require("src.common.Chip")
LHDChip.defaultColor = cc.c3b(255,255,255)--cc.c3b(251,205,0)--cc.c3b(0,255,96)
LHDChip.minChip = 1
function LHDChip:init()
    --logd("内存前"..cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    if self.chipsPool ~= nil then return end
    self.chipsPool = {}
    self.cacheColorTbl = {} --根据筹码值迅速找到对应颜色缓冲表
    self.tbChipsValue = {}
    --按照颜色进行缓存 当服务器发送来对应的下注列表时再按照数值进行分配
    local cacheNum = 100
    local colorArr = LHD_Games_Constant.ColorIndex
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

function LHDChip:getChip(value)
    if self.chipsPool == nil or self.chipsPool[value] == nil or next(self.chipsPool[value]) == nil then 
        return self:create(value) 
    end
    local chip = self.chipsPool[value][#self.chipsPool[value]]
    self.chipsPool[value][#self.chipsPool[value]] = nil
    chip:removeFromParent(true)
    return chip
end

function LHDChip:putChip(chip)
    if not self.chipsPool then return end
    local value = chip.value
    local pool = self.chipsPool[chip.value]
    chip.isBeSign = false
    chip.division = false
    chip:setVisible(false)
    self.chipsPool[chip.value] = self.chipsPool[chip.value] or {}
    self.chipsPool[chip.value][#self.chipsPool[chip.value] + 1] = chip
end

function LHDChip:setChipDivision(chip,bool)
    chip.division = bool
end

function LHDChip:getChipDivision(chip)
    return chip.division
end

function LHDChip:create(value)
    local chip
    local scale = LHD_Games_Constant.chipInPoolScale
    local fontScale = Cache.packetInfo:isRealGold() and LHD_Games_Constant.chipFntScale_RealGold or LHD_Games_Constant.chipFntScale_Gold
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

function LHDChip:createT(value)
    local chips = {}
    local t = self.tbChipsValueReverse
    if not t then return chips end
    local minChipValue = t[#t]

    for i = 1, GameConstants.FORCE_TIME do
        if value < minChipValue then
            break
        end
        logd("value---->".. value)
        for k, v in pairs(t) do
            if value >= v then
                chips[#chips+1] = self:getChip(v)
                value = value - v
                break 
            end
        end
    end


    return chips
end

function LHDChip:fly(delay,chip,from,to,cb)
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
    local rate = Cache.user.room_type == RoomType.BR and 0.0008 or 0.0004

    chip:runAction(cc.Sequence:create(
        cc.CallFunc:create(function() 
            chip:setVisible(true)
        end),
        cc.DelayTime:create(delay),
        cc.MoveTo:create(ds*rate, to),
        cc.CallFunc:create(function() 
            self:putChip(chip)
            MusicPlayer:playChipEffect()
            if cb then cb() end
        end)
    ))
end

function LHDChip:getTempPosition(from,to,value)
    local x1,x2,y1,y2 = from.x,to.x,from.y,to.y
    local x,y = math.abs(x1-x2),math.abs(y1-y2)
    local temp = y1 >= y2 and math.abs(y1-y2)*0.1*x/y or -math.abs(y1-y2)*0.1*x/y
    local value1 = x1 >= x2 and 1-value or value
    local value2 = y1 >= y2 and 1-value or value
    return cc.p((x1+x2)*value1,(y1+y2)*value2)
end

function LHDChip:release()
    if self._rightChips == nil then return end
    for k , v in pairs(self._rightChips) do
        v:release()
        self._rightChips[k] = nil
    end
    self.chipsPool = nil
    self._rightChips = nil
end

function LHDChip:getIndex(value)
    for k, v in pairs(self._varTable1) do
        if value >= v then
            return k
        end
    end
end

function LHDChip:getChipsValueTable()
    return self.tbChipsValue
end

--收到服务器的下注列表进行重新分配处理 以数值为键 筹码列表为值
function LHDChip:updatePoolCacheChips()
    loga("====>>>>updatePoolCacheChips<<<<====")
    --默认从小到大
    local chipList = Cache.lhdinfo.chip_list
    local colorArr = LHD_Games_Constant.ColorIndex
    if self.colorChipPools == nil then
        return
    end

    self.chipsPool = {}
    self.tbChipsValue = {}
    self.tbChipsValueReverse = {}
    for i,v in ipairs(chipList) do
        v = Cache.packetInfo:getProMoney(v)
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

    for i,v in ipairs(self.tbChipsValue) do
        self.tbChipsValueReverse[#self.tbChipsValue - i + 1] = v
    end

    self.colorChipPools = nil
end

ChipManager = LHDChip