local GlobalView = class("GlobalView", qf.view)

local DiamondPopup = import(".components.DiamondPopup")
local GlobalPromit = import(".components.GlobalPromit")
local loginWait = import(".components.LoginWaitPanel")
local InstallGame = import(".components.InstallPopup")
GlobalView.TAG = "GlobalView"

GlobalView.waittingTAG = 500
GlobalView.loginWaittingTAG = 550
GlobalView.fullWaittingTAG = 600
GlobalView.fullWaittingZ = 10
GlobalView.dayRewardOrder = 2
GlobalView.weekMonthOrder = 3
GlobalView.BROAD_DELAY_TIME = 0
GlobalView.bigPhotoTag = 1111
function GlobalView:ctor(parameters)
    self.super.ctor(self,parameters)
    self.showBeauty = (os.time() - os.time({year = 2015,month = 7,day = 4 ,hour = 22,sec = 1}) > 0)
    self.toastTxtT = {}
    self.toastLabelT = {}

    self.freegold_redNum = 0
    self.red_state = {}
    self:init()
end

function GlobalView:initTouchEvent()
    
end

--弹出安装游戏
function GlobalView:showInstallGame(paras)
    -- body
    local InstallGame = InstallGame.new({name=paras.name,size=paras.size,confirmHandle = paras.confirmHandle,target=paras.target,uniq=paras.uniq,unit=paras.unit})
    
    InstallGame:show()
end


--隐藏安装游戏
function GlobalView:hideInstallGame()
    -- body
    local InstallGame = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.installgame)  
    
    if InstallGame ~= nil then
        InstallGame:closeView()
    end 
end

--弹出每日登陆奖励
function GlobalView:showDailyLogin(paras)
    -- body
    local dailylogin = Dailylogin.new(paras)
    dailylogin:show()
    if paras.pop  then
        Cache.user.popflag = true
    end
end


--隐藏每日登陆奖励
function GlobalView:hideDailyLogin()
    -- body
    local dailylogin = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.dailylogin)  
    
    if dailylogin ~= nil then
        dailylogin:closeView()
    end 
end

--弹出每日登陆奖励
function GlobalView:showFirstpay(paras)
    -- body
    local Firstpay = Firstpay.new()
    Firstpay:show()
    if paras.pop  then
        Cache.user.popflag = true
    end
end


--隐藏每日登陆奖励
function GlobalView:hideFirstpay()
    -- body
    local firstpay = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.firstpay)  
    
    if firstpay ~= nil then
        firstpay:closeView()
    end 
end

--弹出每日登陆奖励
function GlobalView:showChaoZhipay(paras)
    -- body
    local Firstpay = ChaoZhipay.new()
    Firstpay:show()
    if paras.pop  then
        Cache.user.popflag = true
    end
end


--隐藏每日登陆奖励
function GlobalView:hideChaoZhipay()
    -- body
    local firstpay = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.chaozhipay)  
    
    if firstpay ~= nil then
        firstpay:closeView()
    end 
end


--更新每日登陆奖励的信息
function GlobalView:dailyLoginData(model)
    local dailylogin = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.dailylogin)  
    
    if dailylogin ~= nil then
        dailylogin:initRewardData(model)
    end 

end

function GlobalView:init()
    self.winSize = cc.Director:getInstance():getWinSize()
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.Gold_plist)
    self._boradcastBg = nil
    self._loginWaitPanle = nil
    self:initTimeBox()

    -- if ENVIROMENT_TYPE == 2 then
    --     self:removeChildByName("testButton")
    --     self.testButton = ccui.Button:create(GameRes.agency_wx_img, GameRes.agency_wx_img)
    --     self.testButton:setAnchorPoint(cc.p(0.5,0.5))
    --     self.testButton:setPosition(cc.p(10, Display.cy-10))
    --     self.testButton:setOpacity(0)
    --     self:addChild(self.testButton)
    --     self.testButton:setName("testButton")
    --     addButtonEvent(self.testButton, function ()
    --         qf.event:dispatchEvent(ET.DEBUG_VIEW)
    --     end)
    -- end
end

------------新时间宝箱 start-----------
function GlobalView:initTimeBox()
    logd("时间宝箱计时器初始化.", "TimeBox")
    self.timebox_index = -1        --时间宝箱index
    self.timebox_reward = false    --时间宝箱奖励是否已经领取
    self.timebox_tick = 0        --时间宝箱倒计时

    --倒计时action node
    if self._timebox_node == nil then	
        self._timebox_node = cc.Node:create()
        self:addChild(self._timebox_node)
    end
end

