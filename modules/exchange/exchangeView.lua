local ExchangeView = class("ExchangeView", CommonWidget.PopupWindow)

ExchangeView.TAG = "ExchangeView"

local BANK_VIEW ={
    ACT = 1,
    BIND = 2,
    NONE = 3
}

function ExchangeView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.exchange)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.exchange, child=self.root})
end

function ExchangeView:init( ... )

    local uiTbl = {
        {name = "bg",            path = "Panel_frame",     handler = handler(self, self.onButtonEvent)},
        {name = "panelTab",            path = "Panel_frame/Panel_tab"},
        {name = "panelBank",            path = "Panel_frame/Panel_bankercard"},
        {name = "panelAlipay",            path = "Panel_frame/Panel_alipay"},
        
        {name = "btnClose",            path = "Panel_frame/Button_close",     handler = handler(self, self.onButtonEvent)},


        {name = "ruleBtn",            path = "Panel_frame/Panel_tab/Panel_rule",      handler = handler(self, self.onButtonEvent)},
        {name = "bankBtn",            path = "Panel_frame/Panel_tab/Button_bankercard",      handler = handler(self, self.onButtonEvent)},
        {name = "aliBtn",            path = "Panel_frame/Panel_tab/Button_alipay",      handler = handler(self, self.onButtonEvent)},
        {name = "customBtn",            path = "Panel_frame/Panel_tab/Panel_custom",      handler = handler(self, self.onButtonEvent)},
        {name = "hongbaoBtn",            path = "Panel_frame/Panel_tab/hongbao",      handler = handler(self, self.onButtonEvent)},


        {name = "restGold",            path = "Panel_frame/Panel_bankercard/Label_gold",      handler = handler(self, self.onButtonEvent)},
        {name = "bankActPanel",            path = "Panel_frame/Panel_bankercard/Panel_action",      handler = handler(self, self.onButtonEvent)},
        {name = "bankbindPanel",            path = "Panel_frame/Panel_bankercard/Panel_no_action",      handler = handler(self, self.onButtonEvent)},
        {name = "bankNoPanel",            path = "Panel_frame/Panel_bankercard/Panel_no_action2",      handler = handler(self, self.onButtonEvent)},

        {name = "getMoneyBtn",            path = "Panel_frame/Panel_bankercard/Panel_action/Button_request",      handler = handler(self, self.onButtonEvent)},
        {name = "findPwdBtn",            path = "Panel_frame/Panel_bankercard/Panel_action/Button_find_pwd",      handler = handler(self, self.onButtonEvent)},
        {name = "manageAccBtn",            path = "Panel_frame/Panel_bankercard/Panel_action/Button_account_list",      handler = handler(self, self.onButtonEvent)},
        {name = "accoutBtn",            path = "Panel_frame/Panel_bankercard/Panel_action/Button_account",      handler = handler(self, self.onButtonEvent)},
        {name = "bindBtn",            path = "Panel_frame/Panel_bankercard/Panel_no_action/Button_request_1",      handler = handler(self, self.onButtonEvent)},



        {name = "rule",            path = "Panel_rule_frame"},
        {name = "ruleTxt",            path = "Panel_rule_frame/Panel_info/Label_23"},
        {name = "ruleCloseBtn",            path = "Panel_rule_frame/Button_close",     handler = handler(self, self.onButtonEvent)}
    }


    Util:bindUI(self, self.root, uiTbl)
    Util:enlargeCloseBtnClickArea(self.btnClose)
    Util:enlargeCloseBtnClickArea(self.ruleCloseBtn)

    self.restGold:setVisible(true)

    self.btnX = self.bankBtn:getPositionX()
    self.tabBtnList = {self.bankBtn}
    self.tabPanelList = {self.panelBank}
    self.panelBankList = {self.bankActPanel, self.bankbindPanel}
    self:initBankCardPanel()
    self:initHongBaoAni()
    self:getBankConfig()
    self:clickTabButton(self.bankBtn)
    qf.event:addEvent(ET.FRESH_CARD_LIST,handler(self,self.freshCardList))
