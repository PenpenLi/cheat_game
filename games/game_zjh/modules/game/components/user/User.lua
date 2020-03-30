local Handlebutton  =  import("src.games.game_zjh.modules.game.components.button.Handlebutton")
local Card          =  import("src.games.game_zjh.modules.game.components.card.Card")
local GameAnimationConfig = import("..animation.AnimationConfig")
local Useranimation = import(".Useranimation")
local Gift = import("..Gift")
local User          =  class("User",function (paras)
    return paras.node
 end)


User.Nick           = "nick"           --玩家昵称name
User.Gold           = "gold"           --玩家金币name
User.Icon           = "icon"           --玩家图像name
User.Card_panel     = "card_panel"      --玩家手牌容器
User.OverBg    		= "overbg"     	 --遮掩图片
User.startTag       = 500
User.Bg             = "bg"             
User.Status_panel   = "user_status"    --用户状态
User.GIFT   = "gift"    --小礼物

User.show_card_bgpanel ="show_card_panel"
User.show_card_gold	   ="gold"
User.show_card_panel   ="card_panel"
User.show_card_kind	   ="card_kind"
User.show_win_kuang	   ="win_kuang"

User.Card_Anim_Time  = 0.4   --发牌动画时间
User.Card_Anim_Space = 0.04  --牌之间的间隔时间
User.defaultCountTimer = 12


User.hatTag = 9873--美女皇冠tag

--玩家各种起始坐标
User.Card_Positon  = {
		user_first = {
			--发牌的中间坐标
			center = {
				x=455,
				y=260,
			},
			--牌的坐标
			card = {
				x = -160,
				y = 100,
			},
			--扔筹码的起始坐标
			chip_start={
				x = -500,
				y = -70,
			},
			panel_card = {
				x = 322.3 ,
				y = 385.9
			},
		},


		user_second = {
			center = {
				x=455,
				y=-50,
			},
			card = {
				x = -160,
				y = 100,
			},
			chip_start={
				x = -500,
				y = 230,
			},
			panel_card = {
				x = 323.5 ,
				y = 697
			},
		},
		user_third = {
			center = {
				x=-150,
				y=-50,
			},
			card = {
				x = 330,
				y = 100,
			},
			chip_start={
				x = 1150,
				y = 230,
			},

			panel_card = {
				x = 1452.2,
				y = 696.9	
			},
		},

		user_fourth = {
			center = {
				x=-150,
				y=260,
			},
			card = {
				x = 330,
				y = 100,
			},
			chip_start={
				x = 1150,
				y = -70,
			},
			panel_card = {
				x = 1452.4,
				y = 385.9	
			},
		},

		--pk左边的位置
		left_pk = {
			x = Display.cx/2-500,
			y = 550,
		},

		--pk右边边的位置
		right_pk = {
			x = Display.cx/2+500,
			y = 550,
		},

	}

-- chat layer position --
User.Chat_position = {
	[0] = {
		x = 750,
		y = 500 
	},
	[1] = {
		x = 1440,
		y = 450 
	},
	[2] = {
		x = 1350,
		y = 800
	},
	[3] = {
		x = 550,
		y = 800,
	},
	[4] = {
		x = 480,
		y = 450,
	},
	[5] = {
		x = 1000,
		y = 500,
	},
}
--emoji position --
User.Emoji_position = cc.p(100,140)

function User:ctor ( paras )
	self.winSize = cc.Director:getInstance():getWinSize()
	self._parent_view = paras.view
	self:init(paras) 
	-- self:setZOrder(1)	

end

--计算pk时牌向左还是向右移动
function User:calcLeftOrRight(win_uin,lost_uin)
 	local other_uin    = win_uin == self._uin and lost_uin or win_uin
 	local my_index     = self:getIndex(self._uin)
 	local other_index  = self:getIndex(other_uin)
	local side         = ""
	if my_index == 0 then
		side =  other_index/2 > 1 and "right_pk" or "left_pk"
	elseif other_index==0 then
		side =  my_index/2 > 1 and "left_pk" or "right_pk"
	else
		side =  my_index < other_index and "right_pk" or "left_pk"
	end

	return side
end


function User:getSexByCache(uin)
    if uin == -1 then return 0 end
    local u = Cache.zjhdesk._player_info[uin]  
    if u == nil then return 0 end

    u.sex = u.sex==2 and 0 or u.sex
    return u.sex or 0

end

