local GameView      = class("GameView", qf.view)
local Chat          = require("src.common.Chat")
local Myself        = import(".components.user.Myself")
local User          = import(".components.user.User")
local Handlebutton  =  import(".components.button.Handlebutton")
local Useranimation = import(".components.user.Useranimation")
local Gameanimation = import(".components.animation.Gameanimation")
local GameAnimationConfig = import(".components.animation.AnimationConfig")
local Dila          = import(".components.user.Dila")
local Chip = import(".components.chip.Chip")
local BeautyEnterAnimat = import(".components.BeautyEnterAnimat")
local Card          =  import("src.games.game_zjh.modules.game.components.card.Card")

GameView.TAG ="ZJHGameview"
GameView.WINNUM     	   = 0  --连胜纪录



GameView.Xiala       =  152
GameView.Shop        =  153
GameView.Chat        =  175
GameView.Xiala_panel =  213
GameView.Back        =  214
GameView.Detail      =  222
GameView.Detail_img  =  224
GameView.Desk_info   =  154
GameView.Base_info   =  155
GameView.Changciinfo =  156
GameView.Desk_gold   =  161
GameView.Desk_turns  =  162
GameView.Change      = "change"
GameView.Dila        =  "dila"  --荷官图片
GameView.Kiss        =  "kiss"  --飞吻按钮
GameView.Start       =  351
GameView.Mine_panel = 163  --操作按钮容器
GameView.Anima_layout = 508

function GameView:ctor(parameters)
	--if not parameters then return end
	logd("zjhGameView:ctor() "..os.clock())
    self.super.ctor(self,parameters)
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_INGAME_POS)
    self.winSize = cc.Director:getInstance():getWinSize()
    self._users             = {}
    self.showcardUser={}
    self.slLeadView = nil
    self.haveSetDaptive = false
	self:init()
    self:initAnimation()
    self:initButton()
    self:initMenu()

	if Util:checkWifiNetPackage() then
        self:refreshNetStrength()
    else
        self:showDeviceStatus()
    end
	self:fullScreenAdaptive()
	self.Xiala_panel:setVisible(false)
end

function GameView:onEnter( ... )
	-- body
end

--显示电池电量和时间
function GameView:showDeviceStatus( ... )
	-- body
	self.deviceStatus = CommonWidget.DeviceStatus.new({layer = self._device_layer})
	self.deviceStatus:startDeviceStatusMonitor()	--开始检测设备状态(电池电量, 网络信号)
end

function GameView:fullScreenAdaptive( ... )
	-- body
	if FULLSCREENADAPTIVE and not self.haveSetDaptive then
		self.haveSetDaptive = true
		Util:adaptIphoneXPos(self)
		if self.Shop then
			self.Shop:setPositionX(self.Shop:getPositionX()+(self.winSize.width/2-1920/2))
		end
		
        if self.Chat then
        	-- self.Chat:setVisible(false) --qf3屏蔽
        	self.Chat:setPositionX(self.Chat:getPositionX()-(self.winSize.width/2-1920/2))
        end
        
        -- if self._chat then
        -- 	self._chat:setVisible(false) --qf3屏蔽
        -- 	self._chat:setPositionX(self._chat:getPositionX()-(self.winSize.width/2-1920/2))
		-- end
		
        if self.gameChestPop then
	        self.gameChestPop:setPositionX(self.gameChestPop:getPositionX()+(self.winSize.width/2-1920/2))
	    end
	    if self.detail_panel then
	    	self.detail_panel:setPositionX(self.detail_panel:getPositionX()-(self.winSize.width/2-1920/2))
	    end
	    if self.Xiala then
	    	self.Xiala:setPositionX(self.Xiala:getPositionX()-(self.winSize.width/2-1920/2))
	    end
        
        if self.Xiala_panel then
        	self.Xiala_panel:setPositionX(self.Xiala_panel:getPositionX()-(self.winSize.width/2-1920/2))
        end
        
        if self.pkCloseP then
        	self.pkCloseP:setPositionX(self.pkCloseP:getPositionX()-(self.winSize.width/2-1920/2))
        	self.pkCloseP:setContentSize(self.pkCloseP:getContentSize().width+self.winSize.width-1920,self.pkCloseP:getContentSize().height)
        end
    	
    	if self._device_layer then
    		self._device_layer:setPositionX(self._device_layer:getPositionX()-(self.winSize.width/2-1920/2))
		end
		self.deskIDTxt:setPositionX(self.deskIDTxt:getPositionX()+(self.winSize.width/2-1920/2))
    end
end

function GameView:noGoldCheck( ... )
	if not Cache.packetInfo:isShangjiaBao() then return end
	if Cache.user.gold < self.limit_gold then
		qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = string.format(Util:getReviewStatus() and GameTxt.string_room_limit_5 or GameTxt.string_room_limit_4, Util:getFormatString(self.limit_gold), Cache.packetInfo:getShowUnit()), confirmCallBack = function ( ... )
	        if Util:getReviewStatus() then
	            qf.event:dispatchEvent(ET.SHOP)
	        else
	            Cache.user.guidetochat = true
	            qf.event:dispatchEvent(Zjh_ET.RE_QUIT)
	        end
	    end})
	end
end

--
function GameView:chageBgImg(thisroom)
	print("this room >>>>>>>>")
	dump(thisroom)

	if thisroom == nil then
		return
	end

	-- body
	logd("zjhGameView:chageBgImg() begin "..os.clock())
	print("设置牌桌背景图片 。。。。。。。")
	print(" >>>>>>>>>>>>>> room_group", room_group)
	local bRed = thisroom.room_color == GameConstants.ZJH_DESKCOLOR.RED
	if bRed then
		ccui.Helper:seekWidgetByName(self.gui,GameView.Dila):loadTexture(string.format(Zjh_Games_res.DILA,15),ccui.TextureResType.plistType)
		gamebg = Zjh_Games_res.REDGAMEBG
		ccui.Helper:seekWidgetByName(self.gui, "desk"):setVisible(true)
		ccui.Helper:seekWidgetByTag(self.gui,155):setColor(cc.c3b(243, 131, 112))
		ccui.Helper:seekWidgetByTag(self.gui,156):setColor(cc.c3b(255, 201, 117))
		ccui.Helper:seekWidgetByTag(self.gui,161):setColor(cc.c3b(252,244,196))
		ccui.Helper:seekWidgetByTag(self.gui,162):setColor(cc.c3b(243, 131, 112))
		ccui.Helper:seekWidgetByTag(self.gui,160):loadTexture(Zjh_Games_res.CHIPICON0,ccui.TextureResType.plistType)
	else
		gamebg = Zjh_Games_res.BLUEGAMEBG
		ccui.Helper:seekWidgetByTag(self.gui,155):setColor(cc.c3b(255, 241, 85))
		ccui.Helper:seekWidgetByTag(self.gui,156):setColor(cc.c3b(22, 27, 71))
		ccui.Helper:seekWidgetByTag(self.gui,161):setColor(cc.c3b(252, 244, 196))
		ccui.Helper:seekWidgetByTag(self.gui,162):setColor(cc.c3b(255, 241, 85))

		ccui.Helper:seekWidgetByName(self.gui, "desk"):setVisible(false)
		ccui.Helper:seekWidgetByTag(self.gui,160):loadTexture(Zjh_Games_res.CHIPICON1,ccui.TextureResType.plistType)
		ccui.Helper:seekWidgetByName(self.gui,GameView.Dila):loadTexture(string.format(Zjh_Games_res.DILA,14),ccui.TextureResType.plistType)
	end
	ccui.Helper:seekWidgetByName(self.gui, "deskBg"):loadTexture(gamebg)
	self:initMenu()
	logd("zjhGameView:chageBgImg() end "..os.clock())
end


function GameView:init()
	self.gui                = ccs.GUIReader:getInstance():widgetFromJsonFile(Zjh_Games_res.ZjhJsonView)
	self:addChild(self.gui)
	
	-- self.autoWaitBtn=ccui.Helper:seekWidgetByName(self.gui,"autositdown")--自动坐下按钮
	-- self.autoWaitText=ccui.Helper:seekWidgetByName(self.autoWaitBtn,"autowaittext")
	-- self.sitwaitP=ccui.Helper:seekWidgetByName(self.gui,"sitwaitP")--坐下按钮
	-- self.sitwaitText=ccui.Helper:seekWidgetByName(self.sitwaitP,"waittext")

	self.startTimeBg=ccui.Helper:seekWidgetByName(self.gui,"starttime")
	self.startTime=ccui.Helper:seekWidgetByName(self.gui,"time")
	--结束游戏动画
	self.show_card_bgpanel = ccui.Helper:seekWidgetByName(self.gui,"show_card_panel") --背景层
	self._device_layer = ccui.Helper:seekWidgetByName(self.gui,"_device_layer") --时间和电量背景层
	self.deskIDTxt = ccui.Helper:seekWidgetByName(self.gui, "deskIDTxt")
	-- self.chat_layer = ccui.Helper:seekWidgetByName(self.gui,"chat_layer") --时间和电量背景层
	-- self.chat_layer:setLocalZOrder(5)
	self:initChatUI()
end


--用户比牌丢金币
function GameView:userCompare(model)
	-- body
	--------------
	self:initAnimation()
	---------------
	if self._users[model.uin] ~=nil then
		self._users[model.uin]:compareCard(model)
	end
	if Cache.zjhdesk._player_info[model.uin] and Cache.zjhdesk._player_info[model.uin].gold==0 then--孤注一掷
		MusicPlayer:playMyEffectGames(Zjh_Games_res,"GUZHUYIZHI_SOUND_"..self._users[model.uin]:getSexByCache(model.uin))
		--孤注一掷动画
		local guzhuyizhi=self.Gameanimation:play({anim=GameAnimationConfig.GUZHUYIZHI,position={x=Display.cx/2,y=Display.cy*0.6},scale=2})
		Scheduler:delayCall(1,function ()
			guzhuyizhi:runAction(cc.Spawn:create(cc.ScaleTo:create(0.3,1.2),cc.MoveTo:create(0.3,cc.p(Display.cx*0.7,Display.cy*0.9)),cc.FadeIn:create(0.3)))
		end)
	end