end

function ExchangeView:showBankDetail(bankNo)
    for i, v in ipairs(self.panelBankList) do
        v:setVisible(false)
    end
    self.panelBankList[bankNo]:setVisible(true)
    if bankNo == BANK_VIEW.BIND then
        self.panelBankList[bankNo]:getChildByName("Button_request_1"):setVisible(true)
        self.panelBankList[bankNo]:getChildByName("Label_1"):setString(GameTxt.no_band_bank_card)
    end
end

function ExchangeView:clickTabButton(sender)
    if sender.name == "bankBtn" then
        self:updateTab(1)
    -- elseif sender.name == "aliBtn" then
    --     self:updateTab(2)
    -- elseif sender.name == "recordBtn" then
    --     self:updateTab(3)
    end
end

function ExchangeView:goBindFunc( ... )
   
    if Cache.user:isBindPhone() then
        if Cache.user.safe_password == 0 then
            self:close()
            qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 5})
            return
        end
    else
        self:close()
        qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 4})
        return
    end

    local function callfunc( ... )
        self.bg:setVisible(not self.bg:isVisible())
        self:updateBankPanel()
    end
    qf.event:dispatchEvent(ET.BIND_CARD,{cb = callfunc, showType = 2})
end

function ExchangeView:getMoneyFunc()
    local actCoin = ccui.Helper:seekWidgetByName(self.panelBank,"Label_exchange_gold") --可提现金币
    --判断提现金额是否在最大和最小范围内
    if self.editCoinNum == nil then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_1})           
        return 
    end
    if tonumber(self.editCoinNum) < self.minExchangeCoin then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_4..self.minExchangeCoin..GameTxt.string_exchange_5})
        return
    end 
    if self.maxExchangeCoin > 0 and tonumber(self.editCoinNum) > self.maxExchangeCoin then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_6..self.maxExchangeCoin..GameTxt.string_exchange_5})
        return
    end 

    local curCoin =  Cache.packetInfo:getCProMoney(self.can_withdraw_money)--tonumber(actCoin:getString()) * 100

    if self:checkSatisfyCond(self.can_withdraw_money, self.editCoinNum) then
        return
    end

    if self.editBoxPay:getText() == nil or self.editBoxPay:getText() == "" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_4})
        return
    end


    local body = {}
    body.uin = Cache.user.uin
    body.withdraw_type = 1 --提现方式，银行卡
    body.account = self.curBankAccount--银行卡号
    body.withdraw_money = tonumber(self.editCoinNum)
    body.safe_password = self.payPwd
    GameNet:send({cmd=CMD.REQ_EXCHANGE,body=body,timeout=nil,callback=function(rsp)
        loga("exchange rsp "..rsp.ret)
        if rsp.ret ~= 0 then
            if rsp.ret == 2014 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_7})
                return
            elseif rsp.ret == 1049 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_12})
                return
            end
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret] or GameTxt.string_exchange_8})
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_9})
            local handCoin = Cache.user.gold - self.editCoinNum
            local curCoin = ccui.Helper:seekWidgetByName(self.panelBank,"Label_gold") --持有金币
            curCoin:setVisible(true)
            local callback = function(m)
                --回调之前已经刷新了gold
                if not curCoin or tolua.isnull(curCoin) then
                    return
                end
                self.restGold:setVisible(true)
                self.restGold:setString(GameTxt.exchange_txt_1 .. Util:getFormatString(Cache.user.gold).. Cache.packetInfo:getShowUnit())
            end
            qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin, callback = callback })

            self:freshLimit()
        end
    end})
end