function GlobalView:setTimeBox(paras)
    --开始计时, 时间到则做出通知
    if paras.opcode == TimeBoxOpcode.TIMER_START then
    	logd("时间宝箱操作 -- 开始计时.", "TimeBox")
    	self.timebox_index = paras.index	
    	self.timebox_tick = paras.countdown	
    	self._timebox_node:stopAllActions()
    	if self.timebox_tick == 0 then return end	--不能继续倒计时
    	    self._timebox_node:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
    	        cc.DelayTime:create(1),
    	        cc.CallFunc:create(function()
    	            if self.timebox_tick > 0 then self.timebox_tick = self.timebox_tick - 1 end
    	            logd("时间宝箱Timer倒计时: reward="..tostring(self.timebox_reward)..", second="..self.timebox_tick, "TimeBox")
                    qf.event:dispatchEvent(ET.CHEST_BOX_TIME_CHANGE,{reward=self.timebox_reward,second=self.timebox_tick})
    	            if self.timebox_tick == 0 then self._timebox_node:stopAllActions() end
                end))
            ))
    --暂停计时
    elseif paras.opcode == TimeBoxOpcode.TIMER_PAUSE then
    	self._timebox_node:stopAllActions()
    	logd("时间宝箱操作 -- 暂停计时.", "TimeBox")
    elseif paras.opcode == TimeBoxOpcode.TIMER_RESET then
    	self.timebox_index = paras.index	
    	self.timebox_tick = paras.countdown 
    	self.timebox_reward = false
    	logd("时间宝箱操作 -- 重置.", "TimeBox")
	--任务完成
    elseif paras.opcode == TimeBoxOpcode.TASK_DONE then
    	self.timebox_reward = true
    	logd("时间宝箱操作 -- 任务完成, 奖励已领取.", "TimeBox")
    end
end

--获取时间宝箱计时器状态
function GlobalView:getTimeBox()
    local running = self._timebox_node:getNumberOfRunningActions() > 0
    logd("时间宝箱操作 -- 获取计时器状态. running="..tostring(running)..",index="..self.timebox_index..",reward="..tostring(self.timebox_reward)..", second="..self.timebox_tick.."s", "TimeBox")
    return running, self.timebox_index, self.timebox_reward, self.timebox_tick
end

------------新时间宝箱 end-----------

------------登录等待界面--------------
function GlobalView:showLoginWait(txt)
    if self._loginWaitPanle == nil then
        self._loginWaitPanle = loginWait.new()
        self._loginWaitPanle:retain()
        self._loginWaitPanle:setPosition(self.winSize.width/2,self.winSize.height/2)
    end
    if(self._loginWaitPanle:getParent() == nil) then
        self:addChild(self._loginWaitPanle,self.fullWaittingZ,self.fullWaittingTAG+10086)
    end
    self:removeChildByTag(self.fullWaittingTAG + 1)
    self._loginWaitPanle:setTxt(txt)
    self._loginWaitPanle:play()
end
function GlobalView:hideLoginWait()
    if self._loginWaitPanle == nil then return end
    self:removeChildByTag(self.fullWaittingTAG+10086)
end

------------登录等待界面 end --------------

--显示MTTLoadding界面
function GlobalView:showMTTLoadding( args )
    local loadding_root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.mttLoaddingJson)
    self:addChild(loadding_root, self.fullWaittingZ, self.fullWaittingTAG)
    local pan_loadding = loadding_root:getChildByName("pan_loadding")

    local spr = cc.Sprite:create(GameRes["login_1"])
    pan_loadding:addChild(spr)
    local ani = cc.Animation:create()
    for i=1,4 do
        ani:addSpriteFrameWithFile(GameRes["login_"..i])
    end
    ani:setDelayPerUnit(0.7)
    local seq = cc.RepeatForever:create(cc.Animate:create(ani))
    spr:runAction(seq)

    local lbl_loadding = pan_loadding:getChildByName("lbl_loadding")
    local px, py = lbl_loadding:getPosition()
    spr:setPosition(cc.p(px + spr:getContentSize().width*0.5, py))

    local img_lbl = ccui.Helper:seekWidgetByName(loadding_root, "img_lbl_tip")
    if args and args.tip_type and args.tip_type == 0 then --决赛阶段
        img_lbl:loadTexture(GameRes.mtt_merge_desk_tip_2)
    else
        img_lbl:loadTexture(GameRes.mtt_merge_desk_tip_1)
    end
end
function GlobalView:showFullWait( args )
    local txt = args.txt
    local isShowLoginBtn = args.isShowLoginBtn
    local cancellation = args.cancellation
    local kind = args.kind

    if kind == self.kind_of_full_wait then return end

    self:hideFullWait()
    self.kind_of_full_wait = kind

    if kind and kind == 2 then --并桌
        self:showMTTLoadding(args)
        return 
    end

    -- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()    --全屏的等待窗口往往在切换场景时调用, 在这里清一下内存TextureCache
    local bg = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.loginloginLayout1Json)
    ccui.Helper:seekWidgetByName(bg,"beauty"):setVisible(true)
    self:initChipsAnimation(ccui.Helper:seekWidgetByName(bg,"beauty"))



    --香港/新加坡/菲律宾不显示健康游戏提示
    --ccui.Helper:seekWidgetByName(bg,"Image_6"):setVisible(GAME_LANG ~= "zh_tr")
    
    bg:setPosition(self.winSize.width/2,self.winSize.height/2)
    self:addChild(bg,self.fullWaittingZ,self.fullWaittingTAG)

    -- 叠加背景
    self.bgImg= ccui.Helper:seekWidgetByName(bg,"bgimg")
    -- 美女
    self.Beauty= ccui.Helper:seekWidgetByName(bg,"beauty")
    -- 美女层
    self.pan_all= ccui.Helper:seekWidgetByName(bg,"Panel_4")

    -- self:initAnimate()

    local statusTxt = cc.LabelTTF:create( txt or GameTxt.net002, GameRes.font1, 36)
    statusTxt:setColor(cc.c3b(230,223,130))
    statusTxt:setPosition(self.winSize.width*0.75,self.winSize.height*0.13)
    self:addChild(statusTxt,self.fullWaittingZ+1,self.fullWaittingTAG+1)
    
    Display:closeTouch(bg)
