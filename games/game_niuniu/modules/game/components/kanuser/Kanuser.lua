local Card          =  import("src.games.game_niuniu.modules.game.components.card.Card")
local GameAnimationConfig          =  import("src.games.game_niuniu.modules.game.components.animation.KananimationConfig")
local Useranimation =  import("src.games.game_niuniu.modules.game.components.kanuser.Useranimation")
local Gift 			= import("..Gift")
local Kanuser          =  class("Kanuser", function (paras)
    return paras.node
 end)


Kanuser.Icon   = "icon"
Kanuser.Nick   = "nick"
Kanuser.Gold   = "gold_num"
Kanuser.GoldImg   = "gold_img"
Kanuser.Base   = "base"
Kanuser.Zhuang = "zhuang"
Kanuser.Buqiang= "bu_qiang"
Kanuser.Qiang  = "qiang"
Kanuser.Cards_panel  = "card_panel"
Kanuser.Qiang_zhuang_high = "qiang_zhuang_high"
Kanuser.Niu_img = "niu_img"
Kanuser.Niu_bg  = "niu_bg"
Kanuser.Niu     = "niu"
Kanuser.BG     = "bg"
Kanuser.GIFT_BTN    = "gift" --礼物
Kanuser.WAITING    = "waitingStart" --礼物
Kanuser.Card_Anim_Time  = 0.4   --发牌动画时间
Kanuser.Card_Anim_Space = 0.04  --牌之间的间隔时间
Kanuser.hatTag=9873--美女皇冠tag

--emoji position --
Kanuser.Emoji_position = cc.p(80,80)

-- chat layer position --
Kanuser.Chat_position = {
	[0] = {
		x = 450,
		y = 280 
	},
	[1] = {
		x = 1420,
		y = 650 
	},
	[2] = {
		x = 1320,
		y = 800
	},
	[3] = {
		x = 700,
		y = 800,
	},
	[4] = {
		x = 450,
		y = 650,
	},
}

Kanuser.Nick_positionX = {
	[0] = 193,
	[1] = 24,
	[2] = 193,
	[3] = 193,
	[4] = 24,
}
function Kanuser:ctor ( paras )
	self._parent_view = paras.view

	local fnt = self:getChildByName("fntname")
	local img = self:getChildByName("imgname")

	if fnt then
		fnt:stopAllActions()
		fnt:removeFromParent()
	end
	
	if img then
		img:stopAllActions()
		img:removeFromParent()
	end

	self:init(paras)
end