end


function GameView:showStart()
	-- body
	--设置按钮功能与游戏类型
	--退出
	print("showStart ")
	-- self.quit_btn:setEnabled(true)
	-- self.quit_btn:setTouchEnabled(true)
	addButtonEvent(self.quit_btn,function ()
		-- print("quit_btn XXXXX  YYYY")
		-- body
		ModuleManager:removeExistView()
		ModuleManager.zjhglobal:show()
        ModuleManager.zjhhall:show()
	end)
	-- Util:enlargeBtnClickArea(self.quit_btn, {x = 1.4, y = 2})
	Cache.DeskAssemble:setGameType(GAME_ZJH) 
end


--下局开始倒计时
function GameView:startTimeCount()
	-- body
	if Cache.zjhdesk.status == 0 and Cache.zjhdesk:getUsersNum() == 1 then
		return
	end
	loga("-----炸金花下一局开始时间" .. Cache.zjhdesk.start_time)
	self.time = Cache.zjhdesk.start_time - 2
	if self.time <= 1 then
		self.startTimeBg:setVisible(false)
	else
		self.startTimeBg:setVisible(true)
		self.startTime:setString(self.time)
	end
	if self.sid then
		Scheduler:unschedule(self.sid)
		self.sid=nil
	end

	self:CHUOHE_CLOSE()
	self.sid = Scheduler:scheduler(1,function ()
		-- body
		if self.time == nil then
			Scheduler:unschedule(self.sid)
			self.sid = nil
			return
		end
		self.time = self.time - 1
		if self.time < 0 or Cache.zjhdesk.status==1 then
			Scheduler:unschedule(self.sid)
			self.sid=nil
			self.startTimeBg:setVisible(false)
		else
			self.startTime:setVisible(true)
			self.startTime:setString(self.time)
			self.startTime:setVisible(false)
			local startTime=self.startTime:clone()
			self.startTimeBg:addChild(startTime)
			startTime:setVisible(true)
			startTime:setString(self.time)
			startTime:setScale(0.7)
			startTime:runAction(cc.Sequence:create(
				cc.Spawn:create(cc.ScaleTo:create(0.5,1.6),cc.FadeOut:create(0.5)),
				cc.CallFunc:create(function( ... )
					-- body
					startTime:removeFromParent()
				end)
				))
		end
	end)
	-- self.Xiala_panel:setVisible(false)
end


--游戏结算
function GameView:gameEnd()
	--------------
	self:initAnimation()
	---------------
	local uin   = Cache.zjhdesk.winner
	local chips 
	if self._users[uin]~=nil then
		chips = Cache.zjhdesk._player_info[uin].win_money
	end
	--开始倒计时 暂时隐藏
	if Cache.zjhdesk:getUsersNum() > 1 then
		self:startTimeCount()
		self.startTimeBg:setVisible(false)
	end

	if uin == Cache.user.uin then
		Cache.zjhdesk.WINNUM=Cache.zjhdesk.WINNUM+1
		if Cache.zjhdesk.WINNUM==3 and Cache.zjhdesk.WINTYPE<1 then Cache.zjhdesk.WINTYPE=1
		elseif Cache.zjhdesk.WINNUM==5 and Cache.zjhdesk.WINTYPE<2 then Cache.zjhdesk.WINTYPE=2
		elseif Cache.zjhdesk.WINNUM==10 then Cache.zjhdesk.WINTYPE=3
		end
	else
		Cache.zjhdesk.WINNUM=0
	end

	if self._users[uin]==nil then
		for i=1,3 do
			for k,v in pairs(self["chips_area_"..i]:getChildren())	do
				local hide=cc.FadeOut:create(0.5)
				local call = cc.CallFunc:create(function()
				if v then
					v:removeFromParent()
				end
				end)
				v:runAction(cc.Sequence:create(hide,call))
			end
		end
	elseif self._users[uin] ~=nil then
		--收金币
		Scheduler:delayCall(2.5,function()

			if tolua.isnull(self) == true then
				return
			end

			self._users[uin]:collectGold()	
			self._users[uin]:showWinnerAni()
		end)

		--收金币后1s玩家显示赢了多少钱
		Scheduler:delayCall(3.5,function()
			if tolua.isnull(self) == true then
				return
			end
			if self._users[uin] and Cache.zjhdesk.status==0 then
				self._users[uin]:winMoneyFly({chips=chips})
			else
            	self:reconnectUsers()
			end
		end)

		--播放赢钱动画
		if uin == Cache.user.uin then
			Scheduler:delayCall(2.5,function()
				if Cache.zjhdesk.status==0 then
					if tolua.isnull(self) ==  false then
						self.Gameanimation:play({anim=GameAnimationConfig.YOUWIN,order=101,scale=2})
						MusicPlayer:playMyEffectGames(Zjh_Games_res,"WINGAME")
					end
				end
			end)			
		end

		--动画播放完了  显示倒计时
		Scheduler:delayCall(4,function ( ... )
			-- body
			if tolua.isnull(self) == true then
				return
			end

			if Cache.zjhdesk.status==0 and Cache.zjhdesk:getUsersNum() ~= 1 then
				self.startTimeBg:setVisible(true)
				self:CHUOHE_CLOSE()
			end

			--检测去掉桌上还有的筹码
			for i=1,3 do
				for k,v in pairs(self["chips_area_"..i]:getChildren())	do
					local hide=cc.FadeOut:create(0.5)
					local call = cc.CallFunc:create(function()
					if v then
						v:removeFromParent()
					end
					end)
					v:runAction(cc.Sequence:create(hide,call))
				end
			end
		end)
	end

	--自己打开牌
	if self._users[Cache.user.uin] then
		self._users[Cache.user.uin]:hideHandleButtonNoAnimate(true) --结束了 把操作面板关掉
		self._users[Cache.user.uin]:openCard()
	end

	--赢了的人显示是否是三条或者同花顺
	Scheduler:delayCall(0,function ( ... )
		if tolua.isnull(self) == true then
			return
		end
		-- body
		if self._users[uin] and Cache.zjhdesk.status==0 then
			self._users[uin]:showBigType()
		else 
			self:reconnectUsers()
		end
	end)

	--判断是否需要亮牌了(被动亮牌)
	for k,v in pairs(self._users) do
		if v._info.showcard == 1 then
			local user={}
			if v.user_info_panel then
				x=v:getPositionX()+v.user_info_panel:getPositionX()-52
				y=v:getPositionY()+v.user_info_panel:getPositionY()-15
			else
				x=v:getPositionX()-52
				y=v:getPositionY()-15
			end 
			user.ifwin= Cache.zjhdesk.winner == k and true  or false
			user.gold 		=v._info.gold
			user.card_type	=v._info.card_type
			user.card 		=v._info.card
			user.x  		=x
			user.y  		=y
			user.node 		=v
			table.insert(self.showcardUser,user)
		end

		Scheduler:delayCall(2.5,function ( ... )
			if tolua.isnull(self) == true then
				return
			end
			v:clear()
		end)


		Scheduler:delayCall(2.5,function ( ... )
			if tolua.isnull(self) == true then
				return
			end

			-- body
			if Cache.zjhdesk.status==0 then
				v:SetPlayerLight(false)
			else
				v:reconnect()
			end
		end)
		v:showChipAndGold()
	end

	--这个应该是主动亮牌
	for k,v in pairs(self.showcardUser) do
		Scheduler:delayCall(0,function ( ... )
			if tolua.isnull(self) == true then
				return
			end
			if Cache.zjhdesk.status == 0 then
				self:showCardAnimate(v.ifwin,v.gold,v.card_type,v.card,{x=v.x,y=v.y},v.seatid)
				v.node:clear()
			end
		end)
	end
end

--结束动画(输或赢、金币数、牌型)
function GameView:showCardAnimate(iswin,goldnum,cardtype,cardinfo,pos,seatid)
	local show_card_bgpanel = self.show_card_bgpanel:clone()
	if seatid then 
		pos = self:getUserPos(seatid)
	end
	show_card_bgpanel:setPosition(pos.x,pos.y)
	self.gui:addChild(show_card_bgpanel,4)
	local show_card_panel   = ccui.Helper:seekWidgetByName(show_card_bgpanel,"card_panel") --牌层
	local show_card_gold    = ccui.Helper:seekWidgetByName(show_card_bgpanel,"gold") --金币
	local show_card_kind    = ccui.Helper:seekWidgetByName(show_card_bgpanel,"card_kind") --牌类型
	local show_win_kuang	= ccui.Helper:seekWidgetByName(show_card_bgpanel,"win_kuang") --赢框
	if not cardtype then return	end
	MusicPlayer:playMyEffectGames(Zjh_Games_res,"FLIP")
	if iswin==false then
		show_win_kuang:setVisible(false)
		show_card_kind:setVisible(false)
	else
		show_win_kuang:setVisible(true)
		show_card_kind:setVisible(true)
		show_card_kind:loadTexture(self:getCardTypeImg(cardtype),ccui.TextureResType.plistType)
		--赢了外面闪个框
		local win_kuang=show_win_kuang:clone()
		win_kuang:setPosition(show_win_kuang:getPosition())
		win_kuang:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.Spawn:create(cc.ScaleTo:create(0.3,3.0),cc.FadeOut:create(0.3)),cc.CallFunc:create(function()
			-- body
		win_kuang:removeFromParent()
		end)))
		show_card_bgpanel:addChild(win_kuang) 
	end
	show_card_gold:setString(Util:getFormatString(Cache.packetInfo:getProMoney(goldnum)))
	show_card_bgpanel:setVisible(true)

	local cards = self:cardRank(cardinfo)
	
	for i=1,3 do
		local card_tmp  = Card.new()
		show_card_panel:addChild(card_tmp,0)
		if cards==nil then 
			show_card_bgpanel:removeFromParent()
			return 
		end
		card_tmp:setValue(cards[i])
		local cardConX=card_tmp:getContentSize().width*0.6
		local cardConY=card_tmp:getContentSize().height*0.7
		card_tmp:setPosition(cc.p(cardConX/2+35,cardConY/2))
		
		local draw		= cc.OrbitCamera:create(0.2, 1, 0, 0, -180, 0, 0)
		local jump		= cc.JumpBy:create(0.2,cc.p(0,0),20,1)
		local jump_draw = cc.Spawn:create(draw,jump)
		local showfront = cc.CallFunc:create(function()
			-- body
			card_tmp:showFront()
			card_tmp:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
		end)
		local moveright = cc.EaseBackOut:create(cc.MoveTo:create(0.4,cc.p(cardConX*(0.5+0.63*(i-1))+35,cardConY/2)))
		local delay3 	= cc.DelayTime:create(1.9)
		local removecard= cc.CallFunc:create(function()
			-- body
			show_card_bgpanel:removeFromParent()
		end)
		--移动到一起，等待使时间一致，跳一下并翻转，显示正面、移动到最终位置
		local sq        = cc.Sequence:create(jump_draw,showfront,moveright,delay3,removecard)
		card_tmp:runAction(sq)
	end
		
