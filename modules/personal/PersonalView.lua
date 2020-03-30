--[[
    个人信息界面
]]
--local PersonalView = class("PersonalView", qf.view)
local PersonalView = class("PersonalView", CommonWidget.PopupWindow)

--玩牌数据不展示进桌前后差额为0的数据
--保险箱存取产生金额变动才进行展示
PersonalView.TAG = "PersonalView"
local IconConfig = {
    ZFB = 1,     --支付宝
    YL = 2,      --银联
    WX = 3,      --微信
    WP = 4,      --玩牌
    SF = 5,      --上分
    SB = 6,      --保险箱
    TX = 7,      --提现
    XF = 8,      --下分
    YSF = 9,     --云闪付
    SCHB = 10,   --首充红包
    TXFL = 11,   --提现返利
}

local TypeConfig = {
    ALL = 1, --全部
    CZ = 2,  --充值
    TX = 3,  --提现
    WP = 4,  --玩牌
    SXF = 5, --上下分
    SB = 6   --保险箱
}

local specialFormatNumber = function (number, bop)
    local _number = math.abs(number)
    local _numberStr = ""
    if (_number >= 10000) then
        _numberStr = _numberStr .. string.formatnumberthousands(_number)
    else
        _numberStr = _numberStr .. _number
    end

    if bop then
        if number > 0 then
            _numberStr = "+" .. _numberStr
        elseif number < 0 then
            _numberStr = "-" .. _numberStr
        elseif number == 0 then
            _numberStr = _numberStr
        end
    end
    return Util:NoRoundedOff(_numberStr, 2)
end

local copyFunc = function (copyStr)
    return function ()
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.person_txt_1})
        qf.platform:copyTxt({txt = copyStr})
    end
end

--将时间戳转化为时间描述字符串, 12-20 11:25
local getTimeDesc = function(timestamp)
    local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local time_str = month .. "-" .. day .. " " .. hour .. ":" ..min
    return time_str
end



function PersonalView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.personal)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.personal, child=self.root})
    self:init(parameters)
end

function PersonalView:initUI()
    local uiTbl = {
        {name = "Panel_info",        path = "Panel_frame"},
        {name = "baseInfoBtn",       path = "Panel_frame/Panel_tab/Button_base_info",  handler = handler(self, self.onButtonEvent)},
        {name = "payRecordBtn",      path = "Panel_frame/Panel_tab/Button_pay_record",  handler = handler(self, self.onButtonEvent)},


        {name = "baseInfoPanel",     path = "Panel_frame/Panel_base_info"},
        {name = "pwdBoxBtn",         path = "Panel_frame/Panel_base_info/Button_pwd_box",  handler = handler(self, self.onButtonEvent)},
        {name = "changeBtn",         path = "Panel_frame/Panel_base_info/Button_change_account",  handler = handler(self, self.onButtonEvent)},
        {name = "bindBtn",           path = "Panel_frame/Panel_base_info/Button_blind_phone",  handler = handler(self, self.onButtonEvent)},
        {name = "closeBtn",          path = "Panel_frame/Button_close",  handler = handler(self, self.onButtonEvent)},
        {name = "modelPanel",          path = "Panel_frame/model_Panel"},

        {name = "payRecordPanel",    path = "Panel_frame/Panel_pay_record"},
        {name = "datePanel",         path = "Panel_frame/Panel_pay_record/upPanel/datePanel"},
        {name = "typePanel",         path = "Panel_frame/Panel_pay_record/upPanel/typePanel"},
        {name = "detailPanel",         path = "Panel_frame/Panel_pay_record/listPanel/detailPanel"},

        {name = "detailDesc",         path = "Panel_frame/Panel_pay_record/listPanel/detailPanel/selectBtn/desc"},
        {name = "detailDownImg",         path = "Panel_frame/Panel_pay_record/listPanel/detailPanel/selectBtn/downImg"},
        {name = "detailBtn",         path = "Panel_frame/Panel_pay_record/listPanel/detailPanel/selectBtn"},

        {name = "detailDesc2",         path = "Panel_frame/Panel_pay_record/listPanel/detailPanel/selectBtn2/desc"},
        {name = "detailDownImg2",         path = "Panel_frame/Panel_pay_record/listPanel/detailPanel/selectBtn2/downImg"},
        {name = "detailBtn2",         path = "Panel_frame/Panel_pay_record/listPanel/detailPanel/selectBtn2"},

        {name = "detailList",         path = "Panel_frame/Panel_pay_record/listPanel/detailList"},
        {name = "detailItem",         path = "Panel_frame/Panel_pay_record/listPanel/detailList/itemPanel"},
        {name = "NoRecordListPanel",    path = "Panel_frame/Panel_pay_record/listPanel/noRecord"},
        {name = "RecordListPanel",    path = "Panel_frame/Panel_pay_record/listPanel"},
        {name = "nodataItem",         path = "Panel_frame/nodata_Item"},

        {name = "Panel_choose",      path = "Panel_choose_change"},
        {name = "Panel_op",          path = "Panel_op"}, 
    }

    Util:bindUI(self, self.root, uiTbl)
    self.detailDesc.x =  self.detailDesc:getPositionX()
    self.detailDownImg.x =  self.detailDownImg:getPositionX()
    self.detailBtn.x =  self.detailBtn:getPositionX()
    self.detailDownImg2.x =  self.detailDownImg2:getPositionX()
    self.detailDesc2.x =  self.detailDesc2:getPositionX()
    self.detailBtn2.x =  self.detailBtn2:getPositionX()
    
    self.pwdBoxBtn.x = self.pwdBoxBtn:getPositionX()
    self.changeBtn.x = self.changeBtn:getPositionX()
    self.modelPanel:setAnchorPoint(cc.p(0.5, 1))
    self.nodataItem:getChildByName("Label_32"):setString(GameTxt.person_txt_2)
