local LoginView = class("LoginView", qf.view)
LoginView.TAG = "LoginView"

local editBoxOffSetX = -60
local offSetX = 0
local txtFontColor = cc.c3b(255,255,255)
local pinTxtColor = cc.c3b(255,255,255)
local placeHolderTxtColor = cc.c3b(38,84,138)

function LoginView:ctor(parameters)
    self.super.ctor(self,parameters)
    self:init(parameters)
    self:initTouchEvent()
    self:initPhoneLoginLayer()
    Cache.user:setShowVisitorTip(true)
    Cache.Config:resetSomeStatus()
    local loginType = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    if loginType ~= VAR_LOGIN_TYPE_NO_LOGIN then
        self:showPanelLayer("null")
    end
end

function LoginView:initTouchEvent()
    self:initLoginTypeButtonEvent()
end

function LoginView:initWithRootFromJson( ... )
    return GameRes.loginLayoutJson
end

function LoginView:isAdaptateiPhoneX()
    return true
end

function LoginView:init(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    --从userdefault 获取对应是否有首次登陆的标识
    Cache.user.isFirstgame =  cc.UserDefault:getInstance():getBoolForKey(SKEY.FIRST_GAME_FLAG,true)
    self:showPanelLayer("LoginTypePannel")
    if paras then
        if paras.showLoginBtnPannel then
            self:showLoginBtnPannel(paras.showLoginBtnPannel)
        end
    end
    self.firstOpen = true
    if FIRST_LOGIN ~= true then
        self.firstOpen = false
        return 
    end
    --非首次登陆 迅速帮用户登陆
    FIRST_LOGIN = false
    qf.event:dispatchEvent(ET.LOGIN_REQUEST_LAST_SERVER)
end

function LoginView:showLogin(_visible)
    -- qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
    PopupManager:removeAllPopup() -- 移除弹窗
    qf.event:dispatchEvent(ET.CLEARLISTPOPUP) --清空弹窗队列
    qf.event:dispatchEvent(ET.GLOBAL_HIDE_BROADCASE_LAYOUT) --隐藏广播
    if self.root then --self.root 表示ui  有的话 直接显示对应的
        self:initLoginTypeButtonEvent(true)
        return 
    end
    Util:adaptIphoneXPos(self.root)
    self:initLoginTypeButtonEvent()
    if not BOL_AUTO_RE_CONNECT then
        BOL_AUTO_RE_CONNECT = true 
        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_EVENT,{content=GameTxt.game_reconnect_text, _type = 2})
    end
    local is_review = 0 ~= Util:binaryAnd(tonumber(Util:getDesDecryptString(TB_SERVER_INFO.modules)), TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    self:initPhoneLoginLayer()
end

function LoginView:showToolsTips( uin )
    -- body
    self.toolTips = require("src.modules.common.widget.toolTip").new()
    if uin and uin ~= 0 then
        self.toolTips:setTipsText(string.format(GameTxt.login007,uin))
    else
        self.toolTips:setTipsText(GameTxt.login008)
    end
    self:addChild(self.toolTips,2)
end

function LoginView:showToolsTips2(txt)
    -- body
    self.toolTips = require("src.modules.common.widget.toolTip").new()
    self.toolTips:setTipsText(txt)
    self:addChild(self.toolTips,2)
end

function LoginView:cleanup( ... )
    -- body
    if self.guangSchedule then
        Scheduler:unschedule(self.guangSchedule)
        self.guangSchedule=nil
    end
end

function LoginView:initLoginTypeButtonEvent()
    --删除globalView中 对应的 fullWaittingTAG PANEL
    if qf.platform:getKey()=="wrong_key" then
    --调用 showToast 方法 弹出提示
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.login_txt_2})
    end
    local panel_button = ccui.Helper:seekWidgetByName(self.root,"Panel_button")

    --根据loginType显示对应的按钮
    local phoneBtn = ccui.Helper:seekWidgetByName(panel_button,"Button_phone")
    local youkeBtn = ccui.Helper:seekWidgetByName(panel_button,"Button_youke")
        
    --游客登陆
    Util:addButtonScaleAnimFuncWithDScale(ccui.Helper:seekWidgetByName(panel_button,"Button_youke"),function (sender)
        --请求信息中
        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
        self:delayRun(0.01,function (  )
            --开始登陆
            qf.event:dispatchEvent(ET.START_TO_LOGIN)
            self:removepclogin()
        end)
        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_VISITOR); -- -1为测试账号登录
        cc.UserDefault:getInstance():flush()
        self:delayRun(1,function (  )
            local regInfo = qf.platform:getRegInfo()
            xpcall(
                function()
                    regInfo.client_ip = Cache.Config:getIPAddress()
                end,
                function() 
                    regInfo.client_ip = Util:getDesDecryptString(TB_SERVER_INFO.client_ip) or ""
                end
            )
            
            qf.event:dispatchEvent(ET.LOGIN_SIGN_IN,{cmd = CMD.REG,body=regInfo})
            --remove 去掉 add 增加 globalview的self.rootWaittingTAG 这个tag 对应的node  node上有一个bg
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove",reConnect = 1})
        end)
        --清空登陆次数 为什么？
        qf.event:dispatchEvent(ET.UPDATE_LOGIN_TIMES)
    end)

    Util:addButtonScaleAnimFuncWithDScale(ccui.Helper:seekWidgetByName(self.root,"Button_phone"),function (sender)
        --if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then game.uploadError(" 点击QQ登录") end
        --显示出对应的手机登陆页面
        self:showPanelLayer()
    end)
end

--与panelButton 相关的ui
function LoginView:setButtonLayerVisible(bVis)
    -- local uiName ={"Panel_button"}
    -- for i,v in ipairs(uiName) do
    --     ccui.Helper:seekWidgetByName(self.root,v):setVisible(bVis)
    -- end    
end

------------------新的手机登录页面------------------------
function LoginView:initPhoneLoginLayer( ... )
    -- body
    local pwdLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_phone_login_pwd")
    local pinLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_phone_login_pin")
    local registLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_login_register")
    local buttonLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_button")
    local findLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_login_find_pwd")
    pinLayer:setVisible(false)
    pwdLayer:setVisible(false)
    registLayer:setVisible(false)
    self:setButtonLayerVisible(true)
    findLayer:setVisible(false)

    if FULLSCREENADAPTIVE then
        local dx = - (cc.Director:getInstance():getWinSize().width-1920)/2
        
        pwdLayer:setContentSize(cc.size(self.winSize.width, self.winSize.height))
        pinLayer:setContentSize(cc.size(self.winSize.width, self.winSize.height))
        registLayer:setContentSize(cc.size(self.winSize.width, self.winSize.height))
        findLayer:setContentSize(cc.size(self.winSize.width, self.winSize.height))
    end

    --验证码登录绑定二级界面事件
    self:initPanelPhoneLoginByPin(pinLayer)
    --密码登录绑定二级界面事件
    self:initPanelPhoneLoginByPwd(pwdLayer)
    --注册绑定二级界面事件
    self:initRegist()
    --找回密码绑定二级界面事件
    self:initFindPwd()
    --手机登录的两个页面加美女动画
    self.bottomPannel = ccui.Helper:seekWidgetByName(self.root,"Panel_99")
    -- self.bottomPannel:setZOrder(99)
    if FULLSCREENADAPTIVE then
        self.bottomPannel:setContentSize(self.winSize.width, self.bottomPannel:getContentSize().height)
    end
end

function LoginView:showLoginBtnPannel(isVisible)
    local buttonLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_button") --三个主按钮
    buttonLayer:setZOrder(2)
    if buttonLayer then
        buttonLayer:setVisible(isVisible)
    end