function ExchangeView:onButtonEvent(sender)
    if sender.name == "btnClose" then
        self:close()
    elseif sender.name == "ruleCloseBtn" then
        self.bg:setVisible(true)
        self.rule:setVisible(false)
    elseif sender.name == "hongbaoBtn" then
        self.bg:setVisible(false)
        self.rule:setVisible(true)
        -- self.ruleTxt:setString(string.format(GameTxt.string_exchange_16, self:getMinExhcnageMoney()))
    elseif sender.name == "bankBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "aliBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "recordBtn" then
        self:clickTabButton(sender)
    elseif sender.name == "customBtn" then
        self:close()
        qf.event:dispatchEvent(ET.CUSTOM_CHAT,{forceLinkType = GameConstants.ChatUserType.OFFICIAL})
    elseif sender.name == "bindBtn" then
        self:goBindFunc()
    elseif sender.name == "getMoneyBtn" then
        self:getMoneyFunc()
    elseif sender.name == "findPwdBtn" then
        self:showFindPwd()
    elseif sender.name == "manageAccBtn" then
        self:showBindCard()
    elseif sender.name == "accoutBtn" then
        if self.cardlist then
            self.cardlist:setVisible(true)
        end
    else
        if sender.name then
            logd(string.format("%s not bind clickistener", sender.name))
        end
    end
end

function ExchangeView:initWithRootFromJson()
    return GameRes.exchange
end

function ExchangeView:isAdaptateiPhoneX()
    return true
end

