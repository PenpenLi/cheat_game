local GuideView = class("GuideView")
local AnimationConfig = require("src.games.game_hall.modules.main.config.AnimationConfig")
GuideView.TAG = "GuideView"

function GuideView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.guideJson)
    self:init(parameters)
end

function GuideView:init( parameters )
	local uiTable = {
        {name = "passBtn",          	path = "root/pass", handler = handler(self, self.passAction)},
        {name = "showImage",            path = "root/showImage"}
    }
    Util:bindUI(self, self.root, uiTable)
    self:initData(parameters)
    self:locateGameBtn()
end

function GuideView:initData(parameters)
	self._callback = parameters.cb
	self.gameBtnNode = parameters.gameBtnNode
	self.gameBtnNodePos = parameters.pos
	self.chooseGameName = parameters.uniq
	self.btnAni = parameters.btnAni
	self.btnFlagAni = parameters.btnFlagAni
	self.winSize = cc.Director:getInstance():getWinSize()
end
 
function GuideView:locateGameBtn( ... )
	if not self.gameBtnNode then return end
	self.gameBtnNode:setVisible(false)
	local gameName = -1
	for _,v in pairs(Cache.user.downGameList) do
		if v.uniq == self.chooseGameName then
			gameName = tonumber(v.name)
			break
		end
	end
	if gameName == -1 then return end
	local gameBtn = ccui.Button:create(GameRes.hallGameImage[gameName] .. "_xiazai.png", GameRes.hallGameImage[gameName] .. "_xiazai.png")
    gameBtn:setAnchorPoint(cc.p(0.5,0.5))
	gameBtn:setPosition(cc.p({x = self.gameBtnNodePos.x, y = self.gameBtnNodePos.y}))
	self:initShowGameBtnAnimation(gameBtn, self.chooseGameName)
	self.root:addChild(gameBtn, 1)
	addButtonEvent(gameBtn, function ( ... )
		self:enterGame()
	end)
end

function GuideView:initShowGameBtnAnimation(sender, uniq)
	local anim = self.btnAni
	if not anim then return end
    local face = Util:addAnimationToSender(sender, {anim = anim, node = sender, posOffset = {y = -18}, forever =true})
    face:setName("ani")
    self:initGameBtnFlagAnimation(sender, uniq)
    self:initGuideHeadAnimation(sender)
end

function GuideView:initGameBtnFlagAnimation(sender, uniq)
	local flagAniConfig = self.btnFlagAni
	if not flagAniConfig then return end
	--先把之前的清除
    if sender:getChildByName("gameFlag") then
        sender:removeChildByName("gameFlag")
    end

    --这里增加标志
    if flagAniConfig then
        local face = Util:addAnimationToSender(sender, {anim = flagAniConfig, node = sender, posOffset = {x = -120, y = 100}, scale = 1, forever =true})
        face:setName("gameFlag")
    end
end

function GuideView:initGuideHeadAnimation(sender)
	--先把之前的清除
    if sender:getChildByName("guideHead") then
        sender:removeChildByName("guideHead")
    end

    local face = Util:addAnimationToSender(sender, {anim = AnimationConfig.GUIDE_HEAD, node = sender, posOffset = {x = sender:getContentSize().width/2 - 80, y = -sender:getContentSize().height/2}, forever =true})
    face:setName("guideHead")
end

function GuideView:show(node)
	if node then
		if node:getChildByName(self.TAG) then
			node:removeChildByName(self.TAG)
		end
		node:setAnchorPoint(cc.p(0.5,0.5))
		if FULLSCREENADAPTIVE then
			self.root:setPositionX(self.winSize.width/2-1920/2)
		end
		self.root:setName(self.TAG)
		node:addChild(self.root, 6)
	end
end

function GuideView:enterGame()
	self:closeFunc()
	Cache.user.firstLogin = true
	ModuleManager.global:quickEnterGame(Cache.user.guide_to_game)
end

function GuideView:passAction( sender )
	self:closeFunc("pass")
end

function GuideView:closeFunc(parameters)
	self:close()
	if self._callback and type(self._callback) == "function" then
		self._callback(parameters)
	end
end

function GuideView:close( ... )
	if self.gameBtnNode then
		self.gameBtnNode:setVisible(true)
	end
	self.root:removeFromParent()
	GameNet:send({cmd = CMD.CLOSE_GUIDE_VIEW, body={user_id = Cache.user.uin}, callback = function (rsp)
		if rsp.ret == 0 then
			Cache.user.guide_to_game = 0
		end
	end})
end

return GuideView