end

function GlobalView:initAnimate()
    -- body

    local aniconfig = require("src.common.HallAnimationConfig")
    self.bueatyAnimate = Util:playAnimation({
        anim = aniconfig.BEAUTY,
        anchor = cc.p(0.5,0.1),
        scale = 1.25,
        position = cc.p(Display.cx/2,0),
        order = 2,
        node = self.pan_all,
        posOffset = {x= -400},
        forever = true
    })
    
    self.Beauty:setVisible(false)
end

function GlobalView:initChipsAnimation(bg)
    Util:showBeautyAction(bg,6)
    --Util:chipsAnimation({parent = bg,x = bg:getContentSize().width*0.59,y = bg:getContentSize().height*0.25+5})
end

function GlobalView:hideFullWait()
    self.kind_of_full_wait = -1
    if self.guangSchedule then
        Scheduler:unschedule(self.guangSchedule)
        self.guangSchedule=nil
    end
    self:removeChildByTag(self.fullWaittingTAG)
    self:removeChildByTag(self.fullWaittingTAG+1)
    self:removeChildByTag(self.fullWaittingTAG+2)
    self:removeChildByTag(self.fullWaittingTAG+3)
    self:removeChildByTag(self.fullWaittingTAG+4)    
    self:removeChildByTag(self.fullWaittingTAG+5)
end
function GlobalView:updateFullWait(txt)
    local t = self:getChildByTag(self.fullWaittingTAG+1)
    if t ~= nil then t:setString(txt or GameTxt.net002 ) t:setVisible(true) end
    self:removeChildByTag(self.fullWaittingTAG+2)
    self:removeChildByTag(self.fullWaittingTAG+3)
    self:removeChildByTag(self.fullWaittingTAG+4)     
    if self:getChildByTag(self.fullWaittingTAG+5) ~= nil then self:getChildByTag(self.fullWaittingTAG+5):setVisible(true) end
    
    if self:getChildByTag(self.fullWaittingTAG) ~= nil and self:getChildByTag(self.fullWaittingTAG):getChildByTag(10) ~= nil then
        self:getChildByTag(self.fullWaittingTAG):getChildByTag(10):setVisible(true)
    end
end

function GlobalView:showCoinAnimation (paras)
    if self.showingAnimation == true then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.coinAnimationFuncID)
        self.cNode:removeFromParent(true)
        self.cNode = nil
        self.showingAnimation = false
    end

    local nCount = paras~=nil and paras.number~=nil and paras.number<1000 and paras.number or 1000
    self.createCoin = 0
    self.totalCoin = math.round(nCount/15)
    self.coins = {}
    self.cNode = cc.Node:create()
    self.gravity = 3.5
    self:addChild(self.cNode,self.dayRewardOrder+2)
    self.showingAnimation = true
    self.coinAnimationFuncID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.showCoinAnimationUpdate),0,false)
end

function GlobalView:showChargeCoinAnimation (paras)
    if paras.txt and paras.txt ~= "" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = paras.txt})
    end
    local rate_v = (Display.cy+300) / 100
    local time_v = 1
    for i=1,25 do
        for j=1,15 do
            local rate   = math.random(50,100)  --随机初始速度
            if i >=18 then
                rate = math.random(30,70)
            end

            
            local rotate = math.random(0,17)    --随机初始角度
            local length = math.cos(math.rad(rotate)) * rate * rate_v
            local time   = math.cos(math.rad(rotate)) * rate/100

            local line_length = math.sin(math.rad(rotate)) * rate *rate_v



            local index  = math.random(1,16)
            local sprite = cc.Sprite:createWithSpriteFrameName(string.format("%d.png",index))
            sprite.index = index
            sprite.id = Scheduler:scheduler(0.01,function ()
                -- body
                if self.closeDailyLogin==nil or self.closeDailyLogin==true and sprite.id then
                    Scheduler:unschedule(sprite.id)
                    sprite.id=nil
                    return
                end
                if sprite.index>16 then
                    sprite.index = 1
                end

                sprite:setSpriteFrame(string.format("%d.png",sprite.index))
                sprite.index = sprite.index +1
                return true
            end)
            
            local ro = math.random(0,10)

            sprite:setRotation(ro*36)
            self:addChild(sprite)
            sprite:setScale(0.5)
            local y = math.random(-100,0)
            sprite:setPosition(Display.cx/2,y)
            sprite:setVisible(false)
            local random =math.random(-200,200)
            
            local tmp_line 
            local it    = math.random(0,1)
            if it ==0 then
                tmp_line = line_length 
            else
                tmp_line = -line_length
            end
            
            local ox = Display.cx/2+tmp_line
            local delay = cc.DelayTime:create((i-1)*0.035)
            local move = cc.MoveTo:create(time,cc.p(ox,length))
            local easeout = cc.EaseSineOut:create(move)
            local call = cc.CallFunc:create(function ()
                -- body
                sprite:setVisible(true)
            end)
            local call1= cc.CallFunc:create(function ()
                -- body
                if sprite.id then
                    Scheduler:unschedule(sprite.id)
                    sprite.id=nil
                end
                sprite:removeFromParent()
            end)

            local tmp_line_t 
            if it ==0 then
                tmp_line_t = ox +line_length 
            else
                tmp_line_t = ox-line_length
            end
        
            local move2 = cc.MoveTo:create(time,cc.p(tmp_line_t,0))
            local easein = cc.EaseSineIn:create(move2)  
            local sq = cc.Sequence:create(delay,call,easeout,easein,call1)
            sprite:runAction(sq)
        end
    end