--1 银行 2 支付宝 3 微信
function ExchangeView:setPayOrder(config)
    local order
    if config ~= nil then
        order = {}
        --确保index_id  即使不按照1到n来排列 只要有大小顺序即可 即使相等也可
        local tempOrderTbl = {}
        for i, v in ipairs(config) do
            tempOrderTbl[#tempOrderTbl + 1] = { index = v.index_id, style = i}
        end
        table.sort(tempOrderTbl, function (a, b)
            return a.index < b.index
        end)
        for i, v in ipairs(tempOrderTbl) do
            order[v.style] = i
        end
    end
    order = order or {1, 2}
    local bankBtn = ccui.Helper:seekWidgetByName(self.root, "Button_bankercard")
    -- local aliBtn = ccui.Helper:seekWidgetByName(self.root, "Button_alipay")
    local retBtn = ccui.Helper:seekWidgetByName(self.root, "Button_exchange_record")

    if self._posYList == nil then
        local posYList = {}
        posYList[#posYList + 1] = bankBtn:getPositionY()
        -- posYList[#posYList + 1] = aliBtn:getPositionY()
        table.sort(posYList, function (a, b)
            return a > b
        end)
        self._posYList = posYList
    end

    local btnList = {
        bankBtn
    }

    for i, v in ipairs(order) do
        btnList[i]:setPositionY(self._posYList[v])
    end
    self.orderList = order
    self:updateTab(self.orderList[1])
end

function ExchangeView:getBankConfig()
    if Cache.Config.exchangeConfig ~= nil then
        self.globalConfig = self:getCache("globalConfig")
        self.bankList =  self:getCache("bankList")
        self:setPayOrder(self.globalConfig)
    end

    local body = {}
    body.uin = Cache.user.uin
    GameNet:send({cmd=CMD.GET_EXCHANGE_CONFIG,body=body,timeout=nil,callback=function(rsp)
        loga("initBankCardPanel rsp "..rsp.ret)
        if rsp.ret ~= 0 then
        else
            if self.restGold then
                self.restGold:setVisible(true)
                self.restGold:setString(GameTxt.exchange_txt_1 .. Util:getFormatString(Cache.user.gold) .. Cache.packetInfo:getShowUnit())
            end
            self.can_withdraw_money = Cache.user.gold - Cache.packetInfo:getProMoney(rsp.model.can_withdraw_money)
            self.globalConfig = {}
            for i = 1, rsp.model.withdraw_list:len() do
                local modelItem = rsp.model.withdraw_list:get(i)
                local item = {}
                item.recharge_id = modelItem.recharge_id         --提现方式 1 银行卡  2支付宝 
                item.recharge_valid = modelItem.recharge_valid      --当前提现是否可用 1 可用 0不可用
                item.max_recharge_money = modelItem.max_recharge_money --最大提现金额  0为不限制
                item.min_recharge_money = modelItem.min_recharge_money --最低提现金额
                item.index_id = modelItem.index_id
                item.notice_word = modelItem.notice_word
                item.rechange_word = modelItem.recharge_word
                item.quick_list = {}          -- 快捷输入列表
                for j = 1, modelItem.quick_list:len() do
                    local subItem = modelItem.quick_list:get(j)
                    item.quick_list[j] = subItem
                end
                table.insert(self.globalConfig, item)
            end
            --按照最低提现金额牌下续吧
            table.sort(self.globalConfig, function (a,b)
                return tonumber(a.min_recharge_money) < tonumber(b.min_recharge_money)
            end)
            self:setPayOrder(self.globalConfig)
            self.bankList = {}
            for i = 1, rsp.model.bank_list:len() do
                local modelItem = rsp.model.bank_list:get(i)
                local item = {}
                item.bank_id = modelItem.bank_id
                item.bank_name = modelItem.bank_name
                table.insert(self.bankList, item)
            end
            self:setCache("globalConfig", self.globalConfig)
            self:setCache("bankList", self.bankList)
        end
    end})
end

--获取所有提现渠道的最小提现金额
function ExchangeView:getMinExhcnageMoney( ... )
    dump(self.globalConfig)
    if self.globalConfig then
        return tonumber(self.globalConfig[1].min_recharge_money)
    end
    --服务器也是默认到100
    return 100
end


--银行卡分页
function ExchangeView:initBankCardPanel()
    Display:closeTouch(self)
    --提现金额
    local imageSetFrame = ccui.Helper:seekWidgetByName(self.bankActPanel,"Image_coin_frame")
    self.depositEdit = Util:createEditBox(imageSetFrame, {
        iSize = cc.size(730, 80),
        tag = -987654,
        fontcolor = cc.c3b(0, 0, 0),
        fontname = GameRes.font1,
        name = "coinNum",
        fontsize = 40,
        placeFontsize = 36,
        placeTxt = GameTxt.string_exchange_15, --默认的输入框提示，后面获取到数据后再更新
        holdColor = cc.c3b(204, 204, 204),
        handler = handler(self, self.editboxEventHandler), 
        retType = cc.KEYBOARD_RETURNTYPE_DONE,
        iMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    })

    local imageSetFrame = ccui.Helper:seekWidgetByName(self.bankActPanel,"Image_pay_pwd")
    self.editBoxPay = Util:createEditBox(imageSetFrame, {
        iSize = cc.size(572, 80),
        tag = -987654,
        fontcolor = cc.c3b(0, 0, 0),
        fontname = GameRes.font1,
        name = "payFrame",
        fontsize = 40,
        placeFontsize = 36,
        placeTxt = GameTxt.string_safebox_4,
        holdColor = cc.c3b(204, 204, 204),
        handler = handler(self, self.editboxEventHandler), 
        retType = cc.KEYBOARD_RETURNTYPE_DONE,
        iMode = cc.EDITBOX_INPUT_MODE_NUMERIC
    })
end


-- self.can_withdraw_money, self.editCoinNum
function ExchangeView:checkSatisfyCond(leastMoney, costMoney)
    local usergold = Cache.packetInfo:getCProMoney(Cache.user.gold) --当前自己手上的金额
    local curCoin = Cache.packetInfo:getCProMoney(leastMoney)--至少留多少金币在手上
    local editCoinNum = Cache.packetInfo:getCProMoney(tonumber(costMoney)) --需要消耗的金币
    --可提现金币 如果
    if tonumber(costMoney) ~= nil and usergold - editCoinNum  < curCoin then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.limitLeastMoneyTip, leastMoney)})
        return true      
    end
    return false
