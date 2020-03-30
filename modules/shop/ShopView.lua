local ShopView = class("ShopView", CommonWidget.PopupWindow)

ShopView.TAG = "ShopView"
function ShopView:ctor(args)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shop)
    self:init(args)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.newShop, child=self.root})
end

function ShopView:isAdaptateiPhoneX()
    return true
end

--1 银行 2 支付宝 3 微信
--设置支付顺序
function ShopView:setPayOrder(config)
    local order = {1}
    if config ~= nil then
        order = {}
        --确保index_id  即使不按照1到n来排列 只要有大小顺序即可 即使相等也可
        local tempOrderTbl = {}
        for i, v in ipairs(config) do
            tempOrderTbl[#tempOrderTbl + 1] = { index = v.index_id, style = v.recharge_id}
        end
        table.sort(tempOrderTbl, function (a, b)
            return a.index < b.index
        end)
        for i, v in ipairs(tempOrderTbl) do
            order[#order + 1] = v.style
        end
    end
    self:refreshTabScrollView(order)    
    -- 存的是 key: 类型 value:顺序
    self.orderList = order
end

function ShopView:refreshTabScrollView(order)
    -- btnList 存储的是 按照服务器顺序存储的按钮列表
    -- 1 是 银行 2 是支付宝 3 是微信 4是微信小额 5是支付宝小额
    -- order 的键是顺序 值是类型
    -- order = {1,2,3,4,5,6, 7}
    for _,v in pairs(self._btnList) do
        v:setVisible(false)
    end

    local cnt = #order - 4
    cnt = cnt > 0 and cnt or 0
    local difHeight = self.dyHeight
    if cnt == 0 then
        self.tabScrollView:setInnerContainerSize(cc.size(450, 700))
        self.tabScrollView:setPosition(cc.p(13, 0))
    else
        self.tabScrollView:setInnerContainerSize(cc.size(450, 700 + cnt * difHeight))
        self.tabScrollView:setPosition(cc.p(13, 0))
    end

    for i, v in ipairs(order) do
        local btn = self._btnList[v]
        btn:setPositionY(self._posYList[i] + cnt*difHeight)
        btn:setVisible(true)
        btn.rechargeId = v
    end
end

function ShopView:init( args )
    local uiTbl = {
        {name = "closeBtn",            path = "Panel_Shop/Panel_top/Button_back",     handler = handler(self, self.onButtonEvent)},
        {name = "topPanel",            path = "Panel_Shop/Panel_top"},

        {name = "panelNoAction",       path = "Panel_Shop/Panel_no_action",     handler = handler(self, self.onButtonEvent)},


        {name = "panelTab",             path = "Panel_Shop/Panel_tab"},
        {name = "modelBtn",             path = "tabDi/Button_bankercard",     handler = handler(self, self.onButtonEvent)},

        {name = "tabScrollView",            path = "Panel_Shop/Panel_tab/TabScrollView"},

        {name = "quesBtn",            path = "Panel_Shop/Panel_top/quesBtn",     handler = handler(self, self.onButtonEvent)},

        {name = "panelInfo",           path = "Panel_Shop/Panel_info"},
        {name = "imageSetFrame",       path = "Panel_Shop/Panel_info/Image_coin_frame"},
        {name = "clearBtn",          path = "Panel_Shop/Panel_info/Button_clear", handler = handler(self, self.onButtonEvent)},           
        {name = "requestBtn",        path = "Panel_Shop/Panel_info/Button_request", handler = handler(self, self.onButtonEvent)},   
        {name = "tipImg",            path = "Panel_Shop/Panel_info/TipImg"},   

        {name = "zhuanshuPanel",           path = "Panel_Shop/Panel_zhuanshu"},
        {name = "zhuanShuHead",       path = "Panel_Shop/Panel_zhuanshu/head"},
        {name = "zhuanShuHeadName",       path = "Panel_Shop/Panel_zhuanshu/head/headname"},
        {name = "goRechargeBtn",          path = "Panel_Shop/Panel_zhuanshu/goBtn", handler = handler(self, self.onButtonEvent)},

        {name = "shopPanel",         path = "Panel_Shop"},
        {name = "quesPanel",         path = "Panel_Ques"},
        {name = "quesCloseBtn",      path = "Panel_Ques/closeBtn", handler = handler(self, self.onButtonEvent)},
        {name = "customBtn",         path = "Panel_Ques/customBtn", handler = handler(self, self.onButtonEvent)},

    }

    self.dyHeight = 145
    Util:bindUI(self, self.root, uiTbl)
    self:initUI()

    self.allConfig = {}
    self:setPayOrder(Cache.Config.shopConfig)
    local body = {}
    body.uin = Cache.user.uin

    GameNet:send({cmd=CMD.GET_EXCHANGE_CONFIG,body=body,timeout=nil,callback=function(rsp)
        if tolua.isnull(self) == true then
            return
        end
        self:saveAllConfig(rsp)
    end})

    if Cache.Config.shopConfig then
        self.allConfig = Cache.Config.shopConfig
        local idx = self.orderList[1]   
        self:clickTabButton(self._btnList[idx])
        self:showRecommendIcon(self._btnList[idx])
    else
        self.bankBtn.rechargeId = 1
        self:clickTabButton(self.bankBtn)
    end


    
    Display:closeTouch(self)
    Util:registerKeyReleased({self=self, cb = function( sender )
        self:backHandler()
    end})
end

function ShopView:showRecommendIcon(sender)
    for i, v in ipairs(self._btnList ) do
        v:getChildByName("recommend"):setVisible(false)
    end
    sender:getChildByName("recommend"):setVisible(true)
end

function ShopView:clickTabButton(sender)
    if not sender:isVisible() then --如果点击的是没有展示的就使用一个展示的来替代
        for i, v in ipairs(self._btnList) do
            if v:isVisible() then
                sender = v
                break
            end
        end
    end

    self.rechargeId = sender.rechargeId
    local idx = table.indexof(self._btnList, sender)
    local ptype = self._pTypeList[idx]
    self:updateUIAndButton(sender, ptype, idx)
end

function ShopView:updateUIAndButton(sender, payType, uid)
    for i, v in ipairs(self._btnList) do
        v:setEnabled(true)
        v:setBright(true)
    end
    sender:setEnabled(false)
    sender:setBright(false)
    self.payType = payType
    self:updateUI(uid)
end

function ShopView:clearCoinEditBox()
    for k, v in ipairs(self.coinNumTable) do
        v:getChildByName("Image_86"):setVisible(false)
    end
    self.editCoinNum = ""
    self._editBoxCoin:setText("")
end

function ShopView:setQuesPanelVis(bVis)
    self.shopPanel:setVisible(bV)
    self.quesPanel:setVisible(bVis)
end

function ShopView:showPanel(sender)
    self.shopPanel:setVisible(false)
    self.quesPanel:setVisible(false)
    sender:setVisible(true)
end

function ShopView:onButtonEvent(sender)
    if sender.name == "closeBtn" then
        self:backHandler()
    elseif sender.name == "aliBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "bankBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "wechatBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "ysfBtn" then
        self:clickTabButton(sender)        
    elseif sender.name == "zsBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "s_aliBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "s_wechatBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "clearBtn" then
        self:clearCoinEditBox()
    elseif sender.name == "requestBtn" then
        self:requestBuyGoods(sender)
    elseif sender.name == "quesBtn" then
        self:showPanel(self.quesPanel)
    elseif sender.name == "quesCloseBtn" then
        self:showPanel(self.shopPanel)
    elseif sender.name == "customBtn" then
        self:close()
        qf.event:dispatchEvent(ET.CUSTOM_CHAT,{autoLink = true})
    elseif sender.name == "goRechargeBtn" then
        if tonumber(GAME_VERSION_CODE) < 440 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.shop_txt_1})
        else
            self:close()
            qf.event:dispatchEvent(ET.CUSTOM_CHAT, {forceLinkType = 2})
        end
    else
        if sender.name then
            logd(string.format("%s not bind clickistener", sender.name))
        end
    end
