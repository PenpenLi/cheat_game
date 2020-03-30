--local SafeBoxView = class("SafeBoxView", qf.view)
local SafeBoxView = class("SafeBoxView", CommonWidget.PopupWindow)

SafeBoxView.TAG = "SafeBoxView"

function SafeBoxView:ctor(parameters)
    --self.super.ctor(self,parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.safeBox)
    self._parameters = parameters
    self:init(parameters)

    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.safeBox, child=self.root})
end

function SafeBoxView:initWithRootFromJson()
    return GameRes.safeBox
end

function SafeBoxView:isAdaptateiPhoneX()
    return true
end

local function setButtonBirghtAndEnabled(btn, enabled)
    btn:setEnabled(enabled)
    btn:setBright(enabled)
    if enabled then
        btn:setPositionX(btn.xpos)
    else
        btn:setPositionX(btn.xpos + 5)
    end
end

function SafeBoxView:init()
    -- body
    local body = {}
    self.bg = ccui.Helper:seekWidgetByName(self.root,"Panel_box")

    self:initNecessaryUI()

    GameNet:send({cmd=CMD.SAFE_QUERY_MONEY,body=body,timeout=nil,callback=function(rsp)
        loga("reqResetPwd rsp "..rsp.ret)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else
            loga("safe rsp.model.ret "..rsp.model.ret)
            if rsp.model.ret == 0 then
                if tolua.isnull(self) == false then
                    Cache.user:updateSafeBoxConfig(rsp.model)
                    self:initUI()
                    self.reqBtn:setVisible(true)
                    self:updateButton()
                    self:btnNumCall()
                end
            end
        end
    end})

    -- qf.platform:umengStatistics({umeng_key = "SafeBox"})
end

function SafeBoxView:initNecessaryUI()
    --关闭按钮
    local uiTbl = {
        {name = "closeBtn",            path = "Panel_box/Button_close",     handler = handler(self, self.onButtonEvent)},
        {name = "saveButton",            path = "Panel_box/Panel_tab/Button_in", handler = handler(self, self.onButtonEvent)},
        {name = "curButton",            path = "Panel_box/Panel_tab/Button_out", handler = handler(self, self.onButtonEvent)},

        {name = "infoPanel",            path = "Panel_box/Panel_info"},
        {name = "saveCoin",            path = "Panel_box/Panel_info/Label_saved_coin"},
        {name = "curCoin",            path = "Panel_box/Panel_info/Label_cur_coin"},
        {name = "actPanel",            path = "Panel_box/Panel_info/Panel_action"},
        {name = "coinWarning",            path = "Panel_box/Panel_info/Label_coin_warning"},

        {name = "clearBtn",            path = "Panel_box/Panel_info/Panel_action/Button_clear", handler = handler(self, self.onButtonEvent)},
        {name = "reqBtn",            path = "Panel_box/Panel_info/Panel_action/Button_request", handler = handler(self, self.onButtonEvent)},
        {name = "findPwdBtn",            path = "Panel_box/Panel_info/Panel_action/Button_find_pwd", handler = handler(self, self.onButtonEvent)},
        {name = "pwdFrame",            path = "Panel_box/Panel_info/Panel_action/Image_pay_pwd"},        
        {name = "coinFrame",            path = "Panel_box/Panel_info/Panel_action/Image_coin_frame"},
        {name = "smallTitle",            path = "Panel_box/Panel_info/Panel_action/Image_in_out"},
    }

    Util:bindUI(self, self.root, uiTbl)
    Util:enlargeCloseBtnClickArea(self.closeBtn,  handler(self, self.onButtonEvent))
    Util:addButtonScaleAnimFunc(self.reqBtn,  handler(self, self.onButtonEvent), 1.2)
    self:initEditBox()--初始化输入框
    self:initButton()
    self.saveButton.xpos = self.saveButton:getPositionX()
    self.curButton.xpos = self.curButton:getPositionX()
    self:clickTabButton(self.saveButton)
    self.reqBtn:setVisible(false)
    -- if ModuleManager:judegeIsIngame() then
    dump(self._parameters)
    
    if self._parameters and self._parameters.inGame then
        self.saveButton:setVisible(false)
        self.curButton:setPositionY(self.saveButton:getPositionY())
        self:clickTabButton(self.curButton)
    end
    Util:addButtonScaleAnimFuncWithDScale(self.curButton, handler(self, self.onButtonEvent))
    Util:addButtonScaleAnimFuncWithDScale(self.saveButton, handler(self, self.onButtonEvent))
