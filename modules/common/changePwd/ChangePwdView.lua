local ChangePwdView = class("ChangePwdView", CommonWidget.PopupWindow)

ChangePwdView.TAG = "ChangePwdView"

function ChangePwdView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.changePwd)
    self.root:getChildByName("Panel_27"):setVisible(false)
    self:init(args)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.changePwd, child=self.root})
end

function ChangePwdView:initWithRootFromJson()
    return GameRes.changePwd
end

function ChangePwdView:isAdaptateiPhoneX()
    return true
end

function ChangePwdView:init()
    self.winSize = cc.Director:getInstance():getWinSize()
    self.loginPwdPanel = ccui.Helper:seekWidgetByName(self.root, "Panel_login_pwd") --修改登陆密码
    self.payPwdPanel = ccui.Helper:seekWidgetByName(self.root, "Panel_pay_pwd")     --修改安全密码
    self.bindPhonePanel = ccui.Helper:seekWidgetByName(self.root, "Panel_bind_phone")--绑定手机
    self.paySetPanel = ccui.Helper:seekWidgetByName(self.root, "Panel_pay_pwd_set") --设置安全密码
    self.bindWizard = ccui.Helper:seekWidgetByName(self.root, "Panel_bind_wizard")  --温馨提示
    self.uiTbl = {self.loginPwdPanel, self.payPwdPanel, self.bindPhonePanel, self.paySetPanel, self.bindWizard}
    for i = 1, #self.uiTbl do
        self.uiTbl[i]:setVisible(false)
    end
end

function ChangePwdView:show( paras )
    -- body
    self:showWithType(paras.showType)
    self._paras = paras
    ChangePwdView.super.show(self)
end

function ChangePwdView:showWithType( showType )
    self:setVisible(true)
    if showType == 1 then --登录密码
        self.loginPwdPanel:setVisible(true)
        self.payPwdPanel:setVisible(false)
        self.bindPhonePanel:setVisible(false)
        self.paySetPanel:setVisible(false)
    elseif showType == 2 or showType == 3  then --安全密码
        self.loginPwdPanel:setVisible(false)
        self.payPwdPanel:setVisible(true)
        self.bindPhonePanel:setVisible(false)
        self.paySetPanel:setVisible(false)
    elseif showType == 4 then --绑定手机号
        self.bindWizard:setVisible(true)
        self.loginPwdPanel:setVisible(false)
        self.payPwdPanel:setVisible(false)
        self.bindPhonePanel:setVisible(false)
        self.paySetPanel:setVisible(false)
    elseif showType == 5 then --设置安全密码
        self.loginPwdPanel:setVisible(false)
        self.payPwdPanel:setVisible(false)
        self.bindPhonePanel:setVisible(false)
        self.paySetPanel:setVisible(true)
    elseif showType == 6 then --直接显示绑定手机页面 又不影响以前的功能
        self.bindWizard:setVisible(false)
        self.loginPwdPanel:setVisible(false)
        self.payPwdPanel:setVisible(false)
        self.bindPhonePanel:setVisible(true)
        self.paySetPanel:setVisible(false)
        showType = 4        
    end
    self:initWithType(showType)
end

