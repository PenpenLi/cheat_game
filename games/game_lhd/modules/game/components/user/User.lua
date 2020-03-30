

local User = class("User",function (paras)
    return paras.node
end)

local Card = import("..cards.Card") 
local Chip = import("..chip.Chip")
local ChipNum = import("..chip.ChipNum")
local ChipUtil = import("..chip.ChipUtil")
local UserDisplay = import(".UserDisplay")
local UserStatusNode = import("..UserStatus")

User.startTag = 300
User.giveCardAnimationTime = 0.2
User.dropCardAnimationTime = 0.6
User.dropCardOpacity = 70

User.maxCardInfoTAG = 558
User.userHeadTag = 1333
User.userHeadWidth = 172
User.overTimeTag = 641
User.headImgTag = 642

User.defaultColor = cc.c3b(251,205,0)--cc.c3b(0,255,96)
User.statusColor = cc.c3b(251,205,0)
User.winWordColor = cc.c3b(255,202,14)
User.nameMaxLen = 12

User.MOVEING_ZORDER = 10

User.TAG = "User"
User.FIVEP = 5
User.NINEP = 9
User.VIP_ACTION_TAG = 4001
User.VIP_ARMATURE_NAME = "vip_armature"
User.breakHideIconTag = 4554
User.hatTag = 9873
function User:ctor ( paras )
    self.desk = Cache.DeskAssemble:getCache()
    self.winSize = cc.Director:getInstance():getWinSize()
    self.selfSize = self:getContentSize()
    self.is_right=paras.is_right

    self.defaultCountTimer = Cache.Config._defaultDelayTime - 3 or 20
    --需要传给UserStatusNode两个节点. 一个用于放置文本，层级在头像上; 一个用于放置背景特效, 层级在头像下. 
    self.name = UserStatusNode.new({txt_node = self:getChildByName("status_text_panel"), effect_node = self:getChildByTag(self.startTag)})

    self.c1 = self:getChildByTag(self.startTag+3)
    self.c2 = self:getChildByTag(self.startTag+4)

    self.c1:setVisible(false)
    self.c2:setVisible(false)
    self.default_hand_card=self:getChildByName("default_hand_card")  --用于解决手牌毛边
    self.default_hand_card:setVisible(false)

    self.is_reverse = false

    self.middlePostion = cc.p(self.winSize.width/2,self.winSize.height*0.7)

    self.status = 0
    self.uin = -1

    self.index = paras.index
    self.total = paras.total

    self:initMoneyLabel()
    self:adjustElements()
    self:initChip()
    if Cache.DeskAssemble:judgeGameType(SNG_MATCHE_TYPE)
        or Cache.DeskAssemble:judgeGameType(MTT_MATCHE_TYPE) then
        self:initTouchSNG()
    else
        self:initTouch()
    end
    self:initHead()
    self:hide()
end

function User:initTouchSNG()
    self:setTouchEnabled(true)
    addButtonEvent(self, function(sender)
        if sender:isVisible() then
            qf.event:dispatchEvent(LHD_ET.GAME_SHOW_USER_INFO,{uin=self.uin})
        end
    end)
end
function User:initTouch ()
    self:setTouchEnabled(true)
    addButtonEvent(self,function ( sender )
        qf.event:dispatchEvent(LHD_ET.GAME_SHOW_USER_INFO,{uin=self.uin})
    end)
end

function User:initChip()
    local directionPoint = {}
    directionPoint[5] = {1,0,0,1,1}
    directionPoint[9] = {1,0,0,0,0,1,1,1,1}
    self.chipDirection = directionPoint[self.total][self.index]
    self._chip = Chip.new({direction = self.chipDirection})
    if self.chipDirection == 0 then
        self._chip:setAnchorPoint(0, 0)
    else
        self._chip:setAnchorPoint(1, 0)
    end

    local cs = self.selfSize
    local pointTable = {}
    pointTable[5] = {{-0.1,0.75},{0,1},{1.2,0.2},{-0.2,0.2},{-0.1,0.75}}
    pointTable[9] = {{-0.2, 0.75},{0,1},{1.2,0.7},{1.25,0.1},{0.35,-0.3},{0.55,-0.3},
        {-0.25, 0.05},{-0.2, 0.7},{-0.2, 0.75}}
    local posx = cs.width * pointTable[self.total][self.index][1]
    local posy = cs.height * pointTable[self.total][self.index][2]
    self._chip:setPosition(posx, posy)
    self._chip:hideContent()
    self:addChild(self._chip,5)
end
-- 创建两张手牌
function User:getDoubleCard( ... )
    local card1 = Card.new()
    local card2 = Card.new()
    return card1, card2