end

function ExchangeView:initHongBaoAni( ... )
    local hongbao = self.hongbaoBtn
    local s1 = cc.ScaleTo:create(0.2, 0.8)
    local s2 = cc.ScaleTo:create(0.2, 1.0)
    local r1= cc.RotateBy:create(0.1, 10)
    local r2= cc.RotateBy:create(0.1, -10)
    local r3= cc.RotateBy:create(0.1, -10)
    local r4= cc.RotateBy:create(0.1, 10)
    local sqs = cc.Sequence:create(s1,s2,r1,r2,r3,r4)
    hongbao:runAction(cc.RepeatForever:create(sqs))
end

function ExchangeView:refreshNoAction(chargeInfo)
    if chargeInfo and chargeInfo.notice_word then
        local noActionPanel = ccui.Helper:seekWidgetByName(self.root,"Panel_no_action")
        noActionPanel:getChildByName("Label_1"):setString(chargeInfo.notice_word)
        noActionPanel:getChildByName("Button_request_1"):setVisible(false)
        noActionPanel:getChildByName("Image_156"):setVisible(false)
    end
end

function ExchangeView:showBankPanel()
    -- body
    if self.globalConfig == nil or  self.globalConfig[1] == nil then
        return
    end

    --银行卡关闭
    if self.globalConfig[1].recharge_valid == 2 then
        self:showBankDetail(BANK_VIEW.NONE)
        self:initNoAction(self.bankNoPanel, self.globalConfig[1].notice_word)
        return
    end


    --未绑定银行卡
    if #self.savedBankList == 0 then
        self:showBankDetail(BANK_VIEW.BIND)
        return
    end
    
    self:showBankDetail(BANK_VIEW.ACT)
    --绑定了银行卡
    if #self.savedBankList > 0 then
        self.curBankAccount = self.savedBankList[1].bank_num
    end
    
    --可选账号列表
    if self.cardlist then
        self.cardlist:removeFromParent()
    end

    local chooseFlag = self.accoutBtn:getChildByName("Image_86")
    if #self.savedBankList > 0 then
        chooseFlag:setVisible(true)
        local btnAccount = ccui.Helper:seekWidgetByName(actionPanel,"Button_account")
        self.accoutBtn:getChildByName("Label_desc"):setString(self.savedBankList[1].bank_name.." "..string.sub(tostring(self.savedBankList[1].bank_num), 1, 4).."***")
        self.cardlist = CommonWidget.ComboList.new(#self.savedBankList, #self.savedBankList, cc.size(560, 80), GameRes.image_item_normal, GameRes.image_item_select)
        if self.cardlist then
            self.cardlist:setPosition(cc.p(0, 0))
            local pos = cc.p(1136, 615)
            self.cardlist:setListPostion(pos)--(cc.p(imagePhoneFrame:getPositionX(), imagePhoneFrame:getPositionY()))
            self.cardlist:setName("cardlist")
            self.cardlist:setVisible(false)
            self.cardlist:setAutoHide("hide")
            self.root:addChild(self.cardlist)
            for i = 1, #self.savedBankList do
                local item = self.cardlist:getItemByIndex(i)
                item:setTitleText(self.savedBankList[i].bank_name.."  "..string.sub(tostring(self.savedBankList[i].bank_num), 1, 4).."****"..string.sub(tostring(self.savedBankList[i].bank_num), -3, -1))
                addButtonEvent(item,function (sender)
                    --qf.event:dispatchEvent(ET.SEARCH_PAY_RECORD,{payType = i})
                    -- print()
                    dump(self.savedBankList)
                    print(ccui.Helper:seekWidgetByName(btnAccount,"Label_desc"))
                    self.accoutBtn:getChildByName("Label_desc"):setString(self.savedBankList[i].bank_name.." "..string.sub(tostring(self.savedBankList[i].bank_num), 1, 4).."***")
                    self.curBankAccount = self.savedBankList[i].bank_num
                    self.cardlist:setVisible(false)
                end)
            end
        end
    else
        chooseFlag:setVisible(false)
    end

    --最低提现
    self.minExchangeCoin = self.globalConfig[1].min_recharge_money
    self.maxExchangeCoin = self.globalConfig[1].max_recharge_money
    self.depositEdit:setPlaceHolder(string.format(GameTxt.exchangePlaceTxt, self.minExchangeCoin))
end

function ExchangeView:updateBankPanel( ... )

    if Cache.user:isBindPhone() == false then
        self:showBankDetail(BANK_VIEW.BIND)        
        return
    end

    if Cache.user:isBindPhone() and Cache.user.safe_password == 0 then
        self:showBankDetail(BANK_VIEW.BIND)
        return
    end

    self.savedBankList = self:getCache("savedBankList")
    if self.savedBankList then
        self:showBankPanel()
    end
    -- body
    local body = {}
    body.uin = Cache.user.uin
    body.bind_type = 1 --1 = 银行卡
    GameNet:send({cmd=CMD.GET_BINDING_CONFIG,body=body,timeout=nil,callback=function(rsp)
        loga("updateBankPanel rsp "..rsp.ret)
        if rsp.ret ~= 0 then
            logd("get binding error", rsp.ret)
        else
            if tolua.isnull(self) == false then
                self.savedBankList = {}--绑定银行卡信息
                for i = 1, rsp.model.bank_list:len() do
                    local modelItem = rsp.model.bank_list:get(i)
                    local item = {}
                    item.bank_num = modelItem.bank_num
                    item.bank_name = modelItem.bank_name
                    if not Util:checkOnlyDigitAndLetter(item.bank_num) then --是否含有中文 有中文字符说明有问题 则替换为此种显示方式
                        item.bank_num = "0000000000000000"
                    end
                    table.insert(self.savedBankList, item)
                end
                self:setCache("savedBankList", self.savedBankList)
                self:showBankPanel()
            end
        end
    end})
end

function ExchangeView:updateAlipayPanel( ... )
    -- body
    --待定 支付宝
    local body = {}
    body.uin = Cache.user.uin
    body.bind_type = 2 --2 = 支付宝
    GameNet:send({cmd=CMD.GET_BINDING_CONFIG,body=body,timeout=nil,callback=function(rsp)
        loga("updateAlipayPanel rsp "..rsp.ret)
        if rsp.ret ~= 0 then
        else
            if tolua.isnull(self) == true then
                return
            end
            local actionPanel = ccui.Helper:seekWidgetByName(self.panelAlipay,"Panel_action")
            local noActionPanel = ccui.Helper:seekWidgetByName(self.panelAlipay,"Panel_no_action")
            self:initNoAction(noActionPanel, GameTxt.string_exchange_14)
            if rsp.model.alipay_flag == 2 then --关闭
                noActionPanel:setVisible(true)
                actionPanel:setVisible(false)
            end
        end
    end})
end

function ExchangeView:initNoAction(panel, txt)
    panel:getChildByName("Label_1"):setVisible(false)
    if panel:getChildByName("rText") then
        panel:removeChildByName("rText")
    end

    local rText = Util:createRichText({size = cc.size(470,300), vspace = 10})
    panel:addChild(rText)
    rText:setName("rText")
    local normalColor = cc.c3b(102, 147, 225)
    local richDesc = {
        {desc = txt, color = normalColor}
    }

    for i, v in ipairs(richDesc) do
        local color = v.color
        local desc = v.desc
        local txt = ccui.RichElementText:create(1, color, 255, desc, GameRes.font1, 38)
        rText:pushBackElement(txt)
    end
    rText:setPosition(cc.p(483, 165))
end

function ExchangeView:updateRecordPanel( index, page )
    local stateStr = {
        [30] = GameTxt.string_exchange_10,
        [50] = GameTxt.string_exchange_11,
        [60] = GameTxt.string_exchange_9, 
        [70] = GameTxt.string_exchange_8
    }
    -- body
    local panelList = ccui.Helper:seekWidgetByName(self.panelRecord,"ListView_info")
    ccui.Helper:seekWidgetByName(self.panelRecord,"Panel_item"):setVisible(false)
    panelList:setItemModel(ccui.Helper:seekWidgetByName(self.panelRecord,"Panel_item"))
    panelList:removeAllItems()
    index = index or 1
    page = page or 0

    local body = {}
    body.uin = Cache.user.uin
    body.ope_time = index
    body.page_index = page
    body.query_type = 2 -- 1= 充值， 2 = 提现
    dump(body)
    GameNet:send({cmd=CMD.PAY_RECORD,body=body,timeout=nil,callback=function(rsp)
        loga("get pay type list rsp "..rsp.ret.." recharge_list = "..rsp.model.recharge_list:len())
        if rsp.ret == 0 then
            --没有数据隐藏列表
            if rsp.model.recharge_list:len() == 0 then
                panelList:setVisible(false)
            else
                panelList:setVisible(true)
            end

            for i = 1, rsp.model.recharge_list:len() do
                panelList:pushBackDefaultItem()
                local itemCount = #panelList:getItems()
                local curItem = panelList:getItem(itemCount - 1)
                curItem:setVisible(true)
                local item = {}
                local pbItem = rsp.model.recharge_list:get(i)
                loga(pb.tostring(pbItem))
                item.recharge_time = os.date("%m-%d %H:%M", tonumber(pbItem.recharge_time))     --提现时间
                --dump(item.recharge_time)
                item.money = pbItem.money      --金额
                item.state = pbItem.state      --状态
                --item.account = pbItem.account  --账号
                item.account = string.sub(tostring(pbItem.account), 1, 4).."****"..string.sub(tostring(pbItem.account), -3, -1)

                --更新控件
                --if i < 5 then
                    --local itemList = ccui.Helper:seekWidgetByName(curItem,"Panel_item"..i)
                    ccui.Helper:seekWidgetByName(curItem,"Label_time"):setString(item.recharge_time)
                    ccui.Helper:seekWidgetByName(curItem,"Label_coin"):setString(Util:getFormatString(item.money))
                    ccui.Helper:seekWidgetByName(curItem,"Label_state"):setString(stateStr[tonumber(item.state)])
                    --三种状态变色
                    if tonumber(item.state) == 50 then
                        ccui.Helper:seekWidgetByName(curItem,"Label_state"):setColor(cc.c3b(231,209,153)) 
                    elseif tonumber(item.state) == 60 then
                        ccui.Helper:seekWidgetByName(curItem,"Label_state"):setColor(cc.c3b(84,175,63)) 
                    elseif tonumber(item.state) == 70 then
                        ccui.Helper:seekWidgetByName(curItem,"Label_state"):setColor(cc.c3b(255,73,73)) 
                    end
                    ccui.Helper:seekWidgetByName(curItem,"Label_account"):setString(item.account)
                --end
            end
        end
    end})
end

--找回密码页面
function ExchangeView:showFindPwd( ... )
    -- body
    --修改安全密码
    local function callfunc( ... )
        -- body
        self.bg:setVisible(not self.bg:isVisible())
    end
    qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 3})