end

function GameView:cardRank(cardsValue)--排序
	local cards={}
	local value=0
	if not cardsValue then return end
	for i=1,#cardsValue do
		value=cardsValue[i]
		table.insert(cards,value)
	end
	for i=1,#cards do
		for j=i+1,#cards do
			if self:getCardValue(cards[j])==1 or self:getCardValue(cards[i])<self:getCardValue(cards[j]) and self:getCardValue(cards[i]) ~=1 then
				value=cards[j]
				cards[j]=cards[i]
				cards[i]=value
			end
		end
	end

	return cards
end

function GameView:getCardValue(value)
		-- body
		local i,t = math.modf(value/4)
	    i = i + 1
	    if i == 14 then i = 1 end

	    value= i
	    
	    return value
end

function GameView:getCardTypeImg(cardvalue)--获得牌的类型
	-- body

	cardvalue = tonumber(cardvalue)
	local file 
	if cardvalue==0 then--高牌
		file= Zjh_Games_res.CardType_1
	elseif cardvalue==1 then--对子
		file= Zjh_Games_res.CardType_2
	elseif cardvalue==2 then--顺子
		file= Zjh_Games_res.CardType_3
	elseif cardvalue==3 then--同花
		file= Zjh_Games_res.CardType_4
	elseif cardvalue==4 then--同花顺·
		file= Zjh_Games_res.CardType_5
	elseif cardvalue==5 then--三条
		file= Zjh_Games_res.CardType_6
	end

	return file
end

--delete遮罩
function GameView:unmaskLayer()
	if self:getChildByName("maskLayer") then
		self:removeChildByName("maskLayer")
	end
end

--初始化动画类
function GameView:initAnimation()
	if self.Gameanimation then
		return 
	end
	self.animation_layout  =  cc.Layer:create()
	self:addChild(self.animation_layout)
	self.animation_layout:setZOrder(101)
	self.Gameanimation     =  Gameanimation.new({view=self,node=self.animation_layout})  --初始化动画	
end

--去除上个玩家的时间条
function GameView:removeTimer()
	if self._users[Cache.zjhdesk.next_uin]~=nil then
		self._users[Cache.zjhdesk.next_uin]:removeTimer()
	end			
end

--用户弃牌
function GameView:userFold(model)
	if self._users[model.uin] ~=nil then
		self._users[model.uin]:userFold()
		self._users[model.uin]:SetPlayerLight(true)
		if model.uin == Cache.user.uin then
			self:cancelPkkuang()
			self:setChangeStatus()
		end
	end

end


--去除所有玩家的pkkuang
function GameView:cancelPkkuang(paras)
	for k,v in pairs(self._users) do
		if v then 
			v:cancelPkkuang()
		end
	end

	if Cache.zjhdesk.status~=nil and Cache.zjhdesk.status > 0 then
		if Cache.zjhdesk.iscompare == 1 then
			if self._users[Cache.user.uin] then 
				self._users[Cache.user.uin]:hideHandleButtonNoAnimate(true)
			end
			local NowPlayer=0
			for k,v in pairs(self._users) do
				if Cache.zjhdesk._player_info[k] and Cache.zjhdesk._player_info[k].status>1020 and Cache.zjhdesk._player_info[k].status~=1050 and Cache.zjhdesk._player_info[k].compare_failed~=1 then
					NowPlayer=NowPlayer+1
				end
			end
			if NowPlayer>=2 and Cache.zjhdesk.lost_uin~=Cache.user.uin and self:isMePlayer() then
				--self._users[Cache.user.uin]:showHandleButton()
			else
				--self._users[Cache.user.uin]:hideHandleButtonNoAnimate(true)
				self:setChangeStatus()
				if NowPlayer<2 then
					if self._users[Cache.user.uin] then
						self._users[Cache.user.uin].look:setVisible(false)
					end
				end
			end
		elseif self:isMePlayer() then
			self._users[Cache.user.uin]:showHandleButton()
		end
	end
end

function GameView:initChatUI()
	self._chat = Chat.new({view=self, ChatCmd = CMD.CHAT})
	self:addChild(self._chat, 300)
    self.chat_txt_layer = self._chat:getChatTxtLayer()
	self:addChild(self.chat_txt_layer, 2)

	--聊天
	self.Chat = Chat.getChatBtn()
	self.Chat:setVisible(true)
	self:addChild(self.Chat)
	-- self.Chat:setPosition(cc.p(80, 63))
	self.Chat:setPosition(cc.p(1838, 203))
	addButtonEvent(self.Chat,function ( )
        -- local myUin = Cache.user.uin
        -- local user = Cache.lhdDesk:getUserByUin(myUin)
        if not Cache.zjhdesk:checkMeDown() then
        --无座 且自己不是庄家
        -- if (user and user.seatid == -1) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.chat_pangguan_txt})
            return 
		end
		-- body
		self._chat:show()
	end)
	-- self._chat:show()
	-- print("zxcvzxvzxcv")
    if FULLSCREENADAPTIVE then
		Util:setPosOffset(self._chat, {x =self.winSize.width/2-1920/2, y = 0})
        Util:setPosOffset(self.Chat, {x =self.winSize.width-1920, y = 0})
	end
end