end
-- 给玩家发牌，
--[[
@rev 是否翻牌
@card1  第一张是啥
@card2  第二张是啥
]]
function User:giveCard(paras)
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
        self:default_hand_card_dark()
    end
    

    if paras.noanimation then 
        self.default_hand_card:setVisible(true)
        if card1:isDark() or card2:isDark() then 
            self:default_hand_card_dark()
        else
            self:default_hand_card_light()
        end
        card1:setVisible(false)
        card2:setVisible(false)
        return
    end

    self.card1.exg = {rev=rev,card=paras.card1}     -- 绑定一些信息
    self.card2.exg = {rev=rev,card=paras.card2}
    self:_giveCardAnimation(1,card1,self.c1:getScale(),self.c1:getRotation(),0.06,paras.st - 0.05,self.c1p[1],self.c1p[2])
    self:_giveCardAnimation(2,card2,self.c2:getScale(),self.c2:getRotation(),paras.st + 0.03,0,self.c2p[1],self.c2p[2])
end
-- 发完牌后回调
function User:whenGivedCard( sender, value )
    sender:setLocalZOrder(3)
    sender.value = value
end

function User:_giveCardAnimation(status,card,scale,rotate,delay,delay2,x,y)
    local dpoint = self:convertToNodeSpace(self.middlePostion)
    local value = self.desk.play_info.cards[status]
    
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
        ),
        cc.CallFunc:create(function( sender )
                if  card:isVisible() then 
                    self.default_hand_card:setVisible(true)
                else
                    self.default_hand_card:setVisible(false)
                end
                if card:isDark() then 
                    self:default_hand_card_dark()
                else
                    self:default_hand_card_light()
                end
                card:setVisible(false)
            end)
        ))
end

function User:resetNameString()
    if self.lockStatus then return end --亮牌中不允许重新设置名字
    local u = self.desk._user[self.uin]
    if u == nil then return end
    local status =u["status"]
    if status == nil then return end
    if status ~= UserStatus.USER_STATE_ALLIN and status ~= UserStatus.USER_STATE_GIVEUP then
        self:setNameString()
    end
end

function User:setNameString(nick)
    if self.lockStatus then return end--用户弃牌后，亮牌需要一直保持到最后
    if self.name == nil then return end
    self.nick=nick or self.nick
    local remark_name= Util:getFriendRemark(self.uin,self.nick)
    local isVip = self.desk:judgeIsVip(self.uin)
    self.name:update({type = "nick",nick = remark_name, beauty = false, vip = isVip})
end

function User:setStatus(status)
    if self.lockStatus then return end--用户弃牌后，亮牌需要一直保持到最后
    self.name:update({type = "other",status = status, beauty = false, rank=self.rank})    
end

function User:adjustElements()
    self.c1:setScale(0.44)
    self.c2:setScale(0.44)
    self.c1p = {self.c1:getPositionX()+5 ,self.c1:getPositionY() - 20}
    self.c2p = {self.c2:getPositionX() ,self.c2:getPositionY() - 20}
    if self.is_right==true then 
        self.c1p = {self.c1:getPositionX()+9 ,self.c1:getPositionY() - 20}  
    end
end

function User:clearCard ()
    self:removeChildByTag(self.startTag + 11) 
    self:removeChildByTag(self.startTag + 12)
    self.card1 = nil
    self.card2 = nil
    self.default_hand_card:setVisible(false)
end

function User:cloneCardStatus (paras) 
    local rc = paras.card
    local oc = self["c"..paras.status]
    rc:setScale(oc:getScale())
    rc:setRotation(oc:getRotation())
    --rc:setPosition(oc:getPosition())

    rc:setTag(self.startTag + 10 + paras.status)
    local ZOder = 3--(self.index<=(math.ceil(self.total/2)) and 4-paras.status or paras.status+1)
    ZOder = self.index==1 and paras.status+1 or ZOder
    self:addChild(rc,ZOder)
    return rc
end

--还原牌的状态
function User:cardsReduction()
    if self.card1 == nil or self.card2 == nil then return end
    for i = 1 , 2 do
        local oc = self["c"..i]
        local rc = self["card"..i]
        rc:setScale(oc:getScale())
        rc:setRotation(oc:getRotation())
    end
end

--修复玩家手牌。对玩家没有手牌问题进行容错处理。只有当找不到自己的手牌数据时，才重新拉取牌桌数据
function User:repairCards()
    if self.card1 == nil or tolua.isnull(self.card1) 
        or self.card2 == nil or tolua.isnull(self.card2) then
        -- 没有手牌，重新创建手牌
        self:giveCard({noanimation=true})
    end
    return true
end

