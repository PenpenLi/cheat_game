local _MainView = import(".MainView")
local MainView = class("MainView", _MainView)

local AnimationConfig = import(".config.AnimationConfig")
function MainView:ctor(parameters)
    self.super.super.ctor(self, parameters)
    self:init(parameters)
    self:enterMainView(parameters)
end

function MainView:getRoot() 
    return LayerManager.MainLayer 
end 

function MainView:initWithRootFromJson()
    return GameRes.reviewMainViewJson
end

function MainView:init(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:initUI()
    if FULLSCREENADAPTIVE then
        self:initFullScreenAdaptive()
    end

end

function MainView:initFullScreenAdaptive()
    local dx = (cc.Director:getInstance():getWinSize().width-1920)/2

    for k, v in pairs(self.root:getChildren()) do
        Util:setPosOffset(v, {x = dx})
    end
end

function MainView:initUI()
    local shopHandler = {
        function (sender)
            self:onButtonEvent(sender)
        end, 
        function (sender)
            sender:setScale(1.1)
        end,
        nil,
        function (sender)
            sender:setScale(1.0)
        end
    }

    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "playerIcon",        path = "Panel_top/Panel_user_info/Image_head_frame", handler = defaultHandler},
        {name = "playerHeadMask",        path = "Panel_top/Panel_user_info/Image_head_frame_0"},
        {name = "playerNickTxt",     path = "Panel_top/Panel_user_info/Label_name",       handler = nil},               
        {name = "playerIdTxt",       path = "Panel_top/Panel_user_info/Label_id",         handler = nil},

        {name = "playerGoldTxt",     path = "Panel_top/Panel_gold/Label_gold",  handler = nil},
        {name = "playerGoldBtn",     path = "Panel_top/Panel_gold",  handler = defaultHandler},
        {name = "imageGold",        path = "Panel_top/Panel_gold/Image_gold"},

        {name = "customBtn",          path = "Panel_left_up/Button_customer",          handler = defaultHandler},
        {name = "headMaskShopBtn",    path = "Panel_left_up/head_mask_shop_btn",          handler = defaultHandler},
        {name = "retMoneyBtn",      path = "Panel_left_up/Button_RetMoney",      handler = defaultHandler},
        {name = "bindPhoneBtn",      path = "Panel_left_up/Button_bind",      handler = defaultHandler},

        {name = "shopBtn",      path = "Panel_bottom/Button_shop",      handler = defaultHandler},
        {name = "safeBox",      path = "Panel_bottom/Button_bank",      handler = defaultHandler},
        {name = "activeBtn",      path = "Panel_bottom/Button_active",      handler = defaultHandler},
        {name = "settingBtn",    path = "Panel_bottom/Button_set",   handler = defaultHandler},
        {name = "mailBtn",    path = "Panel_bottom/Button_mail",   handler = defaultHandler},
        {name = "quickStartBtn",    path = "Panel_bottom/Button_quick_start",   handler = defaultHandler},

        {name = "qznnBtn",        path = "Panel_Game/Button_qznn", handler = defaultHandler},
        {name = "brnnBtn",          path = "Panel_Game/Button_BRNN",          handler = defaultHandler},
        {name = "lhdBtn",          path = "Panel_Game/Button_LHD",          handler = defaultHandler},
        {name = "zjhBtn",          path = "Panel_Game/Button_ZJH",          handler = defaultHandler},
        {name = "brBtn",          path = "Panel_Game/Button_BR",          handler = defaultHandler},
    }

    Util:bindUI(self, self.root, uiTbl)
    self:loadSpriteFrame()
    self:refreshHeadMaskBtn()
    self:refreshBindRewardBtn()
    self:initHallBtnAnimation()

    Util:addButtonScaleAnimFuncWithDScale(self.shopBtn, defaultHandler)
    Util:addButtonScaleAnimFuncWithDScale(self.quickStartBtn, defaultHandler)

    Util:addButtonScaleAnimFuncWithDScale(self.qznnBtn, defaultHandler)
    Util:addButtonScaleAnimFuncWithDScale(self.brnnBtn, defaultHandler)
    Util:addButtonScaleAnimFuncWithDScale(self.lhdBtn, defaultHandler)
    Util:addButtonScaleAnimFuncWithDScale(self.zjhBtn, defaultHandler)
    Util:addButtonScaleAnimFuncWithDScale(self.brBtn, defaultHandler)
