local Myself        = class("Myself",import(".User"))
local Handlebutton  =  import("src.games.game_zjh.modules.game.components.button.Handlebutton")
local Card          =  import("src.games.game_zjh.modules.game.components.card.Card")
local MeteorNode = import("src.modules.common.widget.MeteorNode")
local GameAnimationConfig = import("..animation.AnimationConfig")

Myself.Mine_handle_panel   = 168  --操作按钮容器
Myself.User_info_panel     = 4575  --个人信息容器
Myself.Nick                = 194  --个人信息昵称
Myself.Gold                = 196  --个人信息金币
Myself.Icon                = 195  --个人信息头像
Myself.OverBg              = 389  --个人信息头像
Myself.GIFTBTN     		   = 647  --礼物

-- Myself.show_card_bgpanel   ="show_card_panel"
-- Myself.show_card_gold	   ="gold"
-- Myself.show_card_panel	   ="card_panel"
-- Myself.show_card_kind	   ="card_kind"
-- Myself.show_win_kuang	   ="win_kuang"


--button
Myself.Flod                = 164  --弃牌
Myself.Fire                = 166  --火拼
Myself.Raise               = 169  --加注
Myself.Compare             = 171  --比牌
Myself.Call                = 173  --跟注
Myself.Auto_call           = 293  --自动跟注

Myself.Raise_panel         = 225  --加注列表
Myself.Cards_panel         = 197  --牌容器


Myself.Card_kind           = 208 --牌的类型
Myself.Look                = 253 --看牌
Myself.Liang               = 288 --亮牌
Myself.Kind_font           = 280
Myself.Kind_font_bg        = 209


Myself.Status_panel        = 204  --用户状态panel
Myself.Status_panel_bg     = 205  



Myself.Fire_cost_panel      = 295 
Myself.Fire_cost_free_panel = 297
Myself.Fire_cost_cost_panel = 301


Myself.BQ_TABLE1={"6","14","20","10","24","29"}
Myself.BQ_TABLE2={"4","20","1","9","29","2"}
Myself.BQ_TABLE3={"5","3","28","13","7","27"}

--初始参数
Myself.Card_Center = {
	x=-260,
	y=287,
}


--发牌时间


Myself.Card_Positon  = {
		mine_panel = {
			chip_start={
				x = -320,
				y = -330,
			},
			panel_card = {
				x = 900,
				y = 300	
			},
		},
		--pk左边的位置
		left_pk = {
			x = Display.cx/2 -500,
			y = 550,
		},

		--pk右边边的位置
		right_pk = {
			x = Display.cx/2 +500,
			y = 550,
		},

	}
Myself.Card_Anim_Time  = 0.4   --发牌动画时间
Myself.Card_Anim_Space = 0.04  --牌之间的间隔时间

--emoji position --
Myself.Emoji_position = cc.p(415,110)

Myself.CardPos={nolook={{x=61,y=80},{x=199,y=80},{x=337,y=80}},
				look={{x=111,y=80},{x=199,y=100},{x=287,y=80}}
}

function Myself:ctor ( paras )
	self.winSize = cc.Director:getInstance():getWinSize()
	self.super.ctor(self, paras)
	--self:setZOrder(1)
end

function Myself:initCancelBtnAni()
	-- body
	if self.cancelBtnAni then return end
	--self.auto:setTouchEnabled(false)
	local btnShow = function(bnt,efunc,bfunc,mfunc,cfunc)
		-- body
		bnt:addTouchEventListener(
	        function (sender, eventType)
	            if eventType == ccui.TouchEventType.began then
	            	bnt:setScale(1.0)
	                if bfunc then bfunc(sender) end
	            elseif eventType == ccui.TouchEventType.moved then
	                if(mfunc) then mfunc(sender) end
	            elseif eventType == ccui.TouchEventType.ended then
	            	bnt:setScale(0.9)
	                if(efunc) then efunc(sender) 
	                if sender.noEffect == true then return end 
	                MusicPlayer:playMyEffectGames(Niuniu_Games_res,res) end
	            elseif eventType == ccui.TouchEventType.canceled then
	            	bnt:setScale(0.9)
	                if(cfunc) then cfunc(sender) end
	            end
	        end
	    )
	    return btn
	end

	--自动跟注
	btnShow(self.auto,function()
		-- body
		loga("自动跟注")
		if self._info.auto_call == 1 then
			self._info.auto_call  = nil
			self.cancelBtnAni:setVisible(false)
			self.callBtnAni:setVisible(true)
   			local font = self.auto:getChildByName("font")
   			font:setString(Zjh_GameTxt.Auto_call)
   			self:showHandleButton()
	   		GameNet:send({cmd=Zjh_CMD.CALL_ALL,body={uin=self._uin,is_or_not=0}},function (resp )
			end)
	   else
	   		self._info.auto_call  = 1
	   		self.cancelBtnAni:setVisible(true)
	   		self.callBtnAni:setVisible(false)
   			local font = self.auto:getChildByName("font")
   			font:setString(Zjh_GameTxt.Cancel_auto_call)
	   		GameNet:send({cmd=Zjh_CMD.CALL_ALL,body={uin=self._uin,is_or_not=1}},function (resp )
	   			
			end)
	   end
	   MusicPlayer:playMyEffectGames(Zjh_Games_res,"GEN_ALL")
	end)
	self.auto:setScale(0.9)
	self.cancelBtnAni = Util:playAnimation({
		anim = GameAnimationConfig.CANCELBTNANI,
		forever = true,
		scale= 1.1,
		name = "cancelBtn",
		position = cc.p(self.auto:getContentSize().width/2,self.auto:getContentSize().height/2-7),
		node = self.auto
	})
	self.cancelBtnAni:setVisible(false)
	
	self.callBtnAni = Util:playAnimation({
		anim = GameAnimationConfig.CALLBTNANI,
		forever = true,
		scale= 1.1,
		name = "cancelBtn",
		position = cc.p(self.auto:getContentSize().width/2,self.auto:getContentSize().height/2-7),
		node = self.auto
	})
	self.callBtnAni:setVisible(false)

end

function Myself:addMeteorEffectToButton(button)
    if button == nil then return end
    if button:getChildByTag(9999) then return button:getChildByTag(9999)  end


    button:setAnchorPoint(cc.p(0.5, 0.5))
    local buttonSize = button:getContentSize()
    local meteorNode = MeteorNode.new({
        image = GameRes.main_effect_star,
        width = buttonSize.width, 
        height = buttonSize.height,
        duration = 2,
        circle = false,
        trail = {
            {x=29, y=14, isBezierPoint=false},
            {x=263, y=14, isBezierPoint=false},
            {x=269, y=17, isBezierPoint=true},
            {x=273, y=21, isBezierPoint=true},
            {x=276, y=27, isBezierPoint=false},
            {x=276, y=101, isBezierPoint=false},
            {x=273, y=107, isBezierPoint=true},
            {x=269, y=111, isBezierPoint=true},
            {x=262, y=113, isBezierPoint=false},
            {x=30, y=113, isBezierPoint=false},
            {x=23, y=111, isBezierPoint=true},
            {x=19, y=107, isBezierPoint=true},
            {x=16, y=101, isBezierPoint=false},
            {x=16, y=27, isBezierPoint=false},
            {x=19, y=21, isBezierPoint=true},
            {x=23, y=17, isBezierPoint=true}
        }
    })
    meteorNode:setTag(9999)
    button:addChild(meteorNode)
    return meteorNode