end

--手机验证码登陆
function LoginView:initPanelPhoneLoginByPin( pinLayer )
    -- body
    local playerFrame = ccui.ImageView:create(GameRes.playerFrameImage)
    
    local pinLoginLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_login")
    local phoneCodePannel = ccui.Helper:seekWidgetByName(pinLoginLayer,"phone_code_pannel")
    local imagePhoneFrame = ccui.Helper:seekWidgetByName(pinLoginLayer,"Image_phone_frame")
    local comboListPannel = ccui.Helper:seekWidgetByName(pinLayer,"Panel_comboList")
    local editBoxPhone = cc.EditBox:create(cc.size(imagePhoneFrame:getContentSize().width - phoneCodePannel:getContentSize().width - comboListPannel:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxPhone:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPhone:setFontName(GameRes.font1)
    editBoxPhone:setFontColor(txtFontColor)
    imagePhoneFrame:addChild(editBoxPhone)
    editBoxPhone:setName("editPhoneFrame")
    editBoxPhone:setFontSize(40)
    editBoxPhone:setPlaceholderFontSize(36)
    editBoxPhone:setPlaceHolder(GameTxt.string_login_1)
    editBoxPhone:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxPhone:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    editBoxPhone:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPhone:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxPhone:setPosition(imagePhoneFrame:getContentSize().width/2 - editBoxOffSetX/4 + 25, imagePhoneFrame:getContentSize().height / 2)


    local imagePinFrame = ccui.Helper:seekWidgetByName(pinLoginLayer,"Image_pin_frame")
    local editBox = cc.EditBox:create(cc.size(imagePinFrame:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBox:setFontName(GameRes.font1)
    editBox:setFontColor(txtFontColor)
    editBox:setName("editPinFrame")
    editBox:setFontSize(40)
    editBox:setPlaceholderFontSize(36)
    editBox:setPlaceHolder(GameTxt.string_login_2)
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editBox:setPlaceholderFontColor(placeHolderTxtColor)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imagePinFrame:addChild(editBox)
    editBox:setPosition(imagePinFrame:getContentSize().width * 0.5 - editBoxOffSetX/4, imagePinFrame:getContentSize().height / 2)
    --注册/登录验证码
    addButtonEvent(ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"),function (sender)
        self.phoneNum = editBoxPhone:getText()
        if not self.phoneNum or not Util:isValidPhone(self.phoneNum) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_3})
            return
        end 
        self.rootPinTime = 60 
        ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setEnabled(false)
        ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setBright(false)
        ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setTitleColor(txtFontColor)
        ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setTitleText(string.format(GameTxt.retry_send_code, 60))
        self.regSche = Scheduler:scheduler(1, handler(self, function ()
            if tolua.isnull(self) == true or self.rootPinTime == nil then
                return
            end
            self.rootPinTime = self.rootPinTime - 1
            ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setTitleText(string.format(GameTxt.retry_send_code, self.rootPinTime))
            if self.rootPinTime <= 0 then
                ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setEnabled(true)
                ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setBright(true)
                ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setTitleText(GameTxt.string_login_4)
                ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_pin"):setTitleColor(txtFontColor)
                Scheduler:unschedule(self.regSche)
                self.regSche = nil
            end
        end))

        -- 验证码登录
        self:getVerificationCode(CMD.PHONE_LOGIN_PIN, {nation_code = self.pinZoneNumber, send_type = 1})
    end)

    --验证码注册/登录请求
    Util:addButtonScaleAnimFuncWithDScale(ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_phone_login"),function (sender)
        self.phoneNum = editBoxPhone:getText()
        if self.phoneNum == nil or string.len(self.phoneNum) == 0  then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_5})
            return
        end

        if Util:pinLimitFunc1(self.pin) then
            return
        end
        GameNet:reReg()
        self:reqPinSignIn(2)
    end)

    local pinSetLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_set")
    local imageAffirmFrame = ccui.Helper:seekWidgetByName(pinSetLayer,"Image_set_frame")
    editBox = cc.EditBox:create(cc.size(600, 80), cc.Scale9Sprite:create())
    editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBox:setFontName(GameRes.font1)
    editBox:setFontColor(txtFontColor)
    editBox:setName("editPwdFrame")
    editBox:setFontSize(40)
    editBox:setPlaceholderFontSize(36)
    editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBox:setPlaceHolder(GameTxt.string_login_6)
    editBox:setPlaceholderFontColor(placeHolderTxtColor)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imageAffirmFrame:addChild(editBox)
    editBox:setPosition(imageAffirmFrame:getContentSize().width / 2, imageAffirmFrame:getContentSize().height / 2)
    local imageSetFrame = ccui.Helper:seekWidgetByName(pinSetLayer,"Image_affirm_frame")
    editBox = cc.EditBox:create(cc.size(600, 80), cc.Scale9Sprite:create())
    editBox:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBox:setFontName(GameRes.font1)
    editBox:setFontColor(txtFontColor)
    imageSetFrame:addChild(editBox)
    editBox:setName("affirmPwdFrame")
    editBox:setFontSize(40)
    editBox:setPlaceholderFontSize(36)
    editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBox:setPlaceHolder(GameTxt.string_login_7)
    editBox:setPlaceholderFontColor(placeHolderTxtColor)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBox:setPosition(imageSetFrame:getContentSize().width * 0.5 + offSetX, imageSetFrame:getContentSize().height / 2)

    addButtonEvent(ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_close"),function (sender)
        --pinLayer:setVisible(false)--图层关闭要连着蒙版一起关了
        self:showPanelLayer("LoginTypePannel")
    end)
    Util:enlargeCloseBtnClickArea(ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_close"),function (sender)
        --pinLayer:setVisible(false)--图层关闭要连着蒙版一起关了
        self:showPanelLayer("LoginTypePannel")
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(pinSetLayer,"Button_close"),function (sender)
        self:showPanelLayer()
    end)
    Util:enlargeCloseBtnClickArea(ccui.Helper:seekWidgetByName(pinSetLayer,"Button_close"),function (sender)
        self:showPanelLayer()
    end)

    --初次用验证码登录的账号，强制设置密码
    Util:addButtonScaleAnimFuncWithDScale(ccui.Helper:seekWidgetByName(pinSetLayer,"Button_set_pwd"),function (sender)
        if self.pwd ~= self.affirmPwd then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_8})
            return
        end
        if Util:passWordLimitFunc1(self.pwd) then
            return
        end
        self:reqUpdatePwd()
    end)
    --切换密码登录
    addButtonEvent(ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_use_pwd"),function (sender)
        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_PWD)
        cc.UserDefault:getInstance():flush()
        self:showPanelLayer()
    end)
    --找回密码按钮
    addButtonEvent(ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_find_pwd"),function (sender)
        self:showPanelLayer("findPwd")
    end)
    ccui.Helper:seekWidgetByName(pinLoginLayer,"Button_find_pwd"):setVisible(false)
    --下拉框按钮
    addButtonEvent(comboListPannel,function (sender)
        local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", nil)
        if not phone then
            return
        end
        local comlist = pinLoginLayer:getChildByName("RecordPhoneDropList")
        if comlist and tolua.isnull(comlist) == false  then
            comlist:setVisible(true)
            return
        end

        local zone = cc.UserDefault:getInstance():getStringForKey("loginZone", nil)
        local zoneTable = string.split(zone, "|")
        local phoneTable = string.split(phone,"|")
        local dataTbl = {}
        for i = 1, #phoneTable do
            local dzone = "+86"
            if zoneTable[i]~= nil then
                dzone = "+" .. zoneTable[i]
            end
            dataTbl[#dataTbl + 1] = {
                dzone = dzone,
                phone = phoneTable[i]
            }
        end
        local pos = cc.p(imagePhoneFrame:getPositionX() , imagePhoneFrame:getPositionY() - imagePhoneFrame:getContentSize().height/2)
        local size = cc.size(imagePhoneFrame:getContentSize().width, 81)
        local callfunc = function (paras)
            self.phoneNum = paras.phone
            self.pinZoneNumber =  string.sub( paras.code, 2, #paras.code)
            editBoxPhone:setText(self.phoneNum)
            self:refreshZoneEditTxt(phoneCodePannel, paras.code)
        end
        local paras = {pos = pos, size = size, curPhoneTxt = editBoxPhone:getText(), callfunc = callfunc}
        local comlist = Util:initRecordPhoneDropList(dataTbl, paras)
        pinLoginLayer:addChild(comlist)
    end)


    local phoneCallback = function (index, descTbl, zonecode)
        self.pinZoneNumber = zonecode
        self:refreshZoneEditTxt(phoneCodePannel, descTbl[index].code)
    end

    local cardlist = Util:initPhoneCodeDropList(phoneCodePannel, cc.size(imagePhoneFrame:getContentSize().width,70), self, phoneCallback)
    local listview = cardlist:getListView()
    local tpos = Util:convertALocalPosToBLocalPos(imagePhoneFrame, cc.p(0,-imagePhoneFrame:getContentSize().height/2), listview:getParent())
    listview:setPosition(tpos)
end

function LoginView:hidePhoneCodeList(sender)
    if not sender then return end
    if tolua.isnull(sender) then return end
    if sender:getChildByName("phoneCodeList") then
        sender:removeChildByName("phoneCodeList")
    end
end

--手机密码登陆
function LoginView:initPanelPhoneLoginByPwd( pwdLayer )
    -- body
    local editBox1 = nil
    local pwdLoginLayer = ccui.Helper:seekWidgetByName(pwdLayer,"Panel_pwd_login")
    local imagePwdFrame = ccui.Helper:seekWidgetByName(pwdLoginLayer,"Image_pwd_frame") 
    local phoneCodePannel = ccui.Helper:seekWidgetByName(pwdLoginLayer,"phone_code_pannel")

    -- 密码输入框
    editBox1 = cc.EditBox:create(cc.size(668, 100), cc.Scale9Sprite:create())
    editBox1:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBox1:setFontName(GameRes.font1)
    editBox1:setFontColor(txtFontColor)
    editBox1:setName("editPwdFrame")
    editBox1:setFontSize(40)
    editBox1:setPlaceholderFontSize(36)
    editBox1:setPlaceHolder(GameTxt.string_login_17)
    editBox1:setPlaceholderFontColor(placeHolderTxtColor)
    editBox1:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox1:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imagePwdFrame:addChild(editBox1)
    editBox1:setPosition(imagePwdFrame:getContentSize().width / 2 + editBoxOffSetX, imagePwdFrame:getContentSize().height / 2)

    self.phonePWDEditBox = editBox1
    --是否可见密码
    self.visiblePwd = false --默认不可见
    local btnPwdVisible = ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_show_pwd")
    btnPwdVisible:setZOrder(1)
    addButtonEvent(btnPwdVisible,function (sender)
        self.visiblePwd = not self.visiblePwd
        if self.visiblePwd == true then --显示密码 
            btnPwdVisible:loadTextureNormal(GameRes.btn_show_pwd)
            if self.pwd then
                self.phonePWDEditBox:setText(self.pwd)
            end
        else --不显示密码
            btnPwdVisible:loadTextureNormal(GameRes.btn_hide_pwd)
            local len = string.len(self.phonePWDEditBox:getText())
            if len > 0 then
                local tmpStr = ''
                for i = 1, len do
                    tmpStr = tmpStr..'*'
                end
                self.phonePWDEditBox:setText(tmpStr)
            end
        end
    end)

    local imagePhoneFrame = ccui.Helper:seekWidgetByName(pwdLoginLayer,"Image_phone_frame")
    -- 手机号码输入框
    local editBox = cc.EditBox:create(cc.size(imagePhoneFrame:getContentSize().width - phoneCodePannel:getContentSize().width - 30, 100), cc.Scale9Sprite:create())
    editBox:setTag(-987654)  --  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBox:setFontName(GameRes.font1)
    editBox:setFontColor(txtFontColor)
    imagePhoneFrame:addChild(editBox)
    editBox:setName("editPhoneFrame")
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    editBox:setFontSize(40)
    editBox:setPlaceholderFontSize(36)
    editBox:setPlaceHolder(GameTxt.string_login_1)
    editBox:setPlaceholderFontColor(placeHolderTxtColor)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox:setPosition(phoneCodePannel:getPositionX() + editBox:getContentSize().width/2 + 15, imagePhoneFrame:getContentSize().height / 2)

    local phoneCallback = function (index, descTbl, zonecode)
        self.pinZoneNumber = zonecode
        self:refreshZoneEditTxt(phoneCodePannel, descTbl[index].code)
    end

    local cardlist = Util:initPhoneCodeDropList(phoneCodePannel, cc.size(imagePhoneFrame:getContentSize().width,70), self, phoneCallback)
    local listview = cardlist:getListView()
    local tpos = Util:convertALocalPosToBLocalPos(imagePhoneFrame, cc.p(0,-imagePhoneFrame:getContentSize().height/2), listview:getParent())
    listview:setPosition(tpos)

    local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", nil)
    local phoneTable = {}
    if phone then
        phoneTable = string.split(phone,"|")
    end


    local _editboxEventHandler = function (strEventName, sender)
        self:editboxEventHandler(strEventName, sender)
        
        if strEventName == "began" then
            self.beginPhoneNumber = nil
            local bClearFlag = false
            for i, v in ipairs(phoneTable) do
                if v == sender:getText() then
                    bClearFlag = true
                    self.beginPhoneNumber = sender:getText()
                    break
                end
            end
        elseif strEventName == "return" or strEventName == "ended" then
            local curNumber = sender:getText()
            if self.beginPhoneNumber and curNumber ~= self.beginPhoneNumber then
                editBox1:setText("")
                self.pwd = ""
            end
        end
    end
    editBox:registerScriptEditBoxHandler(_editboxEventHandler)


    local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", nil)
    if not phone then
        return
    end

    local phoneTable = string.split(phone,"|")
    phoneTable = {}
    phoneTable[1] = phone

    --密码登录请求
    Util:addButtonScaleAnimFuncWithDScale(ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_phone_login"),function (sender)
        self.phoneNum = editBox:getText()
        if self.phoneNum == nil or string.len(self.phoneNum) == 0  then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_5})
            return
        end
        if self.pwd == nil or string.len(self.pwd) == 0  then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_9})
            return
        end

        GameNet:reReg()
        self:reqPwdSignIn()
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_close"),function (sender)
        self:showPanelLayer("LoginTypePannel")
    end)
    Util:enlargeCloseBtnClickArea(ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_close"),function (sender)
        self:showPanelLayer("LoginTypePannel")
    end)

    --切换验证码登录
    addButtonEvent(ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_use_pin"),function (sender)
        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_PIN)
        cc.UserDefault:getInstance():flush();
        self:showPanelLayer()
    end)
    --找回密码按钮
    addButtonEvent(ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_find_pwd"),function (sender)
        self:showPanelLayer("findPwd")
    end)
    ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_find_pwd"):setVisible(true)
    --注册按钮
    addButtonEvent(ccui.Helper:seekWidgetByName(pwdLoginLayer,"Button_reg"),function (sender)
        self:showPanelLayer("regist")
    end)
    --记住密码状态
    local checkboxSave = ccui.Helper:seekWidgetByName(pwdLoginLayer,"CheckBox_save_pwd")
    local saveFlag = ccui.Helper:seekWidgetByName(checkboxSave,"Image_flag")
    saveFlag:setVisible(true) --默认记住密码
    self.savePwdFlag = cc.UserDefault:getInstance():getBoolForKey("saveFlag", true)
    saveFlag:setVisible(self.savePwdFlag)
    addButtonEvent(checkboxSave,function (sender)
        self.savePwdFlag = not self.savePwdFlag
        saveFlag:setVisible(self.savePwdFlag)
    end)
    --下拉框按钮
    addButtonEvent(ccui.Helper:seekWidgetByName(pwdLayer,"Panel_comboList"),function (sender)
        local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", nil)
        if not phone then
            return
        end

        local comlist = pwdLoginLayer:getChildByName("RecordPhoneDropList")
        if comlist and tolua.isnull(comlist) == false  then
            comlist:setVisible(true)
            return
        end

        local zone = cc.UserDefault:getInstance():getStringForKey("loginZone", nil)
        local zoneTable = string.split(zone, "|")
        local phoneTable = string.split(phone,"|")

        local dataTbl = {}
        for i = 1, #phoneTable do
            local dzone = "+86"
            if zoneTable[i]~= nil then
                dzone = "+" .. zoneTable[i]
            end
            dataTbl[#dataTbl + 1] = {
                dzone = dzone,
                phone = phoneTable[i]
            }
        end
        local pos = cc.p(imagePhoneFrame:getPositionX() , imagePhoneFrame:getPositionY() - imagePhoneFrame:getContentSize().height/2)
        local size = cc.size(imagePhoneFrame:getContentSize().width, 100)
        local callfunc = function (paras)
            self.phoneNum = paras.phone
            self.pinZoneNumber =  string.sub( paras.code, 2, #paras.code)
            editBox:setText(self.phoneNum)
            self:refreshZoneEditTxt(phoneCodePannel, paras.code)

            --对应的密码填上
            local pwd = cc.UserDefault:getInstance():getStringForKey("loginPwd", "")
            local pwdTable = string.split(pwd,"|")
            dump(pwdTable)
            if pwdTable and #pwdTable > 0 and self.savePwdFlag == true then
                self.pwd = pwdTable[paras.idx]
                --密码是否可见
                local showTxt = ""
                if self.visiblePwd == true then
                    showTxt = self.pwd
                else
                    local len = string.len(self.pwd)
                    if len > 0 then
                        for i = 1, len do
                            showTxt = showTxt..'*'
                        end
                    end
                end
                editBox1:setText(showTxt)
            end
        end
        local paras = {pos = pos, size = size, curPhoneTxt = editBox:getText(), callfunc = callfunc, phonePos = cc.p(185, size.height/2)}
        local comlist = Util:initRecordPhoneDropList(dataTbl, paras)
        pwdLoginLayer:addChild(comlist)
    end)
end

function LoginView:initRegist( registLayer )
    -- body
    local registOffsetX = 0
    local editBox = nil
    local phoneRegistLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_login_register")
    local imagePhoneFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_phone_frame")
    local phoneCodePannel = ccui.Helper:seekWidgetByName(phoneRegistLayer,"phone_code_pannel")
    -- 手机输入框
    local editBoxPhone = cc.EditBox:create(cc.size(imagePhoneFrame:getContentSize().width - phoneCodePannel:getContentSize().width - 30, 80), cc.Scale9Sprite:create())
    editBoxPhone:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPhone:setFontName(GameRes.font1)
    editBoxPhone:setFontColor(txtFontColor)
    imagePhoneFrame:addChild(editBoxPhone)
    editBoxPhone:setName("editPhoneFrame")
    editBoxPhone:setFontSize(40)
    editBoxPhone:setPlaceholderFontSize(36)
    editBoxPhone:setPlaceHolder(GameTxt.string_login_1)
    editBoxPhone:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxPhone:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    editBoxPhone:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPhone:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxPhone:setPosition(phoneCodePannel:getPositionX() +phoneCodePannel:getContentSize().width + editBoxOffSetX - 15, imagePhoneFrame:getContentSize().height / 2)

    --验证码输入框
    local imagePinFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_pin_frame")
    local editBoxPin = cc.EditBox:create(cc.size(imagePinFrame:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxPin:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPin:setFontName(GameRes.font1)
    editBoxPin:setFontColor(txtFontColor)
    editBoxPin:setName("editPinFrame")
    editBoxPin:setFontSize(40)
    editBoxPin:setPlaceholderFontSize(36)
    editBoxPin:setPlaceHolder(GameTxt.string_login_2)
	editBoxPin:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editBoxPin:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxPin:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPin:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imagePinFrame:addChild(editBoxPin)
    editBoxPin:setPosition(imagePinFrame:getContentSize().width / 2 - editBoxOffSetX / 4, imagePinFrame:getContentSize().height / 2)
    phoneRegistLayer:setVisible(false)

    --密码输入框
    local imagePwdFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_pwd_frame")
    local editBoxPwd = cc.EditBox:create(cc.size(imagePwdFrame:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxPwd:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPwd:setFontName(GameRes.font1)
    editBoxPwd:setFontColor(txtFontColor)
    editBoxPwd:setName("editPwdFrame")
    editBoxPwd:setFontSize(40)
    editBoxPwd:setPlaceholderFontSize(36)
    editBoxPwd:setPlaceHolder(GameTxt.string_login_6)
    editBoxPwd:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxPwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBoxPwd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPwd:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imagePwdFrame:addChild(editBoxPwd)
    editBoxPwd:setPosition(imagePwdFrame:getContentSize().width / 2 - editBoxOffSetX / 4, imagePwdFrame:getContentSize().height / 2)

    -- 密码确认框
    local imageAffirmFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_affirm_frame")
    local editBoxAffirm = cc.EditBox:create(cc.size(imageAffirmFrame:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxAffirm:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxAffirm:setFontName(GameRes.font1)
    editBoxAffirm:setFontColor(txtFontColor)
    editBoxAffirm:setName("affirmPwdFrame")
    editBoxAffirm:setFontSize(40)
    editBoxAffirm:setPlaceholderFontSize(36)
    editBoxAffirm:setPlaceHolder(GameTxt.string_login_7)
    editBoxAffirm:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBoxAffirm:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxAffirm:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxAffirm:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imageAffirmFrame:addChild(editBoxAffirm)
    editBoxAffirm:setPosition(imageAffirmFrame:getContentSize().width / 2 - editBoxOffSetX / 4, imageAffirmFrame:getContentSize().height / 2)

    addButtonEvent(ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_close"),function (sender)
        self:showPanelLayer()
    end)
    Util:enlargeCloseBtnClickArea(ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_close"),function (sender)
        self:showPanelLayer()
    end)
    
    addButtonEvent(ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_login"),function (sender)
        self:showPanelLayer()
    end)
    --手机注册验证码
    addButtonEvent(ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"),function (sender)
        if not Util:isValidPhone(editBoxPhone:getText()) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_3})
            return
        end 
        self.regTime = 60 
        ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setEnabled(false)
        ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setBright(false)
        ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setTitleColor(pinTxtColor)
        ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setTitleText(string.format(GameTxt.retry_send_code, 60))
        self.regSche1 = Scheduler:scheduler(1, handler(self, function ()
            if tolua.isnull(self) == true or self.regTime == nil then
                return
            end
            self.regTime = self.regTime - 1
            ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setTitleText(string.format(GameTxt.retry_send_code, self.regTime))   
            if self.regTime <= 0 then
                ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setEnabled(true)
                ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setBright(true)
                ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setTitleText(GameTxt.string_login_4)
                ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_pin"):setTitleColor(pinTxtColor)
                Scheduler:unschedule(self.regSche1)
                self.regSche1 = nil
            end
        end))
        --手机注册
        self:getVerificationCode(CMD.PHONE_LOGIN_PIN, {nation_code = self.registZoneNumber})
    end)
    --请求注册
    Util:addButtonScaleAnimFuncWithDScale(ccui.Helper:seekWidgetByName(phoneRegistLayer,"Button_phone_reg"),function (sender)
        if string.len(editBoxPhone:getText()) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_1})
            return
        end

        if not Util:isValidPhone(editBoxPhone:getText()) or tonumber(editBoxPhone:getText()) == nil then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_12})
            return
        end
        if string.len(editBoxPin:getText()) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_2})
            return
        end
        if string.len(editBoxPwd:getText()) == 0 then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_6})
            return
        end

        if Util:passWordLimitFunc1(self.pwd, self.affirmPwd) then
            return
        end
        if string.len(editBoxPwd:getText()) == 0 then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_6})
            return
        end
        
        GameNet:reReg()
        self:reqPinSignIn(1)
    end)

    local phoneCallback = function (index, descTbl, zonecode)
        self.registZoneNumber = zonecode
        self:refreshZoneEditTxt(phoneCodePannel, descTbl[index].code)
    end

    local cardlist = Util:initPhoneCodeDropList(phoneCodePannel, cc.size(imagePhoneFrame:getContentSize().width,70), self, phoneCallback)
    local listview = cardlist:getListView()
    local tpos = Util:convertALocalPosToBLocalPos(imagePhoneFrame, cc.p(0,-imagePhoneFrame:getContentSize().height/2), listview:getParent())
    listview:setPosition(tpos)
