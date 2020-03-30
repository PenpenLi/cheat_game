
-- // 点数= cards[i]/4+1; 花色= cards[i]%4; 0红 1黑 2梅 3方

local function getCardFileName (value)
    if value == nil then return nil end
    --2019-09-20 修改为 0方 1梅 2红 3黑
    local _ctable = {"f","m","r","h"}
    local i,t = math.modf(value/4)

    i = i + 1
    if i == 14 then i = 1 end
    local c = math.fmod(value,4)
    local ret = nil

    if i < 10 then ret = "poker_".._ctable[(c+1)].."0"..i
    else ret= "poker_".._ctable[(c+1)]..i
    end
    return Niuniu_Games_res[ret]
end

local Card = class("Card",function(paras)
    paras = paras or {}
    return cc.Sprite:create()
end)

function Card:ctor(paras)
    paras = paras or {}
    self.value = paras.value
    self:showBack()
    self._lightback = cc.Sprite:create()
    self:initLightBack()
    self._isback = true
end

function Card:getCardValue()

    -- body
    local i,t = math.modf(self.value/4)

    i = i + 1
    if i == 14 then i = 1 end

    self._card_value = i
    
    return self._card_value
end

--显示背面
function Card:showBack()
    self._isback = true
    
    self:setTexture(Cache.kanconfig:getUIResource(Cache.kanconfig.UI_BACKCARD))
end

--显示正面
function Card:showFront()
    self._isback = false
    local filename = getCardFileName(self.value)
    if filename then
        self:setTexture(filename)
    end
end

function Card:dark() 
    self:setColor(Theme.Color.DARK)
end

function Card:light() 
    self:setColor(Theme.Color.LIGHT)
end

--翻转
function Card:flip()
    if self._isback == true then
        local orbitAction = cc.OrbitCamera:create(0.3, 1, 0, 0, -180, 0, 0)
        local delayAction = cc.DelayTime:create(0.18)
        local callback    = cc.CallFunc:create(handler(self, self.onBackActionComplete_))
        local sq          = cc.Sequence:create(delayAction,callback)
        local spawn       = cc.Spawn:create(orbitAction,sq)
        self:runAction(spawn)
        self._isback = false
    end
end

--设置value
function Card:setValue(value)
    self.value = value
end

function Card:getValue(value)
    return self.value
end

function Card:onBackActionComplete_()
    self:setFlipX(true)
    self:showFront()
end

function Card:refreshConnect()
    Util:delayRun(0.03, function()
        qf.event:dispatchEvent(Niuniu_ET.APPLICATION_ACTIONS_EVENT,{type="show"})
    end)
end

--设置牌高亮背景
function Card:initLightBack()
    self._lightback:setTexture(Niuniu_Games_res.pokerlightback)
    local size = self:getContentSize()
    self._lightback:setPosition(size.width/2-4,size.height/2+10)
    self._lightback:setName("LightBack")
    self:addChild(self._lightback)
    self._lightback:setVisible(false)
end

--显示牌高亮背景
function Card:showLightBack()
    self._lightback:setVisible(true)
end

--hide牌高亮背景
function Card:hideLightBack()
    self._lightback:setVisible(false)
end

-- 添加监听
function Card:addTouchListener( clickedCall, beganCall, movedCall, cancelledCall, tag_ )
    self.clickedCall = clickedCall 
    self.beganCall = beganCall 
    self.movedCall = movedCall 
    self.cancelledCall = cancelledCall 
    self.tag_ = tag_

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function( touch, event )
        local beganPos = self:getParent():convertToNodeSpace(touch:getLocation())
        if cc.rectContainsPoint(self:getBoundingBox(), beganPos) then
            if self.beganCall then
                return self.beganCall(self, beganPos)
            end
            return true
        end
        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function( touch, event )
        if self.movedCall then
            self.movedCall(self, self:getParent():convertToNodeSpace(touch:getLocation()))
        end
    end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function( touch, event )
        if self.clickedCall then
            self.clickedCall(self, self:getParent():convertToNodeSpace(touch:getLocation()))
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function( touch, event )
        if self.cancelledCall then
            self.cancelledCall(self)
        end
    end, cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self.listener = listener
end
-- 设置能否进行触摸监听
function Card:setListenerEnabled( enabled )
    if self.listener then
        self.listener:setEnabled(enabled)
    end
end
-- 设置是否可以吞噬
function Card:setListenerSwallowEnabled( enabled )
    if self.listener then
        self.listener:setSwallowTouches(enabled)
    end
end

return Card