--比牌让牌飞起来
function User:pkCardFly(win_uin,lost_uin)
	Scheduler:delayCall(1.0,function ( ... )
			-- body
			MusicPlayer:playMyEffectGames(Zjh_Games_res,"BI_PAI") --比牌的雷电声
		end)
	Scheduler:delayCall(2.0,function ( ... )
			-- body
			MusicPlayer:playMyEffectGames(Zjh_Games_res,"ZHADAN") --比牌的炸弹声
		end)
	local side      = self:calcLeftOrRight(win_uin,lost_uin)
	local new_panel = self:clone()
	self._parent_view:addChild(new_panel)
	new_panel:getChildByName("gift"):setVisible(false)
	new_panel:getChildByName("user_status"):setVisible(false)
	new_panel:getChildByName("zhuang"):setVisible(false)
	Util:updateUserHead(new_panel:getChildByName("icon"), self._info.portrait, self._info.sex, {add=true,sq=true, url=true})
	new_panel:setPosition(self:getWorldPosition().x,self:getWorldPosition().y)
	new_panel:setZOrder(102)
	new_panel:setVisible(true)
	
	self.cards_panel:setVisible(false)

	local hideview = cc.CallFunc:create(handler(self,function() --隐藏自己的头像
				self:setVisible(false)
		end)
	)
	local scale    = cc.ScaleTo:create(1,1.2)--牌放大
	local move     = cc.MoveTo:create(0.1,cc.p(self.Card_Positon[side]['x']-new_panel:getContentSize().width/2,self.Card_Positon[side]['y']-new_panel:getContentSize().height/2))		            --移动到pk中间

	local scale_s  = cc.ScaleTo:create(0.1,1)
	local delay     = cc.DelayTime:create(1.7)					--等待动画播完	
	local card_dark = cc.CallFunc:create(handler(self,function() 
				if lost_uin == self._uin then
					new_panel:setColor(Theme.Color.DARK)
				end
			end)
		)
	local delay_t   = cc.DelayTime:create(0.8)
	local failed    = cc.CallFunc:create(handler(self,function()	                                                      
				qf.event:dispatchEvent(Zjh_ET.HIDE_ZHEZHAO,{}) --隐藏遮罩层
			end)
		)
	local delay_c   = cc.DelayTime:create(0.5)
	local move_back = cc.MoveTo:create(0.5,cc.p(self:getWorldPosition().x,self:getWorldPosition().y))                    --move到原来位置
	local showview = cc.CallFunc:create(handler(self,function() 
				self:setVisible(true)
			end))

	local hide_panel= cc.CallFunc:create(handler(self,function()		   --删除panel 显示输家比牌失败
			if new_panel then
				self._parent_view:removeChild(new_panel)
			end
			self.cards_panel:setVisible(true)
			if not Cache.zjhdesk.iscompare then
				self:reconnect()
				return
			end
			if lost_uin == self._uin then
				for k,v in pairs(self._cards) do
					v:dark()
				end
				self:SetPlayerLight(true)
				self:CompareFail()
			end

		end)
	)
	if FULLSCREENADAPTIVE then 
		new_panel:setPositionX(new_panel:getPositionX()-self.winSize.width/2+1920/2)
		move     = cc.MoveTo:create(0.1,cc.p(self.Card_Positon[side]['x']-new_panel:getContentSize().width/2-self.winSize.width/2+1920/2,self.Card_Positon[side]['y']-new_panel:getContentSize().height/2))		            --移动到pk中间
		move_back = cc.MoveTo:create(0.5,cc.p(self:getWorldPosition().x-self.winSize.width/2+1920/2,self:getWorldPosition().y))                    --move到原来位置
	end
	local spawn     = cc.Spawn:create(move,scale_s)    --移动到pk中间 缩小 和 hide  同时进行
	local sq = cc.Sequence:create(hideview,scale,spawn,delay,card_dark,delay_t,failed,delay_c,move_back,showview,hide_panel)
	new_panel:runAction(sq)
	self:showChipAndGold()
end

function User:CompareFail()--比牌失败
	-- body
	loga("User:CompareFail()")
	local bg = self.Status_panel:getChildByName("bg")
	bg:loadTexture(Zjh_Games_res.Status_CompareFail,ccui.TextureResType.plistType)
	bg:setVisible(true)
	self.Status_panel:getChildByName("look_bg"):setVisible(false)
	self.Status_panel:setVisible(true)
end