end

function LoginView:initFindPwd( ... )
    -- body
    local editBox = nil
    local pwdFindLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_login_find_pwd")
    local imagePhoneFrame = ccui.Helper:seekWidgetByName(pwdFindLayer,"Image_phone_frame")
    local phoneCodePannel = ccui.Helper:seekWidgetByName(pwdFindLayer,"phone_code_pannel")
    -- 手机输入框
    local editBoxPhone = cc.EditBox:create(cc.size(imagePhoneFrame:getContentSize().width - phoneCodePannel:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxPhone:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPhone:setFontName(GameRes.font1)
    editBoxPhone:setFontColor(txtFontColor)
    imagePhoneFrame:addChild(editBoxPhone)
    editBoxPhone:setName("editPhoneFrame")
    editBoxPhone:setFontSize(40)
    editBoxPhone:setPlaceholderFontSize(36)
    editBoxPhone:setPlaceHolder(GameTxt.string_login_1)
    editBoxPhone:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxPhone:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    editBoxPhone:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPhone:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxPhone:setPosition(phoneCodePannel:getPositionX() + phoneCodePannel:getContentSize().width/2+ 15, imagePhoneFrame:getContentSize().height / 2)

    -- 验证码输入框
    local imagePinFrame = ccui.Helper:seekWidgetByName(pwdFindLayer,"Image_pin_frame")
    local editBoxPin = cc.EditBox:create(cc.size(imagePinFrame:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxPin:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPin:setFontName(GameRes.font1)
    editBoxPin:setFontColor(txtFontColor)
    editBoxPin:setName("editPinFrame")
    editBoxPin:setFontSize(40)
    editBoxPin:setPlaceholderFontSize(36)
    editBoxPin:setPlaceHolder(GameTxt.string_login_2)
	editBoxPin:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editBoxPin:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxPin:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPin:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imagePinFrame:addChild(editBoxPin)
    editBoxPin:setPosition(imagePinFrame:getContentSize().width / 2 - editBoxOffSetX/4 + 10, imagePinFrame:getContentSize().height / 2)
    pwdFindLayer:setVisible(false)

    --新密码输入框
    local imagePwdFrame = ccui.Helper:seekWidgetByName(pwdFindLayer,"Image_pwd_frame")
    local editBoxPwd = cc.EditBox:create(cc.size(imagePwdFrame:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxPwd:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPwd:setFontName(GameRes.font1)
    editBoxPwd:setFontColor(txtFontColor)
    editBoxPwd:setName("editPwdFrame")
    editBoxPwd:setFontSize(40)
    editBoxPwd:setPlaceholderFontSize(36)
    editBoxPwd:setPlaceHolder(GameTxt.string_login_17)
    editBoxPwd:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxPwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBoxPwd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPwd:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imagePwdFrame:addChild(editBoxPwd)
    editBoxPwd:setPosition(imagePwdFrame:getContentSize().width / 2 - editBoxOffSetX/4 + 10, imagePwdFrame:getContentSize().height / 2)

    --确认密码
    local imageAffirmFrame = ccui.Helper:seekWidgetByName(pwdFindLayer,"Image_affirm_frame")
    local editBoxAffirm = cc.EditBox:create(cc.size(imageAffirmFrame:getContentSize().width, 80), cc.Scale9Sprite:create())
    editBoxAffirm:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxAffirm:setFontName(GameRes.font1)
    editBoxAffirm:setFontColor(txtFontColor)
    editBoxAffirm:setName("affirmPwdFrame")
    editBoxAffirm:setFontSize(40)
    editBoxAffirm:setPlaceholderFontSize(36)
    editBoxAffirm:setPlaceHolder(GameTxt.string_login_13)
    editBoxAffirm:setPlaceholderFontColor(placeHolderTxtColor)
    editBoxAffirm:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBoxAffirm:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxAffirm:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    imageAffirmFrame:addChild(editBoxAffirm)
    editBoxAffirm:setPosition(imageAffirmFrame:getContentSize().width / 2 - editBoxOffSetX/3 + 10, imageAffirmFrame:getContentSize().height / 2)

    addButtonEvent(ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_close"),function (sender)
        self:showPanelLayer()
    end)
    Util:enlargeCloseBtnClickArea(ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_close"),function (sender)
        self:showPanelLayer()
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_back"),function (sender)
        pwdFindLayer:setVisible(false)
        pwdLoginLayer:setVisible(true)
    end)
    
    Util:enlargeCloseBtnClickArea(ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_back"))
    --找回验证码
    addButtonEvent(ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"),function (sender)
        -- if string.len(editBoxPhone:getText()) < 11 then
        if not Util:isValidPhone(editBoxPhone:getText()) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_3})
            return
        end 
        self.findTime = 60 
        ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setEnabled(false)
        ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setBright(false)
        ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setTitleColor(pinTxtColor)
        ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setTitleText(string.format(GameTxt.retry_send_code, 60))
        self.findSche = Scheduler:scheduler(1, handler(self, function ()
            if tolua.isnull(self) == true or self.findTime == nil then
                return
            end
            self.findTime = self.findTime - 1
            ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setTitleText(string.format(GameTxt.retry_send_code, self.findTime))   
            if self.findTime <= 0 then
                ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setEnabled(true)
                ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setBright(true)
                ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setTitleText(GameTxt.string_login_4)
                ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_pin"):setTitleColor(pinTxtColor)
                Scheduler:unschedule(self.findSche)
            end
        end))
        --找回密码
        self:getVerificationCode(CMD.PHONE_LOGIN_PIN, {nation_code = self.findPwdZoneNumber})
    end)
    --重置密码
    Util:addButtonScaleAnimFuncWithDScale(ccui.Helper:seekWidgetByName(pwdFindLayer,"Button_reset"),function (sender)
        --这里测试直接跳下级窗口，实际要验证码通过才可以
        if not Util:isValidPhone(editBoxPhone:getText()) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_3})
            return
        end 
        --空判断
        if editBoxPin:getText() == "" then--or (editBoxPwd:getText() == "") or (editBoxAffirm:getText() == "") then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_2})
            return
        end
        if editBoxPwd:getText() ~= editBoxAffirm:getText() then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_8})
            return
        end
        if Util:passWordLimitFunc1(editBoxAffirm:getText()) then
            return
        end
        self:reqResetPwd()
    end)
    

    local phoneCallback = function (index, descTbl, zonecode)
        self.findPwdZoneNumber = zonecode
        self:refreshZoneEditTxt(phoneCodePannel, descTbl[index].code)
    end

    local cardlist = Util:initPhoneCodeDropList(phoneCodePannel, cc.size(imagePhoneFrame:getContentSize().width , 70), self, phoneCallback)
    local listview = cardlist:getListView()
    local tpos = Util:convertALocalPosToBLocalPos(imagePhoneFrame, cc.p(0 , -imagePhoneFrame:getContentSize().height/2), listview:getParent())
    listview:setPosition(tpos)