end

function PersonalView:init()
    -- body
    self:initData()
    self:initUI()
    self:initBaseInfo()
    self:initWalletRecord()
    self.payRecordBtn.x = self.payRecordBtn:getPositionX()
    self.baseInfoBtn.x = self.baseInfoBtn:getPositionX()
    self:initOp()
    self:initEditBox()--初始化输入框
    self:updateTabWithUI(self.baseInfoBtn)
    self:initChooseInfo()
end

function PersonalView:initData()
    self._datelist = Cache.walletInfo:getDateList()
    self._detailDataList = Cache.walletInfo:getDetailList()
end

function PersonalView:onButtonEvent(sender)
    if sender.name == "payRecordBtn" or sender.name == "baseInfoBtn" then
        self:updateTabWithUI(sender)
    elseif sender.name == "pwdBoxBtn" then
        self.Panel_choose:setVisible(true)
    elseif sender.name ==  "changeBtn" then
        self:changeFunc()
    elseif sender.name == "bindBtn" then
        self:doBindFunc()
    elseif sender.name == "closeBtn" then
        self:close()
    end
end

function PersonalView:changeFunc()
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    cc.UserDefault:getInstance():setStringForKey("loginBody", "")
    cc.UserDefault:getInstance():flush()
    qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
    MusicPlayer:setBgMusic()
    MusicPlayer:stopBackGround()
    ModuleManager:removeSubGameHall()
    PopupManager:removeAllPopup()
end

function PersonalView:doBindFunc()
    local callfunc = function ( ... )
        -- body
        self:updateButton()
        self:initBaseInfo()
    end
    qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 6, cb = callfunc})
end

function PersonalView:initWithRootFromJson()
    return GameRes.personal
end

function PersonalView:isAdaptateiPhoneX()
    return true
end

function PersonalView:updateTabWithUI(sender)
    -- body
    local btnList = {self.baseInfoBtn, self.payRecordBtn}
    local textureTbl = {GameRes.player_image_4, GameRes.player_image_9}
    local selTextureTbl = {GameRes.player_image_1, GameRes.player_image_8}
    local panelTbl = {self.baseInfoPanel, self.payRecordPanel}
    local ox = 5
    for i, v in ipairs(btnList) do
        v:setEnabled(true)
        v:setBright(true)
        v:getChildByName("Image_title"):loadTexture(textureTbl[i])
        v:setPositionX(v.x)
        panelTbl[i]:setVisible(false)
        if v == sender then
            sender:getChildByName("Image_title"):loadTexture(selTextureTbl[i])
            sender:setEnabled(false)
            sender:setBright(false)
            sender:setPositionX(v.x+ox)
            panelTbl[i]:setVisible(true)
        end
    end

    --只需要第一次点击按钮的时候进行刷新 其余情况下默认就好了    
    if sender == self.payRecordBtn and self.bFirstSearch == nil then
        self.bFirstSearch = true
        self:showPanelPayPanel()
    end
end

function PersonalView:initBaseInfo( ... )
    --id
    ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Label_id"):setString("ID:"..Cache.user.uin)
    --coin
    ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Label_gold"):setString(Util:getFormatString(Cache.user.gold))
    --gold
    ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Image_gold"):loadTexture(Cache.packetInfo:getGoldImg())
    --phone
    if Cache.user:isBindPhone() then
        ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Label_blind_phone"):setString(GameTxt.string_person_1..Cache.user.is_bind_phone)
    else
        ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Label_blind_phone"):setString(GameTxt.string_person_2)
    end
    --invite
    local frame = ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Image_invite")
    ccui.Helper:seekWidgetByName(frame,"Label_invite"):setString(GameTxt.string_person_3..Cache.user.invite_code)
    --sex
    local male = ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Button_male")
    ccui.Helper:seekWidgetByName(male,"Image_flag"):setVisible((Cache.user.sex == 0))
    local female = ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Button_female")
    ccui.Helper:seekWidgetByName(female,"Image_flag"):setVisible((Cache.user.sex == 1))
    --修改性别
    addButtonEvent(male,function (sender)
        ccui.Helper:seekWidgetByName(male,"Image_flag"):setVisible(true)
        ccui.Helper:seekWidgetByName(female,"Image_flag"):setVisible(false)
        self:updateNickAndSex(Cache.user.nick, 0)
    end)
    addButtonEvent(female,function (sender)
        ccui.Helper:seekWidgetByName(male,"Image_flag"):setVisible(false)
        ccui.Helper:seekWidgetByName(female,"Image_flag"):setVisible(true)
        self:updateNickAndSex(Cache.user.nick, 1)
    end)

    --head
    Util:updateUserHead(ccui.Helper:seekWidgetByName(self.Panel_info,"Image_head"), Cache.user.portrait, Cache.user.sex, {add = true, sq = false, url = true, circle = false})

    --上传头像
    local headImage = ccui.Helper:seekWidgetByName(self.Panel_info,"Image_head")
    local btnCover = ccui.Helper:seekWidgetByName(self.Panel_info,"Button_head_cover")
    addButtonEvent(btnCover,function (sender)
        self.Panel_op:setVisible(true)
    end)
    self:updateButton()
end

local selectColor = cc.c3b(182, 211, 253)
local unSelectColor = cc.c3b(173, 173, 173)

