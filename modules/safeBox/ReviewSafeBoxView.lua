
local _SafeBoxView = import(".SafeBoxView")
local SafeBoxView = class("SafeBoxView", _SafeBoxView)

SafeBoxView.TAG = "SafeBoxView"

function SafeBoxView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewSafeBoxJson)
    self._parameters = parameters
    self:init(parameters)
    self.super.super.ctor(self, {id=PopupManager.POPUPWINDOW.safeBox, child=self.root})
end

local function setButtonBirghtAndEnabled(btn, enabled)
    btn:setEnabled(enabled)
    btn:setBright(enabled)
    if enabled then
        btn:setPositionX(btn.xpos)
    else
        btn:setPositionX(btn.xpos + 5)
    end
end


function SafeBoxView:clickTabButton(sender)
    self.coinWarning:setVisible(false)
    setButtonBirghtAndEnabled(self.saveButton, true)
    setButtonBirghtAndEnabled(self.curButton, true)

    self.editBoxCoin:setText("")
    self.editBoxPwd:setText("")
    self.editCoinNum = ""
    self.pwd = "" 


    if sender.name == "saveButton" then
        self.reqType = 1
        ccui.Helper:seekWidgetByName(self.saveButton,"Image_title"):loadTexture(GameRes.review_safeBox_deposit, 1)
        ccui.Helper:seekWidgetByName(self.curButton,"Image_title"):loadTexture(GameRes.review_safeBox_fetch2, 1)
        self.smallTitle:loadTexture(GameRes.review_safeBox_image_in3, 1)
        self.editBoxCoin:setPlaceHolder(GameTxt.string_safebox_2)
    elseif sender.name == "curButton" then
        self.reqType = 2
        ccui.Helper:seekWidgetByName(self.saveButton,"Image_title"):loadTexture(GameRes.review_safeBox_deposit2, 1)
        ccui.Helper:seekWidgetByName(self.curButton,"Image_title"):loadTexture(GameRes.review_safeBox_fetch, 1)
        self.smallTitle:loadTexture(GameRes.review_safeBox_image_out3, 1)
        self.editBoxCoin:setPlaceHolder(GameTxt.string_safebox_3)
    end
    self:btnNumCall()
    self:updateButton()
    setButtonBirghtAndEnabled(sender, false)
    local bVis = sender.name == "curButton"
    ccui.Helper:seekWidgetByName(self.actPanel,"Label_id_1_2_3"):setVisible(bVis)
    self.pwdFrame:setVisible(bVis)
    self.findPwdBtn:setVisible(bVis)
    if ModuleManager:judegeIsInChouMaArea() then
        Util:ensureBtn(self.reqBtn, self.reqType == 2)
    end
end

return SafeBoxView