function Kanuser:init(paras)

	local icon_btn         = ccui.Helper:seekWidgetByName(self,Kanuser.Icon)           --玩家图像name
	self.nick              = ccui.Helper:seekWidgetByName(self,Kanuser.Nick)           --玩家昵称name
	self.gold              = ccui.Helper:seekWidgetByName(self,Kanuser.Gold)           --玩家金币name
	self.goldImg              = ccui.Helper:seekWidgetByName(self,Kanuser.GoldImg)        --玩家金币图片
	self.cards_panel       = ccui.Helper:seekWidgetByName(self,Kanuser.Cards_panel)    --玩家手牌容器

	if self.cards_panel then
		self.cards_panel:removeAllChildren()
	end

	self.base              = ccui.Helper:seekWidgetByName(self,Kanuser.Base)           --下注的倍数
	self.zhuang            = ccui.Helper:seekWidgetByName(self,Kanuser.Zhuang)         --庄的标示
	self.buqiang           = ccui.Helper:seekWidgetByName(self,Kanuser.Buqiang)        --不抢
	self.qiang             = ccui.Helper:seekWidgetByName(self,Kanuser.Qiang)          --不抢
	self.qiang_zhuang_high = ccui.Helper:seekWidgetByName(self,Kanuser.Qiang_zhuang_high)          --抢庄框
	self.qiang_zhuang_high:setVisible(true)
	self.qiang_zhuang_high:setOpacity(0)
	self.niu_img           = ccui.Helper:seekWidgetByName(self,Kanuser.Niu_img)          --niu
	self.niu_bg            = ccui.Helper:seekWidgetByName(self,Kanuser.Niu_bg) 
	self.niu               = ccui.Helper:seekWidgetByName(self,Kanuser.Niu) 

	ccui.Helper:seekWidgetByName(self,Kanuser.GIFT_BTN):setTouchEnabled(true)
	self.showWaitingStart  = ccui.Helper:seekWidgetByName(self,Kanuser.WAITING)  --等待
	
	self._bg               = ccui.Helper:seekWidgetByName(self,Kanuser.BG) 
	self.selfSize          = self._bg:getContentSize()

	self._uin              = paras.uin                                              --玩家id
	self._info             = Cache.kandesk._player_info[self._uin]                     --玩家的信息
	self._seatid           = self._info.seatid
	self._info.quit        = 0
	self._cards            = {}                                                     --玩家的牌节点
	self._panel_name       = self:getName()    

	self._index   = self:getIndex(self._uin)                                     --用户panel名称

	-- if self._info.nick~=string.sub(self._info.nick, 1, 15) then
	-- 	local index = self:getIndex(self._uin)
	-- 	self.nick:getLayoutParameter():setMargin({ left = self.Nick_positionX[index]-10,right =self.nick:getLayoutParameter():getMargin().right, top = self.nick:getLayoutParameter():getMargin().top, bottom = self.nick:getLayoutParameter():getMargin().bottom})
	-- end

	self.nick:setString(self._info.nick)
     -- self.gold:setContentSize(cc.size(170,40))
    self.gold:setString(Util:getFormatString(self._info.chips+Cache.packetInfo:getProMoney(self._info.gold)))
	--self:updateUserInfo()

	self:updateBeauty()--显示美女标识

	--头像按钮事件
    local function buttonEvent(sender, eventType)
        if eventType == CommonWidget.CButton.EVENT.CLICK or eventType == CommonWidget.CButton.EVENT.DOUBLE_CLICK then
        	if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
        	local gold=Cache.kandesk.magic_express_money and Cache.kandesk.magic_express_money or 0
        	local localinfo={gold=Cache.kandesk._player_info[self._uin].gold+Cache.kandesk._player_info[self._uin].chips,
            				nick=self._info.nick,
            				portrait=self._info.portrait,
            				sex=self._info.sex}
            qf.event:dispatchEvent(Niuniu_ET.GAME_SHOW_USER_INFO,{uin=self._uin,localinfo=localinfo})
            --qf.event:dispatchEvent(Niuniu_ET.GAME_SHOW_USER_INFO,{uin=self._uin})
        elseif eventType == CommonWidget.CButton.EVENT.LONG_PRESS_DOWN then
        	-- if not self.stt_button_press then
	        -- 	self.stt_button_press = true
	        -- 	local pos
	        -- 	local dir
	        -- 	local gold=Cache.zjhdesk.magic_express_money and Cache.zjhdesk.magic_express_money or 0
	        -- 	local seatid=self._info.seatid- Cache.user.meIndex
	        -- 	seatid= seatid<0 and seatid+5 or seatid
	        -- 	loga("seatid"..self._info.seatid- Cache.user.meIndex)
	        -- 	dir=seatid>2 and 4 or 3
	        -- 	if seatid==1 then
	        -- 		dir=3
	        -- 		pos=cc.p(self:getPositionX(),self:getPositionY()+self:getContentSize().height/2)
	        -- 	elseif seatid==2 or seatid==3 then
	        -- 		dir=2
	        -- 		pos=cc.p(self:getPositionX()+self:getContentSize().width/2,self:getPositionY())
	        -- 	else
	        -- 		dir=4
	        -- 		pos=cc.p(self:getPositionX()+self:getContentSize().width,self:getPositionY()+self:getContentSize().height/2)
	        -- 	end
	        -- 	local paras={uin=self._uin,pos=pos,dir=dir,gold=gold}
	        --     qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION,paras)
	        -- end
	    elseif eventType == CommonWidget.CButton.EVENT.LONG_PRESS_UP then
            self.stt_button_press = nil
        end
    end

    --头像按钮事件
    self.icon = CommonWidget.CButton.new(icon_btn)
    self.icon:setTouchEnabled(true)
    --self.icon:setPressedActionEnabled(true)
    self.icon:addButtonEventListener(buttonEvent)
    loga("抢庄牛牛"..self._info.portrait)
    Util:updateUserHead(self.icon, self._info.portrait, self._info.sex, {add=true, sq=true,url=true})

	if self.goldImg then
	    self.goldImg:loadTexture(Cache.packetInfo:getGoldImg())
	end

	if self._uin ~= Cache.user.uin then
		addButtonEvent(ccui.Helper:seekWidgetByName(self,Kanuser.GIFT_BTN),function ( sender )
	        local type 
	        --if ModuleManager:judegeIsIngame() then
	            type = self._uin == Cache.user.uin and 3 or 4
	       -- end
	        --loga("xxxxxxxxxx"..type)
	        qf.event:dispatchEvent(ET.SHOW_GIFT,{name="gift",from=self.TAG, type = type, uin = self._uin ,gifts = self.gifts })
	    end)
	end

	self.gift = ccui.Helper:seekWidgetByName(self,Kanuser.GIFT_BTN)
	self:updateBtn(-1)
	--if  not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.gift:setVisible(false)
	--end
	self:setWaitingStartVis(false)
	--初始化状态
	if self.niu_bg then
		self.niu_bg:setVisible(false)
	end
	if self.niu_img then
		self.niu_img:setVisible(false)
	end
	self.buqiang:setVisible(false)
	self.qiang:setVisible(false)
	self.base:setVisible(false)
	self.zhuang:setVisible(false)
