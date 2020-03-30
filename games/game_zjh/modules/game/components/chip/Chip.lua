
local Chip = class("Chip",function  ( paras )
	return cc.Node:create()
end)

local ChipNum = import(".ChipNum")
local ChipUtil = import(".ChipUtil")

Chip.maxChipsNumber = 12
Chip.chipOffsetY = 1.8
Chip.maxChipLen = 160
Chip.unitNLen = 16

Chip.HEAP_OFFSET_X = 4  --筹码堆相对于底图左/右边缘的坐标偏移 x
Chip.HEAP_OFFSET_Y = 0  --筹码堆相对于底图下边缘的坐标偏移 y
Chip.HEAP_TXT_GAP = 4   --筹码堆和数字之间的距离
Chip.TXT_OFFSET_X = 6   --数字距离底图左/右边缘的偏移
Chip.DESCRIPTION_VERICAL_TAP = -10

Chip.DESC_TAG = 134

Chip._resTable1 = ChipUtil._resTable1
Chip._resTable2 = ChipUtil._resTable2
Chip._varTable1 = ChipUtil._varTable1--	{100000000,10000000,1000000,100000,10000,1000,500,100,50,5,1}
Chip._varPartical = ChipUtil._varPartical --{40,40,32,24,18,12,8,8,8,8,8}
Chip._varParticalSpeed = ChipUtil._varParticalSpeed --{320, 320, 300, 280, 280, 260, 260, 230, 230, 230, 230}

--以下是用来设置精度的阀值. 在100万到1亿之间, 只显示小数点以后的1位数字, 其他显示2位
Chip.PrecisionThreshold_1 = 100000000
Chip.PrecisionThreshold_2 = 1000000

function Chip:ctor(paras)
    self.precision = 2    --精度
    if paras ~= nil and paras.direction ~= nil then --方向0->筹码在左边    方向1->筹码在右边
        self.direction = paras.direction
    else
        self.direction = 0
    end
	self:init()
end

function Chip:init(paras)
    local chip_temp = cc.Sprite:create(Chip._resTable2[1])
    self.chipSize = chip_temp:getContentSize()
    local middle = cc.Sprite:create(GameRes.chip_04)
    self.fixHeight = middle:getContentSize().height
	self.number = 0
    self:hideContent()
end

--更新筹码数. paras.number: 增加多少筹码; self.beauty, 是否是美女
function Chip:update(paras)
    self.number = self.number + paras.number
    self.beauty = paras.beauty
    if self.number < Chip.PrecisionThreshold_1 and self.number > Chip.PrecisionThreshold_2 then   --大于100万精度改为取小数点以后2位
        self.precision = 0
    else
        self.precision = 2
    end
    
    if self.number <= 0 then
        self:hideContent()
    else
        self:showContent()
        self:removeAllChips()
        self:rebuild(self.number)
    end
end

function Chip:removeAllChips()
    local children = self:getChildren()
    for k, child in pairs(children) do
        local tag = child:getTag()
        if tag ~= nil and tag == self.DESC_TAG then
            --jackpot描述不移除
        else
            child:removeFromParent(true)
        end
    end
end

--更新筹码数到paras.number
function Chip:updateTo(paras)
    self.number = 0
    self:update(paras)
end
--添加筹码描述(Jackpot会用到)
function Chip:appendDescriptionSprite(img)
    if self:getChildByTag(self.DESC_TAG) ~= nil then
        self:removeChildByTag(self.DESC_TAG)
    end

    local sprite = cc.Sprite:create(img)
    sprite:setAnchorPoint(0.5, 1)
    sprite:setTag(self.DESC_TAG)
    self:addChild(sprite)
    local x = self:getContentSize().width / 2
    local y = self.DESCRIPTION_VERICAL_TAP
    sprite:setPosition(x, y)
end

function Chip:getLen()
    local width = self:getContentSize().width
    local desc = self:getChildByTag(self.DESC_TAG)
    if desc ~= nil then
        width = (width >= desc:getContentSize().width) and width or desc:getContentSize().width
    end
    return width
end