function PersonalView:initDropList(descTbl, sbtn, itemsize, cpos, callback)
    paras = paras or {}
    local tempPanel = self.modelPanel:clone()
    -- dump(descTbl)
    local dx = 8
    local paras = {
        selectFunc = function (paras)
            if paras.act == "sel" then
                paras.item:setTitleColor(selectColor)
            else
                paras.item:setTitleColor(unSelectColor)
            end
        end,
        noline = true,
        maskPos = true,
        diPanelConfig = {
            node = tempPanel,
            pos = cc.p(-(itemsize.width+dx-2)/2, -itemsize.height*#descTbl -4)
        },
        capInsect = true
    }
    tempPanel:setVisible(true)
    tempPanel:setContentSize(cc.size(itemsize.width+dx, (itemsize.height * #descTbl) + 10))
    local cardlist
    cardlist = CommonWidget.ComboList.new(#descTbl, #descTbl, itemsize, GameRes.new_image_item_normal, GameRes.new_image_item_select, paras)
    self.root:addChild(cardlist)
    cardlist:setPosition(cpos)
    local opos = cardlist:convertToNodeSpace(cc.p(cardlist.mask:getPosition()))
    Util:setPosOffset(cardlist.mask, opos)
    cardlist:setAutoHide()
    for i = 1, #descTbl do
        local item = cardlist:getItemByIndex(i)
        item:setTitleText(descTbl[i].typename)
        addButtonEvent(item,function (sender)
            sbtn:getChildByName("desc"):setString(descTbl[i].typename)
            cardlist:setVisible(false)
            cardlist:setCursor(i)
            if callback then
                callback(i)
            end
        end)
    end

    sbtn:setEnabled(true)
    sbtn:setTouchEnabled(true)
    addButtonEvent(sbtn, function ( ... )
        cardlist:setVisible(true)
    end)
    local sbtnSize = sbtn:getContentSize()
    local _listview = cardlist:getListView()
    local tpos = Util:convertALocalPosToBLocalPos(sbtn, cc.p(0,-sbtnSize.height/2), _listview:getParent())
    _listview:setPosition(tpos)
    local tpos2 = Util:convertALocalPosToBLocalPos(sbtn, cc.p(0,-sbtnSize.height/2), tempPanel:getParent())
    tempPanel:setPosition(tpos2)
    return cardlist
end

function PersonalView:getDetailDataByQueryId(queryId)
    for i, v in ipairs(self._detailDataList) do
        if v.queryId == queryId then
            return v
        end
    end
end

function PersonalView:refreshDetailBtn()
    local detail = self:getDetailDataByQueryId(self._type)
    if not detail then
        return
    end
    
    local detailData = detail.descTbl
    if not detailData then
        return
    end
    self.detailBtn2:setVisible(false)
    self.detailBtn:setVisible(false)
    local csize
    local detailBtn, detailDesc
    local tpos = cc.p(235,194)
    local descOffX = 0
    local descImgOffX = 0
    local descBtnX = 0

    if self._type == 5 then
        detailBtn = self.detailBtn2
        detailDesc = self.detailDesc2
        detailDownImg = self.detailDownImg2
        csize = cc.size(223, 60)
    else
        detailBtn = self.detailBtn
        detailDesc = self.detailDesc
        detailDownImg = self.detailDownImg
        csize = cc.size(343, 60)
    end

    if self._type == 5 then
        tpos = cc.p(291, 195)
    else
        descOffX = 43
        descImgOffX = 65
        if self._type == 4 then
            descBtnX = -20
            descOffX = 30
            descImgOffX = 70
        elseif self._type == 3 then
            descBtnX = -110
        elseif self._type == 1 then
            descBtnX = -80
        elseif self._type == 2 then
            descBtnX = -80
        elseif self._type == 6 then
            descBtnX = -110
        end
    end
    print("_type >>>>", self._type)

    detailDownImg:setPositionX(detailDownImg.x + descImgOffX)
    detailDesc:setPositionX(detailDesc.x + descOffX)
    detailBtn:setPositionX(detailBtn.x + descBtnX)

    detailBtn:setVisible(true)
    if self.preType ~= self._type then   
        if self.cardlist3 and tolua.isnull(self.cardlist3) == false then
            self.cardlist3:removeFromParent()
            self.cardlist3 = nil
        end

        local detailCallback = function (idx)
            dump(detailData[idx])
            self._detail = detailData[idx].queryId
            self:showPanelPayPanel()
        end
        local dpos = self.root:convertToWorldSpaceAR(detailBtn:getPosition3D())
        --保证一致
        local pOffset = cc.p(dpos.x, dpos.y)
        self.cardlist3 = self:initDropList(detailData, detailBtn, csize, pOffset, detailCallback)
        self.cardlist3:setVisible(false)
    end


    self.detailPanel:getChildByName("Label_26"):setString(detail.name)
    self.detailPanel:getChildByName("Label_26"):setPosition(tpos)
    
    if self.preType ~= self._type then
        if detailData[1] and detailData[1].typename then

            detailBtn:getChildByName("desc"):setString(detailData[1].typename)
        end
        self._detail = 0
    end
end

function PersonalView:showPanelPayPanel()
    print("showPanelPayPanel >>>>>>>>>>>>>")
    if self._type == 0 then 
        --没有三级选择标签
        self.NoRecordListPanel:setVisible(false)
        self.detailList:setVisible(true)
        self.detailPanel:setVisible(false)
        self.detailList:setContentSize(cc.size(1000, 580))
    else
        --有三级选择标签
        self.NoRecordListPanel:setVisible(false)
        self.detailList:setVisible(true)
        self.detailPanel:setVisible(true)
        self.detailList:setContentSize(cc.size(1000, 500))
    end
    self:refreshDetailBtn()
    self.preType = self._type
    local paras = {
        time = self._date,
        page_index = 0,
        queryType = self._type,
        rechargeStatus = 0,
        withdrawStatus = 0,
        playStatus = 0,
        pointStatus = 0,
        safeStatus = 0,
        detailStatus = 0
    }

    local detailIdx = self._detail
    print(">>>>>>>>>>>>> paras queryType", paras.queryType)
    print("detailIdx >>>>>>>>>>>>>", self._detail)
    if paras.queryType+1 == TypeConfig.CZ then
        paras.rechargeStatus = detailIdx
    elseif paras.queryType+1 == TypeConfig.TX then
        paras.withdrawStatus = detailIdx
    elseif paras.queryType+1 == TypeConfig.WP then
        paras.playStatus = detailIdx
        print("=================")
    elseif paras.queryType+1 == TypeConfig.SXF then
        paras.pointStatus = detailIdx
    elseif paras.queryType+1 == TypeConfig.SB then
        paras.safeStatus = detailIdx
    else
        paras.detailStatus = detailIdx
    end

    -- print("]]]]]]]]]]]]]]]]]]]")
    -- dump(paras)
    --服务器 以0开始 客户端以1 开始
    paras.queryType = self._type
    self:stopAllActions()
    self.nodataFlag = true
    self.refreshing = false
    self:sendDataRequest(paras, false)
end

function PersonalView:initWalletRecord()
    local datePanel = self.datePanel
    local selectBtn = datePanel:getChildByName("selectBtn")
    local dateCallback = function(idx)
        --idx 对应一个关联消息
        self._date = self._datelist[idx].queryId
        self:showPanelPayPanel()
    end

    self.cardlist = self:initDropList(self._datelist, self.datePanel:getChildByName("selectBtn"), cc.size(223, 60), cc.p(0,0), dateCallback)
    self.cardlist:setVisible(false)
    local typeCallback = function (idx)
        self._type = self._detailDataList[idx].queryId
        self:showPanelPayPanel()
    end


    self.cardlist2 = self:initDropList(self._detailDataList, self.typePanel:getChildByName("selectBtn"), cc.size(223, 60), cc.p(1510,690), typeCallback)
    self.cardlist2:setVisible(false)
    self.detailList:setItemModel(self.detailItem)
    self.detailList:removeAllChildren()
    self.detailList:addScrollViewEventListener(function (sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrollToBottom then
            -- print("123123123")
            if self._pageIndex == nil then
                return
            end
            if self.refreshing == false and self.nodataFlag then
                self.refreshing = true
                if self._pageIndex < self._pageTotal-1 then
                    self.paras.page_index = self.paras.page_index + 1
                    self:sendDataRequest(self.paras, true)
                else
                    if self.nodataFlag and #self.detailList:getChildren() > 2 then
                        self:addNoDataItem()
                        self.nodataFlag = false
                    end
                end
            end
        end
    end)
    self.detailList:setEnabled(true)
    self.detailList:setTouchEnabled(true)

    
    self._type = self._detailDataList[1].queryId
    self._date = self._datelist[1].queryId
    self._detail = 0
end

local getIcon = function (iconfigIdx)
    local iconTbl = {
        [IconConfig.ZFB] = GameRes.icon_flag_1,
        [IconConfig.YL] = GameRes.icon_flag_2,
        [IconConfig.WX] = GameRes.icon_flag_3,
        [IconConfig.WP] = GameRes.icon_flag_4,
        [IconConfig.SF] = GameRes.icon_flag_5,
        [IconConfig.SB] = GameRes.icon_flag_6,
        [IconConfig.TX] = GameRes.icon_flag_7,
        [IconConfig.XF] = GameRes.icon_flag_8,
        [IconConfig.YSF] = GameRes.icon_flag_9,
        [IconConfig.SCHB] = GameRes.icon_flag_10,
        [IconConfig.TXFL] = GameRes.icon_flag_11

    }
    if iconTbl[iconfigIdx] then
        return iconTbl[iconfigIdx]
    end
    return iconTbl[IconConfig.ZFB]
end

--data icon, title, time, leftTxt, copyimg, rightTxt, rest,  statusTxt
-- GameRes.fnt_score_2
function PersonalView:refreshItem(item, info)
    item:getChildByName("icon"):loadTexture(info.icon)
    item:getChildByName("itemTitle"):setString(info.titleTxt)
    local leftTxt = item:getChildByName("myid")
    leftTxt:setString(info.leftTxt)
    item:getChildByName("time"):setString(info.timeTxt)
    item:getChildByName("Label_52"):setString(info.rightUpTxt)
    item:getChildByName("Label_52"):setFntFile(info.rightUpFnt)
    item:getChildByName("statusTxt"):setString(info.rightDownTxt)
    if info.rightDownSize then
        item:getChildByName("statusTxt"):setFontSize(info.rightDownSize)
    end
    
    if info.rightDownColor then
        item:getChildByName("statusTxt"):setColor(info.rightDownColor)
    else
        item:getChildByName("statusTxt"):setColor(cc.c3b(98, 139, 213))
    end
    item:getChildByName("restPanel"):getChildByName("restNumber"):setString(info.rightMiddleTxt)
    local middleTxt = item:getChildByName("restPanel"):getChildByName("restfont")
    if qf.device.platform == "ios" then
        middleTxt:getLayoutParameter():setMargin({top = 13})
    end

    item:getChildByName("restPanel"):getChildByName("restfont"):setString(info.rightMiddleTxt2)
    local csize = leftTxt:getContentSize()
    local lx = leftTxt:getPositionX()
    item:getChildByName("copyimg"):setPositionX(lx + csize.width + 60)
    item:getChildByName("copyimg"):setEnabled(true)
    item:getChildByName("copyimg"):setTouchEnabled(true)
    addButtonEvent(item:getChildByName("copyimg"), function ( ... )
        if info.copyFunc then
            info.copyFunc()
        end
    end)

    if info.bcopy == false then
        item:getChildByName("copyimg"):setVisible(false)
    end
end

--只负责刷新整个listview 不考虑数据
function PersonalView:refreshRecordList(datalist, bAdd)
    if bAdd then        
        -- print("refresing ", self.refreshing)
    else
        self.detailList:removeAllChildren()
        --当前状态下 记录列表为全部的条件下没有一个数据
        if #datalist == 0 then
            --当前状态下  记录列表全部不为空 但当时所选的为空的情况下 数据为空
            if self._type ~= 0 then
                self.NoRecordListPanel:setVisible(true)
                self.detailList:setVisible(false)
                self.detailPanel:setVisible(true)
            else                
                self.NoRecordListPanel:setVisible(true)
                self.detailList:setVisible(false)
                self.detailPanel:setVisible(false)
            end
        end
    end
    local addLen = 10
    local len = #datalist
    local times = math.ceil(#datalist/addLen)
    local cnt = #self.detailList:getChildren()

    -- 5条为1次刷 防止加载卡住
    for i = 1, times do
        local cntT = (i-1) * 10
        performWithDelay(self, function()
            for j = 1, addLen do
                local idx = cntT + j
                if idx == len then
                    self.refreshing = false
                end
                if idx > len then
                    break
                end
                self.detailList:pushBackDefaultItem()
                -- print(idx)
                local item = self.detailList:getItem(cnt + idx-1)
                self:refreshItem(item, datalist[idx])
            end
        end, 0.3 * (i - 1))
    end
    self.detailList:requestRefreshView()
end


function PersonalView:addNoDataItem()

    --此处需要延时加载
    performWithDelay(self, function ( ... )
        local tempItem = self.nodataItem:clone()
        tempItem:setVisible(true)
        self.detailList:pushBackCustomItem(tempItem)
    end, 0.03)

end


function PersonalView:initOp( ... )
    -- body
    --关闭和返回一样
    local btnClose = ccui.Helper:seekWidgetByName(self.Panel_op,"Button_close")
    addButtonEvent(btnClose,function (sender)
        self.Panel_op:setVisible(false)
    end)
    Util:enlargeCloseBtnClickArea(btnClose)

    -- local btnCancel = ccui.Helper:seekWidgetByName(self.Panel_op,"Button_cancel")
    -- addButtonEvent(btnCancel,function (sender)
    --     self.Panel_op:setVisible(false)
    -- end)

    local nativeParams = {
        cb= function(status)
            if "-1" == status then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploadFail})
            elseif "0" == status then
                -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploading})
            elseif "1" == status then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploadSuc})
                --上传完更新头像
                qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin,wait=false,txt=GameTxt.main001,callback=handler(self,self.updateUserHead)})
            end
        end,
        path = CACHE_DIR.."head_"..Cache.user.uin..".jpg",
        uin = Cache.user.uin,
        key = QNative:shareInstance():md5(Cache.user.key),
        url = Cache.Config:getWebHost() .. "/portrait/upload",
        upload=1,
    }
    --调起照相机
    local btnPhoto = ccui.Helper:seekWidgetByName(self.Panel_op,"Button_photo")
    addButtonEvent(btnPhoto,function (sender)
		nativeParams.upload=1
        qf.platform:takePhoto(nativeParams)
    end)
    --调起相册
    local btnLocal = ccui.Helper:seekWidgetByName(self.Panel_op,"Button_local")
    addButtonEvent(btnLocal,function (sender)
		nativeParams.upload=2
        qf.platform:selectPhoto(nativeParams)
    end)

    -- local device = cc.Application:getInstance():getTargetPlatform()
    -- if device == cc.PLATFORM_OS_IPAD then
    --     btnLocal:setVisible(false)
    --     btnPhoto:setPositionX(477)
    -- end