end


--获得座位序号
function Kanuser:getIndex(uin)
	if not Cache.kandesk._player_info[uin] then return end
	local seat = Cache.kandesk._player_info[uin].seatid
	local cut = seat - Cache.kandesk:getMeIndex()
	if cut < 0 then
		cut = 5+cut
	end
	if cut >= 5 then
		cut = 0
	end
	return cut
end


--显示
function Kanuser:show(times)
	self:setVisible(true)
	local fadeout    = cc.FadeIn:create(times)
	self:runAction(fadeout)
end


--退出房间
function Kanuser:quitRoom(times)
	if Cache.kandesk.status == 1 or self._info.status == UserStatus.USER_STATE_READY then
		self._info.quit = 1
		self:clear()

		local fadeout    = cc.FadeOut:create(0.2)
		self:runAction(fadeout)
		self._parent_view._users[self._uin] = nil
	else
		self._info.quit = 1
	end
end


function Kanuser:clear()
	self.cards_panel:removeAllChildren()
	self._cards = {}
	self.bQiang = false
	if self._info.quit ==1 then
		local fadeout    = cc.FadeOut:create(0.2)
		self:runAction(fadeout)
		Cache.kandesk._player_info[self._uin] = nil
		self._parent_view._users[self._uin]   = nil
		self.cards_panel:setVisible(false)
		self.zhuang:setVisible(false)
		self.buqiang:setVisible(false)
		self.qiang:setVisible(false)
		self.niu_img:setVisible(false)
		self.base:setVisible(false)
		self.niu_bg:setVisible(false)
		self.icon:setTouchEnabled(false)
		ccui.Helper:seekWidgetByName(self,Kanuser.GIFT_BTN):setTouchEnabled(false)
	else
		self.cards_panel:setVisible(false)
		self.zhuang:setVisible(false)
		self.buqiang:setVisible(false)
		self.qiang:setVisible(false)
		self.niu_img:setVisible(false)
		self.niu_bg:setVisible(false)
		self.base:setVisible(false)
	end
end