end

--输入框监听事件、该组建只有密码（editPwdFrame）、手机号（editPhoneFrame）、验证码（editPinFrame）三种输入
function LoginView:editboxEventHandler( strEventName,sender )
    logd(">>>>>>>>>>>>>>>>>>>>>>>", strEventName)
    --编辑开始
    if strEventName == "began" then
        --sender:setText("")   
        if sender:getName() == "editPhoneFrame" then
            self.phoneNum = ""
        elseif sender:getName() == "editPinFrame" then
            self.pin = ""
        elseif sender:getName() == "editPwdFrame" then
            local pwdLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_phone_login_pwd")
            if pwdLayer:isVisible() then --表明显示的是 用户手机登陆密码输入框
                 sender:setText(self.pwd)
            else
                self.pwd = ""
            end

        elseif sender:getName() == "affirmPwdFrame" then
            self.affirmPwd = ""
        elseif sender:getName() == "editInviteFrame" then
            self.invite = ""
        end
    --编辑结束        
    elseif strEventName == "return" or strEventName == "ended" then
        if sender:getName() == "editPhoneFrame" then
            self.phoneNum = sender:getText()
        elseif sender:getName() == "editPinFrame" then  
            self.pin = sender:getText()
        elseif sender:getName() == "editPwdFrame" then
            --密码是否可见
            --密码手机输入框
            local pwdLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_phone_login_pwd")
            if pwdLayer:isVisible() then
                --ended 方法 与 return方法是不一样的
                if strEventName == "ended" then
                    self.pwd = sender:getText()
                else
                    if self.visiblePwd then
                    else
                        local len = string.len(sender:getText())
                        if len > 0 then
                            local tmpStr = ''
                            for i = 1, len do
                                tmpStr = tmpStr..'*'
                            end
                            sender:setText(tmpStr)
                        end                        
                    end
                end
            else
                --其他密码框简单处理即可
                self.pwd = sender:getText()
            end

        elseif sender:getName() == "affirmPwdFrame" then
            self.affirmPwd = sender:getText()
        elseif sender:getName() == "editInviteFrame" then
            self.invite = sender:getText()
        end
        if self.phoneNum and  self.pin and self.pwd and self.affirmPwd then
            loga("phoneNum = "..self.phoneNum.." pin = "..self.pin.." pwd = "..self.pwd.." affirmPwd = "..self.affirmPwd)   
        end
    -- elseif strEventName == "changed" then 
    end