end


--协议详情看proto文件 数据比较多 写在这里比较占位置
function PersonalView:sendDataRequest(paras, bAdd)
    local body = {}
    body.uin = Cache.user.uin
    body.ope_time = paras.time
    body.page_index = paras.page_index
    body.query_type = paras.queryType
    body.recharge_status = paras.rechargeStatus
    body.withdraw_status = paras.withdrawStatus
    body.play_method = paras.playStatus
    body.points_type = paras.pointStatus
    body.safe_status = paras.safeStatus
    body.query_detail_type = paras.detailStatus
    --query_detail_type 这个类型是对于新增所特殊使用的
    self.paras = paras
    -- dump(self.paras)
    dump(body)
    GameNet:send({cmd=CMD.PAY_RECORD,body=body,timeout=nil,callback=function(rsp)
        print("ret >>>>>>>>>>>>", rsp.ret)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else

            local model = rsp.model
            if bAdd == false then
                self._data = {}
            end
            local attrNameList = {"uin", "create_time", "own_gold", "bet_gold", "win_or_lose", "fee", "desk_name", "desk_type", "room_id", "remian_gold", "bank_name"}
            self:updateQueryData(model.game_list, "gameinfo", attrNameList)

            print("model l123en >>>>", model.bill_list:len())
            -- --充值
            local rechargeNameList = {"bill_type", "create_time", "id", "state", "amt", "balance", "bank_name", "bank_number", "order_type"}
            self:updateQueryData(model.bill_list, "recharge", rechargeNameList)

            self._pageIndex = model.page_index --0表示首页
            self._pageTotal = model.page_total --总页数
            self._queryType = model.query_type --查询类型

            -- print("pageIndex >>>>>>>>>>>>>>>>>>", self._pageIndex)
            -- print("_pageTotal >>>>>>>>>>>>>>>>>>", self._pageTotal)
            -- print
            self:updateClientData()
            self:refreshRecordList(self:getShowData(), bAdd)
        end
    end})
