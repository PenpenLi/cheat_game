local BindCardView = class("BindCardView", CommonWidget.PopupWindow)

BindCardView.TAG = "BindCardView"
local areaData = require("src.cache.other.BindCardData")
function BindCardView:ctor(args)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.bindCard)
    self.root:getChildByName("Panel_27"):setVisible(false)
    self:init(args)

    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.bindCard, child=self.root})
end

function BindCardView:init( args )
    -- body
    self:setArea()
    self.uinKey = "real_name_" .. Cache.user.uin
    self.winSize = cc.Director:getInstance():getWinSize()
    self.bindPanel = ccui.Helper:seekWidgetByName(self.root, "Panel_bind_card")
    self.managerPanel = ccui.Helper:seekWidgetByName(self.root, "Panel_manager")
    self:initBank()
    self:setZOrder(9999)
    --self:showWithType(args.showType)
end

function BindCardView:show( args )
    -- body
    args = args or {showType = 2}
    self:setVisible(true)
    self:showWithType(args.showType)
    BindCardView.super.show(self)
end

function BindCardView:setArea()
    -- body
    self.area = areaData
end

function BindCardView:initWithRootFromJson()
    return GameRes.bindCard
end

function BindCardView:isAdaptateiPhoneX()
    return true
end

function BindCardView:initBank( ... )
    -- body
    --开户姓名
    local imageOwnerFrame = ccui.Helper:seekWidgetByName(self.bindPanel,"Image_owner")
    local editBoxPay = cc.EditBox:create(cc.size(650, 80), cc.Scale9Sprite:create())
    editBoxPay:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPay:setFontName(GameRes.font1)
    editBoxPay:setFontColor(cc.c3b(0, 0, 0))
    imageOwnerFrame:addChild(editBoxPay)
    editBoxPay:setName("realName")
    editBoxPay:setFontSize(40)
    editBoxPay:setPlaceholderFontSize(36)
    editBoxPay:setPlaceHolder(GameTxt.string_bind_2)
    editBoxPay:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBoxPay:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPay:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxPay:setPosition(imageOwnerFrame:getContentSize().width * 0.5, imageOwnerFrame:getContentSize().height / 2)
    --支持的银行
    local body = {}
    body.uin = Cache.user.uin
    GameNet:send({cmd=CMD.GET_EXCHANGE_CONFIG,body=body,timeout=nil,callback=function(rsp)
        loga("initBankCardPanel rsp "..rsp.ret)
        if rsp.ret ~= 0 then
        else
            self.bankList = {}
            local btnChooseBank = ccui.Helper:seekWidgetByName(self.bindPanel, "Button_choose_bank")
            for i = 1, rsp.model.bank_list:len() do
                local modelItem = rsp.model.bank_list:get(i)
                local item = {}
                item.bank_id = modelItem.bank_id
                item.bank_name = modelItem.bank_name
                table.insert(self.bankList, item)
            end
            --dump(self.bankList)
            self.bankWidgetlist = CommonWidget.ComboList.new(5, #self.bankList, cc.size(650, 80), GameRes.image_item_normal, GameRes.image_item_select)
            if self.bankWidgetlist then
                --ccui.Helper:seekWidgetByName(pinLayer,"Panel_comboList"):setEnabled(false)
                self.bankWidgetlist:setPosition(cc.p(0, 0))
                local pos = cc.p(1045, 685)
                self.bankWidgetlist:setListPostion(pos)--(cc.p(imagePhoneFrame:getPositionX(), imagePhoneFrame:getPositionY()))
                self.bankWidgetlist:setName("cardlist")
                self.bankWidgetlist:setVisible(false)
                self.bankWidgetlist:setAutoHide("hide")
                self.root:addChild(self.bankWidgetlist)
                for i = 1, #self.bankList do
                    local item = self.bankWidgetlist:getItemByIndex(i)
                    item:setTitleText(self.bankList[i].bank_name)
                    addButtonEvent(item,function (sender)
                        --qf.event:dispatchEvent(ET.SEARCH_PAY_RECORD,{payType = i})
                        self.bankName = self.bankList[i].bank_name
                        ccui.Helper:seekWidgetByName(btnChooseBank,"Label_bank_name"):setString(self.bankList[i].bank_name)
                        ccui.Helper:seekWidgetByName(btnChooseBank,"Label_bank_name"):setVisible(true)
                        self.curBankId = self.bankList[i].bank_id
                        self.bankWidgetlist:setVisible(false)
                    end)
                end
            end
        end
    end})
    --省市合集
    local province = {}
    local city = {}
    local area = {}
    for k, v in ipairs(self.area) do
        table.insert(province, v.name)
        -- for k2, v2 in ipairs(v.city) do
        --     table.insert(city, v2.name)
        --     if v.area then
        --         for k3, v3 in ipairs(v.area) do
        --             table.insert(area, v3.name)
        --         end
        --     end
        -- end
    end
    --dump(province, "province  ------------")
    self.widgetProvince = nil
    self.widgetCity = nil
    self.widgetArea = nil

    local btnChooseProvince = ccui.Helper:seekWidgetByName(self.bindPanel, "Button_choose_province")
    ccui.Helper:seekWidgetByName(btnChooseProvince, "Label_province"):setVisible(false)
    local btnChooseCity = ccui.Helper:seekWidgetByName(self.bindPanel, "Button_choose_city")
    ccui.Helper:seekWidgetByName(btnChooseCity, "Label_city"):setVisible(false)
    --省控件
    self.widgetProvince = CommonWidget.ComboList.new(5, #province, cc.size(650, 80), GameRes.image_item_normal, GameRes.image_item_select)
    self.widgetProvince.list:setBounceEnabled(false)
    if self.widgetProvince then
        --ccui.Helper:seekWidgetByName(pinLayer,"Panel_comboList"):setEnabled(false)
        self.widgetProvince:setPosition(cc.p(0, 0))
        local pos = cc.p(1045, 605)
        self.widgetProvince:setListPostion(pos)--(cc.p(imagePhoneFrame:getPositionX(), imagePhoneFrame:getPositionY()))
        self.widgetProvince:setName("cardlist")
        self.widgetProvince:setVisible(false)
        self.widgetProvince:setAutoHide("hide")
        self.root:addChild(self.widgetProvince)
        for i = 1, #province do
            local item = self.widgetProvince:getItemByIndex(i)
            item:setTitleText(province[i])
            addButtonEvent(item,function (sender)
                ccui.Helper:seekWidgetByName(btnChooseProvince, "Label_province"):setVisible(true)
                ccui.Helper:seekWidgetByName(btnChooseProvince, "Label_place"):setVisible(false)
                ccui.Helper:seekWidgetByName(btnChooseProvince, "Label_province"):setString(province[i])
                self.province = province[i]
                self.widgetProvince:setVisible(false)
                --根据省创建市
                if self.widgetCity then
                    self.widgetCity:removeFromParent()
                    city = {}
                end
                --如果city长度为1，说明是直辖市，用区来代替
                if #self.area[i].city == 1 then
                   -- dump(self.area[i].city)
                    for k, v in ipairs(self.area[i].city[1].area) do
                        table.insert(city, v)
                    end
                else
                    for k, v in ipairs(self.area[i].city) do
                        table.insert(city, v.name)
                    end
                end
                --自动选第一个市
                ccui.Helper:seekWidgetByName(btnChooseCity, "Label_city"):setVisible(true)
                ccui.Helper:seekWidgetByName(btnChooseCity, "Label_place"):setVisible(false)
                ccui.Helper:seekWidgetByName(btnChooseCity, "Label_city"):setString(city[1])
                self.city = city[1]
                ---------------------------------------
                self.widgetCity = CommonWidget.ComboList.new(5, #city, cc.size(650, 80), GameRes.image_item_normal, GameRes.image_item_select)
                self.widgetCity.list:setBounceEnabled(false)
                if self.widgetCity then
                    --ccui.Helper:seekWidgetByName(pinLayer,"Panel_comboList"):setEnabled(false)
                    self.widgetCity:setPosition(cc.p(0, 0))
                    local pos = cc.p(1045, 520)
                    self.widgetCity:setListPostion(pos)--(cc.p(imagePhoneFrame:getPositionX(), imagePhoneFrame:getPositionY()))
                    self.widgetCity:setName("citylist")
                    self.widgetCity:setVisible(false)
                    self.widgetCity:setAutoHide("hide")
                    self.root:addChild(self.widgetCity)
                    
                    for j = 1, #city do
                        local item = self.widgetCity:getItemByIndex(j)
                        item:setTitleText(city[j])
                        addButtonEvent(item,function (sender)
                            ccui.Helper:seekWidgetByName(btnChooseCity, "Label_city"):setVisible(true)
                            ccui.Helper:seekWidgetByName(btnChooseCity, "Label_place"):setVisible(false)
                            ccui.Helper:seekWidgetByName(btnChooseCity, "Label_city"):setString(city[j])
                            self.city = city[j]
                            self.widgetCity:setVisible(false)
                        end)
                    end
                end
                --------------------------------------------
            end)
        end
    end
    --选择银行
    local btnChooseBank = ccui.Helper:seekWidgetByName(self.bindPanel, "Button_choose_bank")
    ccui.Helper:seekWidgetByName(btnChooseBank, "Label_bank_name"):setVisible(false)
    addButtonEvent(btnChooseBank,function (sender)
        self.bankWidgetlist:setVisible(true)
    end)
    --选择省
    addButtonEvent(btnChooseProvince,function (sender)
        self.widgetProvince:setVisible(true)
    end)
    --选择市
    addButtonEvent(btnChooseCity,function (sender)
        if self.widgetCity then
            self.widgetCity:setVisible(true)
        end
    end)
    --支行信息
    local imageBankFrame = ccui.Helper:seekWidgetByName(self.bindPanel,"Image_bank_account")
    local editBoxBank = cc.EditBox:create(cc.size(650, 80), cc.Scale9Sprite:create())
    editBoxBank:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxBank:setFontName(GameRes.font1)
    editBoxBank:setFontColor(cc.c3b(0, 0, 0))
    imageBankFrame:addChild(editBoxBank)
    editBoxBank:setName("bank")
    editBoxBank:setFontSize(40)
    editBoxBank:setPlaceholderFontSize(36)
    editBoxBank:setPlaceHolder(GameTxt.string_bind_3)
    editBoxBank:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBoxBank:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxBank:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxBank:setPosition(imageBankFrame:getContentSize().width * 0.5, imageBankFrame:getContentSize().height / 2)
    --银行卡号
    local imageSubBankFrame = ccui.Helper:seekWidgetByName(self.bindPanel,"Image_bank_sub")
    local editBoxBank = cc.EditBox:create(cc.size(650, 80), cc.Scale9Sprite:create())
    editBoxBank:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxBank:setFontName(GameRes.font1)
    editBoxBank:setFontColor(cc.c3b(0, 0, 0))
    imageSubBankFrame:addChild(editBoxBank)
    editBoxBank:setName("subbank")
    editBoxBank:setFontSize(40)
    editBoxBank:setPlaceholderFontSize(36)
    --editBoxBank:setPlaceHolder(GameTxt.string_bind_3)
    editBoxBank:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBoxPay:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxBank:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxBank:setPosition(imageSubBankFrame:getContentSize().width * 0.5, imageSubBankFrame:getContentSize().height / 2)
    --安全密码
    local imagePwdFrame = ccui.Helper:seekWidgetByName(self.bindPanel,"Image_pay_pwd")
    local editBoxPwd = cc.EditBox:create(cc.size(488, 80), cc.Scale9Sprite:create())
    editBoxPwd:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPwd:setFontName(GameRes.font1)
    editBoxPwd:setFontColor(cc.c3b(0, 0, 0))
    imagePwdFrame:addChild(editBoxPwd)
    editBoxPwd:setName("payFrame")
    editBoxPwd:setFontSize(40)
    editBoxPwd:setPlaceholderFontSize(36)
    editBoxPwd:setPlaceHolder(GameTxt.string_safebox_4)
    editBoxPwd:setPlaceholderFontColor(cc.c3b(204, 204, 204))
    editBoxPwd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBoxPwd:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
    editBoxPwd:setPosition(imagePwdFrame:getContentSize().width * 0.5, imagePwdFrame:getContentSize().height / 2)
    --找回安全密码
    addButtonEvent(ccui.Helper:seekWidgetByName(self.bindPanel,"Button_find"),function (sender)
        self:showFindPwd()
    end)
    self.subBank = ""
    self.editCoinNum = ""
    self.payPwd = ""
end

function BindCardView:getRealName()
    local uinKey = self.uinKey
    local realName = cc.UserDefault:getInstance():getStringForKey(uinKey, "")
    if realName ~= "" then --找到了对应的realname
        return realName
    else --如果没有的话 就从老版本中的realName中去找
        local realNameTemp = cc.UserDefault:getInstance():getStringForKey("realName", "")
        if realNameTemp ~= "" then --如果老版本中的姓名 直接使用这个realName
            cc.UserDefault:getInstance():setStringForKey(uinKey, realNameTemp)
            cc.UserDefault:getInstance():setStringForKey("realName", "")
            return realNameTemp
        else --都没有的话暂时设定这个name 不存在
        end
    end
end

function BindCardView:updateBank( ... )
    -- body
    -- local realName = cc.UserDefault:getInstance():getStringForKey("realName") -- 绑定用户名
    local realName = self:getRealName()
    if realName then
        local warning = ccui.Helper:seekWidgetByName(self.bindPanel,"Panel_warning2")
        ccui.Helper:seekWidgetByName(warning,"Label_name"):setString(realName)
        local imageOwnerFrame = ccui.Helper:seekWidgetByName(self.bindPanel,"Image_owner")
        imageOwnerFrame:setVisible(false)
    end

    --关闭按钮
    local closeButton = ccui.Helper:seekWidgetByName(self.bindPanel,"Button_close")
    addButtonEvent(closeButton,function (sender)
        self:close()
    end)
    Util:enlargeCloseBtnClickArea(closeButton)
    --请求按钮
    local reqButton = ccui.Helper:seekWidgetByName(self.bindPanel,"Button_request")
    addButtonEvent(reqButton,function (sender)
        self:requestByType(1)
    end)
    
    local agreementTxt = ccui.Helper:seekWidgetByName(self.bindPanel,"Label_16")
    agreementTxt:setTouchEnabled(true)
    addButtonEvent(agreementTxt,function (sender)
        self.root:setVisible(false)
        qf.event:dispatchEvent(ET.AGREEMENT, {cb = function ()
            self.root:setVisible(true)
        end})
    end)

    self.checkAgreementBtn = ccui.Helper:seekWidgetByName(self.bindPanel,"CheckBox_15")

    self:initManager()
end

function BindCardView:checkInValidRealName()
    self.realName = self.realName or ""
    local utfLen = string.utf8len(self.realName)
    local strLen = string.len(self.realName)
    if utfLen > 5 then --最多5个汉字
        return true
    end
    
    if utfLen * 3 == strLen then
        return false
    else
        return true
    end
end

function BindCardView:checkInValidBankNumber(bankNumber)
    if Util:checkOnlyDigitAndLetter(bankNumber) then
        return false
    end
    return true
end


function BindCardView:checkInValidSubBank(subBank)
    local arr = string.utf8List(subBank)
    for i, v in ipairs(arr) do
        if string.len(v) == 1 and Util:checkIsLetter(string.byte(v)) then
            return true
        end
    end
    return false
end

function BindCardView:initManager( ... )
    -- body
    local panelInfo = ccui.Helper:seekWidgetByName(self.managerPanel,"Panel_info")
    local itemModel = ccui.Helper:seekWidgetByName(panelInfo,"Panel_item")
    local cardList = ccui.Helper:seekWidgetByName(panelInfo,"ListView_card")
    cardList:setItemModel(itemModel)
    cardList:removeAllItems() 
    itemModel:setVisible(false)

    local body = {}
    body.uin = Cache.user.uin
    body.bind_type = 1 --1 = 银行卡
    GameNet:send({cmd=CMD.GET_BINDING_CONFIG,body=body,timeout=nil,callback=function(rsp)
        -- loga("updateBankPanel rsp "..rsp.ret)
        if rsp.ret ~= 0 then
        else
            for i = 1, rsp.model.bank_list:len() do
                cardList:pushBackDefaultItem()
                local itemCount = #cardList:getItems()
                local curItem = cardList:getItem(itemCount - 1)
                curItem:setVisible(true)
                local modelItem = rsp.model.bank_list:get(i)
                local bank_num = modelItem.bank_num
                if not Util:checkOnlyDigitAndLetter(bank_num) then --是否含有中文 有中文字符说明有问题 则替换为此种显示方式
                    bank_num = "0000000000000000"
                end

                ccui.Helper:seekWidgetByName(curItem,"Label_desc"):setString(modelItem.bank_name.."  "..string.sub(bank_num, 1, 4).."**** **** ****"..string.sub(bank_num, -3, -1))

                if i == 1 then
                    ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setVisible(false)
                else
                    ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setVisible(true)
                end
                ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setEnabled(true)
                ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setTouchEnabled(true)
                --解除绑定
                addButtonEvent(ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"),function (sender)
                    if itemCount == 1 then
                        return
                    end
                    local cardBody = {}
                    cardBody.uin = Cache.user.uin
                    cardBody.bind_type = 1 --解绑银行卡
                    cardBody.bind_op = 2
                    print("banke_numbe >>>>>>>>>>>>", bank_num)
                    cardBody.user_bank_num = bank_num
                    cardBody.safe_password = self.payPwd
                    dump(cardBody)
                    GameNet:send({cmd=CMD.BIND_CARD,body=cardBody,timeout=nil,callback=function(rsp)
                        if rsp.ret ~= 0 then
                            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_status_1})
                        else
                            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_status_2})
                            curItem:removeFromParent(true)
                            qf.event:dispatchEvent(ET.FRESH_CARD_LIST)
                        end
                    end})
                end)
            end
        end
    end})
    --添加银行卡
    addButtonEvent(ccui.Helper:seekWidgetByName(panelInfo,"Panel_add_card"),function (sender)
        self.bindPanel:setVisible(true)
        self.managerPanel:setVisible(false)
    end)
    --关闭按钮
    local closeBtn = ccui.Helper:seekWidgetByName(self.managerPanel,"Button_close")
    addButtonEvent(closeBtn,function (sender)
        -- if self.preViewCallBack then
        --     self.preViewCallBack()
        -- end
        -- self:setVisible(false)
        self:close()
    end)
    
    Util:enlargeCloseBtnClickArea(closeBtn)