function ChangePwdView:initWithType( showType )
    -- body 
    local function editboxEventHandler( strEventName,sender )
        -- body
        if strEventName == "began" then
            sender:setText("")  
      
            if sender:getName() == "pwd" then    
                self.pwd = "" 
            elseif sender:getName() == "affirmPwd" then    
                self.affirmPwd = ""   
            elseif sender:getName() == "pin" then    
                self.pin = ""    
            elseif sender:getName() == "phone" then 
                self.phone = ""       
            elseif sender:getName() == "invite" then 
                self.invite = ""
            end
        elseif strEventName == "ended" then
                                                          
        elseif strEventName == "return" then
            if sender:getName() == "pwd" then    
                self.pwd = sender:getText() 
            elseif sender:getName() == "affirmPwd" then    
                self.affirmPwd = sender:getText()   
            elseif sender:getName() == "pin" then    
                self.pin = sender:getText()
            elseif sender:getName() == "phone" then 
                self.phone = sender:getText()     
            elseif sender:getName() == "invite" then 
                self.invite = sender:getText()     
            end                                        
        elseif strEventName == "changed" then
                    
        end
    end
    
    --1 = 修改登录密码， 2 = 修改安全密码， 3 = 找回安全密码, 4= 绑定手机, 5 = 设置安全密码
    local panelMain = nil
    if showType == 1 then
        self.phone = Cache.user.is_bind_phone
        panelMain = self.loginPwdPanel
    elseif showType == 2 then
        self.phone = Cache.user.is_bind_phone
        panelMain = self.payPwdPanel
    elseif showType == 3 then
        --兑换找回安全密码
        self.phone = Cache.user.is_bind_phone
        panelMain = self.payPwdPanel
        --标题改一下
        ccui.Helper:seekWidgetByName(panelMain,"Image_title"):loadTexture(GameRes.player_image_7)
    elseif showType == 4 then
        panelMain = self.bindPhonePanel
        --邀请码
        local editFrame = ccui.Helper:seekWidgetByName(panelMain,"Image_invite_frame")  
        editFrame:removeAllChildren() 
        local editBox = cc.EditBox:create(cc.size(550, 80), cc.Scale9Sprite:create())
        editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
        local phoneCodePannel = ccui.Helper:seekWidgetByName(panelMain,"phone_code_pannel")
        editBox:setFontName(GameRes.font1)
        editBox:setFontSize(40)
        editBox:setPlaceholderFontSize(36)
        editBox:setPlaceHolder(GameTxt.string_login_10)
		editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        editBox:setPlaceholderFontColor(cc.c3b(204, 204, 204))
        editBox:setFontColor(cc.c3b(0, 0, 0))
        editBox:setName("invite")
        editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        editBox:registerScriptEditBoxHandler(editboxEventHandler)
        editFrame:addChild(editBox)
        editBox:setPosition(editFrame:getContentSize().width / 2 +  phoneCodePannel:getContentSize().width / 2, editFrame:getContentSize().height / 2)

        --手机号
        editFrame = ccui.Helper:seekWidgetByName(panelMain,"Image_phone_frame")   
        editFrame:removeAllChildren()
        editBox = cc.EditBox:create(cc.size(650, 80), cc.Scale9Sprite:create())
        editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
        editBox:setFontName(GameRes.font1)
        editBox:setFontSize(40)
        editBox:setPlaceholderFontSize(36)
        editBox:setPlaceHolder(GameTxt.string_bind_1)
        editBox:setPlaceholderFontColor(cc.c3b(204, 204, 204))
        editBox:setFontColor(cc.c3b(0, 0, 0))
        editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
        editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) 
        editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        editBox:setName("phone")
        editBox:registerScriptEditBoxHandler(editboxEventHandler)
        editFrame:addChild(editBox)
        editBox:setPosition(editFrame:getContentSize().width / 2 + phoneCodePannel:getContentSize().width/2 + 50, editFrame:getContentSize().height / 2)

        local phoneCallback = function (index, descTbl, zonecode)
            self.zoneNumber = zonecode
            self:refreshZoneEditTxt(phoneCodePannel, descTbl[index].code)
        end

        local cardlist = Util:initPhoneCodeDropList(phoneCodePannel, cc.size(editFrame:getContentSize().width+2,70), self, phoneCallback)
        local listview = cardlist:getListView()
        local tpos = Util:convertALocalPosToBLocalPos(editFrame, cc.p(-15,-editFrame:getContentSize().height/2), listview:getParent())
        listview:setPosition(tpos)

        local passwordTipTxt = ccui.Helper:seekWidgetByName(panelMain,"Label_title_pin_0")  
        passwordTipTxt:setString(string.format(GameTxt.PASSWORDTIP1, GameConstants.LIMIT_MIN_LEN))

        --先显示引导页再显示绑定页
        GameNet:send({cmd=CMD.SAFE_QUERY_MONEY,body={},timeout=nil,callback=function(rsp)
            local panelInfo = ccui.Helper:seekWidgetByName(self.bindWizard,"Panel_info")
            local bindButton = ccui.Helper:seekWidgetByName(self.bindWizard,"Button_bind")
            if rsp.ret ~= 0 then
            else
                loga("safe rsp.model.ret "..rsp.model.ret)
                if rsp.model.ret == 0 then
                elseif rsp.model.ret == 1 then
                    --赠送的钱
                    local bindTxtBg = self.bindWizard:getChildByName("bind_info_bg")
                    local bindTxt = bindTxtBg:getChildByName("txt")
                    if rsp.model.bind_money == 0 then
                        bindTxtBg:setVisible(false)
                        -- bindButton:setPositionY(bindButton:getPositionY() + 50)
                    else
                        bindTxtBg:setVisible(true)
                        bindTxt:setString(string.format(GameTxt.string_changepwd_11, Util:getFormatString(rsp.model.bind_money), Cache.packetInfo:getShowUnit()))
                    end
                 end
            end
           --关闭按钮
            local closeButton = ccui.Helper:seekWidgetByName(self.bindWizard,"Button_close")
            addButtonEvent(closeButton,function (sender)
                --qf.event:dispatchEvent(ET.MAIN_MOUDLE_VIEW_EXIT,{name="changePwd",from=self.from.name})
                self:close()
            end)
            Util:enlargeCloseBtnClickArea(closeButton)
            addButtonEvent(bindButton,function (sender)
                self.loginPwdPanel:setVisible(false)
                self.payPwdPanel:setVisible(false)
                self.bindPhonePanel:setVisible(true)
                self.paySetPanel:setVisible(false)
                self.bindWizard:setVisible(false)
            end)
        end})
    elseif showType == 5 then
        self.phone = Cache.user.is_bind_phone
        panelMain = self.paySetPanel
    end
    --手机号
    if showType ~= 4 then
        if ccui.Helper:seekWidgetByName(panelMain,"Label_phone_num") then
            if Cache.user:isBindPhone() then
                local phoneNumber = Cache.user.is_bind_phone
                local encryptNumber = string.sub(phoneNumber, 1, 3) .. "****" .. string.sub(phoneNumber, 8, -1)
                ccui.Helper:seekWidgetByName(panelMain,"Label_phone_num"):setString(encryptNumber)
            else
                ccui.Helper:seekWidgetByName(panelMain,"Label_phone_num"):setString("")
            end
        end
    end
    --验证码
    local editFrame = ccui.Helper:seekWidgetByName(panelMain,"Image_pin_frame")    
    if editFrame ~= nil then
        editFrame:removeAllChildren()
        local editBox = cc.EditBox:create(cc.size(422, 80), cc.Scale9Sprite:create())
        editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
        editBox:setFontName(GameRes.font1)
        editBox:setFontSize(40)
        editBox:setPlaceholderFontSize(36)
        editBox:setPlaceHolder(GameTxt.string_login_2)
        editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        editBox:setPlaceholderFontColor(cc.c3b(204, 204, 204))
        editBox:setFontColor(cc.c3b(0, 0, 0))
        editBox:setName("pin")
        editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        editBox:registerScriptEditBoxHandler(editboxEventHandler)
        editFrame:addChild(editBox)
        editBox:setPosition(editFrame:getContentSize().width / 2, editFrame:getContentSize().height / 2)
    end
    --密码
    local frame = ccui.Helper:seekWidgetByName(panelMain, "Image_pwd_frame")
    frame:removeAllChildren()
    editBox = cc.EditBox:create(cc.size(650, 80), cc.Scale9Sprite:create())
    editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBox:setFontName(GameRes.font1)
    editBox:setFontSize(40)
    editBox:setPlaceholderFontSize(36)
    if showType == 2 or showType == 3 or showType == 5 then
        editBox:setMaxLength(6)
    else
        editBox:setMaxLength(20)
    end
    editBox:setPlaceHolder(GameTxt.string_login_6)
    editBox:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBox:setFontColor(cc.c3b(0, 0, 0))
    editBox:setName("pwd")
    editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox:registerScriptEditBoxHandler(editboxEventHandler)
    frame:addChild(editBox)
    if showType == 5 then
        editBox:setPosition(frame:getContentSize().width / 2 - 17, frame:getContentSize().height / 2)
    else
        editBox:setPosition(frame:getContentSize().width / 2 - 10, frame:getContentSize().height / 2)
    end
    --确认密码
    frame = ccui.Helper:seekWidgetByName(panelMain, "Image_affirm_frame")
    frame:removeAllChildren()
    local editBox = cc.EditBox:create(cc.size(650, 80), cc.Scale9Sprite:create())
    editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBox:setFontName(GameRes.font1)
    editBox:setFontSize(40)
    editBox:setPlaceholderFontSize(36)
    editBox:setPlaceHolder(GameTxt.string_login_7)
    editBox:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBox:setFontColor(cc.c3b(0, 0, 0))
    editBox:setName("affirmPwd")
    editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    if showType == 2 or showType == 3 or showType == 5 then
        editBox:setMaxLength(6)
    else
        editBox:setMaxLength(20)
    end
    editBox:registerScriptEditBoxHandler(editboxEventHandler)
    frame:addChild(editBox)
    editBox:setPosition(frame:getContentSize().width / 2, frame:getContentSize().height / 2)
    if showType == 5 then
        editBox:setPosition(frame:getContentSize().width / 2 - 17, frame:getContentSize().height / 2)
    end
    --验证码按钮
    if ccui.Helper:seekWidgetByName(panelMain,"Button_pin") then
        addButtonEvent(ccui.Helper:seekWidgetByName(panelMain,"Button_pin"),function (sender)
            if not self.phone or not Util:isValidPhone(self.phone) then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_3})
                return
            end 
            self.regTime = 60 
            ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setEnabled(false)
            ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setBright(false)
            ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setTitleColor(cc.c3b(255,255,255))
            ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setTitleText(60 .. GameTxt.pin_txt_3)

            self.regSche = schedule(self, function ()
                if tolua.isnull(self) == true or self.regTime == nil then
                    return
                end
                
                self.regTime = self.regTime - 1
                ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setTitleText(self.regTime .. GameTxt.pin_txt_3)
                if self.regTime <= 0 then
                    ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setEnabled(true)
                    ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setBright(true)
                    ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setTitleText(GameTxt.string_login_4)
                    ccui.Helper:seekWidgetByName(panelMain,"Button_pin"):setTitleColor(cc.c3b(255,255,255))
                    self:stopRegSche()
                end
            end, 1)
            -- 显示模式
            --1 = 修改登录密码， 2 = 修改安全密码， 3 = 找回安全密码, 4= 绑定手机, 5 = 设置安全密码
            local cmdType = {
                [1] = CMD.CHANGE_LOGIN_PWD,
                [2] = CMD.SAFE_CHANGE_PASSWORD,
                [3] = CMD.SAFE_CHANGE_PASSWORD,
                [4] = CMD.CHANGE_LOGIN_PWD,
                [5] = CMD.SAFE_CHANGE_PASSWORD
            }
            --绑定手机页面 需要发送对应的区号
            local paras = {}
            if showType == 4 then
                paras.nation_code = self.zoneNumber
            else
                paras.nation_code = "86"
            end

            self:getVerificationCode(cmdType[showType], paras)
        end)
    end


    --关闭按钮
    local closeButton = ccui.Helper:seekWidgetByName(panelMain,"Button_close")
    addButtonEvent(closeButton,function (sender)
        self:stopRegSche()
        if self.preViewCallBack then
            self.preViewCallBack()
        end
        self:close()
    end)

    Util:enlargeCloseBtnClickArea(closeButton)
    --请求按钮
    local reqButton = ccui.Helper:seekWidgetByName(panelMain,"Button_request")
    addButtonEvent(reqButton,function (sender)
        self:requestByType(showType)
    end)
