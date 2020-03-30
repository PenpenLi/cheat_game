--[[
主大厅model文件
]]
local MainController = class("MainController",qf.controller)

MainController.TAG = "MainController"
local MainView = import(".MainView")

if Util:checkInReviewStatus() then
    MainView = import(".ReviewMainView")
end

MainController.isfirstEnter=true


function MainController:ctor(parameters)
    self.super.ctor(self)
end
function MainController:show(paras)
    self.super.show(self, paras)
     
    self._popup_record = {}

    MusicPlayer:playBackGround() 

    qf.event:dispatchEvent(ET.BG_CLOSE)
    qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin,wait=false,txt=GameTxt.main001,callback= handler(self,self.updateUserInfo)})
    qf.event:dispatchEvent(ET.MODULE_SHOW,"gameshall")
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="activity",number=Cache.Config.FinishActivityNum or 0})

    -- qf.platform:feedBackUnreadRequst()
    
    self.view:updateUserInfo()
    self.view:updateUserHead()
    self:noAddNewPopup(paras)
end 


function MainController:checkShowBindRewardView(paras)
    if paras and type(paras) == "table" and Cache.user.first_recharge_flag == 1 and (paras.lastview == "loginview" or Cache.user.firstLogin ) then
        -- firstLogin 表示用户 首次关掉引导 这个动作
        Cache.user.firstLogin = false
    end
    -- if Cache.user.guide_to_game == 0 and Util:checkInReviewStatus() then
    --     qf.event:dispatchEvent(ET.ADDLISTPOPUP,{id=ET.HONGBAO,priority=2})
    -- end
end

function MainController:checkShowProxcyNewUserWelcomeTips( ... )
    -- 查询代理信息
    if Cache.user.invite_from > 0 and Cache.user.showWelcomeTxtTips == nil then
        Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
            data.welcome_words = "登录测试代理新注册用户消息"
            if Cache.user:isNewRegAndHasProxcy() then
                Cache.user.showWelcomeTxtTips = true
                Cache.cusChatInfo:insertProxcyToUserWelcomeTxtTips(data, true)
            end
        end)
    end
end

function MainController:checkShowGoBindPhoneView(paras)
    --未绑定手机 且 从登陆页面进到大厅页面
    if paras and type(paras) == "table" and paras.lastview == "loginview" and (Cache.user:isBindPhone() == false) and ModuleManager:judegeIsInMain() then
        qf.event:dispatchEvent(ET.ADDLISTPOPUP,{id=ET.CHANGE_PWD,priority=4,bPopList = true, showType = 4})
    end
end

function MainController:checkShowMaintainView()
    if Cache.user.showMaintainFlag == nil and Cache.user.switch == 1 and ModuleManager:judegeIsInMain() then
        qf.event:dispatchEvent(ET.ADDLISTPOPUP,{id=ET.MAIN_TAIN, priority=5, desc = Cache.user.content, begintime = Cache.user.begin_time, endtime = Cache.user.end_time})
        Cache.user.showMaintainFlag = true
    end
end

function MainController:refreshLuckBtn()
    if self and self.view and tolua.isnull(self.view) == false then
        self.view:refreshLuckBtn()
    end
end

function MainController:refreshHongBaoBtn()
    if self and self.view and tolua.isnull(self.view) == false then
        self.view:refreshHongBaoBtn()
    end
end

function MainController:checkIfShowNewMessageNotice( ... )
    qf.event:dispatchEvent(ET.CHECK_IF_NEWMESSAGE)
end

function MainController:refreshCustomeMessageStatus( ... )
    if self.view then
        self.view:refreshCustomerBtn()
    end
end

function MainController:noAddNewPopup(paras)
    self:showHallPopView(paras)
end

function MainController:showHallPopView(paras)
    Util:delayRun(0.5,function ( ... )
        if not self.view or Cache.user.old_roomid > 0 then 
            Cache.user.old_roomid = 0
            return 
        end
        if self.view then
            self.view:setTouch(true)
        end
        self:checkIfShowNewMessageNotice()
        if Cache.user.guide_to_game == 0 then 
            self:checkShowBindRewardView(paras)
    	    self:checkShowGoBindPhoneView(paras)
            self:checkShowMaintainView()
            qf.event:dispatchEvent(ET.POPLISTPOPUP) 
        end
    end)
end