end

function BindCardView:editboxEventHandler( strEventName,sender )
    -- body
    if strEventName == "began" then
        --sender:setText("")  
        if sender:getName() == "bank" then
            --self.editCoinNum = "" 
        elseif sender:getName() == "subbank" then     
            --self.subBank = ""   
        elseif sender:getName() == "payFrame" then     
            --self.payPwd = ""   
        elseif sender:getName() == "realName" then    
            --self.realName = ""
        end
    elseif strEventName == "ended" then
                                                      
    elseif strEventName == "return" then
        if sender:getName() == "bank" then
            local editCoinNum = string.upper(sender:getText())
            if self:checkInValidBankNumber(editCoinNum) then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_error_3})
                sender:setText(self.editCoinNum)
                return
            end
            self.editCoinNum = editCoinNum
            sender:setText(editCoinNum)
        elseif sender:getName() == "subbank" then
            local subBank = string.upper(sender:getText())
            if self:checkInValidSubBank(subBank) then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_4})
                sender:setText(self.subBank)
                return
            end
            self.subBank = string.upper(sender:getText())
        elseif sender:getName() == "payFrame" then
            local payPwd =sender:getText() 
            if Util:payLimitFunc1(payPwd) then
                sender:setText(self.payPwd)
                return
            end
            self.payPwd = payPwd
        elseif sender:getName() == "realName" then
            self.realName = sender:getText()
			sender:setText(self.realName)
        end                                   
    elseif strEventName == "changed" then
    end