end

function ChangePwdView:stopRegSche()
    if self.regSche then
        self:stopAction(self.regSche)
        self.regSche = nil
    end
end

--获取验证码
function ChangePwdView:getVerificationCode(cmd, paras)
    Util:getSMSCodeConfig({phone = self.phone, nation_code = paras.nation_code, cmdcode = cmd, send_type = 0, callback = function (paras)
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = paras.msg})
    end})
end

--请求操作
function ChangePwdView:requestByType( reqType )
    print("requestByType >>>>>>>>>>>>", reqType)
    -- body
    if reqType == 1 then
        --空判断

        if not self.pin or self.pin == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_2})
            return
        end

        if Util:pinLimitFunc1(self.pin) then
            return
        end

        if not self.pwd or self.pwd == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_6})
            return
        end


        if Util:passWordLimitFunc1(self.pwd, self.affirmPwd) then
            return
        end
        
        local body = {}
        body.phone = Cache.user.is_bind_phone
        body.code = self.pin
        body.zone = "86"
        body.passwd = self.pwd
        GameNet:send({cmd=CMD.PHONE_FIND_PWD,body=body,timeout=nil,callback=function(rsp)
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_2})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_20})
                if self.preViewCallBack then
                    self.preViewCallBack()
                end
                self:stopRegSche()
                self:close()

                qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
                cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
                cc.UserDefault:getInstance():setStringForKey("loginBody", "")
                cc.UserDefault:getInstance():flush()
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)

            end
        end})
    elseif reqType == 2 or reqType == 3 then
        --空判断
        if not self.pin or self.pin == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_2})
            return
        end
        if not self.pwd or self.pwd == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_6})
            return
        end
        --密码仅支持6位数字        
        if not Util:checkOnlyDigit(self.pwd) or string.len(self.pwd) ~= 6  then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_3})
            return
        end
        --两次密码不一致
        if self.pwd ~= self.affirmPwd then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.PASSWORDERRORTIP1})
            return
        end
        if Util:pinLimitFunc1(self.pin) then
            return
        end
        local body = {}
        body.phone = Cache.user.is_bind_phone
        body.code = self.pin
        body.zone = "86"
        body.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..body.phone.."|"..body.code.."|"..body.zone)
        body.new_password = self.affirmPwd
        GameNet:send({cmd=CMD.SAFE_CHANGE_PASSWORD,body=body,timeout=nil,callback=function(rsp)
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_4})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_5})
                if self.preViewCallBack then
                    self.preViewCallBack()
                end
                Cache.user.safe_password = self.affirmPwd
                self:stopRegSche()
                self:close()
            end
        end})
    elseif reqType == 4 then
        --空判断
        if (not self.phone or self.phone == "") or (not self.pwd or self.pwd == "") or (not self.pin or self.pin == "") then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_11})
            return
        end

        -- --两次密码不一致
        -- if self.pwd ~= self.affirmPwd then
        --     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.PASSWORDERRORTIP1})
        --     return
        -- end

        --手机号必须为数字
        if tonumber(self.phone) == nil or not Util:isValidPhone(self.phone)  then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_12})
            return
        end

        if Util:passWordLimitFunc1(self.pwd) then
            return
        end

        if Util:pinLimitFunc1(self.pin) then
            return
        end

        local body = {}
        body.uin = Cache.user.uin
        body.phone = self.phone
        body.code = self.pin
        -- body.zone = "86"
        body.zone = self.zoneNumber
        body.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..body.uin.."|"..body.phone)
        body.passwd = self.pwd
        body.invete_code = self.invite or ""
        dump(body)
        GameNet:send({cmd=CMD.CHANGE_LOGIN_PWD,body=body,timeout=nil,callback=function(rsp)
            loga("changed login pwd rsp "..rsp.ret)
            if rsp.ret ~= 0 then
                if rsp.ret == 2003 then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_6})
                    return
                end
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_10})
            else
                if self._paras.notTip then
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_7})  
                end

                self:savePhone(body.phone, body.passwd, body.zone)
                Cache.user.is_bind_phone = self.phone
                if ModuleManager["personal"].view and ModuleManager["personal"].view:isVisible() == true then
                    ModuleManager["personal"]:getView():updateButton()
                end           
                if ModuleManager["gameshall"] and ModuleManager["gameshall"].view and tolua.isnull(ModuleManager["gameshall"].view) == false then
                    ModuleManager["gameshall"]:getView():refreshBindRewardBtn()
                end
                self:setVisible(false)
                self.phone = ""
                self.pwd = ""
                self.affirmPwd = ""
                self.pin = ""
                if self._paras and self._paras.cb and type(self._paras.cb) == "function" then
                    self._paras.cb()
                end

                if Cache.user.show_promotion == 1 then --是否展示填入邀请码  0 不展示 1展示
                    local function callfunc( ... )
                        -- body
                        Cache.user.show_promotion = 0
                        qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 5})
                    end
                    --移除邀请码回调
                    -- qf.event:dispatchEvent(ET.INVITE_CODE)
                    self:close()
                else
                    self:showWithType(5)
                end

            end
        end})
    elseif reqType == 5 then  --设置安全密码
        --空判断
        if not self.pwd or self.pwd == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_6})
            return
        end
        --手机号必须为数字
        if tonumber(self.phone) == nil or not Util:isValidPhone(self.phone)  then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_12})
            return
        end
        --密码仅支持6位数字
        if tonumber(self.affirmPwd) == nil or string.len(self.affirmPwd) ~= 6 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_3})
            return
        end
        --两次密码不一致
        if self.pwd ~= self.affirmPwd then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.PASSWORDERRORTIP1})
            return
        end
        -- if not self.pin or self.pin == "" then
        --     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_2})
        --     return
        -- end

        -- if Util:pinLimitFunc1(self.pin) then
        --     return
        -- end
        local body = {}
        body.phone = Cache.user.is_bind_phone
        body.code = ""
        body.zone = "86"
        body.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..body.phone.."|"..body.code.."|"..body.zone)
        body.new_password = self.affirmPwd
        GameNet:send({cmd=CMD.SAFE_CHANGE_PASSWORD,body=body,timeout=nil,callback=function(rsp)
            loga("changed safeBox pwd rsp "..rsp.ret)
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_8})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_changepwd_9})
                if self.preViewCallBack then
                    self.preViewCallBack()
                end
                Cache.user.safe_password = self.affirmPwd
                self:stopRegSche()
                self:close()
            end
        end})
    end