end

--获取验证码
function LoginView:getVerificationCode(cmd, paras)
    paras = paras or {}
    paras.nation_code =  paras.nation_code or "86"
    paras.send_type = paras.send_type or 0
    paras.cmdcode = cmd
    paras.phone = self.phoneNum
    paras.callback = function (para)
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = para.msg})
    end

    Util:getSMSCodeConfig(paras)
end

--请求验证码登录
function LoginView:reqPinSignIn( loginType )
    print("loginType >>>>>>>>>>>>>>>> ]]]]]]]]]", loginType)
    -- body
    local pinLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_phone_login_pin")
    if loginType == 1 then
    elseif loginType == 2 then
        local pinLoginLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_login")
        local imagePhoneFrame = ccui.Helper:seekWidgetByName(pinLoginLayer,"Image_phone_frame")
        local editBoxPhone = imagePhoneFrame:getChildByName("editPhoneFrame")
        local imagePinFrame = ccui.Helper:seekWidgetByName(pinLoginLayer,"Image_pin_frame")
        local editBoxPin = imagePinFrame:getChildByName("editPinFrame")--cc.EditBox:create(cc.size(470, 80), cc.Scale9Sprite:create())

        if (editBoxPhone:getText() == "") or (editBoxPin:getText() == "")then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_11})
            return
        end
        if not Util:isValidPhone(editBoxPhone:getText()) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_3})
            return
        end
    end
    
    local zone
    if loginType == 2 then
        zone = self.pinZoneNumber
    elseif loginType == 1 then
        zone = self.registZoneNumber
    end

    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
    local reg = qf.platform:getRegInfo() 
    local body = {}
    body.phone = self.phoneNum
    body.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..body.phone.."|"..reg.device_id)
    body.device_id = reg.device_id
    body.uuid = reg.uuid
    body.mac_addr = reg.mac_addr
    body.channel = reg.channel
    body.version = reg.version
    body.os = reg.os
    body.lang = reg.lang
    body.res_md5 = reg.res_md5
    body.code = self.pin
    body.zone = zone or "86"
    body.passwd = self.pwd or ""
    body.invite_code = self.invite or ""
    body.login_type = loginType or 1
    -- print("reqPinSignIn >>>>>>>>>>>>>>>>")
    -- dump(body)

    --把参数存起来以备自动重连
    local loginBody = json.encode(body)
    cc.UserDefault:getInstance():setStringForKey("loginBody", loginBody)
    if loginType == 1 then
        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_REG)
    elseif loginType == 2 then
        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_PIN)
    end

    cc.UserDefault:getInstance():flush()
    qf.event:dispatchEvent(ET.START_TO_LOGIN)
