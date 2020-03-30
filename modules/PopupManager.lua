--[[
    重要提示!!! 140版本开始:
    (1) 强制所有PopupWindow都加载在PopupLayer上, 非弹框node不允许加在该layer上
    (2) 继承自 qf.view 的类，如果是弹框类型，getRoot要返回LayerMananger.PopupLayer
    (3) 弹出框背景名为"LAYERMANAGER_POPUP_BACKGROUND", 其他控件不要重名
]]
local PM = class("PM")

--===================================
--弹框在此定义
--===================================
PM.POPUPWINDOW_START=4000
PM.POPUPVIEW_START=8000
--这里的弹框是一个普通的node或者layer，不加入模块管理
PM.POPUPWINDOW = enum(PM.POPUPWINDOW_START,
    "background",
    "brHelper", 
    "brHistory",
    "userinfo",
    "jackpotInfo",
    "jackpotRecord",
    "jackpotRules",
    "jackpotBrInfo",
    "shopPromit",   --快捷支付
    "bankruptcy",   --破产弹框
    "activeNotice",   --活动通知
    "createRoom",      --创建房间
    "searchRoom",       --搜索房间
    "inviteFriend",     --被好友邀请
    "friendInvite",     --邀请好友
    "friendApply",       --申请好友
    "customizeCreateRoom", --私人定制创建房间
    "phoneBinding",    --绑定手机
    "passwordView",
    "heGuanDialog",
    "brPerson",
    "brDelarList",
    "inviteView",
    "gallery",
    "gameLevelUp",
    "exitDialog",
    "lockDesk",
    "scoreExchange",
    "giveGiftTip",
    "sngSettle",                --sng结算
    "matchResult",              --sng赛况
    "SNGLevel",                 --等级系统
    "goodDetailView",           --物品详情框
    "vipDetailView",            --VIP详情
    "buyPopupTipView",          --购买提示框
    "payMethodView",            --支付方式框
    "WaitingQueueDialog",       --等待人数过多提示
    "mttRuleView",              --mtt大厅规则框
    "mttApplySuccessView",      --mtt大厅报名成功框
    "mttMatchDetailsView",       --mtt大厅赛况框
    "giftCardTipView",          --礼物卡提示框
    "deskCountdown",            --mtt倒计时界面
    "rebuyView",                --mtt重购&增购
    "mttMatchResult",           --mtt赛况
    "mttSettle",                --mtt名次结算弹窗
    "commonTipWindow",           --公共提示框-- 标题、内容、取消、确认
    "mttGameStatusTip",           --mtt赛事通知
    "dailylogin",
    "installgame",
    "firstpay",
    "winningstreak",
    "lackgold",
    "friendtips",
    "turntable",
    "newtotallogin",
    "firstgame",
    "freegoldshortcut",
    "lhdHelper",
    "lhdHistory",
    "lhdDelarList",
    "visitortips",
    "chaozhipay",
    "changePwd",
    "bindCard",
    "inviteCode",
    "messageBox",
    "personal",
    "custom",
    "setting",
    "ddzsetting",
    "exchange",
    "safeBox",
    "newAgreeMent",
    "newActivity",
    "gameRule",
    "mailView",
    "newShop",
    "retMoneyView",
    "bJLDelarList",
    "bjlHelper",
    "bjlHistory",
    "bjlPerson",
    "bjlDalu",
    "hongbaoView",
    "maintainView",
    "agencyView",
    "luckView",
    "debugView",
    "agencyAlert",
    "customerServiceChat",
    "walletRecord",
    "HeadMaskShopView",
    "HeadMaskBagView",
    "userPolicyView",
    "communityView"
)
--[[
    这里的弹窗是一个moudle， 名字要与ModuleManager中定义的一致
    例如: module中定义， self.setting = settingModule.new(), setting是一个弹窗，那么要加入这里:"setting"
]]
PM.POPUPVIEW = enum(PM.POPUPVIEW_START,
    "setting", 
    "prize",
    "rank",
    "daoju",
    "change_userinfo",
    "gift",
    "friend",
    "share",
    "activity",
    "safeBox",
    "changePwd",
    "exchange",
    "inviteCode",
    "custom",
    "messageBox",
    "personal"
)
--===================================
--以下代码不要随意修改
--===================================
PM.DEBUG = false
PM.TAG = "PopupMananger"
PM.BG_STYLE = enum(0, "NONE", "BLUR", "GREY", "DARK", "HIGHLIGHT")
PM.STATUS = enum(0, "NORMAL", "UPWARD")
PM.ACTION_TAG = 8001
PM.DEFAULT_BLUR_RADIUS = 10
PM.DEFAULT_HIGHLIGHT_INCREMENT = 50

