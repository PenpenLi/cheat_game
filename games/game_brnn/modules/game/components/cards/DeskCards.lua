--桌牌
local DeskCards = class("DeskCards",function ()
	return cc.Node:create()
end)
local Card = import(".Card")
local SpecialStyle = import(".SpecialStyle")

DeskCards.CARDS_MAX = 3
DeskCards.REVERT_DELAY = 0.8    --翻牌延迟

function DeskCards:ctor()
    self._deskCard = {}
    self._deskCardValue = nil
    self.specialStyle = SpecialStyle.new()  --特殊牌型
    self:init()
end

--初始化
function DeskCards:init()
    --得到牌的宽高
    local card = Card.new()
    self.card_w = card:getContentSize().width
    self.card_h = card:getContentSize().height
    self.card_gap = self.card_w * 0.05
    --计算控件宽高
    self.width = self.card_w * DeskCards.CARDS_MAX + self.card_gap * (DeskCards.CARDS_MAX - 1)
    self.height = self.card_h
    self:setContentSize(self.width, self.height)
end

--直接显示桌牌. 参数: cards数组
function DeskCards:refreshWithoutAction(cards)
    self._deskCardValue = clone(cards)  --牌的值
    self._deskCard = {}         --牌的对象数组
    if self:getCardsNumber() > 0 then
        for k, v in pairs(self._deskCardValue) do  -- 添加公共牌
            local card = Card.new({value=v})
            local pos = self:getCardPos(k)
            card:setAnchorPoint(0.5, 0.5)
            card:setPosition(pos)
            self:addChild(card)
            self._deskCard[k] = card
        end
        qf.event:dispatchEvent(ET.GAME_SHARE_CARDS_EVENT, {index = self:getCardsNumber(), total = self:getCardsNumber()})    --触发显示公共牌事件
    end
end

--显示桌牌动画. 参数: cards, 牌的值数组; offset_y, 发牌起始位置的纵向偏移
function DeskCards:refreshWithAction(paras)
    if paras == nil or paras.cards == nil then
        return 
    end
    local deskCardsNum = self:getCardsNumber()
    local updateCardsNum = table.getn(paras.cards)
    local first = (deskCardsNum == 0)

    self:reset()    --容错，停止动作并重置桌牌
    self._startPosition = cc.p(self.width / 2, paras.offset_y or 0)  --发牌位置偏移
    self._deskCardValue = clone(paras.cards)
    
    local flag = 0
    local fanpai_delay =  0.8
    for i = deskCardsNum + 1, updateCardsNum do
        local cardValue = self._deskCardValue[i]
        if flag ~= 0 then
            if i >3 and flag>2 then
                fanpai_delay = 2.0*(flag)-3
            end
            if i > 3 and flag<3 then
                fanpai_delay = 2.6*flag
            end
        end

        local delay2 = (3 - flag)*0.1 + 0.5 -- 延迟这么久后翻拍
        if deskCardsNum + 1 > 3 then
            delay2 = 0.7
        end
        self:_showAction({index=i,delay=flag*0.1+fanpai_delay, delay2=delay2,value=cardValue,first = first, cb=paras.cb})
        flag = flag + 1
    end
    self._deskCardValue = clone(paras.cards)  --牌的值
end

