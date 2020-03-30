--[[
-- 是我自己
--]]

local M = class("MySelf", import(".User"))

local Card = import("..cards.Card") 
local Chip = import("..chip.Chip")
local ChipNum = import("..chip.ChipNum")
local ChipUtil = import("..chip.ChipUtil")
local UserDisplay = import(".UserDisplay")
local UserStatusNode = import("..UserStatus")

M.TAG = "MySelf"
function M:ctor( args )
    self.super.ctor(self, args)
    self.desk = Cache.DeskAssemble:getCache()
end

-- 初始化筹码
function M:initChip()
    self._chip = Chip.new({direction = 1})
    self._chip:setAnchorPoint(1, 0)

    local cs = self.selfSize
    local sx, sy = -0.1, 0.75
    if 5 == self.total then
    	sx, sy = -0.1, 0.75
    elseif 9 == self.total then
    	sx, sy = -0.2, 0.75
    end
    self._chip:setPosition(cs.width*sx, cs.height*sy)
    self._chip:hideContent()
    self:addChild(self._chip, 5)
end
function M:getDoubleCard( noanimation )
	local card1, card2
    if noanimation then
        card1 = Card.new({value=self.desk.play_info.cards[1]})
        card2 = Card.new({value=self.desk.play_info.cards[2]})
    else
        card1 = Card.new()
        card2 = Card.new()
    end
    return card1, card2
end

function M:giveCard(paras)
    self:clearCard()
    self.is_reverse = false

    local card1, card2 = self:getDoubleCard(paras.noanimation)
    self.card1 = self:cloneCardStatus({card=card1,status=1})
    self.card2 = self:cloneCardStatus({card=card2,status=2})

    self.card1:setAnchorPoint(0.3,0.8) 
    self.card2:setAnchorPoint(0.3,0.8)
    card1:setPosition(cc.p(self.c1p[1],self.c1p[2]))
    card2:setPosition(cc.p(self.c2p[1],self.c2p[2]))
    
    card1:setScale(self.c1:getScale())
    card2:setScale(self.c2:getScale())
    paras = paras or {}
    local rev = paras.rev or nil
    
    if paras.dark then
        self.card1:dark()
        self.card2:dark()
    end
    
    if paras.noanimation then return end
    -- 如果没有牌型，则延迟1帧重连
    if (not self.desk.play_info.cards[1] 
        or not self.desk.play_info.cards[2]) then
        Util:delayRun(0.03, function()
            qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT,{type="show"})
        end)
    end

    self.card1.exg = {rev=rev,card=paras.card1}     -- 绑定一些信息
    self.card2.exg = {rev=rev,card=paras.card2}
    self:_giveCardAnimation(1,card1,self.c1:getScale(),self.c1:getRotation(),0.06,paras.st - 0.05,self.c1p[1],self.c1p[2])
    self:_giveCardAnimation(2,card2,self.c2:getScale(),self.c2:getRotation(),paras.st + 0.03,0,self.c2p[1],self.c2p[2])
end

-- 发完牌后回调
function M:whenGivedCard( sender, value )
    sender:setLocalZOrder(3)
    sender.value = value
    sender:reverseSelfNoAction(nil, value)
end

function M:_giveCardAnimation(status,card,scale,rotate,delay,delay2,x,y)
    local dpoint = self:convertToNodeSpace(self.middlePostion)
    local value = self.desk.play_info.cards[status]
    --if self.uin ~= Cache.user.uin then y = y - 50 end
    local giveDelay = self.giveCardAnimationTime
    local toPos = cc.p(self.c1p[1],self.c1p[2])
    card:setLocalZOrder(self.MOVEING_ZORDER)
    card:setScale(0.5)
    card:setRotation(0)
    card:setPosition(dpoint)
    card:setVisible(false)
    card:runAction(cc.Sequence:create(cc.DelayTime:create(delay)
        , cc.CallFunc:create(function() 
                MusicPlayer:playMyEffect("FAPAI")
                card:setVisible(true)
            end)
        , cc.Spawn:create(
            cc.EaseSineIn:create(cc.ScaleTo:create(giveDelay, scale)),
            cc.EaseSineIn:create(cc.MoveTo:create(giveDelay, toPos)))
        , cc.DelayTime:create(0.4 + delay2)
        , cc.CallFunc:create(function( sender )
                self:whenGivedCard(sender, value)
            end)
        , cc.DelayTime:create(0.1)
        , cc.Spawn:create(
            cc.EaseSineIn:create(cc.RotateTo:create(0.3,rotate)),
            cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(x,y)))
        )))