--初始化user
function User:init(paras)
	local icon_btn         = ccui.Helper:seekWidgetByName(self,User.Icon)           --玩家图像name
	self.nick              = ccui.Helper:seekWidgetByName(self,User.Nick)           --玩家昵称name
	self.gold              = ccui.Helper:seekWidgetByName(self,User.Gold)           --玩家金币name
	self.cards_panel       = ccui.Helper:seekWidgetByName(self,User.Card_panel)     --玩家手牌容器
	self._bg               = ccui.Helper:seekWidgetByName(self,User.Bg)             --玩家信息背景
	self.Status_panel      = ccui.Helper:seekWidgetByName(self,User.Status_panel)   --玩家状态
	self.overbg     	   = ccui.Helper:seekWidgetByName(self,User.OverBg)  	 --玩家遮掩层
	self.zhuangIcon		   = ccui.Helper:seekWidgetByName(self,"zhuang")  --玩家庄家符号
	self.addBetTips		   = ccui.Helper:seekWidgetByName(self,"addbetTips")  --玩家加注符号
	self.showWaitingStart  = ccui.Helper:seekWidgetByName(self,"waitingStart")  --等待开始

	self.defaultCountTimer = 12
	self.selfSize          = self._bg:getContentSize()
	self.progresstimer     = Zjh_Games_res.progresstimer
	self._panel_name       = self:getName()                                         --用户panel名称
	self._cards            = {}  


	ccui.Helper:seekWidgetByName(self,User.GIFT):setTouchEnabled(true)


	self._uin   = paras.uin
	self._info  = Cache.zjhdesk._player_info[self._uin]  
	self.nick:setString(self._info.nick)
    self.gold:setContentSize(cc.size(195,50))
	self.gold:setString(Util:getFormatString(self._info.chips+Cache.packetInfo:getProMoney(self._info.gold)))--setString(Util:getFormatString(self._info.chips+self._info.gold,1))
	self:updateBeauty()--显示美女标识



	-- self.icon:setTouchEnabled(true)
	-- addButtonEvent(self.icon,function ()
	-- 	qf.event:dispatchEvent(Zjh_ET.GAME_SHOW_USER_INFO,{uin=self._uin})
	-- end)
	--头像按钮事件
    local function buttonEvent(sender, eventType)
    	if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        if eventType == CommonWidget.CButton.EVENT.CLICK or eventType == CommonWidget.CButton.EVENT.DOUBLE_CLICK then
        	if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
            local gold=Cache.zjhdesk.magic_express_money and Cache.zjhdesk.magic_express_money or 0
            local localinfo={gold=Cache.zjhdesk._player_info[self._uin].gold+Cache.zjhdesk._player_info[self._uin].chips,
            				nick=self._info.nick,
            				portrait=self._info.portrait,
            				sex=self._info.sex}
            if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 then
            	qf.event:dispatchEvent(Zjh_ET.GAME_SHOW_USER_INFO,{uin=self._uin,localinfo=localinfo})
            else
            	qf.event:dispatchEvent(Zjh_ET.GAME_SHOW_USER_INFO,{uin=self._uin,face={gold=gold},localinfo=localinfo})
            end
        elseif eventType == CommonWidget.CButton.EVENT.LONG_PRESS_DOWN then
        	if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 then return end
        	if not self.stt_button_press then
	        	self.stt_button_press = true
	        	local pos
	        	local dir
	        	local gold=Cache.zjhdesk.magic_express_money and Cache.zjhdesk.magic_express_money or 0
	        	local seatid=self._info.seatid- Cache.user.meIndex
	        	seatid= seatid<0 and seatid+5 or seatid

	        	dir=seatid>2 and 4 or 3
	        	pos=seatid<=2 and cc.p(self:getPositionX(),self:getPositionY()+self:getContentSize().height/2) or cc.p(self:getPositionX()+self:getContentSize().width,self:getPositionY()+self:getContentSize().height/2)
	        	local paras={uin=self._uin,pos=pos,dir=dir,gold=gold}
	            qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION,paras)
	        end
	    elseif eventType == CommonWidget.CButton.EVENT.LONG_PRESS_UP then

            self.stt_button_press = nil
        end
    end
    end

    --头像按钮事件
    self.icon = CommonWidget.CButton.new(icon_btn)
	self.icon:setTouchEnabled(true)
    --self.icon:setPressedActionEnabled(true)
    self.icon:addButtonEventListener(buttonEvent)

    Util:updateUserHead(self.icon, self._info.portrait, self._info.sex, {add=true, sq=true,url=true})
	
	
	self:playerInfoShow(true)
	

    self.gift = ccui.Helper:seekWidgetByName(self,User.GIFT)
    self:updateBtn(-1)
    addButtonEvent(self.gift,function ( sender )
    	if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        local type 
        --if ModuleManager:judegeIsIngame() then
            type = self._uin == Cache.user.uin and 3 or 4
        --end
        qf.event:dispatchEvent(ET.SHOW_GIFT,{name="gift",from=self.TAG, type = type, uin = self._uin ,gifts = self.gifts })
    	end
    end)
    self.gift:setVisible(false)
    self.gift:setTouchEnabled(true)
	if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.gift:setVisible(false)
    end
end


--退出房间
function User:quitRoom(times)

	self._info.quit = 1
	self:removeTimer()
	self:clear()

end


--弃牌
function User:userFold(paras)
	MusicPlayer:playMyEffectGames(Zjh_Games_res,"FLIP")
	self:GiveUpCard()
	self:cancelPkkuang()
end

function User:SetPlayerLight(flag)--遮掩
	-- body
	local isLight=false
	if flag == nil  then
		loga("self._info.status:"..self._info.status)
		loga("Cache.zjhdesk.status:"..Cache.zjhdesk.status)
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

function User:setWaitingStartVis(bvis)
	self.showWaitingStart:setVisible(bvis)
end

--显示
function User:show(times)
	self:setVisible(true)
	local fadeout    = cc.FadeIn:create(times)
	self:runAction(fadeout)
end


function User:clear()

	self.cards_panel:removeAllChildren()
	self:HideStatusPanel()
	self:SetPlayerLight(false)	
	self:setWaitingStartVis(false)	
	self.addBetTips:stopAllActions()
	self.addBetTips:setVisible(false)
	self._cards = {}
	if self._info.quit ==1 then
		self._info.quit=nil
		self.gift:setVisible(false)
		local kuang_fire = nil 
		if self._parent_view.animation_layout then
			kuang_fire = self._parent_view.animation_layout:getChildByName("kuang_fire")
		end
		if kuang_fire  then
			kuang_fire:removeFromParent()
		end
		if Cache.zjhdesk._player_info[self._uin] and (Cache.zjhdesk._player_info[self._uin].compare_failed or Cache.zjhdesk._player_info[self._uin].compare_win) then
			if Cache.zjhdesk._player_info[self._uin].compare_failed==1 then
				self.showcardInfo={iswin=false,cardinfo=self._info.card,cardtype=self._info.card_type,goldnum=self._info.gold}
			else
				self.showcardInfo={iswin=true,cardinfo=self._info.card,cardtype=self._info.card_type,goldnum=self._info.gold}
			end
		else
			self._parent_view._users[self._uin] = nil
		end
		local fadeout    = cc.FadeOut:create(0.2)
		self:runAction(fadeout)
		ccui.Helper:seekWidgetByName(self,User.GIFT):setTouchEnabled(false)
		self.icon:setTouchEnabled(false)
	end
end