function PM:ctor()
    self.winSize = cc.Director:getInstance():getWinSize()
    self.status = PM.STATUS.NORMAL
end

--===================================
--Public Interface
--===================================
--设置弹框层大小和位置
function PM:init()
    self.root = LayerManager.PopupLayer
    self.root:setContentSize(self.winSize.width, self.winSize.height)
    self.root:setAnchorPoint(cc.p(0, 0))
    self.root:setPosition(cc.p(0, 0))
    self.root:setVisible(true)
    self.zorder = self.root:getZOrder()
end

--获取弹框所在层
function PM:getPopupLayer()
    return self.root
end

--添加一个弹框
function PM:addPopupWindow(id, windowNode)
    if id < PM.POPUPVIEW_START and self.root:getChildByTag(id) ~= nil then
        self.root:removeChildByTag(id)  --如果存在相同弹窗，先移除
    end
    self.root:addChild(windowNode, 0, id)
end

--获取弹框对象
function PM:getPopupWindow(id)
    return self.root:getChildByTag(id)
end

--显示/添加弹框背景(在弹框弹出时调用)
function PM:checkShowBackground(id, style, cb)
    -- if qf.device.platform ~= "ios" and style ~= self.BG_STYLE.NONE then --目前只有ios支持高斯模糊背景，其他平台暂时使用暗背景
    --     self:_log("目前只有IOS平台支持弹窗背景. 非IOS平台不能添加背景.")
    --     style = self.BG_STYLE.DARK
    -- end

    if id==PM.POPUPWINDOW["payMethodView"] then 
        if cb then cb() end
        return 
    end
    self:_removeBackground()
    style = self.BG_STYLE.DARK
    if qf.device.platform == "ios" and (id==PM.POPUPWINDOW["firstpay"] or id==PM.POPUPWINDOW["turntable"] or id==PM.POPUPWINDOW["newtotallogin"] or id==PM.POPUPWINDOW["visitortips"] ) then
        style = self.BG_STYLE.BLUR
    elseif id == PM.POPUPWINDOW["freegoldshortcut"] or 
        PM.POPUPVIEW["friend"]==id or  
        --PM.POPUPVIEW["setting"]==id or  
        PM.POPUPVIEW["prize"]==id or  
        PM.POPUPVIEW["rank"]==id or  
        PM.POPUPVIEW["activity"]==id then
        style = self.BG_STYLE.BGIMG
    end
    self:reset(id)
    local bg = self.root:getChildByTag(self.POPUPWINDOW.background)

    if bg ~= nil then
        --如果背景存在, 直接设置可见
        if not bg:isVisible() then
            self:_backgroundFadeIn()
        end
        if cb then cb() end
    else
        if style == self.BG_STYLE.BLUR then
            QNative:shareInstance():getScreenBlurSprite(function(success, sprite)
                if success and sprite ~= nil then
                    self:_addBackgroundSprite(sprite)
                end
                if cb then cb() end
            end, false, self.DEFAULT_BLUR_RADIUS)
        elseif style == self.BG_STYLE.GREY then
            QNative:shareInstance():getScreenGraySprite(function(success, sprite)
                if success and sprite ~= nil then
                    self:_addBackgroundSprite(sprite)
                end
                if cb then cb() end
            end, true)
        elseif style == self.BG_STYLE.DARK then
            local sprite = cc.Sprite:create(GameRes.common_widget_dark_bg)
            self:_addBackgroundSprite(sprite)
            if cb then cb() end
        elseif style == self.BG_STYLE.BGIMG then
            local sprite = cc.Sprite:create(GameRes.mohubg)
            self:_addBackgroundSprite(sprite)
            if cb then cb() end
        elseif style == self.BG_STYLE.HIGHLIGHT then
            QNative:shareInstance():getScreenHighlightSprite(function(success, sprite)
                if success and sprite ~= nil then
                    self:_addBackgroundSprite(sprite)
                end
                if cb then cb() end
            end, false, self.DEFAULT_HIGHLIGHT_INCREMENT)
        else
            if cb then cb() end
        end
    end