function GameView:initMenu(room_group)
	--下拉菜单按钮
	self.Xiala = ccui.Helper:seekWidgetByName(self.gui,"back")
	--下拉菜单
	self.Xiala_panel = ccui.Helper:seekWidgetByName(self.gui,"quit_panel")
	self.Xiala_panel:setZOrder(102)
	self.Xiala_panel:removeAllChildren()
	local img = ccui.ImageView:create(Zjh_Games_res.menu_guang)
	img:setName("menu_guang")
	img:setAnchorPoint(cc.p(0,0))
	self.Xiala_panel:addChild(img)
	self.back=nil
	self.safebox=nil
	self.detail=nil
	self.standup=nil

	local menuTbale={}
	self.menuItem = ccui.Helper:seekWidgetByName(self.gui,"quititemP")
	self.menuItem:setLocalZOrder(2)
	self.menuItem:setVisible(true)
	
	if self.backP and tolua.isnull(self.backP) == false then
		self.backP:removeFromParent()
		self.backP = nil
	end
	self.backP=self.menuItem:clone()
	self.back=self.backP:getChildByName("quit")
	self.back:setBackGroundImage(Zjh_Games_res.menu_newback)
	table.insert(menuTbale,self.backP)
	--back

	-- if Cache.zjhdesk.view_table~=1 or Cache.zjhdesk.can_not_change_table~=1 then
		if self.safeboxP and tolua.isnull(self.safeboxP) == false then
			self.safeboxP:removeFromParent()
			self.safeboxP = nil
		end
		self.safeboxP=self.menuItem:clone()
		self.safebox=self.safeboxP:getChildByName("quit")
		self.safebox:setBackGroundImage(Zjh_Games_res.menu_newbank)
		table.insert(menuTbale,self.safeboxP)
	-- end

	if  Cache.zjhdesk.view_table==1 then
		if self.standupP and tolua.isnull(self.standupP) == false then
			self.standupP:removeFromParent()
			self.standupP = nil
		end
		self.standupP=self.menuItem:clone()
		self.standup=self.standupP:getChildByName("quit")
		self.standup:setBackGroundImage(Zjh_Games_res.menu_newstandup)
		table.insert(menuTbale,self.standupP)
	end

	if self.DetailP and tolua.isnull(self.DetailP) == false then
		self.DetailP:removeFromParent()
		self.DetailP = nil
	end
	self.DetailP=self.menuItem:clone()
	self.detail=self.DetailP:getChildByName("quit")
	self.detail:setBackGroundImage(Zjh_Games_res.menu_paixing)
	table.insert(menuTbale,self.DetailP)


	if self.RuleP and tolua.isnull(self.RuleP) == false then
		self.RuleP:removeFromParent()
		self.RuleP = nil
	end

	self.RuleP=self.menuItem:clone()
	self.rule=self.RuleP:getChildByName("quit")
	self.rule:setBackGroundImage(Zjh_Games_res.menu_wanfa)
	-- self.rule:setBackGroundImage(Zjh_Games_res.menu_rule)
	table.insert(menuTbale,self.RuleP)
	
	self.Xiala_panel:setContentSize(cc.size(self.Xiala_panel:getContentSize().width,30+(#menuTbale)*self.menuItem:getContentSize().height))
	local menuguang = self.Xiala_panel:getChildByName("menu_guang")
	local menu_guang_x = self.Xiala_panel:getContentSize().width / menuguang:getContentSize().width
	local menu_guang_y = self.Xiala_panel:getContentSize().height / menuguang:getContentSize().height
	menuguang:setScaleX(menu_guang_x)
	menuguang:setScaleY(menu_guang_y)
	self.Xiala_panel:setPositionY(Display.cy-5-self.Xiala_panel:getContentSize().height)
	local y=self.Xiala_panel:getContentSize().height-15
	for k,v in pairs(menuTbale)do
		self.Xiala_panel:addChild(v)
		y=y-self.menuItem:getContentSize().height
		v:setPosition(14,y)
	end

	
	if self.Xiala then
		addButtonEvent(self.Xiala,function()
			-- body
			if not self.Xiala_panel:isVisible() then
				self.Xiala_panel:setVisible(true)
				-- print("sadfasdfasfsadf ")
				-- if self.change and (Cache.zjhdesk._player_info[Cache.user.uin]==nil or Cache.zjhdesk.status==nil)  then 
				-- 	self.change_btn:setDisable() 
				-- 	return 
				-- end
				-- Util:lookUpNode(self.Xiala_panel, function (str, nodename, v)
				-- 	print(str, nodename, tolua.type(v))
				-- end)
				self:setChangeStatus()
				-- print("view_table >>>", Cache.zjhdesk.view_table)
				-- print("is_view >>>", Cache.zjhdesk.is_view)
				-- print("standup >>>", self.standup)
				-- print("is_view >>>", Cache.zjhdesk.can_not_change_table)				
				if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 and self.standup then
					self.standup_btn:setOpacity(100)
					self.standup_btn:setTouchEnabled(false)
				elseif self.standup then
					self.standup_btn:setOpacity(255)
					self.standup_btn:setTouchEnabled(true)
				end
				self:setBgTouchEnable(true)
			else
				self.Xiala_panel:setVisible(false)
			end
		end)
	end
	
	--退出
	local back_callback = function ( ... )
		if Cache.zjhdesk.status and Cache.zjhdesk.status >= 1 and Cache.zjhdesk._player_info[Cache.user.uin] and Cache.zjhdesk._player_info[Cache.user.uin].compare_failed ~= 1 and Cache.zjhdesk._player_info[Cache.user.uin].status ~= 1050 and  Cache.zjhdesk._player_info[Cache.user.uin].status ~= 1020  then
			qf.event:dispatchEvent(Zjh_ET.GAME_QUIT_KICK,{method="show",type="myselfquit"})
		else
			qf.event:dispatchEvent(Zjh_ET.RE_QUIT)
		end
	end

	
	if self.back then
		-- print("add quit_ btn YYYYYYYYYYYYYYYYY")
		self.quit_btn   = Handlebutton.new({button=self.back})
		addButtonEvent(self.quit_btn,function ()
			-- print("XXXXXXXXXXXX AAAAAAAAAAAAAAA")
			back_callback()
		end)
		-- self.quit_btn:setVisible(false)
	end

	Util:registerKeyReleased({self = self,cb = function ()
		back_callback()
    end})

	if self.standup then
		self.standup_btn   = Handlebutton.new({button=self.standup})
		--站起
		addButtonEvent(self.standup_btn,function ()
			if Cache.zjhdesk.status and Cache.zjhdesk.status >= 1 and  Cache.zjhdesk._player_info[Cache.user.uin].compare_failed ~= 1 and Cache.zjhdesk._player_info[Cache.user.uin].status ~= 1050 and  Cache.zjhdesk._player_info[Cache.user.uin].status ~= 1020  then
				-- qf.event:dispatchEvent(Zjh_ET.GAME_Standup,{method="show"})
				 qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt="游戏中，无法站起"})
			else
				GameNet:send({cmd=Zjh_CMD.CMD_EVENT_GOLD_FLOWER_UP_REQ,body={uin=Cache.user.uin,desk_id=Cache.zjhdesk.deskid}})
			end
		end)
	end

	if self.safebox then
		self.safebox_btn   = Handlebutton.new({button=self.safebox})
		--换桌
		addButtonEvent(self.safebox_btn,function ()
	    -- if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击炸金花换桌") end
			-- body
			-- self:loadingCuoHe()	
			--Cache.zjhdesk.changetable=true
			-- qf.event:dispatchEvent(Niuniu_ET.SEND_LOGIN_PRO)
			-- print("changebnt XXXXXXXX")
			-- qf.event:dispatchEvent(Zjh_ET.CHANGE_TABLE)
	        qf.event:dispatchEvent(ET.SAFE_BOX, {inGame = true})
		end)
	end

	if self.RuleP then
		self.rule_btn   = Handlebutton.new({button=self.rule})
		addButtonEvent(self.rule_btn, function ()
			self.Xiala_panel:setVisible(false)
			qf.event:dispatchEvent(ET.GAMERULE, {GameType = Cache.DeskAssemble:getGameType()})
		end)
	end

	--牌型
	self.detail_panel = ccui.Helper:seekWidgetByTag(self.gui,GameView.Detail_img)
	self.detail_panel:setZOrder(102)
	if self.detail then
		self.detail_btn   = Handlebutton.new({button=self.detail})
		addButtonEvent(self.detail_btn,function ()
	    	if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击炸金花牌型") end
			-- body		
			self.detail_panel:setVisible(true)
			self.Xiala_panel:setVisible(false)

			self:setBgTouchEnable(true)
		end)
	end

	if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 and self.gameChestPop then
		self.gameChestPop:setVisible(false)
	end
	if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 then
		self.kiss:setVisible(false)
	end
	-- if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.can_not_chat==1 and Cache.zjhdesk.is_view==1 then 
	-- 	self.Chat:setVisible(false)
	-- end
end

--初始化按钮事件
function GameView:initButton()
	-- body
	
	--商店
	self.Shop  = ccui.Helper:seekWidgetByTag(self.gui,GameView.Shop)
	self.Shop:setVisible(true)
	addButtonEvent(self.Shop,function()
		print("打开商城 。。。。。。。。。")
    	qf.event:dispatchEvent(ET.SHOP)
	end)

	self.deskinfo     = ccui.Helper:seekWidgetByTag(self.gui,GameView.Desk_info)
	self.baseinfo     = ccui.Helper:seekWidgetByTag(self.gui,GameView.Base_info)
	self.changciinfo  = ccui.Helper:seekWidgetByTag(self.gui,GameView.Changciinfo)
	self.changciinfo:setString("")

	self.deskgold     = ccui.Helper:seekWidgetByTag(self.gui,GameView.Desk_gold)
	self.deskturns    = ccui.Helper:seekWidgetByTag(self.gui,GameView.Desk_turns)

	self.kiss         = ccui.Helper:seekWidgetByName(self.gui,GameView.Kiss)                    --飞吻按钮
 	self.dila         = ccui.Helper:seekWidgetByName(self.gui,GameView.Dila)                    --荷官
 	self.Dila = Dila.new({node=self.dila})
	-- if  not true then
    --     ccui.Helper:seekWidgetByName(self.gui,"dila"):setVisible(false)
    --     ccui.Helper:seekWidgetByName(self.gui,"kiss"):setVisible(false)
    -- end
    --打赏	 
	self.kiss.noEffect=true
	self.kiss:setVisible(false)
	addButtonEvent(self.kiss,function (sender)
		sender:setScale(1)
		GameNet:send({cmd=Zjh_CMD.DASHANG,body={uin=Cache.user.uin,desk_id=Cache.zjhdesk.deskid}})
	end,function (sender)
		-- body
		sender:setScale(0.9)
	end)
	if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 then
		self.kiss:setVisible(false)
	end

	self.chips_area_1 = ccui.Helper:seekWidgetByTag(self.gui,248)
	self.chips_area_2 = ccui.Helper:seekWidgetByTag(self.gui,250)
	self.chips_area_3 = ccui.Helper:seekWidgetByTag(self.gui,252)
	self.start        = ccui.Helper:seekWidgetByTag(self.gui,GameView.Start)                   --开始按钮
	self:setStartBtnVis(false)
	--开始按钮
	addButtonEvent(self.start,function ()
		print("请求开始游戏")
		-- body
		self:loadingCuoHe()
		Cache.zjhdesk:clear()
		qf.event:dispatchEvent(Zjh_ET.KAN_NET_INPUT_REQ,{roomid = Cache.zjhdesk.roomid,deskid=Cache.zjhdesk.deskid})
	end)

	
	self.pkCloseP=ccui.Helper:seekWidgetByName(self.gui,"pkclose")
	--开始按钮
	addButtonEvent(self.pkCloseP,function ()
		-- body
		self:cancelPkkuang()
		self.pkCloseP:setVisible(false)
	end)

	self.sitdownLayer = ccui.Helper:seekWidgetByName(self.gui,"sitdownLayer")
	local currentTime = socket.gettime()
	self.sitdownLayer:setTouchEnabled(false)
	for i = 0, 4 do
		local btn = self.sitdownLayer:getChildByName("sitDown_" .. i)
		btn:setTouchEnabled(true)
		btn:setEnabled(true)
		addButtonEvent(btn, function ( ... )
			-- print(">>>>>>>>>>>>>>>>>>>>>")
			if Cache.zjhdesk:checkMeDown() then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = "您已坐下"})
                return
			end

            if self.limit_gold then
                if Cache.user.gold < self.limit_gold then
                    -- qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = string.format(GameTxt.string_room_limit_3, Util:getFormatString(self.limit_gold), Cache.packetInfo:getShowUnit())})
                    qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = string.format(Util:getReviewStatus() and GameTxt.string_room_limit_5 or GameTxt.string_room_limit_4, Util:getFormatString(self.limit_gold), Cache.packetInfo:getShowUnit()), confirmCallBack = function ( ... )
                    	if Util:getReviewStatus() then
	                        qf.event:dispatchEvent(ET.SHOP)
	                    else
	                        Cache.user.guidetochat = true
	                    	qf.event:dispatchEvent(Zjh_ET.RE_QUIT)
	                    end
                    end})
                    return
                end
            end

			--1s钟 限制一次点击
			local lasttime = socket.gettime()
			-- print("xzcvxzcvQWERQWERQWERWQERQWER")
			if lasttime - currentTime > 1 then
				-- print(">>>>>>>>>>>>>>>>>>>>>AAAAAAAAAAAAAAAAA")
				currentTime = lasttime
				GameNet:send({cmd=Zjh_CMD.CMD_EVENT_GOLD_FLOWER_SEAT_REQ,body={uin=Cache.user.uin,desk_id=Cache.zjhdesk.deskid}})
			end
		end)
	end

	-- local root_hide_arr = {}
	-- table.insert(root_hide_arr,self.detail_panel)
	-- table.insert(root_hide_arr,self.Xiala_panel)
	-- local raise_panel  = ccui.Helper:seekWidgetByTag(self.gui,225)
	-- table.insert(root_hide_arr,raise_panel)

	local showDesk = function (bVis)
		if self.detail_panel then
			self.detail_panel:setVisible(false)
		end

		if self.Xiala_panel then
			self.Xiala_panel:setVisible(false)
		end

		local raise_panel = ccui.Helper:seekWidgetByTag(self.gui,225)
		if raise_panel then
			raise_panel:setVisible(false)
		end

		-- if self._users[Cache.user.uin] then
		-- 	self._users[Cache.user.uin]:hideRaisePannel()
		-- end

		self:setBgTouchEnable(false)
	end

	ccui.Helper:seekWidgetByName(self.gui,"zjh_gamebg").noEffect = true
	addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"zjh_gamebg"),function ( ... )
		showDesk()
	end)
	self.gui.noEffect = true
	addButtonEvent(self.gui,function ( ... )
		showDesk()
	end)