end



function SafeBoxView:onButtonEvent(sender)
    if sender.name == "closeBtn" then
        self:close()
    elseif sender.name == "saveButton" then
        self:clickTabButton(sender)
    elseif sender.name == "curButton" then
        self:clickTabButton(sender)
    elseif sender.name == "clearBtn" then
        self.editBoxCoin:setText("")
        self.editCoinNum = ""
    elseif sender.name == "reqBtn" then
        self:doReqFunc()
    elseif sender.name == "findPwdBtn" then
        qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 3})
    else
        if sender.name then
            logd(string.format("%s not bind clickistener", sender.name))
        end
    end
end

function SafeBoxView:btnNumCall(sender)
    sender = sender or self["Button_5000"]
    local coinNum = string.sub(sender:getName(), 8, string.len(sender:getName()))
    if checknumber(coinNum) == 0 then
        if self.reqType == 2 then --取
            coinNum = math.floor(checknumber(Cache.user.safe_gold))
        else --存
            coinNum = math.floor(checknumber(Cache.user.free_gold))
        end
    end
    dump(sender:getName())
    if not Cache.packetInfo:isRealGold() and sender:getName() ~= "Button_MAX" then
        coinNum = Cache.packetInfo:getGoldByRealGod(coinNum)
    end
    self.editBoxCoin:setText(coinNum)
    self.editCoinNum = tonumber(coinNum)
    --更新flag标记
    for k, v in ipairs(self.coinNumTable) do
        print("vgaName", v:getName())
        print("vgaName", sender:getName())
        if v:getName() == sender:getName() then
            v:getChildByName("Image_86"):setVisible(true)
        else
            v:getChildByName("Image_86"):setVisible(false)
        end
    end
end

function SafeBoxView:clickTabButton(sender)
    self.coinWarning:setVisible(false)
    setButtonBirghtAndEnabled(self.saveButton, true)
    setButtonBirghtAndEnabled(self.curButton, true)

    self.editBoxCoin:setText("")
    self.editBoxPwd:setText("")
    self.editCoinNum = ""
    self.pwd = "" 


    if sender.name == "saveButton" then
        self.reqType = 1
        ccui.Helper:seekWidgetByName(self.saveButton,"Image_title"):loadTexture(GameRes.safeBox_deposit)
        ccui.Helper:seekWidgetByName(self.curButton,"Image_title"):loadTexture(GameRes.safeBox_fetch2)
        self.smallTitle:loadTexture(GameRes.safeBox_image_in3)
        self.editBoxCoin:setPlaceHolder(GameTxt.string_safebox_2)
    elseif sender.name == "curButton" then
        self.reqType = 2
        ccui.Helper:seekWidgetByName(self.saveButton,"Image_title"):loadTexture(GameRes.safeBox_deposit2)
        ccui.Helper:seekWidgetByName(self.curButton,"Image_title"):loadTexture(GameRes.safeBox_fetch)
        self.smallTitle:loadTexture(GameRes.safeBox_image_out3)
        self.editBoxCoin:setPlaceHolder(GameTxt.string_safebox_3)
    end
    self:btnNumCall()
    self:updateButton()
    setButtonBirghtAndEnabled(sender, false)
    local bVis = sender.name == "curButton"
    ccui.Helper:seekWidgetByName(self.actPanel,"Label_id_1_2_3"):setVisible(bVis)
    self.pwdFrame:setVisible(bVis)
    self.findPwdBtn:setVisible(bVis)
    if ModuleManager:judegeIsInChouMaArea() then
        Util:ensureBtn(self.reqBtn, self.reqType == 2)
    end
end

function SafeBoxView:initUI(param)
    local panelInfo = ccui.Helper:seekWidgetByName(self.bg,"Panel_info")
    local savedCoin = ccui.Helper:seekWidgetByName(panelInfo,"Label_saved_coin")
    self.restMoneyLabel = ccui.Helper:seekWidgetByName(panelInfo,"Label_id_0")

    savedCoin:setString(Util:getFormatString(Cache.user.safe_gold) .. Cache.packetInfo:getShowUnit())
    local curCoin = ccui.Helper:seekWidgetByName(panelInfo,"Label_cur_coin")
    curCoin:setString(Util:getFormatString(Cache.user.free_gold) .. Cache.packetInfo:getShowUnit())
    self.curCoin = curCoin
