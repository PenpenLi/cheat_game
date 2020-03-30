local RetMoneyView = class("RetMoneyView", CommonWidget.PopupWindow)
RetMoneyView.TAG = "RetMoneyView"

function RetMoneyView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.retMoneyJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.retMoneyView, child=self.root})
end


function RetMoneyView:init( parameters )
    local bg = self.root:getChildByName("Panel_28")
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "rulePanel",           path = "Panel_Rule",          handler = nil},
        {name = "ruleCloseBtn",        path = "Panel_Rule/CloseBtn", handler = defaultHandler},
        {name = "retMoneyPanel",       path = "Panel_RetMoney",      handler = nil},
        {name = "retCloseBtn",         path = "Panel_RetMoney/CloseBtn", handler = defaultHandler},
        {name = "helpBtn",             path = "Panel_RetMoney/helpBtn", handler = defaultHandler},
        {name = "exchangeBtn",         path = "Panel_RetMoney/Panel_Bg/exchangeBtn", handler = defaultHandler},

        {name = "bonusTxt",            path = "Panel_RetMoney/Panel_Bonus/bonusTxt"},
        {name = "flowTxt",             path = "Panel_RetMoney/Panel_flow/flowTxt"},
        {name = "flowSlider",          path = "Panel_RetMoney/Panel_flow/flowSlider"},
        {name = "tipBg",               path = "Panel_RetMoney/tipBg"},
        {name = "girl",                path = "Panel_RetMoney/Image_30"},
        {name = "dayTxt",              path = "Panel_Bg/numberDayTxt"},

        {name = "fullDayTxt",          path = "Panel_Bg/fulldayTxt"},
        -- {name = "exchangeImg",          path = "Panel_Bg/Image_Exchange"},
        {name = "exchangeTxt",          path = "Panel_Bg/exchangeTxt"},
        {name = "yesterdayTxt",         path = "Panel_Bg/yesterdayTxt"},
        {name = "totalTxt",            path = "Panel_Bg/totalTxt"},
        {name = "vipTxt",              path = "Panel_Bg/TipPanel/vipTxt"},
        {name = "upLimitTxt",          path = "Panel_Bg/TipPanel/upLimitTxt"},
        {name = "tip1Txt",          path = "Panel_Bg/TipPanel/TipTxt_0"},
        {name = "tip2Txt",          path = "Panel_Bg/TipPanel/TipTxt_1"},
	}
    Util:bindUI(self, self.root, uiTbl)
	Util:enlargeCloseBtnClickArea(self.ruleCloseBtn,defaultHandler)
    Util:enlargeCloseBtnClickArea(self.retCloseBtn,defaultHandler)
    self.flowSlider:setTouchEnabled(false)
    self:initUI()
    self:getInfoAndRefreshUI(parameters.data)
    -- local spr = cc.Sprite:create(Cache.packetInfo:getGoldImg())
    -- spr:setScale(0.9)
    -- Util:setPosOffset(spr, cc.p(43,78))
    -- self.exchangeImg:addChild(spr)
     Util:addButtonScaleAnimFuncWithDScale(self.exchangeBtn, handler(self, self.onButtonEvent))
end

function RetMoneyView:initUI( ... )
    --由于服务器取数据很慢 所以使用上一轮 服务器的数据来进行刷新 如果没有就使用默认处理
    if Cache.Config.retMoneyInfo then
        self._rewardinfo = Cache.Config.retMoneyInfo.rewardinfo
        self._vipinfo = Cache.Config.retMoneyInfo.vipinfo
        self._data = Cache.Config.retMoneyInfo.data
        self:refreshUI()
    else
        self.bonusTxt:setString(string.format("%.1f%%", 0))
        self.flowSlider:setPercent(0)
        self.flowTxt:setString(string.format("%d/%d"..Cache.packetInfo:getShowUnit(), 0, 0))
        self.fullDayTxt:setString("7") --当前默认为7天
        self.dayTxt:setString(1)
        self.yesterdayTxt:setString("0 "..Cache.packetInfo:getShowUnit())
        self.totalTxt:setString("0 ")
        self.upLimitTxt:setString("0 "..Cache.packetInfo:getShowUnit())
        self.exchangeTxt:setString("0 "..Cache.packetInfo:getShowUnit())
    end
end