end


--初始化
function Myself:init(paras)
	
	--容器
	self.mine_handle_panel = ccui.Helper:seekWidgetByName(self,"button_panel") --操作按钮容器
	self.user_info_panel   = ccui.Helper:seekWidgetByName(self,"user_info")   --个人信息界面
	self.nick              = ccui.Helper:seekWidgetByName(self,"nick")              --个人信息昵称
	self.gold              = ccui.Helper:seekWidgetByName(self,"gold")              --个人信息金币
	self.icon              = ccui.Helper:seekWidgetByName(self,"icon")              --个人信息头像
	self.overbg            = ccui.Helper:seekWidgetByName(self,"overbg")              --遮掩层
	self.zhuangIcon		   = ccui.Helper:seekWidgetByName(self,"zhuang")  --玩家庄家符号
	self.addBetTips		   = ccui.Helper:seekWidgetByName(self,"addbetTips")  --玩家加注符号
	self.showWaitingStart  = ccui.Helper:seekWidgetByName(self,"waitingStart")  --等待开始

	self._panel_name       = "mine_panel"
	self._bg               = ccui.Helper:seekWidgetByName(self,"bg")             --玩家信息背景

	self.mine_handle_panel:setVisible(false)

	self._uin   = Cache.user.uin
	self._info  = Cache.zjhdesk._player_info[self._uin]   
	self.nick:setString(self._info.nick)
    self.gold:setContentSize(cc.size(195,50))
    self.gold:setString(Util:getFormatString(Cache.packetInfo:getProMoney(self._info.chips+self._info.gold)))
    
	self:updateBeauty()--显示美女标识
	
	Util:updateUserHead(self.icon, Cache.user.portrait, self._info.sex, {add=true,sq=true, url=true})

	self.icon:setTouchEnabled(true)
	local num =1
	addButtonEvent(self.icon,function ( )
		if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
		local localinfo={gold=Cache.zjhdesk._player_info[self._uin].gold+Cache.zjhdesk._player_info[self._uin].chips,
            				nick=self._info.nick,
            				portrait=self._info.portrait,
            				sex=self._info.sex}
        qf.event:dispatchEvent(Zjh_ET.GAME_SHOW_USER_INFO,{uin=self._uin,localinfo=localinfo})
	end)


	self.Flod      = ccui.Helper:seekWidgetByName(self,"btn_flod") 
    ccui.Helper:seekWidgetByName(self,"btn_fire"):setVisible(false)
--	self.Fire      = ccui.Helper:seekWidgetByName(self,"btn_fire")
	self.Raise     = ccui.Helper:seekWidgetByName(self,"btn_raise")
	self.Compare   = ccui.Helper:seekWidgetByName(self,"btn_compare")
	self.Call      = ccui.Helper:seekWidgetByName(self,"btn_call")

	self.card_kind = ccui.Helper:seekWidgetByName(self,"card_kind")


	self.flod     = Handlebutton.new({button=self.Flod})
--	self.fire     = Handlebutton.new({button=self.Fire})
	self.raise    = Handlebutton.new({button=self.Raise})
	self.compare  = Handlebutton.new({button=self.Compare})
	self.call     = Handlebutton.new({button=self.Call})
	self.look     = ccui.Helper:seekWidgetByName(self,"kan")
	self.liang    = ccui.Helper:seekWidgetByName(self,"liang")
	self.auto     = ccui.Helper:seekWidgetByName(self,"btn_call_auto")


	self.Raise_panel  = ccui.Helper:seekWidgetByName(self._parent_view.gui,"raise_panel")
	self.Raise_panel:setZOrder(103)
	self.cards_panel  = ccui.Helper:seekWidgetByName(self,"card_panel")


	self.Fire_cost_panel   = ccui.Helper:seekWidgetByName(self,"fire_cost")
	self.Fire_cost_free_panel   = ccui.Helper:seekWidgetByName(self,"free")
	self.Fire_cost_cost_panel   = ccui.Helper:seekWidgetByName(self,"cost")
    self.Fire_cost_panel:setVisible(false)
    self.Fire_cost_free_panel:setVisible(false)
    self.Fire_cost_cost_panel:setVisible(false)

	self._cards            = {} --玩家的牌的img


	self._bg               = ccui.Helper:seekWidgetByName(self,"bg")             --玩家信息背景

	self.defaultCountTimer = 12
	self.selfSize          = self._bg:getContentSize()
	self.progresstimer     = Zjh_Games_res.progresstimer

	--结束游戏动画
	self:playerInfoShow(true)
	self.Status_panel        = ccui.Helper:seekWidgetByName(self,"user_status")
	self.Status_panel_bg        = ccui.Helper:seekWidgetByName(self.Status_panel,"bg")
	self.Kind_font        = ccui.Helper:seekWidgetByName(self.card_kind,"kind_font")
	self.Kind_font_bg        = ccui.Helper:seekWidgetByName(self.card_kind,"bg")

	

	local start_x = self:getPositionX()
	local start_y = self:getPositionY()
--	start_x =self.fire:getContentSize().width/2
--	start_y =self.fire:getContentSize().height/2


	if self.button_fire==nil then
--		self.button_fire=self._parent_view.Gameanimation:play({name="button_fire",node=self.fire,scale=2,anim=GameAnimationConfig.BUTTONFIRE,order=101,forever=1,position={x=start_x,y=start_y}})
--		self.button_fire:setScale(2.2,2)
--		self.button_fire:setAnchorPoint(0.5,0.5)
	end