end

function SafeBoxView:initEditBox( ... )
    -- body
    local limitCoinLen = 11
    local limitPayLen = 6
    local function editboxEventHandler( strEventName,sender )
        -- body
        if strEventName == "began" then  
            if sender:getName() == "coinNum" then
                self.editCoinNum = "" 
            elseif sender:getName() == "payPwd" then    
                self.pwd = "" 
            end
        elseif strEventName == "ended" then
        elseif strEventName == "changed" then
            if sender:getName() == "coinNum" then
                local num = sender:getText()
                if string.len(num) > limitCoinLen and tonumber(num) ~= nil then
                    num = string.sub(num, 1, limitCoinLen)
                    sender:setText(num)
                end
            end


            if sender:getName() == "payPwd" then
                local num = sender:getText()
                if string.len(num) > limitPayLen and tonumber(num) ~= nil then
                    num = string.sub(num, 1, limitPayLen)
                    sender:setText(num)
                end
            end
        elseif strEventName == "return" then
            if sender:getName() == "coinNum" then
                --过滤掉中文等闲杂字符
                if tonumber(sender:getText()) == nil then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_1})
                    sender:setText("")
                    return
                end
                --输入数字过滤掉小数部分
                if tonumber(sender:getText()) then
                    local intNum = math.floor(tonumber(sender:getText()))
                    sender:setText(math.abs(intNum)) 
                end
                self.editCoinNum = sender:getText() 
                --更新flag标记
                for k, v in ipairs(self.coinNumTable) do
                    v:getChildByName("Image_86"):setVisible(false)
                end
            elseif sender:getName() == "payPwd" then    
                self.pwd = sender:getText() 
            end
        end
    end

    self.coinFrame:removeAllChildren()
    self.pwdFrame:removeAllChildren()
    --金额
    self.editBoxCoin = Util:createEditBox(self.coinFrame, {
        iSize = cc.size(730, 80),
        tag = -987654,
        fontcolor = cc.c3b(0, 0, 0),
        fontname = GameRes.font1,
        name = "coinNum",
        fontsize = 40,
        placeFontsize = 36,
        placeTxt = GameTxt.string_safebox_2,
        holdColor = cc.c3b(204, 204, 204),
        handler = editboxEventHandler, 
        retType = cc.KEYBOARD_RETURNTYPE_DONE,
        iMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
        posOffset = {x = 10, y = 0}
    })


    --安全密码
    self.editBoxPwd = Util:createEditBox(self.pwdFrame, {
        iSize = cc.size(560, 80),
        tag = -987654,
        fontcolor = cc.c3b(0, 0, 0),
        fontname = GameRes.font1,
        name = "payPwd",
        fontsize = 40,
        placeFontsize = 36,
        placeTxt = GameTxt.string_safebox_4,
        holdColor = cc.c3b(204, 204, 204),
        handler = editboxEventHandler, 
        retType = cc.KEYBOARD_RETURNTYPE_DONE,
        iMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
        iFlag = cc.EDITBOX_INPUT_FLAG_PASSWORD,
        posOffset = {x = 15, y = 0},
        maxLen = 6,
    })
end