function RetMoneyView:refreshUI()
    -- self.bonusTxt:setString(self._rewardinfo.reward_coefficient/10 .. "%")
    self.bonusTxt:setString(self._rewardinfo.coefficient)
    print(">>>>>>>>>", self._rewardinfo.reward_coefficient)
    if self._data.flow_today < self._rewardinfo.reward_recharge then
        self.flowTxt:setString(string.format("%s / %s"..Cache.packetInfo:getShowUnit(), Util:getFormatString(Cache.packetInfo:getProMoney(self._data.flow_today)), Util:getFormatString(Cache.packetInfo:getProMoney(self._rewardinfo.reward_recharge))))
    else
        self.flowTxt:setString(string.format("%s / %s"..Cache.packetInfo:getShowUnit(), Util:getFormatString(Cache.packetInfo:getProMoney(self._data.flow_today)), Util:getFormatString(Cache.packetInfo:getProMoney(self._data.flow_today))))
    end
    
    self.flowSlider:setPercent(self._data.flow_today/self._rewardinfo.reward_recharge * 100 )

    self.dayTxt:setString(self._data.activity_login_days)

    self.fullDayTxt:setString("7") --当前默认为7天
    self.yesterdayTxt:setString(Util:getFormatString(Cache.packetInfo:getProMoney(self._data.yesterday_profit)) .. " " .. Cache.packetInfo:getShowUnit())
    self.totalTxt:setString(Util:getFormatString(Cache.packetInfo:getProMoney(self._data.profit_total)) .. " " .. Cache.packetInfo:getShowUnit())
    self.upLimitTxt:setString(Util:getFormatString(Cache.packetInfo:getProMoney(self._vipinfo.vip_receive)) .. Cache.packetInfo:getShowUnit())
    -- print("wait_draw >>>>>>>>", self._data.wait_draw)

    self.exchangeTxt:setString(Util:getFormatString(Cache.packetInfo:getProMoney(self._data.wait_draw)) .. Cache.packetInfo:getShowUnit())
    local lbl_content = self:getRemindTxt()
    lbl_content:setName("content")
    if self.tipBg:getChildByName("content") then
        self.tipBg:removeChildByName("content")
    end

    self.tipBg:addChild(lbl_content)

    local bEnable = false
    if self._data.can_draw == 1 then
        bEnable = true
    end

    Util:ensureBtn(self.exchangeBtn, bEnable)

    --调整位置
    local x = self.tip1Txt:getPositionX() + self.tip1Txt:getContentSize().width / 2 
    self.upLimitTxt:setPositionX(x + self.upLimitTxt:getContentSize().width/2)
    self.tip2Txt:setPositionX(x +  self.upLimitTxt:getContentSize().width + self.tip2Txt:getContentSize().width/2)
end

function RetMoneyView:getRemindTxt(remindDescTbl)
    local lbl_content = ccui.RichText:create()

    lbl_content:ignoreContentAdaptWithSize(true)
    lbl_content:setContentSize(cc.size(1280, 300))
    lbl_content:setAnchorPoint(cc.p(0,0))
    lbl_content:setVerticalSpace(5)
    lbl_content:setPosition(cc.p(670,20))
    local fontName = GameRes.font1
    local markedColor = cc.c3b(255, 205, 86)
    local normalColor = cc.c3b(154, 191, 255)

    --暂且写到1到10的中文配对
    local numberTbl = GameTxt.string_retmoney_8
    
    local curRewardLevelStr = string.format(GameTxt.string_retmoney_1, numberTbl[self._rewardinfo.reward_id])
    local nextRewardLevelStr
    --确保不会达到最大档次
    if self._rewardinfo.reward_id+1 <= #Cache.Config.reward_info then
        nextRewardLevelStr = string.format(GameTxt.string_retmoney_1, numberTbl[self._rewardinfo.reward_id+1])
    end

    local richDesc 
    if nextRewardLevelStr then
        --修复 如果要达到下一档 应该以当前档位的最大值加1 来进行计算
        local diffCharge = Cache.packetInfo:getProMoney((self._rewardinfo.reward_recharge + Cache.packetInfo:getCProMoney(1) - self._data.flow_today))
        local diffStr = string.format("%s" .. Cache.packetInfo:getShowUnit(), Util:getFormatString(diffCharge))
        richDesc = {
            {desc = GameTxt.string_retmoney_2, color = normalColor},
            {desc = curRewardLevelStr, color = markedColor},
            {desc = GameTxt.string_retmoney_3, color = normalColor},
            {desc = diffStr, color = markedColor},
            {desc = GameTxt.string_retmoney_4, color = normalColor},
            {desc = nextRewardLevelStr, color = markedColor},
        }
    else
        richDesc = {
            {desc = GameTxt.string_retmoney_6, color = normalColor},
        }
    end


    for i, v in ipairs(richDesc) do
        local color = v.color
        local desc = v.desc
        local txt = ccui.RichElementText:create(1, color, 255, desc, GameRes.font1, 32)
        lbl_content:pushBackElement(txt)
    end
    lbl_content:formatText()
    local vsize = lbl_content:getVirtualRendererSize()
    local size = self.tipBg:getContentSize()
    local offsetW  = 40
    -- self.tipBg:setContentSize(vsize.width + offsetW, size.height)
    local pos = self.tipBg:getPosition3D()
    local px = 0 - vsize.width/2 + offsetW/2
    -- self.girl:setPositionX(pos.x - vsize.width/2 - 100 )
    lbl_content:setPositionX(self.tipBg:getContentSize().width/2 - vsize.width)
    return lbl_content