end

function MainView:loadSpriteFrame( ... )
    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(GameRes.hall_game_btn_sprite_plist_1, GameRes.hall_game_btn_sprite_png_1)
    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(GameRes.hall_game_btn_sprite_plist_2, GameRes.hall_game_btn_sprite_png_2)
end

function MainView:removeSpriteFrameFromeCache( ... )
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GameRes.hall_game_btn_sprite_plist_1)
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(GameRes.hall_game_btn_sprite_png_1)
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GameRes.hall_game_btn_sprite_plist_2)
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(GameRes.hall_game_btn_sprite_png_2)
end

function MainView:initHallBtnAnimation( ... )

    self:initGameBtnWithAnimation(self.imageGold, AnimationConfig.HALL_GOLD, {x  = 0, y= 0})

    self:initGameBtnWithAnimation(self.qznnBtn, AnimationConfig.HALL_GMAE_NIUNIU, {x  = 0, y= 0})
    self:initGameBtnWithAnimation(self.brnnBtn, AnimationConfig.HALL_GMAE_BRNN, {x  = 0, y= 0})
    self:initGameBtnWithAnimation(self.lhdBtn, AnimationConfig.HALL_GMAE_LHD, {x  = 0, y= 0})
    self:initGameBtnWithAnimation(self.zjhBtn, AnimationConfig.HALL_GMAE_ZJH, {x  = 0, y= 0})
    self:initGameBtnWithAnimation(self.brBtn, AnimationConfig.HALL_GMAE_BR, {x  = 0, y= 0})

    local addGameSpriteFrameAniFunc = function (node, animationConfig)
        if not node then return end
        if node:getChildByName(animationConfig.gameName) then
            node:stopAllActions()
            node:removeChildByName()
        end
        local defaultImageFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(animationConfig.name, 1))
        local sprite = cc.Sprite:createWithSpriteFrame(defaultImageFrame)
        sprite:setName(animationConfig.gameName)
        sprite:setPosition(cc.p(node:getContentSize().width/2 + animationConfig.offset.x, node:getContentSize().height/2 + animationConfig.offset.y))
        local spriteFrames = {}
        for i = 1, animationConfig.count  do
            spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(animationConfig.name, i))
        end
        local animation = cc.Animation:createWithSpriteFrames(spriteFrames, animationConfig.time)
        sprite:runAction(cc.RepeatForever:create( cc.Animate:create(animation) ) )
        node:addChild(sprite)
    end

    addGameSpriteFrameAniFunc(self.qznnBtn, self:getGameBtnAnimationConfig("game_niuniu"))
    addGameSpriteFrameAniFunc(self.brnnBtn, self:getGameBtnAnimationConfig("game_brnn"))
    addGameSpriteFrameAniFunc(self.lhdBtn, self:getGameBtnAnimationConfig("game_lhd"))
    addGameSpriteFrameAniFunc(self.zjhBtn, self:getGameBtnAnimationConfig("game_zjh"))
    addGameSpriteFrameAniFunc(self.brBtn, self:getGameBtnAnimationConfig("game_br"))

    self:initGameBtnWithAnimation(self.quickStartBtn, AnimationConfig.HALL_QUICK_START, {x  = 0, y= 0})
    self:initGameBtnWithAnimation(self.shopBtn, AnimationConfig.HALL_SHOP, {x  = -40, y= -35})
    self:initGameBtnWithAnimation(self.shopBtn:getChildByName("tips"), AnimationConfig.HALL_SHOP_TIPS, {x  = 140, y= 30})
end

function MainView:updateShopTips( ... )
    self.shopBtn:getChildByName("tips"):setVisible(Cache.user.store_first_recharge == 1)
end