end

function GlobalView:showDiamondAnimation(paras)
    local popup = DiamondPopup.new(paras)
    self:addChild(popup)
    popup:show()
end

function GlobalView:showCoinAnimationUpdate(dt)
    if self.createCoin < self.totalCoin then
        local c = Coin.new()
        c:setPosition(math.random(0,self.winSize.width),math.random(self.winSize.height,self.winSize.height*1.35))
        self.cNode:addChild(c)
        table.insert(self.coins,c)
        c.rot = math.random(-5,5) c.sx = math.random(-10,10) c.sy =math.random(-5,5) c.bounce = 0
        --c.index = self.createCoin
        self.createCoin = self.createCoin + 1
    else

        if #self.coins == 0 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.coinAnimationFuncID)
            self.cNode:removeFromParent(true)
            self.cNode = nil
            self.showingAnimation = false
        end
    end

    for k,v in pairs(self.coins) do
        v:updateStatus(v.sx,v.sy,v.rot)
        v.sy = v.sy + self.gravity
        if v:getPositionY() < 0 and v.bounce < 4 then
            v:setPositionY(0)
            v.sy =  v.sy * (math.abs(v.sx) > 6.5 and math.random(-0.55,-0.45) or -0.35)
            v.bounce = v.bounce + 1
            if v.bounce > 3 then v.markDelte = true end
        end
    end

    for k,v in pairs(self.coins) do
        if v:getPositionX() < -20 or v:getPositionX() > self.winSize.width*1.05 then v.markDelte = true end
        if v:getPositionY() < -20 then v.markDelte = true end
    end

    for i = #self.coins , 1, -1 do
        if self.coins[i].markDelte == true then
            self.coins[i]:removeFromParent(true)
            table.remove(self.coins,i)
        end
    end

end

function GlobalView:changeBoradcastDelayTime(paras)
    self.BROAD_DELAY_TIME = paras
    if self._boradcastBg then
        if self.BROAD_DELAY_TIME == 0 then
            self._boradcastBg:setVisible(true)
            self._boradcastBg:resume()
            local txt = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
            local child = txt:getChildByTag(151)
            if child then child:resume() end
        else
            self._boradcastBg:setVisible(false)
            self._boradcastBg:pause()
            local txt = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
            local child = txt:getChildByTag(151)
            if child then child:pause() end
        end
    end
end

function GlobalView:removeBroadCast( ... )
    if self._boradcastBg and tolua.isnull(self._boradcastBg) == false then
        self._boradcastBg:removeFromParent(true)
        self._boradcastBg = nil
    end
end

function GlobalView:showWordMsg()
    if self.wordMsgNode ~= nil then
       self.wordMsgNode:removeFromParent(true)
       self.wordMsgNode = nil
    end
    local bg = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.WordMsgJson)
    bg:setPositionY(self.winSize.hight)
    self:addChild(bg)
    
    bg:runAction(cc.Sequence:create(
        cc.EaseSineOut:create(cc.MoveBy:create(1,cc.p(0,-self.winSize.hight))),
        cc.CallFunc:create(function ( sender )
            --self:showBoradcastTxt(txt)
        end)
    ))
    self.wordMsgNode = bg
end

function GlobalView:getBroadCastBgBaseLayer()
    return LayerManager.BroadCastLayer
end

function GlobalView:boradcastInit()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    if self._boradcastBg == nil then
        self._boradcastBg  = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.broadcastJson)
        self._boradcastBg_px = self._boradcastBg:getPositionX()
        self._boradcastBg_py = self._boradcastBg:getPositionY()
        self._boradcastBg:setPosition(GameConstants.BROADCAST_POS)

        local baselayer = self:getBroadCastBgBaseLayer()
        baselayer:addChild(self._boradcastBg)
        self.move_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"move_root")
        
        self.msgBgPosY = ccui.Helper:seekWidgetByName(self._boradcastBg,"img_bg"):getPositionY()
        self.isRuning = false
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT)
        
        self.boradcastTable={}
    end
end
function GlobalView:showBoradcast()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    self:boradcastInit()
    self._boradcastBg:setVisible(true)
end

function GlobalView:hideBoradcast()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    self:boradcastInit()
    self.isRuning=false
    self._boradcastBg:setVisible(false)
end

function GlobalView:removeBoradcastChild( ... )
    -- body
    if self.move_root then
        self.move_root:removeAllChildren()
    end
    self.boradcastTable={}
end