end

function RetMoneyView:onButtonEvent(sender)
    -- print(sender.name)
	if sender.name == "ruleCloseBtn" then
		self.rulePanel:setVisible(false)
    elseif sender.name == "exchangeBtn" then
        self:sendRetExchangeReq()
        self:sendRetMoneyReq()
    elseif sender.name == "retCloseBtn" then 
        self:close()
    elseif sender.name == "helpBtn" then
        self.rulePanel:setVisible(true)
        self:showRulePanel()
    end
end

function RetMoneyView:showRulePanel()
    -- local scrollview = self.rulePanel:getChildByName("ScrollView_70")
    -- local img = scrollview:getChildByName("Image_71")
    -- img:setAnchorPoint(cc.p(0,0))
    -- local contentSize = img:getContentSize()
    -- local innerSize = scrollview:getInnerContainerSize()
    
    -- scrollview:setInnerContainerSize(cc.size(innerSize.width, contentSize.height))
    -- local _x = (innerSize.width - contentSize.width)
    -- img:setPosition(_x, 0)
end


function RetMoneyView:sendRetExchangeReq()

    Cache.retmoneyInfo:sendRetExchangeReq()
end

function RetMoneyView:getInfoAndRefreshUI(data)
    self._data = data
    self:getVipAndRewardInfo()
    self:refreshUI()
end

function RetMoneyView:sendRetMoneyReq()
    local cb = function (data)
        if tolua.isnull(self) then
            return
        end
        self:getInfoAndRefreshUI(data)
    end
    Cache.retmoneyInfo:sendRetMoneyReq(cb)
end

function RetMoneyView:getVipAndRewardInfo()
    --从大到小排序
    local vipinfo = Cache.Config.vip_info
    table.sort(vipinfo, function (a, b)
        return a.vip_recharge > b.vip_recharge
    end)

    self._vipinfo = nil
    --服务器传送过来的数据对于最后一个档次给的是最低值 而其他档次给的最大值 所以单独处理
    --档次处理也是一样的
    --但是我这里经过了排序处理
    --当前用户的vip信息
    for i,v in ipairs(vipinfo) do
        if (i > 1) and self._data.recharge_total <= v.vip_recharge then
            self._vipinfo = v
        elseif (1 == i and self._data.recharge_total >= v.vip_recharge) then
            self._vipinfo = v
            break
        end
    end
    -- --当天流水档位
    self._rewardinfo = nil
    local rewardinfo = Cache.Config.reward_info
    table.sort(rewardinfo, function (a, b)
        return a.reward_recharge > b.reward_recharge
    end)
    -- print(">>>>>>>> reward info")
    -- dump(rewardinfo)
    for i, v in ipairs(rewardinfo) do
        if (i > 1) and self._data.flow_today <= v.reward_recharge then
            self._rewardinfo = v
        elseif (i == 1 and self._data.flow_today >= v.reward_recharge) then
            self._rewardinfo = v
        end
    end
    -- self._rewardinfo = Cache.Config.reward_info[1]
    Cache.Config.retMoneyInfo  = {
        rewardinfo = self._rewardinfo,
        vipinfo = self._vipinfo,
        data = self._data
    }
end

return RetMoneyView