-- 添加倒计时的时候，发送消息给 控制器,然后来改变按钮状态
function User:addTimer (paras)
    if self._timer then return end
    self:removeTimer()
    --self:overTimerStart({time = self.defaultCountTimer+5})
    paras = paras or {}
    local costTime = paras.time or 0
    local percent = 100*(self.defaultCountTimer - costTime)/self.defaultCountTimer
    
    self:setStatus(GameUserStatus.STATUS_THINKING)
    local timer = cc.ProgressTimer:create(cc.Sprite:create(GameRes.res001))
    timer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    timer:setReverseDirection(true)
    timer:setPercentage(percent)
    timer:setPosition(self.selfSize.width/2,self.selfSize.height/2)
    timer:setTag(self.startTag+2)

    self:addChild(timer,1)

    self._timev    = self.defaultCountTimer - costTime 
    self._preTimev = self.defaultCountTimer - costTime - 1 
    self._timer = timer
    self._timer:setColor(self:getGradualValue())

    self:scheduleUpdateWithPriorityLua(handler(self,self._timeCounterInFrames),0)

    --如果头像倒计时了，那么必然需要更新自己的按钮了
    qf.event:dispatchEvent(ET.GAME_CHANGE_BUTTON_STATUS,{uin=self.uin})
end 

function User:getGradualValue()
    local r1 = (self.defaultCountTimer - self._timev)/self.defaultCountTimer
    local r = 0 local g = 0 local b = 0
    if r1 < 0.5 then g = 255 r = 2*r1*255 end
    if r1 > 0.5 then g = (1-r1)*2*255 r =255 end
    return cc.c3b(r,g,b)
end

function User:_timeCounterInFrames(dt)
    self._timev = self._timev - dt
    if self._timer == nil then self:removeTimer() return end
    self._timer:setColor(self:getGradualValue())
    self._timer:setPercentage(self._timev*100/self.defaultCountTimer)
    if self._timev < self._preTimev then 
        self:timeCounter(self._preTimev)
        self._preTimev = self._preTimev - 1
    end

    if self._timev < 0.000001 then
        self:removeTimer({timeover = true})
    end
end

function User:removeTimer (paras)
    -- logd("移除倒计时"..self.uin,self.TAG)
    if paras == nil or paras.overtime == false then self:stopOverTimer() end
    self:unscheduleUpdate()
    self:removeChildByTag(self.startTag+2)
    self._timer = nil
end

function User:existTimer()
    return self:getChildByTag(self.startTag+2) ~= nil
end

-- 弃牌 , 去掉牌， 去掉最大牌信息
function User:dropCard( noaction ) 
    self:setStatus(GameUserStatus.STATUS_GIVEUP)
    self:setStopStatus()
    self:setMaxCardInfoDark()
    self.default_hand_card:setVisible(false)               
    local dpoint = self:convertToNodeSpace(self.middlePostion)
    for i = 1, 2 do
        if self["card"..i] then
            self["card"..i]:setVisible(true)
            self["card"..i]:runAction(cc.Sequence:create(
                cc.Spawn:create(
                    cc.MoveTo:create(self.dropCardAnimationTime,dpoint),
                    cc.ScaleTo:create(self.dropCardAnimationTime,0)
                ),
                cc.CallFunc:create(function (sender)
                      self["card"..i]:dark()
                      self["card"..i]:setScale(1)
                      self["card"..i]:setVisible(false)
                      self.default_hand_card:setVisible(false)
                end)))
        end
    end
    
    self:removeTimer()
end

--输掉SNG比赛. 
function User:lose(rank)
    self.rank = rank
    self:setNameString()
    self:setStatus(GameUserStatus.STATUS_LOSE)
    self:setStopStatus()
    self:removeMaxCardInfo()
end

-- 更新信息，包括金币 ，人物信息等等 , 仅用于进牌桌时
--
-- paras 用户缓存的信息
--[[
USER_STATE_NORMAL = 1000  # 不存在
USER_STATE_STAND = 1010  # 旁观中
USER_STATE_STAND_WAIT = 1015  # 站着等
USER_STATE_READY = 1020  # 坐下，如果已经开局，那么是不能操作的
USER_STATE_INGAME = 1030  # 玩游戏中
USER_STATE_ALLIN = 1040  # 已经全部ALLIN了，之后的跟注不用管他了
USER_STATE_GIVEUP = 1050  # 弃牌
USER_STATE_LOSE_IN_CHALLENGE = 1060  # 比牌输了--金花专用
]]
function User:update(paras)
    local status = paras.status
    local next_uin = self.desk.next_uin
    local myuin = Cache.user.uin
    local uin = paras.uin
    self.be_anti= paras.be_anti
    self.uin = paras.uin
    self.sex = paras.sex
    self.nick = Util:showUserName(paras.nick)
    self.seatid = paras.seatid
    -- self.portrait = paras.portrait	--头像
    self.hiding = paras.hiding	--隐身状态
    if Cache.DeskAssemble:judgeGameType(SNG_MATCHE_TYPE)
     or Cache.DeskAssemble:judgeGameType(MTT_MATCHE_TYPE) then
        self.hiding = 0
    end
    self.rank = paras.rank    --比赛场排名

    self:stopVipStandupAnimation()  --先停止vip动画,解决站起动画播放时时有人坐下出现的bug
    -- self:adjustElements()
    self:show()
    self:updateHead(paras.portrait)
    self:setNameString()
    self:updateMoneyLable(paras.chips)

    if paras.round_chips ~= nil and paras.round_chips > 0 then 
        self._chip:updateTo({number=paras.round_chips,beauty = false})   --round_chips应该直接设置，不应该累加
        self._chip:showContent()
    end

    paras.next_uin = next_uin
    self:updateWithStatus(paras)
    if self.be_anti then 
        self:updateBreakHideIcon(true)
    else
        self:clearBreakHideIcon()
    end