end


function ChangePwdView:savePhone(phone,pwd, zone)
    local cmpIndex = Util:saveUniqueValueByKey("loginPhone", phone)
    Util:insertValueByKeyAndIndex("loginPwd", pwd, cmpIndex)
    Util:insertValueByKeyAndIndex("loginZone", zone, cmpIndex)
end

function ChangePwdView:setRichTextContent(txt, sender)
    if self._rText then
        self._rText:removeFromParent(true)
        self._rText = nil
    end

    local rText = Util:createRichText({size = cc.size(1180,300), vspace = 10})
    sender:addChild(rText)

    local normalColor = cc.c3b(102, 147, 225)
    local keyColor = cc.c3b(241, 204, 80)
    local richDesc = {
        {desc = GameTxt.bind_txt_1, color = normalColor},
        {desc = txt, color = keyColor},
        {desc = GameTxt.bind_txt_2, color = normalColor}
    }

    for i, v in ipairs(richDesc) do
        local color = v.color
        local desc = v.desc
        local txt = ccui.RichElementText:create(1, color, 255, desc, GameRes.font1, 42)
        rText:pushBackElement(txt)
    end
    rText:setPosition(cc.p(880, 430))
    self._rText = rText
end

function ChangePwdView:getRoot() 
    return LayerManager.PopupLayer
end

function ChangePwdView:refreshZoneEditTxt(zonePanel, txt)
    local num = string.len(txt)
    local arror = zonePanel:getChildByName("arror")
    local numTxt = zonePanel:getChildByName("num")
    numTxt:setString(txt)
    arror:setPositionX(35 + num*20)
end

        -- self:refreshZoneEditTxt(phoneCodePannel, descTbl[index].code)

function ChangePwdView:setPreViewCallback( callback )
    -- body
    self.preViewCallBack = callback
end

return ChangePwdView