--local SettingView = class("SettingView", qf.view)
local SettingView = class("SettingView", CommonWidget.PopupWindow)

SettingView.TAG = "SettingView"

function SettingView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.setting)
    self:init(parameters)
    
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.setting, child=self.root})
    qf.platform:umengStatistics({umeng_key = "Setting"})
end

function SettingView:initWithRootFromJson()
    return GameRes.setting
end

function SettingView:isAdaptateiPhoneX()
    return true
end

function SettingView:init()
    Display:closeTouch(self)
    self:initUI()
end


function SettingView:onButtonEvent(sender)
    if sender.name == "musicBtn" then
        self:changeStatus("MUSIC", self.musicBtn)

    elseif sender.name == "effectBtn" then
        self:changeStatus("EFFECT", self.effectBtn)

    elseif sender.name == "shakeBtn" then
        self:changeStatus("SHOCK", self.shakeBtn)

    elseif sender.name == "logoutBtn" then
        self:doLogout()
    elseif sender.name == "closeBtn" then
        self:close()
    elseif sender.name == "bindBtn" then
        qf.event:dispatchEvent(ET.CHANGE_PWD,{
            actType = 1, showType = 4, cb = function ( ... )
                self:bindPhoneAdjust()
            end}
        )
    end
end

function SettingView:restoreStatus()
    local beffect = cc.UserDefault:getInstance():getBoolForKey("EFFECT", true)
    self:setButtonEnable(self.effectBtn, beffect)
    local bmusic = cc.UserDefault:getInstance():getBoolForKey("MUSIC", true)
    self:setButtonEnable(self.musicBtn, bmusic)
    local bshock = cc.UserDefault:getInstance():getBoolForKey("SHOCK", true)
    self:setButtonEnable(self.shakeBtn, bshock)

end

function SettingView:changeStatus(keyName, sender)
    local beffect = cc.UserDefault:getInstance():getBoolForKey(keyName, true)
    cc.UserDefault:getInstance():setBoolForKey(keyName, not beffect)
    -- cc.UserDefault:getInstance():flush()

    self:setButtonEnable(sender, not beffect)
    MusicPlayer:initSetting()

    if sender.name == "musicBtn" then
        if beffect == true then
            MusicPlayer:stopBackGround()
        else
            MusicPlayer:playBackGround(Cache.DeskAssemble:getBgMusicByGameType())
        end
    end
end

function SettingView:setButtonEnable(sender, bopen)
    local bg = sender:getChildByName("Image_bg")
    local circle = sender:getChildByName("Image_circle")
    local diffX = 20
    local bgRes = bopen and GameRes.setting_btn_on or GameRes.setting_btn_off
    local x = bopen and (circle:getContentSize().width / 2 - 5) or (bg:getContentSize().width - circle:getContentSize().width / 2 + diffX)
    circle:setPositionX(x)
    bg:loadTexture(bgRes, 0)
end

function SettingView:initUI( ... )
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "musicBtn",         path = "Panel_info/Panel_music",  handler = defaultHandler},
        {name = "effectBtn",        path = "Panel_info/Panel_effect", handler = defaultHandler},
        {name = "shakeBtn",        path = "Panel_info/Panel_shake", handler = defaultHandler},

        {name = "panelInfo",        path = "Panel_info", handler = nil},
        {name = "labelId",         path = "Panel_info/Label_id",  handler = nil},
        {name = "labelNick",        path = "Panel_info/Label_nick", handler = nil},
        {name = "labelVersion",        path = "Panel_info/Label_version", handler = nil},
        {name = "imageHead",        path = "Panel_info/Image_head", handler = nil},

        {name = "closeBtn",         path = "Button_close",  handler = defaultHandler},
        {name = "bindBtn",        path = "Button_bind", handler = defaultHandler},
        {name = "logoutBtn",        path = "Button_logout", handler = defaultHandler},

        {name = "panelFrame", path = "Panel_frame"}
    }

    
    Util:bindUI(self, self.root, uiTbl)
    -- Util:enlargeCloseBtnClickArea(self.closeBtn)
    -- body
    --基本信息
    
    self:updateHead()
    Util:setPosOffset( ccui.Helper:seekWidgetByName(self.panelInfo, "Image_92"), {x = 1})
    self.labelId:setString("ID:"..Cache.user.uin)
    self.labelNick:setString(Cache.user.nick)
    self.labelVersion:setString(GameTxt.setting_txt_1 .. GAME_BASE_VERSION)

    self:restoreStatus()
    self:bindPhoneAdjust()
end

function SettingView:getRoot() 
    return LayerManager.PopupLayer
end

function SettingView:updateHead( ... )
    Util:updateUserHead(self.imageHead, Cache.user.portrait, Cache.user.sex, {add = false, sq = false, url = true, circle = false})
end

function SettingView:bindPhoneAdjust()
    if Cache.user:isBindPhone() and tolua.isnull(self) == false then
        self.bindBtn:setVisible(false)
        self.logoutBtn:setPositionX(self.panelFrame:getContentSize().width / 2 + 20)
    end
end

function SettingView:doLogout( ... )
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    cc.UserDefault:getInstance():setStringForKey("loginBody", "")
    cc.UserDefault:getInstance():flush()
    qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
    MusicPlayer:setBgMusic()
    MusicPlayer:stopBackGround()
    ModuleManager:removeSubGameHall()
    PopupManager:removeAllPopup()
end

return SettingView