end
-- 根据状态进行改变
function User:updateWithStatus( paras )
    self.default_hand_card:setVisible(false)
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
    elseif self.status == UserStatus.USER_STATE_ALLIN then
        self:allin()
        self:giveCard({noanimation=true})
    elseif self.status == UserStatus.USER_STATE_GIVEUP then
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
function User:updateBreakHideIcon(isVisible,hiding)
    if isVisible then 
        logd("updateBreakHideIcon true")
        self.be_anti=true
        self.hiding=0
        if self:getChildByTag(self.breakHideIconTag) then 
            self:getChildByTag(self.breakHideIconTag):removeFromParent(true)
        end
        local img = GameRes.break_hide_card_using_icon_ingame
        local icon = cc.Sprite:create(img)
        icon:setAnchorPoint(0.0,1.0)
        icon:setPosition(cc.p(-30, 276+8))
        icon:setTag(self.breakHideIconTag)
        self:addChild(icon,2)
    else
         logd("updateBreakHideIcon false")
         self.be_anti=false
         self.hiding=1
         if hiding then self.hiding=hiding end
         self:clearBreakHideIcon()
    end
end
function User:clearBreakHideIcon()
    if self:getChildByTag(self.breakHideIconTag) then 
        self:getChildByTag(self.breakHideIconTag):removeFromParent(true)
    end
end

function User:updateHead(url)
    if url==self.portrait and self.portrait~=nil then  return  end
    self.portrait=url or self.portrait
	Util:updateUserHead(self._headImg, self.portrait, self.sex, {scale=self.userHeadWidth, url=true})
end

function User:initHead()
    local p = cc.Sprite:create(GameRes.user_default1)
    p:setScale(self.userHeadWidth/p:getContentSize().width)
    local cs = self.selfSize
    p:setPosition(cs.width/2,cs.height/2)
    self:addChild(p, 1)
    self._headImg = p
end

function User:setStopStatus()
    self:setOpacity(self.dropCardOpacity)
    self.name:setOpacity(self.dropCardOpacity)
    self.money:setOpacity(self.dropCardOpacity)
    self.money:setLocalZOrder(0)
    self:getChildByName("head_img"):setOpacity(self.dropCardOpacity)
    self._headImg.opacity = 0
    self._headImg.type = self._headImg.type or 0
    if self._headImg.type == nil or self._headImg.type == 0 then
        self._headImg:setOpacity(self.dropCardOpacity)
    end
    if self._headImg then
        self._headImg:setOpacity(self.dropCardOpacity)
    end
    self:setCascadeOpacityEnabled(false)  -- 透明状态，如果不关闭，则新出现的聊天框也会变成半透明
    self:setMaxCardInfoDark()
end

function User:setNormalStatus()
    self.lockStatus = false
    self._headImg.opacity = 1
    self:setOpacity(255)
    self.name:setOpacity(255)
    self.money:setOpacity(255)
    self.money:setLocalZOrder(3)
    self:getChildByName("head_img"):setOpacity(255)
    self._headImg.type = self._headImg.type or 0
    if self._headImg.type == nil or self._headImg.type == 0 then
        self._headImg:setOpacity(255)
    end
    if self._headImg then
        self._headImg:setOpacity(255)
    end
    self:setCascadeOpacityEnabled(true)
end

-- 去掉胜利状态
function User:dropWin()
    self:removeChildByTag(555)
    self:removeChildByTag(556)
    self:removeChildByTag(557)
end

function User:ready()
    self:setNormalStatus()
    self._chip:hideContent()
    self:clearCard()
    self:updateBaseInfo()
    self:removeTimer()
    self:dropWin()

    -- VIP用户进入有进入动画，会把头像隐藏，如果动画还没完成就收到游戏开始消息，则头像会消失
    -- 此处手动把头像可见
    self._headImg:setVisible(true)
    self:stopAllActions()

    self:removeShowCard()
    self:hideCardType()
    -- self:removeMaxCardInfo()
end