--	if Cache.zjhdesk.rush_diamond == 0 then
--		self.Fire_cost_free_panel:setVisible(true)
--		self.Fire_cost_cost_panel:setVisible(false)
--		local font = self.Fire_cost_free_panel:getChildByName("font")
--		font:setString(Zjh_GameTxt.Fire_free)
--	else
--		self.Fire_cost_free_panel:setVisible(false)
--		self.Fire_cost_cost_panel:setVisible(false)
--		local font = self.Fire_cost_cost_panel:getChildByName("font")
--		font:setString(string.format(Zjh_GameTxt.Fire_cost,Cache.zjhdesk.rush_diamond ))
--	end
	self:initButtonEvent()


	self.wait2start        = nil
	self.gift = ccui.Helper:seekWidgetByName(self,"gift")
	self:updateBtn(-1)
	addButtonEvent(self.gift,function ( sender )
        local type 
        --if ModuleManager:judegeIsIngame() then
            type = self._uin == Cache.user.uin and 3 or 4
        --end
        qf.event:dispatchEvent(ET.SHOW_GIFT,{name="gift",from=self.TAG, type = type, uin = self._uin ,gifts = self.gifts })
    end)

	if  not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.gift:setVisible(false)
    else
    	self.gift:setVisible(false)
    	self.gift:setTouchEnabled(true)
    end
    self:hideHandleButtonNoAnimate(false)
    self:initCancelBtnAni()

end


--显示
function Myself:show(times)
	self.super.show(self,times)
	self.user_info_panel:setVisible(true)

	
end

function Myself:SetPlayerLight(flag)--遮掩
	-- body
	print("SetPlayerLight >>>>>>>>>>>", flag)

	local isLight=false
	if  flag == nil  then
		if self._info.status==1050 or self._info.status==1020 then
			isLight=true
		end

		if Cache.zjhdesk.status ==0 and self._info.status==1020  then
			isLight=false
		end
	else
		isLight  = flag
	end

	self.overbg:setVisible(isLight)
	self.overbg:setColor(Theme.Color.DARK)
	if isLight then
		self.gold:setOpacity(180)
		self.nick:setOpacity(180)
	else
		self.gold:setOpacity(255)
		self.nick:setOpacity(255)
	end
end

function Myself:standUp()
	Cache.zjhdesk:updateCacheByStandUp({uin = Cache.user.uin})
	self._parent_view:standUp(Cache.user.uin)
end

--退出房间
function Myself:quitRoom(times)
	-- self:clear()
	dump(Cache.zjhdesk.reason)
	if Cache.zjhdesk.reason == 5 then
		ModuleManager:removeExistView()
		Cache.zjhdesk:clear()
		if Cache.user.game_list_type==1 and Cache.user.downGameList[1].name=="1" then
            ModuleManager.gameshall:initModuleEvent()
			ModuleManager.gameshall:show()
    		ModuleManager.gameshall:showReturnHallAni()
    	else
    		ModuleManager.zjhglobal:show()
    		ModuleManager.zjhhall:show()
    	end
	elseif Cache.zjhdesk.reason == 11 or model.reason == 12 or model.reason == 13 then
		local time = 3
		Scheduler:delayCall(time,function ()
			-- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =GameTxt.string_room_limit_2})
			if Cache.packetInfo:isShangjiaBao() then
				if model.reason == 11 then
					ModuleManager.zjhgame:noGoldCheck()
				end
				if model.reason == 13 then
					qf.event:dispatchEvent(ET.OVER_ROOM_MAX_LIMIT, {confirmCallBack = function ( ... )
						local roomid = Cache.kanconfig:getAvailableRoom()
				        qf.event:dispatchEvent(ET.QUICK_START_GAME, {
				        	type = QUICKGAME_TYPE.QUICKMATCH,
				        	roomid = roomid
				        })
				    end})
				end
			end
			self:standUp()
		end)
		-- Scheduler:delayCall(1,function ()
		-- 	if tolua.isnull(self) == true then
		-- 		return
		-- 	end
		-- 	self:clear()
		-- 	Scheduler:clearAll()
		-- 	qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =Niuniu_GameTxt.Game_no_gold})
		-- 	self._parent_view.startTimeBg:setVisible(false)
		-- 	Scheduler:delayCall(2,function ()
		-- 		-- body
		-- 		ModuleManager:removeExistView()
		-- 		Cache.zjhdesk:clear()
		-- 		qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
		-- 		qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)
		-- 		qf.event:dispatchEvent(Zjh_ET.NO_GOLD,{roomid=Cache.zjhdesk.roomid})
		-- 		if Cache.user.game_list_type==1 and Cache.user.downGameList[1].name=="1" then
		--             ModuleManager.gameshall:initModuleEvent()
		-- 			ModuleManager.gameshall:show()
		--     		ModuleManager.gameshall:showReturnHallAni()
		--     	else
		--     		ModuleManager.zjhglobal:show()
		--     		ModuleManager.zjhhall:show()
		--     	end
		-- 	end)
		-- end)
	else
		Scheduler:clearAll()
		Scheduler:delayCall(1,function ()
			if tolua.isnull(self) == true then
				return
			end
			-- body
			self:clear()
			ModuleManager:removeExistView()
			ModuleManager.zjhglobal:show()
			ModuleManager.zjhgame:show()
			Cache.zjhdesk:clear()
			qf.event:dispatchEvent(Zjh_ET.TIME_CLEAR_DESK)
			qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
			qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)
			--没操作被踢了
			qf.event:dispatchEvent(Zjh_ET.GAME_QUIT_KICK,{method="show",type="nohandle"})
			qf.event:dispatchEvent(Zjh_ET.KICK_ADJUST)
		end)
	end

	Cache.desk.is_play = -1

	
end

-- button 数值
function Myself:initButtonNum()

--    self.Fire_cost_free_panel:setVisible(false)
--	if Cache.zjhdesk.rush_diamond == 0 then
--		self.Fire_cost_free_panel:setVisible(true)
--		self.Fire_cost_cost_panel:setVisible(false)
--		local font = self.Fire_cost_free_panel:getChildByName("font")
--		font:setString(Zjh_GameTxt.Fire_free)
--	else
--		self.Fire_cost_free_panel:setVisible(false)
--		self.Fire_cost_cost_panel:setVisible(false)
--		local font = self.Fire_cost_cost_panel:getChildByName("font")
--		font:setString(string.format(Zjh_GameTxt.Fire_cost,Cache.zjhdesk.rush_diamond / 100 ))--筹码数值也改成1：1
--	end



	local rate  = 1
	if  self._info.look then	
		rate = 2
	end


	--跟注
	local num = ccui.Helper:seekWidgetByName(self.call,"font")
	local str = string.format(Zjh_GameTxt.Call,Util:getFormatStringK(Cache.zjhdesk.now_chips*rate,1))
	num:setString(str)
	self.call:setValue(Cache.zjhdesk.now_chips*rate)




--	--火拼
--	local num = ccui.Helper:seekWidgetByName(self.fire,"font")
--	local str = string.format(Zjh_GameTxt.Fire,Util:getFormatStringK(Cache.zjhdesk.rush_money*rate,1))
--	num:setString(str)
--	self.fire:setValue(Cache.zjhdesk.rush_money*rate)