function Kanuser:clearQuit()
	self.cards_panel:removeAllChildren()
	self._cards = {}

	local fadeout    = cc.FadeOut:create(0.2)
	self:runAction(fadeout)
	self._parent_view._users[self._uin]   = nil
	self.cards_panel:setVisible(false)
	self.zhuang:setVisible(false)
	self.buqiang:setVisible(false)
	self.qiang:setVisible(false)
	self.niu_img:setVisible(false)
	self.base:setVisible(false)
	self.niu_bg:setVisible(false)
end


--发牌动画
function Kanuser:sendCardAnim()
	if self._cards and type(self._cards) == "table" and #self._cards == 5 then
		return
	end
	self:stopSendCardAnim()
	self.cards_panel:setVisible(true)
	local tx = self.cards_panel:getPositionX()
	local ty = self.cards_panel:getPositionY()


	local tx1 = self:getPositionX()
	local ty1 = self:getPositionY()
	self._cards      = {}

	local card_tmp  = Card.new()
	local size      = card_tmp:getContentSize()

	local alllength = (4*55+size.width)*0.7
	local panelsize = self.cards_panel:getContentSize()
	local start_width =  (panelsize.width - alllength)/2
	start_width = size.width/2*0.7+start_width

	MusicPlayer:playMyEffectGames(Niuniu_Games_res,"FLIP")
	for i=1,5 do
		local card_tmp  = Card.new()
		table.insert(self._cards,card_tmp)
		self.cards_panel:addChild(card_tmp)
		local name = self._panel_name
		card_tmp:setScale(0.7)
		-- card_tmp:setAnchorPoint(cc.p(0,0))
		card_tmp:setPosition(Display.cx/2-(tx+tx1),Display.cy/2-(ty+ty1))
		-- local move = cc.MoveTo:create(10,cc.p(tx+tx1,ty+ty1))
		
		local delay     = cc.DelayTime:create(Kanuser.Card_Anim_Space*(5-i))
		local move      = cc.MoveTo:create(Kanuser.Card_Anim_Time,cc.p(size.width*0.7/2,size.height*0.7/2))
		local delay_1ms = cc.DelayTime:create(Kanuser.Card_Anim_Time)
		local move_line = cc.MoveTo:create(Kanuser.Card_Anim_Time,cc.p((i-1)*50+size.width*0.7/2,size.height*0.7/2))
		local sq        = cc.Sequence:create(delay,move,delay_1ms,move_line)

		card_tmp:runAction(sq)
	end
end

--停止发牌
function Kanuser:stopSendCardAnim()
	if type(self.cards) == "table" then
		for i, v in ipairs(self.cards) do
			v:stopAllActions()
			v:removeFromParent()
		end
		self.cards = {}
	end
end


function Kanuser:qiangFuc( call_times )
	-- body
	if call_times == 0 then
		self.buqiang:setVisible(true)
	else
		self.qiang:setVisible(true)
		self.qiang:setString("qx"..tostring(call_times))
	end
	self.bQiang = true
end

--检查是否已经抢庄了
function Kanuser:checkQiang()
	return self.bQiang
end

--type 1渐变 2常亮
function Kanuser:showQiangKuang(type)
	if type == 1 then
		MusicPlayer:playMyEffectGames(Niuniu_Games_res,"QIANG")
		local fadein  = cc.FadeIn:create(0.1)
		local fadeout = cc.FadeOut:create(0.1)
		local sq      = cc.Sequence:create(fadein,fadeout)
		

		self.qiang_zhuang_high:setCascadeColorEnabled(false)
		self.qiang_zhuang_high:runAction(sq)

		 
	end
	local size = self:getSize()

	if type == 2 then
		Util:delayRun(1,function ( ... )
			-- body
			MusicPlayer:playMyEffectGames(Niuniu_Games_res,"SETZHUANG")
		end)
		
		if self._uin == Cache.user.uin  then
			 
			-- body
				self._parent_view.Gameanimation:play({anim=GameAnimationConfig.KUANG_HENG,node=self,position={x=size.width/2,y=size.height/2}})
			
		else
			local index = self:getIndex(self._uin)
			if index == 1 or index ==4 then
				local face = self._parent_view.Gameanimation:play({anim=GameAnimationConfig.KUANG_SHU,node=self,position={x=size.width/2,y=size.height/2}})
				face:setLocalZOrder(2)
			else
				self._parent_view.Gameanimation:play({anim=GameAnimationConfig.KUANG_HENG,node=self,position={x=size.width/2,y=size.height/2}})
			end
		end
	end
