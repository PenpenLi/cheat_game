local KanMyself        = class("KanMyself",import(".Kanuser"))
local Card          =  import("src.games.game_niuniu.modules.game.components.card.Card")
local GameAnimationConfig          =  import("src.games.game_niuniu.modules.game.components.animation.KananimationConfig")


KanMyself.Cards_panel = 94
KanMyself.Cards       = 331
KanMyself.Cards_panel_small_cards =  500
KanMyself.Cards_panel_small       =  493
KanMyself.Niu_bg       =  498
KanMyself.Niu_img_small      =  499
KanMyself.Niu      =  497
KanMyself.Niu_img      =  161
KanMyself.GIFTBTN     		   = 637  --礼物
--初始参数
KanMyself.Card_Center = {
	x=-260,
	y=287,
}


--发牌时间
KanMyself.Card_Anim_Time  = 0.5   --发牌动画时间
KanMyself.Card_Anim_Space = 0.05  --牌之间的间隔时间



function KanMyself:ctor ( paras )
	self.super.ctor(self, paras)
end

function KanMyself:init(paras)
	-- body
	self.super.init(self, paras)
	self.cards_panel = ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Cards_panel) --玩家手牌容器

	self.cards_content= ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Cards)       --玩家手牌
	self.niu_img     = ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Niu_img)       --niu
	self.niu         = ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Niu)       --niu
	self.niu_img_small  = ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Niu_img_small)       --niu
	self.niu_bg         = ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Niu_bg)       --niu
	self.cards_panel_small_cards = ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Cards_panel_small_cards)       --niu
	self.cards_panel_small = ccui.Helper:seekWidgetByTag(self._parent_view.root,KanMyself.Cards_panel_small)       --niu
	self._cards            = {} --玩家的牌的img
	addButtonEvent(ccui.Helper:seekWidgetByTag(self,KanMyself.GIFTBTN),function ( sender )
        local type 
        --if ModuleManager:judegeIsIngame() then
            type = self._uin == Cache.user.uin and 3 or 4
        --end
        qf.event:dispatchEvent(ET.SHOW_GIFT,{name="gift",from=self.TAG, type = type, uin = self._uin ,gifts = self.gifts })
    end)


    self.gift = ccui.Helper:seekWidgetByTag(self,KanMyself.GIFTBTN)
    self:updateBtn(-1)
	--if  not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.gift:setVisible(false)
    --end
	
	--金币跳转商店
	local gold_img = ccui.Helper:seekWidgetByName(self, "gold_img")
	local gold_num = ccui.Helper:seekWidgetByName(self, "gold_num")
	gold_img:loadTexture(Cache.packetInfo:getGoldImg())
	gold_img:setVisible(false)
	Util:addButtonListEventEx({gold_img, gold_num},function ( sender)
        qf.platform:umengStatistics({umeng_key = "QuickSale1Open"})
        qf.event:dispatchEvent(ET.SHOP)
	 end)
	 
	-- --初始化状态
	-- self.buqiang:setVisible(false)
	-- self.qiang:setVisible(false)
	-- self.base:setVisible(false)
end


function KanMyself:outRoomWithGameNotGoing()
	ModuleManager.kancontroller:outRoomWithGameNotGoing()
end


function KanMyself:standUp()
	Cache.kandesk:updateCacheByStandUp({uin = Cache.user.uin})
	self._parent_view:standUp(Cache.user.uin)
end

--退出房间
function KanMyself:quitRoom(model)
	print(" ====== KanMyself:quitRoom ===== ")
	-- self:clear()
	Cache.kandesk:clearChat()--清除聊天记录
	dump(model.reason)
	if model.reason == 5 then -- 主动退桌
		self:outRoomWithGameNotGoing()
		-- Cache.kandesk:clear()
	elseif model.reason == 11 or model.reason == 12 or model.reason == 13 then -- 11是金币不足，12是未操作被站起 13 是金币超上限
		--打得过程中 没有钱了
		-- Scheduler:clearAll()
		self._info.kick =1
		local time
		time = 8 + Cache.kandesk.playerNum*1
		Scheduler:delayCall(time,function ()
			if Cache.packetInfo:isShangjiaBao() then
				-- 金币不足提示
				if model.reason == 11 then
					ModuleManager.kancontroller:noGoldCheck()
				end

				-- 金币超上限
				if model.reason == 13 then
				    ModuleManager.kancontroller:showOverLimitGoldPop()
				end
			end
			self:standUp()
		end)
	--站起桌子已解散
	elseif model.reason == 0 then
		qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Niuniu_GameTxt.niu_txt_6})
		self:standUp()
		self:outRoomWithGameNotGoing()
	else
		self._outRoomId = Scheduler:delayCall(10,function ()
			self:outRoomWithGameNotGoing()
		end)
	end