--	if Cache.zjhdesk.ifFire then
--		local str = string.format(Zjh_GameTxt.Fire,Util:getFormatStringK(Cache.zjhdesk.now_fire_chip*rate*2,1))
--		num:setString(str)
--		self.fire:setValue(Cache.zjhdesk.now_fire_chip*rate*2)
--	end


	--比牌
	local num = ccui.Helper:seekWidgetByName(self.compare,"font")
	local str 
	local all = Cache.zjhdesk._player_info[Cache.user.uin].gold+Cache.zjhdesk._player_info[Cache.user.uin].chips
	if Cache.zjhdesk.now_chips*rate<all then
		str= string.format(Zjh_GameTxt.Compare,Util:getFormatStringK(Cache.zjhdesk.now_chips*rate,1))
	else
		str= string.format(Zjh_GameTxt.Compare,Util:getFormatStringK(all ,1))
	end
	num:setString(str)	
	self.compare:setValue(Cache.zjhdesk.now_chips*rate)


	local i = 2
	for k,v in pairs(Cache.zjhdesk.chip_list)  do
		local tmp = v
		tmp = tmp * rate

		local btn  = ccui.Helper:seekWidgetByName(self.Raise_panel,"raise_"..i)
		local str  = Util:getFormatStringK(tmp,1)
		local num  = btn:getChildByName("font")
		
		if num then
			if Util:UTF8length(str) > 3 then
				num:setScale(0.8)
			end
			num:setString(str)
		end

		self["raise_"..i] = Handlebutton.new({button=btn})
		self["raise_"..i]:setValue(tmp)		

		addButtonEvent(self["raise_"..i],function()
			local coin = tonumber(tmp)
			loga(string.format("room:%d,raise:%d",Cache.zhajinhuaconfig.zhajinhua_room[Cache.zjhdesk.roomid].room_group,k))
			qf.platform:umengStatistics({umeng_key="ZJH_addRaise",umeng_value=string.format("room:%d,raise:%d",Cache.zhajinhuaconfig.zhajinhua_room[Cache.zjhdesk.roomid].room_group,k)})
			GameNet:send({cmd=Zjh_CMD.USER_RE_RAISE_CALL,body={uin=self._uin,desk_id=Cache.zjhdesk.deskid,call_money=Cache.packetInfo:getCProMoney(coin)}},function (resp )
			end)
		end)

		i = i +1
	end
	
end


function Myself:setSendCardTime(time,gamenum)--设置发牌初始时间和人数
	-- body
	self.sendcardTime=time
	self.sendcardNum=gamenum
end
--发牌
function Myself:sendCardAnim()

	if self._info.status == 1030 then
		self.cards_panel:setVisible(true)
		self.cards_panel:removeAllChildren()
		self._cards={}
		local x         = self:getPositionX()
		local y         = self:getPositionY()
		local ttx       = self.user_info_panel:getPositionX()
		local tty       = self.user_info_panel:getPositionY()
		local tttx      = self.card_kind:getPositionX()
		local ttty      = self.card_kind:getPositionY()
		local tx        = self.cards_panel:getPositionX()
		local ty        = self.cards_panel:getPositionY()

		local start_x  = x+ttx+tttx+tx
		local start_y  = y+tty+ttty+ty




		local card_tmp  = Card.new()
		local size      = card_tmp:getContentSize()
		local alllength = size.width*3-50*2
		local sizet     = self.card_kind:getContentSize()

		local panelsize   = self.cards_panel:getContentSize()
		local start_width =  (alllength-panelsize.width)/2
		MusicPlayer:playMyEffectGames(Zjh_Games_res,"FLIP")
		for i=1,3 do
			local card_tmp  = Card.new()
			table.insert(self._cards,card_tmp)
			self.cards_panel:addChild(card_tmp,0)
			card_tmp:setScale(0.7)
			card_tmp:setPosition(Display.cx/2-start_x,Display.cy/2-start_y)
			
			local delay     = cc.DelayTime:create(self.sendcardTime*0.05+(i-1)*0.05*self.sendcardNum+Myself.Card_Anim_Space*(3-i))
			local move      = cc.MoveTo:create(Myself.Card_Anim_Time,cc.p(self.CardPos.nolook[i].x,self.CardPos.nolook[i].y))
			local scale     = cc.ScaleTo:create(Myself.Card_Anim_Time,1)
			local spawn     = cc.Spawn:create(move,scale)
			local rotation 	= cc.RotateBy:create(self.sendcardTime*0.05+(i-1)*0.05*self.sendcardNum+Myself.Card_Anim_Space*(3-i)+Myself.Card_Anim_Time,360)
			local sp        = cc.Spawn:create(cc.Sequence:create(delay,spawn),rotation)


			card_tmp:runAction(sp)
		end
		
		Scheduler:delayCall(0.8,function ( ... )
			-- body
			if tolua.isnull(self) == true then
				return
			end
			loga("我的状态")
			loga(self._info.fold)
			loga(Cache.zjhdesk.status)
			if self._info.fold ~= 1 and  Cache.zjhdesk.status ~= 0 then
				self.look:setVisible(true)
			end
		end)
	end
end

function Myself:HideStatusPanel()
	-- body
	self.Status_panel:setVisible(false)
end

function Myself:GiveUpCard()--弃牌
	-- body
	self.Status_panel_bg:loadTexture(Zjh_Games_res.Status_GiveUp,ccui.TextureResType.plistType)
	self.Status_panel:setVisible(true)
	self:SetPlayerLight(false)
	self:hideHandlePanel()
end

function Myself:CompareFail(isReconnect)--比牌失败
	if not isReconnect then
		if true then 
--			qf.event:dispatchEvent(ET.SHOW_QUICKLY_CHAT,{bqtable=self.BQ_TABLE2})
		end
	end
	-- body
	self.Status_panel_bg:loadTexture(Zjh_Games_res.Status_CompareFail,ccui.TextureResType.plistType)
	self.Status_panel:setVisible(true)

	self:hideHandlePanel()
end

--显示我的操作按钮
function Myself:showMyhandlePanel()
	if self._info.fold ~= 1 and (self._info.compare_failed~=1 and self._info.status == 1030 or self._info.status == 1045) then
		self:showHandleButton()
	
		self.Raise_panel:setVisible(false)
		self.Raise_panel:setTouchEnabled(false)
		
	end


	--弃牌了 就别显示了
	if self._info.fold == 1 then
		--qf.event:dispatchEvent(ET.SHOW_QUICKLY_CHAT,{uin=self._uin})
		self:hideHandlePanel()
	end

end


