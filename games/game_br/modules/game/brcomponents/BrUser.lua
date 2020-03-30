local BrUser = class("BrUser",function(paras)
    return paras.node
end)
-- local Chat = import("..components.Chat")
local Gift = import("..components.Gift")
BrUser.VIP_TAG = 8001

function BrUser:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.index = paras.index
    self:init()
end

function BrUser:init()
    self:getAll()
    self:leave()
    self:initTouch()
end

function BrUser:initTouch()
    addButtonEvent(self,function()
        if self.isSeat then
            --这里只显示目前显示的金币数量，防止开牌了，去查询服务器，客户端显示不一致的问题
            qf.event:dispatchEvent(ET.GAME_SHOW_USER_INFO,{uin=self.uin,showGoldTxt = self.chip_str:getString()})
        else
            if Cache.brdesk.br_delar.uin == Cache.user.uin then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = BrTXT.br_sitdown_failed_error1})
                return
            end
            qf.event:dispatchEvent(BR_ET.BR_SEATDOWN_REQ,{index = self.index})
        end
    end)
    addButtonEvent(self.btn_gift,function ( sender )
        -- local type 
        -- if ModuleManager:judegeIsIngame() then
        --     type = self.uin == Cache.user.uin and 3 or 4
        -- end
        -- qf.event:dispatchEvent(ET.SHOW_GIFT,{name="gift",from=self.TAG, type = type, uin = self.uin , gifts = self.gifts })
    end)
end

function BrUser:getAll()
    local nameT = {"name_str","chip_str","seat_down","btn_gift", "img_beauty", "user_bg", "user_head"}
    for k, v in pairs(nameT) do
        self[v] = self:getChildByName(v)
        -- self[v]:setVisible(true)
    end
    
    self.name_str:setPosition(cc.p(87, 198))
    self.chip_str:setPosition(cc.p(87, 22))
    self.user_head:setPosition(cc.p(87, 111))

    -- performWithDelay(self, function ( ... )
    --     -- self.name_str:setVisible(true)
    --     -- if self.name_str then
    --     --     Util:setPosOffset(self.name_str, {y = -6})
    --     --     self.name_str:setVisible(true)
    --     -- end
    --     print("ZXCXZCVZXCV")
    --     self.chip_str:setVisible(true)
    --     self.chip_str:setString("10000")
    --     self.user_head:setVisible(true)
    --     self.name_str:setVisible(true)
    --     self.name_str:setString("string ——")
    --     -- if self.user_head then
    --     --     Util:setPosOffset(self.user_head, {y = -3})
    --     -- end

    --     self.name_str:setPosition(cc.p(87, 195))
    --     self.chip_str:setPosition(cc.p(87, 22))
    --     self.user_head:setPosition(cc.p(87, 111))
    --     self.sex = 1
    --     self.portrait = "IMG1"
    --     self:updateHead()
    -- end,0.1)
end

function BrUser:bet()
    local u = Cache.brdesk.br_user[self.uin]
    if u ~= nil then
        self:setGoldTxt(u.chips)
    end
end

function BrUser:checkLeft()
    return self.index <= 3
end