function MainController:initModuleEvent()
    self:addModuleEvent(ET.MAIN_UPDATE_BNT_NUMBER,handler(self,self.updateBntNumber))
    self:addModuleEvent(ET.HALL_UPDATE_INFO,handler(self,self.update))
    self:addModuleEvent(ET.NET_CHANGEGOLD_EVT,handler(self,self.processGameChangeGoldEvt))
    self:addModuleEvent(ET.MAIN_UPDATE_USER_HEAD,handler(self,self.MAIN_UPDATE_USER_HEAD))
    self:addModuleEvent(ET.NET_DIAMOND_CHANGE_HALL,handler(self,self.NET_DIAMOND_CHANGE_HALL))
    self:addModuleEvent(ET.UPDATETURNICON,handler(self,self.updateTURNICON))--重置大转盘
    self:addModuleEvent(ET.UPDATE_MIAN_USER_INFO, handler(self,self.update))
    self:addModuleEvent(ET.SHOWHALLPOPVIEW, handler(self,self.showHallPopView))
    self:addModuleEvent(ET.FRESH_HALL_SHOP_FIRST, handler(self, self.updateShopFirstPay))

    self:addModuleEvent(ET.FINISH_BIND_PHONE, function ( ... ) --绑定手机之后，弹出设置安全密码
        -- body
        qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 2})
    end) 
end

function MainController:removeModuleEvent()
    qf.event:removeEvent(ET.MAIN_UPDATE_BNT_NUMBER)
    qf.event:removeEvent(ET.HALL_UPDATE_INFO)
    qf.event:removeEvent(ET.MAIN_UPDATE_USER_HEAD)
    qf.event:removeEvent(ET.NET_DIAMOND_CHANGE_HALL)
    qf.event:removeEvent(ET.NET_CHANGEGOLD_EVT)
    qf.event:removeEvent(ET.UPDATETURNICON)
    qf.event:removeEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER)
    qf.event:removeEvent(ET.UPDATE_PAY_LIBAO)
    qf.event:removeEvent(ET.CHANGE_PWD)
    qf.event:removeEvent(ET.UPDATE_MIAN_USER_INFO)
    qf.event:removeEvent(ET.FRESH_HALL_SHOP_FIRST)
end

function MainController:showReturnHallAni(paras)
    self.view:showAnimation()
    self:noAddNewPopup(paras)
end

function MainController:updateTURNICON()--重置大转盘
    -- body
    -- self.view:TurnTableIconShow()
end

--钻石更新
function MainController:NET_DIAMOND_CHANGE_HALL( )
    -- body
    self.view:updateUserDiamond()
end


--t头像更新
function MainController:MAIN_UPDATE_USER_HEAD( )
    -- body
    self.view:updateUserHead()
end

--金币更改
function MainController:processGameChangeGoldEvt(rsp)
    -- body
    
    if rsp.model == nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.gold)--rsp.gold  当前版本金币与法币1：1
    elseif rsp.model ~= nil then
        Cache.user.gold = Cache.packetInfo:getProMoney(rsp.model.gold) --rsp.model.gold
    end
    qf.event:dispatchEvent(ET.HALL_UPDATE_INFO )

end

function MainController:update()
    if self.view == nil then
        return
    end
    -- body
    self.view:updateUserInfo()
    self.view:updateUserHead()
end

function MainController:removeModuleEvent()
    PopupManager:removeAllPopup()
end

-- 这里注册与服务器相关的的事件，不销毁
function MainController:initGlobalEvent()
    loga("这里注册与服务器相关的的事件，不销毁")
    qf.event:addEvent(ET.MAIN_BUTTON_CLICK,handler(self,self.bntPressHandler))
    qf.event:addEvent(ET.MAIN_MOUDLE_VIEW_EXIT,handler(self,self.moduleViewExit))
    qf.event:addEvent(ET.REFRESH_FREE_GILD_RED_NUM,handler(self,self.refreshFreeGoldRedNum))
    qf.event:addEvent(ET.AUTO_SHOW_FREE_GOLD,handler(self,self.autoShowFreeGlod))
    qf.event:addEvent(ET.SETTING_QUICK_START_CHOOSE_CHANGE,handler(self,self.quickStartChooseChange))
    qf.event:addEvent(ET.BG_CLOSE,handler(self,function ()
         -- body
         if self.view then
             local bg = self.view:getChildByName("mohubg")            
             if bg then
                bg:removeFromParent()
             end
        end
    end))

    qf.event:addEvent(ET.REFRESH_LUCK_BTN, handler(self, self.refreshLuckBtn))
    -- qf.event:addEvent(ET.REFRESH_HONGBAO_BTN, handler(self, self.refreshHongBaoBtn))
end