end

function ShopView:btnNumCall(sender)
    local coinNum = sender:getChildByName("number"):getString()
    coinNum = string.sub(coinNum, 1, -4)
    self._editBoxCoin:setText(coinNum)
    self.editCoinNum = tonumber(coinNum)
    --更新flag标记
    for k, v in ipairs(self.coinNumTable) do
        if v:getName() == sender:getName() then
            v:getChildByName("Image_86"):setVisible(true)
        else
            v:getChildByName("Image_86"):setVisible(false)
        end
    end
end

function ShopView:requestBuyGoods(sender)
    local lastClickTime = self.payLastTime
    self.payLastTime = socket.gettime()
    if lastClickTime and self.payLastTime - lastClickTime <= 1 then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_show_3})
        return
    end
    self.payLastTime = socket.gettime()
    local rData = self:getRechargeData(self.rechargeId)
    if checknumber(self.editCoinNum) <= 0 then
        if rData.showAnyNumFlag == false then --无输入框
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_show_13})
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_show_4})
        end
        return 
    end

    
    --判断金额合法
    if tonumber(self.minCoin) > 0 and tonumber(self.editCoinNum) < tonumber(self.minCoin) then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.string_show_5, self.minCoin)})
        return
    end
    if tonumber(self.maxCoin) > 0 and tonumber(self.editCoinNum) > tonumber(self.maxCoin) then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.string_show_6, self.maxCoin)})
        return
    end

    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.string_show_14})

    local info = qf.platform:getRegInfo()
    --请求下单
    local url = HOST_BILL .. "/bill/alloc_v2?"
    local req = {}
    req.data = {}
    req.data.userid = Cache.user.uin
    req.data.cur = "CN"
    req.data.amt = self.editCoinNum
    req.data.bill_type = self.payType
    req.data.os = info.os
    req.data.channel = GAME_CHANNEL_NAME
    req.data.source = rData.pay_channel .. ""
    req.data.withdraw_type = 1
    req.data.invite_from = Cache.user.invite_from or 0
    req.sign = QNative:shareInstance():md5(qf.platform:getKey().."|".."/bill/alloc_v2|"..tostring(qf.json.encode(req.data)))
    url = url.."data="..tostring(qf.json.encode(req.data)).."&sign="..req.sign
    dump(req, "request bill url = "..url)
    local xhr = cc.XMLHttpRequest:new()
    xhr.payType = self.payType
    xhr.editCoinNum = self.editCoinNum
    local function callbackFunc()
        local response  = xhr.response
        local output = {
            ret = -1, 
            error = GameTxt.string_show_15
        }

        xpcall(
            function()  --try
                output = qf.json.decode(response,1)
            end,
            function(msg)   --catch
            end
        )

        if output.ret == 0 then
            --请求支付
            local payUrl = Cache.Config:getWebHost() .. "/BULL/third_pay_bull?"
            local payReq = {}
            payReq.data ={}
            payReq.data.mhtOrderNo = output.bill_id   --订单号  就是第一步获取的bill_id
            payReq.data.payChannelType = xhr.payType  --支付方式    39支付宝  40微信  41 银行卡 501 苹果官方支付
            payReq.data.mhtOrderAmt = xhr.editCoinNum  --    支付金额    整形
            payUrl = payUrl.."data="..tostring(qf.json.encode(payReq.data))
            loga("request bill url = "..payUrl)
            ------------------------
            local winsize = cc.Director:getInstance():getWinSize()
            local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
            local w = winsize.width
            local h = fsize.height*winsize.width/fsize.width
            local x = 0
            local y = 0
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
            Util:delayRun(1/60, function ( ... )
                qf.platform:showSchemeUrl({url = payUrl, cb = function ()
                    -- body
                end})
            end)
        else
            if output.error then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = output.error})
            end
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
        end
    end    
    xhr:open("GET", url)
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xhr:registerScriptHandler(callbackFunc)
    xhr:send()