-- 0 跟注 1 加注 2 allin 3看牌
function User:updateBaseInfo(paras)
    local m = self.desk:getUserByUin(self.uin)
    if m == nil then return end

    local status = nil
    paras = paras or {}
    if paras.bet_type == 0 then     status = GameUserStatus.STATUS_FOLLOW
    elseif paras.bet_type == 1 then status = GameUserStatus.STATUS_ADD
    elseif paras.bet_type == 2 then status = GameUserStatus.STATUS_ALLIN
    elseif paras.bet_type == 3 then status = GameUserStatus.STATUS_LOOK
    end 
    
    if status ~= nil then 
        self:setStatus(status)
    else
        self:setNameString()
    end

    self:updateMoneyLable(m.chips)
end

function User:initMoneyLabel()
    local money = self:getChildByTag(self.startTag+1)
    money:setVisible(false)

    self.money = ChipNum.new({num=0})
    self:addChild(self.money,3)
    self.money:setAnchorPoint(0.5, 0)
    self.money:setPosition(self.selfSize.width/2, 10)
end

function User:updateMoneyLable(chips)
    if self.money == nil then return  end
    self.money:setColor(self.statusColor)
    --个人筹码小于1亿大于100万时，精度为小数点后1位;其他时候为小数点后2位
    local precision = (chips > 1000000 and chips < 100000000) and 1 or 2
    --self.money:setString(chips, precision)
    self.money:setString(Util:getFormatString(chips))
end

function User:collectBet ()
    local userBet = self._chip.number
    if userBet == 0 then return nil,nil end
    local node = ChipUtil:getHeap(userBet)
    local wp = self:convertToWorldSpace(cc.p(self:getChipHeapPos()))
    node:setPosition(wp)
    return node, userBet
end

function User:gameStartInitChip(paras)
    self._chip:updateTo({number = paras.number, beauty = false})
end
-- 无动作的亮牌
function User:showCardWithoutAction( paras )
    if paras == nil or paras.card1 == nil or paras.card2 == nil then return end

    local card1, card2 = self.card1, self.card2
    -- 如果没有牌就不执行
    if not card1 or not card2 then return end

    local cs = self.selfSize
    
    card1:setVisible(true)
    card2:setVisible(true)
    self.default_hand_card:setVisible(false)
    
    local ca1 = card1:getAnchorPoint()
    local ca2 = card2:getAnchorPoint()

    local function _reverseCard( target, dot, px, py )
        target:setPosition(cc.p(px, py))
        target:setScale(0.95)
        target:setRotation(0)
        target:reverseSelfNoAction(nil, dot)
    end
    _reverseCard(card1, paras.card1, cs.width*0.4*ca1.x/0.5-2, cs.height*0.44*ca1.y/0.5)
    _reverseCard(card2, paras.card2, cs.width*0.8*ca2.x/0.5+2, cs.height*0.44*ca2.y/0.5)

    self.is_reverse = true
end
function User:showCard( paras )
    if paras == nil or paras.card1 == nil or paras.card2 == nil then return end
    
    local card1, card2 = self.card1, self.card2
    -- 如果没有牌就不执行
    if not card1 or not card2 then return end
    
    local cs = self.selfSize
    
    card1:setVisible(true)
    card2:setVisible(true)
    self.default_hand_card:setVisible(false)
    
    local ca1 = card1:getAnchorPoint()
    local ca2 = card2:getAnchorPoint()

    local function createSpawn( dt, px, py )
        return cc.Spawn:create(cc.MoveTo:create(dt, cc.p(px, py))
            , cc.RotateTo:create(0.3, 0)
            , cc.ScaleTo:create(0.3, 0.95))
    end
    if not self.is_reverse then
        local spawn1 = createSpawn(0.3, cs.width*0.4*ca1.x/0.5-2, cs.height*0.44*ca1.y/0.5)
        local spawn2 = createSpawn(0.3, cs.width*0.8*ca2.x/0.5+2, cs.height*0.44*ca2.y/0.5)
        card1:reverseSelf(nil, paras.card1, spawn1)
        card2:reverseSelf(nil, paras.card2, spawn2)
    end
    self.is_reverse = true

    if paras.nodark ~= true then
        card1:dark()
        card2:dark()
        self:default_hand_card_dark()
        -- 有传亮牌的数据，就用亮牌的，没有传就用原来的
        if paras.max_card_type ~= nil then        
            self:showCardType(paras.max_card_type) 
        else
            local u = self.desk:getUserByUin(self.uin)
            if u ~= nil then self:showCardType(u.max_cards_formation) end
        end
    end
end

function User:lightDoubleCard()
    local card1 = self.card1
    local card2 = self.card2
    if card1 then card1:light() self:default_hand_card_light()end
    if card2 then card2:light() self:default_hand_card_light()end
    
end