function BrUser:winMoneyFly(paras)
    local money = tonumber(paras.chips)
    if money == 0 then return end
    --如果这个时候刚才人走了，或者人不是之前的那个人
    if not self.isSeat or self.uin ~= paras.uin then return end
    local fnt
    local img
    if money > 0 then
        fnt  = cc.LabelBMFont:create('+'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_add_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_win_money_back)
    else
        fnt  = cc.LabelBMFont:create('-'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_reduce_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_reduce_money_back)
    end
    self:setVisible(true)
    self:addChild(img)
    img:addChild(fnt)
    local high = self:getContentSize().height -20
    local wx = 0
    local bLeft = true
    local fntX = 30
    -- -- 最右边的座位需要右对齐
    if self.index > 3 then
        bLeft = false
    end
    local move
    if bLeft then
        if fnt:getContentSize().width < img:getContentSize().width then
            fntX = fntX + (img:getContentSize().width - 45 - fnt:getContentSize().width)/2
        end
        fnt:setAnchorPoint(0,0.5)
        img:setAnchorPoint(0.5,0.5)
        img:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        fnt:setPosition(fntX,img:getContentSize().height/2)
        img:setScale(0.7)
        fnt:setScale(1)
        img:setZOrder(6)
        fnt:setZOrder(6)

        move = cc.MoveTo:create(0.25,cc.p(self:getContentSize().width/2,high))
    else
        if fnt:getContentSize().width < img:getContentSize().width then
            fntX = fntX + (img:getContentSize().width - fnt:getContentSize().width)/2 - 25
        end
        fnt:setAnchorPoint(1,0.5)
        fnt:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        img:setAnchorPoint(0.5,0.5)
        img:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        fnt:setPosition(img:getContentSize().width - fntX,img:getContentSize().height/2)
        img:setScale(0.7)
        fnt:setScale(1)
        img:setZOrder(6)
        fnt:setZOrder(6)

        move  = cc.MoveTo:create(0.25,cc.p(self:getContentSize().width/2,high))
    end
    
    local delay = cc.DelayTime:create(2)
    local call  = cc.CallFunc:create(function (sender)
        if sender then
            sender:removeFromParent()  
        end
    end)
    local sq   = cc.Sequence:create(move,delay,call)
    img:runAction(sq)
    if money > 0 then
        qf.event:dispatchEvent(BR_ET.BR_WINMONEY,{node=self, idx = 1, uin = self.uin})
    end
end

function BrUser:refreshGold(gold)
    if not gold then return end
    self:setGoldTxt(gold)
end

function BrUser:seatDown(someone)
    self.isSeat = true
    self.seat_down:setVisible(false)
    self.btn_gift:setVisible(false)
    self.user_head:setVisible(true)
    self.name_str:setVisible(true)
    self.chip_str:setVisible(true)
    self.uin = someone.uin
    self.sex = someone.sex
    self.nick = Util:showUserName(someone.nick)
    self.chips = someone.chips
    self.is_vip = (someone.vip_days ~=nil and someone.vip_days > 0) and true or false
    self.portrait = someone.portrait
    self:setGoldTxt(self.chips)
    self:setNickTxt(self.nick)
    self:setVipFlagVisible(self.is_vip)
    self:initHead()
    self:updateHead()
    self:updateGiftBtn(someone.decoration)
    if someone.beauty then
        self.img_beauty:setVisible(true)
        self.user_bg:loadTexture(BrRes.br_game_vip_bg)
    end
end

function BrUser:update(info)
    
end

function BrUser:setNickTxt(nick)
    local remark_name= Util:getFriendRemark(self.uin,nick)
    self.name_str:setString(remark_name)
    self.name_str:setAnchorPoint(0.5, 0.5)
    self.name_str:setPositionX(self:getContentSize().width / 2)
end

function BrUser:setVipFlagVisible(visible)
	--移除vip标识
	if self:getChildByTag(self.VIP_TAG) ~= nil then
		self:removeChildByTag(self.VIP_TAG)
	end
	if visible == false then return end
	--添加vip标识
	local img_vip = cc.Sprite:create(BrRes.vip_playgame_icon)
	img_vip:setTag(self.VIP_TAG)
	self:addChild(img_vip, 5)
	--nick限制长度
	local vip_w = img_vip:getContentSize().width
	self.name_str:setTextAreaSize(cc.size(self:getContentSize().width - vip_w - 5, self.name_str:getContentSize().height))
	--vip和nick居中
	local w = vip_w + self.name_str:getContentSize().width + 5
	local vip_x = (self:getContentSize().width - w) / 2
	img_vip:setAnchorPoint(0, 0.5)
	img_vip:setPosition(vip_x, self.name_str:getPositionY())
	local nick_x = vip_x + vip_w + 5
	self.name_str:setAnchorPoint(0, 0.5)
	self.name_str:setPositionX(nick_x)
end