end

function GameView:setBgTouchEnable(bEnable)
	self.gui:setTouchEnabled(bEnable)
	ccui.Helper:seekWidgetByName(self.gui,"zjh_gamebg"):setTouchEnabled(bEnable)
end

function GameView:setChangeStatus()
	-- body
	-- if not self.change then return end
	-- print("setChangeStatus XXXXX")
	-- print(Cache.zjhdesk.status)
	-- print(Cache.zjhdesk._player_info[Cache.user.uin])
	-- print(Cache.zjhdesk._player_info[Cache.user.uin].status)
	-- print(Cache.zjhdesk._player_info[Cache.user.uin].compare_failed)
	-- if not self.change_btn then return end
	-- if (Cache.zjhdesk.status==0 ) or
	--  ((Cache.zjhdesk._player_info[Cache.user.uin]) and
	--   (Cache.zjhdesk._player_info[Cache.user.uin].status == 1050 or 
	--   Cache.zjhdesk._player_info[Cache.user.uin].status == 1020 or 
	--   Cache.zjhdesk._player_info[Cache.user.uin].compare_failed==1
	--   )) or (Cache.zjhdesk.can_not_change_table == 0)
	-- then
	-- 	self.change_btn:setPressable()
	-- else
	-- 	self.change_btn:setDisable()
	-- end
end


--用户加注 用户跟注
function GameView:userRaise(model)
	print("userRaise model.uin 加注", model.uin)
	if self._users[model.uin] ~=nil  then
		self._users[model.uin]:userRaise(model)
	end
end

--加注标识 显示然后停留几秒后隐藏
function GameView:showAddBetImg(model)
	-- body
	if self._users[model.uin] ~=nil  then
		self._users[model.uin]:showAddBetImg()
	end
end

--chat
function GameView:chat(model)
    print("聊天用户 uin >>>>>>>>", model.op_uin)
    user = self._users[model.op_uin]
    self._chat:chatProtocol(model, user, self)

    local userData = Cache.zjhdesk._player_info[model.op_uin]
    print("userData >>>>>>>>>>>", userData)
    if userData then
        local nick = userData.nick or ""
        print("nick >>>>>>>>>>>", nick)
        self._chat:receiveNewMsg({model = model, name = nick, uin = model.op_uin})
    end
end

--chat
-- function GameView:chat(model)
-- 	print("chat 聊天 。。。。。。。。。。。")
-- 	if Cache.zjhdesk.haveLookupChat then
-- 		self.ChatPoint:setVisible(true)
-- 		self._chat:showChatPoint()
-- 	end

-- 	local isplayer
-- 	for k,v in pairs(Cache.zjhdesk._player_info)do
-- 		if k==model.op_uin then
-- 			isplayer=true
-- 			break
-- 		end
-- 	end
-- 	if not isplayer then return end
-- 	if Cache.user.uin == model.op_uin then
-- 		self._chat:hide()
-- 	end
-- 	if self._users[model.op_uin] then
-- 		self._users[model.op_uin]:showPopChat(model)
-- 	end
	
-- 	local index=self._chat:getChatListIndex(model.content)--第几条话
-- 	if self._users[model.op_uin]:getSexByCache(model.op_uin)==0 and index then
-- 		MusicPlayer:playEffectFile(string.format(Zjh_Games_res.all_music.CHAT_0,index))
-- 	elseif index then
-- 		MusicPlayer:playEffectFile(string.format(Zjh_Games_res.all_music.CHAT_1,index))
-- 	end
-- end

function GameView:showALLSitDownStatus(bvis)
	local layer = self.sitdownLayer
	for i = 0, 4 do
		self:showPlayerSitDownVis(i, bvis)
	end
end

function GameView:showPlayerSitDownVis(idx, bvis)
	self.sitdownLayer:getChildByName("sitDown_" .. idx):setVisible(bvis)
end

function GameView:showPlayerSitDownVisBySeat(seat, bvis)
	local cut = seat - Cache.user.meIndex
	if cut < 0 then
		cut = 5+cut
	end
	self:showPlayerSitDownVis(cut, bvis)
end

--显示当前下座位置ui显示
function GameView:showCurrentSitDownStatus()
	self:showALLSitDownStatus(true)
	for k,v in pairs(self._users)do
		local uin = k
		local info = Cache.zjhdesk._player_info[k]
		if info and info.seatid then
			self:showPlayerSitDownVisBySeat(info.seatid, false)
		end
	end
	-- for idx = 1, 5 do
	-- 	print("idx >>>>>> ", idx , self.sitdownLayer:getChildByName("sitDown_" .. (idx-1)):isVisible())
	-- end 
end

--用户自己进场
function GameView:enterDesk(parameters)
	-- body
	qf.event:dispatchEvent(Zjh_ET.DESK_SHOW_INFO)
	MusicPlayer:playEffectFile(Zjh_Games_res.all_music.EnterRoom)
	print("用户自己进场")
	if tolua.isnull(self) then
		return
	end
	self.limit_gold = Cache.zhajinhuaconfig:getLimitMoney(parameters.roomid)
	-- printRspModel(parameters)

	--默认显示全部的坐下图片
	if parameters.op_uin == Cache.user.uin then
		if not Cache.zjhdesk.ISINPUTREQ then
			Cache.zjhdesk.ISINPUTRE=false
			Cache.zjhdesk.WINNUM=0
		end
		Cache.zjhdesk:clearChat()--清除聊天记录
		for k,v in pairs(Cache.zjhdesk._player_info) do
			if k == Cache.user.uin  then
				local info_node = ccui.Helper:seekWidgetByName(self.gui,"mine_panel")
				self._myself    = Myself.new({node = info_node,view=self})
				self._myself:show(0.2)
				self._users[k]  = self._myself
				-- self.sitdown:setVisible(false)
				-- self.sitwaitP:setVisible(false)
				-- self.autoWaitBtn:setVisible(false)
				-- self:showPlayerSitDownVisBySeat(v.seatid, false)
			else
				local user_node    = self:getUserPanel(v.seatid)
				if user_node then
					-- self:showPlayerSitDownVisBySeat(v.seatid, false)
					user_node:setVisible(true)
					local user         = User.new({node = user_node,uin=v.uin,view=self})
					self._users[v.uin] = user
					user:show(0.2)
				end
			end
		end
		for i=1,3 do
			for k,v in pairs(self["chips_area_"..i]:getChildren())	do
				v:removeFromParent()
			end
		end
		self:reconnect()
		self:noGoldCheck()
		if Cache.zjhdesk.status ~= 1 then
			self:startTimeCount()
		end
	else
		local item         = Cache.zjhdesk._player_info[parameters.op_uin]
		if item then
			local user_node    = self:getUserPanel(item.seatid)
			user_node:setVisible(true)
			-- self:showPlayerSitDownVisBySeat(item.seatid, false)
			local user         = User.new({node = user_node,uin=item.uin,view=self})
			self._users[item.uin] = user
			user:show(0.2)
			-- self._users[item.uin]:updateGiftBtn(Cache.zjhdesk._player_info[parameters.op_uin].decoration)--初始化挂件
		end
	end

	for k,v in pairs(self._users)do
		v:setFirster()
	end
	if self.showCurrentSitDownStatus then
		self:showCurrentSitDownStatus()
	end

	--进入别人在玩牌则头像变灰
	-- if Cache.zjhdesk._player_info[parameters.op_uin] and Cache.zjhdesk._player_info[parameters.op_uin].status==1020 and Cache.zjhdesk:getUsersNum() ~= 1 and Cache.zjhdesk.status == 1 then
	-- 	self._users[parameters.op_uin]:setWaitingStartVis(true)
	-- end

	self:refreshWaitingStart()

	if Cache.zjhdesk.status == 0 and Cache.zjhdesk:getUsersNum() == 1 then
		self:showTips(Zjh_GameTxt.Waiting)
		self.startTimeBg:setVisible(false)
	elseif Cache.zjhdesk.status ~= 0 then
		if self.font then
			self.font:setVisible(false)
		end
	end
	if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 then
		self:autoSitWaitNum()
	end
	logd("GameView:enterDesk "..os.time())
	if self.refreshChatStatus then
		self:refreshChatStatus()
	end
	self.deskIDTxt:setString(parameters.show_desk_id .. "桌")
	-- self:refreshNoMoneyTip()
end

function GameView:refreshWaitingStart()
	for k, v in pairs(self._users) do
		v:setWaitingStartVis(false)
		if Cache.zjhdesk._player_info[k] and 
			Cache.zjhdesk._player_info[k].status==1020 and 
			Cache.zjhdesk:getUsersNum() ~= 1 and 
			Cache.zjhdesk.status == 1 then
			v:setWaitingStartVis(true)
		end
	end
end

function GameView:refreshChatStatus()
	if Cache.zjhdesk:checkSelfIsWatching() then
		-- self.Chat:setVisible(false)
		self._chat:setVisible(false)
	else 
		-- self.Chat:setVisible(true)
	end
end