end

---[玩家点了看牌按钮后看牌]
function M:lookCards()
    --在翻牌之前需要把看牌的状态更新,暂时还没写
    if self.looking_status ~= 2 then
        for i = 1, 2 do
            self["card"..i]:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.3*(i-1)),
                cc.CallFunc:create(function(sender) 
                    sender.value = self.desk.jh_user_cards[i] -- 为毛是jh_user_cards？
                    sender:reverseSelf(nil, self.desk.jh_user_cards[i])
            end)))
        end
    end
end
function M:adjustElements()
    self.c1:setScale(0.9)
    self.c2:setScale(0.9)
    self.c1p = {self.c1:getPositionX() + 45, self.c1:getPositionY() + 30}
    self.c2p = {self.c2:getPositionX() + 70, self.c2:getPositionY() + 30}
end
--修复玩家手牌。对玩家没有手牌问题进行容错处理。只有当找不到自己的手牌数据时，才重新拉取牌桌数据
function M:repairCards()
    if self.card1 == nil or tolua.isnull(self.card1) 
        or self.card2 == nil or tolua.isnull(self.card2) then
        if self.desk.play_info.cards[1] == nil or self.desk.play_info.cards[2] == nil then
            -- 手牌数据不全，无法修复
            return false
        else
            -- 没有手牌，重新创建手牌
            self:giveCard({noanimation=true})
        end
    end
    return true
end
-- 倒计时回调
function M:timeCounter(index)
    if index <= math.floor(self.defaultCountTimer/2) then 
        if index == math.floor(self.defaultCountTimer/2) then qf.platform:playVibrate(500) end -- 震动
        self:cardShock(0)
        MusicPlayer:playMyEffect("G_ALARM")
    end
end
-- 还原牌的状态
function M:cardsReduction()
    if self.card1 == nil or self.card2 == nil then return end
    for i = 1 , 2 do
        local oc = self["c"..i]
        local rc = self["card"..i]
        rc:setScale(oc:getScale())
        rc:setRotation(oc:getRotation())
    end
end
-- 牌震动
function M:cardShock(time)
    --self:setCardPosition()
    time = time or 0
    if self.card1 == nil or self.card2 == nil then return end
    self:cardsReduction()
    local actionTime = 0.125
    local function _createBig( ... )
        local scaleBig = cc.Spawn:create(cc.EaseSineOut:create(cc.RotateBy:create(actionTime,-5))
            ,cc.EaseSineOut:create(cc.ScaleTo:create(actionTime,11/10,10/9)))
        return scaleBig
    end
    local function _createSmall( ... )
        local scaleSmall = cc.Spawn:create(cc.EaseSineIn:create(cc.RotateBy:create(actionTime,5))
            ,cc.EaseSineIn:create(cc.ScaleTo:create(actionTime,10/11,9/10)))
        return scaleSmall
    end
    self.card1:runAction(cc.Sequence:create(
        _createBig(), _createSmall(),
        _createBig(), _createSmall(),
        _createBig(), _createSmall(),
        _createBig(), _createSmall()
    ))
    self.card2:runAction(cc.Sequence:create(cc.DelayTime:create(time),
        _createBig(), _createSmall(),
        _createBig(), _createSmall(),
        _createBig(), _createSmall(),
        _createBig(), _createSmall()
    ))