end

--隐藏/移除弹框背景(在弹框关闭时调用)
function PM:checkRemoveBackground()
    self:setTouchLayerEnabled(false)
    local visible = false
    local children = self.root:getChildren()
    for k, child in pairs(children) do
        local tag = child:getTag()
        if tag ~= self.POPUPWINDOW.background and child:isVisible() then
            self:_log("还存在弹框，保留背景. tag="..tostring(tag))
            visible = true
            break
        end
    end
    if not visible then
        self:_log("所有弹框都被关闭了，移除背景")
        self:_removeBackground() --如果所有child都不可见,就将背景移除.
    end
    return visible
end

--移除所有弹框(如果modules的view不是一个弹窗，那么在其remove的时候，要调用这个接口)
function PM:removeAllPopup(id)
    self:setTouchLayerEnabled(false)
    self:_removeAllOtherChlid(id)
    self.root:setPosition(0, 0)
    self.root:setZOrder(self.zorder)
    self.root:setVisible(true)
end

--收起所有弹框
function PM:upwardAllPopup()
    if self.root:getActionByTag(PM.ACTION_TAG) and self.status == PM.STATUS.UPWARD then --如果有其他动作正在进行，打断并直接设置位置，防止动画出错
        self.root:stopActionByTag(PM.ACTION_TAG)
        self.root:setPosition(0, self.winSize.height)
        self:_setBgVisible(false)
        self:setTouchLayerEnabled(false)
    elseif self:checkRemoveBackground() and self.status == PM.STATUS.NORMAL then
        self:_setBgVisible(false)
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.3, cc.p(0, self.winSize.height)),
            cc.CallFunc:create(function()
                self.root:setZOrder(-1)
                self.root:setVisible(false)
                self:setTouchLayerEnabled(false)
            end))
        action:setTag(PM.ACTION_TAG)
        self.root:runAction(action)
        self.status = PM.STATUS.UPWARD
        self:setTouchLayerEnabled(true)
    end
end

--拉回所有弹框
function PM:downwardAllPopup()
    self:setTouchLayerEnabled(false)
    if self.root:getActionByTag(PM.ACTION_TAG) then --如果有其他动作正在进行，打断并直接设置位置，防止动画出错
        self.root:stopActionByTag(PM.ACTION_TAG)
        self.root:setPosition(0, 0)
        self:_setBgVisible(true)
    elseif self:checkRemoveBackground() and self.status == PM.STATUS.UPWARD then
        self.root:setZOrder(self.zorder)
        self.root:setVisible(true)
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.3, cc.p(0, 0)),
            cc.CallFunc:create(function()
                self:_setBgVisible(true)
            end)
        )
        action:setTag(PM.ACTION_TAG)
        self.root:runAction(action)
    else
        self.root:setPosition(0, 0)
    end
    self.status = PM.STATUS.NORMAL
end

--===================================
--Private Function(外部禁止调用)
--===================================
--移除背景
function PM:_removeBackground()
    if self.root:getChildByTag(self.POPUPWINDOW.background) then
        self.root:removeChildByTag(self.POPUPWINDOW.background)
    end

    self.root:getEventDispatcher():removeEventListenersForTarget(self.root)
end

--背景慢慢出现效果
function PM:_backgroundFadeIn()
    local bg = self.root:getChildByTag(self.POPUPWINDOW.background)
    if bg ~= nil and bg:getNumberOfRunningActions() == 0 then
        bg:setVisible(true)
        bg:setOpacity(155)
        bg:runAction(cc.FadeTo:create(0.2, 255))
    end
end

function PM:_setBgVisible(visible)
    local bg = self.root:getChildByTag(self.POPUPWINDOW.background)
    if bg then
        bg:setVisible(visible)
    end
end

--添加背景精灵

function PM:_addBackgroundSprite(node, bdirShow)
    if node ~= nil then
        local size = node:getContentSize()
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(cc.p(self.winSize.width / 2, self.winSize.height / 2))
        node:setScaleX(self.winSize.width / size.width)
        node:setScaleY(self.winSize.height / size.height)

        self.root:addChild(node, -1, self.POPUPWINDOW.background)

        --fix bug 将此处设置为点击吞噬 可能会造成多个页面可以同时存在
        Util:addNormalTouchEvent(self.root, function ( method, touch, event )
            return true
        end)

        self:_backgroundFadeIn()
    end