end

--隐藏抢庄的信息
function Kanuser:hideQiang()
	-- body
	self.qiang:setVisible(false)
	self.buqiang:setVisible(false)
end

--显示下分倍数
function Kanuser:showBase(num)
	-- body
	self.qiang:setVisible(false)
	self.buqiang:setVisible(false)
	self.base:setVisible(true)
	self.base:setOpacity(0)
	local fadein = cc.FadeIn:create(0.2)
	self.base:setString("x"..tostring(num))
	self.base:runAction(fadein)
end


--显示庄
function Kanuser:showZhuang()
	-- body
	self.zhuang:setVisible(true)
end

--出牌完成
function Kanuser:sendCard(type)
	self.niu_img:setVisible(true)
	self.niu_img:loadTexture(Niuniu_Games_res.Kan_niu_wan,ccui.TextureResType.plistType)
end


function Kanuser:getSexByCache(uin)
    if uin == -1 then return 0 end
    local u = Cache.kandesk._player_info[uin]  
    if u == nil then return 0 end

    u.sex = u.sex==2 and 0 or u.sex
	return u.sex or 0
end

--显示牌
function Kanuser:showCard()
	-- body
	local info   = Cache.kandesk._result_info[self._uin]
	if info ==nil then return end
	local i = 1
	MusicPlayer:playMyEffectGames(Niuniu_Games_res,"COMPLETE_"..math.random(1,2))
	MusicPlayer:playMyEffectGames(Niuniu_Games_res,"NIU_"..tostring(self:getSexByCache(self._uin))..'_'..tostring(info.card_type))

	for k,v in pairs(self._cards) do
		v:setValue(info.card[i])
		i = i + 1
		v:flip()
		if info.card_type == 0 then
			v:dark()
		else
			self.niu_bg:setVisible(true)
		end
		if info.card_type>0 and info.card_type<=10 then
			self:chaiCard()
		end
	end


	self.niu_img:loadTexture(Niuniu_Games_res['Kan_niu_'..tostring(info.card_type)],ccui.TextureResType.plistType)
	local tx = self:getPositionX()
	local ty = self:getPositionY()
	local tx1 = self.niu:getPositionX()
	local ty1 = self.niu:getPositionY()
	local tx2 = self.niu_img:getPositionX()
	local ty2 = self.niu_img:getPositionY()

	if info.card_type ~= 0 then
		self._parent_view.Gameanimation:play({anim=GameAnimationConfig.CHU,node=self.niu_img,position=cc.p(tx2,ty2)})
	end
	-- self.niu_bg:setVisible(true)
end

--拆分出牌
function Kanuser:chaiCard()
	local i = 1
	for k,v in pairs(self._cards) do
		if i >=4 then
			local x = v:getPositionX()
			local y = v:getPositionY()
			v:setPosition(x+5,y)
		end
		i = i + 1
	end
end