end

--发牌
function KanMyself:sendCardAnim()
	
	self.cards_panel:setVisible(true)
	local tx        = self.cards_panel:getPositionX()
	local ty        = self.cards_panel:getPositionY()
	local card_tmp  = Card.new()
	local size      = card_tmp:getContentSize()
	local alllength = 4*15+size.width*5

	local panelsize   = self.cards_panel:getContentSize()
	local start_width =  (alllength-panelsize.width)/2
	MusicPlayer:playMyEffectGames(Niuniu_Games_res,"FLIP")
	self.cards_content:removeAllChildren()
	self._cards={}
	for i=1,5 do
		
		local card_tmp  = Card.new()
		table.insert(self._cards,card_tmp)
		self.cards_content:addChild(card_tmp,0)
		card_tmp:setScale(0.7)
		-- card_tmp:setPosition(tx+KanMyself.Card_Center['x'],ty+KanMyself.Card_Center['y'])
		
		card_tmp:setPosition(Display.cx/2-tx,Display.cy/2-ty)
		-- card_tmp:setAnchorPoint(cc.p(0,0))
		if self._info.card[i] then
			card_tmp:setValue(self._info.card[i])
		end

		local delay     = cc.DelayTime:create(KanMyself.Card_Anim_Space*(5-i))
		local move      = cc.MoveTo:create(KanMyself.Card_Anim_Time,cc.p(20,80))
		local scale     = cc.ScaleTo:create(KanMyself.Card_Anim_Time,1.2)
		local spawn     = cc.Spawn:create(move,scale)
		local delay_1ms = cc.DelayTime:create(KanMyself.Card_Anim_Time)
		local move_line = cc.MoveTo:create(KanMyself.Card_Anim_Time,cc.p(size.width/2+(size.width+30)*(i-1)-start_width,80))
		local call      = cc.CallFunc:create(function ()
			-- body
			if self._info.card[i] then
				card_tmp:flip()
				MusicPlayer:playMyEffectGames(Niuniu_Games_res,"FLIP")
			end
		end)
		local sq        = cc.Sequence:create(delay,spawn,delay_1ms,move_line,call)

		card_tmp:runAction(sq)
	end
end

function KanMyself:stopSendCardAnim()
	if type(self.cards) == "table" then
		for i, v in ipairs(self.cards) do
			v:stopAllActions()
			v:removeFromParent()
		end
		self.cards = {}
	end
end

--翻开第五章牌
function KanMyself:fiveCard()
	if tolua.isnull(self) == false and self._cards and tolua.isnull(self._cards[5]) == false then
		self._cards[5]:setValue(Cache.kandesk.last_card)
		self._cards[5]:flip()
	end
end

--出牌完成
function KanMyself:sendCard(ptype)
	self.niu_img:setVisible(true)
	self.niu_img:loadTexture(Niuniu_Games_res['Kan_niu_'..tostring(ptype)],ccui.TextureResType.plistType)
	if ptype == 0 then
		for k,v in pairs(self._cards) do
			v:dark()
		end
	end

	for k,v in pairs(self._cards) do
		if tolua.isnull(v) == false then
			v:stopAllActions()
			v:setPositionY(80)
		end
	end
end



--
function KanMyself:clear( )
	-- body
	self.cards_content:removeAllChildren()
	self._cards = {}
	self.cards_panel_small_cards:removeAllChildren()
	self.bQiang = false
	self.cards_panel:setVisible(false)
	self.zhuang:setVisible(false)
	self.buqiang:setVisible(false)
	self.qiang:setVisible(false)
	self.niu_bg:setVisible(false)
	self.niu_img_small:setVisible(false)

	self.niu_img:setVisible(false)
	self.base:setVisible(false)

	
