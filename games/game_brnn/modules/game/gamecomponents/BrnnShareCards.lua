local BrnnShareCards = class("BrnnShareCards",function(paras)
    return paras.node
end)

local Card = import("..components.cards.Card")  
local IButton = import("..components.IButton")  

BrnnShareCards.TAG = "BrnnShareCards"

function BrnnShareCards:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end

function BrnnShareCards:init()
    for i = 1 , 5 do
        self["c"..i] = self:getChildByName("share_card_"..i)
        self["c"..i]:setVisible(false)
    end
end


function BrnnShareCards:giveCards(delay,cdelay,dpoint)
    delay = delay or 0
    cdelay = cdelay or 0
    self:clearCards()
    self.cards = {}
    for i = 1, 5 do
        local card = Card.new()
        self:addChild(card)
        Util:giveCardsAnimation({first = self.c1,delay = (i-1)*cdelay+delay,parent = self,c1 = self["c"..i],z = 2,c2 = card,dpoint = dpoint})
        self.cards[i] = card
    end
    
    for i = 1 , 5 do
        local card = self.cards[i]
        local dt = {delay+1.5,delay+1.5,delay+1.5,delay+2,delay+2.5}
        self:delayRun(dt[i],function() 
            card.value = Cache.BrniuniuDesk.br_sharecards[i]
            card:reverseSelf(nil,card.value)
        end)
    end
end

function BrnnShareCards:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function BrnnShareCards:clearCards()
    if self.cards == nil or #self.cards == 0 then return end
    for k, v in pairs(self.cards) do
        v:removeFromParent(true)
    end
    self.cards = {}
end

return BrnnShareCards