--赢了显示的钱数
function Kanuser:winMoneyFly(money)

	if self._info == nil then return  false end



	local fnt
	local img
	if money > 0 then
		fnt  = cc.LabelBMFont:create('+'..Util:getFormatString(math.abs(money)),Niuniu_Games_res.KAN_WINMONEY_FNT)
		img  = cc.Sprite:create(Niuniu_Games_res.WINMONEY_BACK)
	else
		fnt  = cc.LabelBMFont:create('-'..Util:getFormatString(math.abs(money)),Niuniu_Games_res.KAN_LOSTMONEY_FNT)
		img  = cc.Sprite:create(Niuniu_Games_res.LOSTMONEY_BACK)
	end

	self:addChild(img)
	self:addChild(fnt)

	fnt:setName("fntname")
	img:setName("imgname")
	local high  = 320
	local start = 160

	if self._uin == Cache.user.uin then --自己头像特殊处理
		high = 230
	else --其他头像
		local index = self:getIndex(self._uin)
		if not index then return end
		if index == 2 or index==3 then
			start=-200
			high = 150
		elseif index == 0 then -- 自己方向的盘观位置
			start= 90
			high = 250
		end
	end



	fnt:setPosition(100,start)
	img:setPosition(100,start)
	fnt:setScale(0.9)
	img:setScale(0.9)

	fnt:setZOrder(6)
	img:setZOrder(5)
	local move  = cc.MoveTo:create(0.4,cc.p(100,high))
	local delay = cc.DelayTime:create(2)
	local call  = cc.CallFunc:create(function ()
		-- -- body
		if fnt then
			self:removeChild(fnt)
		end
	end)
	local sq   = cc.Sequence:create(move,delay,call)
	fnt:runAction(sq)

	local move1  = cc.MoveTo:create(0.4,cc.p(100,high))
	local delay1 = cc.DelayTime:create(2)
	local call1  = cc.CallFunc:create(function ()
		-- -- body
		if img then 
			self:removeChild(img)
		end
	end)
	local sq1   = cc.Sequence:create(move1,delay1,call1)
	img:runAction(sq1)
end


--更新用户信息
function Kanuser:updateUserInfo()
	-- if self._info.nick~=string.sub(self._info.nick, 1, 15) then
	-- 	--local index = self:getIndex(self._uin)
	-- 	--self.nick:getLayoutParameter():setMargin({ left = self.Nick_positionX[index]-10,right =self.nick:getLayoutParameter():getMargin().right, top = self.nick:getLayoutParameter():getMargin().top, bottom = self.nick:getLayoutParameter():getMargin().bottom})
	-- end
	self.nick:setString(self._info.nick)
	local gold = self._info.chips+ self._info.gold>0 and self._info.chips+ self._info.gold or 0

	self.gold:setString(Util:getFormatString(Cache.packetInfo:getProMoney(gold)))
	-- Util:updateUserHead(self.icon, self._info.portrait, 0, {add=true, sq=true, url=true})
end


--断线重连、
function Kanuser:reconnect()
	if self._info.status  >= 1081 then
		self:stopSendCardAnim()
		-- self._info.draw = 1  --标示已经绘制了牌桌的信息了
		self.cards_panel:setVisible(true)
		local tx = self.cards_panel:getPositionX()
		local ty = self.cards_panel:getPositionY()
		local tx1 = self:getPositionX()
		local ty1 = self:getPositionY()

		self.cards_panel:removeAllChildren()
		self._cards      = {}

		local card_tmp  = Card.new()
		local size      = card_tmp:getContentSize()

		local alllength = (4*55+size.width)*0.7
		local panelsize = self.cards_panel:getContentSize()
		local start_width =  (panelsize.width - alllength)/2
		start_width = size.width/2*0.7+start_width


		for i=1,5 do
			local card_tmp  = Card.new()
			table.insert(self._cards,card_tmp)
			self.cards_panel:addChild(card_tmp)
			card_tmp:setScale(0.7)
			card_tmp:setPosition(cc.p((i-1)*50+size.width*0.7/2,size.height*0.7/2))
		end

		if Cache.kandesk.zhuang_uin == self._uin then
			self:showZhuang()
		else
			self.zhuang:setVisible(false)
		end

		if self._info.status == 1082 then
			self:qiangFuc(self._info.grab_score)
		end

		if self._info.status == 1084 then
			self:showBase(self._info.callscore_time)
		end

		if self._info.status == 1086 then
			self:sendCard(self._info.card_type)
		end
	end
end



--显示表情
-- function Kanuser:vipemoji(index)
-- 	local chat   = self._parent_view._chat
-- 	local windex = self:getIndex(self._uin) 
-- 	self._parent_view.Gameanimation:playvipemoji({node=self.icon,index=index,position=self.Emoji_position,order=3})
-- end