--弃牌
function Myself:userFold(paras)
	-- if true then 
	-- 	qf.event:dispatchEvent(ET.SHOW_QUICKLY_CHAT,{bqtable=self.BQ_TABLE1})
	-- end
	local i = 1
	MusicPlayer:playMyEffectGames(Zjh_Games_res,"FLIP")
	local cards=self:cardRank(self._info.card)
	for k,v in pairs(self._cards) do
		v:setValue(cards[i])

		if self._info.look == nil or self._info.look == false then

			v:showFront()
		end
		v:dark()
		v:stopAllActions()
		i= i + 1
	end
	if self._cards and #self._cards==3 then
		self._cards[1]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,-25),cc.MoveTo:create(0.2,self.CardPos.look[1])))
		self._cards[2]:runAction(cc.MoveTo:create(0.2,self.CardPos.look[2]))
		self._cards[3]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,25),cc.MoveTo:create(0.2,self.CardPos.look[3])))
		-- self._cards[1]:setRotation(-25)
		-- self._cards[1]:setPositionX(self.CardPos.look[1].x)
		-- self._cards[2]:setPosition(self.CardPos.look[2].x,self.CardPos.look[2].y)
		-- self._cards[3]:setRotation(25)
		-- self._cards[3]:setPositionX(self.CardPos.look[3].x)
	end
	self._info.look = 1
	self:showCardType()
	self:hideHandleButtonNoAnimate(true)
	self:GiveUpCard()

	--qf.event:dispatchEvent(ET.SHOW_QUICKLY_CHAT,{uin=self._uin})

end

function Myself:showHandleButtonAnimate(btn,isShow)
	-- body
	btn:stopAllActions()
	if isShow then 
		btn:runAction(cc.MoveTo:create(0.2,cc.p(btn:getPositionX(),65)))
	else
		btn:runAction(cc.MoveTo:create(0.2,cc.p(btn:getPositionX(),-150)))
	end
end

function Myself:hideHandleButtonNoAnimate(isShow)
	-- body
	self.flod:stopAllActions()
	self.compare:stopAllActions()
	self.call:stopAllActions()
	self.raise:stopAllActions()
--	self.fire:stopAllActions()
	self.auto:stopAllActions()
	if isShow then 
		self.flod:runAction(cc.MoveTo:create(0.2,cc.p(self.flod:getPositionX(),-150)))
		self.compare:runAction(cc.MoveTo:create(0.2,cc.p(self.compare:getPositionX(),-150)))
		self.call:runAction(cc.MoveTo:create(0.2,cc.p(self.call:getPositionX(),-150)))
		self.raise:runAction(cc.MoveTo:create(0.2,cc.p(self.raise:getPositionX(),-150)))
--		self.fire:runAction(cc.MoveTo:create(0.2,cc.p(self.fire:getPositionX(),-150)))
		self.auto:runAction(cc.MoveTo:create(0.2,cc.p(self.auto:getPositionX(),-150)))
	else
		self.flod:setPositionY(-150)
		self.compare:setPositionY(-150)
		self.call:setPositionY(-150)
		self.raise:setPositionY(-150)
--		self.fire:setPositionY(-150)
		self.auto:setPositionY(-150)
	end
end

--显示按钮
function Myself:showHandleButton()
	-- body
	--qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT,{uin=self._uin})
	self.mine_handle_panel:setVisible(true)
	if (Cache.zjhdesk.next_uin ~= Cache.user.uin or self._info.auto_call == 1 ) then
		--self._parent_view:cancelPkkuang({flag=1})
		if self._info.fold == 1 then
			self:hideHandlePanel()
			return
		end
		self:SetPlayerLight(false)
		self:showHandleButtonAnimate(self.flod,true)
		self:showHandleButtonAnimate(self.compare,false)
		self:showHandleButtonAnimate(self.call,false)
		self:showHandleButtonAnimate(self.raise,false)
--		self:showHandleButtonAnimate(self.fire,false)
		self:showHandleButtonAnimate(self.auto,true)
		self.Raise_panel:setVisible(false)
		self.Raise_panel:setTouchEnabled(false)
		--self.call:setVisible(false)
	else
		self:SetPlayerLight(false)
--		self:showHandleButtonAnimate(self.fire,true)
		self.call:setVisible(true)

		self:showHandleButtonAnimate(self.auto,false)
		if Cache.zjhdesk.can_operator_arr['qi'] then
			self.flod:setOpacity(255)
			self.flod:setTouchEnabled(true)
		else
			self.flod:setOpacity(125)
			self.flod:setTouchEnabled(false)
		end
		self:showHandleButtonAnimate(self.flod,true)

		if Cache.zjhdesk.can_operator_arr['bi'] then
			self.compare:setOpacity(255)
			self.compare:setTouchEnabled(true)
		else
			self.compare:setOpacity(125)
			self.compare:setTouchEnabled(false)
		end
		self:showHandleButtonAnimate(self.compare,true)


		if Cache.zjhdesk.can_operator_arr['gen'] and self.call:getValue() <=Cache.zjhdesk._player_info[Cache.user.uin].gold then
			self.call:setOpacity(255)
			self.call:setTouchEnabled(true)
		else
			self.call:setOpacity(125)
			self.call:setTouchEnabled(false)
		end
		self:showHandleButtonAnimate(self.call,true)

		local rate  = 1
		if  self._info.look or self._info.status==1045 then	
			rate = 2
			self.look:setVisible(false)
		elseif self._info.status~=1020 and self._info.status~=1050 and self._info.look==false then
			self.look:setVisible(true)
		end



		local now_chips  = Cache.zjhdesk.now_chips*rate

		local flag   = false

		for i=2,5 do
			local item   = self["raise_"..i]
			if item then
				local value  = item:getValue()
				local fnt = item:getChildByName("font")
				if 	value <= Cache.packetInfo:getProMoney(Cache.zjhdesk._player_info[Cache.user.uin].gold) and  value > now_chips then
					-- item:setBright(true)
					-- item:setEnabled(true)
					Util:ensureBtn(item, true)
					flag   = true
				else
					-- item:setBright(false)
					-- item:setEnabled(false)
					Util:ensureBtn(item, false)
				end		
			end
		end

		if  flag and Cache.zjhdesk.next_uin == Cache.user.uin then
			self.raise:setOpacity(255)
			self.raise:setTouchEnabled(true)
		else
			self.raise:setOpacity(125)
			self.raise:setTouchEnabled(false)
		end
		self:showHandleButtonAnimate(self.raise,true)
		MusicPlayer:playMyEffectGames(Zjh_Games_res,"NOWISME")
	end
end



