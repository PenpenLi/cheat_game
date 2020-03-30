
-- // 点数= cards[i]/4+1; 花色= cards[i]%4; 0红 1黑 2梅 3方
-- local function getCardFileName (value)
--     if value == nil then return nil end
--     local _ctable = {"r","h","m","f"}
--     local i,t = math.modf(value/4)

--     i = i + 1
--     if i == 14 then i = 1 end

--     local c = math.fmod(value,4)
--     local ret = nil

--     if i < 10 then 
--         ret = "poker_".._ctable[(c+1)].."0"..i
--     else 
--         ret= "poker_".._ctable[(c+1)]..i
--     end
--     return GameRes[ret]
-- end

local cardObj = import (".CardObj")

local Card = class("Card",function(paras)
    paras = paras or {}
    local obj = cardObj.new()
    obj:updatePoint(paras.value)
    return obj
end)


function Card:ctor(paras)
    paras = paras or {}
    self.value = paras.value
    self._isDark = false
    self:loadCardTexture()
end

function Card:loadCardTexture( ... )
    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(BrniuniuRes.poker_textrue_plist, BrniuniuRes.poker_textrue)
end

function Card:refreshConnect()
    Util:delayRun(0.03, function()
        qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT,{type="show"})
    end)
end

-- 翻牌动画
function Card:reverseSelf(cb,card, spawn)
    if card == nil then return end
    if card and type(card) == "number" then
        self.value = card 
    end
    local ani = cc.Animation:create()
    for i=2,7 do
        ani:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(BrniuniuRes.poker_anim, i)))
    end

    -- local filename = getCardFileName(card)
    -- if not filename then
    --     self:refreshConnect()
    -- end
    
    -- ani:addSpriteFrameWithFile(filename or BrniuniuRes.poker_back)
    ani:setDelayPerUnit(0.04)
    -- ani:setLoops(-1)

    local seq = cc.Sequence:create(cc.Animate:create(ani)
        , cc.CallFunc:create(function( ... )
            if cb then cb() end
            local sprite = cardObj.new(card)
            sprite:setAnchorPoint(0, 0)
            sprite:updatePoint(card)
            self:addChild(sprite)
        end))
    if spawn then
        seq = cc.Spawn:create(seq, spawn)
    end
    self:runAction(seq)
end


-- 没有翻牌动作直接反过来
function Card:reverseSelfNoAction(cb,card)
    if card and type(card) == "number" then
        self.value = card
    end
    self:updatePoint(self.value)
    --self:getTexture():setAliasTexParameters()
end

-- 翻牌动画
function Card:reverseSelfShare(cb,card, spawn)
    self.reverse_time=0.15
    if card and type(card) == "number" then
        self.value = card 
    end
   
    local filename = getCardFileName(card)
    if not filename then
        self:refreshConnect()
    end
   
    local seq = cc.Sequence:create(
        cc.CallFunc:create(function( ... )
          self:showObtAniUseOrbitCamera(self:getContentSize())
            end),
        cc.DelayTime:create(self.reverse_time*2+0.2),
        cc.CallFunc:create(function( ... )
            if cb then 
                cb() 
            end
            end)
        )
    if spawn then
        seq = cc.Spawn:create(seq, spawn)
    end
    self:setOpacity(0)
    self:runAction(seq)
end
function Card:dark() 
    self:setColor(Theme.Color.DARK)
    self._isDark = true
end

function Card:isDark() 
    return self._isDark
end

function Card:light() 
    self:setColor(Theme.Color.LIGHT)
    self._isDark = false
end