end

-- RECHARGE_ROOM_ID = 40301
-- WITHDRAW_IN = 40302
-- WITHDRAW_OUT = 40303
-- INIT_GOLD = 40304
-- BIND_PHONE = 40305
-- PROXY_POINTS_ON = 40306
-- PROXY_POINTS_OUT = 40307
-- SAFE_BOX_IN = 40201
-- SAFE_BOX_OUT = 40202

function PersonalView:updateQueryData(rsplist, dataListName, attrNameList)
    -- if self._data[dataListName] == nil then
        self._data[dataListName] = {}
    -- end
    for i = 1, rsplist:len() do
        local item = rsplist:get(i)
        local _item = {}
        for j, v in ipairs(attrNameList) do
            _item[v] = item[v]
        end
        self._data[dataListName][i] = _item
    end
    if dataListName == "recharge" then
        local tempList = {}
        for i, v in ipairs(self._data[dataListName]) do
            if v.order_type ~= 0 then
                tempList[#tempList + 1] = v
            end 
        end
        self._data[dataListName] = tempList
    end
end

function PersonalView:getShowData()
    local data = {}
    for i,v in ipairs(self._data["gameinfo"]) do
        if v.titleTxt ~= nil then
            data[#data + 1] = v
        end
    end

    for i, v in ipairs(self._data["recharge"]) do
        if v.titleTxt ~= nil then
            data[#data + 1] = v
        end
    end



    if data then
        table.sort(data, function (a, b)
            return a.create_time > b.create_time
        end)
    end

    print(" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    for i, v in ipairs(data) do
        -- print("create_time", v.create_time)
        -- print(" >>>>>>>>>>>>>>>>>", getTimeDesc(v.create_time))
    end
    print(" >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")

    -- dump(data)
    return data
end

function PersonalView:updateClientData()

    for i, v in ipairs(self._data["gameinfo"]) do
        local wanpai = false
        if false then
        elseif v.room_id == 40306 then --代理上分
            v.icon = getIcon(IconConfig.SF)
            v.timeTxt = getTimeDesc(v.create_time)
            v.leftTxt = GameTxt.person_txt_3 .. v.uin
            -- v.titleTxt = "上分 - 代理充值"

            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.fee), false)
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            v.rightDownTxt = ""
            v.rightUpFnt = GameRes.fnt_score_3
            v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.win_or_lose), true)
            v.copyFunc = copyFunc("" .. v.uin)
        elseif v.room_id == 40307 then --代理下分
            v.icon = getIcon(IconConfig.XF)
            v.timeTxt = getTimeDesc(v.create_time)
            v.leftTxt = GameTxt.person_txt_3 .. v.uin
            -- v.titleTxt = "下分 - 提现至代理"
            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.fee), false)
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            v.rightDownTxt = ""
            v.rightUpFnt = GameRes.fnt_score_2
            v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney( -1 * v.win_or_lose), true)
            v.copyFunc = copyFunc("" .. v.uin)
        elseif v.room_id == 40201 or v.room_id == 40202 then --存入
            v.icon = getIcon(IconConfig.SB)
            v.timeTxt = getTimeDesc(v.create_time)
            v.leftTxt = GameTxt.person_txt_5 .. specialFormatNumber(Cache.packetInfo:getProMoney(v.fee), false)
            v.bcopy = false
            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.own_gold), false)
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            v.rightDownTxt = ""
            if v.room_id == 40201 then
                v.rightUpFnt = GameRes.fnt_score_2
                v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.win_or_lose), true)
            elseif v.room_id == 40202 then
                v.rightUpFnt = GameRes.fnt_score_3
                v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.win_or_lose), true)
            end
        elseif v.room_id == 40308 then --首充红包
            v.icon = getIcon(IconConfig.SCHB)
            v.timeTxt = getTimeDesc(v.create_time)
            v.rightDownTxt = v.bank_name
            -- print("bankename >>", v.bank_name)
            v.rightUpFnt = GameRes.fnt_score_3
            v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.win_or_lose), true)
            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.own_gold), false)
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            v.leftTxt = GameTxt.person_txt_6 .. specialFormatNumber(Cache.packetInfo:getProMoney(v.bet_gold), false)
            v.bcopy = false
            v.rightDownColor = cc.c3b(237, 56, 60)
        elseif v.room_id == 40309 then --提现返利红包
            v.icon = getIcon(IconConfig.TXFL)
            v.timeTxt = getTimeDesc(v.create_time)
            v.rightDownTxt = v.bank_name
            v.rightUpFnt = GameRes.fnt_score_3
            v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.win_or_lose), true)
            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.own_gold), false)
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            v.bcopy = false
            v.rightDownColor = cc.c3b(237, 56, 60)
        elseif v.room_id >= 30101 and v.room_id <= 30106 then --牛牛
            wanpai = true
            -- local base_chip = Cache.packetInfo:getProMoney(Cache.Config.bull_classic_room[v.room_id].base_chip)
            -- v.titleTxt = "抢庄牛牛 - " .. Util:getFormatString(base_chip) .. "底分"
        elseif v.room_id >= 30201 and v.room_id <= 30206 then --炸金花
            wanpai = true
            -- local base_chip = Cache.packetInfo:getProMoney(Cache.Config.bull_zjh_room[v.room_id].base_chip)
            -- v.titleTxt = "炸金花 - " .. Util:getFormatString(base_chip) .. "底分"
        elseif v.room_id >= 30001 and v.room_id <= 30006 then --炸金牛
            wanpai = true
            -- v.titleTxt = "炸金牛"
        elseif v.room_id == 40001 then --龙虎斗
            wanpai = true
            -- v.titleTxt = "龙虎斗"
        elseif v.room_id == 40101 then --百人炸金花
            wanpai = true
            -- v.titleTxt = "百人炸金花"
        elseif v.room_id == 40203 or v.room_id == 40210 then --百人牛牛
            wanpai = true
            -- if v.room_id == 40203 then
            --     v.titleTxt = "百人牛牛 - （3倍场）"
            -- elseif v.room_id == 40210 then
            --     v.titleTxt = "百人牛牛 - （10倍场）"
            -- end
        end

        v.titleTxt = Cache.walletInfo:getOtherInfo(v.room_id)
        if wanpai then
            v.icon = getIcon(IconConfig.WP)
            local enterTime = os.date("*t", v.fee)
            local exitTime = os.date("*t", v.create_time)
            if enterTime.day == exitTime.day then --同一天
                v.timeTxt = getTimeDesc(v.fee) .. GameTxt.person_txt_9 .. Util:getDigitalTime(v.create_time) ..GameTxt.person_txt_10
            else
                v.timeTxt = getTimeDesc(v.fee) .. GameTxt.person_txt_9 .. getTimeDesc(v.create_time) ..GameTxt.person_txt_10
            end
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.remian_gold), false)
            v.leftTxt = GameTxt.person_txt_7 .. specialFormatNumber(Cache.packetInfo:getProMoney(v.own_gold), false)
            v.rightDownTxt = GameTxt.person_txt_8 .. specialFormatNumber(Cache.packetInfo:getProMoney(v.win_or_lose), false)
            v.rightDownSize = 30
            v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.bet_gold), true)
            if v.bet_gold > 0 then
                v.rightUpFnt = GameRes.fnt_score_3
            else
                v.rightUpFnt = GameRes.fnt_score_2
            end
            v.rightDownColor = cc.c3b(98, 139, 213)
            v.bcopy = false
        end
    end
    for i, v in ipairs(self._data["recharge"]) do
        if v.order_type == 1 then --充值
            local titleTxt
            v.icon = getIcon(IconConfig.ZFB)
            if v.bill_type == 39 then
                v.icon = getIcon(IconConfig.ZFB)
                -- titleTxt = "充值-支付宝"
            elseif v.bill_type == 40 then
                v.icon = getIcon(IconConfig.WX)
                -- titleTxt = "充值-微信"
            elseif v.bill_type == 41 then
                v.icon = getIcon(IconConfig.YL)
                -- titleTxt = "充值-银行卡"
            elseif v.bill_type == 42 then
                v.icon = getIcon(IconConfig.ZFB)
                -- titleTxt = "充值-支付宝"
            elseif v.bill_type == 43 then
                v.icon = getIcon(IconConfig.WX)
                -- titleTxt = "充值-微信"
            elseif v.bill_type == 44 then
                v.icon = getIcon(IconConfig.YSF)
            end
            titleTxt = Cache.walletInfo:getPayInfo(v.bill_type) or ""
            v.timeTxt = getTimeDesc(v.create_time)
            v.titleTxt = titleTxt
            v.rightUpFnt = GameRes.fnt_score_1
            v.rightDownTxt = Cache.walletInfo:getRechargeInfo(v.state)
            if v.state == 0 then --等待确认
                v.rightDownColor = cc.c3b(213, 201, 98)
                -- v.rightDownTxt = "等待确认"
            elseif v.state == 10 then --失败
                v.rightDownColor = cc.c3b(63, 195, 49)
                -- v.rightDownTxt = "充值失败"
            elseif v.state == 20 or v.state == 30 then --成功
                v.rightDownColor = cc.c3b(237, 56, 60)
                -- v.rightDownTxt = "充值成功"
                v.rightUpFnt = GameRes.fnt_score_3
            end
            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.balance), false)
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            v.leftTxt = GameTxt.person_txt_11 .. string.format("%08d", v.id)
            v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.amt), true)
            v.copyFunc = copyFunc("" .. string.format("%08d", v.id))
        elseif v.order_type == 2 then --提现
            v.icon = getIcon(IconConfig.TX)
            v.timeTxt = getTimeDesc(v.create_time)
            v.leftTxt = GameTxt.person_txt_11 ..string.format("%08d", v.id)
            v.titleTxt = GameTxt.person_txt_12 .. v.bank_name .. " (" .. string.sub(v.bank_number,-4, -1) .. ")"
            v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.amt), true)
            v.rightMiddleTxt = specialFormatNumber(Cache.packetInfo:getProMoney(v.balance), false)
            v.rightMiddleTxt2 = GameTxt.person_txt_4
            if v.state == 60 then
                v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(-v.amt), true)
                v.rightDownColor = cc.c3b(63, 195, 49)
                v.rightUpFnt = GameRes.fnt_score_2
            elseif v.state == 50 then
                v.rightUpTxt = specialFormatNumber(Cache.packetInfo:getProMoney(-v.amt), true)
                v.rightDownColor = cc.c3b(213, 201, 98)
                v.rightUpFnt = GameRes.fnt_score_1
            end
            v.rightDownTxt = Cache.walletInfo:getRechargeInfo(v.state)
            v.copyFunc = copyFunc("" .. string.format("%08d", v.id))
        end
    end
    -- dump(self._data)