end

--绑卡界面
function ExchangeView:showBindCard( ... )
    qf.event:dispatchEvent(ET.BIND_CARD, {showType = 1})
end

--刷新分页
function ExchangeView:updateTab( tab )
    local dx = 5
    local textureTbl = {
        {GameRes.exchange_4, GameRes.exchange_1},
        {GameRes.exchange_2, GameRes.exchange_5},
        {GameRes.exchange_3, GameRes.exchange_6}
    }
    local funcTbl = {
        handler(self, self.updateBankPanel),
        handler(self, self.updateAlipayPanel),
        handler(self, self.updateRecordPanel)
    }
    for i, v in ipairs(self.tabBtnList) do
        v:setPositionX(self.btnX)
        v:setEnabled(true)
        v:setBright(true)
        ccui.Helper:seekWidgetByName(v,"Image_title"):loadTexture(textureTbl[i][1])
    end
    local tBtn = self.tabBtnList[tab]
    tBtn:setEnabled(false)
    tBtn:setBright(false)
    tBtn:setPositionX(self.btnX + dx)
    ccui.Helper:seekWidgetByName(tBtn,"Image_title"):loadTexture(textureTbl[tab][2])

    for i,v in ipairs(self.tabPanelList) do
        v:setVisible(false)
    end

    self.tabPanelList[tab]:setVisible(true)
    funcTbl[tab]()