--比牌让牌飞起来
function Myself:pkCardFly(win_uin,lost_uin)
	Scheduler:delayCall(1.0,function ( ... )
			-- body
			MusicPlayer:playMyEffectGames(Zjh_Games_res,"BI_PAI") --比牌的雷电声
		end)
	Scheduler:delayCall(2.0,function ( ... )
			-- body
			MusicPlayer:playMyEffectGames(Zjh_Games_res,"ZHADAN") --比牌的炸弹声
		end)
	self.card_kind:setVisible(false)
	local side       = self:calcLeftOrRight(win_uin,lost_uin)
	local new_panel  = self.user_info_panel:clone()
	new_panel:setVisible(true)
	new_panel:getChildByName("gift"):setVisible(false)
	new_panel:getChildByName("user_status"):setVisible(false)
	new_panel:getChildByName("zhuang"):setVisible(false)
	Util:updateUserHead(new_panel:getChildByName("icon"), Cache.user.portrait, self._info.sex, {add=true,sq=true, url=true})
	new_panel:setPosition(self.user_info_panel:getWorldPosition().x,self.user_info_panel:getWorldPosition().y)
	new_panel:setZOrder(102)
	self._parent_view:addChild(new_panel)

	self.cards_panel:setVisible(false)

	local hideview = cc.CallFunc:create(handler(self,function() 
			self:setVisible(false)
		end)
	)
	local scale = cc.ScaleTo:create(1,1.2)
	local move  = cc.MoveTo:create(0.1,cc.p(self.Card_Positon[side]['x']-new_panel:getContentSize().width/2,self.Card_Positon[side]['y']-new_panel:getContentSize().height/2))
	local scale_s  = cc.ScaleTo:create(0.1,1)
	local delay     = cc.DelayTime:create(1.7)					--等待动画播完	
	local card_dark = cc.CallFunc:create(handler(self,function() 
			if lost_uin == self._uin then
				new_panel:setColor(Theme.Color.DARK)
			end
		end)
	)
	local delay_t   = cc.DelayTime:create(0.8)
	local failed    = cc.CallFunc:create(handler(self,function()--显示失败		                                                      
			qf.event:dispatchEvent(Zjh_ET.HIDE_ZHEZHAO,{}) --隐藏遮罩层
		end)
	)
	local delay_c   = cc.DelayTime:create(0.5)
	local move_back = cc.MoveTo:create(0.5,cc.p(self.user_info_panel:getWorldPosition().x,self.user_info_panel:getWorldPosition().y))                    --move到原来位置
	local showview = cc.CallFunc:create(handler(self,function() 
			self:setVisible(true)
		end)
	)

	local hide_panel= cc.CallFunc:create(handler(self,function()		   --删除panel 显示输家比牌失败
			if new_panel then
				self._parent_view:removeChild(new_panel)
			end
			self.card_kind:setVisible(true)
			self.cards_panel:setVisible(true)
			if not Cache.zjhdesk.iscompare then
				self:reconnect()
				return
			end

			if lost_uin == self._uin then
				local i = 1
				MusicPlayer:playMyEffectGames(Zjh_Games_res,"FLIP")
				local cards=self:cardRank(self._info.card)
				for k,v in pairs(self._cards) do
					v:setValue(cards[i])
					v:dark()
					v:showFront()
					v:stopAllActions()
					i = i + 1
				end
				if self._cards and #self._cards==3 then
					self._cards[1]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,-25),cc.MoveTo:create(0.2,self.CardPos.look[1])))
					self._cards[2]:runAction(cc.MoveTo:create(0.2,self.CardPos.look[2]))
					self._cards[3]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,25),cc.MoveTo:create(0.2,self.CardPos.look[3])))
					-- self._cards[1]:setRotation(-25)
					-- self._cards[1]:setPositionX(self.CardPos.look[1].x)
					-- self._cards[2]:setPosition(self.CardPos.look[2].x,self.CardPos.look[2].y)
					-- self._cards[3]:setRotation(25)
					-- self._cards[3]:setPositionX(self.CardPos.look[3].x)
				end
				self:showCardType()
				self._info.look = 1
				self:CompareFail()	
				self:SetPlayerLight(true)
			end
		end)
	)
	if FULLSCREENADAPTIVE then 
		new_panel:setPositionX(new_panel:getPositionX()-self.winSize.width/2+1920/2)
		move     = cc.MoveTo:create(0.1,cc.p(self.Card_Positon[side]['x']-new_panel:getContentSize().width/2-self.winSize.width/2+1920/2,self.Card_Positon[side]['y']-new_panel:getContentSize().height/2))		            --移动到pk中间
		move_back = cc.MoveTo:create(0.5,cc.p(self.user_info_panel:getWorldPosition().x-self.winSize.width/2+1920/2,self:getWorldPosition().y))                    --move到原来位置
	end
	local spawn = cc.Spawn:create(move,scale_s)
	local sq  = cc.Sequence:create(hideview,scale,spawn,delay,card_dark,delay_t,failed,delay_c,move_back,showview,hide_panel)
	new_panel:runAction(sq)
end


--init button event
function  Myself:initButtonEvent()
	--弃牌
	addButtonEvent(self.flod,function()
		loga("点击弃牌")
		GameNet:send({cmd=Zjh_CMD.USER_RE_FOLD_CARD,body={uin=self._uin,desk_id=Cache.zjhdesk.deskid}},function (resp )
		end)
	end)


	--比牌
	addButtonEvent(self.compare,function ()
		-- body
		loga("点击比牌")
		MusicPlayer:playMyEffectGames(Zjh_Games_res,"COMPARE_BTN")
		
		self._parent_view:pkKuang()

		self:hideHandlePanel()
	end)




	local arr = {self.call,self["raise_2"],self["raise_3"],self["raise_4"],self["raise_5"]}



	--跟注 加注
	for k,v in ipairs(arr) do
		addButtonEvent(v,function(sender)
			local coin = sender:getValue()
			      coin = tonumber(coin)
			loga("点击加注")
			loga("coincoincoincoincoincoincoincoincoincoincoincoincoincoincoin:"..Cache.zjhdesk.now_chips)
			loga("coincoincoincoincoincoincoincoincoincoincoincoincoincoincoin:"..coin)
			--coin=-100000
			GameNet:send({cmd=Zjh_CMD.USER_RE_RAISE_CALL,body={uin=self._uin,desk_id=Cache.zjhdesk.deskid,call_money=Cache.packetInfo:getCProMoney(coin)}},function (resp )
				loga("跟住加注")
				loga(resp.ret)
			end)
		end)
	end


	--加注面板
	addButtonEvent(self.raise,function ()
		if self.Raise_panel:isVisible() then
			self.Raise_panel:setVisible(false)
			self.Raise_panel:setTouchEnabled(false)
			return
		end
		self.Raise_panel:setVisible(true)
		self.Raise_panel:setTouchEnabled(true)
	end)


	--看牌
	addButtonEvent(self.look,function()
		loga("点击看牌")
		-- body
		GameNet:send({cmd=Zjh_CMD.USER_RE_KAN_PAI,body={uin=self._uin,desk_id=Cache.zjhdesk.deskid}})

	end)


	
	


	--点击亮牌
	addButtonEvent(self.liang,function ()
		loga("点击亮牌")
		-- body
		GameNet:send({cmd=Zjh_CMD.RE_LIGHT_CARD,body={}})
	end)


	--火拼