function MainView:getGameBtnAnimationConfig(gameName)
    local config = {
        ["game_br"] = {
            name = GameRes.hall_game_btn_frame_name["game_br"],
            gameName = "game_br",
            count = 20,
            time = 0.05,
            offset = {x = 0, y = 20}
        },
        ["game_brnn"] = {
            name = GameRes.hall_game_btn_frame_name["game_brnn"],
            gameName = "game_brnn",
            count = 20,
            time = 0.05,
            offset = {x = 10, y = 40}
        },
        ["game_zjh"] = {
            name = GameRes.hall_game_btn_frame_name["game_zjh"],
            gameName = "game_zjh",
            count = 10,
            time = 0.1,
            offset = {x = 0, y = 20}
        },
        ["game_niuniu"] = {
            name = GameRes.hall_game_btn_frame_name["game_niuniu"],
            gameName = "game_niuniu",
            count = 20,
            time = 0.05,
            offset = {x = 0, y = 40}
        },
        ["game_lhd"] = {
            name = GameRes.hall_game_btn_frame_name["game_lhd"],
            gameName = "game_lhd",
            count = 10,
            time = 0.1,
            offset = {x = -10, y = 40}
        }
    }
    return config[gameName]
end

function MainView:initGameBtnWithAnimation(sender, anim, offset, faceName)
    local face = Util:addAnimationToSender(sender, {anim = anim, node = sender, posOffset = offset, forever =true})
    if faceName then
        face:setName(faceName)
    end
    return face
end

function MainView:refreshHeadMaskBtn( ... )
    if Cache.user:isProxy() then
        self.headMaskShopBtn:setVisible(false)
        self.retMoneyBtn:setVisible(false)
        self.retMoneyBtn:setPositionX(self.headMaskShopBtn:getPositionX())
    else
        self.headMaskShopBtn:setVisible(true)
    end
end

function MainView:refreshBindRewardBtn()
    if Cache.user:isBindPhone() or Cache.user:isProxy() then
        self.bindPhoneBtn:setVisible(false)
    end
end

function MainView:refreshCustomerBtn( ... )
    if self.customBtn.bNewMsg == true then
        return
    end
    local newMesgNode = self.customBtn:getChildByName("newMsgAni")
    if not newMesgNode then
        return
    end
    newMesgNode:setVisible(true)
    newMesgNode:stopAllActions()
    newMesgNode:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.EaseSineOut:create (cc.Spawn:create(
                -- cc.ScaleTo:create(0.05,1),
                cc.FadeIn:create(0.05)
            )),
            -- cc.EaseSineOut:create(cc.ScaleTo:create(0.05,1.05)),
            -- cc.EaseSineIn:create(cc.ScaleTo:create(0.05,1)),
            cc.DelayTime:create(3),
            cc.FadeOut:create(0.05),
            cc.DelayTime:create(0.8),
            cc.CallFunc:create(function ( sender )
                
            end)
        )
    ))
    self.customBtn.bNewMsg = true
end

--普通按键相关
function MainView:onButtonEvent(sender)
    print("sender 》》》", sender.name)
    if sender.name == "playerGoldBtn" then
        qf.event:dispatchEvent(ET.SHOP)        
    elseif sender.name == "playerIcon" then
        qf.event:dispatchEvent(ET.PERSONAL_INFO)
    elseif sender.name == "shopBtn" then
        qf.event:dispatchEvent(ET.SHOP)
    elseif sender.name == "bindBtn" then
        qf.event:dispatchEvent(ET.BIND_REWARD)
    elseif sender.name == "retMoneyBtn" then
        qf.event:dispatchEvent(ET.RETMONEY)

    elseif sender.name == "customBtn" then
        sender.bNewMsg = false
        local newMesgNode = self.customBtn:getChildByName("newMsgAni")
        if newMesgNode then
            newMesgNode:setVisible(false)
            newMesgNode:stopAllActions()
        end
        qf.event:dispatchEvent(ET.CUSTOM_CHAT,{autoLink = true})
    elseif sender.name == "bindPhoneBtn" then
        qf.event:dispatchEvent(ET.CHANGE_PWD,{showType = 4})
    elseif sender.name == "mailBtn" then
        local cb = function ()
            qf.event:dispatchEvent(ET.MAIL)
        end
        Cache.mailInfo:requestMailInfo(cb)
    elseif sender.name == "settingBtn" then
        qf.event:dispatchEvent(ET.SETTING)
    elseif sender.name  == "activeBtn" then
        qf.event:dispatchEvent(ET.NEWACITIVY)
    elseif sender.name == "moreBtn" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "XXXXXXXXXXXXXX"})
    elseif sender.name == "safeBox" then
        qf.event:dispatchEvent(ET.SAFE_BOX)
    elseif sender.name == "qznnBtn" then
        self.super:runGame("game_niuniu")
    elseif sender.name == "brnnBtn" then
        self.super:runGame("game_brnn")
    elseif sender.name == "lhdBtn" then
        self.super:runGame("game_lhd")
    elseif sender.name == "zjhBtn" then
        self.super:runGame("game_zjh")
    elseif sender.name == "brBtn" then
        self.super:runGame("game_br")
    elseif sender.name == "headMaskShopBtn" then
        qf.event:dispatchEvent(ET.HEAD_MASK_SHOP)
    elseif sender.name == "quickStartBtn" then
        qf.event:dispatchEvent(ET.QUICK_START_GAME)
    else
        if sender.name then
            logd(string.format("%s not bind clickistener", sender.name))
        end
    end