end

function ShopView:alignTabBtnAndIcon(btnList)
    for i, v in ipairs(btnList) do
        local icon = v:getChildByName("Image_title")
        local content =  v:getChildByName("Image_title_0")
        content:setAnchorPoint(cc.p(0, 0.5))
        icon:setPositionX(45)
        content:setPositionX(80)
    end
end

function ShopView:initUI( ... )
    local imgsfSize = self.imageSetFrame:getContentSize()
    self._editBoxCoin = Util:createEditBox(self.imageSetFrame, {
        offset = {x = -80, y = 0},
        tag = -987654,
        fontcolor = cc.c3b(30, 74, 130),
        fontname = GameRes.font1,
        name = "coinNum",
        fontsize = 38,
        placeFontsize = 38,
        placeTxt = GameTxt.string_show_2,
        holdColor = cc.c3b(159, 158, 158),
        handler = handler(self, self.editboxEventHandler), 
        retType = cc.KEYBOARD_RETURNTYPE_DONE,
        iMode = cc.EDITBOX_INPUT_MODE_NUMERIC
    })

    --快捷选择按钮
    self.coinNumTable = {}
    local defaultPriceTbl = {
        0, 0, 0, 0,
        0, 0, 0, 0
    }
    for i = 1, 8 do
        local btn98 = ccui.Helper:seekWidgetByName(self.panelInfo, string.format("Button_98_%d", i))
        btn98:getChildByName("number"):setString(defaultPriceTbl[i] .. Cache.packetInfo:getShowUnit())
        addButtonEvent(btn98, handler(self, self.btnNumCall))
        table.insert(self.coinNumTable, btn98)
    end

    self._pTypeList = {41,39,40,43,42,44,1}
    self._texNormal = {
        [1] = {GameRes.shop_image_1, GameRes.shop_image_2},
        [2] = {GameRes.shop_image_3, GameRes.shop_image_4},
        [3] = {GameRes.shop_image_5, GameRes.shop_image_6},
        [4] = {GameRes.shop_image_5, GameRes.shop_image_15},
        [5] = {GameRes.shop_image_3, GameRes.shop_image_17},
        [6] = {GameRes.shop_image_18, GameRes.shop_image_20},
        [7] = {GameRes.shop_image_21, GameRes.shop_image_23},
    }

    self._texSelect = {
        [1] = {GameRes.shop_image_1, GameRes.shop_image_12},
        [2] = {GameRes.shop_image_3, GameRes.shop_image_10},
        [3] = {GameRes.shop_image_5, GameRes.shop_image_8},
        [4] = {GameRes.shop_image_5, GameRes.shop_image_14},
        [5] = {GameRes.shop_image_3, GameRes.shop_image_16},
        [6] = {GameRes.shop_image_18, GameRes.shop_image_19},
        [7] = {GameRes.shop_image_21, GameRes.shop_image_22},
    }

    --一定要按照服务器的顺序来 按钮列表
    local btnNameList = {"bankBtn", "aliBtn", "wechatBtn", "s_wechatBtn", "s_aliBtn", "ysfBtn", "zsBtn"}
    self._btnList = self:initBtnList(self.modelBtn, btnNameList)
    self:alignTabBtnAndIcon(self._btnList)

    if self._posYList == nil then
        Util:setPosOffset(self.bankBtn, {x = 0, y = -30})
        self.btnX = self.bankBtn:getPositionX()
        self.btnY = self.bankBtn:getPositionY()
        local posYList = {}
        local dy = self.dyHeight
        for i, v in ipairs(self._btnList) do
            posYList[i] = self.btnY - dy *(i-1)
        end
        table.sort(posYList, function (a, b)
            return a > b
        end)
        self._posYList = posYList
    end


    Util:enlargeCloseBtnClickArea(self.closeBtn)
    Util:enlargeCloseBtnClickArea(self.quesCloseBtn)
    for i, v in ipairs(self._btnList) do
        local res = GameRes.shop_image_13
        local spr = cc.Sprite:create(res)
        spr:setName("recommend")
        local pos = cc.p(320, 130)
        spr:setPosition3D(pos)
        v:addChild(spr)
        spr:setVisible(false)
    end

    if FULLSCREENADAPTIVE then
        local winSize = cc.Director:getInstance():getWinSize()
        self.root:setContentSize(winSize.width, winSize.height)
        self.root:setPositionX(self.root:getPositionX()-(winSize.width/2-1920/2))
        self.panelTab:setPositionX(self.panelTab:getPositionX()+(winSize.width/2-1920/2))
        self.panelInfo:setPositionX(self.panelInfo:getPositionX()+(winSize.width/2-1920/2))
        self.panelNoAction:setPositionX(self.panelNoAction:getPositionX()+(winSize.width/2-1920/2))
        self.topPanel:setPositionX(self.topPanel:getPositionX()+(winSize.width/2-1920/2))
        self.quesPanel:setPositionX(self.quesPanel:getPositionX()+(winSize.width/2-1920/2))
        self.zhuanshuPanel:setPositionX(self.zhuanshuPanel:getPositionX()+(winSize.width/2-1920/2))
    end
