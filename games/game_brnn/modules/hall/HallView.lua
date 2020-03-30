
local HallView = class("HallView", qf.view)
HallView.TAG = "hallView"


local gametype = BRNN_MATCHE_TYPE
local HallAnimationConfig = require("src.common.HallAnimationConfig")
function HallView:ctor(parameters)
    self.super.ctor(self, parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:initPublicModule()
    if FULLSCREENADAPTIVE then
        self:setPositionX(self.winSize.width/2-1920/2)
        -- self.root:getChildByName("bgimg"):setPositionX(self.root:getChildByName("bgimg"):getPositionX()+(self.winSize.width/2-1920/2))
        -- self.user_infoP:setPositionX(self.user_infoP:getPositionX()-(self.winSize.width/2-1920/2))
        -- self.user_infoP:getChildByName("user_infobg"):setScaleX(1.1)
    end
    self:updateUserInfo()
    self:initAnimate()
    self:initGuangbo()
    self:getInRoom()
    self:initChangciInfoNew()
    self:initGoldAnimate()
    --self:initReview()
end

function HallView:initReview( ... )
    if Util:isHasReviewed() then return end
    self.shopBtn:setVisible(false)
    self.helpBtn:setVisible(false)
end

function HallView:processGameChangeGoldEvt()
    self.goldNumber:setString(Util:getFormatString(Cache.user.gold))
end

function HallView:getInRoom()
    self.getInRoom = function (roomid)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击百人牛牛"..roomid) end
        self.roomid = roomid
        Cache.BrniuniuDesk.roomid = self.roomid
        local paras = {
                roomid=roomid,
                src_deskid = 0,
                dst_desk_id=0,
                password="",
                enter_source=1,
                new_desk=0,
                just_view=0,
                name="",
                must_spend=0,
                last_time=0,
                buyin_limit_multi=0,
                hot_version = GAME_VERSION_CODE,
        }
        -- --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
        -- self.beginTime = os.clock()
        -- Util:delayRun(0.1,function ( ... )
        --                   -- body
        --     GameNet:send({cmd=CMD.INPUT,body=paras,wait=true,timeout=5,callback=function(rsp)
        --         if rsp.ret~=0 then
        --             self:ifNeedReturnMainView()
        --         end
        --         loga("rsp.retrsp.retrsp.retrsp.retrsp.retrsp.ret:"..rsp.ret)
        --         if rsp.ret == 36 then
        --             --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
        --             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        --             return
        --         end
        --         --用户未登陆
        --         if rsp.ret == 14 then
        --             -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        --             qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
        --             return
        --         end
        --         if rsp.ret ~= 0 then    
        --             --qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
        --             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        --             return
        --         end

        --         --ModuleManager:removeExistView()
        --         ModuleManager.BrnnHall:remove()
        --         ModuleManager.gameshall:remove()
        --         ModuleManager.brniuniugame:show({roomid=roomid})
        --     end})
        -- end)
        Util:delayRun(0.2,function ()
            local cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_USER_ENTER_DESK_V2 or BRNN_CMD.CMD_BR_USER_ENTER_DESK_V10
            GameNet:send({cmd = cmd, body=paras,
                timeout = 10,
                wait = true,
                callback=function(rsp)
                    if rsp.ret ~= 0 and rsp.ret then
                        if rsp.ret == NET_WORK_ERROR.TIMEOUT then --重试多1次
                            if self.tryCount == nil then
                                self.tryCount = 1
                            else
                                self.tryCount = self.tryCount + 1
                            end
                            if self.tryCount < 2 then--再发一次进桌
                                qf.event:dispatchEvent(BRNN_ET.NET_BR_BULL_INPUT_REQ,paras)
                                return 
                            end
                        end
                        --用户未登陆
                        if rsp.ret == 14 then
                            -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                            qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                            return
                        end
                        self.tryCount = nil
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret] or string.format(GameTxt.input_roomerror_tips, rsp.ret)})
                        if tolua.isnull(self) == true then
                            return
                        end
                        self:ifNeedReturnMainView()
                        --qf.event:dispatchEvent(ET.BR_EXIT_REQ, {send=true})
                    else
                        ModuleManager.BrnnHall:remove()
                        ModuleManager.gameshall:remove()
                        ModuleManager.brniuniugame:show({roomid=roomid})
                    end
                end
            })
        end)
    end
end

function HallView:initChangciInfoNew()
    local arr = Cache.BrniuniuDesk:getRoomConfig()
    for i = 1, #arr do
        local info = arr[i]
        local panel = self["panel" .. i]
        if info then
            local infoPannel = ccui.Helper:seekWidgetByName(panel,"infoPanel")
            infoPannel:setVisible(false)
            local btn = panel:getChildByName("Img1")
            btn:setTouchEnabled(true)
            addButtonEvent(btn, function ()
                self.getInRoom(info)
                -- qf.platform:umengStatistics({umeng_key = "Enter_room", umeng_value = tostring(info.base_chip)})                    
            end)
        else
            panel:setVisible(false)
        end
    end

end

function HallView:enterGame(paras)
    -- body
    self.getInRoom(paras.roomid)
end

--初始化button事件
function HallView:initGuangbo()
    --广播
    local broadcast_txt_func = cc.CallFunc:create(function ()
        if not self.has_broadcast_txt then
            self.has_broadcast_txt = true
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT) --回到主界面接收世界广播
        end
    end)
    local broadcast_layout_func = cc.CallFunc:create(function ()
        if not self.has_broadcast_layout then
            self.has_broadcast_layout = true
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_LAYOUT)
        end
    end)
    
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(4.0)
        , broadcast_txt_func
        , cc.DelayTime:create(1.0)
    , broadcast_layout_func))