function MainController:moduleViewExit(paras) 
    loga("事件点击的分发1moduleViewExit");
    if paras == nil and paras.name == nil then return end
    local m = ModuleManager[paras.name]
    local v = m:getView()
    local winSize = cc.Director:getInstance():getWinSize()
    qf.event:dispatchEvent(ET.BG_CLOSE)
    if paras.from ~= "main" or paras.full == true  then     --满屏窗口收向右边
          v:runAction(cc.Sequence:create(
            cc.FadeTo:create(0.3,0),
            cc.CallFunc:create(function ( sender )
                m:remove()
            end)))
        return 
    end
    if self.view == nil then return end
    local p = cc.p(self.view.bnt[paras.name]:getPosition())
    self:moduleExitAnimation(v,p,m)
end

function MainController:bntPressHandler(paras)
    if paras == nil and paras.name == nil then return end
    loga("事件点击的分发1bntPressHandler");
    local popTable = {
        beauty= "full",
        setting= "window",
        rank= "window",
        friend= "window",
        activity= "window",
        prize= "window",
        shop= "full",
        laba="window",
        -- safeBox = "window",
        -- personal = "window",
        -- exchange = "window",
        bindCard = "window",
        -- inviteCode = "window",
        -- custom = "window"
    }

    if paras.name == "shop" then
        qf.event:dispatchEvent(ET.SHOP)
        return
    end

    if popTable[paras.name] ~= nil then 
        self:commonEventEx({name=paras.name,type=popTable[paras.name],delay = paras.delay,cb = paras.cb, overCb = paras.overCb, bookmark=paras.bookmark, showType = paras.showType})
        return
    end

    if self[paras.name.."Event"] ~= nil then
        -- 进入各个游戏方法 
        self[paras.name.."Event"](self,paras)
    end
end

function MainController:commonEventEx(paras)
    if paras.name == "bindCard" then
        qf.event:dispatchEvent(ET.BIND_CARD, paras)
        return
    end
    self:commonEvent(paras)
end

function MainController:commonEvent(paras)
    local winSize = cc.Director:getInstance():getWinSize()
    if ModuleManager[paras.name] == nil then
        return 
    end
    local view = ModuleManager[paras.name]:getView({name="main",cb = paras.cb, bookmark=paras.bookmark})
    view:setVisible(true)

    if paras.cb then --打开新弹窗后的回调
        paras.cb()
        view:setPreViewCallback(paras.cb)
    end
    if paras.showType then --部分弹窗可能有多种形态
        view:showWithType(paras.showType)
    end
    if paras.overCb then
        view:setOverCallback(paras.overCb)
    end
    if paras.type == "full" or paras.from == "main" then    --满屏窗口"beauty"从右侧出现
        view:setCascadeOpacityEnabled(true)
        view:setOpacity(0)
        if paras.noanimation ~= true then qf.event:dispatchEvent(ET.MAIN_VIEW_DISMISS_ANIMATION) end
        view:runAction(cc.Sequence:create(
                cc.DelayTime:create(paras.delay or 0),
                cc.CallFunc:create(function ( sender )
                sender:enterCoustomFinish()
                end),
                --cc.MoveBy:create(0.3,cc.p(-winSize.width,0)),
                cc.FadeTo:create(0.5,255)
         ))
        return
    elseif self.view and self.view.bnt ~= nil and self.view.bnt[paras.name] ~= nil then
        local px,py = self.view.bnt[paras.name]:getPosition()
        self:moduleEnterAnimation(view, px, py, paras.name)
    end
end

function MainController:remove()
    self.super.remove(self)
    if self.action then
        Scheduler:unschedule(self.action)
        self.action=nil
    end
    qf.event:dispatchEvent(ET.MODULE_HIDE,"gameshall")
end

function MainController:initView(parameters)
    if self.view and not tolua.isnull(self.view) then
        return self.view
    else
        local view = MainView.new(parameters)
        return view
    end
end