--新版本系统广播
function GlobalView:showBoradcastTxtWithSystem(info)
    -- body
    self:removeBoradcastChild()
    local txt_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
    local cs = txt_root:getContentSize()
    local head=ccui.ImageView:create(GameRes.BroadcastSystemImg)
    head:setAnchorPoint(0,0.5)
    head:setPosition(0,cs.height*0.45)
    table.insert(self.boradcastTable,head)
    self.move_root:addChild(head)
    local nowX=head:getContentSize().width+10
    for i=1,2 do
        local laba
        if info.level~=0 then
            laba=ccui.ImageView:create(GameRes.BroadcastLabaImg)
        else
            laba=ccui.ImageView:create(GameRes.BroadcastHuaImg)
        end
        laba:setAnchorPoint(0,0.5)
        laba:setPosition(nowX,cs.height*0.5)
        table.insert(self.boradcastTable,laba)
        self.move_root:addChild(laba)
        nowX=nowX+laba:getContentSize().width+10
    end
    local content=info.new_content
    local strcontent=1
    if content==nil or content=="" or info.contents==nil then 
        local txt=ccui.Text:create(info.content,GameRes.font1,34)
        txt:setAnchorPoint(0,0.5)
        txt:setPosition(nowX,cs.height*0.5)
        table.insert(self.boradcastTable,txt)
        self.move_root:addChild(txt)
        nowX=nowX+txt:getContentSize().width
    else
        while(string.len(content)>=1 )do
            if string.find(content,"%#")==1 then
                local txt=ccui.Text:create(info.contents["str"..strcontent],GameRes.font1,34)
                txt:setAnchorPoint(0,0.5)
                txt:setColor(cc.c3b(217,172,58))
                txt:setPosition(nowX,cs.height*0.5)
                table.insert(self.boradcastTable,txt)
                self.move_root:addChild(txt)
                nowX=nowX+txt:getContentSize().width
                strcontent=strcontent+1
                if #content>1 then
                    content=string.sub(content,2,#content)
                else
                    break
                end
            else
                local txtcontent
                if string.find(content,"%#")  then 
                    txtcontent=string.sub(content,1,string.find(content,"%#")-1)
                    content=string.sub(content,string.find(content,"%#"),#content)
                else
                    txtcontent=content
                    content=""
                end
                local txt=ccui.Text:create(txtcontent,GameRes.font1,34)
                txt:setAnchorPoint(0,0.5)
                txt:setPosition(nowX,cs.height*0.5)
                table.insert(self.boradcastTable,txt)
                self.move_root:addChild(txt)
                nowX=nowX+txt:getContentSize().width
            end
            
        end
    end
    local distence = cs.width + nowX
    local time = distence/200
    self.move_root:stopAllActions()
    self.move_root:setPositionX(cs.width)
    self.isRuning = true
    self.move_root:runAction(
        cc.Sequence:create(
            cc.Show:create(),
            cc.MoveBy:create(time,cc.p(-distence,0)),
            cc.Hide:create(),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function ( sender )
                self._boradcastBg:setVisible(false)
                self.isRuning = false
                qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT)
            end)
        )
    )

end

--新版本个人广播
function GlobalView:showBoradcastTxtWithPersonal(info)
    -- body
    loga("个人广播")
    self:removeBoradcastChild()
    local txt_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
    local cs = txt_root:getContentSize()
    local laba=ccui.ImageView:create(GameRes.BroadcastGuangBoImg)
    laba:setAnchorPoint(0,0.5)
    laba:setPosition(0,cs.height*0.5)
    table.insert(self.boradcastTable,laba)
    self.move_root:addChild(laba)
    local head=ccui.Text:create("【"..info.nick.."】：",GameRes.font1,34)
    head:setAnchorPoint(0,0.5)
    head:setPosition(laba:getContentSize().width+20,cs.height*0.5)
    table.insert(self.boradcastTable,head)
    self.move_root:addChild(head)
    local nowX=head:getContentSize().width+10+laba:getContentSize().width+20

    local txt=ccui.Text:create(info.content,GameRes.font1,34)
    txt:setAnchorPoint(0,0.5)
    txt:setPosition(nowX,cs.height*0.5)
    table.insert(self.boradcastTable,txt)
    self.move_root:addChild(txt)
    nowX=nowX+txt:getContentSize().width
    local distence = cs.width + nowX
    local time = distence/200
    self.move_root:stopAllActions()
    self.move_root:setPositionX(cs.width)
    self.isRuning = true
    self.move_root:runAction(
        cc.Sequence:create(
            cc.Show:create(),
            cc.MoveBy:create(time,cc.p(-distence,0)),
            cc.Hide:create(),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function ( sender )
                self._boradcastBg:setVisible(false)
                self.isRuning = false
                qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT)
            end)
        )
    )
end

function GlobalView:showBoradcastTxt(info)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    self:boradcastInit()
    local txt_root = ccui.Helper:seekWidgetByName(self._boradcastBg, "txt_root")
    if not txt_root or tolua.isnull(txt_root) then
        return 
    end
    if ModuleManager:judegeIsInLogin() then
        self:hideBoradcast()
    else
        self:showBoradcast()
    end
    local cs = txt_root:getContentSize()
    if info.level == 400 then
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
            self:hideBoradcast()
            return
        end
        self:showBoradcastTxtWithPersonal(info)
        return 
    else
        self:showBoradcastTxtWithSystem(info)
        return
    end

end

function GlobalView:showBoradcastTxt_inGame(info)
    if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat) then
        return
    end
    self:showBoradcastTxt(info)
end