end
-- 弃牌 , 去掉牌， 去掉最大牌信息
function M:dropCard ( noaction ) 
    self:setStatus(GameUserStatus.STATUS_GIVEUP)
    self:setStopStatus()
    self:setMaxCardInfoDark()

    local dpoint = self:convertToNodeSpace(self.middlePostion)
    for i = 1,2 do
        if self["card"..i] then
            self["card"..i]:stopAllActions()    --抖动停止
            self["card"..i]:runAction(cc.Sequence:create(
                cc.Spawn:create(
                    cc.MoveTo:create(self.dropCardAnimationTime*0.5,dpoint),
                    cc.ScaleTo:create(self.dropCardAnimationTime*0.5,0)
                ),
                cc.CallFunc:create(function (sender)
                    if sender == self.card2 then
                        self:setDropStatus()
                    end
                end)))
        end
    end
    
    self:removeTimer()
end

--设置弃牌后的状态
function M:setDropStatus()
    if not self.card1 or not self.card2 then return end

    --还原角度和缩放
    self:cardsReduction()
    --重置位置
    self.card1:setAnchorPoint(0.3,0.8) 
    self.card2:setAnchorPoint(0.3,0.8)
    self.card1:setPosition(cc.p(self.c1p[1],self.c1p[2]))
    self.card2:setPosition(cc.p(self.c2p[1],self.c2p[2]))
    --变灰
    self.card1:dark()
    self.card2:dark()
    --容错，显示牌的正面
    local value1 = self.desk.play_info.cards[1]
    local value2 = self.desk.play_info.cards[2]
    if value1 == nil or value2 == nil then
        loge("弃牌后找不到手牌的值")
        return
    end
    self.card1:reverseSelfNoAction(nil, value1)
    self.card2:reverseSelfNoAction(nil, value2)
end

function M:setmaxCardtxt(flopCardsNum)
    local mc = self.desk:getMyMaxCardsFormation(flopCardsNum)
    if mc == nil then
        return 
    end
    local cs = self.selfSize
    local maxCardInfo = self:getChildByTag(self.maxCardInfoTAG)
    if maxCardInfo == nil then 
        maxCardInfo = cc.LabelTTF:create("", GameRes.font1, 40)
        maxCardInfo:setAnchorPoint(cc.p(0,0.5))
        maxCardInfo:setPosition(cs.width*1.05,cs.height*0.08)
        maxCardInfo:setTag(self.maxCardInfoTAG)
        self:addChild(maxCardInfo,10)
    end
    maxCardInfo:setString(GameTxt.string008[mc+1])
end
-- 更新自己的额最大牌信息. flopCardsNum: 当前翻开了第几张牌
function M:updateMaxCardInfo(flopCardsNum)
    --亮牌之后不许再更新, 如果指定了根据翻开的桌牌数进行更新，则更新
    if self.is_reverse and flopCardsNum == nil then return end
    local m = self.desk:getUserByUin(self.uin)

    if m == nil then return end
    --游戏中、弃牌、allin都要显示牌型
    if m.status ~= UserStatus.USER_STATE_INGAME 
        and m.status ~= UserStatus.USER_STATE_ALLIN 
        and m.status ~= UserStatus.USER_STATE_GIVEUP then
        return 
    end
    self:setmaxCardtxt(flopCardsNum)
end
-- 移除最大牌型
function M:removeMaxCardInfo() 
    self:removeChildByTag(self.maxCardInfoTAG)
end
-- 把最大牌型设置为灰色
function M:setMaxCardInfoDark()
    local maxCardInfo = self:getChildByTag(self.maxCardInfoTAG)
    if maxCardInfo ~= nil then
        maxCardInfo:setColor(Theme.Color.DARK)
    end
end
function M:ready()
	self.super.ready(self)

    self:removeMaxCardInfo()