end

function PersonalView:updateUserHead()
    -- body
    Util:updateUserHead(ccui.Helper:seekWidgetByName(self.Panel_info,"Image_head"), Cache.user.portrait, Cache.user.sex, {add = true, sq = false, url = true, circle = false})
end

function PersonalView:initEditBox( ... )
    -- body
    local editFrame = ccui.Helper:seekWidgetByName(self.Panel_info,"Image_nick_frame")

    local function editboxEventHandler( strEventName,sender )
        -- body
        if strEventName == "began" then

        elseif strEventName == "ended" then
                                                          
        elseif strEventName == "return" then
            local nick = sender:getText()
            local _nick = Util:showUserName(nick)
            if string.len(nick) ~= string.len(_nick) then
                sender:setText(Cache.user.nick)
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_person_7})
                return
            end

            if string.find(nick, " ") then
                sender:setText(Cache.user.nick)
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_person_8})
                return
            end
            self.nick = _nick
            sender:setText(_nick)
            self:updateNickAndSex(_nick, Cache.user.sex)
        elseif strEventName == "changed" then
        end
    end


    local editbox = Util:createEditBox(editFrame, {
        iSize = cc.size(250, 60),
        tag = -987654,
        fontcolor = cc.c3b(231,209,153),
        fontname = GameRes.font1,
        name = "nick",
        fontsize = 34,
        handler = editboxEventHandler
    })
    editbox:setText(Cache.user.nick)