end

function BindCardView:showWithType( showType )
    if showType == 1 then --银行卡管理
        self.bindPanel:setVisible(false)
        self.managerPanel:setVisible(true)
    elseif showType == 2 or showType == 3  then --安全密码
        self.bindPanel:setVisible(true)
        self.managerPanel:setVisible(false)
    end
    self:initWithType(showType)
end

function BindCardView:initWithType( showType )
    -- body
    --1 = 绑定银行卡（添加）， 2 = 绑定银行卡（未绑定过）
    local panelMain = nil 
    if showType == 1 then
        self:updateBank()
    elseif showType == 2 then
        panelMain = self.payPwdPanel
        self:updateBank()
    elseif showType == 3 then

    end
end

--找回密码页面
function BindCardView:showFindPwd( ... )
    -- body
    --修改安全密码
    if Cache.user:isBindPhone() then
        qf.event:dispatchEvent(ET.CHANGE_PWD, {actType = 1, showType = 2})
    else
        qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 6})
    end
end

--请求操作
function BindCardView:requestByType( reqType )
    -- body
    if reqType == 1 then
        ---------验证数据完整--------------
        if not self.realName or self.realName == "" then
            self.realName = cc.UserDefault:getInstance():getStringForKey(self.uinKey, "")
        end
        if not self.realName or string.len(self.realName) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_5})
            return
        end
        if not self.bankName or string.len(self.bankName) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_6})
            return
        end
        if not self.curBankId or string.len(self.curBankId) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_6})
            return
        end
        if not self.province or string.len(self.province) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_7})
            return
        end
        if not self.city or string.len(self.city) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_8})
            return
        end
        if not self.subBank or string.len(self.subBank) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_9})
            return
        end
        if not self.editCoinNum or string.len(self.editCoinNum) == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_10})
            return
        end
        ----------------------------------
        --检查是否是纯中文字符
        if self:checkInValidRealName() then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_11})
            return
        end
        -- if self.checkAgreementBtn:getSelectedState() == false then
        --     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_12})
        --     return
        -- end

        local body = {}
        body.uin = Cache.user.uin
        body.bind_type = 1
        body.bind_op = 1
        body.user_bank_info = {} --要绑定的银行卡信息
        body.user_bank_info.bank_name = self.bankName
        body.user_bank_info.bank_num = self.editCoinNum
        body.user_bank_info.bank_province = self.province
        body.user_bank_info.bank_city = self.city
        body.user_bank_info.user_name = self.realName
        body.user_bank_info.sub_bank_name = self.subBank
        body.user_bank_info.bank_id = self.curBankId
        body.safe_password = self.payPwd
        dump(body, "requestByType req ")
        GameNet:send({cmd=CMD.BIND_CARD,body=body,timeout=nil,callback=function(rsp)
            loga("requestByType rsp "..rsp.ret)
            if rsp.ret ~= 0 then
                if rsp.ret == 1049 then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_exchange_12})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_13})                    
                end
            else
                cc.UserDefault:getInstance():setStringForKey(self.uinKey, self.realName) -- 绑定用户名
                cc.UserDefault:getInstance():flush()
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_14})
                qf.event:dispatchEvent(ET.FRESH_CARD_LIST)
                self:close()
            end
        end})
    elseif reqType == 2 or reqType == 3 then
        local body = {}
        body.phone = Cache.user.is_bind_phone
        body.code = self.pin
        body.zone = "86"
        body.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..body.phone.."|"..body.code.."|"..body.zone)
        body.new_password = self.affirmPwd
        GameNet:send({cmd=CMD.SAFE_CHANGE_PASSWORD,body=body,timeout=nil,callback=function(rsp)
            loga("changed safeBox pwd rsp "..rsp.ret)
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_15})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_invite_3})
                -- if self.preViewCallBack then
                --     self.preViewCallBack()
                -- end
                -- self:setVisible(false)
                self:close()
            end
        end})
    end