--翻牌动画
function DeskCards:_showAction(paras)
    local delay = paras.delay or 0
    local giveDeskCardAnimationTime =  0.2
    local moveDeskCardTime = 0.17 * (paras.index - 1)
    if paras.index > 2 then
        moveDeskCardTime = moveDeskCardTime + 0.02
    end
    local card = Card.new()
    card.value = paras.value
    local dest_pos = self:getCardPos(paras.index)       --最终放置的位置
    local send_pos = self:getCardPos((paras.first == true and paras.index < 4) and 1 or paras.index)    --发到桌面上的位置
    card:setAnchorPoint(0.5, 0.5)
    card:setPosition(self._startPosition)
    card:setScale(0.5)
    card:setVisible(false)
    self:addChild(card)
    self._deskCard[paras.index] = card

    card:runAction(cc.Sequence:create(
        cc.DelayTime:create(delay),
        cc.CallFunc:create(function() 
            card:setVisible(true)
        end),
        cc.Spawn:create(
            cc.ScaleTo:create(giveDeskCardAnimationTime,1),
            cc.MoveTo:create(giveDeskCardAnimationTime, send_pos) 
        ),
        cc.DelayTime:create(paras.delay2),
        cc.CallFunc:create(function ( sender )
            MusicPlayer:playMyEffect("FAPAI")
            sender:reverseSelfShare(function()
                --如果直接发牌到了目标位置，则不再做移动动作
                if send_pos.x == dest_pos.x and send_pos.y == dest_pos.y then
                    qf.event:dispatchEvent(ET.GAME_SHARE_CARDS_EVENT, {index = paras.index, total = self:getCardsNumber(), cb = paras.cb})    --触发显示公共牌事件
                else
                    card:runAction(cc.Sequence:create(
                        cc.MoveTo:create(moveDeskCardTime, dest_pos),
                        cc.CallFunc:create(function() 
                            qf.event:dispatchEvent(ET.GAME_SHARE_CARDS_EVENT, {index = paras.index, total = self:getCardsNumber(), cb = paras.cb})    --触发显示公共牌事件
                        end)
                    ))
                end
            end,
            sender.value)
        end)
        ))
end
-- 停止所有发牌动画并显示所有的牌
function DeskCards:stopAllActionAndShowAllCard( is_show_all )
    for k, v in pairs(self._deskCard) do
        v:stopAllActions()
        if v:isVisible() then
            v:setScale(1.0)
            v:setPosition(self:getCardPos(k))
            v:reverseSelfNoAction(nil, v.value)
        elseif is_show_all then -- 把隐藏的牌也显示出来
        end
    end
end
--重置，停止一切动作并直接显示桌牌(容错处理)
function DeskCards:reset()
    --没有桌牌或者没有正在进行的动作，不重置
    if self._deskCardValue == nil or self:getNumberOfRunningActions() == 0 then
        return
    end
    --重置桌牌
    local cardsValue = clone(self._deskCardValue)
    self:clear()
    self:showWithoutAction(cardsValue)
end

--获取桌牌数量
function DeskCards:getCardsNumber()
    if self._deskCardValue == nil then
        return 0
    else
        return table.getn(self._deskCardValue)
    end
end

--获取牌的位置
function DeskCards:getCardPos(index)
    local x = (self.card_w + self.card_gap) * (index - 1) + self.card_w / 2
    local y = self.card_h / 2
    return cc.p(x, y)
end

--使所有牌变暗
function DeskCards:darkAll()
    for k, card in pairs(self._deskCard) do 
        card:dark() 
    end
end

--使部分牌变亮
function DeskCards:light(max_cards)
    if max_cards == nil then return end
    for k,v in pairs(self._deskCard) do v:dark() end
    for k,v in pairs(max_cards) do 
        for j,c in pairs(self._deskCard) do
            if c.value == v then c:light() break end
        end
    end
end

--展示特殊牌型
function DeskCards:showSpecialCardType(cardType)
    if self.specialStyle == nil then
        self.specialStyle = SpecialStyle.new()
    end
    if self.specialStyle ~= nil then
        self.specialStyle:showSpecialStyle(cardType, self._deskCard, self)
    end
end

--清除桌牌
function DeskCards:clear()
    self:_stopAllChildrenActions()
    self:removeAllChildren(true)
    if self.specialStyle ~= nil then    --清除特殊牌型
        self.specialStyle:clear()
        self.specialStyle = nil
    end
    self._deskCardValue = nil   --清除桌牌值
    self._deskCard = {}         --控件对象清空
end

--清除桌牌
function DeskCards:_stopAllChildrenActions()
    for k,v in pairs(self._deskCard) do
        if not tolua.isnull(v) then
            v:stopAllActions()
        end
    end
end

function DeskCards:getValue()
    local cards_value = {}
    if self._deskCard ~= nil then
        for k, card in pairs(self._deskCard) do
            table.insert(cards_value, card:getValue())
        end
    end
    return cards_value
end

function DeskCards:setValue(cards)
    self:refreshWithoutAction(cards)
end

return DeskCards