end

function ExchangeView:editboxEventHandler( strEventName,sender )
    -- body
    if strEventName == "began" then
        --sender:setText("")  
        if sender:getName() == "coinNum" then
            self.editCoinNum = "" 
        elseif sender:getName() == "payFrame" then    
            self.payPwd = ""   
        end
    elseif strEventName == "ended" then
    elseif strEventName == "return" then
        if sender:getName() == "coinNum" then
            if tonumber(sender:getText()) == nil then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_13})
                return
            end
            local intNum = math.floor(sender:getText())
            self.editCoinNum = math.abs(intNum)
            sender:setText(math.abs(intNum))
            --检测最低提现金额
            if self.editCoinNum <  self.minExchangeCoin then
                self.editCoinNum = 0
                sender:setText("")
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.exchangePlaceTxt, "" .. self.minExchangeCoin)})                
                return
            end

            if self:checkSatisfyCond(self.can_withdraw_money, self.editCoinNum) then
                self.editCoinNum = 0
                sender:setText("")
            end
        elseif sender:getName() == "payFrame" then    
            self.payPwd = sender:getText()   
        end                              
        if sender:getText() ~= "" then
            --更新flag标记
            -- for k, v in ipairs(self.coinNumTable) do
            --     v:getChildByName("Image_86"):setVisible(false)
            -- end
        end
    elseif strEventName == "changed" then
                 
    end
