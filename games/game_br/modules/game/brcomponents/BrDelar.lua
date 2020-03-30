local BrDelar = class("BrDelar",function(paras) 
    return paras.node
end)
local Gift = import("..components.Gift")
local Card = import("..components.cards.Card")  
local IButton = import("..components.IButton")  

BrDelar.TAG = "BrDelar"

function BrDelar:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end

function BrDelar:init()
    self:clearAll()
    self:initTouch()
    self:initCards()
    self:getChildByName("delar_head"):setVisible(false)
    -- self:getChildByName("btn_gift"):setVisible(false)
    self:getChildByName("img_beauty"):setVisible(false)
    self:getChildByName("card_type"):setVisible(false)
    self:leave()
end

function BrDelar:initTouch()
    addButtonEvent(self:getChildByName("bnt_tobe_delar"),function()
        -- 申请上庄
        -- qf.event:dispatchEvent(ET.BR_DELARLIST_SHOW,{isExit = self.uin == Cache.user.uin})
        local isExit = self.uin == Cache.user.uin
        if isExit == true then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=BrTXT.br_delarlist_exit_tip})
            qf.event:dispatchEvent(BR_ET.BR_DELAR_EXIT_REQ)
        else
            qf.event:dispatchEvent(BR_ET.BR_DELARLIST_SHOW, {isExit = isExit})
        end
    end)
    addButtonEvent(self:getChildByName("user_bg"),function()
        if self.uin == nil then return end
        local defaultImg
        if Util:checkSysZhuangUin(self.uin) then
            defaultImg = GameRes.defaultZhuangCircleImg
        end

        qf.event:dispatchEvent(ET.GAME_SHOW_USER_INFO,{uin=self.uin, defaultImg = defaultImg,showGoldTxt = self.delar_chip:getString()})
    end)
    -- self:getChildByName("btn_gift"):setVisible(false)
    -- addButtonEvent(self:getChildByName("btn_gift"),function ( sender )
        -- local type 
        -- if ModuleManager:judegeIsIngame() then
        --     type = self.uin == Cache.user.uin and 3 or 4
        -- end
        -- qf.event:dispatchEvent(ET.SHOW_GIFT,{name="gift",from=self.TAG, type = type, uin = self.uin , gifts = self.gifts })
    -- end)
    self:getChildByName("bnt_tobe_delar"):getChildByName("title"):setVisible(false)
end


function BrDelar:clearAll()
    local nameT = {"delar_name", "delar_chip", "delar_name", "user_bg"
        , "img_beauty", "delar_head", "img_vip"}
    for k, v in pairs(nameT) do
        self[v] = self:getChildByName(v)
    end

    self.delar_head:setPosition(cc.p(508, 176))
    self.delar_name:setPosition(cc.p(508, 263))
    self.delar_chip:setPosition(cc.p(508, 87))
    self.user_bg:setPosition(cc.p(508, 176))

end

function BrDelar:seatDown()
    self.onBody = false
    local delar = Cache.brdesk.br_delar
    if delar == nil then return end
    self.isSeat = true
    self.uin = delar.uin
    self.sex = delar.sex
    self.nick = delar.nick
    self.chips = delar.chips
    self.is_vip = (delar.vip_days > 0) and true or false
    self.portrait = delar.portrait
    self:setNick(self.nick)
    self:setGold(self.chips)
    self:initHead()
    self:updateHead()
    self.delar_name:setVisible(true)
    self.delar_chip:setVisible(true)
    self.user_bg:setVisible(true)
    self.delar_head:setVisible(true)
    self.img_vip:setVisible(self.is_vip)
    -- self:getChildByName("btn_gift"):setVisible(false) --庄家送礼的按钮屏蔽
    self:updataGiftBtn(delar.decoration)
    if self.uin == Cache.user.uin then 
        -- 庄家列表
        self:getChildByName("bnt_tobe_delar"):loadTextureNormal(BrRes.br_game_btn_not_want_be_delar)
    end
    if delar.beauty then
        self.img_beauty:setVisible(true)
        self.user_bg:loadTexture(BrRes.br_game_vip_bg)
    end
end

function BrDelar:updateDelarRuler()
    local str = Util:getOldFormatString(Cache.packetInfo:getProMoney(Cache.brdesk.min_banker)) .. Cache.packetInfo:getShowUnit()
    self:getChildByName("dealer_txt"):setString(string.format(BrTXT.delar_tips, str))
end

function BrDelar:updataGiftBtn(paras)
    -- qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = self:getChildByName("btn_gift") ,icon = paras} )
end

function BrDelar:leave()
    self.onBody = true
    self:setNick(" ")
    self:setGold(" ")
    self.uin = nil
    self.isSeat = false
    self:clearCards()
    self.isSeat = false
    self.delar_name:setVisible(false)
    self.delar_chip:setVisible(false)
    self.user_bg:setVisible(false)
    self.img_vip:setVisible(false)
    self.delar_head:setVisible(false)
    -- self:getChildByName("btn_gift"):setVisible(false)
    self.img_beauty:setVisible(false)
    if self.user_head then
        self.user_head:removeFromParent()
        self.user_head = nil
    end
    self.user_bg:loadTexture(BrRes.br_game_common_bg)
    self.user_bg:removeAllChildren()
    -- 我要上庄
    self:getChildByName("bnt_tobe_delar"):loadTextureNormal(BrRes.br_game_btn_want_be_delar)