end



--断线重连、
function KanMyself:reconnect()

	if self._info.status  >= 1081 and #self._cards <= 0  and Cache.kandesk._player_info[self._uin].draw == 1 then
		-- self._info.draw = 1  --标示已经绘制了牌桌的信息了
		self:stopSendCardAnim()
		self.cards_panel:setVisible(true)
		local tx        = self.cards_panel:getPositionX()
		local ty        = self.cards_panel:getPositionY()
		local card_tmp  = Card.new()
		local size      = card_tmp:getContentSize()
		local alllength = 4*15+size.width*5

		local panelsize   = self.cards_panel:getContentSize()
		local start_width =  (alllength-panelsize.width)/2
		MusicPlayer:playMyEffectGames(Niuniu_Games_res,"FLIP")
		self.cards_content:removeAllChildren()
		self._cards={}
		for i=1,5 do
			local card_tmp  = Card.new()
			table.insert(self._cards,card_tmp)
			self.cards_content:addChild(card_tmp,0)
			if self._info.card[i] then
				card_tmp:setValue(self._info.card[i])
				card_tmp:showFront()
			end
			card_tmp:setScale(1.2)
			-- card_tmp:setPosition(tx+KanMyself.Card_Center['x'],ty+KanMyself.Card_Center['y'])
			card_tmp:setPosition(size.width/2+(size.width+30)*(i-1)-start_width,80)
		end

		if Cache.kandesk.zhuang_uin == self._uin then
			self:showZhuang()
		end

		if self._info.status == 1081 then
			self._parent_view:showQiangBase()
        	self._parent_view:timeCount(1,Cache.kandesk.left_time - 1)
		end 

		if self._info.status == 1082 then
			self:qiangFuc(self._info.grab_score)
		end

		if self._info.status == 1083 then
			if Cache.kandesk.zhuang_uin ~= self._uin then
				self._parent_view:showXiaFen()
			end
			self._parent_view:timeCount(2,Cache.kandesk.left_time -1)
		end

		if self._info.status == 1084 then
			self:qiangFuc(self._info.grab_score)
			if Cache.kandesk.zhuang_uin ~= self._uin then
				self:showBase(self._info.callscore_time)
			end
		end

		if self._info.status == 1085 then
			self._parent_view:USER_LAST_CARD(1,Cache.kandesk.left_time - 1)
		end

		if self._info.status == 1086 then
			self:sendCard(self._info.card_type)
		end
	end

	-- local panel  = self._parent_view.root:getChildByName("notice_panel_0")
	-- local myfont = panel:getChildByName("notice")
	
	if  Cache.kandesk.status>= 1 and  self._info.status  == UserStatus.USER_STATE_READY then
		self._parent_view:showTips(Niuniu_GameTxt.Game_started)
	else
		self._parent_view:showTips("")
	end



end