end

function BindCardView:getRoot() 
    return LayerManager.PopupLayer
end

function BindCardView:setPreViewCallback( callback )
    -- body
    self.preViewCallBack = callback
end

function BindCardView:test()
    self.bindPanel:setVisible(false)
    self.managerPanel:setVisible(true)
    local panelInfo = ccui.Helper:seekWidgetByName(self.managerPanel,"Panel_info")
    local itemModel = ccui.Helper:seekWidgetByName(panelInfo,"Panel_item")
    local cardList = ccui.Helper:seekWidgetByName(panelInfo,"ListView_card")
    cardList:setItemModel(itemModel)
    cardList:removeAllItems() 
    itemModel:setVisible(false)    
    local bank_list = {
        [1] = {bank_num = "123123123", bank_name = "阿斯顿姜辣蛇开放的"},
        [2] = {bank_num = "123123123", bank_name = "阿斯顿姜辣蛇开放的"},
        [3] = {bank_num = "123123123", bank_name = "阿斯顿姜辣蛇开放的"},
        [4] = {bank_num = "123123123", bank_name = "阿斯顿姜辣蛇开放的"}
    }

    for i,v in ipairs(bank_list) do
        cardList:pushBackDefaultItem()
        local itemCount = #cardList:getItems()
        local curItem = cardList:getItem(itemCount - 1)
        curItem:setVisible(true)

        local modelItem = v
        if not Util:checkOnlyDigitAndLetter(modelItem.bank_num) then --是否含有中文 有中文字符说明有问题 则替换为此种显示方式
            modelItem.bank_num = "0000000000000000"
        end

        ccui.Helper:seekWidgetByName(curItem,"Label_desc"):setString(modelItem.bank_name.."  "..string.sub(tostring(modelItem.bank_num), 1, 4).."**** **** ****"..string.sub(tostring(modelItem.bank_num), -3, -1))

        if i == 1 then
            ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setVisible(false)
        else
            ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setVisible(true)
        end
        ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setEnabled(true)
        ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"):setTouchEnabled(true)
        --解除绑定
        addButtonEvent(ccui.Helper:seekWidgetByName(curItem,"Label_no_bind"),function (sender)
            -- print("zxvcasdfwqe 21312", itemCount)
            print(#cardList:getItems())
            if itemCount == 1 then
                return
            end
            print(">>>>>>>>", i)
            -- local cardBody = {}
            -- cardBody.uin = Cache.user.uin
            -- cardBody.bind_type = 1 --解绑银行卡
            -- cardBody.bind_op = 2
            -- cardBody.user_bank_num = modelItem.bank_num
            -- cardBody.safe_password = self.payPwd
            -- dump(cardBody)
            -- GameNet:send({cmd=CMD.BIND_CARD,body=cardBody,timeout=nil,callback=function(rsp)
            --     if rsp.ret ~= 0 then
                --     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_status_1})
                -- else
                    -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_bind_status_2})
                    curItem:removeFromParent(true)
                    -- cardList:removeItem(i - 1)
                    -- qf.event:dispatchEvent(ET.FRESH_CARD_LIST)
            --     end
            -- end})
        end)
    end
                -- for i = 1, rsp.model.bank_list:len() do
        --         -- local modelItem = rsp.model.bank_list:get(i)

        -- end

end

return BindCardView