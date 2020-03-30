local BrnnDelar = class("BrnnDelar",function(paras) 
    return paras.node
end)
local Card = import("..components.cards.Card")  
local IButton = import("..components.IButton")  

BrnnDelar.TAG = "BrnnDelar"

function BrnnDelar:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end

function BrnnDelar:init()
    self:clearAll()
    self:initTouch()
    self:initCards()
    self:getChildByName("delar_head"):setVisible(false)
    self:getChildByName("card_type"):setVisible(false)
    self:leave()
end

function BrnnDelar:initTouch()
    addButtonEvent(self:getChildByName("bnt_tobe_delar"),function()
        -- 申请上庄
        -- qf.event:dispatchEvent(ET.BR_DELARLIST_SHOW,{isExit = self.uin == Cache.user.uin})
        local isExit = self.uin == Cache.user.uin
        if isExit == true then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=BrniuniuTXT.br_delarlist_exit_tip})
            qf.event:dispatchEvent(BRNN_ET.BR_DELAR_EXIT_REQ)
        else
            qf.event:dispatchEvent(BRNN_ET.BR_DELARLIST_SHOW, {isExit = isExit})
        end
    end)
    addButtonEvent(self:getChildByName("user_bg"),function()
        if self.uin == nil then return end
        local defaultImg
        if Util:checkSysZhuangUin(self.uin) then
            defaultImg = GameRes.defaultZhuangCircleImg
        end
        
        qf.event:dispatchEvent(ET.GAME_SHOW_USER_INFO,{uin=self.uin, defaultImg = defaultImg, showGoldTxt = self.delar_chip:getString()})
    end)
end


function BrnnDelar:clearAll()
    local nameT = {"delar_name", "delar_chip", "delar_name", "user_bg"
        , "delar_head", "img_jackpot"}
    for k, v in pairs(nameT) do
        self[v] = self:getChildByName(v)
    end
    self.delar_head:setPosition(cc.p(508, 176))
    self.delar_name:setPosition(cc.p(508, 263))
    self.delar_chip:setPosition(cc.p(508, 87))
    self.user_bg:setPosition(cc.p(508, 176))
end

function BrnnDelar:seatDown()
    self.onBody = false
    local delar = Cache.BrniuniuDesk.br_delar
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
    if self.uin == Cache.user.uin then 
        -- 庄家列表
        self:getChildByName("bnt_tobe_delar"):loadTextureNormal(BrniuniuRes.br_game_btn_not_want_be_delar)
    else
        self:getChildByName("bnt_tobe_delar"):loadTextureNormal(BrniuniuRes.br_game_btn_want_be_delar)
    end
end

function BrnnDelar:updateDelarRuler()
    local str = Util:getOldFormatString( Cache.packetInfo:getProMoney(Cache.BrniuniuDesk.min_banker)) .. Cache.packetInfo:getShowUnit()
    self:getChildByName("dealer_txt"):setString(string.format(BrniuniuTXT.delar_tips, str))
end

function BrnnDelar:leave()
    self.onBody = true
    self.isSeat = false
    self:setNick(" ")
    self:setGold(" ")
    self.uin = nil
    self:clearCards()
    self.delar_name:setVisible(false)
    self.delar_chip:setVisible(false)
    self.user_bg:setVisible(false)
    self.delar_head:setVisible(false)
    if self.user_head then
        self.user_head:removeFromParent()
        self.user_head = nil
    end
    self.user_bg:loadTexture(BrniuniuRes.br_game_common_bg)
    self.user_bg:removeAllChildren()
    -- 我要上庄
    self:getChildByName("bnt_tobe_delar"):loadTextureNormal(BrniuniuRes.br_game_btn_want_be_delar)
end

function BrnnDelar:updateWaitDelar()
    local allInfo = Cache.BrniuniuInfo.delars
    if allInfo == nil then return end
    local delarCount = #allInfo-1;
    local bcurrentDelar = false
    for k,v in pairs(allInfo) do
        if v.uin == Cache.BrniuniuDesk.br_delar.uin then
            bcurrentDelar = true
        end
    end
    if bcurrentDelar == false then
        delarCount = #allInfo
    end
    if delarCount < 0 then 
        delarCount = 0;
    end
    self:getChildByName("dealer_wait_txt"):setString(string.format(BrniuniuTXT.delarWait, delarCount))
end


function BrnnDelar:setNick(nick)
    nick = self.onBody == true and " " or nick
    local txt = self:getChildByName("delar_name")
    local remark_name= Util:getFriendRemark(self.uin,nick)
    txt:setString(remark_name or " ")
    -- txt:setAnchorPoint(0,0.5)
    -- txt:setPosition(cc.p(self:getContentSize().width*0.425,self:getContentSize().height*0.84))
end
function BrnnDelar:setGold(gold)
    if checkint(self.uin) >= 2000 and checkint(self.uin) <= 2010 then
        self.delar_chip:setString(BrniuniuTXT.system_dealer)
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
    self.delar_chip:setString(Util:getFormatString( Cache.packetInfo:getProMoney(checknumber(gold))))
end

function BrnnDelar:winMoneyFly(paras)
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
        qf.event:dispatchEvent(BRNN_ET.BR_WINMONEY,{node=self, idx = 2, uin = self.uin})
    end
end

function BrnnDelar:initCards()
    for i = 1 , 5 do
        self["c"..i] = self:getChildByName("share_card_"..i)
        self["c"..i]:setVisible(false)
    end