--获取最上面的筹码的中心坐标，提供给增减筹码动画
function Chip:getHeapTopCenter()
    local x, y = 0, 0
    if self.heapNode == nil or tolua.isnull(self.heapNode) then
        --按label_width=0计算chip的固定位置
        if self.direction == 0 then
            x = Chip.HEAP_OFFSET_X + self.chipSize.width / 2
        else
            x = Chip.TXT_OFFSET_X + Chip.HEAP_TXT_GAP + self.chipSize.width / 2
        end
        y = Chip.HEAP_OFFSET_Y
    else
        x, y = self.heapNode:getPosition()
        y = y + self.chipCount * self.chipOffsetY
    end
    return x, y
end

function Chip:getRealContentSize()
    if self.heapNode == nil or tolua.isnull(self.heapNode) then
        return {width = Chip.HEAP_OFFSET_X + Chip.HEAP_TXT_GAP + self.chipSize.width + Chip.TXT_OFFSET_X, height = self.fixHeight}
    end
    return self:getContentSize()
end

--显示
function Chip:showContent()
	self:setVisible(true)
end

--隐藏
function Chip:hideContent() 
	self:setVisible(false)
	self.number = 0
    self.chipCount = 0
    self:removeAllChips()
    self.heapNode = nil
end

function Chip:getValue()
    return self.number
end

----------------------- private function -----------------------------
function Chip:rebuild(number)
    --筹码堆
    local heapNode, chipCount = ChipUtil:getHeap(number)
    local heapSize = heapNode:getContentSize()

    --筹码数量
    local numTxt = ChipNum.new({num=number, precision=self.precision})
	if self.beauty then 
        numTxt:setColor(cc.c3b(251,205,0))
	else
        numTxt:setColor(cc.c3b(251,205,0))
	end
    local numTxtSize = numTxt:getContentSize()

    --背景
    local bgW, bgH = self:createBg(heapSize.width, numTxtSize.width)
    
    --设置大小(将背景大小做为筹码堆对象的大小)
    self:setContentSize(bgW, bgH) 
    
    --子控件位置调整
    local numTxtY = (bgH - numTxtSize.height) / 2
    heapNode:setAnchorPoint(0.5, 0)
    numTxt:setAnchorPoint(0, 0)
    if self.direction == 0 then
        heapNode:setPosition(Chip.HEAP_OFFSET_X + heapSize.width / 2, Chip.HEAP_OFFSET_Y)
        self:addChild(heapNode)
        numTxt:setPosition(Chip.HEAP_OFFSET_X + heapSize.width + Chip.HEAP_TXT_GAP, numTxtY)
    else
        numTxt:setPosition(Chip.TXT_OFFSET_X, numTxtY) 
        heapNode:setPosition(Chip.TXT_OFFSET_X + numTxtSize.width + Chip.HEAP_TXT_GAP + heapSize.width / 2, Chip.HEAP_OFFSET_Y)
        self:addChild(heapNode)
    end
    self:addChild(numTxt)
    self.heapNode = heapNode
    self.chipCount = chipCount
end

--获取背景, 返回背景大小
function Chip:createBg(heap_w, txt_w)
    --计算背景最小宽度
    local totalWidth = Chip.HEAP_OFFSET_X + heap_w + Chip.HEAP_TXT_GAP + txt_w + Chip.TXT_OFFSET_X
    --左半圆
	local left = cc.Sprite:create(GameRes.chip_03)
    local leftSize = left:getContentSize()
    left:setAnchorPoint(0, 0)
    self:addChild(left)
    --中间部分
	local middle = cc.Sprite:create(GameRes.chip_04)
    local middleSize = middle:getContentSize()
    middle:setAnchorPoint(0, 0)
    self:addChild(middle)
    --右半圆
	local right = cc.Sprite:create(GameRes.chip_05)
    local rightSize = right:getContentSize()
    right:setAnchorPoint(0, 0)
    self:addChild(right)
    --拉伸中间部分
    local middleWidth = totalWidth - leftSize.width - rightSize.width
    middle:setScaleX(middleWidth / middleSize.width)
    --位置调整
    left:setPosition(0, 0)
    middle:setPosition(leftSize.width, 0)
    right:setPosition(leftSize.width + middleWidth, 0)

    return leftSize.width + middleWidth + rightSize.width, middleSize.height
end

function Chip:show() end
function Chip:hide() end

return Chip