--	addButtonEvent(self.fire,function ( ... )
--		-- body
--		local money = self.fire:getValue()
--		loga("火拼")
--		GameNet:send({cmd=Zjh_CMD.FIRE_RE,body={uin=self._uin,desk_id=Cache.zjhdesk.deskid,money=money,flag=1}})
--		qf.platform:umengStatistics({umeng_key="Click_on_the_button"})--点击上报
--	end)


end

--加注
function Myself:userRaise(paras)
	-- body
	self.super.userRaise(self,paras)
	self:showHandleButton()
end


function Myself:removeTimer (paras)
    -- logd("移除倒计时"..self.uin,self.TAG)
    -- if paras == nil or paras.overtime == false then self:stopOverTimer() end
    local userinfo =  self:getChildByName("user_info")
    self:unscheduleUpdate()
    self:cardsReduction()
    if userinfo:getChildByTag(self.startTag+2) then
	    userinfo:removeChildByTag(self.startTag+2)
	end
    self._timer = nil
end

function Myself:setLookVisible(islook)
	self.look:setVisible(islook)
end

--看牌
function Myself:userCheck(paras)
	MusicPlayer:playMyEffectGames(Zjh_Games_res,"FLIP")
	self:initButtonNum()
	self:showHandleButton()
	self.look:setVisible(false)
	local i = 1
	local cards=self:cardRank(self._info.card)
	for k,v in pairs(self._cards) do 
		v:setValue(cards[i])
		v:showFront()
		v:stopAllActions()
		i =i +1
	end
	if self._cards and #self._cards==3 then
		self._cards[1]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,-25),cc.MoveTo:create(0.2,self.CardPos.look[1])))
		self._cards[2]:runAction(cc.MoveTo:create(0.2,self.CardPos.look[2]))
		self._cards[3]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,25),cc.MoveTo:create(0.2,self.CardPos.look[3])))
	end
	self.Kind_font:setString(Zjh_GameTxt.CardType_txt[self._info.card_type])
	self.Kind_font:setVisible(true)
	self.Kind_font_bg:setVisible(true)
end


--显示牌型 1win 2fail
function Myself:showCardType()
	self.Kind_font:setString(Zjh_GameTxt.CardType_txt[self._info.card_type])
	self.Kind_font:setVisible(true)
	self.look:setVisible(false)
	self.Kind_font_bg:setVisible(true)
end

--hide handle panel
function Myself:hideHandlePanel()	
	self:hideHandleButtonNoAnimate(true)
	self.Raise_panel:setVisible(false)
	self.Raise_panel:setTouchEnabled(false)
end

function Myself:hideRaisePannel( ... )
	self.Raise_panel:setVisible(false)
	self.Raise_panel:setTouchEnabled(false)
end

--show handle panel
function Myself:showHandlePanel()
	if self._info.compare_failed~=1 and self._info.status == 1030 then
		self:hideHandleButtonNoAnimate(false)
		self:showHandleButton()
	end
end


--clear
function Myself:clear()
	qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
	self.cards_panel:removeAllChildren()

	self._cards = {}
	self:hideHandlePanel()
	self.look:setVisible(false)
	self.liang:setVisible(false)
	self.Kind_font_bg:setVisible(false)
	self.Kind_font:setVisible(false)
	self:HideStatusPanel()
	self.Kind_font_bg:setVisible(false)
	self._info.auto_call=nil
	self.cancelBtnAni:setVisible(false)
	self.callBtnAni:setVisible(true)
	self:setWaitingStartVis(false)
	self.addBetTips:stopAllActions()
	self.addBetTips:setVisible(false)

	--初始化按钮

   	if self._info.quit ==1 then
   		self._info.quit=nil
		self.gift:setVisible(false)
		self._parent_view._users[self._uin] = nil
		local fadeout    = cc.FadeOut:create(0.2)
		self:runAction(fadeout)
		self.gift:setTouchEnabled(false)
		self.icon:setTouchEnabled(false)
	end
end

--最后没看牌的话把牌旋转
function Myself:openCard()
	loga("     Myself:openCard")
	-- body
	local i = 1
	local cards=self:cardRank(self._info.card)
	for k,v in pairs(self._cards) do
		if not cards[i] then break end
		v:setValue(cards[i])
		v:showFront()
		v:stopAllActions()
		i =i +1
	end
	if self._cards and #self._cards==3 then
		self._cards[1]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,-25),cc.MoveTo:create(0.2,self.CardPos.look[1])))
		self._cards[2]:runAction(cc.MoveTo:create(0.2,self.CardPos.look[2]))
		self._cards[3]:runAction(cc.Spawn:create(cc.RotateTo:create(0.2,25),cc.MoveTo:create(0.2,self.CardPos.look[3])))
		-- self._cards[1]:setRotation(-25)
		-- self._cards[1]:setPositionX(self.CardPos.look[1].x)
		-- self._cards[2]:setPosition(self.CardPos.look[2].x,self.CardPos.look[2].y)
		-- self._cards[3]:setRotation(25)
		-- self._cards[3]:setPositionX(self.CardPos.look[3].x)
	end
	self.look:setVisible(false)
	if self._info.showcard ~= 1 and self._info.status  > 1020 then
		self.liang:setVisible(true)
		qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
		self.Kind_font:setString(Zjh_GameTxt.CardType_txt[self._info.card_type])
		self.Kind_font:setVisible(true)
		self.Kind_font_bg:setVisible(true)
	else
		self.liang:setVisible(false)
		
	end
	self._info.look = 1
end


function Myself:showCard()
	self.super.showCard(self)
	self.Kind_font:setVisible(false)
	self.Kind_font_bg:setVisible(false)
	self:clear()
end


--头像火
function Myself:kuangFire()
	local kuang_fire = self._parent_view.animation_layout:getChildByName("kuang_fire")
	if kuang_fire  then
		kuang_fire:removeFromParent()
	end
	local start_x =self:getPositionX()
	local start_y =self:getPositionY()

	start_x  =start_x + self:getChildByName("user_info"):getPositionX()
	start_y  =start_y + self:getChildByName("user_info"):getPositionY()

	-- self._parent_view.Gameanimation:play({scale=2,name="kuang_fire",anim=GameAnimationConfig.KUANGFIRE,order=101,forever=1,position={x=start_x,y=start_y},anchor=cc.p(0,0)})
	self._parent_view.Gameanimation:play({scale=2,name="kuang_fire",anim=GameAnimationConfig.KUANGFIRE,position={x=start_x-50,y=start_y-60},forever=1,anchor=cc.p(0,0)})
end

function Myself:showWinnerAni( ... )
	-- body
	local x=self:getChildByName("user_info"):getContentSize().width/2+self:getChildByName("user_info"):getPositionX()
	local y=self:getChildByName("user_info"):getContentSize().height/2+self:getChildByName("user_info"):getPositionY()
	self._parent_view.Gameanimation:play({node=self,scale=2,name="win money",anim=GameAnimationConfig.WINNERSHOW,position={x=x,y=y},anchor=cc.p(0.5,0.5)})