function User:darkCard() 
    local card1 = self.card1
    local card2 = self.card2
    if card1 then card1:dark() self:default_hand_card_dark() end
    if card2 then card2:dark() self:default_hand_card_dark() end
end

function User:lightCard(paras)
    local card1 = self.card1
    local card2 = self.card2
    if card1 and card1.value == paras.value then 
        card1:light() 
        self:default_hand_card_light()
     end
    if card2 and card2.value == paras.value then 
        card2:light()
        self:default_hand_card_light() 
    end

end

function User:removeShowCard () 
    self:removeChildByTag(self.startTag + 11) 
    self:removeChildByTag(self.startTag + 12)
    self.default_hand_card:setVisible(false)
end

function User:mustSpendBet(paras)
    if paras == nil or paras.chips == nil or paras.chips == 0 then 
        logd(" zero bet , no action " , self.TAG)
        return
    end
    MusicPlayer:playMyEffect("CHIP_FLY")
    local heapTable,realNumber = ChipUtil:getHeapTable(paras.chips)
    local cs = self.selfSize

    self._chip:update({number=paras.chips-realNumber,beauty = false})
    local startPos = cc.p(cs.width/2, cs.height/3)
    local endPos = cc.p(self:getChipHeapPos())
    for k,v in pairs(heapTable) do
        self:addChild(v, 10)
        v.k = k
        ChipUtil:moveChipToPos(v, startPos, endPos, function( sender )
            if sender.k == 1 then 
                self._chip:showContent()
            end
            self._chip:update({number=sender.value,beauty = false})
            sender:removeFromParent(true)
        end, {delay = k*0.05, moveDelay = 0.3})
    end
end

function User:bet(paras)
    self:removeTimer()

    self:updateBaseInfo({bet_type=paras.bet_type})
    self:updateMoneyLable(paras.chips)
    
    if paras.bet_chips == 0 then 
        logd(" zero bet , no action " , self.TAG)
        return
    end
    
    MusicPlayer:playMyEffect("CHIP_FLY")
    local heapTable,realNumber = ChipUtil:getHeapTable(paras.bet_chips)
    local cs = self.selfSize

    self._chip:update({number=paras.bet_chips-realNumber,beauty = false}) 

    local startPos = cc.p(cs.width/2, cs.height/3)
    local endPos = cc.p(self:getChipHeapPos())
    for k,v in pairs(heapTable) do
        self:addChild(v, 10)
        v.k = k
        ChipUtil:moveChipToPos(v, startPos, endPos, function( sender )
            if sender.k == 1 then 
                self._chip:showContent()
            end
            self._chip:update({number=sender.value,beauty = false})
            sender:removeFromParent(true)
        end, {delay = k*0.05, moveDelay = 0.3})
    end
end

function User:showJifen()
    logd("积分")
    if self.desk.jifen == nil or self.uin ~= Cache.user.uin then return end
    local num = cc.LabelAtlas:_create(self.desk.jifen,GameRes.jifen_num_img, 32, 36, string.byte('0'))
    local l = cc.Sprite:create(GameRes.jifen_word_img)
    local height = self.selfSize.height
    local x,y = self.selfSize.width - 10 + l:getContentSize().width,height*0.4
    num:setPosition(x,y)
    l:setPosition(x,y)
    
    self.desk.jifen = nil
    l:setAnchorPoint(1,0.5)
    num:setAnchorPoint(0,0.5)
    
    self:_jifenAction(l)
    self:_jifenAction(num)
end
-- 显示积分
function User:_jifenAction(l)
    if not l then return end
    self:addChild(l, 10)
    -- UserDisplay:getJiFenAction(l, {offsetY = self.selfSize.height*0.5})
end
-- win文本动画
function User:showWinWord(paras)
    if not paras then return end
    local txt = "."..paras
    local l = cc.LabelAtlas:_create(txt, GameRes.game_win_font, 43, 63, string.byte('.'))
    l:setColor(self.winWordColor)
    l:setPosition(self.selfSize.width/2, self.selfSize.height*0.25)
    self:addChild(l, 10)

    local pos
    if (5 == self.index or 6 == self.index) and 9 == self.total then
        pos = cc.p(0, self.selfSize.height*0.42)
    else
        pos = cc.p(0, self.selfSize.height*0.75)
    end
    return UserDisplay:getWinWordAction({label=l, pos = pos})
end