-- 添加倒计时的时候，发送消息给 控制器,然后来改变按钮状态
function User:addTimer (paras)
    if self._timer then 
    	self:removeTimer() 
	end

    paras = paras or {}
    local costTime = paras.time or 0
    local percent = 100*(self.defaultCountTimer - costTime)/self.defaultCountTimer
    local timer = cc.ProgressTimer:create(cc.Sprite:create(self.progresstimer))
    timer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    timer:setReverseDirection(true)
    timer:setScale(0.96)
    timer:setPercentage(percent)

	timer:setPosition(self.selfSize.width/2,self.selfSize.height/2)
    timer:setTag(self.startTag+2)


    local userinfo =  self:getChildByName("user_info")
    if userinfo then
    	userinfo:addChild(timer,1)
    else
    	self:addChild(timer,1)
    end
    


    self._timev    = self.defaultCountTimer - costTime 
    self._preTimev = self.defaultCountTimer - costTime - 1 
    self._timer = timer
    self._timer:setColor(self:getGradualValue())


    self.timeoverPlayerMusic = true
    self:scheduleUpdateWithPriorityLua(handler(self,self._timeCounterInFrames),0)



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
    if self._timer == nil then 
    	self:removeTimer() 
    	self.timeoverPlayerMusic=nil
    	return 
    end
    self._timer:setColor(self:getGradualValue())
    self._timer:setPercentage(self._timev*100/self.defaultCountTimer)
    if self._timev < self._preTimev then 
    	if self._uin==Cache.user.uin then--倒计时震动扑克
       		self:timeCounter(self._preTimev)
       		if self.timeoverPlayerMusic~=nil and self._preTimev <= math.floor(self.defaultCountTimer/2) then
       			MusicPlayer:playEffectFile(Zjh_Games_res.all_music.TimeIsOver)
       			self.timeoverPlayerMusic=nil
       		end
       	end
        self._preTimev = self._preTimev - 1.2
    end

    if self._timev < 0.000001 then
        self:removeTimer({timeover = true})
        self.timeoverPlayerMusic=nil
    end
end


function User:removeTimer (paras)
    -- logd("移除倒计时"..self.uin,self.TAG)
    -- if paras == nil or paras.overtime == false then self:stopOverTimer() end
    self:unscheduleUpdate()
    if self:getChildByTag(self.startTag+2) then
	    self:removeChildByTag(self.startTag+2)
	end
    self._timer = nil
    self.timeoverPlayerMusic=nil
end


function User:setSendCardTime(time,gamenum)--设置发牌初始时间和人数
	-- body
	self.sendcardTime=time
	self.sendcardNum=gamenum
end

--发牌动画
function User:sendCardAnim()
	loga("播放 玩家 发牌 动画 XXXXXXXXXXXXX sendCardAnim")

	if self._info.status == 1030 then
		self.cards_panel:setVisible(true)
		local tx = self.cards_panel:getPositionX()
		local ty = self.cards_panel:getPositionY()
		local ttx = self:getPositionX()
		local tty = self:getPositionY()

		self.cards_panel:removeAllChildren()
		self._cards      = {}

		local card_tmp  = Card.new()
		local size      = card_tmp:getContentSize()
		local alllength = (4*55+size.width)*0.7
		local panelsize = self.cards_panel:getContentSize()
		local start_width =  (panelsize.width - alllength)/2
		start_width = size.width/2*0.7+start_width

		MusicPlayer:playMyEffectGames(Zjh_Games_res,"FLIP")
		for i=1,3 do
			local card_tmp  = Card.new()
			table.insert(self._cards,card_tmp)
			self.cards_panel:addChild(card_tmp)
			local name = self._panel_name
			card_tmp:setScale(0.7)
			card_tmp:setPosition(Display.cx/2-tx-ttx,Display.cy/2-ty-tty)
			local delay     = cc.DelayTime:create(self.sendcardTime*0.05+(i-1)*0.05*self.sendcardNum+User.Card_Anim_Space*(3-i))
			local move      = cc.MoveTo:create(User.Card_Anim_Time,cc.p(size.width/2+(i-1)*40,size.height/2))
			local rotation 	= cc.RotateBy:create(self.sendcardTime*0.05+(i-1)*0.05*self.sendcardNum+User.Card_Anim_Space*(3-i)+User.Card_Anim_Time,360)
			local sp        = cc.Spawn:create(cc.Sequence:create(delay,move),rotation)
			card_tmp:runAction(sp)
		end
	end
end



--丢筹码
function  User:diuChip(paras)
	
	Useranimation:xiaZhu(paras)
	--MusicPlayer:playMyEffectGames(Zjh_Games_res,"DIU_CHIPS")
end

function User:showWinnerAni( ... )
	-- body
	self._parent_view.Gameanimation:play({node=self,scale=2,name="win money",anim=GameAnimationConfig.WINNERSHOW,position={x=self:getContentSize().width/2,y=self:getContentSize().height/2},anchor=cc.p(0.5,0.5)})
end