end

--请求密码登录
function LoginView:reqPwdSignIn( ... )
    -- body
    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
    local reg = qf.platform:getRegInfo()
    local body = {}
    body.phone = self.phoneNum
    body.passwd = self.pwd
    body.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..body.phone.."|"..body.passwd)
    body.channel = reg.channel
    body.version = reg.version
    body.os = reg.os
    body.zone = self.pinZoneNumber
    --把参数存起来以备自动重连
    local loginBody = json.encode(body)
    cc.UserDefault:getInstance():setStringForKey("loginBody", loginBody)
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_PWD)
    cc.UserDefault:getInstance():flush()
    qf.event:dispatchEvent(ET.START_TO_LOGIN)
    cc.UserDefault:getInstance():setBoolForKey("saveFlag", self.savePwdFlag)
end

function LoginView:reqWxLogin( ... )
    -- body
    --qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
    local orginInfo = qf.platform:getRegInfo()
    local ot = Util:getOpenIDAndToken()

    local device_id = orginInfo.device_id
    local body ={}
    body.sign = QNative:shareInstance():md5(UNITY_PAY_SECRET.."|"..ot.openid.."|"..ot.token.."|"..device_id)
    body.openid = ot.openid
    body.access_token = ot.token
    body.expire_date = ___tmpsdkaccountloginDate
    body.channel = orginInfo.channel
    body.version = orginInfo.version
    body.os = orginInfo.os
    body.lang = orginInfo.lang
    body.res_md5 = STRING_UPDATE_FILE_MD5 -- 更新文件列表的md5
    body.device_id = device_id
    --把参数存起来以备自动重连
    local loginBody = json.encode(body)
    cc.UserDefault:getInstance():setStringForKey("loginBody", loginBody)
    -- cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_WECHAT)
    cc.UserDefault:getInstance():flush()
    -- qf.event:dispatchEvent(ET.START_TO_LOGIN)
    -- do
    --     return
    -- end
    --body.hot_version = orginInfo.version
    --local cmd = Util:isLanguageChinese() and (ot.type == "1" and CMD.QQ_REG or CMD.WX_REG) or CMD.FACEBOOK_REG


    GameNet:send({cmd=CMD.WX_REG,body=body,timeout=nil,callback=function(rsp)
        loga("reqWxignIn rsp ==="..rsp.ret)

        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_WECHAT)
        cc.UserDefault:getInstance():flush()

        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
            qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
            return
        end
        Cache.user:updateCacheByLogin(rsp.model)
        cc.UserDefault:getInstance():setIntegerForKey(SKEY.UIN,Cache.user.uin)
        cc.UserDefault:getInstance():flush()
        local _config = GameNet:getDataBySignedBody(rsp.model.config, CMD.CONFIG)

        if not _config then
            -- 解析失败
            loga("-----------config-------------------config fail")
            -- GameNet:reReg()
        elseif xpcall(
            function() 
                Cache.Config:saveConfig(_config.model)
            end,
            function() 
                game.uploadError(debug.traceback())
                game.uploadError(" 存储config出错的model-->>"..tostring(_config.model))
            end) 
        then
            qf.event:dispatchEvent(ET.NET_GETCONFIG_DONE)
        else
            -- 保存配置失败/出错
            --GameNet:reReg()
        end
    end})