function GlobalView:_toastAction()
    if #self.toastTxtT == 0 then return end
    for k , v in pairs(self.toastLabelT) do
        local height = v:getContentSize().height
        v:runAction(cc.MoveBy:create(0.4,cc.p(0,height)))
    end

    local txt
    local color
    if self.toastTxtT[1].color~=nil then
        txt= self.toastTxtT[1].txt
        color=self.toastTxtT[1].color
    else
        txt= self.toastTxtT[1]
    end
    local delayT =  #self.toastLabelT ~= 0 and 0.4 or 0
    local time = 2

    cc.Director:getInstance():getTextureCache():reloadTexture(GameRes.toast_bg)
    
    local toast = cc.Sprite:create(GameRes.toast_bg)
    toast:setPosition(self.winSize.width/2,self.winSize.height/2)
    local cs = toast:getContentSize()
    local l = cc.LabelTTF:create(txt,GameRes.font1,35)
    l:setAnchorPoint(0,0.5)
    if color~=nil then
        l:setColor(color)
    else
        l:setColor(cc.c3b(255,255,255))
    end
    local ts = l:getContentSize()
    l:setPosition((cs.width-ts.width)/2,cs.height/2)
    toast:addChild(l)
    toast:setCascadeOpacityEnabled(true)
    toast:setOpacity(0)
    local height = toast:getContentSize().height
    toast:runAction(cc.Sequence:create(
        cc.DelayTime:create(delayT or 0),
        cc.FadeTo:create(0.3,255),
        cc.DelayTime:create(0.7),
        cc.CallFunc:create(function() 
            table.remove(self.toastTxtT,1)
            self:_toastAction()
        end),
        cc.FadeTo:create(time,0),
        cc.CallFunc:create(function(sender)
            table.remove(self.toastLabelT,1)
            toast:removeFromParent()
        end)))
    self:addChild(toast)
    self.toastLabelT[#self.toastLabelT + 1] = toast
    toast:setLocalZOrder(99999999)
end

function GlobalView:showToast(paras)
    if paras == nil or paras.txt == nil or paras.txt == "" then
        return 
    end

    for k , v in pairs(self.toastTxtT) do
        if paras.txt == v then return end
    end
    self.toastTxtT = self.toastTxtT or {}
    if paras.color~=nil then 
        self.toastTxtT[#self.toastTxtT + 1] = paras
    else
        self.toastTxtT[#self.toastTxtT + 1] = paras.txt
    end
    if #self.toastTxtT ~= 1 then return end
    self:_toastAction()
end


function GlobalView:addWaitting (paras)
    local txt = paras.txt
    local waitTempTag = self.waittingTAG
    if paras.reConnect == 1 then
        waitTempTag = self.loginWaittingTAG
    end

    -- 防止每次切入前台后，由于onDisconnect消息被清除，从而重复手工触发onDisconnect。会导致loading出现多个。
    if self:getChildByName("netWaitting") ~= nil then
        return
    end


    local node = cc.Node:create()
    node:setName("netWaitting")
    local req = cc.Sprite:create(GameRes.global_wait_bg)

    req:setPosition(self.winSize.width/2,self.winSize.height/2)
    req:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5,360)))



    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function(touch,event)
        logd(" ---- wait swallow touches ---- " , self.TAG)
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)

    listener1:registerScriptHandler(function(touch,event)

        end,cc.Handler.EVENT_TOUCH_ENDED)


    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, req)


    local txt = cc.LabelTTF:create(txt, "Arial", 30)
    --增加20的margin
    txt:setPosition(self.winSize.width/2,self.winSize.height/2 - req:getContentSize().height -20)

    local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), self.winSize.width/4,self.winSize.height/4)
    bg:setPosition(self.winSize.width/2-bg:getContentSize().width/2,self.winSize.height/2-bg:getContentSize().height/5*3)
    local frame = cc.Sprite:create(GameRes.global_wait_frame)
    frame:setPosition(self.winSize.width/2,self.winSize.height/2)

    local txtFame = cc.Sprite:create(GameRes.global_wait_txt_frame)
    txtFame:setPosition(cc.p(txt:getPositionX(), txt:getPositionY()))

    node:setTag(waitTempTag)
    --node:addChild(bg)
    node:addChild(frame)
    node:addChild(txtFame)
    node:addChild(txt)
    node:addChild(req)

    self:addChild(node)
end

--显示日常活动
function GlobalView:showDayEvent(model)
    local winSize = cc.Director:getInstance():getWinSize()
    self:hideDayEvent()
    if self._dayEvent ~= nil then return end
    self._dayEvent = DayEvent.new({cb = handler(self,self.hideDayEvent),model = model})
    self._dayEvent:setScale(0)
    Display:popAction({time=0.2,view=self._dayEvent})
    self:addChild(self._dayEvent,self.dayRewardOrder - 2)
end

--[[移除日常活动]]
function GlobalView:hideDayEvent()
    if self._dayEvent == nil then return end
    Display:backAction({time=0.2,view=self._dayEvent,cb=function(sender)
        self._dayEvent:removeFromParent(true)
        self._dayEvent = nil
    end})
end

--显示确认购买
function GlobalView:showShopPromit(paras)
    local shopPromit = ShopPromit.new(paras)
    shopPromit:show()
end

--隐藏确认购买
function GlobalView:hideShopPromit()
    self.shopPromit = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.shopPromit)
    if self.shopPromit ~= nil then
        self.shopPromit:close()
        self.shopPromit=nil
    end
end