end

function PersonalView:updateNickAndSex(nick, sex)
    -- body
    loga("updateNickAndSex nick = "..nick.." sex = "..sex)
    GameNet:send({cmd = CMD.USER_MODIFY,body = {sex = sex,nick = nick},callback = function(rsp) 
        if rsp.ret == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =  GameTxt.string_person_9})
            qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin, callback = function (args)
                if tolua.isnull(self) == false then
                    self:updateUserHead()
                end
            end})
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_person_10})
        end
    end})
end

function PersonalView:updateButton( ... )
    -- body
    --绑定之后 刷新按钮位置
    if Cache.user:isBindPhone() then
        self.bindBtn:setVisible(false)
        self.pwdBoxBtn:setPositionX(self.pwdBoxBtn.x + 140)
        self.changeBtn:setPositionX(self.changeBtn.x + 300)
    end
end

function PersonalView:initChooseInfo( ... )
    -- body
    addButtonEvent(ccui.Helper:seekWidgetByName(self.Panel_choose,"Button_change_login_pwd"),function (sender)
        --修改登录密码
        if Cache.user:isBindPhone() then
            qf.event:dispatchEvent(ET.CHANGE_PWD, {actType = 1, showType = 1})
        else
            qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 4})
        end
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.Panel_choose,"Button_change_pay_pwd"),function (sender)
        --修改安全密码
        if Cache.user:isBindPhone() then
            qf.event:dispatchEvent(ET.CHANGE_PWD, {actType = 1, showType = 2})
        else
            qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 4})
        end
        
    end)
    local closeButton = ccui.Helper:seekWidgetByName(self.Panel_choose,"Button_close")
    addButtonEvent(closeButton,function (sender)
        self.Panel_info:setVisible(true)
        self.Panel_choose:setVisible(false)
    end)

    Util:enlargeCloseBtnClickArea(closeButton)