function GameView:reconnectRandomChips()--入场时随机位置筹码
	print("入场时随机位置筹码 reconnectRandomChips")
	-- body
	local chips=Cache.packetInfo:getProMoney(Cache.zjhdesk.total_chips)
	local base=Cache.packetInfo:getProMoney(Cache.zjhdesk.base_chip)
	local NowMaxChip=0
	for i=1,20 do
		if chips<=(10^i) then
			NowMaxChip=10^(i-1)
			break
		end
	end
	while(chips>=base) do
		if chips>=NowMaxChip then
			Useranimation:drawChips({chip=NowMaxChip,base=base,panel=self:getRandomChipsPanel(),panel1=self:getChipsPanel1()})
			chips=chips-NowMaxChip
		elseif (NowMaxChip/10)>(base*10) then
			NowMaxChip=NowMaxChip/10
		else
			for i=10,1,-1 do
				if chips>=base*i then
					Useranimation:drawChips({chip=base*i,base=base,panel=self:getRandomChipsPanel(),panel1=self:getChipsPanel1()})
					chips=chips-base*i
					break
				end
			end
		end
	end
end
		
--断线重连
function GameView:reconnect()
	print("GameView reconnect 断线重连")
	if Cache.zjhdesk.status and Cache.zjhdesk.status >= 1  then
		qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove",hard=true})
		if self.ismeSitdown then
			self.ismeSitdown=nil
		else
			self:reconnectRandomChips()
		end
		for k,v in pairs(self._users) do
			v:reconnect()
		end
		local timer = 0
		if Cache.zjhdesk.player_op_past_time then
			timer = Cache.zjhdesk.player_op_past_time
		end
		qf.event:dispatchEvent(Zjh_ET.USER_HANDLE_TURN,{timer=timer})

		qf.event:dispatchEvent(Zjh_ET.RECONNECT_FIRE)
	end 
end

function GameView:reconnectUsers()
	print("reconnectUsers 用户重连 。。。。。。。。。。。。。")
	-- body
	for k,v in pairs(self._users) do
		if v then
			v:reconnect()
		end
	end
end

--赢家亮牌
function GameView:lightCard(model)
	print("玩家亮牌 。。。。。。。。。。。。。。。。。", model.uin)
	if self._users[model.uin] then
		self._users[model.uin]:showCard()
		local ifwin = false
		if self._users[model.uin]._info then
			local x,y
			if self._users[model.uin].user_info_panel then
				x=self._users[model.uin]:getPositionX()+self._users[model.uin].user_info_panel:getPositionX()-52
				y=self._users[model.uin]:getPositionY()+self._users[model.uin].user_info_panel:getPositionY()-15
			else
				x=self._users[model.uin]:getPositionX()-52
				y=self._users[model.uin]:getPositionY()-15
			end 
			self:showCardAnimate(ifwin,self._users[model.uin]._info.gold,self._users[model.uin]._info.card_type,self._users[model.uin]._info.card,{x=x,y=y})
		end
	end
end


function GameView:getUserNode(cut)
	local name = 192
	if cut == 1 then
		name = 136
	end

	if cut == 2 then
		name = 88
	end

	if cut == 3 then
		name = 5
	end

	if cut == 4 then
		name = 56
	end
	local node = ccui.Helper:seekWidgetByTag(self.gui,name)
	return node,cut
end

--获得对应seat的用户节点
function GameView:getUserPanel(seat)
	local cut = seat - Cache.user.meIndex
	if cut < 0 then
		cut = 5+cut
	end

	local name = 192
	if cut == 1 then
		name = 136
	end

	if cut == 2 then
		name = 88
	end

	if cut == 3 then
		name = 5
	end

	if cut == 4 then
		name = 56
	end

	local node = self:getUserNode(cut)
	return node,cut
end

--获得退出的人位置
function GameView:getUserPos(seat)
	-- body
	local node, cut = self:getUserPanel()
	local x,y
	x=node:getPositionX()-52
	y=node:getPositionY()-15
	return cc.p(x,y)
end


--其他用户退场
function GameView:quitRoom(uin)
	print("uin 用户退场 >>>>>>>>>>>>>>>>>>", uin)
	if tolua.isnull(self) then
		return
	end
	if self._users[uin] then
		if Cache.zjhdesk.status==1 and Cache.zjhdesk._player_info[uin] and (Cache.zjhdesk._player_info[uin].compare_failed or Cache.zjhdesk._player_info[uin].compare_win) then
			local user={}
			local x,y
			if self._users[uin].user_info_panel then
				x=self._users[uin]:getPositionX()+self._users[uin].user_info_panel:getPositionX()-52
				y=self._users[uin]:getPositionY()+self._users[uin].user_info_panel:getPositionY()-15
			else
				x=self._users[uin]:getPositionX()-52
				y=self._users[uin]:getPositionY()-15
			end 
			if Cache.user.uin ~= uin then
				user.seatid = Cache.zjhdesk._player_info[uin].seatid
			end
			user.ifwin=false
			user.gold=self._users[uin]._info.gold
			user.card_type=self._users[uin]._info.card_type
			user.card=self._users[uin]._info.card
			user.x=x
			user.y=y
			table.insert(self.showcardUser,user)
		end
		self._users[uin]:quitRoom(0.2)
		if Cache.zjhdesk.status == 0 and uin~=Cache.user.uin then
			self._users[uin] = nil
		end
		Cache.zjhdesk._player_info[uin] = nil
		if uin == Cache.user.uin then
			if tolua.isnull(self) == false then
				performWithDelay(self, function ( ... )
					-- print("XZCVXZCVASDFQWEWQERQWERQWER")
					if self.showCurrentSitDownStatus then
						self:showCurrentSitDownStatus()
					end				
				end, 1)
			end
		else
			if self.showCurrentSitDownStatus then
				self:showCurrentSitDownStatus()
			end
		end
		if self.refreshChatStatus then
			self:refreshChatStatus()
		end
	end

	if Cache.zjhdesk.status == 0 and Cache.zjhdesk:getUsersNum() == 1  and uin ~= Cache.user.uin  then
		if self.sid then
			Scheduler:unschedule(self.sid)
			self.sid=nil
		end
		self:showTips(Zjh_GameTxt.Waiting)
		self.startTimeBg:setVisible(false)
	end
end

--显示桌面提示语
function GameView:showTips(text)
	print("显示桌面提示语 。。。。。。。。。。。。。。。。。。。。", text)
	self:CHUOHE_CLOSE()
	self.font = ZJH_Display:getDeskTips(text)	
	self:addChild(self.font,2)

	local px = Display.cx/2
	if FULLSCREENADAPTIVE then
		px = px - (self.winSize.width -1920)/2
	end

	self.font:setPosition(px,Display.cy/2)
end

--正在撮合
function GameView:loadingCuoHe()
	print("正在撮合中 。。。。。。。。。。。。。。。。。。")
	self:CHUOHE_CLOSE()
	self.font =  ZJH_Display:getCuoheTips(Zjh_GameTxt.Game_cuohe)
	self:addChild(self.font,2)

	local px = Display.cx/2
	if FULLSCREENADAPTIVE then
		px = px - (self.winSize.width -1920)/2
	end
	self.font:setPosition(px,Display.cy/2)
end

function GameView:setSendcardTime()--设置发牌顺序
	-- body
	local timernum=math.random(0,4)--确定发牌个数
	local tableuser
	if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 then
		tableuser={56,5,88,136,192}
	else
		tableuser={56,5,88,136,163}
	end
	local tabletime={}
	for i=1,5 do--随机人发牌
		timernum=timernum+1
		if timernum==6 then
			timernum=1
		end
		table.insert(tabletime,tableuser[timernum]) 
	end
	timernum=0
	local playerNum=0
	for k ,v in pairs(self._users) do
		playerNum=playerNum+1
	end
	for m,n in pairs(tabletime) do
		for k ,v in pairs(self._users) do
		 	if v:getTag()==n then
		 		v:setSendCardTime(timernum,playerNum)
		 		timernum=timernum+1
		 		break
		 	end
		end
	end
end


--gamestart
function GameView:gameStart()
	print("游戏开始 gameStart 。。。。。。。。。。。。。。")
	-- 清除多余的部件
	self:CHUOHE_CLOSE()
	self.showcardUser={}
	self.startTimeBg:setVisible(false)
	self:setChangeStatus()
	qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
	self.Xiala_panel:setVisible(false)

	if self._users[Cache.user.uin] then
		--初始化自己操作按钮的值
		self._users[Cache.user.uin]:initButtonNum()
		--显示操作按钮
		self._users[Cache.user.uin]:showHandleButton()
	end
	--发牌
	--设置发牌顺序
	self:setSendcardTime()
	for k ,v in pairs(self._users) do
		if Cache.zjhdesk._player_info[k] then
			Cache.zjhdesk._player_info[k].draw  =  1 --标示已经绘制了牌桌的信息了
			qf.event:dispatchEvent(Zjh_ET.PLAYER_SEND_CARD,{user=v}) --其他玩家发牌
			v:setFirster()
		else
			self._users[k]=nil
		end
	end
	if self.showCurrentSitDownStatus then
		self:showCurrentSitDownStatus()
	end
	if self.refreshChatStatus then
		self:refreshChatStatus()
	end

	--丢筹码 显示下注数 显示桌面信息
	local timer = 0
	timer =timer + 0.4
	Scheduler:delayCall(timer,function()
		if tolua.isnull(self) then
			return
		end

		if Cache.zjhdesk.status == 1 then
			print("显示其他玩家丢筹码 与 显示下注 XXXXXXXXXX 。。。。。")
			for k ,v in pairs(self._users) do
				if v then
					local panel = self:getRandomChipsPanel()
					local panel1 = self:getChipsPanel1()
					qf.event:dispatchEvent(Zjh_ET.PLAYER_DIU_CHIP,{panel=panel,panel1=panel1,user=v})  --其他玩家丢筹码
					qf.event:dispatchEvent(Zjh_ET.PLAYER_SHOW_ROUND_CHIPS,{user=v})					--其他玩家显示下注
				end
			end
			qf.event:dispatchEvent(Zjh_ET.USER_HANDLE_TURN)                                            --到谁操作了
		end
	end)
end