function SafeBoxView:doReqFunc()
    self.lastTime = self.lastTime or 0
    self.curTime = socket.gettime()
    local diffTime = 0.5
    if (self.curTime - self.lastTime) < diffTime then
        print("too frequent !!!")
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_8})
        return
    end

    self.lastTime = self.curTime
    
    local body = {}
    self.coinWarning:setVisible(false)
    -- ccui.Helper:seekWidgetByName(panelInfo,"Label_coin_warning"):setVisible(false)
    if not self.editCoinNum or tonumber(self.editCoinNum) == nil or self.editCoinNum == "" then
        if self.reqType == 1 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_2})
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_3})
        end
        return
    end

    if tonumber(self.editCoinNum) == 0 then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_5})
        return
    end

    if self.reqType == 1 then
        body.gold = Cache.packetInfo:getCProMoney(tonumber(self.editCoinNum))
        if tonumber(Cache.user.free_gold) < tonumber(self.editCoinNum) then
            self.coinWarning:setVisible(true)
            return
        else
            self.coinWarning:setVisible(false)
        end

        GameNet:send({cmd=CMD.SAFE_DEPOSIT,body=body,timeout=nil,callback=function(rsp)
            loga("save coin rsp "..rsp.ret)
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            else
                if tolua.isnull(self) == true then
                    return
                end

                Cache.user:updateSafeBoxConfig(rsp.model)
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_6})
                self.saveCoin:setString(Util:getFormatString(Cache.user.safe_gold) .. Cache.packetInfo:getShowUnit())
                self.curCoin:setString(Util:getFormatString(Cache.user.free_gold).. Cache.packetInfo:getShowUnit())
                self:updateButton()
            end
        end})
    else
        if not self.pwd or self.pwd == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_4})
            return
        end
        body.gold = Cache.packetInfo:getCProMoney(tonumber(self.editCoinNum))
        body.password = self.pwd
        if tonumber(Cache.user.safe_gold) < tonumber(self.editCoinNum) then
            self.coinWarning:setVisible(true)
            return
        else
            self.coinWarning:setVisible(false)
        end
        GameNet:send({cmd=CMD.SAFE_WITHDRAW,body=body,timeout=nil,callback=function(rsp)
            loga("pull coin rsp "..rsp.ret)
            if rsp.ret ~= 0 then
                if tonumber(Cache.user.safe_gold) < tonumber(self.editCoinNum) then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_9})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_7})
                end
            else
                if tolua.isnull(self) == true then
                    return
                end

                Cache.user:updateSafeBoxConfig(rsp.model)
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_6})
                self.saveCoin:setString(Util:getFormatString(Cache.user.safe_gold) .. Cache.packetInfo:getShowUnit())
                self.curCoin:setString(Util:getFormatString(Cache.user.free_gold) .. Cache.packetInfo:getShowUnit())
            end
        end})
    end
end

function SafeBoxView:initButton( ... )
    self.coinNumTable = {}
    local btnNumberTbl = {"100","500","1000","MAX"}
    local btnName = {"Button_10", "Button_50", "Button_100", "Button_5000"}
    for i, v in ipairs(btnName) do
        local btn = self.actPanel:getChildByName(v)
        btn:setName("Button_" .. btnNumberTbl[i])
        addButtonEvent(btn, handler(self, self.btnNumCall))
        if checknumber(btnNumberTbl[i]) > 0 then
            local btnNum = tonumber(btnNumberTbl[i])
            if not Cache.packetInfo:isRealGold() then
                btnNum = Cache.packetInfo:getGoldByRealGod(btnNum)
            end
            local realNum = Cache.packetInfo:getProMoney(btnNum)
            btn:getChildByName("AtlasLabel_text"):setString(Util:getProductFormatString(realNum))
        end
        self[v] = btn
        self.coinNumTable[#self.coinNumTable + 1] = btn
    end
end

--金币更新
function SafeBoxView:refreshSafeBoxRestNum()
    local panelInfo = ccui.Helper:seekWidgetByName(self.bg,"Panel_info")
    local curCoin = ccui.Helper:seekWidgetByName(panelInfo,"Label_cur_coin")
    curCoin:setString(Util:getFormatString(Cache.user.gold) .. Cache.packetInfo:getShowUnit())
end

function SafeBoxView:updateButton()
    --根据身上的钱，判断快捷按钮是否可点
    local cmpCoin = 0
    if self.reqType == 2 then --取
        cmpCoin = tonumber(Cache.user.safe_gold)
    else --存
        cmpCoin = tonumber(Cache.user.free_gold)
    end
    if cmpCoin == nil then
        return
    end
    print("reqType >>>>>>>", self.reqType)
    for k, v in ipairs(self.coinNumTable) do
        -- v:getChildByName("Image_86"):setVisible(false)
        local coinNum = string.sub(v:getName(), 8, string.len(v:getName()))
        if checknumber(coinNum) == 0 then
            break
        end
        print(coinNum, cmpCoin)
        if checknumber(coinNum) >= cmpCoin then
            v:setEnabled(false)
        else
            v:setEnabled(true)
        end
    end
end

function SafeBoxView:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
     )
      self:runAction(action)
end

function SafeBoxView:getRoot() 
    return LayerManager.PopupLayer
end

return SafeBoxView