--view: 要弹出的窗口. px py, 起始位置. name, 模块名
function MainController:moduleEnterAnimation ( view, px, py, name )--点击图标弹出窗口动画
    if self._popup_record[name] then  --如果窗口还没弹出完毕，禁止再次打开
        return 
    end
    self._popup_record[name] = true

    local bg =  cc.Sprite:create(GameRes.mohubg)
    bg:setPosition(Display.cx/2,Display.cy/2)
    local winSize = cc.Director:getInstance():getWinSize()
    if FULLSCREENADAPTIVE then
        bg:setPosition(-((winSize.width/2-1920/2)/2)+(winSize.width)/2,Display.cy/2)
    end

    bg:setName("mohubg")
    self.view:addChild(bg)

    view:setAnchorPoint(cc.p(0.5,0.5))
    view:ignoreAnchorPointForPosition(false)
    view:setScale(0)
    view:setPosition(winSize.width/2, winSize.height/2)--(px,py)
    view:setCascadeOpacityEnabled(true)
    view:setOpacity(0)

    local atime = 0.2
    --先由快到慢（同时进行动作：移到中心，完全放大，在time内渐变出现），再由快到慢（放大），由慢到快（缩小到正常大小）
    view:runAction(cc.Sequence:create(
        cc.EaseSineOut:create (cc.Spawn:create(
            cc.MoveTo:create(atime,cc.p(winSize.width/2,winSize.height/2)),
            cc.ScaleTo:create(atime,1),
            cc.FadeIn:create(atime)
            )),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.05,1.05)),
        cc.EaseSineIn:create(cc.ScaleTo:create(0.05,1)),
        cc.CallFunc:create(function ( sender )
            self._popup_record[name] = false    --弹出动画播放完毕
            view:enterCoustomFinish()
        end)
        ))
end


function MainController:moduleExitAnimation(view,pos,module)--窗口回到图标位置

    local atime = 0.2
    view:runAction(cc.Sequence:create(
        cc.EaseSineOut:create ( cc.Spawn:create(--cc.MoveTo:create(atime,pos),
            cc.ScaleTo:create(atime,0),cc.FadeTo:create(atime,50))
            ),
        cc.CallFunc:create(function ( sender )
            module:remove()
        end)
        ))
end


function MainController:brhallEvent()--百人场
    logd( " --- start Button process brhallEvent --- ")
    qf.event:dispatchEvent(ET.NET_BR_INPUT_REQ,{roomid = 0})
    Util:delayRun(0.02,function()
        ModuleManager:removeExistView()
        ModuleManager.texasbrgame:show({name="main"})
    end)
    qf.platform:umengStatistics({umeng_key = "AutoStart"})
end

function MainController:brnnhallEvent() --百人牛牛
    logd( " --- start Button process brnnhallEvent --- ")
    local winSize = cc.Director:getInstance():getWinSize()
    ModuleManager.BrnnHall:getView():setPosition(773,0)
    ModuleManager.BrnnHall:getView():stopAllActions()
    if FULLSCREENADAPTIVE then
        ModuleManager.BrnnHall:getView():runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.2,cc.p(winSize.width/2-1920/2,0))
        ))
    else
        ModuleManager.BrnnHall:getView():runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.2,cc.p(0,0))
        ))
    end
end


-- 进入德州大厅 游戏大厅由右侧出现
function MainController:hallEvent(parameters)
    local winSize = cc.Director:getInstance():getWinSize()
    qf.platform:umengStatistics({umeng_key = "RoomStart"})
    ModuleManager.texashall:getView():setPosition(winSize.width,0)
    ModuleManager.texashall:getView():runAction(
        cc.Sequence:create(
            cc.MoveBy:create(0.3,cc.p(-winSize.width,0)),
            cc.CallFunc:create(function ( sender )
               sender:enterCoustomFinish()
           end))
    )
end

--进入扎金花大厅 游戏大厅由右侧出现
function MainController:zjhhallEvent(parameters)
    local winSize = cc.Director:getInstance():getWinSize()
    ModuleManager.zjhhall:getView():setPosition(773,0)
    ModuleManager.zjhhall:getView():stopAllActions()
    local posT = cc.p(0,0)
    if FULLSCREENADAPTIVE then
        posT = cc.p(winSize.width/2-1920/2,0)
    end
    ModuleManager.zjhhall:getView():runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, posT),
            cc.CallFunc:create(function ( ... )
                if self.view and tolua.isnull(self.view) == false then
                    self:hide()
                end
            end)
    ))
end

--进入龙虎斗 游戏大厅由右侧出现
function MainController:lhdhallEvent(parameters)
    qf.event:dispatchEvent(LHD_ET.NET_LHD_INPUT_REQ,{roomid = 0})
    Util:delayRun(0.02,function()
        ModuleManager:removeExistView()
        ModuleManager.lhdgame:show({name="main"})
    end)
    qf.platform:umengStatistics({umeng_key = "AutoStart"})
end

--进入炸金牛 游戏大厅由右侧出现
function MainController:zhajinniuhallEvent(parameters)
    local winSize = cc.Director:getInstance():getWinSize()
    ModuleManager.zhajinniuhall:getView():setPosition(773,0)
    ModuleManager.zhajinniuhall:getView():stopAllActions()
    local posT = cc.p(0,0)
    if FULLSCREENADAPTIVE then
        posT = cc.p(winSize.width/2-1920/2,0)
    end
    ModuleManager.zhajinniuhall:getView():runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, posT),
            cc.CallFunc:create(function ( ... )
                if self.view and tolua.isnull(self.view) == false then
                    self:hide()
                end
            end)
    ))