--显示pk选择的框
function User:pkKuang()
	self:cancelPkkuang()
	local index = self:getIndex(self._uin)

	local kuang = ccui.ImageView:create(Zjh_Games_res.PK_KUANG)
	local arrow = cc.Sprite:create(Zjh_Games_res.PK_ARROW)
	local arrow_move = 0
	GAME_SCALE = 1
	local movein = nil
	local moveout= nil 
	if index <=2 then
		arrow:setRotation(180)
		arrow_move = 10
		kuang:setPosition(-20*GAME_SCALE,133*GAME_SCALE)
		arrow:setPosition(-300*GAME_SCALE,200*GAME_SCALE)
		movein  = cc.MoveTo:create(0.5,cc.p(-300*GAME_SCALE+arrow_move,200*GAME_SCALE))
		moveout = cc.MoveTo:create(0.5,cc.p(-300*GAME_SCALE-arrow_move,200*GAME_SCALE))
	else
		kuang:setPosition(210*GAME_SCALE,133*GAME_SCALE)
		arrow:setPosition(500*GAME_SCALE,200*GAME_SCALE)

		arrow_move = -10
		movein  = cc.MoveTo:create(0.5,cc.p(500*GAME_SCALE+arrow_move,200*GAME_SCALE))
		moveout = cc.MoveTo:create(0.5,cc.p(500*GAME_SCALE-arrow_move,200*GAME_SCALE))
	end
	
	kuang:setOpacity(600)
	local fadeout = cc.FadeTo:create(0.5, 200)
	local fadeint = cc.FadeTo:create(0.5, 600)
	local sq      = cc.Sequence:create(fadeout,fadeint)
	local rep     = cc.RepeatForever:create(sq)
	kuang:runAction(rep)
	
	
	local sq      = cc.Sequence:create(movein,moveout)
	local rep     = cc.RepeatForever:create(sq)
	arrow:runAction(rep)
	self:addChild(kuang,101)
	self:addChild(arrow,101)
	kuang:setName("kuang"..tostring(self._uin))
	arrow:setName("arrow"..tostring(self._uin))

	kuang:setZOrder(200)
	kuang:setTouchEnabled(true)
	addButtonEvent(kuang,function ()

		MusicPlayer:playMyEffectGames(Zjh_Games_res,"COMPARE_BTN_CHOOSE")
		
		-- body
		GameNet:send({cmd=Zjh_CMD.USER_RE_COMPARE,body={uin=Cache.user.uin,desk_id=Cache.zjhdesk.deskid,compare_uin=self._uin}})

		self._parent_view:cancelPkkuang({flag=1})
	end)
end

--去除pkkuang
function User:cancelPkkuang()
	-- body
	local kuang = self:getChildByName("kuang"..tostring(self._uin))

	local arrow = self:getChildByName("arrow"..tostring(self._uin))

	if kuang then
		self:removeChildByName("kuang"..tostring(self._uin))
	end

	if arrow then
		self:removeChildByName("arrow"..tostring(self._uin))
	end
--clear	
end



--获得座位序号
function User:getIndex(uin)
	print("seatid", Cache.zjhdesk._player_info[uin].seatid)
	print("meIndex >>>>", Cache.user.meIndex)
	

	local seat = Cache.zjhdesk._player_info[uin].seatid
	local cut = seat - Cache.user.meIndex
	-- if cut 
	if cut < 0 then
		cut = 5+cut
	end
	return cut
end


--加注
function User:userRaise()
	-- body
	local panel = self._parent_view:getRandomChipsPanel()
	local panel1 = self._parent_view:getChipsPanel1()
	qf.event:dispatchEvent(Zjh_ET.PLAYER_DIU_CHIP,{panel=panel,panel1=panel1,user=self})  --自己丢筹码
	self:showChipAndGold()
end

function User:showAddBetImg()
	self.addBetTips:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(2),cc.Hide:create()))
end

--看牌
function User:userCheck(paras)
	local bg = self.Status_panel:getChildByName("bg")
	bg:setVisible(false)
	self.Status_panel:getChildByName("look_bg"):setVisible(true)
	self.Status_panel:setVisible(true)

	if self._cards and #self._cards==3 then
		self._cards[1]:runAction(cc.RotateTo:create(0.2,-30))
		self._cards[2]:runAction(cc.MoveTo:create(0.2,cc.p(self._cards[2]:getPositionX(),self._cards[2]:getPositionY()+10)))
		self._cards[3]:runAction(cc.RotateTo:create(0.2,30))
		-- self._cards[1]:setRotation(-30)
		-- self._cards[2]:setPositionY(self._cards[2]:getPositionY()+10)
		-- self._cards[3]:setRotation(30)
	end
	
end


--显示牌型 1win 2fail
function User:showCardType()

end