end
-- 摊牌
function M:showCard( paras )
    if not paras or not paras.card1 or not paras.card2 then return end
    
    local card1, card2 = self.card1, self.card2
    -- 如果没有牌就不执行
    if not card1 or not card2 then return end
    
    local cs = self.selfSize
    card1:setVisible(true)
    card2:setVisible(true)
    
    local ca1 = card1:getAnchorPoint()
    local ca2 = card2:getAnchorPoint()

    local function createSpawn( dt, px, py )
        return cc.Spawn:create(cc.MoveTo:create(dt, cc.p(px, py))
            ,cc.RotateTo:create(0.3, 0)
            ,cc.ScaleTo:create(0.3, 0.95))
    end
    if not self.is_reverse then
        local spawn1 = createSpawn(0.3, cs.width*0.4*ca1.x/0.5-2, cs.height*0.44*ca1.y/0.5)
        local spawn2 = createSpawn(0.3, cs.width*0.8*ca2.x/0.5+2, cs.height*0.44*ca2.y/0.5)
        card1:runAction(spawn1)
        card2:runAction(spawn2)
    end
    self.is_reverse = true

    if not paras.nodark then
        card1:dark()
        card2:dark()
        -- 解决服务器bug
        local mc = self.desk:getMyMaxCardsFormation()
        self:showCardType(mc)
        self:removeMaxCardInfo()
    end
end

function M:showMyCard(paras)--亮牌
    if paras.card1 == nil or paras.card2 == nil then return end
    self:setNormalStatus()
    
    if not self.card1 or not self.card2 then
        local card1 = Card.new({value=paras.card1})
        local card2 = Card.new({value=paras.card2})
        self.card1 = self:cloneCardStatus({card=card1,status=1})
        self.card2 = self:cloneCardStatus({card=card2,status=2})
        --if self.uin == Cache.user.uin then  self.card2:setRotation(-self["c1"]:getRotation()) end
        self.card1:setAnchorPoint(0.3, 0.8) 
        self.card2:setAnchorPoint(0.3, 0.8)
        card1:setPosition(cc.p(self.c1p[1], self.c1p[2]))
        card2:setPosition(cc.p(self.c2p[1], self.c2p[2]))

        card1:setScale(self.c1:getScale())
        card2:setScale(self.c2:getScale())
    end
    
    self:showCard(paras) 
    self:lightDoubleCard()
    self:setStatus(GameUserStatus.STATUS_SHOWCARDS) 
    self.lockStatus = true --锁定状态，在setNormalStatus 中恢复
end

-- 根据状态进行改变
function M:updateWithStatus( paras )
    self.status = paras.status
    if self.status == UserStatus.USER_STATE_NORMAL then
    elseif self.status == UserStatus.USER_STATE_STAND then
    elseif self.status == UserStatus.USER_STATE_STAND_WAIT then
    elseif self.status == UserStatus.USER_STATE_READY then  --- 不发牌，不操作
        self:setStopStatus()
        qf.event:dispatchEvent(ET.EVT_AUTO_SUPPLY_CHIPS_REMIND, {uin=self.uin, chips = paras.chips})
    elseif self.status == UserStatus.USER_STATE_INGAME then
        self:giveCard({noanimation=true})
        if self.uin == paras.next_uin then
            self:addTimer({time=self.desk.player_op_past_time}) --根据时间设置
        end
        self:updateMaxCardInfo()
    elseif self.status == UserStatus.USER_STATE_ALLIN then
        self:allin()
        self:giveCard({noanimation=true})
        self:updateMaxCardInfo()
    elseif self.status == UserStatus.USER_STATE_GIVEUP then
        self:giveCard({noanimation=true,dark = true}) 
        self:updateMaxCardInfo()
        self:setStopStatus()
        self:setStatus(GameUserStatus.STATUS_GIVEUP)
    elseif self.status == UserStatus.USER_STATE_LOSE then
        self:lose(self.rank)
    else
    end
    -- 如果已经摊过牌了 则牌还是要翻开
    if self.desk.reverse_show_cards_order then
        local cards = self.desk._all_user_cards_formation[self.uin]
        if cards then
            self:showCardWithoutAction({card1=cards.card1, card2=cards.card2})
        end
    end
end

function M:getHandCardsValue()
    if self.card1 ~= nil and self.card2 ~= nil then
        return self.card1:getValue(), self.card2:getValue()
    end
end

local MySelf = M
return MySelf