--显示牌
function KanMyself:showCard()
	-- body
	local info   = Cache.kandesk._result_info[self._uin]

	MusicPlayer:playMyEffectGames(Niuniu_Games_res,"NIU_"..tostring(self:getSexByCache(self._uin))..'_'..tostring(info.card_type))
	self.cards_panel:setVisible(false)
	self.niu_img:setVisible(false)
	self.cards_panel_small_cards:setVisible(true)
	self.cards_panel_small:setVisible(true)

	local tx = self.cards_panel_small_cards:getPositionX()
	local ty = self.cards_panel_small_cards:getPositionY()


	local tx1 = self.cards_panel_small:getPositionX()
	local ty1 = self.cards_panel_small:getPositionY()

	self._cards      = {}

	local card_tmp  = Card.new()
	local size      = card_tmp:getContentSize()

	local alllength = (4*55+size.width)*0.7+10
	local panelsize = self.cards_panel_small_cards:getContentSize()
	local start_width =  (panelsize.width - alllength)/2
	start_width = size.width/2*0.8+start_width



	for i=1,5 do
		local card_tmp  = Card.new()
		-- table.insert(self._cards,card_tmp)
		self.cards_panel_small_cards:addChild(card_tmp)
		card_tmp:setValue(info.card[i])
		card_tmp:setScale(0.7)
		if info.card_type == 0  or  info.card_type > 10 then
			card_tmp:setPosition(cc.p((i-1)*50+size.width*0.7/2,size.height*0.7/2))
		end
		if info.card_type >=1 and info.card_type<=10 then
			if i <=3 then
				card_tmp:setPosition(cc.p((i-1)*50+size.width*0.7/2,size.height*0.7/2))
			else
				card_tmp:setPosition(cc.p((i-1)*50+size.width*0.7/2+30,size.height*0.7/2))
			end
		end
		

		card_tmp:flip()
		if info.card_type == 0 then
			card_tmp:dark()
		else
			self.niu_bg:setVisible(true)
		end
	end

	self.niu_img_small:loadTexture(Niuniu_Games_res['Kan_niu_'..tostring(info.card_type)],ccui.TextureResType.plistType)
	self.niu_img_small:setVisible(true)

	if info.card_type ~= 0 then
		local tx1 = self.niu:getPositionX()
		local ty1 = self.niu:getPositionY()
		local tx2 = self.niu_img_small:getPositionX()
		local ty2 = self.niu_img_small:getPositionY()
		self._parent_view.Gameanimation:play({order=10,anim=GameAnimationConfig.CHU,node=self.cards_panel_small,position=cc.p(tx1+tx2,ty1+ty2)})
	end
end



function KanMyself:updateGiftBtn(paras)
    local btn_gift = ccui.Helper:seekWidgetByTag(self,KanMyself.GIFTBTN)
    if self.disable_gift and btn_gift:isVisible() then
        btn_gift:setVisible(false)
    else
        local updateBtn = function()
    		-- body
    		qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = btn_gift,icon = paras})
    	end
    	if paras and paras >=2000 and paras<2006 then
    		qf.event:dispatchEvent(ET.SHOW_GIFTCAR_ANI,{id =paras,txt=self._info.nick,pos=btn_gift:getWorldPosition(),cb=updateBtn})
    	else
        	updateBtn()
    	end
        local u = Cache.kandesk:getUserByUin(self.uin)
        if u and u.decoration == -1 then --如果当前的用户礼物是空的，就改变其为最新的
           u.decoration = paras
        end
    end
end

function KanMyself:checkShowCard()
	self.cards_panel:setVisible(true)
	if self._cards == nil or #self._cards == 0 or (self._cards[1] and tolua.isnull(self._cards[1]) == true) then
		local card_tmp  = Card.new()
		local size  = card_tmp:getContentSize()
		local alllength = 4*15+size.width*5
		local panelsize   = self.cards_panel:getContentSize()
		local start_width =  (alllength-panelsize.width)/2
		self.cards_content:removeAllChildren()
		self.cards_content:setVisible(true)
		self._cards={}
		for i=1,5 do
			local card_tmp  = Card.new()
			local size  = card_tmp:getContentSize()
			table.insert(self._cards,card_tmp)
			self.cards_content:addChild(card_tmp,0)
			if self._info.card[i] then
				card_tmp:setValue(self._info.card[i])
				card_tmp:showFront()
			end
			card_tmp:setScale(1.2)
			card_tmp:setPosition(size.width/2+(size.width+30)*(i-1)-start_width,80)
		end
	else
		for i, v in ipairs(self._cards) do
			v:setVisible(true)
		end
	end
end

-- function KanMyself:setWaitingStartVis(bvis)
-- 	self.showWaitingStart:setVisible(bvis)
-- 	self.gold:setVisible(not bvis)
-- 	self.goldImg:setVisible(not bvis)
-- end

function KanMyself:playShowChatMsg(txt_layer, msg)
	local chatnode = txt_layer:playShowChatMsg(self, self.icon, {
        corner = GameConstants.CORNER.LEFT_DOWN,
        -- offset = {x = -47, y = -21},
		msg = msg,
		chatname = "myself"
	})
	self.chatnode = node
	-- self:emoji(1)
end

return KanMyself