end


--断线重连
function Myself:reconnect()

	self:SetPlayerLight(false)
	if Cache.zjhdesk.status and Cache.zjhdesk.status>= 1 and self._info and self._info.status and self._info.status  > 1020 then
		-- self._info.draw  = 1  --标示已经绘制了牌桌的信息了
		self.cards_panel:setVisible(true)
		self.cards_panel:removeAllChildren()
		local card_tmp  = Card.new()
		local size      = card_tmp:getContentSize()
		local alllength = size.width*3-50*2
		local sizet     = self.card_kind:getContentSize()

		local panelsize   = self.cards_panel:getContentSize()
		local start_width =  (alllength-panelsize.width)/2

		self._cards = {}
		for i=1,3 do
			local card_tmp  = Card.new()
			table.insert(self._cards,card_tmp)
			self.cards_panel:addChild(card_tmp)
			card_tmp:setScale(1)
			card_tmp:setPosition(self.CardPos.nolook[i].x,self.CardPos.nolook[i].y)
		end

		if self._info.auto_call==1 then 
			self.cancelBtnAni:setVisible(true)
			self.callBtnAni:setVisible(false)
		else
			self.cancelBtnAni:setVisible(false)
			self.callBtnAni:setVisible(true)
   		end
   		self:initButtonNum()
   		if self._info.status ~= 1050 and self._info.compare_failed ~= 1 then
   			self:showHandlePanel()
   		end
	elseif Cache.zjhdesk.status==0 or self._info.status  == 1020 then
		self:hideHandleButtonNoAnimate(false)
		self:setWaitingStartVis(true)
		-- self:SetPlayerLight(true)
		return
	end

	if self._info.status == 1050 then
		self:GiveUpCard()
		self.Kind_font:setString(Zjh_GameTxt.CardType_txt[self._info.card_type])
		self.Kind_font:setVisible(true)
		self.Kind_font_bg:setVisible(true)
	end

	--是否弃牌
	if self._info.status == 1050 or self._info.fold == 1 or self._info.compare_failed == 1 then
		local i = 1
		local cards=self:cardRank(self._info.card)
		for k,v in pairs(self._cards) do
			v:setValue(cards[i])
			v:showFront()
			v:dark()
			i= i + 1
		end
		self._info.look=1
		if self._cards and #self._cards==3 then
			self._cards[1]:setRotation(-25)
			self._cards[1]:setPositionX(self.CardPos.look[1].x)
			self._cards[2]:setPositionY(self.CardPos.look[2].y)
			self._cards[3]:setRotation(25)
			self._cards[3]:setPositionX(self.CardPos.look[3].x)
		end
		-- self:showCardType()
		self:hideHandleButtonNoAnimate(false)
		self:SetPlayerLight(true)
		return
	end


	--是否看牌
	if self._info.look or self._info.status == 1045 then
		self:userCheck(true)
	elseif self._info.status~=1020 and self._info.status~=1050 and self._info.look==false then
		self.look:setVisible(true)
	end
end

function Myself:updateGiftBtn(paras)
    if self.disable_gift and self.gift:isVisible() then
        self.gift:setVisible(false)
    else
    	local updateBtn = function()
    		-- body
    		qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = self.gift,icon = paras})
    	end
    	if paras and paras >=2000 and paras<2006 then
    		qf.event:dispatchEvent(ET.SHOW_GIFTCAR_ANI,{id =paras,txt=self._info.nick,pos=self.gift:getWorldPosition(),cb=self.updateBtn,node = self})
    	else
        	self:updateBtn(paras)
    	end
        local u = Cache.zjhdesk:getUserByUin(self.uin)
        if u and u.decoration == -1 then --如果当前的用户礼物是空的，就改变其为最新的
           u.decoration = paras
        end
    end
end

-- 倒计时回调
function Myself:timeCounter(index)
    if index <= math.floor(self.defaultCountTimer/2) then
   		qf.platform:playVibrate(500) -- 震动
   		
   		self:cardShock(0)
        --MusicPlayer:playMyEffect("G_ALARM")
    end
end

-- 牌震动
function Myself:cardShock(time)
    --self:setCardPosition()
    time = time or 0
    self:cardsReduction()
    local actionTime = 0.15
   	local function _createScale1( ... )
    	local scaleBig1 = cc.EaseBackOut:create(cc.ScaleTo:create(actionTime,1.05))
   		return scaleBig1
   	end
   	local function _createScale2( ... )
    	local scaleSmall1 = cc.EaseBackOut:create(cc.ScaleTo:create(actionTime,1.0))
    	return scaleSmall1
   	end
   	local function _createScale3( ... )
    	local scaleBig2 = cc.EaseBackOut:create(cc.ScaleTo:create(actionTime,1.04))
    	return scaleBig2
   	end
   	local function _createScale4( ... )
    	local scaleSmall2 = cc.EaseBackOut:create(cc.ScaleTo:create(actionTime,1.0))
    	return scaleSmall2
   	end
   	local function _createScale5( ... )
    	local scaleBig3 = cc.EaseBackOut:create(cc.ScaleTo:create(actionTime,1.02))
    	return scaleBig3
   	end
   	local function _createScale6( ... )
    	local scaleSmall3 = cc.EaseBackOut:create(cc.ScaleTo:create(actionTime,1.0))
    	return scaleSmall3
   	end
    for k,v in pairs(self._cards) do
    	if v==nil then return end
    	v:runAction(cc.Sequence:create(_createScale1(),_createScale2(),_createScale3(),_createScale4(),_createScale5(),_createScale6()))
    end
end
function Myself:setWaitingStartVis(bvis)
	self.showWaitingStart:setVisible(bvis)
end

-- 还原牌的状态
function Myself:cardsReduction()
	-- for k,v in pairs(self._cards) do
	-- 	if v==nil then return end
	-- 	v:setScale(1)
	-- 	if not self._info.look and self._info.fold~=1 and self._info.compare_failed~=1 then 
	-- 		v:stopAllActions()
	-- 		v:setRotation(0)
	-- 	end
	-- end
end

function Myself:playShowChatMsg(txt_layer, msg)
	local corner =  GameConstants.CORNER.LEFT_DOWN
	-- local txt_layer= self._parent_view.chat_txt_layer
	txt_layer:playShowChatMsg(self.user_info_panel, self.icon, {
        corner = corner,
		msg = msg,
		chatname = "myself"
	})
    self.chatnode = node
end

--显示表情
function Myself:emoji(index, Emoji_index)
	self._parent_view.Gameanimation:play({node=self.icon,anim=Emoji_index[index].animation,index=Emoji_index[index].index,scale=2,position=self.Emoji_position,order=5, posOffset = {x = -340, y = -25}})
end

return Myself