--[[--
]]
function User:showVictory(paras)

    if not self:isVisible() then return end
    if self.uin == Cache.user.uin then 
        MusicPlayer:playMyEffect("GAME_WIN") 
    end

    local cs = self.selfSize
    local frames = {}
    local ani = cc.Animation:create()
    for i=1, 6 do
        ani:addSpriteFrameWithFile(string.format(GameRes.effect_win, i))
    end
    ani:setDelayPerUnit(0.15)

    self.sprWinEffect = cc.Sprite:create(string.format(GameRes.effect_win, 1))
    self.sprWinEffect:setPosition(cs.width/2,cs.height/2+30)
    self:addChild(self.sprWinEffect, 5)
    self.sprWinEffect:runAction(cc.RepeatForever:create( cc.Animate:create(ani) ))

    self.sprNewRedBg = cc.Sprite:create(GameRes.img_user_red_bg)
    self.sprNewRedBg:setPosition(cs.width/2,cs.height/2)
    self:addChild(self.sprNewRedBg)
    self.sprNewFrame = cc.Sprite:create(GameRes.game_win_anim_bk_all)
    self.sprNewFrame:setPosition(cs.width/2,cs.height/2)
    self:addChild(self.sprNewFrame)

    local pop = cc.Sprite:create(GameRes.pop_win)
    pop:setPosition(cs.width/2, 95)
    pop:setScale(0.5)
    pop:setOpacity(100)
    self:addChild(pop, 5)

    --弹出收缩动作
    local popAction = UserDisplay:getVictoryPopAction(function( sender )
        if self.sprWinEffect and not tolua.isnull(self.sprWinEffect) then
            self:removeChild(self.sprWinEffect)
            self.sprWinEffect = nil 
        end
        self:removeChild(sender)
        if self.sprNewRedBg and not tolua.isnull(self.sprNewRedBg) then
            self.sprNewRedBg:runAction(cc.Sequence:create(cc.DelayTime:create(1.0)
                ,cc.CallFunc:create(function()
                    self:removeChild(self.sprNewRedBg)
                    self:removeChild(self.sprNewFrame)
                    self.sprNewRedBg = nil 
                    self.sprNewFrame = nil 
                end)))
        end
    end)
    pop:runAction(popAction)

    -- 高亮牌
    if paras.max_cards ~= nil then 
        for k,v in pairs(paras.max_cards) do
            self:lightCard({value=v})
        end
    end
    --飞数字 
end

function User:_addWinAnimation () 
    local bg = cc.Sprite:create(GameRes.game_winner_bg)--金色字母
    local w = cc.Sprite:create(GameRes.game_result_winner)
    local light = cc.Sprite:create(GameRes.game_result_light)
    local cs = self.selfSize
    light:setAnchorPoint(0.5,0)
    light:setPosition(cs.width*0.5,cs.height*0.2)
    self:addChild(light,0)
    w:setAnchorPoint(0.5,0)
    w:setPosition(bg:getContentSize().width*0.5,0)
    bg:addChild(w)
    bg:setAnchorPoint(0.5,0)
    bg:setPosition(cs.width*0.5,cs.height*0.2)
    bg:setScale(0)
    light:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.EaseSineIn:create(cc.ScaleTo:create(1,0.5)),
        cc.EaseSineOut:create(cc.ScaleTo:create(1,1))
    )))
    bg:runAction(cc.Sequence:create(
        cc.EaseSineOut:create(cc.ScaleTo:create(0.5,1.1)),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.4,0.9)),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.3,1))
    ))
    light:setTag(557)
    bg:setTag(556)
    self:addChild(bg,11)
end

-- 播放粒子效果
function User:showVictoryPartical(chip_num)
    local cs = self.selfSize
    local emitter = ChipUtil:getVictoryPartical(chip_num)
    emitter:setPosition(cc.p(cs.width*0.5,cs.height*0.7))
    self:addChild(emitter, 4) --4是中间那张牌的层级
end

function User:_addstarAnimation (paras)
    local star = cc.Sprite:create(GameRes.game_result_star)
    local x = paras.x or 0
    local y = paras.y or 0
    local t = paras.t or 0
    local dtime = 2.5  ---2->3
    self:addChild(star,10)
    star:setPosition(x,y)
    star:setScale(0.2)
    star:setOpacity(0)
    star:runAction(cc.Sequence:create(
        cc.DelayTime:create(t),
        cc.Spawn:create(
            cc.RotateBy:create(dtime,360),
            cc.Sequence:create(cc.FadeTo:create(dtime/2,255),cc.FadeTo:create(dtime/2,50)),
            cc.Sequence:create(cc.ScaleTo:create(dtime/2,1.1),cc.ScaleTo:create(dtime/2,0.2))
            ),
            cc.CallFunc:create(function( sender ) 
                sender:removeFromParent(true)
            end)
        ))
end

function User:getChipHeapPos()
    local x, y = self._chip:getPosition()
    local size = self._chip:getRealContentSize()
    local chip_x, chip_y = self._chip:getHeapTopCenter()    --顶部筹码在筹码堆中的内部坐标
    if self.chipDirection == 0 then
        return x + chip_x, y + chip_y
    else
        return x - size.width + chip_x, y + chip_y
    end
