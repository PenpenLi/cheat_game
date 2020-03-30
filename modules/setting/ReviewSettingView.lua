local _SettingView = import(".SettingView")
local SettingView = class("SettingView", _SettingView)

SettingView.TAG = "SettingView"

function SettingView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewSettingJson)
    self:init(parameters)
    
    self.super.super.ctor(self, {id=PopupManager.POPUPWINDOW.setting, child=self.root})
    self:initPolicy()
end

function SettingView:initPolicy( ... )
    addButtonEvent(ccui.Helper:seekWidgetByName(self.root, "user_policy"), function ( ... )
        self:close()
        Util:delayRun(0.25, function ( ... )
            qf.event:dispatchEvent(ET.SHOW_USER_POLICY)
        end)
    end)
end

function SettingView:setButtonEnable(sender, bopen)
    local bg = sender:getChildByName("Image_bg")
    local circle = sender:getChildByName("Image_circle")
    local txt = sender:getChildByName("ImageSt")
    local diffX = -12
    local bgRes = bopen and GameRes.setting_btn_on_st or GameRes.setting_btn_off_st
    local txtRes = bopen and GameRes.setting_btn_on_txt or GameRes.setting_btn_off_txt
    local x = bopen and 129 or 52
    txt:setPositionX(bopen and 45 or 131) 
    circle:setPositionX(x)
    txt:loadTexture(txtRes, 1)
    bg:loadTexture(bgRes, 1)
end

function SettingView:updateHead(parameters)
    Util:updateUserHead(self.imageHead, Cache.user.portrait, Cache.user.sex, {add = false, sq = false, url = true, circle = false})
    local playerHeadMask  = ccui.Helper:seekWidgetByName(self.root,"Image_92")
    if Cache.user.number > 0 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.headMaskPlist, GameRes.headMaskPng)
        playerHeadMask:setScale(1.3)
        playerHeadMask:loadTexture(string.format(GameRes.headMaskImage, Cache.user.number, 1),ccui.TextureResType.plistType)
    else
        playerHeadMask:setScale(1)
        playerHeadMask:loadTexture(GameRes.headMaskDefault, ccui.TextureResType.plistType)
    end
end

return SettingView