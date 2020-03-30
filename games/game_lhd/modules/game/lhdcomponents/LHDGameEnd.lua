--结算页面
local LHDGameEnd = class("LHDGameEnd", function(paras)
    return paras.node
end)
LHDGameEnd.TAG = "LHDGameEnd"
local LHDCard = import(".LHDCard")

function LHDGameEnd:ctor(paras)
	self.winSize = cc.Director:getInstance():getWinSize()
	self:loadPokerSpriteFrame()
	self:init()
	self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
end

function LHDGameEnd:show(cb)
	self.cb = cb
	self:gameEndStart()
	self:openCard()
end

function LHDGameEnd:init()
	self.GameState = {
		sendCard 	= "sendCard", --发牌
		showCard 	= "openCard", --开牌
		showResult  = "setResult", --展示结果
	}
	self.longLayer = self:getChildByName("Image_30")
	
	self.huLayer = self:getChildByName("Image_31")
	self.huLayer.pos = cc.p(self.huLayer:getPositionX(), self.huLayer:getPositionY())

	self.longBack = self.longLayer:getChildByName("back")
	-- 加载背面
	self.longBack:loadTexture(GameRes.poker_back_big_img_name, ccui.TextureResType.plistType)
	self.longBack.pos = cc.p(self.longBack:getPositionX() - 6, self.longBack:getPositionY())
	self.huBack = self.huLayer:getChildByName("back")
	-- 加载背面
	self.huBack:loadTexture(GameRes.poker_back_big_img_name, ccui.TextureResType.plistType)
	self.huBack.pos = cc.p(self.huBack:getPositionX(), self.huBack:getPositionY())
end

function LHDGameEnd:loadPokerSpriteFrame( ... )
	cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.poker_plist, GameRes.poker_plist_png)
end

function LHDGameEnd:gameEndStart()
	--游戏开始
	print("===============生成牌===============")
	if self.card_long then
		self.card_long:removeFromParentAndCleanup()
	end
	if self.card_hu then
		self.card_hu:removeFromParentAndCleanup()
	end
	self.card_long = self:getNewCard()
	self.card_long:setScale(1)
	self.longLayer:addChild(self.card_long)
	
	self.card_long:setPosition(self.longLayer:getContentSize().width/2 - 4, self.longLayer:getContentSize().height/2 -4)


	self.card_hu   = self:getNewCard()
	self.card_hu:setScale(1)
	self.huLayer:addChild(self.card_hu)
	
	self.card_hu:setPosition(self.huLayer:getContentSize().width/2 -4 ,self.huLayer:getContentSize().height/2 -4)
end

function LHDGameEnd:sendCard(noAni,cb)
	self.state = self.GameState.sendCard
	self.longBack:setVisible(true)
	self.huBack:setVisible(true)

	if not noAni then return end
	self.longBack:setPosition(238, -283)
	self.longBack:setScale(0)
	self.huBack:setPosition(-132, -238)
	self.huBack:setScale(0)

	print("======================发牌动画开始=====================")
	
	self.longBack:runAction(cc.Sequence:create(
        cc.EaseSineIn:create(cc.Spawn:create(
            cc.ScaleTo:create(0.3,1),
            cc.CallFunc:create(function ( ... )
            	MusicPlayer:playMyEffectGames(LHD_Games_res,"FAPAI")
            end),
            cc.MoveTo:create(0.3,cc.p(self.longBack.pos.x,self.longBack.pos.y))
        ))
	))

	self.huBack:runAction(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.EaseSineIn:create(cc.Spawn:create(
            cc.ScaleTo:create(0.3,1),
            cc.CallFunc:create(function ( ... )
            	MusicPlayer:playMyEffectGames(LHD_Games_res,"FAPAI")
            end),
            cc.MoveTo:create(0.3,cc.p(self.huBack.pos.x,self.huBack.pos.y))
        )),
        cc.CallFunc:create(function ( ... )
        	if cb then
        		cb()
        	end
        end)
	))
end

--开牌
function LHDGameEnd:openCard()
	local longValue = self.deskCache:getLhdCardsByCardId(1)
	local huValue = self.deskCache:getLhdCardsByCardId(2)
	if longValue == nil or huValue == nil then
		return
	end
	--开牌
	self.state = self.GameState.showCard

	--龙开牌
	self:delayRun(0.7,function ( ... )
		print("=================龙开牌============")
		self.longLayer:getChildByName("back"):setVisible(false)
		self.card_long:reverseSelf(nil, longValue)
        MusicPlayer:playMyEffectGames(LHD_Games_res,"FANPAI")
	end)
	
	--虎开牌
 	self:delayRun(2, function ( ... )
 		print("=================虎开牌============")
 		self.huLayer:getChildByName("back"):setVisible(false)
 		self.card_hu:reverseSelf(function ( ... )
        	MusicPlayer:playMyEffectGames(LHD_Games_res,"FANPAI")
 		end, huValue)
 	end)

 	--收到结算通知后3s播放亮起动画
 	self:delayRun(3, function ( ... )
 		print("=================开牌后显示对比结果============")
 		--发牌后显示游戏结果
 		if tolua.isnull(self) == false then
			local win_card_id = self.deskCache:getLhdWinCardId()
	    	self:showGameResult(win_card_id, "nobet")
 		end
 	end)
end


function LHDGameEnd:showGameResult(winCard)
	--显示结果
	winCard = winCard or 1
	if winCard == 1 then
		--龙赢
		self:setCardWin(self.card_long, winCard)
	elseif winCard == 2 then
		--虎赢
		self:setCardWin(self.card_hu, winCard)
	elseif winCard == 3 then
		--和赢
		self:setCardWin(self.card_hu, winCard)
		self:setCardWin(self.card_long, winCard)
	end

	self:delayRun(0, function()
		self.state = self.GameState.showResult
		self:showMyResult(winCard)
	end)
end

function  LHDGameEnd:getNewCard()
	local card = LHDCard.new()
    return card
end

--显示card对比结果
function LHDGameEnd:setCardWin(card)
	if tolua.isnull(card) == false then
		card:runAction(cc.Sequence:create(
					cc.ScaleTo:create(0.3, 1.2),
					cc.ScaleTo:create(0.1, 1.1)
			))
	end
end

--重置卡牌
function LHDGameEnd:resetCard( ... )
	self.longLayer:getChildByName("back"):setVisible(false)
	self.huLayer:getChildByName("back"):setVisible(false)
	if self.card_long then
		self.card_long:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.1, 1),
			cc.CallFunc:create(function ( ... )
				if tolua.isnull(self) == false then
					self.card_long:removeFromParentAndCleanup()
					self.card_long = nil
				end
			end)
		))
		
	end
	if self.card_hu then
		self.card_hu:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.1, 1),
			cc.CallFunc:create(function ( ... )
				self.card_hu:removeFromParentAndCleanup()
				self.card_hu = nil
			end)
		))
	end
end

-- 显示自己结果
function LHDGameEnd:showMyResult(winCard)
	print("=================下注区亮起============")
	qf.event:dispatchEvent(LHD_ET.BR_QUERY_RECENT_TREND_CLICK)
	print("=================请求走势信息============")
	if self.cb then
		self.cb(winCard)
	end
end

function LHDGameEnd:delayRun(time, cb)
	local action = cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(function()
			if cb then cb() end
		end)
	)
	self:runAction(action)
end

return LHDGameEnd