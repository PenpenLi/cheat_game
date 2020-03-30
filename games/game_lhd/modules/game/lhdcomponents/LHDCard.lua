
local CacheSpriteInstance = cc.SpriteFrameCache:getInstance()
local LHDCard = class("LHDCard", function(value)
	local sprite = cc.Sprite:create()
	return sprite
end)

local cardColor = {"r", "h", "m", "f"}

function LHDCard:ctor(value)	
	self:loadCardPlist()
    if value then
		self:setCardValue(value)
	end
end

function LHDCard:loadCardPlist( ... )
    CacheSpriteInstance:addSpriteFrames(GameRes.poker_plist, GameRes.poker_plist_png)
end

function LHDCard:setCardValue(value)
	if not value then
		self:removeAllChildrenWithCleanup(true)
		self:setSpriteFrame(CacheSpriteInstance:getSpriteFrameByName(LHD_Games_res.lhdcard_card_back))
		return
	end
	self.value = value
	local point = self:getCardPoint()
	local color = self:getCardColor()

	local pngName = string.format("poker_%s%s.png", self:getCardColor(), self:getCardPoint() < 10 and "0" .. self:getCardPoint() or self:getCardPoint())
	self:setSpriteFrame(CacheSpriteInstance:getSpriteFrameByName(pngName))
end

-- 花色= cards[i]%4; 0红 1黑 2梅 3方
function LHDCard:getCardColor()
	local color = math.mod(self.value , 4) + 1
	return cardColor[color]
end

--点数= cards[i]/4+1; 4-55 4的牌型是2
function LHDCard:getCardPoint()
	local point = math.floor(self.value /4) + 1
	if point == 14 then point = 1 end
	return point
end

-- 翻牌动画
function LHDCard:reverseSelf(cb,card, spawn)
    if card == nil then return end
    if card and type(card) == "number" then
        self.value = card 
    end
    local ani = cc.Animation:create()
    for i=2,7 do
        ani:addSpriteFrameWithFile(string.format(LHD_Games_res.poker_anim, i))
    end
    ani:setDelayPerUnit(0.04)

    local seq = cc.Sequence:create(cc.Animate:create(ani)
        , cc.CallFunc:create(function( ... )
            if cb then cb() end
            local pngName = string.format("poker_%s%s.png", self:getCardColor(), self:getCardPoint() < 10 and "0" .. self:getCardPoint() or self:getCardPoint())
            local sprite = cc.Sprite:createWithSpriteFrame(CacheSpriteInstance:getSpriteFrameByName(pngName))
            sprite:setScale(0.8)
            sprite:setAnchorPoint(0, 0)
            self:addChild(sprite)
        end))
    if spawn then
        seq = cc.Spawn:create(seq, spawn)
    end
    self:runAction(seq)
end


return LHDCard