end

--请求重置密码
function LoginView:reqResetPwd( ... )
    -- body
    local body = {}
    body.phone = Encrypt:encryptData(self.phoneNum, UNITY_PAY_SECRET)
    body.code = Encrypt:encryptData(self.pin, UNITY_PAY_SECRET)
    body.zone = Encrypt:encryptData(self.findPwdZoneNumber, UNITY_PAY_SECRET)
    body.passwd = Encrypt:encryptData(self.pwd, UNITY_PAY_SECRET)

    self.find_pwd_req = nil
    self.find_pwd_req = cc.XMLHttpRequest:new()
    self.find_pwd_req.timeout = 52
    self.handler_scheduler = Util:runOnce(self.find_pwd_req.timeout, function( ... )
        if self.find_pwd_req then
            self.find_pwd_req:abort()
            self.find_pwd_req = nil
        end
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_14})
    end)

    self.find_pwd_req:registerScriptHandler(function(event)
        Util:stopRun(self.handler_scheduler)
        self.handler_scheduler = nil
        if self.find_pwd_req.status == 200 then
            if self.find_pwd_req.response then
                local model = json.decode(self.find_pwd_req.response)
                if model.ret ~= 0 then
                    if model.msg then
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = model.msg})
                    else
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_15})
                    end
                else
                    self:resetPwd()
                end
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_15})
            end
        end
    end)
    response_type = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.find_pwd_req.responseType = response_type
    self.find_pwd_req:open("POST", Util:getResetPWDURL())
    self.find_pwd_req:send(string.format("phone=%s&code=%s&zone=%s&passwd=%s", body.phone, body.code, body.zone, body.passwd))
end

function LoginView:resetPwd()
    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_16})
    local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", "")
    local pwd = cc.UserDefault:getInstance():getStringForKey("loginPwd", "")

    local phoneTable = string.split(phone,"|")
    local pwdTable = string.split(pwd,"|")
    if phoneTable and #phoneTable > 0 and pwdTable and #pwdTable > 0 then
        for i = 1, #phoneTable do
            if phoneTable[i] == tostring(self.phoneNum) then
                pwdTable[i] = tostring(self.pwd)
            end
        end
        local allPwd = table.concat(pwdTable, "|")
        cc.UserDefault:getInstance():setStringForKey("loginPwd", allPwd)
        cc.UserDefault:getInstance():flush()
    end
    self:showPanelLayer()
end

--请求设置密码
function LoginView:reqUpdatePwd( ... )
    -- body
    local body = {}
    body.phone = self.phoneNum
    body.passwd = self.pwd
    body.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..body.phone.."|"..body.passwd)
    body.zone = self.pinZoneNumber
    --把参数存起来以备自动重连
    local loginBody = json.encode(body)
    cc.UserDefault:getInstance():setStringForKey("setBody", loginBody)
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_SET)
    cc.UserDefault:getInstance():flush()
    -- qf.event:dispatchEvent(ET.START_TO_LOGIN)
    --实际上这个时候已经连接上了
    if GameNet:isConnected() then
        qf.event:dispatchEvent(ET.LOGIN_NET_GOTO_LOGIN)
    else
        qf.event:dispatchEvent(ET.START_TO_LOGIN)
    end
end