end

function BrDelar:updateWaitDelar()
    local allInfo = Cache.brinfo.delars
    if allInfo == nil then return end
    local delarCount = #allInfo-1;
    local bcurrentDelar = false
    for k,v in pairs(allInfo) do
        if v.uin == Cache.brdesk.br_delar.uin then
            bcurrentDelar = true
        end
    end
    if bcurrentDelar == false then
        delarCount = #allInfo
    end
    if delarCount < 0 then 
        delarCount = 0;
    end
    self:getChildByName("dealer_wait_txt"):setString(string.format(BrTXT.delarWait, delarCount))
end


function BrDelar:setNick(nick)
    nick = self.onBody == true and " " or nick
    local txt = self:getChildByName("delar_name")
    local remark_name= Util:getFriendRemark(self.uin,nick)
    txt:setString(remark_name or " ")
    -- txt:setAnchorPoint(0,0.5)
    -- txt:setPosition(cc.p(self:getContentSize().width*0.425,self:getContentSize().height*0.84))
end
function BrDelar:setGold(gold)
    if checkint(self.uin) >= 1000 and checkint(self.uin) <= 1010 then
        self.delar_chip:setString(BrTXT.system_dealer)
        return
    end
    gold = self.onBody == true and " " or gold
    if self.delar_chip == nil then
        local head = self:getChildByName("delar_head")
        self.delar_chip = cc.LabelTTF:create(" ", GameRes.font1, 35)
        self.delar_chip:setAnchorPoint(0,0.5)
        self.delar_chip:setPosition(head:getPositionX()+head:getContentSize().width*0.5+25,head:getPositionY()-head:getContentSize().height*0.5+30)
        self:addChild(self.delar_chip,2)
        self.delar_chip:setColor(cc.c3b(252,205,0))
    end
    self.delar_chip:setString(Util:getFormatString(Cache.packetInfo:getProMoney(checknumber(gold))))
end

function BrDelar:winMoneyFly(paras)
    local money = tonumber(paras.chips)
    if money == 0 then return end
    local fnt
    local img
    
    if money > 0 then
        fnt  = cc.LabelBMFont:create('+'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_add_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_win_money_back)
    else
        fnt  = cc.LabelBMFont:create('-'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_reduce_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_reduce_money_back)
    end
    self:addChild(fnt)
    self:addChild(img)
    local wx = self.delar_head:getPositionX()
    local wy = self.delar_head:getPositionY()
    local high = wy + 80
    img:setPosition(wx,wy)
    fnt:setPosition(wx,wy)
    img:setScale(0.7)
    fnt:setScale(0.7)

    img:setZOrder(6)
    fnt:setZOrder(6)
    local move  = cc.MoveTo:create(0.25,cc.p(wx,high))
    local delay = cc.DelayTime:create(2)
    local call  = cc.CallFunc:create(function (sender)
        if sender then
            sender:removeFromParent()  
        end
    end)
    local sq   = cc.Sequence:create(move,delay,call)
    img:runAction(sq)
    local move  = cc.MoveTo:create(0.25,cc.p(wx,high))
    local delay = cc.DelayTime:create(2)
    local call  = cc.CallFunc:create(function (sender)
        if sender then
            sender:removeFromParent()  
        end
    end)
    local sq   = cc.Sequence:create(move,delay,call)
    fnt:runAction(sq)
    if money > 0 then
        qf.event:dispatchEvent(BR_ET.BR_WINMONEY,{node=self, idx = 2, uin = self.uin})
    end
end

function BrDelar:initCards()
    for i = 1 , 3 do
        self["c"..i] = self:getChildByName("share_card_"..i)
        self["c"..i]:setVisible(false)
    end
end

function BrDelar:giveCards(delay,cdelay,dpoint)
    delay = delay or 0
    cdelay = cdelay or 0
    self:clearCards()
    self.cards = {}
    for i = 1, 3 do
        local card = Card.new()
        self:addChild(card)
        Util:giveCardsAnimation({delay = (i-1)*cdelay+delay,parent = self,c1 = self["c"..i],z = 2,c2 = card,dpoint = dpoint,first = self.c1})
        self.cards[i] = card
    end
end

function BrDelar:showCards(delay,cdelay,dpoint)
    delay = delay or 0
    cdelay = cdelay or 0
    self:clearCards()
    self.cards = {}
    for i = 1, 3 do
        local card = Card.new()
        self:addChild(card)
        card:setScale(self["c"..i]:getScale())
        card:setLocalZOrder(2)
        card:setPosition(self["c"..i]:getPositionX(),self["c"..i]:getPositionY())
        self.cards[i] = card
    end
end