--user reconnect
function User:reconnect()
	--显示牌
	if self._info and self._info.status  > 1020 and self._cards and (#self._cards <= 0 or self._info.compare_failed == 1) then
		-- self._info.draw = 1  --标示已经绘制了牌桌的信息了
		self.cards_panel:setVisible(true)
		if self._info.status ~= 1050 then
			self._cards      = {}
			local card_tmp  = Card.new()
			local size      = card_tmp:getContentSize()
			self.cards_panel:removeAllChildren()
			for i=1,3 do
				local card_tmp  = Card.new()
				table.insert(self._cards,card_tmp)
				self.cards_panel:addChild(card_tmp)
				local name = self._panel_name
				card_tmp:setScale(0.7)
				card_tmp:setPosition(size.width/2+(i-1)*40,size.height/2)
			end
		end
		self:SetPlayerLight(false)
		--是否弃牌
		print(">>>>>>>>>>>>>>>>>>>>", self._info.status)
		if self._info.status == 1050 then
			self._cards      = {}
			self.cards_panel:removeAllChildren()
			self:userFold()
			self:SetPlayerLight(true)
			return
		end

		--是否比牌失败
		if self._info.compare_failed == 1 then
			for k,v in pairs(self._cards) do
				v:dark()
			end
			if self._info.look then
				if self._cards then
					self._cards[1]:setRotation(-30)
					self._cards[2]:setPositionY(self._cards[2]:getPositionY()+10)
					self._cards[3]:setRotation(30)
				end
			end
			self:CompareFail()--弃牌
			self:SetPlayerLight(true)
			return
		end

		--是否看牌
		if self._info.look or self._info.status == 1045 then
			self:userCheck()
		end
	elseif self._info and self._info.status  <= 1020 then
		if Cache.zjhdesk.status and Cache.zjhdesk.status>0 then
			self:SetPlayerLight(true)
		end
	end
end


--收金币动作
function User:collectGold(paras)
	local index = self:getIndex(self._uin)
	if not index then return end


	local node_x       = self:getPositionX()
	local node_y       = self:getPositionY()

	local usericon =self:getChildByName("icon")
	if usericon then
		node_x = node_x +  usericon:getPositionX()  
		node_y = node_y +  usericon:getPositionY()  
		else
		usericon =self:getChildByName("user_info"):getChildByName("icon")
		if usericon then
		  node_x = node_x +  usericon:getPositionX()  
		  node_y = node_y +  usericon:getPositionY()  
		end
	end
	local userinfo =self:getChildByName("user_info")-- node:getChildByName("icon") 
	if userinfo then
		node_x = node_x +  userinfo:getPositionX()  
		node_y = node_y +  userinfo:getPositionY()  
		end





		for i=1,3 do
		local chips_table = {}
		for k,v in pairs(self._parent_view["chips_area_"..i]:getChildren())	do
			table.insert(chips_table,v)
		end


		local index =self:getIndex(self._uin) 
		if index==1 or index ==2 then
			table.sort( chips_table, function(a,b)
				return a:getPositionX()>b:getPositionX()
			end)
		else
			table.sort( chips_table, function(a,b)
				return a:getPositionX()<b:getPositionX()
			end)
		end

		local end_x = self._parent_view["chips_area_"..i]:getPositionX()
		local end_y = self._parent_view["chips_area_"..i]:getPositionY()

		local j = 1
		for k,v in pairs( chips_table) do		
			local move = cc.MoveTo:create(0.2,cc.p(node_x-end_x,node_y-end_y))
			local delay  = cc.DelayTime:create((j-1)*0.3/(#chips_table))
			local call = cc.CallFunc:create(function()
				if v then
					v:removeFromParent()
				end
			end)
			local sq     = cc.Sequence:create(delay,move,call)
			v:runAction(sq)
			j=j+1
		end



	end


	

end

function User:setFirster( ... )
	-- 如果先手返回的是0，则不显示
	-- body
	if self._info.uin == Cache.zjhdesk.first_uin then
		self.zhuangIcon:setVisible(true)
	else
		self.zhuangIcon:setVisible(false)
	end
end

--赢了显示的钱数
function User:winMoneyFly(paras)
	local fnt  = cc.LabelBMFont:create('+'..Util:getFormatString(paras.chips), Zjh_Games_res.WINMONEY_FNT)

	self.gold:addChild(fnt)
	local high = 310

	fnt:setPosition(100,140)
	fnt:setScale(0.9)


	fnt:setZOrder(6)
	local move  = cc.MoveTo:create(0.3,cc.p(100,high))
	local delay = cc.DelayTime:create(2.5)
	local call  = cc.CallFunc:create(function ()
		-- -- body
		if fnt then
			fnt:removeFromParent()	
		end
			end)
	local sq   = cc.Sequence:create(move,delay,call)
	fnt:runAction(sq)


end



function User:showCard()
	--self:setVisible(true)
	self.cards_panel:removeAllChildren()
	
	self:SetPlayerLight(false)

end



function User:getCardTypeSound(cardvalue)--获得牌的类型
	-- body

	cardvalue = tonumber(cardvalue)
	local file 
	if cardvalue==0 then--高牌
		file= "GAOPAI_"
	elseif cardvalue==1 then--对子
		file= "DUIZI_"
	elseif cardvalue==2 then--顺子
		file= "SHUNZI_"
	elseif cardvalue==3 then--同花
		file= "TONGHUA_"
	elseif cardvalue==4 then--同花顺·
		file= "TONGHUASHUN_"
	elseif cardvalue==5 then--三条
		file= "BAOZI_"
	end

	return file
end

function User:playerInfoShow(isShow)--是否显示或隐藏人物头像、金钱等
	-- body
	self._bg:setVisible(isShow)
	self.nick:setVisible(isShow)
	self.icon:setVisible(isShow)
	self.gold:setVisible(isShow)
	if self.hat then
		self.hat:setVisible(isShow)
	end
	if self.beautyBg then
		self.beautyBg:setVisible(isShow)
	end
end

--头像火
function User:kuangFire()
	local kuang_fire = self._parent_view.animation_layout:getChildByName("kuang_fire")
	if kuang_fire  then
		kuang_fire:removeFromParent()
	end
	local start_x =self:getPositionX()
	local start_y =self:getPositionY()

	-- self._parent_view.Gameanimation:play({scale=2,name="kuang_fire",anim=GameAnimationConfig.KUANGFIRE,order=101,forever=1,position={x=start_x,y=start_y},anchor=cc.p(0,0)})
	self._parent_view.Gameanimation:play({scale=2,name="kuang_fire",anim=GameAnimationConfig.KUANGFIRE,position={x=start_x-50,y=start_y-60},forever=1,anchor=cc.p(0,0)})
end

function User:HideStatusPanel()
	-- body
	self.Status_panel:setVisible(false)
end

function User:GiveUpCard()--弃牌
	-- body
	local bg = self.Status_panel:getChildByName("bg")
	bg:loadTexture(Zjh_Games_res.Status_GiveUp,ccui.TextureResType.plistType)
	bg:setVisible(true)
	self.Status_panel:getChildByName("look_bg"):setVisible(false)
	self.Status_panel:setVisible(true)
	local tx = self.cards_panel:getPositionX()
	local ty = self.cards_panel:getPositionY()
	local ttx = self:getPositionX()
	local tty = self:getPositionY()
	local i = 0
	for k,v in pairs(self._cards) do
		local move = cc.MoveTo:create(0.5,cc.p(Display.cx/2-tx-ttx,Display.cy/2-ty-tty))
		local fadeout =cc.FadeOut:create(0.5)
		local rota = cc.RotateBy:create(0.5,360)
		local move_rota= cc.Spawn:create(move,rota,fadeout)
		local delay = cc.DelayTime:create(0.05*i)
		local remove = cc.CallFunc:create(function()
			-- body
			if v then
				v:removeFromParent()
			end
		end)
		v:runAction(cc.Sequence:create(delay,move_rota,remove))
	end
	self._cards={}
end


--显示聊天
-- function User:showPopChat(paras)
-- 	local index = string.sub(paras.content,1,1)
-- 	local lenght = string.len(paras.content)
-- 	local num = string.sub(paras.content,2,lenght)
-- 	if index == "#" and string.len(paras.content)>1 and tonumber(num) and tonumber(num)>0 and tonumber(num)<=30 then
-- 		local lenght = string.len(paras.content)

-- 		local num = string.sub(paras.content,2,lenght)
	
-- 		num = tonumber(num)

-- 		self:emoji(num)

-- 	elseif index == "$" and string.len(paras.content)>1 and tonumber(num) and tonumber(num)>0 and tonumber(num)<=18 then
-- 		local lenght = string.len(paras.content)
-- 		local num = string.sub(paras.content,2,lenght)
	
-- 		num = tonumber(num)
-- 		self:vipemoji(num)
-- 	else
-- 		local index = self:getIndex(self._uin)
-- 		local image = Zjh_Games_res.game_chat1
-- 		if index ~= 0 then
-- 			image = Zjh_Games_res.game_chat3
-- 		end

-- 		local rotation = 0
-- 		if index == 1 or index == 2 then
-- 			rotation = 180
-- 		end

		
-- 		local content=Util:filterEmoji(paras.content or "")
-- 		if content=="" then return end
-- 		if Cache.zjhdesk.view_table==1 and Cache.zjhdesk.is_view==1 and index == 0 then
-- 			index=5
-- 		end
-- 	    local chatNode = Useranimation:getChatNode({content =content,image=image,pos=self.Chat_position[index],rotation=rotation,uin=paras.op_uin })

-- 	    if self:getParent() and self:getParent():getParent() then
-- 	        self:getParent():getParent():addChild(chatNode,self:getParent():getParent().WAITZ or 9)
-- 	    end
-- 	end
    
-- end

--显示表情
function User:emoji(index)
	local chat   = self._parent_view._chat
	local windex = self:getIndex(self._uin) 
	self._parent_view.Gameanimation:play({node=self,anim=chat.Emoji_index[index].animation,index=chat.Emoji_index[index].index,scale=2,position=self.Emoji_position,order=5})
end


-- --显示表情
-- function User:vipemoji(index)
-- 	local chat   = self._parent_view._chat
-- 	local windex = self:getIndex(self._uin) 
-- 	self._parent_view.Gameanimation:playvipemoji({node=self,index=index,position=self.Emoji_position,order=5})
-- end


--显示自己下注的chips
function User:showChipAndGold()
	if Cache.zjhdesk._player_info[self._uin] then
		local gold =Cache.zjhdesk._player_info[self._uin].gold+Cache.zjhdesk._player_info[self._uin].chips
		loga("当前玩家的金币数"..self._uin.."    "..gold)

		gold =gold >0 and gold or 0
		self.gold:setString(Util:getFormatString(Cache.packetInfo:getProMoney(gold)))
	end
end

--比牌
function User:compareCard(paras)
	-- body
	local panel = self._parent_view:getRandomChipsPanel()
	local panel1 = self._parent_view:getChipsPanel1()
	qf.event:dispatchEvent(Zjh_ET.PLAYER_DIU_CHIP,{panel=panel,panel1=panel1,user=self,chip=paras.user_pay_real_money})  --自己丢筹码
	self:showChipAndGold()
end

function User:getCardValue(value)
	-- body
	local i,t = math.modf(value/4)
    i = i + 1
    if i == 14 then i = 1 end

    value= i
    
    return value
end

function User:cardRank(cardsValue)--排序
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


function User:showBigType()

	 -- local type1 =math.random(4,5)
	 -- self._info.card_type  = type1
	local anim 

	if self._info.card_type == 4 then
		anim = GameAnimationConfig.TONGHUASHUN
	elseif self._info.card_type == 5 then
		anim = GameAnimationConfig.SANTIAO
	else
		return
	end


	local bg = cc.Sprite:createWithSpriteFrameName(Zjh_Games_res.BIGCARDBG)
	self._parent_view:addChild(bg,100)	
	local px = Display.cx/2
	if FULLSCREENADAPTIVE then
		px = px - (self.winSize.width -1980)/2
	end
	bg:setPosition(cc.p(px,Display.cy/2))


	local new_icon      = ccui.Helper:seekWidgetByName(self._parent_view.gui,"icon")
	new_icon  = new_icon:clone()
	bg:addChild(new_icon)	
	new_icon:setPosition(300,100)
	Util:updateUserHead(new_icon, self._info.portrait, self._info.sex, {add=true, sq=true, url=true})
	new_icon:setVisible(true)

	local nick = ccui.Helper:seekWidgetByName(self._parent_view.gui,"nick")
	nick  = nick:clone()
	nick:setString(Util:showUserName(self._info.nick))
	bg:addChild(nick)
	nick:setVisible(true)
	nick:setPosition(300,210)

	local i  = 1
	local cards=self:cardRank(self._info.card)
	for k,v in pairs(cards) do
		local tmp_card =Card.new({value=v})
		bg:addChild(tmp_card)
		tmp_card:showFront()
		tmp_card:setPosition(cc.p((i-1)*120+500,90))
		tmp_card:setScale(0.8)
		i = i + 1
	end
	

	local cb = function ( ... )
		if bg then
			bg:removeFromParent()
		end
	end

	if self._info.card_type == 4 then
		self._parent_view.Gameanimation:play({order=101,scale=1.9,anim=anim,position={x=px,y=Display.cy/2+230},callback=cb,time=1.5})
		Scheduler:delayCall(0,function ( ... )
			-- body
			MusicPlayer:playMyEffectGames(Zjh_Games_res,"TONGHUASHUNSOUND")
		end)
	elseif self._info.card_type == 5 then
		Scheduler:delayCall(0.2,function ( ... )
			-- body
		self._parent_view.Gameanimation:play({order=101,scale=0.65,anim=anim,position={x=px,y=Display.cy/2+300},callback=cb,time=1.5})
		end)
		MusicPlayer:playMyEffectGames(Zjh_Games_res,"SANTIAOSOUND")
	end

end


function User:receiveGift(paras)
    local from = self:convertToNodeSpace(cc.p(paras.x,paras.y))
    local cs = self.selfSize
    local to = cc.p(0+cs.width/2,0+cs.height/2)
    if self._uin == Cache.user.uin then
        x=0+cs.width/2+ccui.Helper:seekWidgetByName(self,"user_info"):getPositionX()
        y=0+cs.height/2+ccui.Helper:seekWidgetByName(self,"user_info"):getPositionY()
        to=cc.p(x,y)
        local isShow = cc.UserDefault:getInstance():getBoolForKey(SKEY.ZJH_GIFTLEAD, true)
        if isShow and paras.from_uin ~= Cache.user.uin and Cache.Config.lhd_gift_switch == 1 then
        	cc.UserDefault:getInstance():setBoolForKey(SKEY.ZJH_GIFTLEAD, false)
        	qf.event:dispatchEvent(Zjh_ET.SEND_GIFT_LEAD)
        end
    end
    local id =paras.id
    local gift = Gift.new({from=from,to=to,id=id,from_uin=paras.from_uin,to_uin=paras.to_uin,ask_friend=paras.ask_friend})
    if gift then
        self:addChild(gift,10)
    end
    --if paras.to_uin~=Cache.user.uin then
    	self:updateGiftBtn(paras.decoration)
    -- else
    -- 	self:updateGiftBtn(paras.id)
    -- end
end

function User:updateBtn(paras)
	-- body
	qf.event:dispatchEvent(ET.CHANGE_GIFT,{button = self.gift,icon = paras})
end

function User:updateGiftBtn(paras,isMeEnter)
    local btn_gift = ccui.Helper:seekWidgetByName(self,User.GIFT)
    if self.disable_gift and btn_gift:isVisible() then
        btn_gift:setVisible(false)
    else
    	if paras and not isMeEnter and paras >=2000 and paras<2006 then
    		qf.event:dispatchEvent(ET.SHOW_GIFTCAR_ANI,{id =paras,txt=self._info.nick,pos=self.gift:getWorldPosition(),cb=self.updateBtn,node = self})
    	else
        	self:updateBtn(paras)
    	end
        local u = Cache.zjhdesk._player_info[self.uin]
        if u and u.decoration == -1 then --如果当前的用户礼物是空的，就改变其为最新的
           u.decoration = paras
        end
    end
end

--更新是否需要显示美女皇冠
function User:updateBeauty()
    --if not true then return end
    self:clearBeautyHat()
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
        local img = Zjh_Games_res["beauty_rank_hat_"..rank] or Zjh_Games_res["beauty_rank_hat_4"]
        self.beautyBg=self._bg:clone()
        self.beautyBg:loadTexture(Zjh_Games_res.beauty_rank_bg)
        self._bg:addChild(self.beautyBg)
        if img == nil then return end
        self.hat = ccui.ImageView:create()
        self.hat:loadTexture(img)
        self.hat:setPosition(cc.p(img == Zjh_Games_res["beauty_rank_hat_4"] and 15 or 5, 290 - (img == Zjh_Games_res["beauty_rank_hat_4"] and 35 or 25)))
        self.hat:setTag(self.hatTag)
        self.hat.img=img--增加一个记号
        self._bg:addChild(self.hat,2)
    end
end

function User:clearBeautyHat()--清除美女皇冠
	if self.beautyBg then 
		self.beautyBg:removeFromParent()
		self.beautyBg=nil
	end
	if self.hat then
    	self.hat:removeFromParent()
		self.hat=nil
	end
end

function User:playShowChatMsg(txt_layer, msg)
	local corner =  GameConstants.CORNER.LEFT_DOWN
	local index = self:getIndex(self._uin)
	if self:getName() == "user_fourth" or self:getName() == "user_third" then
        corner = GameConstants.CORNER.RIGHT_DOWN
	end

	local chatnode = txt_layer:playShowChatMsg(self, self.icon, {
        corner = corner,
        -- offset = {x = -47, y = -21},
		msg = msg,
		chatname = "chat_" .. index
	})
    self.chatnode = node
end

function User:showPopChat(model, del)
	del._chat:showPopChatProtocol(model, self, {chatDel = del})
end

--显示表情
function User:emoji(index, Emoji_index)
	-- local chat   = self._parent_view._chat
	-- local windex = self:getIndex(self._uin) 
	self._parent_view.Gameanimation:play({node=self.icon,anim=Emoji_index[index].animation,index=Emoji_index[index].index,scale=2,position=self.Emoji_position,order=5, posOffset = {x = -30, y = -45}})
end

return User