end


function HallView:initPublicModule()
    -- body
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.gameNewHallJSON)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "title",             path = "Panel_top/titleBg/title",          },
        {name = "helpBtn",           path = "Panel_top/help",                   handler = defaultHandler},
        {name = "backBtn",           path = "Panel_top/back",                   handler = defaultHandler},               
        {name = "Panel_gold",        path = "Panel_top/Panel_gold",             handler = defaultHandler},
        {name = "goldNumber",        path = "Panel_top/Panel_gold/number",      handler = defaultHandler},
        {name = "shopBtn",           path = "Panel_top/Panel_gold/addBtn",      handler = defaultHandler},
        {name = "fakeShop",          path = "Panel_top/Panel_gold/fake_shop",   handler = defaultHandler},

        {name = "panel1",           path = "Panel_middle/Panel_1",            handler = nil},
        {name = "buttonQuick",       path = "Panel_Bottom/Button_quick",        handler = defaultHandler},
    }

    
    Util:bindUI(self, self.root, uiTbl)
    self:addChild(self.root)
    self.buttonQuick:setVisible(false)
    self:updateGameTitle()
    
    Util:registerKeyReleased({self = self, cb = function ()
        self:goBcak()
    end})
end

function HallView:updateGameTitle()
    if tolua.type(self.title) == "ccui.ImageView" then
        self.title:loadTexture(self:getTitleRes(), 0)
    elseif tolua.type(self.title) == "ccui.TextBMFont" then
        self.title:setString(self:getTitleName())
    end
end

function HallView:onButtonEvent(sender)
    if sender.name == "buttonQuick" then

    elseif sender.name == "helpBtn" then
        qf.event:dispatchEvent(ET.GAMERULE, {GameType = gametype})        
    elseif sender.name == "backBtn" then
        self:goBcak()
    elseif sender.name == "fakeShop" then
        qf.event:dispatchEvent(ET.SHOP)
    elseif sender.name == "shopBtn" then
        qf.event:dispatchEvent(ET.SHOP)
    end
end

--更新玩家信息
function HallView:updateUserInfo()
    -- 更新信息栏
    self.goldNumber:setString(Util:getFormatString(Cache.user.gold))
end

function HallView:getRoot() 
    return LayerManager.ChoseHallLayer
end

function HallView:ifNeedReturnMainView(roomid)
    if Cache.user.game_list_type == 1 and Cache.user.downGameList[1].name == "11" then
        ModuleManager.BrnnHall:remove()
        ModuleManager.gameshall:initModuleEvent()
        ModuleManager.gameshall:show()
        ModuleManager.gameshall:showReturnHallAni()
    end
end

function HallView:openErji(parameters) 
    
end


function HallView:goBcak()
    self.root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 0)))
    self:runAction(cc.Sequence:create(
        cc.MoveBy:create(0.3, cc.p(733, 0)), 
        cc.CallFunc:create(function (sender)
            qf.event:dispatchEvent(ET.MODULE_HIDE, "BrnnHall")
            ModuleManager.BrnnHall:remove()
            ModuleManager.gameshall:initModuleEvent()
        end)))
    ModuleManager.gameshall:show()
    ModuleManager.gameshall:showReturnHallAni({lastview = "hallview"})
end


function HallView:initAnimate()
    self:initPanel()
end

function HallView:initPanel()
    local diffX = 800
    for i = 1, #Cache.BrniuniuDesk:getRoomConfig() do
        if self["panel" ..  i] == nil then
            local node = self.panel1:clone()
            node:setVisible(true) 
            self.panel1:getParent():addChild(node)
            self["panel" ..  i] = node
            Util:setPosOffset(node, {x = (i-1)*diffX})
        end
        
    end
    for i = 1, #Cache.BrniuniuDesk:getRoomConfig() do
        self:playAnimation(i)
    end
end

function HallView:playAnimation(idx)
    local face = Util:playAnimation({
        node = self["panel" .. idx]:getChildByName("animPanel"),
        anim= HallAnimationConfig["BRNNHALLANI"..idx], 
        position = cc.p(self.winSize.width/2, self.winSize.height/2), 
        forever = true,
    })


    local boneNameTbl = {"1sanbeichang", "2shibeichnag"}
    local renderNode = face:getBone(boneNameTbl[idx]):getDisplayRenderNode()
    -- renderNode:initWithFile(GameRes[xcImgres.. idx])
    local size = renderNode:getContentSize()
    posOffset = {x = -self.winSize.width/2 + size.width/2 , y=-self.winSize.height/2 + size.height/2 -100}
    Util:setPosOffset(face, posOffset)
end

--金币动画
function HallView:initGoldAnimate()
    -- body
    local imageGold = ccui.Helper:seekWidgetByName(self.root, "icon")
    local face = Util:addAnimationToSender(imageGold, {anim = HallAnimationConfig.GOLD, node = imageGold, forever =true})
    local renderNode = face:getBone("2jb"):getDisplayRenderNode()
    renderNode:initWithFile(Cache.packetInfo:getGoldImg())
end

function HallView:getTitleRes()
    return GameRes.brnnTxt
end
function HallView:getTitleName()
    return "百人牛牛"
end

return HallView