end

function ShopView:initBtnList(model, listName)
    local parent = model:getParent()
    local btnList = {}
    model:setVisible(false)
    for i, v in ipairs(listName) do
        local tmpBtn = model:clone()
        tmpBtn:setName(v)
        parent:addChild(tmpBtn)
        btnList[#btnList + 1] = tmpBtn
        tmpBtn.name = v
        self[v] = tmpBtn
    end
    return btnList
end

function ShopView:getRechargeData(chargeId)
    print("chargeId >>>>>", chargeId)
    for i,v in ipairs(self.allConfig) do
        if checknumber(v.recharge_id) == chargeId  then
            return v
        end
    end
end

function ShopView:getRechargeBtnImage(sender)
    local rechargeId = sender.rechargeId
    if not rechargeId then 
        rechargeId = 1
    end
    --1 银行卡  2支付宝  3微信  4微信固定额度 5支付宝固定额度
    return self._texNormal[rechargeId], self._texSelect[rechargeId]
end

function ShopView:refreshButton(id)
    for i, v in ipairs(self._btnList) do
        v:setPositionX(self.btnX)
        local normalText, selectText = self:getRechargeBtnImage(v)
        v:getChildByName("Image_title"):loadTexture(normalText[1], 0)
        v:getChildByName("Image_title_0"):loadTexture(normalText[2], 0)
    end
    local dx = 3.5
    local sender = self._btnList[id]
    local normalText, selectText = self:getRechargeBtnImage(sender)
    sender:setPositionX(self.btnX+dx)
    sender:getChildByName("Image_title"):loadTexture(selectText[1])
    sender:getChildByName("Image_title_0"):loadTexture(selectText[2])
end

function ShopView:refreshNoAction(chargeInfo)
    if chargeInfo and chargeInfo.notice_word then
        local panelNoAction = self.panelNoAction
        panelNoAction:getChildByName("Label_133"):setString(chargeInfo.notice_word)
    end
end

function ShopView:refreshZhuanshuPanel( ... )
    local data = Cache.agencyInfo:getAgencyDetailInfo()
    
    local _refreshPanel = function (data)
        Util:updateUserHead(self.zhuanShuHead, data.proxy_portrait, data.sex, {add = true, sq = true, url = true, scale = self.zhuanShuHead:getContentSize().width, circle = false})

        self.zhuanShuHeadName:setString(data.nick)
    end

    if agencyInfo == nil then
        Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
            _refreshPanel(data)
        end)
    else
        _refreshPanel(data)
    end

    self.zhuanshuPanel:setVisible(true)