function BrUser:setGoldTxt(gold)
    self.chip_str:setString(Util:getFormatString(Cache.packetInfo:getProMoney(gold)))
end

function BrUser:leave()
    self.isSeat = false
    self.uin = nil
    self.name_str:setString(" ")
    self.name_str:setVisible(false)
    self.chip_str:setString(" ")
    self.chip_str:setVisible(false)
    self.seat_down:setVisible(true)
    self.btn_gift:setVisible(false)
    self.img_beauty:setVisible(false)
    self.user_head:setVisible(false)
    self:setVipFlagVisible(false)
    self.user_bg:loadTexture(BrRes.br_game_common_bg)
    self.user_bg:removeAllChildren()
end

function BrUser:initHead( ... )
    -- local _res
    -- local p = cc.Sprite:create(GameRes.br_default_head_icon)
    -- local cs = self:getContentSize()
    -- local posx, posy = self:getChildByName("user_head"):getPosition()
    -- p:setPosition(posx, posy)
    -- self:addChild(p, 2, 10)
    -- self.user_head = p
end
function BrUser:updateHead()
    local scale = self.user_head:getContentSize().width
    Util:updateUserHead(self.user_head, self.portrait, self.sex, {add=true, circle=false, sq = true, scale=scale, url=true})  
    self.user_head:setScale(0.95)
end

function BrUser:getChipsPosition() 
    return cc.p(self:getPositionX()+self.user_bg:getPositionX(),self:getPositionY()+self.user_bg:getPositionY())
end

-- self:playEmojiAni({anim=Chat.Emoji_index[num].animation,index=Chat.Emoji_index[num].index,scale=2})
--显示表情
function BrUser:playEmojiAni( paras )
    paras.node = self
    local head = self.user_head
    if paras.position  == nil then
        paras.position = cc.p(head:getContentSize().width/2+19,head:getContentSize().height/2+35)
    end

    if paras.order == nil then
        paras.order = 5
    end

    local face =  Util:playAnimation(paras)
end


function BrUser:emoji(index, Emoji_index)
    self:playEmojiAni({anim = Emoji_index[index].animation,index=Emoji_index[index].index,scale=2})
end

function BrUser:playShowChatMsg(txt_layer, msg)
    local corner =  GameConstants.CORNER.LEFT_DOWN
    if self.index > 3 then
        corner = GameConstants.CORNER.RIGHT_DOWN
    end
	local chatnode = txt_layer:playShowChatMsg(self, self.user_bg, {
        corner = corner,
        -- offset = {x = -47, y = -21},
		msg = msg,
		chatname = "chat_" .. self.index
    })
    self.chatnode = node
end

function BrUser:showPopChat(model, del)
    del._chat:showPopChatProtocol(model, self, {chatDel = del})
end

function BrUser:receiveGift(paras) --这个用来 加好友的动画 所以没有updateGiftBtn
   local user_bg=nil
       if paras.fr_u then 
             user_bg= paras.fr_u:getChildByName("user_bg")
             user_bg=user_bg or paras.fr_u:getChildByName("img_head_bg") --百人场自己的头像位置
       end
   local pox=paras.x--+self:getContentSize().width/2
   local posy=paras.y--+self:getContentSize().height/2+30
   if user_bg then 
          pox=paras.x+user_bg:getPositionX()
          posy=paras.y+user_bg:getPositionY()
   end
   local from = self:convertToNodeSpace(cc.p(pox,posy))
   local cs = self:getContentSize()
   local to = cc.p(0+cs.width/2,0+cs.height/2)
   local id =paras.id
   local gift = Gift.new({from=from,to=to,id=id,from_uin=paras.from_uin,to_uin=paras.to_uin,ask_friend=paras.ask_friend})
   if gift then
       self:addChild(gift)
   end
    --logd("-----接收到礼物，更新挂饰 : "..tostring(paras.decoration).."-------")  这个用来 加好友
     if paras.decoration then self:updateGiftBtn(paras.decoration)  end
end

function BrUser:updateGiftBtn(paras)
    qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = self.btn_gift,icon = paras} )
end

return BrUser