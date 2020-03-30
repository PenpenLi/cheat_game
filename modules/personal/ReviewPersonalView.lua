--[[
    个人信息界面
]]
-- local PersonalView = class("PersonalView", qf.view)
-- local PersonalView = class("PersonalView", CommonWidget.PopupWindow)

local _PersonalView = import(".PersonalView")
local PersonalView = class("PersonalView", _PersonalView)

--玩牌数据不展示进桌前后差额为0的数据
--保险箱存取产生金额变动才进行展示
PersonalView.TAG = "PersonalView"

function PersonalView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewPersonJson)
    self.super.super.ctor(self, {id=PopupManager.POPUPWINDOW.personal, child=self.root})
    self:init(parameters)
end

function PersonalView:initUI()
    local uiTbl = {
        {name = "Panel_info",        path = "Panel_frame"},

        {name = "baseInfoPanel",     path = "Panel_frame/Panel_base_info"},
        {name = "pwdBoxBtn",         path = "Panel_frame/Panel_base_info/Button_pwd_box",  handler = handler(self, self.onButtonEvent)},
        {name = "changeBtn",         path = "Panel_frame/Panel_base_info/Button_change_account",  handler = handler(self, self.onButtonEvent)},
        {name = "bindBtn",           path = "Panel_frame/Panel_base_info/Button_blind_phone",  handler = handler(self, self.onButtonEvent)},
        {name = "closeBtn",          path = "Panel_frame/Button_close",  handler = handler(self, self.onButtonEvent)},
        {name = "policyBtn",          path = "Panel_frame/Panel_base_info/policy_btn",  handler = handler(self, self.onButtonEvent)},

        {name = "Panel_choose",      path = "Panel_choose_change"},
        {name = "Panel_op",          path = "Panel_op"}, 
    }

    Util:bindUI(self, self.root, uiTbl)
    -- self.detailDesc.x =  self.detailDesc:getPositionX()
    -- self.detailDownImg.x =  self.detailDownImg:getPositionX()
    -- self.detailBtn.x =  self.detailBtn:getPositionX()
    -- self.detailDownImg2.x =  self.detailDownImg2:getPositionX()
    -- self.detailDesc2.x =  self.detailDesc2:getPositionX()
    -- self.detailBtn2.x =  self.detailBtn2:getPositionX()
    self.policyBtn:setVisible(false)
    self.pwdBoxBtn.x = self.pwdBoxBtn:getPositionX()
    self.changeBtn.x = self.changeBtn:getPositionX()
end

function PersonalView:init()
    -- body
    self:initData()
    self:initUI()
    self:initBaseInfo()
    self:initOp()
    self:initEditBox()--初始化输入框
    self:initChooseInfo()
end

function PersonalView:initData()
    self._datelist = Cache.walletInfo:getDateList()
    self._detailDataList = Cache.walletInfo:getDetailList()
end

function PersonalView:onButtonEvent(sender)
    if sender.name == "pwdBoxBtn" then
        self.Panel_choose:setVisible(true)
    elseif sender.name ==  "changeBtn" then
        self:changeFunc()
    elseif sender.name == "bindBtn" then
        self:doBindFunc()
    elseif sender.name == "policyBtn" then
        self:close()
        Util:delayRun(0.25, function ( ... )
            qf.event:dispatchEvent(ET.SHOW_USER_POLICY)
        end)
    elseif sender.name == "closeBtn" then
        self:close()
    end
end

function PersonalView:changeFunc()
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    cc.UserDefault:getInstance():setStringForKey("loginBody", "")
    cc.UserDefault:getInstance():flush()
    qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
end

function PersonalView:doBindFunc()
    local callfunc = function ( ... )
        -- body
        self:updateButton()
        self:initBaseInfo()
    end
    qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 6, cb = callfunc})
end

function PersonalView:isAdaptateiPhoneX()
    return true
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
    -- --invite
    -- local frame = ccui.Helper:seekWidgetByName(self.baseInfoPanel,"Image_invite")
    -- ccui.Helper:seekWidgetByName(frame,"Label_invite"):setString(GameTxt.string_person_3..Cache.user.invite_code)
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
    local headIcon = ccui.Helper:seekWidgetByName(self.Panel_info,"Image_head")
    local headMaskEditBtn = ccui.Helper:seekWidgetByName(self.Panel_info,"head_edit_btn")
    local defaultEditBtn = ccui.Helper:seekWidgetByName(self.Panel_info,"Image_14")
    Util:updateUserHead(headIcon, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true, circle = false})

    local btnCover = ccui.Helper:seekWidgetByName(self.Panel_info,"Button_head_cover")
    if Cache.user.number > 0 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.headMaskPlist, GameRes.headMaskPng)
        headIcon:setScale(0.9)
        btnCover:loadTextureNormal(string.format(GameRes.headMaskImage, Cache.user.number, 1),ccui.TextureResType.plistType)
        btnCover:loadTexturePressed(string.format(GameRes.headMaskImage, Cache.user.number, 1),ccui.TextureResType.plistType)
        headMaskEditBtn:setVisible(true)
        defaultEditBtn:setVisible(false)
    else
        headIcon:setScale(1)
        btnCover:loadTextureNormal(GameRes.headMaskDefault_1, ccui.TextureResType.plistType)
        btnCover:loadTexturePressed(GameRes.headMaskDefault_1,ccui.TextureResType.plistType)
        headMaskEditBtn:setVisible(false)
        defaultEditBtn:setVisible(true)
    end

    --上传头像
    local headImage = ccui.Helper:seekWidgetByName(self.Panel_info,"Image_head")
    addButtonEvent(btnCover,function (sender)
        self.Panel_op:setVisible(true)
    end)
    addButtonEvent(headMaskEditBtn,function (sender)
        self.Panel_op:setVisible(true)
    end)
    self:updateButton()
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