end

function User:allin()
    self:setStatus(GameUserStatus.STATUS_ALLIN)
end

function User:hide()
    -- 隐藏的时候把头像置为空
    self.portrait = nil
    self:ready()

    if self.sprNewRedBg and not tolua.isnull(self.sprNewRedBg) then
        self.sprNewRedBg:removeFromParent()
        self.sprNewRedBg = nil 
    end
    if self.sprNewFrame and not tolua.isnull(self.sprNewFrame) then
        self.sprNewFrame:removeFromParent()
        self.sprNewFrame = nil 
    end 
    if self.sprWinEffect and not tolua.isnull(self.sprWinEffect) then
        self.sprWinEffect:removeFromParent()
        self.sprWinEffect = nil 
    end

    self:setVisible(false)
end

function User:setAllChildVisible(visible)
    self.name:setVisible(visible)
    self.money:setVisible(visible)
    self:getChildByName("head_img"):setVisible(visible)
    if self._headImg then
        self._headImg:setVisible(visible)
    end
    self:getChildByTag(self.startTag):setVisible(visible)
end

function User:show()
    if self.sprNewRedBg and not tolua.isnull(self.sprNewRedBg) then
        self.sprNewRedBg:removeFromParent()
        self.sprNewRedBg = nil 
    end
    if self.sprNewFrame and not tolua.isnull(self.sprNewFrame) then
        self.sprNewFrame:removeFromParent()
        self.sprNewFrame = nil 
    end 
    if self.sprWinEffect and not tolua.isnull(self.sprWinEffect) then
        self.sprWinEffect:removeFromParent()
        self.sprWinEffect = nil 
    end

    self:setAllChildVisible(true)
    self:setVisible(true)
end

function User:stopOverTimer()
    if self:getActionByTag(self.overTimeTag) then
        self:stopActionByTag(self.overTimeTag)
    end
end

function User:overTimerStart(paras)
    if paras == nil then return end
    local time = paras.time == nil and 25 or paras.time
    self:stopOverTimer()
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function() 
            GameNet:disconnect() 
            end)
    )
    action:setTag(self.overTimeTag)
    self:runAction(action)
end

function User:showCardType(type)
    if type == nil or GameTxt.string008[type+1] == nil then return end
    self:hideCardType()
    self.cardType = cc.Sprite:create(GameRes.game_card_type_bg)
    self.cardType:setAnchorPoint(0.5,0)
    self.cardType:setPosition(self.selfSize.width*0.5,0)
    self:addChild(self.cardType,5)
    local txt = cc.LabelTTF:create(GameTxt.string008[type+1], GameRes.font1, 40)
    txt:setColor(cc.c3b(12,255,0))
    txt:setAnchorPoint(0.5,0)
    txt:setPosition(self.cardType:getContentSize().width*0.5,self.cardType:getContentSize().height*0.2)
    self.cardType:addChild(txt)
end

function User:hideCardType()
    if self.cardType ~= nil then self.cardType:removeFromParent(true)  self.cardType = nil end
end

function User:showMyCard(paras)--亮牌
    self:setNormalStatus()
    
    if not self.card1 or not self.card2 then
        local card1 = Card.new()
        local card2 = Card.new()
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

--更新用户昵称和头像
function User:updateNickAndPortrait(hiding, nick, portrait)
	self.hiding = hiding
    if Cache.DeskAssemble:judgeGameType(SNG_MATCHE_TYPE)
     or Cache.DeskAssemble:judgeGameType(MTT_MATCHE_TYPE) then
        self.hiding = 0
    end
    local user= Cache.DeskAssemble:getCache():getUserByUin(self.uin)
    if self.hiding==1 and  user and user.be_anti then  return  end --如果是在隐身状态 并且被破隐则不更新 数据
	self.nick = Util:showUserName(nick)
	--self.portrait = portrait
	if self.name:isNick() == true then	--当前显示昵称才更新，否则仍然显示状态
		self:setNameString()
	end
	self:updateHead(portrait)
end

function User:default_hand_card_dark() 
    self.default_hand_card:setColor(Theme.Color.DARK)
end

function User:default_hand_card_light() 
    self.default_hand_card:setColor(Theme.Color.LIGHT)
end

function User:getChipValue()
    if (not self:isVisible()) or tolua.isnull(self._chip) or (not self._chip:isVisible()) then
        return 0
    else
        return self._chip:getValue()        
    end
end
----------------------------------
-- MySelf实现的方法

function User:updateMaxCardInfo()
end
function User:removeMaxCardInfo()
end
function User:setMaxCardInfoDark()
end
-- 倒计时回调
function User:timeCounter(index)
end
function User:cardShock(time)
end
function User:stopCardShock()
end
function User:getHandCardsValue()
end

-- end
----------------------------------

return User