end

--累计登陆
function MainView:NewTotalLodinShow()
end
    
--初始化游戏图标
function MainView:initGames()
end

function MainView:isShowPop(size)
end

-- 进入主界面，初次进入游戏或者返回主界面调用 
function MainView:enterMainView(parameters)
    qf.event:dispatchEvent(ET.SETBROADCAST,GameConstants.BROADCAST_POS)
    if parameters then
        if parameters.toChat then
            Util:delayRun(0.35, function ( ... )
                qf.event:dispatchEvent(ET.CUSTOM_CHAT,{autoLink = true})
            end)
        end
    end
end
    
-- 设置个人基本信息
function MainView:updateUserInfo()
    -- -- 更新信息栏

    local u = Cache.user
    print(u.gold)
    print("asdfasdf", type(u.gold))

    self.playerNickTxt:setString(u.nick)
    print(">>>>>>>>>>>>>>>> ID uin", Cache.user.uin)
    self.playerIdTxt:setString("ID:"..Cache.user.uin)
    self.playerIdTxt:setVisible(true)
    print(u.gold)
    self.playerGoldTxt:setString(Util:getFormatString(u.gold))
end

-- 更新头像
function MainView:updateUserHead()
    self.playerIcon:removeAllChildren()
    loga("user head url = "..Cache.user.portrait)
    Util:updateUserHead(self.playerIcon, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true, circle=false})
    Cache.user.number = Cache.user.number or 0
    if Cache.user.number > 0 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.headMaskPlist, GameRes.headMaskPng)
        self.playerHeadMask:setScale(0.5)
        self.playerHeadMask:loadTexture(string.format(GameRes.headMaskImage, Cache.user.number, 1),ccui.TextureResType.plistType)
    else
        self.playerHeadMask:setScale(1.02)
        self.playerHeadMask:loadTexture(GameRes.headMaskDefault, ccui.TextureResType.plistType)
    end
end

-- 更新钻石
function MainView:updateUserDiamond()
end

-- 设置界面是否可点击
function MainView:setTouch(isCantouch)
    self.isCantouch = isCantouch
    self.setAllTouch = function(root)
        for k, v in pairs(root:getChildren())do
            if v.setTouchEnabled then
                if v:isTouchEnabled() and not isCantouch then
                    v:setTouchEnabled(isCantouch)
                    v.cansetTouch = true
                elseif v.cansetTouch then
                    v.cansetTouch = nil
                    v:setTouchEnabled(isCantouch)
                end
            end
            self.setAllTouch(v)
        end
    end
    self.setAllTouch(self.root)
end
            
--播放入场动画
function MainView:showAnimation()
end


--大转盘icon
function MainView:TurnTableIconShow()
end

function MainView:refreshOnline()
end

function MainView:lockGameBtn(sender, res, offset)
end

--按钮特效统一管理
function MainView:initAnimate()
end

function MainView:initBtnAnimation(sender, anim, offset, forever)
end


function MainView:initGameBtnAnimation(sender, uniq, offset)
end

function MainView:exit()
    -- self:removeSpriteFrameFromeCache()
end

function MainView:test()
    print("xzvcadsfqwer")
end

function MainView:refreshLuckBtn( ... )

end

return MainView