--显示桌面信息
function GameView:showDeskInfo()
	print("showDeskInfo 显示牌桌信息 。。。。。。。。。。。。。")
	
	self.deskinfo:setVisible(true)
	local all_chip  = Cache.zjhdesk.total_chips
	local base      = Cache.zjhdesk.base_chip
	local limit     = Cache.zjhdesk.max_chips
	local now_round = Cache.zjhdesk.round_count
	local max_round = Cache.zjhdesk.max_round
	if not now_round or not max_round then return end
	local base      = Zjh_GameTxt.hall_limt_txt_2.. "：" .. Util:getFormatString(Cache.packetInfo:getProMoney(base)) .."  ".. Zjh_GameTxt.hall_limt_txt_1 .. Util:getFormatString(Cache.packetInfo:getProMoney(limit))
	local round     = string.format(Zjh_GameTxt.DeskTurn,now_round,max_round)

	self.baseinfo:setString(base)
	self.deskgold:setString(Util:getFormatString(Cache.packetInfo:getProMoney(all_chip))) --下注池也要1：1
	self.deskturns:setString(round)
	self.Xiala_panel:setVisible(false)
end

--比牌动画
function GameView:userComp(win_uin,lost_uin)
	print("比牌动画播放 。。。。。。。")
	--------------
	self:initAnimation()
	---------------
	self:cancelPkkuang()
	if self._users[win_uin]==nil or self._users[lost_uin]==nil then return end

	if self.font then
		self.font:setVisible(false)
	end
	self:maskLayer(100)

	self._users[win_uin]:pkCardFly(win_uin,lost_uin)
	self._users[lost_uin]:pkCardFly(win_uin,lost_uin)

	PopupManager:upwardAllPopup()   --收起弹框
	qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)--删除快捷聊天
	qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)--删除互动表情

	--hide 操作面板 
	if self._users[Cache.user.uin] then
		self._users[Cache.user.uin]:hideHandleButtonNoAnimate(true)
	end
	Scheduler:delayCall(0.5,function ( ... )
		if tolua.isnull(self) == true then
			return
		end
		self.Gameanimation:play({anim=GameAnimationConfig.PK,order=101,scale=1})
	end)

	Scheduler:delayCall(2.2,function ( ... )
		if tolua.isnull(self) == true then
			return
		end
		local tmp = self.Gameanimation:getSide(model)
		local zhadan=self.Gameanimation:play({anim=GameAnimationConfig.PKFIRE,layerOrder=103,create=true})
		zhadan:setScale(2.0)
		if tmp==0 then
			zhadan:setPosition(cc.p(Display.cx/2 -500,550))
		else
			zhadan:setPosition(cc.p(Display.cx/2 +500,550))
		end
		if FULLSCREENADAPTIVE then
			zhadan:setPositionX(zhadan:getPositionX()-self.winSize.width/2+1920/2)
		end
	end)

	--show 操作面板 
	Scheduler:delayCall(4,function ( ... )
		-- body
		if tolua.isnull(self) == true then
			return
		end
		if Cache.zjhdesk.iscompare then
			if not Cache.zjhdesk.allcom and Cache.zjhdesk._player_info[Cache.user.uin] then
				local NowPlayer=0
				for k,v in pairs(self._users) do
					if Cache.zjhdesk._player_info[k] and Cache.zjhdesk._player_info[k].status>1020 and Cache.zjhdesk._player_info[k].status~=1050 and Cache.zjhdesk._player_info[k].compare_failed~=1 then
						NowPlayer=NowPlayer+1
					end
				end
				if NowPlayer>=2 and Cache.zjhdesk.lost_uin~=Cache.user.uin and Cache.zjhdesk._player_info[Cache.user.uin].status>1020 and Cache.zjhdesk._player_info[Cache.user.uin].status~=1050 and Cache.zjhdesk._player_info[Cache.user.uin].compare_failed~=1 then
					loga("userComp")
					if self._users[Cache.user.uin] then
						self._users[Cache.user.uin]:showHandleButton()
					end
				else
					self:setChangeStatus()
					if self._users[Cache.user.uin] then
						self._users[Cache.user.uin]:hideHandleButtonNoAnimate(true)
						if NowPlayer<2 then
							self._users[Cache.user.uin].look:setVisible(false)
						end
					end
				end
			end
		elseif  Cache.zjhdesk.status~=0 then
            self:reconnectUsers()
		end
	end)
	
end

--添加遮罩
function GameView:maskLayer(opacity,func,...)
    local winSize = cc.Director:getInstance():getWinSize() 
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0),winSize.width, winSize.height)
    layer:setOpacity(opacity)
    
    layer:setTouchEnabled(true)
    layer:setName("maskLayer")

    self:addChild(layer)
    layer:setZOrder(100)
    if FULLSCREENADAPTIVE then 
    	layer:setPositionX(-winSize.width/2+1920/2)
    end
    local function touchLayerCallFunc(eventType, x, y,...)   
        if eventType == "began" then  
            if func then func(...) end
            return true  
        end
    end
    layer:registerScriptTouchHandler(touchLayerCallFunc,false,-1024,true)
end


function GameView:getRoot()
    return LayerManager.GameLayer
end


function GameView:getRandomChipsPanel()
	local  i  = math.random(1,3)
	return self["chips_area_"..i]
end

function GameView:getChipsPanel1()
	return self["chips_area_"..1]
end

function GameView:isMePlayer( ... )
	-- body
	local ismeplayer=false
	if Cache.zjhdesk._player_info[Cache.user.uin] and 
		Cache.zjhdesk._player_info[Cache.user.uin].status>1020 and
		Cache.zjhdesk._player_info[Cache.user.uin].status~=1050 and 
		Cache.zjhdesk._player_info[Cache.user.uin].compare_failed~=1 and 
		Cache.zjhdesk._player_info[Cache.user.uin].fold~=1 then
		ismeplayer=true
	end
	return ismeplayer
end

--到了该用户操作了
function GameView:userHandleTurn(timer)
	local call = function ( ... )
		Cache.zjhdesk.iscompare=nil
		-- body
		if Cache.zjhdesk.status~=0 then
			self._users[Cache.zjhdesk.next_uin]:addTimer({time=timer})
			for k,v in pairs(self._users) do
				if k~=Cache.zjhdesk.next_uin then
					v:removeTimer()
				end
			end
		end
		if Cache.zjhdesk.status~=0 and self:isMePlayer() then
			self._users[Cache.user.uin]:initButtonNum()
			self._users[Cache.user.uin]:showHandleButton()
		end

		if Cache.zjhdesk.next_uin == Cache.user.uin then
			PopupManager:upwardAllPopup()   --收起弹框
		else
			PopupManager:downwardAllPopup()   --拉回弹框
		end
	end

	local nextuin=Cache.zjhdesk.next_uin
	if self._users[Cache.zjhdesk.next_uin] ~= nil then
		--如果为比牌 延迟动画五秒
		if Cache.zjhdesk.iscompare == 1 then
			PopupManager:upwardAllPopup()   --收起弹框
			Scheduler:delayCall(5,function ( ... )
				-- body
				call()
				if nextuin~=Cache.zjhdesk.next_uin then
					if tolua.isnull(self) == false then
	        			self:reconnectUsers()
					end
        		end
			end)
		else
			call()
		end
	end
	if Cache.zjhdesk.iscompare == 1 then
		Scheduler:delayCall(1, function()
			if nextuin~=Cache.zjhdesk.next_uin then
				if tolua.isnull(self) == false then
	    			self:reconnectUsers()
				end
    		end
		end)
	end	
end

--到了该用户操作了
function GameView:userHandleTurnNoTimer(timer)
	local call = function ( ... )
		-- body
		if not Cache.zjhdesk._player_info[Cache.user.uin] then return end
		if Cache.zjhdesk._player_info[Cache.user.uin].status > 1020 and Cache.zjhdesk.status~=0 then
			self._users[Cache.user.uin]:initButtonNum()
			self._users[Cache.user.uin]:showHandleButton()
		end

		if Cache.zjhdesk.next_uin == Cache.user.uin then
			PopupManager:upwardAllPopup()   --收起弹框
		else
			PopupManager:downwardAllPopup()   --拉回弹框
		end
	end

	local nextuin=Cache.zjhdesk.next_uin
	if self._users[Cache.zjhdesk.next_uin] ~= nil then
		--如果为比牌 延迟动画五秒
		if Cache.zjhdesk.iscompare == 1 then
			PopupManager:upwardAllPopup()   --收起弹框
			Scheduler:delayCall(5,function ( ... )
				-- body
				call()
				if nextuin~=Cache.zjhdesk.next_uin then
					if tolua.isnull(self) == false then
	           			self:reconnectUsers()
					end
				end
			end)
		else
			call()
		end
	end
end

--显示比牌框
function GameView:pkKuang()
	local count = 0
	local arr   = {}
	if Cache.zjhdesk.next_uin~=Cache.user.uin then return end
	for k,v in pairs(self._users) do
		if k ~= Cache.user.uin and Cache.zjhdesk._player_info[k] and Cache.zjhdesk._player_info[k].fold ~= 1 and  Cache.zjhdesk._player_info[k].compare_failed ~= 1 and Cache.zjhdesk._player_info[k].status>1020 then
			table.insert(arr,v)
		end
	end

	if #arr >1 then
		for k,v in pairs(arr) do
			v:pkKuang()
		end
	end

	if #arr == 1 then
		GameNet:send({cmd=Zjh_CMD.USER_RE_COMPARE,body={uin=Cache.user.uin,desk_id=Cache.zjhdesk.deskid,compare_uin=arr[1]._uin}})
	end
	self.pkCloseP:setVisible(true)
end

--用户看牌
function GameView:userCheck(model)
	if self._users[model.uin] ~=nil then
		self._users[model.uin]:userCheck(model)
		if model.uin == Cache.user.uin then
			self:cancelPkkuang()
		end
	end
end

--clear
function GameView:clear()
	for k,v in pairs(self._users) do
		v:clear()
	end

	if Cache.zjhdesk.status == 0 and Cache.zjhdesk:getUsersNum() == 1 then
		if self.sid then
			Scheduler:unschedule(self.sid)
			self.sid=nil
		end
		self:showTips(Niuniu_GameTxt.Waiting)
		self.startTimeBg:setVisible(false)
	end