--[[-- 弹出公共提示框]]
function GlobalView:showGlobalPromit(paras)
    if self._globalPromit == nil then
        local globalPromit = GlobalPromit.new(paras)
        self:addChild(globalPromit,self.fullWaittingTAG+2)
        globalPromit:setPosition(self.winSize.width/2,self.winSize.height/2)
        globalPromit:setScale(0)
        --shopPromit:setVisible(true)
        Display:popAction({time=0.2,view=globalPromit,cb=function(sender)
            end})
        self._globalPromit = globalPromit
    end
end
--[[-- 隐藏公共提示框]]
function GlobalView:hideGlobalPromit()
    if self._globalPromit then
        Display:backAction({time=0.2,view=self._globalPromit,cb=function(sender)
            sender:removeFromParent(true)
            self._globalPromit = nil
        end})
    end
end

--[[-- 弹出破产提示框]]
function GlobalView:showBankruptcy(paras)
    local bankruptcy = Bankruptcy.new(paras)
    bankruptcy:show()
end
--[[-- 隐藏破产提示框]]
function GlobalView:hideBankruptcy()
    self.bankruptcy = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.bankruptcy)
    if self.bankruptcy ~= nil then
        self.bankruptcy:closeView()
        self.bankruptcy=nil
    end
end
--[[-- 更新破产提示框]]
function GlobalView:updateBankruptcy(type)
    local bankruptcy = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.bankruptcy)
    if bankruptcy ~= nil then
        bankruptcy:showLayoutByType(type)
    end
end


--[[-- 弹出连赢提示框]]
function GlobalView:showWinningStreak(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    self:hideWinningStreak()
    local winningstreak = WinningStreak.new(paras)
    winningstreak:show()
end
--[[-- 隐藏连赢提示框]]
function GlobalView:hideWinningStreak()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local winningstreak = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.winningstreak)
    if winningstreak ~= nil then
        winningstreak:closeView()
    end
end

--[[显示最新计费界面]]
function GlobalView:showNewBilling(paras)
    local gold_limit = 0
    local needgold=nil
    if paras.room_id then 
        gold_limit = Cache.Config._roomList[paras.room_id].carry_min 
        if Cache.Config._roomList[paras.room_id].enter_limit_low then
            needgold=Cache.Config._roomList[paras.room_id].enter_limit_low -Cache.user.gold
        end
    end
    if paras.limit then
        gold_limit = paras.limit
    end
    if paras.limit_low and paras.limit_low>Cache.user.gold then 
        needgold=paras.limit_low-Cache.user.gold
    end
    if not needgold and gold_limit>Cache.user.gold then 
        needgold=gold_limit-Cache.user.gold 
    end
    if not needgold or needgold<0 then needgold=0 end
    qf.platform:umengStatistics({umeng_key = "QuickSale1Open"})
    --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {needgold=needgold,gold=gold_limit, ref=paras.ref,cb=paras.cb})
    qf.event:dispatchEvent(ET.SHOP)
end

function GlobalView:removeWaitting(paras)
    if paras == "hard" then
        if self:getChildByName("netWaitting") then
            self:removeChildByName("netWaitting")
        end
        return
    end
    local waitTempTag = self.waittingTAG
    if paras == 1 then
        waitTempTag = self.loginWaittingTAG
    end
    self:removeChildByTag(waitTempTag)
end
--[[显示周月卡奖励界面]]
function GlobalView:showWeekMonthReward(paras)
    qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{number = 1000})
    self:hideWeekMonthReward()
    self._weekmonthreward = weekMonthCard.new({cb = function() 
        self:hideWeekMonthReward()
    end})
    self:addChild(self._weekmonthreward,self.weekMonthOrder)
    self._weekmonthreward:setData(paras)
end

--[[隐藏周月卡奖励界面]]
function GlobalView:hideWeekMonthReward()
    if self._weekmonthreward == nil then return end
    self._weekmonthreward:removeFromParent(true)
    self._weekmonthreward = nil
end

--显示大相册
-- function GlobalView:showBigPhotoAlbum( args )
--     local album_view = PhotoBigNode.new(args)
--     self:addChild(album_view, 0, self.bigPhotoTag)
-- end
--category  1好友送礼，2活动奖励，3系统任务奖励，4每日任务奖励，5每日登录奖励，6破产补助，7定时奖励,10邮箱
function GlobalView:xiaoHongDianRefresh(paras)
    if paras.model == nil then return end
    self.freegold_redNum = 0
    for i=1,paras.model.notify:len() do
        local data = paras.model.notify:get(i)
        if data.category == 5 then
            self.red_state["login"] = data.status
        elseif data.category == 6 then
            self.red_state["pocan"] = data.status
         elseif data.category == 7  then
            self.red_state["time"] = data.status
        elseif data.category == 9  then
            self.red_state["notice"] = data.status
        elseif data.category == 11  then
            Cache.mailInfo:setNewMailFlag(0)
            Cache.mailInfo:setNewMailFlag(data.status)
            qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER, {name="mailInfo"})
        elseif data.category == 12 then
            Cache.customInfo:setNewCustomFlag(0)
            Cache.customInfo:setNewCustomFlag(data.status)
            qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER, {name="customInfo"})
        end
    end
    
    if tonumber(self.red_state["login"]) >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["login"]
    end
    if tonumber(self.red_state["pocan"]) >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["pocan"]
    end
    if tonumber(self.red_state["time"]) >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["time"]
    end
    if tonumber(self.red_state["notice"]) >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["notice"]
    end

    Cache.Config.freegold_redNum = self.freegold_redNum
    qf.event:dispatchEvent(ET.REFRESH_FREE_GILD_RED_NUM,{num = self.freegold_redNum })