end

--进入抢庄牛牛 游戏大厅由右侧出现
function MainController:niuniuhallEvent(parameters)
    local winSize = cc.Director:getInstance():getWinSize()
    ModuleManager.niuniuhall:getView():setPosition(773,0)
    ModuleManager.niuniuhall:getView():stopAllActions()

    local posT = cc.p(0,0)
    if FULLSCREENADAPTIVE then
        posT = cc.p(winSize.width/2-1920/2,0)
    end
    ModuleManager.niuniuhall:getView():runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, posT),
            cc.CallFunc:create(function ( ... )
                if self.view and tolua.isnull(self.view) == false then
                    self:hide()
                end
            end)
    ))
end

--进入斗地主大厅 游戏大厅由右侧出现
function MainController:DDZhallEvent(parameters)
    local winSize = cc.Director:getInstance():getWinSize()
    ModuleManager.DDZhall:getView():setPosition(773,0)
    ModuleManager.DDZhall:getView():stopAllActions()
    local posT = cc.p(0,0)
    if FULLSCREENADAPTIVE then
        posT = cc.p(winSize.width/2-1920/2,0)
    end
    ModuleManager.DDZhall:getView():runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, posT),
            cc.CallFunc:create(function ( ... )
                if self.view and tolua.isnull(self.view) == false then
                    self:hide()
                end
            end)
    ))
end

--进入百家乐 游戏大厅由右侧出现
function MainController:bjlhallEvent(parameters)
    logd( " --- start Button process --- ")
    qf.event:dispatchEvent(ET.NET_BJL_INPUT_REQ,{roomid = 0})

    Util:delayRun(0.02,function()
        ModuleManager:removeExistView()
        ModuleManager.baccaratGame:show({name="main"})
    end)

    qf.platform:umengStatistics({umeng_key = "AutoStart"})
end

function MainController:updateShopFirstPay( ... )
    if self.view then
        self.view:updateShopTips()
    end
end

function MainController:getUniqTable( ... )
    local uniqTbl = {
        game_texas     =  {upErrorStr = " 点击大厅进入德州扑克", mainStr = "hall"      , gameName = "德州扑克"    },
        game_lhd       =  {upErrorStr = " 点击大厅进入龙虎斗",   mainStr = "lhdhall"   , gameName = "龙虎斗"      },
        game_niuniu    =  {upErrorStr = " 点击大厅进入看牌抢庄", mainStr = "niuniuhall", gameName = "抢庄牛牛"        },
        game_zhajinniu =  {upErrorStr = " 点击大厅进入扎金牛",   mainStr = "zhajinniuhall", gameName = "炸金牛"   },
        game_br        =  {upErrorStr = " 点击大厅进入百人场",   mainStr = "brhall"    , gameName = "百人炸金花"   },
        game_zjh       =  {upErrorStr = " 点击大厅进入炸金花",   mainStr = "zjhhall"   , gameName = "经典炸金花"   },
        game_ddz       =  {upErrorStr = " 点击大厅进入斗地主",   mainStr = "DDZhall"   , gameName = "斗地主"       },
        game_brnn      =  {upErrorStr = " 点击大厅进入百人牛牛", mainStr = "brnnhall"  , gameName = "百人牛牛"     },
        game_bjl  =  {upErrorStr = " 点击大厅进入百家乐",   mainStr = "bjlhall"   , gameName = "百家乐"       }
    }
    return uniqTbl
end

function MainController:quickStartChooseChange()
    if self.view then
        self.view:QuickStartAni()
    end 
end

function MainController:updateBntNumber(paras)
    if paras == nil or paras.name == nil  or self.view == nil then return end
    if paras.name == "activity" then
        self.view:setRedHint("activeBtn", checknumber(paras.number) > 0)
    end

    if paras.name == "mailInfo" then
        self.view:setRedHint("mailBtn", Cache.mailInfo:checkNewMail())
    end

    if paras.name == "customInfo" then
        Cache.customInfo:checkNewCustom()
        self.view:setRedHint("customerBtn", Cache.customInfo:checkNewCustom())
    end
end

--修改密码
function MainController:changePwd( info )
    -- body
    if not info then
        return
    end
    local view = ModuleManager["changePwd"]:getView()
    view:setVisible(true)
end

return MainController