end

function BrnnDelar:giveCards(delay,cdelay,dpoint)
    delay = delay or 0
    cdelay = cdelay or 0
    self:clearCards()
    self.cards = {}
    for i = 1, 5 do
        local card = Card.new()
        self:addChild(card)
        Util:giveCardsAnimation({delay = (i-1)*cdelay+delay,parent = self,c1 = self["c"..i],z = 2,c2 = card,dpoint = dpoint,first = self.c1})
        self.cards[i] = card
    end
end

function BrnnDelar:showCards(delay,cdelay,dpoint)
    delay = delay or 0
    cdelay = cdelay or 0
    self:clearCards()
    self.cards = {}
    for i = 1, 5 do
        local card = Card.new()
        self:addChild(card)
        card:setScale(self["c"..i]:getScale())
        card:setLocalZOrder(2)
        card:setPosition(self["c"..i]:getPositionX(),self["c"..i]:getPositionY())
        self.cards[i] = card
    end
end

function BrnnDelar:reverseCards(delay)
    for i = 1, 6 do
        local card = self.cards[i]
        if card == nil then
            self:delayRun(delay+0.3,function() 
                self:showCardInfo()
            end)
        else
            self:delayRun(delay,function() 
                MusicPlayer:playMyEffect("FAPAI")
                card.value = Cache.BrniuniuDesk.br_delar.cards[i]
                if not tolua.isnull( card ) then
                   card:reverseSelf(nil,Cache.BrniuniuDesk.br_delar.cards[i])
                end
            end)
        end

    end 
end

function BrnnDelar:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function BrnnDelar:initHead( ... )
    -- self.delar_head:setVisible(false)
    -- local p = cc.Sprite:create(BrniuniuRes.br_default_head_icon)
    -- local cs = self:getContentSize()
    -- local posx, posy = self.delar_head:getPosition()
    -- p:setPosition(posx, posy)
    -- self:addChild(p, 2)
    -- self.user_head = p
end
function BrnnDelar:updateHead()
    local scale = self.delar_head:getContentSize().width
    local extparas = {add=true, circle=false, url=true, sq = true}
    if Util:checkSysZhuangUin(self.uin) then
        extparas.default = GameRes.defaultZhuangImg
    end

    Util:updateUserHead(self.delar_head, self.portrait, self.sex, extparas)
end

function BrnnDelar:clearCards(bCloudCard)
    --self:getChildByName("card_info"):setVisible(false)
    if self.cards == nil or #self.cards == 0 or (bCloudCard and bCloudCard == true) then return end
    for k, v in pairs(self.cards) do
        v:removeFromParent(true)
    end
    self.cards = {}
end


---下注
function BrnnDelar:bet()
    local chip = Cache.BrniuniuDesk.br_delar.chips
    self:setGold(chip)
end

function BrnnDelar:showCardInfo()
    local txt = self:getChildByName("card_type")

    local ty = BrniuniuRes.br_game_card_type_10
    if Cache.BrniuniuDesk:getRoomType() == 14 then    -- 3人场
        ty = BrniuniuRes.br_game_card_type
    end
    
    txt:setVisible(true)
    --如果是没牛就显示灰色，其他都是高亮
    txt:getChildByName("type"):loadTexture(string.format(ty, Cache.BrniuniuDesk.br_delar.card_type, Cache.BrniuniuDesk.br_delar.card_type == 0 and 0 or 1),ccui.TextureResType.plistType)
    txt:getChildByName("bg"):setVisible(false)
    -- txt:getChildByName("bg"):loadTexture(string.format(BrniuniuRes.br_game_card_type_bg, Cache.BrniuniuDesk.br_delar.card_type == 0 and 0 or 1),ccui.TextureResType.plistType)
    MusicPlayer:playMyEffectGames(BrniuniuRes, string.format("NIU_%d_%d",1, Cache.BrniuniuDesk.br_delar.card_type))
end

function BrnnDelar:hideCardInfo()
    self:getChildByName("card_type"):setVisible(false)
end

function BrnnDelar:getChipsPosition() 
    return cc.p(self:getPositionX()+self.user_bg:getPositionX(),self:getPositionY()+self.user_bg:getPositionY())
end

function BrnnDelar:ready(bCloudCard)
    self:hideCardInfo()
    self:clearCards(bCloudCard)
    self.img_jackpot:setVisible(false)
end


--聊天相关 begin
function BrnnDelar:showPopChat(model, del)
    del._chat:showPopChatProtocol(model, self, {chatDel = del})
end

function BrnnDelar:emoji(index, Emoji_index)
    self:playEmojiAni({anim = Emoji_index[index].animation,index=Emoji_index[index].index,scale=2})
end

--显示表情
function BrnnDelar:playEmojiAni( paras )
    local head = ccui.Helper:seekWidgetByName(self, "delar_head")
    paras.node = self
    paras.order= 100
    if paras.position  == nil then
        paras.position = cc.p(head:getPositionX(),head:getPositionY())
    end
    local face =  Util:playAnimation(paras)
end

function BrnnDelar:playShowChatMsg(txt_layer, msg)
	local chatnode = txt_layer:playShowChatMsg(self, self:getChildByName("delar_head"), {
        corner = GameConstants.CORNER.LEFT_DOWN,
        offset = {x = -47, y = -70},
		msg = msg,
		chatname = "delar"
    })
    self.chatnode = node
end

return BrnnDelar