--[[
-- 筹码帮助类：和筹码相关处理类
--]]
local M = {}
local m_instance

local function new( o )
    o = o or {}
    setmetatable(o, {__index=M})
    return o
end
local function getInstance( ... )
    if not m_instance then
        m_instance = new()
        m_instance:init()
    end
    return m_instance
end

function M:init( ... )
    self.res = {}
    self.resShadow = {}
    self.values = {}

    self._resTable1 = {
        GameRes.chips_yellow_img,
        GameRes.chips_orange_img,
        GameRes.chips_black_img,
        GameRes.chips_purple_img,
        GameRes.chips_red_img,
        GameRes.chips_green_img,
        GameRes.chips_blue_img,
        GameRes.chips_orange_img,
        GameRes.chips_yellow_img,
        GameRes.chips_yellow_img,
        GameRes.chips_orange_img
    }

    self._resTable2 = {
        GameRes.chips_shadow_yellow_img,
        GameRes.chips_shadow_orange_img,
        GameRes.chips_shadow_black_img,
        GameRes.chips_shadow_purple_img,
        GameRes.chips_shadow_red_img,
        GameRes.chips_shadow_green_img,
        GameRes.chips_shadow_blue_img,
        GameRes.chips_shadow_orange_img,
        GameRes.chips_shadow_yellow_img,
        GameRes.chips_shadow_yellow_img,
        GameRes.chips_shadow_orange_img
    }

    self._varTable1 =   {100000000,10000000,1000000,100000,10000,1000,500,100,50,5,1}
    self._varPartical = {40,40,32,24,18,12,8,8,8,8,8}
    self._varParticalSpeed = {320, 320, 300, 280, 280, 260, 260, 230, 230, 230, 230}
    self.maxChipsNumber = 12
    self.chipOffsetY = 1.8
end
--取得所有筹码的所有精灵
function M:getHeapTable (number) 
    local chipsNumber = number
    local chipsSeqen = {}
    local chipsIndex = 1

    for i = 1, GameConstants.FORCE_TIME do
        if chipsNumber <= 0 then
            break
        end
        for k,v in pairs(self._varTable1) do
            if chipsNumber >= v then 
                chipsSeqen[chipsIndex] = k
                chipsIndex = chipsIndex + 1
                chipsNumber = chipsNumber - v
                break
            end
        end
    end

    local retSprites = {}
    local retNumber = 0
    for k,v in pairs(chipsSeqen) do
        if k > self.maxChipsNumber then break end
        
        retNumber = retNumber + self._varTable1[v]
        if k == 1 then
            retSprites[k] = cc.Sprite:create(self._resTable2[v])
        else 
            retSprites[k] =  cc.Sprite:create(self._resTable1[v])
        end

        retSprites[k].value = self._varTable1[v]
        retSprites[k]:setAnchorPoint(cc.p(0.5, 0))
    end

    return retSprites, retNumber
end
function M:getHeap(number)
    local heapTable = self:getHeapTable(number)
    local heapNode = cc.Node:create()
    local heapWidth = 0
    local chipCount = 0
    local y = 0
    for k, heap in pairs(heapTable) do
        if heapWidth == 0 then
            heapWidth = heap:getContentSize().width
        end
        heap:setAnchorPoint(cc.p(0.5, 0))
        heap:setPosition(heapWidth/2, y)
        heapNode:addChild(heap)
        y = y + self.chipOffsetY
        chipCount = chipCount + 1
    end
    heapNode:setContentSize(cc.size(heapWidth, y))
    return heapNode, chipCount
end
function M:getMaxParValueImage( number )
    local maxPar = GameRes.chips_orange_img
    local particalNum = 3
    local speed = 1
    for k,v in pairs(self._varTable1) do
        if number >= v then 
            maxPar = self._resTable1[k]
            particalNum = self._varPartical[k]
            speed = self._varParticalSpeed[k]
            break
        end
    end
    return maxPar,particalNum,speed
end
-- 获取粒子效果
function M:getVictoryPartical(chip_num)
    local chipImage,particalNum,speed = self:getMaxParValueImage(chip_num)
    local emitter = cc.ParticleSystemQuad:create(GameRes.particle_win)
    emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage(chipImage))
    emitter:setAutoRemoveOnFinish(true)
    emitter:setTotalParticles(particalNum)
    emitter:setSpeed(speed)
    emitter:setSpeedVar(200)
    emitter:setDuration(0.5)

    return emitter
end
-- 筹码飞动
-- startPos: 其实位置
-- endPos: 结束位置
function M:moveChipToPos( target, startPos, endPos, callback, args )
    if not target or tolua.isnull(target) then return end
    if not endPos then return end

    startPos = startPos or cc.p(target:getPosition())
    local sequence = {}
    if args.delay then
        table.insert(sequence, cc.DelayTime:create(args.delay))
    end
    if args.sfunc then
        table.insert(sequence, cc.CallFunc:create(function( sender )
            args.sfunc(sender)
        end))
    end
    sequence[#sequence + 1] = cc.Show:create()
    sequence[#sequence + 1] = cc.EaseSineOut:create(cc.MoveTo:create(args.moveDelay, endPos))
    if callback then
        sequence[#sequence + 1] = cc.CallFunc:create(function( sender )
            callback(sender)
        end)
    end
    target:setPosition(startPos)
    target:runAction(cc.Sequence:create(sequence))
end
-- 移动筹码栈
function M:moveChipStackToPos( target, startPos, endPos, callback, args )
    if not target or tolua.isnull(target) then return end
    if not endPos then return end

    startPos = startPos or cc.p(target:getPosition())
    local delay = args.delay or 0
    target:setPosition(startPos)
    target:runAction(cc.Sequence:create(cc.Show:create()
        , cc.DelayTime:create(delay)
        , cc.Spawn:create(cc.EaseSineOut:create(cc.MoveTo:create(1.0, endPos))
            , cc.FadeTo:create(1.0, 30))
        , cc.CallFunc:create(function( sender )
            callback(sender)
        end)))
end

local ChipUtil = getInstance()
return ChipUtil