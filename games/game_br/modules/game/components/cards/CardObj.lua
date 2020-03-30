local Card = class("CardObj", function ()
	return cc.Sprite:create()
end)
Card.TAG = "CardObj"

-- 点数= cards[i]/4+1; 花色= cards[i]%4; # 0方 1梅 2红 3黑
function Card:ctor()
	self:init(true)
end

function Card:getCardFileInfo(value)
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
function Card:init()
	self:setBack(true)
end

function Card:setBack(flag)
	if flag == true then
		self:setTexture(BrRes.poker_back)
	else
		self:setTexture(BrRes.poker_bg)
	end
end

-- 初始化子节点
function Card:updatePoint(value)
	if value == nil then return end
	self:removeAllChildren(true)
	self:setBack(false)
	self:getCardFileInfo(value)
	self:setPoint(value)
end

-- 正常花色
function Card:setPoint()
	-- 设置点数
	local pointSprite = cc.Sprite:create(string.format(BrRes.poker_point, self.point,self.pointFlag))
	pointSprite:setPosition(23,self:getContentSize().height -27)
	pointSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(pointSprite, 2)

	--设置花色 小
	local colorSmallSprite = cc.Sprite:create(string.format(BrRes.poker_color_small, self.color))
	colorSmallSprite:setPosition(22,self:getContentSize().height -60)
	colorSmallSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(colorSmallSprite, 2)

	--设置中间的节点
	local colorLargeSprite = nil
	if self.point <= 10 then
		colorLargeSprite = cc.Sprite:create(string.format(BrRes.poker_color_large, self.color))
		colorLargeSprite:setPosition(69.5,self:getContentSize().height -106.50)
	else -- J、Q、K
		colorLargeSprite = cc.Sprite:create(string.format(BrRes.poker_color_special, self.point, self.pointFlag))
		colorLargeSprite:setPosition(65,self:getContentSize().height -90)
	end
	colorLargeSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(colorLargeSprite, 2)
end

return Card