end

function ExchangeView:freshLimit( ... )
    -- body
    GameNet:send({cmd=CMD.GET_EXCHANGE_CONFIG,body=body,timeout=nil,callback=function(rsp)
        loga("initBankCardPanel rsp "..rsp.ret)
        if rsp.ret ~= 0 then
        else
            self.minExchangeCoin = self.globalConfig[1].min_recharge_money
            self.maxExchangeCoin = self.globalConfig[1].max_recharge_money
            for i = 1, rsp.model.withdraw_list:len() do
                local modelItem = rsp.model.withdraw_list:get(i)
                self.maxExchangeCoin = modelItem.max_recharge_money --最大提现金额  0为不限制
                self.minExchangeCoin = modelItem.min_recharge_money --最低提现金额
            end
            local actionPanel = ccui.Helper:seekWidgetByName(self.panelBank,"Panel_action")
            ccui.Helper:seekWidgetByName(actionPanel,"Button_request"):setEnabled(true)
        end
    end})
end

function ExchangeView:freshCardList( params )
    -- body
    self:updateBankPanel()
end

function ExchangeView:getRoot() 
    return LayerManager.PopupLayer
end

function ExchangeView:setCache(key, value)
    if Cache.Config.exchangeConfig == nil then
        Cache.Config.exchangeConfig = {}
    end
    Cache.Config.exchangeConfig[key] = value
end

function ExchangeView:getCache(key)
    if Cache.Config.exchangeConfig == nil then
        return nil
    end
    return Cache.Config.exchangeConfig[key]
end

return ExchangeView