end

--移除..之外的所有子节点. id == nil 时移除所有子节点
function PM:_removeAllOtherChlid(id)
    local children = self.root:getChildren()
    for k, child in pairs(children) do
        local tag = child:getTag()
		loga("child name is "..child:getName().."root name is "..self.root:getName())
        if id == nil or id ~= tag then
            if tag >= PM.POPUPVIEW_START then
                --这是一个模块，必须调用Module.remove来移除
                local key = self:getTagKey(tag, PM.POPUPVIEW)
                if key ~= nil and ModuleManager[key] ~= nil then
                    ModuleManager[key]:remove()
                    self:_log("从弹窗层移除一个Module: "..tostring(key))
                else
                    loge("!! 弹窗管理尝试移除一个未知tag的moudle. tag="..tostring(tag))
                end
            elseif tag == PM.POPUPWINDOW_START then
                --背景直接移除
                self:_log("从弹窗层移除背景")
                self.root:removeChildByTag(tag)
			elseif tag < 0 then
				return --无效的tag直接返回
            else
                --弹窗，调用析构函数 destructor
                local key = self:getTagKey(tag, PM.POPUPWINDOW)
                if key ~= nil then 
                    self:_log("从弹窗层移除一个 Node "..key) 
                    if child.destructor then
                        child:destructor()
                    end
                else
                    loge("!! 弹窗管理尝试移除一个未知tag的子节点. tag="..tostring(tag))
                end
                self.root:removeChildByTag(tag)
            end
        end
    end
end

function PM:getTagKey(tag, tab)
    for k,v in pairs(tab) do
        if v == tag then
            return k
        end
    end
end

--在打开一个新的弹框时调用，如果PopupLayer是向上收起状态，移除所有其他的弹窗
function PM:reset(id)
    self:_log("打开了新的弹窗. 当前状态: "..tostring(self.status))
    self:setTouchLayerEnabled(false)
    if self.root:getActionByTag(PM.ACTION_TAG) then --如果有正在向上拉/向下收的动作，先停止
        self:_log("停止动画")
        self.root:stopActionByTag(PM.ACTION_TAG)
    end
    local y = self.root:getPositionY()
    if (self.status == PM.STATUS.UPWARD) or (y ~= 0) or (not self.root:isVisible()) or (self.root:getZOrder() ~= self.zorder) then
        self:_log("目前PopupLayer被移动到了屏幕外, 移除所有屏幕外的弹框, 再打开新的弹框")
        self:_removeAllOtherChlid(id)
        self.root:setPosition(0, 0)
        self.root:setZOrder(self.zorder)
        self.root:setVisible(true)
        self.status = PM.STATUS.NORMAL
    end
end

function PM:_log(str)
    --if PM.DEBUG then loga("["..PM.TAG.."]"..str) end
    if PM.DEBUG then logd(str, PM.TAG) end
end

--当弹窗层在移动时，覆盖在上面吞噬点触
function PM:setTouchLayerEnabled(visible)
    if visible then
        if self.touch_layer == nil then
            self.touch_layer = cc.Layer:create()
            self.touch_layer:setContentSize(self.winSize.width, self.winSize.height)
            self.root:addChild(self.touch_layer, 100)

            local listener = cc.EventListenerTouchOneByOne:create()  
            listener:setSwallowTouches(true)
            listener:registerScriptHandler(function(touch, event)
                    return true
                end, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(function(touch, event) end,
                cc.Handler.EVENT_TOUCH_MOVED)
            listener:registerScriptHandler(function(touch, event) end,
                cc.Handler.EVENT_TOUCH_ENDED)
            self.touch_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.touch_layer)
        end
        Util:addNormalTouchEvent(self.root, function ( method, touch, event )
            return true
        end)
    else
        if self.touch_layer ~= nil and not tolua.isnull(self.touch_layer) then
            self.touch_layer:removeFromParent(true)
            self.touch_layer = nil
        end
        self.root:getEventDispatcher():removeEventListenersForTarget(self.root)
    end
end



PopupManager = PM.new()