function BrDelar:reverseCards(delay)
    for i = 1, 4 do
        local card = self.cards[i]
        if card == nil then
            self:delayRun(delay+0.3,function() 
                self:showCardInfo()
            end)
        else
            self:delayRun(delay,function() 
                MusicPlayer:playMyEffect("FAPAI")
                card.value = Cache.brdesk.br_delar.cards[i]
                if not tolua.isnull( card ) then
                   card:reverseSelf(nil,Cache.brdesk.br_delar.cards[i])
                end
            end)
        end

    end 
end

function BrDelar:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function BrDelar:initHead( ... )
    -- self.delar_head:setVisible(false)
    -- local p = cc.Sprite:create(BrRes.br_default_head_icon)
    -- local cs = self:getContentSize()
    -- local posx, posy = self.delar_head:getPosition()
    -- p:setPosition(posx, posy)
    -- self:addChild(p, 2)
    -- self.user_head = p
end
function BrDelar:updateHead()
    local scale = self.delar_head:getContentSize().width
    local extparas = {add=true, circle=false, url=true,sq = true}
    if Util:checkSysZhuangUin(self.uin) then
        extparas.default = GameRes.defaultZhuangImg
    end

    Util:updateUserHead(self.delar_head, self.portrait, self.sex, extparas)
end

function BrDelar:clearCards(bCloudCard)
    --self:getChildByName("card_info"):setVisible(false)
    if self.cards == nil or #self.cards == 0 or (bCloudCard and bCloudCard == true) then return end
    for k, v in pairs(self.cards) do
        v:removeFromParent(true)
    end
    self.cards = {}
end


---下注
function BrDelar:bet()
    local chip = Cache.brdesk.br_delar.chips
    self:setGold(chip)
end

function BrDelar:showCardInfo()
    local txt = self:getChildByName("card_type")
    txt:setVisible(true)
    txt:loadTexture(string.format(BrRes["br_game_card_type_2"], (Cache.brdesk.br_delar.card_type + 1)))
    
--    local txt = self:getChildByName("card_info")
--    txt:setString(GameTxt.string008[])
end

function BrDelar:hideCardInfo()
    self:getChildByName("card_type"):setVisible(false)
end

function BrDelar:getChipsPosition() 
    return cc.p(self:getPositionX()+self.user_bg:getPositionX(),self:getPositionY()+self.user_bg:getPositionY())
end

function BrDelar:ready(bCloudCard)
    self:hideCardInfo()
    self:clearCards(bCloudCard)
end

function BrDelar:receiveGift(paras)  --百人场 现在不支持送礼 这个用来 加好友的动画 所以没有updateGiftBtn

       local user_bg=nil
       if paras.fr_u then 
             user_bg= paras.fr_u:getChildByName("user_bg")
             user_bg=user_bg or paras.fr_u:getChildByName("img_head_bg") --百人场自己的头像位置
       end
      local pox=paras.x
      local posy=paras.y
      if user_bg then 
          pox=paras.x+user_bg:getPositionX()
          posy=paras.y+user_bg:getPositionY()
       end
       local from = self:convertToNodeSpace(cc.p(pox,posy))
       local cs = self:getContentSize()
       local to = cc.p(0+cs.width/2,0+cs.height/2)
       local my_user_bg=self:getChildByName("user_bg")
       if my_user_bg then
         to = cc.p(my_user_bg:getPositionX(),my_user_bg:getPositionY())
       end
       local id =paras.id
       local gift =  Gift.new({from=from,to=to,id=id,from_uin=paras.from_uin,to_uin=paras.to_uin,ask_friend=paras.ask_friend})
       if gift then
           self:addChild(gift)
       end
    --logd("-----接收到礼物，更新挂饰 : "..tostring(paras.decoration).."-------")
   if paras.decoration then self:updateGiftBtn(paras.decoration) end
end
function BrDelar:updateGiftBtn(paras)
    paras.scale = 1.2
    -- qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = self:getChildByName("btn_gift") ,icon = paras} )
end


--聊天相关 begin
function BrDelar:showPopChat(model, del)
    del._chat:showPopChatProtocol(model, self, {chatDel = del})
end

function BrDelar:emoji(index, Emoji_index)
    self:playEmojiAni({anim = Emoji_index[index].animation,index=Emoji_index[index].index,scale=2})
end

--显示表情
function BrDelar:playEmojiAni( paras )
    local head = ccui.Helper:seekWidgetByName(self, "delar_head")
    paras.node = self
    paras.order= 100
    if paras.position  == nil then
        paras.position = cc.p(head:getPositionX(),head:getPositionY())
    end
    local face =  Util:playAnimation(paras)
end

function BrDelar:playShowChatMsg(txt_layer, msg)
	local chatnode = txt_layer:playShowChatMsg(self, self:getChildByName("delar_head"), {
        corner = GameConstants.CORNER.LEFT_DOWN,
        offset = {x = -47, y = -70},
		msg = msg,
		chatname = "delar"
    })
    self.chatnode = node
end

return BrDelar