
--[[
    click use head 
    pop up this panel
]]


--GLOBAL_SHOW_USER_INFO 事件新增参数说明: 
--[[
hide_enabled: (true/false)是否支持隐身, 默认为false. 如果支持隐身, 用户信息将按照hiding显示
hide_nick: 隐身后的昵称. 不设置则使用默认隐身后的昵称“神秘人”
]]

local UserInfo = class("UserInfo", CommonWidget.PopupWindow)
UserInfo.TAG = "UserInfo"

local HeadImage = require("src.modules.global.components.big_head_image.HeadImage")
function UserInfo:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init(paras)
    self:initData()
    self.super.ctor(self, {id = PopupManager.POPUPWINDOW.userinfo, child = self.gui})
end

function UserInfo:init(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.userInfoJson)

    self.imgHeadBg = ccui.Helper:seekWidgetByName(self.gui, "head_bg")
    self.imgHead = ccui.Helper:seekWidgetByName(self.gui, "head")
    
    self.itemInfoNick = ccui.Helper:seekWidgetByName(self.gui, "item_info_nick")
    self.itemInfoEdit = ccui.Helper:seekWidgetByName(self.gui, "item_info_edit")
    self.itemInfoGold = ccui.Helper:seekWidgetByName(self.gui, "item_info_gold")
    self.itemInfoTitle = ccui.Helper:seekWidgetByName(self.gui, "item_info_title")

    
    self.btn_common = ccui.Helper:seekWidgetByName(self.gui, "btn_common")

    self.itemInfoGold:getChildByName("img_gold"):loadTexture(Cache.packetInfo:getGoldImg())

    self:addClickListner()
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function(event, touch) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener1:registerScriptHandler(function(event, touch)end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self)
    
    self:initLocalInfo(paras)
end

function UserInfo:initData()
    self.index = "common"
    self.userinfoData = nil
end

function UserInfo:initLocalInfo(paras)
    if paras then
        self.incomeInfo = paras
    end
    -- body
    if paras.localinfo then
        if paras.localinfo.gold then
            -- 金币
            self.itemInfoGold:getChildByName("lbl_gold"):setString(Util:getFormatString(paras.localinfo.gold))
        end
        if paras.localinfo.nick then
            -- 昵称
            self.itemInfoNick:getChildByName("nick_txt"):setString(GameTxt.string904..paras.localinfo.nick)
        end
        -- 头像
        self.imgHead:setVisible(true)
        Util:updateUserHead(self.imgHead, paras.localinfo.portrait, paras.localinfo.sex, {url = true, circle = true, add = true}) --头像变成实际头像
    end
end

--[[根据服务器数据刷新界面]]
function UserInfo:initView(paras)
    self.model = paras.model
    self:setInfo()
    
    self.itemInfoNick:getChildByName("img_sex"):loadTexture(string.format(GameRes.img_user_info_my_sex, self.model.sex))

    self:delayRun(0, function() 
        self:setHeadByUin(self.imgHead, self.uin) 
    end) 
    self:delayRun(0.05, function() 
        self.imgHead:setVisible(true) 
    end)
    self:setUserIdDisplay() --设置用户id的显示
end

--设置用户id的显示
function UserInfo:setUserIdDisplay()
    --如果本人是vip，且当前在私人定制场内，显示用户ID。
    if GAME_SHOW_UIN_FLAG and ModuleManager:judegeIsIngame() 
        and Cache.DeskAssemble:judgeGameType(JDC_MATCHE_TYPE) 
        and Cache.desk:isCustomizeRoom() then
        ccui.Helper:seekWidgetByName(self.gui, "item_info_uin"):setVisible(true)
    else
        ccui.Helper:seekWidgetByName(self.gui, "item_info_uin"):setVisible(true)
    end
end