function Kanuser:receiveGift(paras)
    local from = self:convertToNodeSpace(cc.p(paras.x,paras.y))
    local cs = self.selfSize
    local to = cc.p(self.icon:getPositionX(),self.icon:getPositionY())--cc.p(0+cs.width/2,0+cs.height/2)
    -- if self._uin ==Cache.user.uin then
    --     x=0+cs.width/2+ccui.Helper:seekWidgetByTag(self,41):getPositionX()
    --     y=0+cs.height/2+ccui.Helper:seekWidgetByTag(self,41):getPositionY()
    --     to=cc.p(x,y)
    -- end
    local id =paras.id
    local gift = Gift.new({from=from,to=to,id=id,from_uin=paras.from_uin,to_uin=paras.to_uin,ask_friend=paras.ask_friend})
    if gift then
        self:addChild(gift)
    end
    self:updateGiftBtn(paras.decoration)
end

function Kanuser:updateBtn(paras)
	-- body
    local btn_gift = ccui.Helper:seekWidgetByName(self,Kanuser.GIFT_BTN)
	qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = btn_gift,icon = paras})
end

function Kanuser:updateGiftBtn(paras,isMeEnter)
    local btn_gift = ccui.Helper:seekWidgetByName(self,Kanuser.GIFT_BTN)
    if self.disable_gift and btn_gift:isVisible() then
        btn_gift:setVisible(false)
    else
    	if paras and not isMeEnter and paras >=2000 and paras<2006 then
    		qf.event:dispatchEvent(ET.SHOW_GIFTCAR_ANI,{id =paras,txt=self._info.nick,pos=btn_gift:getWorldPosition(),cb=self.updateBtn,node = self})
    	else
        	self:updateBtn(paras)
    	end
        --qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = btn_gift,icon = paras} )
        local u = Cache.kandesk:getUserByUin(self.uin)
        if u and u.decoration == -1 then --如果当前的用户礼物是空的，就改变其为最新的
           u.decoration = paras
        end
    end
end

--更新是否需要显示美女皇冠
function Kanuser:updateBeauty()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    self:clearBeautyHat()
    self:clearBeautyRankHat()
  --  if self.hiding ~= nil and self.hiding == 1 then return end	--隐身状态下不显示美女皇冠
    local u =self._info  --self.zjhdesk._user[self.uin]
    if u == nil then return end
    if u and u.beauty and  u.b_rank then
        local rank 
        if u.b_rank > 3 then
            rank = 4
        else
            rank = u.b_rank
        end
        local img = Niuniu_Games_res["beauty_rank_hat_"..rank] or Niuniu_Games_res["beauty_rank_hat_4"]
        self.beautyBg=self._bg:clone()
        self._bg:addChild(self.beautyBg)
        if self:getContentSize().height>self:getContentSize().width then
        	self.beautyBg:loadTexture(Niuniu_Games_res.kp_beauty_rank_bg1,ccui.TextureResType.plistType)
        	self.beautyBg:setScale(1.07)
        	self.beautyBg:setPosition(cc.p(self.beautyBg:getPositionX()-5,self.beautyBg:getPositionY()+8))
        else
        	self.beautyBg:loadTexture(Niuniu_Games_res.kp_beauty_rank_bg2,ccui.TextureResType.plistType)
        	--self.beautyBg:setPosition(cc.p(self.beautyBg:getPositionX()-15,self.beautyBg:getPositionY()-5))
        end
        if img == nil then return end
        self.hat = cc.Sprite:create(img)
        if self:getContentSize().height>self:getContentSize().width then
			self.hat:setPosition(cc.p(img == Niuniu_Games_res["beauty_rank_hat_4"] and 4 or -5, self:getContentSize().height - (img == Niuniu_Games_res["beauty_rank_hat_4"] and -3 or -13)))
        else
        	self.hat:setPosition(cc.p(img == Niuniu_Games_res["beauty_rank_hat_4"] and 14 or 9, self:getContentSize().height - (img == Niuniu_Games_res["beauty_rank_hat_4"] and 15 or 0)))
        end
        self.hat:setTag(self.hatTag)
        self.hat.img=img--增加一个记号
        self:addChild(self.hat,2)
    else
        self:clearBeautyHat()
    end
