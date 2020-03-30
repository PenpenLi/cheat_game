local GameRuleView = class("GameRuleView", CommonWidget.PopupWindow)
GameRuleView.TAG = "GameRuleView"

function GameRuleView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.gameRuleJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.gameRule, child=self.root})
end


function GameRuleView:init( parameters )
    local closeFunc = function ( ... )
        self:close()
    end
    local turnFunc = handler(self, self.changeTab)

    local uiTbl = {
        {name = "closeBtn",        path = "Panel_frame/Button_close",  handler = closeFunc},
        {name = "panelBox",        path = "ScrollView_39",             handler = nil}
    }

    Util:bindUI(self, self.root, uiTbl)
    Util:enlargeCloseBtnClickArea(self.closeBtn, closeFunc)
    
    self:refreshRule(parameters)
end

function GameRuleView:refreshRule(paras)
    local gt = paras.GameType
    if gt == nil then
        return
    end
    local ruleImg
    if gt == BRC_MATCHE_TYPE then --百人炸金花
        ruleImg = GameRes.ruleBR
    elseif gt == GAME_NIU_ZHA then --炸金牛
        ruleImg = GameRes.ruleZJN
    elseif gt == GAME_ZJH then --炸金花
        ruleImg = GameRes.ruleZJH
    elseif gt == LHD_MATCHE_TYPE then --龙虎斗
        ruleImg = GameRes.ruleLHD
    elseif gt == GAME_DDZ then --斗地主    
        ruleImg = GameRes.ruleDDZ
    elseif gt == GAME_NIU_KAN then --抢庄牛牛
        ruleImg = GameRes.ruleDN
    elseif gt == BRNN_MATCHE_TYPE then         --百人牛牛
        ruleImg = GameRes.ruleBRNN
    elseif gt == BJL_MATCHE_TYPE then         --百家乐
        ruleImg = GameRes.ruleBJL
    end
    
    self.panelBox:getChildByName("showTxt"):loadTexture(ruleImg)

    local contentSize = self.panelBox:getChildByName("showTxt"):getContentSize()
    local innerSize = self.panelBox:getInnerContainerSize()

    --设置滚动区域的长度
    self.panelBox:setInnerContainerSize(cc.size(innerSize.width, contentSize.height + 70))
    local _x = (innerSize.width - contentSize.width)/2
    local _y = 0
    if contentSize.height < self.panelBox:getContentSize().height then
        _y = (self.panelBox:getContentSize().height - contentSize.height)/2
    end
    self.panelBox:getChildByName("showTxt"):setPosition(_x, _y)
    -- Util:setPosOffset(self.panelBox, {x = 0, y = -55})
end

return GameRuleView