function UserInfo:setInfo()
    local str = self.model.nick
    -- 用户id
    ccui.Helper:seekWidgetByName(self.gui, "txt_uin"):setString("ID："..tostring(self.uin))

    ccui.Helper:seekWidgetByName(self.gui, "txt_uin"):setVisible(Cache.user.uin == self.uin)
    if self.uin ~= Cache.user.uin then
        ccui.Helper:seekWidgetByName(self.gui, "txt_uin"):setVisible(false)
    else
        ccui.Helper:seekWidgetByName(self.gui, "txt_uin"):setVisible(true)
    end
    

    -- 昵称
    self.itemInfoNick:getChildByName("nick_txt"):setString(GameTxt.string904..self.model.nick)
    -- 金币
	local tmpGold = self.model.gold + self.model.chips
    print(" >>>>> tmpGold", tmpGold)
    
    local goldeDateType = 1
    -- -- 主要是无座玩家使用
    if self.incomeInfo then
        if type(self.incomeInfo.showGoldTxt) == "string" and self.incomeInfo.showGoldTxt and self.incomeInfo.showGoldTxt ~= "" then
            goldeDateType = 2
        end
    end

    self.itemInfoGold:getChildByName("lbl_gold"):setString(goldeDateType == 1 and Util:getFormatString(Cache.packetInfo:getProMoney(tmpGold)) or self.incomeInfo.showGoldTxt) --这里金币是0，因为全兑换成筹码了
    -- 头像
    self.imgHead:setVisible(true)
    Util:updateUserHead(self.imgHead, self.model.portrait, self.model.sex, {url = true, circle = true, add = true}) --头像变成实际头像
    if Util:checkSysZhuangUin(self.uin) then
        self.itemInfoGold:setVisible(false)
    else
        self.itemInfoGold:setVisible(true)
    end
end

function UserInfo:delayRun(time, cb, tag)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time), 
    cc.CallFunc:create(function () if cb then cb() end end))
    if tag then action:setTag(tag) end
    self:runAction(action)
end

--[[下载图片 start]]
function UserInfo:setHeadByUin(view, uin)
    if view == nil or uin == nil then return end
    local HeadImage = HeadImage.new({node = view})
    self:viewAddClick(HeadImage, "big_head_image")
    
    local defaultImag = GameRes.default_man_large_icon
    if self.model.sex == 1 then
        defaultImag = GameRes.default_girl_large_icon
    end
    if self._defaultImg then
        defaultImag = self._defaultImg
    end
    if self.hide == 1 then
        Util:updateUserHead(HeadImage, Cache.Config.hiding_portrait[self.model.sex + 1], self.model.sex, {url = true, circle = true, add = true, default= defaultImag})
    else
        Util:updateUserHead(HeadImage, self.model.portrait, self.model.sex, {url = true, circle = true, add = true, default= defaultImag})
    end
end

function UserInfo:addClickListner()
    self:viewAddClick(self.gui, "root")
    self:viewAddClick(self.gui:getChildByName("back"), "root")
    self.gui:getChildByName("bg"):setTouchEnabled(true)
    Util:registerKeyReleased({self = self, cb = function ()
        self:close()
    end})
    self:viewAddClick(self.gui:getChildByName("btn_gallery"), "btn_gallery")
    self:viewAddClick(self.btn_title_desc, "btn_title_desc")
end

--[[加点击事件start]]
function UserInfo:viewAddClick(view, name)
    if view == nil or tolua.isnull(view) then
        return
    end
    view:setTouchEnabled(true)
    view.name = name
    view:addTouchEventListener(handler(self, self.addCallBack)) 
end

function UserInfo:addCallBack(sender, eventType)
    if sender.clickable == false then return false end
    if eventType == ccui.TouchEventType.began then
        return true
    elseif eventType == ccui.TouchEventType.moved then
    elseif eventType == ccui.TouchEventType.ended then
        return self:myClick(sender, sender.name)
    elseif eventType == ccui.TouchEventType.canceled then
    end
end

function UserInfo:myClick(sender, name)
    if self.editBoxShowing == true then
        return
    end
    MusicPlayer:playMyEffect("BTN")
    if name == "root" then
            self:close()
    elseif name == "btn_gallery" then
        local gallery = Gallery.new({uin = self.uin, model = self.model})
        gallery:show()
    elseif name == "big_head_image" then
        qf.event:dispatchEvent(ET.SHOW_BIG_HEAD_IMAGE_EVENT, {src_photo = sender})
    end
end
--[[加点击事件end]]

--显示UserInfo
function UserInfo:show(paras)
    if paras == nil or paras.uin == nil then return end
    self.uin = paras.uin
    self.type = paras.type
    self.hide_enabled = paras.hide_enabled or false--是否可以显示隐身状态
    self.hide_nick = paras.hide_nick--隐身后的昵称
    self.from_friend = paras.from_friend or 0 --是否来自 好友资料卡
    self._defaultImg = paras.defaultImg
    self.super.show(self) 
    if paras.face then
        self:setFaceGold(paras.face)
    end
end

function UserInfo:setFaceGold(paras)
    if not self.goldText then return end
    -- body
    self.goldText:setString(paras.gold .. Cache.packetInfo:getShowUnit())
end

return UserInfo