function Card:showObtAniUseScaleTo( visibleSize) --使用scale 进行翻牌

    if self.m_pCardFront then
        self:removeChild(self.m_pCardFront)
    end
    if self.m_pCardBack then
        self:removeChild(self.m_pCardBack)
    end
    -- 加载牌的正反两面
    self.m_pCardFront = cardObj.new()
    self.m_pCardFront:updatePoint(self.value)

    self.m_pCardBack = cardObj.new() 
    self.m_pCardFront:setAnchorPoint(1.0,0.5)
    self.m_pCardBack:setAnchorPoint(1.0,0.5)

    self.m_pCardFront:setFlipX(true)
    self.m_pCardFront:setPosition(visibleSize.width,visibleSize.height/2)
    
    self.m_pCardBack:setPosition(visibleSize.width,visibleSize.height/2) 
    self:addChild(self.m_pCardFront,5)
    self:addChild(self.m_pCardBack,5) -- 动画序列（延时，隐藏，延时，隐藏）
   
    local pBackSeq =cc.Sequence:create(cc.DelayTime:create(0.2),cc.Hide:create(),cc.DelayTime:create(0.2),cc.Hide:create()) 
    local pScaleBack =cc.ScaleTo:create(0.4,-1,1)
    local pMoveBack = cc.MoveTo:create(0.4,cc.p(visibleSize.width,visibleSize.height/2))
    local pSpawnBack = cc.Spawn:create(pBackSeq,pScaleBack,pMoveBack)
     local action_back=cc.Sequence:create(pSpawnBack, cc.CallFunc:create(function(sender)
              sender:removeFromParent()
            end))
    self.m_pCardBack:runAction(action_back)-- 动画序列（延时，显示，延时，显示） 
   
    local pFrontSeq = cc.Sequence:create(cc.DelayTime:create(0.2),cc.Show:create(),cc.DelayTime:create(0.2),cc.Show:create());
    local pScaleFront = cc.ScaleTo:create(0.4,-1,1)
      local pMoveFront = cc.MoveTo:create(0.4,cc.p(visibleSize.width,visibleSize.height/2))
    local pSpawnFront = cc.Spawn:create(pFrontSeq,pScaleFront,pMoveFront)
  
     local action_front=cc.Sequence:create(pSpawnFront, cc.CallFunc:create(function(sender)
            self:setTexture(sender:getTexture())
             self:setOpacity(255)
             sender:removeFromParent()
            end))
    self.m_pCardFront:runAction(action_front)
end

function Card:showObtAniUseOrbitCamera(  visibleSize )--使用 相近进行翻牌
    if self.m_pCardFront then
        self:removeChild(self.m_pCardFront)
    end
    if self.m_pCardBack then
        self:removeChild(self.m_pCardBack)
    end
    -- 加载牌的正反两面
    self.m_pCardFront = cardObj.new()
    self.m_pCardFront:updatePoint(self.value)
    self.m_pCardBack  = cardObj.new()

    self.m_pCardFront:setAnchorPoint(--[[0.0--]] 1/3,0.5)
    self.m_pCardBack:setAnchorPoint(--[[1.0--]]  2/3,0.5)
    self.m_pCardFront:setPosition(--[[0--]]visibleSize.width/3,visibleSize.height/2)
    self.m_pCardBack:setPosition(--[[visibleSize.width--]] visibleSize.width*2/3,visibleSize.height/2)
    self:addChild(self.m_pCardFront,5)
    self:addChild(self.m_pCardBack,5)
   
    --持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
    local pBackCamera = cc.OrbitCamera:create(self.reverse_time, 1, 0, 0, -90, 0, 0)
     local pMoveBack = cc.MoveTo:create(self.reverse_time,cc.p(--[[0--]]visibleSize.width/3,visibleSize.height/2))

    local pLandCamera = cc.OrbitCamera:create(self.reverse_time, 1, 0, 90, -90, 0, 0)
    local pMoveFront = cc.MoveTo:create(self.reverse_time,cc.p(--[[0--]]visibleSize.width/3,visibleSize.height/2))
    local action_front_c=cc.Sequence:create(cc.Show:create(),cc.Spawn:create(pMoveFront,pLandCamera), cc.CallFunc:create(function(sender)
              self:setTexture(self.m_pCardFront:getTexture())
              self:setOpacity(255)
              self.m_pCardFront:removeFromParent()
              self.m_pCardBack:removeFromParent()
            end))
    local target_action= cc.TargetedAction:create(self.m_pCardFront,action_front_c)
    --self.m_pCardFront:runAction(action_front)

     self.m_pCardFront:setVisible(false)
     local action_back_c=cc.Sequence:create(cc.Show:create(),cc.Spawn:create(pMoveBack,pBackCamera),cc.Hide:create(),target_action)
     self.m_pCardBack:runAction(action_back_c)
 
end

function Card:getValue()
    return self.value
end

return Card