end

function ShopView:updateUI( chargeId )
    if chargeId == nil then
        chargeId = self._chargeId or 1
    end
    self._chargeId = chargeId

    -- body
    self:refreshButton(chargeId)

    local panelInfo = self.panelInfo
    local panelNoAction = self.panelNoAction
    local zhuanshuPanel = self.zhuanshuPanel

    panelNoAction:setVisible(false)
    panelInfo:setVisible(false)
    zhuanshuPanel:setVisible(false)
    if self._chargeId == 7 then
        self:refreshZhuanshuPanel()
        return
    end

    local chargeInfo = self:getRechargeData(self._chargeId)
    self._editBoxCoin:setText("")
    self.editCoinNum = ""
    self:refreshNoAction(chargeInfo)
    for k, v in ipairs(self.coinNumTable) do
        v:getChildByName("Image_86"):setVisible(false)
    end

    if chargeInfo == nil then
        panelInfo:setVisible(false)
        panelNoAction:setVisible(true)
        return
    end
    

    if chargeInfo.recharge_valid == 1 then
        panelInfo:setVisible(true)
        panelNoAction:setVisible(false)
    else
        panelInfo:setVisible(false)
        panelNoAction:setVisible(true)
        return
    end

    self.minCoin = chargeInfo.min_recharge_money or 0
    self.maxCoin = chargeInfo.max_recharge_money or 0
    --按钮金额
    for k, v in ipairs(self.coinNumTable) do
        if chargeInfo.quick_list[k] then
            v:getChildByName("number"):setString(chargeInfo.quick_list[k] .. Cache.packetInfo:getShowUnit())
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end

    if self.minCoin and self.maxCoin then
        self._editBoxCoin:setPlaceHolder(string.format(GameTxt.string_show_11, self.minCoin, self.maxCoin))
    end

    local flagTbl = {
        GameRes.shop_bank_path,
        GameRes.shop_zfb_path,
        GameRes.shop_wx_path,
        GameRes.shop_wx_path,
        GameRes.shop_zfb_path,
        GameRes.shop_ysf_path,
        GameRes.shop_ysf_path,
    }
    local flagPng = flagTbl[chargeId] or GameRes.shop_bank_path
    self:refreshTipImg(HOST_PREFIX..RESOURCE_HOST_NAME .. chargeInfo.url, flagPng)

    self:refreshOKPanel(chargeId)
