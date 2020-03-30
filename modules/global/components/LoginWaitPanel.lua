local LoginWaitPanel = class("LoginWaitPanel",function(paras) 
    return ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.loginloginLayout1Json)
end)

LoginWaitPanel.TAG = "LoginWaitPanel"

function LoginWaitPanel:ctor(parameters)
    self:init(parameters)
end

function LoginWaitPanel:init(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    local bg = cc.Sprite:create(GameRes["login_bg"])
    self:addChild(bg)
    if FULLSCREENADAPTIVE then
        bg:setZOrder(1)
        bg:setScaleX(1.5)
    end
    bg:setPosition(self.winSize.width/2,bg:getContentSize().height/2)

    self.con = cc.Sprite:create()
    self.con:setZOrder(2)
    self:addChild(self.con)
    self.con:setAnchorPoint(cc.p(0,0))

    self.statusTxt = cc.LabelTTF:create(GameTxt.load001, GameRes.font1, 40)
    self.con:addChild(self.statusTxt)
    self.statusTxt:setAnchorPoint(cc.p(0,0))

    self.spr = cc.Sprite:create(GameRes["login_1"])
    self.con:addChild(self.spr)
    self:play()

    self.spr:setPosition(self.statusTxt:getPositionX() + self.statusTxt:getContentSize().width + self.spr:getContentSize().width/2,self.statusTxt:getPositionY() + self.statusTxt:getContentSize().height/2)
    self.con:setPosition(self.winSize.width/2 - self.spr:getContentSize().width/2 - self.statusTxt:getContentSize().width/2, 106)

    --叠加背景
    self.bgImg= ccui.Helper:seekWidgetByName(self,"bgimg")
    --美女
    self.Beauty= ccui.Helper:seekWidgetByName(self,"beauty")
    --美女层
    self.pan_all= ccui.Helper:seekWidgetByName(self,"Panel_4")
end

function LoginWaitPanel:initAnimate()
    local is_review = 0 ~= Util:binaryAnd(tonumber(Util:getDesDecryptString(TB_SERVER_INFO.modules)), TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    self.Beauty:setVisible(is_review)
end

function LoginWaitPanel:setTxt(txt)
    self.statusTxt:setString(txt)

    self.spr:setPosition(self.statusTxt:getPositionX() + self.statusTxt:getContentSize().width + self.spr:getContentSize().width/2,self.statusTxt:getPositionY() + self.statusTxt:getContentSize().height/2)
    self.con:setPosition(self.winSize.width/2 - self.spr:getContentSize().width/2 - self.statusTxt:getContentSize().width/2, 106)
end
function LoginWaitPanel:play()
    self.spr:stopAllActions()
    local ani = cc.Animation:create()
    for i=1,4 do
        ani:addSpriteFrameWithFile(GameRes["login_"..i])
    end
    ani:setDelayPerUnit(0.7)

    local seq = cc.RepeatForever:create(cc.Animate:create(ani))
    self.spr:runAction(seq)
end

return LoginWaitPanel