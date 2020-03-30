local CardObj = class("CardObj", function ()
	return cc.Sprite:create()
end)
CardObj.TAG = "CardObj"

-- 点数= cards[i]/4+1; 花色= cards[i]%4; 0红桃 1黑桃 2梅花 3方片
function CardObj:ctor()
	self:init(true)
end

function CardObj:loadCardTexture( ... )
    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(BrniuniuRes.poker_textrue_plist, BrniuniuRes.poker_textrue)
end

function CardObj:getCardFileInfo(value)
	if value == nil then return nil end
	self.value = value
    local i,t = math.modf(value/4)

    i = i + 1
    if i == 14 then i = 1 end

    local c = math.fmod(value,4)
    self.color = c
    self.point = i

    local colorConfig = {
    	[0] = 0,
    	[1] = 1,
    	[2] = 0,
    	[3] = 1
	}
    self.pointFlag = colorConfig[self.color]
end

-- 初始化
function CardObj:init()
	self:loadCardTexture()
	self:setBack(true)
end

function CardObj:setBack(flag)
	if flag == true then
		self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(BrniuniuRes.poker_back))
	else
		self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(BrniuniuRes.poker_bg))
	end
end

-- 初始化子节点
function CardObj:updatePoint(value)
	if value == nil then return end
	self:removeAllChildren(true)
	self:setBack(false)
	self:getCardFileInfo(value)
	self:setPoint(value)
end

-- 正常花色
function CardObj:setPoint()
	-- 设置点数
	local pointSprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(BrniuniuRes.poker_point, self.point,self.pointFlag)))
	pointSprite:setPosition(23,self:getContentSize().height -27)
	pointSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(pointSprite, 2)

	--设置花色 小
	local colorSmallSprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(BrniuniuRes.poker_color_small, self.color)))
	colorSmallSprite:setPosition(22,self:getContentSize().height -60)
	colorSmallSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(colorSmallSprite, 2)

	--设置中间的节点
	local colorLargeSprite = nil
	if self.point <= 10 then
		colorLargeSprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(BrniuniuRes.poker_color_large, self.color)))
		colorLargeSprite:setPosition(69.5,self:getContentSize().height -106.50)
	else -- J、Q、K
		local flag = math.fmod(self.color,2)
		colorLargeSprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(BrniuniuRes.poker_color_special, self.point, self.pointFlag)))
		colorLargeSprite:setPosition(65,self:getContentSize().height -90)
	end
	colorLargeSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(colorLargeSprite, 2)
end

return CardObj