end

function ShopView:refreshOKPanel(id)
    local normalPos = cc.p(836, 99)
    local simplePos = cc.p(519, 99)
    local chargeInfo = self:getRechargeData(id)
    if not chargeInfo.showAnyNumFlag then
        self.requestBtn:setPosition(simplePos)
        self.imageSetFrame:setVisible(false)
        self._editBoxCoin:setVisible(false)
    else
        self.requestBtn:setPosition(normalPos)
        self.imageSetFrame:setVisible(true)
        self._editBoxCoin:setVisible(true)
    end
end

function ShopView:refreshTipImg(url, png)
    self.tipImg:loadTexture(png)
    if url and url ~= "" then
        Util:downloadImg(url, self.tipImg, 0, 2)
    end
end

function ShopView:editboxEventHandler( strEventName,sender )
    local limitCoinLen = 9
    -- body
    if strEventName == "began" then
    elseif strEventName == "ended" then
    elseif strEventName == "return" then
        if sender:getName() == "coinNum" then
            --self.editCoinNum = sender:getText()
            --过滤掉中文等闲杂字符
            if tonumber(sender:getText()) == nil then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_show_10})
                sender:setText("")
                self.editCoinNum = ""
                return
            end
            local intNum = math.floor(tonumber(sender:getText()))
            self.editCoinNum = math.abs(intNum)
            sender:setText(math.abs(intNum))
        end
        --更新flag标记
        for k, v in ipairs(self.coinNumTable) do
            v:getChildByName("Image_86"):setVisible(false)
        end                                     
    elseif strEventName == "changed" then
        if sender:getName() == "coinNum" then
            local num = sender:getText()
            if string.len(num) > limitCoinLen and tonumber(num) ~= nil then
                num = string.sub(num, 1, limitCoinLen)
                sender:setText(num)
            end
        end

    end