end

function Kanuser:clearBeautyRankHat()--清楚排行皇冠
    if self.hat then
    	self.hat:removeFromParent()
		self.hat=nil
	end
end
function Kanuser:clearBeautyHat()--清除美女皇冠
	if self.beautyBg then 
		self.beautyBg:removeFromParent()
		self.beautyBg=nil
	end
end

function Kanuser:setWaitingStartVis(bvis)
	self.showWaitingStart:setVisible(bvis)
	self.gold:setVisible(not bvis)
	if self.goldImg then
		-- self.goldImg:setVisible(not bvis)
		self.goldImg:setVisible(false)
	end
end

function Kanuser:testSetCard()
		self.cards_panel:setVisible(true)
	local tx = self.cards_panel:getPositionX()
	local ty = self.cards_panel:getPositionY()
	local tx1 = self:getPositionX()
	local ty1 = self:getPositionY()
	self._cards      = {}
	local card_tmp  = Card.new()
	local size      = card_tmp:getContentSize()

	local alllength = (4*55+size.width)*0.7
	local panelsize = self.cards_panel:getContentSize()
	local start_width =  (panelsize.width - alllength)/2
	start_width = size.width/2*0.7+start_width
	for i=1,5 do
		local card_tmp  = Card.new()
		table.insert(self._cards,card_tmp)
		self.cards_panel:addChild(card_tmp)
		-- local name = self._panel_name
		card_tmp:setScale(0.7)
		card_tmp:setPosition(cc.p((i-1)*50+size.width*0.7/2,size.height*0.7/2))
		-- -- card_tmp:setAnchorPoint(cc.p(0,0))
		-- card_tmp:setPosition(Display.cx/2-(tx+tx1),Display.cy/2-(ty+ty1))
		-- -- local move = cc.MoveTo:create(10,cc.p(tx+tx1,ty+ty1))
		
		-- local delay     = cc.DelayTime:create(Kanuser.Card_Anim_Space*(5-i))
		-- local move      = cc.MoveTo:create(Kanuser.Card_Anim_Time,cc.p(size.width*0.7/2,size.height*0.7/2))
		-- local delay_1ms = cc.DelayTime:create(Kanuser.Card_Anim_Time)
		-- local move_line = cc.MoveTo:create(Kanuser.Card_Anim_Time,cc.p((i-1)*50+size.width*0.7/2,size.height*0.7/2))
		-- local sq        = cc.Sequence:create(delay,move,delay_1ms,move_line)

		-- card_tmp:runAction(sq)
	end
end

function Kanuser:playShowChatMsg(txt_layer, msg)
	local corner =  GameConstants.CORNER.LEFT_DOWN
	print("asdfasdf", self:getName(), "index >>>", self._index)--user_sencod

	if self:getName() == "user_sencod" then
        corner = GameConstants.CORNER.LEFT_UP
    end
    if self:getName() == "user_third" then
        corner = GameConstants.CORNER.LEFT_UP
    end
    if self:getName() == "user_fourth" then
        corner = GameConstants.CORNER.RIGHT_DOWN
	end

	local chatnode = txt_layer:playShowChatMsg(self, self.icon, {
        corner = corner,
		msg = msg,
		chatname = "chat_txt" .. self._index
	})
	self.chatnode = node
end

--显示聊天
function Kanuser:showPopChat(model, del)
	del._chat:showPopChatProtocol(model, self, {chatDel = del})
end


--显示表情
function Kanuser:emoji(index, Emoji_index)
	self._parent_view.Gameanimation:play({node=self.icon,anim=Emoji_index[index].animation,index=Emoji_index[index].index,scale=2,position=self.Emoji_position,order=3})
end

return Kanuser