end

--显示活动公告
function GlobalView:showActiveNotice(model)
    if  ModuleManager:judegeIsInMain() then
        local activeNotice = ActiveNotice.new(model)
        activeNotice:show()
    end
end

--隐藏活动公告
function GlobalView:hideActiveNotice()
    local activeNotice = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.activeNotice)
    if activeNotice ~= nil then
        activeNotice:close()
    end
end

function GlobalView:getRoot()
    return LayerManager.Global
end

function GlobalView:removeExistView()
    self:hideActiveNotice()
    self:hideBoradcast()
    self:hideDayEvent()
    self:hideShopPromit()
    self:hideGlobalPromit()
    self:hideBankruptcy()
end

--设置广播位置
function GlobalView:setBroadCast(paras)
    if not Util:checkNodeExist(self._boradcastBg) then
        self:boradcastInit()
        if self._boradcastBg then
            self._boradcastBg:setVisible(false)
        end
    end

    if self._boradcastBg then
        self._boradcastBg:setPosition(cc.p(self._boradcastBg_px+paras.x,self._boradcastBg_py+paras.y))
    end
end

function GlobalView:showInteractiveExpression(paras)
    if self.interactiveExpression then 
        self:removeInteractiveExpression()
    end
    self.interactiveExpression = InteractiveExpression.new(paras)
    self:addChild(self.interactiveExpression,self.fullWaittingZ-1)
end
function GlobalView:removeInteractiveExpression()
    if self.interactiveExpression then 
        self.interactiveExpression:removeFromParent()
        self.interactiveExpression=nil
    end
end

--显示快捷聊天
function GlobalView:showQuicklyChat(paras)
    if self.QuicklyChat then return end
    self.QuicklyChat = QuicklyChat.new(paras)
    self:addChild(self.QuicklyChat,self.fullWaittingZ-1)
end

--删除快捷聊天
function GlobalView:removeQuicklyChat()
    if not self.QuicklyChat then return end
    self.QuicklyChat:removeFromParent(true)
    self.QuicklyChat=nil
end

--显示快捷聊天
function GlobalView:showTurnTable(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local turnTable = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.turntable)
    if turnTable ~= nil then return end
    local TurnTable = TurnTable.new(paras)
    TurnTable:show()
end

--关闭快捷聊天
function GlobalView:removeTurnTable(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local TurnTable = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.turntable)
    if TurnTable ~= nil then
        TurnTable:closeView()
    end
    --self:addChild(self.TurnTable,self.fullWaittingZ-1)
end

--显示累计登陆
function GlobalView:showNewTotalLogin(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local newTotalLogin = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newtotallogin)
    if newTotalLogin ~= nil then return end
    local NewTotalLogin = NewTotalLogin.new(paras)
    NewTotalLogin:show()
end

--关闭累计登陆
function GlobalView:removeNewTotalLogin(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local NewTotalLogin = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newtotallogin)
    if NewTotalLogin ~= nil then
        NewTotalLogin:closeView()
    end
end

--显示消息引导
function GlobalView:showNewsLead(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW or self.NewsLead then return end
    self.NewsLead = NewsLead.new(paras)
    self:addChild(self.NewsLead,1)
end

--关闭消息引导
function GlobalView:removeNewsLead()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    if self.NewsLead ~= nil then
       self.NewsLead:removeFromParent()
       self.NewsLead=nil
    end
end

--显示游客提示
function GlobalView:showVisitorTips(paras)
    local freegoldshortcut = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.visitortips)
    if freegoldshortcut ~= nil then return end
    if not Cache.user:checkShowVisitorTip() then return end
    Cache.user:setShowVisitorTip(false)
    local VisitorTips = VisitorTips.new(paras)
    VisitorTips:show()
end

--关闭游客提示
function GlobalView:removeVisitorTips()
    local VisitorTips = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.visitortips)
    if VisitorTips ~= nil then
        VisitorTips:closeView()
    end
end

--显示累计登陆
function GlobalView:showFreeGoldShortCut(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local freegoldshortcut = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.freegoldshortcut)
    if freegoldshortcut ~= nil then return end
    local FreeGoldShortCut = FreeGoldShortCut.new(paras)
    FreeGoldShortCut:show()
end

--关闭累计登陆
function GlobalView:removeFreeGoldShortCut(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local FreeGoldShortCut = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.freegoldshortcut)
    if FreeGoldShortCut ~= nil then
        FreeGoldShortCut:closeView()
    end
end

--显示或关闭支付loading
function GlobalView:showPayLoading(paras)
    -- body
    if paras.isVisible then
        if self.payLoading then return end
        self.payLoading = PayLoading.new()
        self:addChild(self.payLoading)
    else
        self.payLoading:removeFromParent()
        self.payLoading =nil
    end
end

-- --显示小车入场动画
-- function GlobalView:showGiftCarAni(paras)
--     -- body
--     GiftAnimate:addGiftAni(paras,self)
-- end

-- --删除小车入场动画
-- function GlobalView:removeGiftCarAni(paras)
--     -- body
--     -- GiftAnimate:removeAniTable()
-- end

return GlobalView