end


--fire
function GameView:fire(model)
	--------------
	self:initAnimation()
	---------------
	if not self._users[model.uin] then return end
	self._users[model.uin]:kuangFire()
	local fire = self.animation_layout:getChildByName("all_fire")
	if not fire  then
		local scale = 2
		self.Gameanimation:play({scale=scale,anim=GameAnimationConfig.ALLFIRE,name="all_fire",forever=1})
    end
end

function GameView:delayRun(time,cb)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(cb)))
end

--关闭撮合
function GameView:CHUOHE_CLOSE()
	if self.font then
		self.font:removeFromParent()
		self.font=nil
	end
end

function GameView:exit( )
	-- body
	-- MusicPlayer:backgroundSineOut()
	if self.sid then
		Scheduler:unschedule(self.sid)
		self.sid=nil
	end
	Cache.zjhdesk.gametype = nil
	Scheduler:clearAll()
    Util:loadAnim(GameAnimationConfig, false)
end

-- 通过seatid获取user
function GameView:getUser(i) 
    if not i or not self._users then return end

    return self._users[i]
end

function GameView:checkShow()
	-- body
	for k,v in pairs(self._users)do
		if Cache.zjhdesk.status~=1 then
			v:SetPlayerLight(false)
		end
	end
	 
	if Cache.zjhdesk.status~=1 and Cache.zjhdesk:getUsersNum()<=1 then
		self.startTimeBg:setVisible(false)
		self:showTips(Zjh_GameTxt.Waiting)
	end
end
function GameView:standUpShowCard(uin)
	-- body
	if  Cache.zjhdesk.status==1 and Cache.zjhdesk._player_info[uin] and (Cache.zjhdesk._player_info[uin].compare_failed or Cache.zjhdesk._player_info[uin].compare_win) then
		local user={}
		local x,y
		if self._users[uin].user_info_panel then
			x=self._users[uin]:getPositionX()+self._users[uin].user_info_panel:getPositionX()-52
			y=self._users[uin]:getPositionY()+self._users[uin].user_info_panel:getPositionY()-15
		else
			x=self._users[uin]:getPositionX()-52
			y=self._users[uin]:getPositionY()-15
		end 
		user.ifwin=false
		user.gold=self._users[uin]._info.gold
		user.card_type=self._users[uin]._info.card_type
		user.card=self._users[uin]._info.card
		user.x=x
		user.y=y
		table.insert(self.showcardUser,user)
	end
end

--站起
function GameView:standUp(uin)
	print(">>>>>>>>>>>>>>>>> standUp ", uin)
	-- body
	if uin ~= Cache.user.uin then
		self:quitRoom(uin)
	else
		self._chat:hide()
		if self.gameChestPop then
			self.gameChestPop:setVisible(false)
		end
		
		self.kiss:setVisible(false)
		self.standup_btn:setOpacity(100)
		self.standup_btn:setTouchEnabled(false)
		Cache.zjhdesk.is_view=1
		if self._users[uin] then
			self._users[uin]._info.quit=1
			self._users[uin]:setOpacity(0)
			self._users[uin]:clear()
		end
		if self.refreshChatStatus then
			self:refreshChatStatus()
		end

		-- self.sitdown:setVisible(true)
		print("Cache.zjhdesk.can_not_chat >>>>>>>>>", Cache.zjhdesk.can_not_chat)
		print("Cache.zjhdesk.view_table >>>>>>>>>", Cache.zjhdesk.view_table)
		print("Cache.zjhdesk.is_view >>>>>>>>>", Cache.zjhdesk.is_view)
		if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.can_not_chat==1 and Cache.zjhdesk.is_view==1 then 
			-- self.Chat:setVisible(false)
		end
		-- self.Chat:setVisible(false)
	end
	self:checkShow()
	self:autoSitWaitNum()
	if self.showCurrentSitDownStatus then
		self:showCurrentSitDownStatus()
	end
	if self.refreshChatStatus then
		self:refreshChatStatus()
	end
end

--坐下
function GameView:sitDown(uin)
	-- body
	logd("GameView zjh:sitDown begin"..os.clock())
	if uin ~= Cache.user.uin then
	else
		for k,v in pairs(self._users)do
			if k~=Cache.user.uin then
				v:quitRoom()
				self._users[k]=nil
			end
		end
		self._users={}
		if self.standup then
			self.standup_btn:setOpacity(255)
			self.standup_btn:setTouchEnabled(true)
		end
		if self.gameChestPop then
			self.gameChestPop:setVisible(true)
		end
		-- self.kiss:setVisible(false) --打赏关闭
		Cache.zjhdesk.is_view=0
		--self.Chat:setVisible(true) --qf3屏蔽
		-- self.sitdown:setVisible(false)
	end
	logd("GameView zjh:sitDown end"..os.clock())
end

function GameView:autoSitWaitNum()
	-- body
	-- self.autoWaitText:setString(string.format(Zjh_GameTxt.game_tips_1, Cache.zjhdesk.wait_num))
	-- self.sitwaitText:setString(string.format(Zjh_GameTxt.game_tips_2, Cache.zjhdesk.wait_num))
	-- if Cache.zjhdesk.is_view==1 and Cache.zjhdesk.can_seat_num<=0 and Cache.zjhdesk.ismeWait then
		-- self.sitwaitP:setVisible(true)
		-- self.autoWaitBtn:setVisible(false)
		-- self.sitdown:setVisible(false)
	-- elseif Cache.zjhdesk.is_view==1 and Cache.zjhdesk.can_seat_num<=0 then
		-- self.sitwaitP:setVisible(false)
		-- self.autoWaitBtn:setVisible(true)
		-- self.sitdown:setVisible(false)
	-- elseif Cache.zjhdesk.is_view==1 and Cache.zjhdesk.can_seat_num>0 then
		-- self.sitdown:setVisible(true)
		-- self.sitwaitP:setVisible(false)
		-- self.autoWaitBtn:setVisible(false)
	-- end
end

function GameView:enter()
    Util:loadAnim(GameAnimationConfig, true)
end

function GameView:exit()
    Util:loadAnim(GameAnimationConfig, false)
end

function GameView:setStartBtnVis(bVis)
	self.start:setVisible(bVis)
end

function GameView:refreshHongBaoBtn()
    self.Shop:setVisible(Cache.user.first_recharge_flag == 0)
    if Cache.user.first_recharge_flag == 1 then
        local pos = self.Shop:getPosition3D()
        Util:addHongBaoBtn(self, pos)
    elseif Cache.user.first_recharge_flag == 0 then
        Util:removeHongBaoBtn(self)
    end
end

function GameView:refreshNetStrength(paras)
    local diffX = 0
    if FULLSCREENADAPTIVE then
        diffX = self.winSize.width/2-1920/2
    end

	Util:addNetStrengthFlag(self.gui, cc.p(170-diffX,1045), paras)
end

function GameView:refreshNoMoneyTip(paras)
	if self.limit_gold ~= nil then
		paras = paras or {}
		paras.restMoney = self.limit_gold - Cache.user.gold
		paras.noImgTip = true
		Util:refreshNoMoneyTip(self.gui, paras)
	end
end


function GameView:test()
	-- local playerinfo = {
	-- 	nick = "nick XX",
	-- 	chips = 300000,
	-- 	gold = 300000,
	-- 	sex = 0
	-- }
	-- Cache.zjhdesk._player_info[Cache.user.uin] = playerinfo   
	-- --显示自己
	-- local info_node = ccui.Helper:seekWidgetByName(self.gui,"mine_panel")
	-- self._myself    = Myself.new({node = info_node,view=self})
	-- self._myself:show(0.2)


	-- local raise_panel  = ccui.Helper:seekWidgetByTag(self.gui,225)
	-- -- raise_panel:setVisible(false)

	-- performWithDelay(self, function ( ... )
	-- 	raise_panel:setVisible(false)
	-- end, 1)
	-- -- performWithDelay(self, function ()
	-- -- 	self._myself:userFold()
	-- -- end, 0.5)

	-- -- 牌桌上显示筹码
	-- local spr = Useranimation:getChipsimg(200, 100)	
	-- self.gui:addChild(spr)
	-- spr:setPosition3D(cc.p(300,300))

	Cache.zjhdesk._player_info = {
		 [1] = {
            seatid = 0,
            nick = "1111",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
        [2] = {
            seatid = 1,
            nick = "2222",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 0
        },
        [3] = {
            seatid = 2,
            nick = "3333",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
        [4] = {
            seatid = 3,
            nick = "4444",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
        [5] = {
            seatid = 4,
            nick = "5555",
            chips = 1000,
            gold = 30000,
            portrait = "IMG2",
            sex = 1
        },
	}
	Cache.user.uin = 1

	local info_node = ccui.Helper:seekWidgetByName(self.gui,"mine_panel")
	self._myself    = Myself.new({node = info_node,view=self, uin = 1})
	self._myself:show(0.2)
	self._myself:playShowChatMsg(self.chat_txt_layer, "dkasdfhasdf")
	Cache.user.meIndex = 0
	for i = 1, 5 do
		local user_node = self:getUserPanel(i)
		print("user_node >>>>>>>", user_node)
		if user_node then
			-- self:showPlayerSitDownVisBySeat(v.seatid, false)
			user_node:setVisible(true)
			local user         = User.new({node = user_node,uin=i,view=self})
			self._users[i] = user
			user:playShowChatMsg(  self.chat_txt_layer, "asjhfdasdf ")
			-- user:emoji(1, self._chat.Emoji_index)
			user:show(0.2)
		end
	end
	-- performWithDelay(self, function ( ... )
		-- self._myself:playShowChatMsg("1729831729381723")
		-- self._myself:emoji(1, self._chat.Emoji_index)
	-- end, 2)
	-- performWithDelay(self, function ( ... )
	-- 	self._myself:playShowChatMsg("1729831729381safdasdfsadf723")
	-- end, 5)
end

return GameView