function LoginView:showPanelLayer( type )
    --先读取配置，看上次是验证码登录还是密码登录
    local phoneLoginType = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, "")
    local pwdLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_phone_login_pwd") --手机密码登陆
    local pinLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_phone_login_pin")--手机验证码登陆 还有设置密码
    local registLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_login_register") --手机注册
    local buttonLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_button") --三个主按钮
    local findLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_login_find_pwd") --找回密码

    if not type then
        local phoneEdit = nil
        local pwdEdit = nil
        local zoneEdit = nil
        if phoneLoginType == VAR_LOGIN_TYPE_PHONE_PIN then
            pinLayer:setVisible(true)
            pwdLayer:setVisible(false)
            self:setButtonLayerVisible(false)
            registLayer:setVisible(false)
            findLayer:setVisible(false)
            local pinLoginLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_login")
            pinLoginLayer:setVisible(true)
            local pinSetLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_set")
            pinSetLayer:setVisible(false)

            local imagePhoneFrame = ccui.Helper:seekWidgetByName(pinLayer,"Image_phone_frame")
            phoneEdit = imagePhoneFrame:getChildByName("editPhoneFrame")
            if self.phoneNum and self.phoneNum ~= "" and phoneEdit then
                phoneEdit:setText(self.phoneNum)
            end

            zoneEdit = pinLoginLayer:getChildByName("phone_code_pannel"):getChildByName("num")
            self:refreshZoneEditTxt(pinLoginLayer:getChildByName("phone_code_pannel"), self.pinZoneNumber)
        else
            pinLayer:setVisible(false)
            pwdLayer:setVisible(true)
            self:setButtonLayerVisible(false)
            registLayer:setVisible(false)
            findLayer:setVisible(false)
            local pwdLoginLayer = ccui.Helper:seekWidgetByName(pwdLayer,"Panel_pwd_login")
            pwdLoginLayer:setVisible(true)

            local imagePhoneFrame = ccui.Helper:seekWidgetByName(pwdLoginLayer,"Image_phone_frame")
            local imagePwdFrame = ccui.Helper:seekWidgetByName(pwdLoginLayer,"Image_pwd_frame")
            phoneEdit = imagePhoneFrame:getChildByName("editPhoneFrame")
            if self.phoneNum and self.phoneNum ~= "" and phoneEdit then
                phoneEdit:setText(self.phoneNum)
            end
            --记住密码
            pwdEdit = imagePwdFrame:getChildByName("editPwdFrame")
            zoneEdit = pwdLoginLayer:getChildByName("phone_code_pannel"):getChildByName("num")
            self:refreshZoneEditTxt(pwdLoginLayer:getChildByName("phone_code_pannel"), self.pinZoneNumber)
        end

        --手机登录自动填上次登录的账号和密码
        local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", nil)
        local pwd = cc.UserDefault:getInstance():getStringForKey("loginPwd", nil)
        local zone = cc.UserDefault:getInstance():getStringForKey("loginZone", nil)        
        print("ZZZZZZZZZZZZZZ", zone)
        if not phone or string.len(phone) == 0 then
            --没有登录过的手机号，隐藏下拉框按钮
            ccui.Helper:seekWidgetByName(pinLayer,"Panel_comboList"):setVisible(false)
            ccui.Helper:seekWidgetByName(pwdLayer,"Panel_comboList"):setVisible(false)
            return
        end

        local phoneTable = string.split(phone,"|")
        local pwdTable = string.split(pwd,"|")
        local zoneTable = string.split(zone, "|")
        if #phoneTable == 1 then
            ccui.Helper:seekWidgetByName(pinLayer,"Panel_comboList"):setVisible(false)
            ccui.Helper:seekWidgetByName(pwdLayer,"Panel_comboList"):setVisible(false)
        end

        if phoneEdit then
            self.phoneNum = phoneTable[#phoneTable]
            phoneEdit:setText(phoneTable[#phoneTable])
            pwd = pwdTable[#pwdTable]
        end

        if zoneEdit then
            print(">>>>>>>>>>>>>>> zoneTable")
            dump(zoneTable)

            if phoneLoginType == VAR_LOGIN_TYPE_PHONE_PIN then
                self.pinZoneNumber = zoneTable[#zoneTable]
            else
                self.pinZoneNumber = zoneTable[#zoneTable]
            end
            if self.pinZoneNumber == "" then
                self.pinZoneNumber =  "86"
            end
            self:refreshZoneEditTxt(zoneEdit:getParent(), self.pinZoneNumber)
        end

        if pwd and pwdEdit and self.savePwdFlag == true then
            self.pwd = pwd
            pwdEdit:setText(pwd)
            --密码是否可见
            if pwdLayer:isVisible() then
                if self.visiblePwd == true then
    
                else
                    local len = string.len(pwdEdit:getText())
                    if len > 0 then
                        local tmpStr = ''
                        for i = 1, len do
                            tmpStr = tmpStr..'*'
                        end
                        pwdEdit:setText(tmpStr)
                    end
                end
            end
        end
    else
        if type == "findPwd" then
            findLayer:setVisible(true)
            pinLayer:setVisible(false)
            pwdLayer:setVisible(false)
            self:setButtonLayerVisible(false)
            registLayer:setVisible(false)
        elseif type == "regist" then
            findLayer:setVisible(false)
            pinLayer:setVisible(false)
            pwdLayer:setVisible(false)
            self:setButtonLayerVisible(false)
            registLayer:setVisible(true)
        elseif type == "LoginTypePannel" then
            findLayer:setVisible(false)
            pinLayer:setVisible(false)
            pwdLayer:setVisible(false)
            self:setButtonLayerVisible(true)
            registLayer:setVisible(false)
            if not BOL_AUTO_RE_CONNECT then
                BOL_AUTO_RE_CONNECT = true 
                qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_EVENT,{content=GameTxt.game_reconnect_text, _type = 2})
            end
        elseif type == "setPwd" then
            pinLayer:setVisible(true)
            pwdLayer:setVisible(false)
            self:setButtonLayerVisible(false)
            registLayer:setVisible(false)
            findLayer:setVisible(false)
            local pinLoginLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_login")
            pinLoginLayer:setVisible(false)
            local pinSetLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_set")
            pinSetLayer:setVisible(true)
        elseif type == "null" then
            pinLayer:setVisible(false)
            pwdLayer:setVisible(false)
            self:setButtonLayerVisible(false)
            self:showLoginBtnPannel(false)
            registLayer:setVisible(false)
            findLayer:setVisible(false)
            local pinLoginLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_login")
            pinLoginLayer:setVisible(false)
            local pinSetLayer = ccui.Helper:seekWidgetByName(pinLayer,"Panel_pin_set")
            pinSetLayer:setVisible(false)
        end
    end
    self:updatePanelLayer(type)
end

--更新模块
function LoginView:updatePanelLayer( updateType )
    -- body
    if updateType == "regist" then
        local phoneRegistLayer = ccui.Helper:seekWidgetByName(self.root,"Panel_login_register")
        local imagePhoneFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_phone_frame")
        local editBoxPhone = imagePhoneFrame:getChildByName("editPhoneFrame")
        editBoxPhone:setText("")

        local imagePinFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_pin_frame")
        local editBoxPin = imagePinFrame:getChildByName("editPinFrame")
        editBoxPin:setText("")
        
        local imagePwdFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_pwd_frame")
        local editBoxPwd = imagePwdFrame:getChildByName("editPwdFrame")
        editBoxPwd:setText("")

        local imageAffirmFrame = ccui.Helper:seekWidgetByName(phoneRegistLayer,"Image_affirm_frame")
        local editBoxAffirm = imageAffirmFrame:getChildByName("affirmPwdFrame")
        editBoxAffirm:setText("")
    end
end

-- 射灯、美女动画逻辑
function LoginView:removepclogin()
    if not tolua.isnull(self.root)  then 
        if self.guangSchedule then
            Scheduler:unschedule(self.guangSchedule)
            self.guangSchedule=nil
        end
        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(function ( ... )
                -- body
                if self.bueatyAnimate then
                    self.bueatyAnimate:runAction(cc.MoveTo:create(0.3,cc.p(-self.bueatyAnimate:getContentSize().width,self.bueatyAnimate:getPositionY())))
                end
                if self.btn_bg then
                    self.btn_bg:runAction(cc.MoveTo:create(0.3,cc.p(Display.cx+self.btn_bg:getContentSize().width,self.btn_bg:getPositionY())))
                end
            end),cc.DelayTime:create(1)
            ,cc.CallFunc:create(function( ... )
        end)))
    end
end

-- 移除所有定时器
function LoginView:removeAllScheduler( ... )
    -- body
    if self.regSche then
        Scheduler:unschedule(self.regSche)
    end
    if self.regSche1 then
        Scheduler:unschedule(self.regSche1)
    end
    if self.findSche then
        Scheduler:unschedule(self.findSche)
    end
end

function LoginView:delayRun(time,cb)
    if time == nil or cb == nil then return end
    self:runAction(
        cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function() 
            if cb then cb() end
        end) 
    ))
end

function LoginView:getRoot() 
    return LayerManager.LoginLayer
end
--预加载mainview下的动画资源
function LoginView:enter()
    local config = require("src.games.game_hall.modules.main.config.AnimationConfig")
    Util:loadAnim(config, true)
end

function LoginView:refreshZoneEditTxt(zonePanel, txt)
    local arror = zonePanel:getChildByName("arror")
    local numTxt = zonePanel:getChildByName("num")
    local addStr = ""
    if not string.starts(txt, "+") then
        addStr = "+" .. addStr
    end
    local num = string.len(addStr .. txt)
    numTxt:setString(addStr .. txt)
    arror:setPositionX(numTxt:getContentSize().width + arror:getContentSize().width/2 + 30)
end

return LoginView