end

--[[退出键]]
function ShopView:backHandler()
    self:close()
end

function ShopView:close()
    self.super.close(self)
    if ModuleManager.shop then
        ModuleManager.shop.view = nil
    end
end

--刷新当前的页面
function ShopView:refreshView()
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
    local chargeId = self._chargeId
    local queryInfo
    queryInfo = function ( ... )
        if tolua.isnull(self) == true then
            return
        end
        Cache.Config.shopConfig = nil
        self:setPayOrder(Cache.Config.shopConfig)
        local body = {}
        body.uin = Cache.user.uin
        GameNet:send({cmd=CMD.GET_EXCHANGE_CONFIG,body=body,timeout=nil,callback=function(rsp)
            if self and tolua.isnull(self) == false then
                if rsp.ret == NET_WORK_ERROR.TIMEOUT then
                    Util:delayRun(0.5, function ( ... )
                        queryInfo()
                    end)
                else
                    self:saveAllConfig(rsp)
                    -- local idx = table.indexof(self.orderList, chargeId) 
                    self:clickTabButton(self._btnList[chargeId])
                end
            end
        end})
    end
    queryInfo()
end

function ShopView:saveAllConfig(rsp)
    loga("ShopView:init rsp "..rsp.ret)
    if self and tolua.isnull(self) == true then
        return
    end
    if rsp.ret ~= 0 then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_show_1})
        self:backHandler()
    else
        if tolua.isnull(self) == true then
            return 
        end
        self.allConfig = {}
        if rsp.model and rsp.model['source'] then
            self.allConfig.paySource = rsp.model['source']
        end
        for i = 1, rsp.model.recharge_list:len() do
            local item = rsp.model.recharge_list:get(i)
            local configItem = {}
            configItem.recharge_id = item.recharge_id                 --充值方式 1 银行卡  2支付宝  3微信  4其他
            configItem.recharge_valid = item.recharge_valid           --当前支付是否可用 1 可用 0不可用

            configItem.max_recharge_money = item.max_recharge_money --最大充值金额  0为不限制
            configItem.min_recharge_money = item.min_recharge_money --最低充值金额

            configItem.index_id = item.index_id
            configItem.notice_word = item.notice_word
            configItem.pay_channel = item.pay_channel
            configItem.quick_list = {}                             --快捷输入列表

            configItem.showAnyNumFlag = true
            if item.fixed_amounts:len() > 0 then
                configItem.showAnyNumFlag = false
            end

            --epay
            for j = 1, item.fixed_amounts:len() do
                table.insert(configItem.quick_list, item.fixed_amounts:get(j))
            end
            
            --pn、epay都会使用
            for j = 1, item.quick_list:len() do
                table.insert(configItem.quick_list, item.quick_list:get(j))
            end
            configItem.recharge_word = item.recharge_word
            configItem.url = item.url

            --自己不是代理 且绑定了代理的情况下  才显示专属充值
            if configItem.recharge_id == 7 then
                if (not Cache.user:isProxy()) and Cache.agencyInfo:checkBindAgency() then
                    table.insert(self.allConfig, configItem)
                end
            else
                table.insert(self.allConfig, configItem)
            end
        end

        self:setPayOrder(self.allConfig)
        if #self.allConfig == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_show_12})
            self:backHandler()
            return
        end
        
        Cache.Config.shopConfig = self.allConfig
        local idx = self.orderList[1]
        self:clickTabButton(self._btnList[idx])
        self:showRecommendIcon(self._btnList[idx])
    end
end

return ShopView