end

function PersonalView:getRoot() 
    return LayerManager.PopupLayer
end

function PersonalView:test() 
    -- local body = {}
    -- body.uin = Cache.user.uin
    -- body.ope_time = 7
    -- body.page_index = 0
    -- body.query_type = 0
    -- body.recharge_status = 0
    -- body.withdraw_status = 0
    -- body.play_method = 0
    -- body.points_type = 0
    -- body.safe_status = 0

    -- for i = 0, 5 do
    --     -- performWithDelay(self, function (i)
    --     body.page_index = i
    --     GameNet:send({cmd=CMD.PAY_RECORD,body=body,timeout=nil,callback=function(rsp)
    --         print("BBBBBBBBBBBBBBBBBBBBBBBBBBBBB", rsp.ret)
    --         if rsp.ret ~= 0 then
    --             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
    --         else
    --             print("页数 》》》》》》》》》》》》》》", i)
    --             local model = rsp.model
    --             self._data = {}
    --             local attrNameList = {"uin", "create_time", "own_gold", "bet_gold", "win_or_lose", "fee", "desk_name", "desk_type", "room_id", "remian_gold"}
    --             self:updateQueryData(model.game_list, "gameinfo", attrNameList)

    --             -- print("model l123en >>>>", model.bill_list:len())
    --             -- --充值
    --             local rechargeNameList = {"bill_type", "create_time", "id", "state", "amt", "balance", "bank_name", "bank_number"}
    --             self:updateQueryData(model.bill_list, "recharge", rechargeNameList)
    --             print("model l123en >>>>", model.bill_list:len())
    --             print("model l123en >>>>", model.game_list:len())

    --             self._pageIndex = model.page_index --0表示首页
    --             self._pageTotal = model.page_total --总页数
    --             self._queryType = model.query_type --查询类型
    --             print("pagetoalt ", self._pageTotal)
    --             self:updateClientData()
    --             self:getShowData()
    --         end
    --     end})
    --     -- end, 0.1)
    -- end
end

return PersonalView