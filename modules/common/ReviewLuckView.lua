local _LuckView = import(".LuckView")
local LuckView = class("LuckView", _LuckView)

LuckView.TAG = "LuckView"

local AnimationConfig = require("src.games.game_hall.modules.main.config.AnimationConfig")
local ViewTbl  = {
    LuckMain = 1
}

function LuckView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewLuckJson)
    self.super.init(self, parameters)
    self.super.super.ctor(self, {id=PopupManager.POPUPWINDOW.luckView, child=self.root})
end

function LuckView:init( parameters )
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "luckMainView",            path = "Panel_main"},
        {name = "closeBtn",           	   path = "Panel_main/Button_close", handler = defaultHandler},
        {name = "buyBtn",             	   path = "Panel_main/Button_buy", handler= defaultHandler},


        {name = "goldTxt",            	   path = "Panel_main/Panel_info/GoldTxt", handler = nil},
        {name = "priceTxt",           	   path = "Panel_main/Panel_info/GoldTxt_0", handler = nil},
        {name = "timeTxt",            	   path = "Panel_main/Panel_info/timeTxt", handler = nil},
        {name = "diFrame",            	   path = "Panel_main/Panel_info/Image_44", handler= nil},
        {name = "idol",            	   	   path = "Panel_main/Panel_info/idol", handler = nil},
        {name = "wchat",            	   path = "Panel_main/Panel_info/wish_chat", handler = nil},
        {name = "tipTxt",            	   path = "Panel_main/Panel_info/tipTxt", handler = nil},
        {name = "descTxt",            	   path = "Panel_main/Panel_info/Label_32", handler = nil},
        {name = "descTxt2",            	   path = "Panel_main/Panel_info/Label_40", handler = nil},
    }

    Util:bindUI(self, self.root, uiTbl)
    Util:enlargeCloseBtnClickArea(self.closeBtn)


    self._uiViewTbl = {
    	self.luckMainView
   	}

	local defaultConfig = {
		min_money = 10000,
		remain_money = 1000
	}

	self.baseConfig = defaultConfig
	if Cache.mammonInfo.config then
		self.baseConfig = Cache.mammonInfo.config
	else
		Cache.mammonInfo:requestGetMammonInfo({uin = Cache.user.uin}, function ( paras )
			self.baseConfig = paras
			Cache.mammonInfo.config = paras
			if tolua.isnull(self) == false then
			    self:showView(ViewTbl.LuckMain)
			end
	    end)
	end
    
    self:initLuckMainView()
    -- self:initLuckRecordView()
    self:showView(ViewTbl.LuckMain)
end

function LuckView:initBaseUI()

end

function LuckView:onButtonEvent(sender)
	if sender.name == "closeBtn" then
		self:close()
	elseif sender.name == "buyBtn" then

		if self.lastInput == "" then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_luck_5})
			return
		end
		
		local inputNumber = tonumber(self.lastInput)
		if self.baseConfig.min_money > tonumber(self.lastInput)then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.string_luck_6, self.baseConfig.min_money)})
			return
		end

		if Cache.user.gold < tonumber(self.lastInput) + self.baseConfig.remain_money then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_luck_8})
			return
		end

		if inputNumber ~= math.ceil(inputNumber) then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_luck_7})
			return
		end

		self:buyMammmon()
	end
end

function LuckView:showView(viewNo)
	for i, v in ipairs(self._uiViewTbl) do
		v:setVisible(false)
	end
	self._uiViewTbl[viewNo]:setVisible(true)
	if viewNo == ViewTbl.LuckDetail then
		self:refreshDetail()
	elseif viewNo == ViewTbl.LuckMain then
		self:refreshLuckMainView()
	end
end

function LuckView:initLuckMainView()
	self.inputBox = Util:createEditBox(self.diFrame, {
		placeTxt = GameTxt.string_luck_3,
		handler = handler(self, self.editboxEventHandler),
		retType = cc.KEYBOARD_RETURNTYPE_DONE
	})

    Util:addAnimationToSender(self.idol, {anim = AnimationConfig.CAISHENYEBIG, node = self.idol, posOffset = nil, forever =true, scale = 0.9})
	self.descTxt:setString(GameTxt.string_luck_1)
	self.descTxt2:setString(GameTxt.string_luck_2)
end

function LuckView:refreshLuckMainView()
	self.goldTxt:setString(Util:getFormatString(Cache.user.gold))
	local tipStr = string.format(GameTxt.string_luck_4, Util:getProductFormatString(checknumber(self.baseConfig.min_money)) .. "" , Util:getProductFormatString(checknumber(self.baseConfig.remain_money)))
	if Util:checkInReviewStatus() then
		tipStr = "购买成功后按钮将会更换成财神爷图标"
	end
	self.tipTxt:setString(tipStr)
	self:resetInfo()
end

function LuckView:resetInfo()
	self.inputBox:setText("")
	self.lastInput = ""
end

function LuckView:editboxEventHandler( strEventName,sender )
    local limitCoinLen = 11
    -- body
    if strEventName == "began" then
    elseif strEventName == "ended" then
    elseif strEventName == "return" then
        if tonumber(sender:getText()) == nil then
        else
        	self.timeTxt:setText(string.format("%s".. GameTxt.second_unit, sender:getText()))
        end
    elseif strEventName == "changed" then
        local num = sender:getText()
        if Util:checkOnlyDigit(num)  then
        	self.lastInput = num
        else
        	sender:setText(self.lastInput)
        end
        --由于输入一个极大的数可能超过了int的表示范围 使用了一个11位的长度来控制数的大小
        if string.len(self.lastInput) > limitCoinLen then
	        self.lastInput = string.sub(num, 1, limitCoinLen)
            sender:setText(self.lastInput)
        end
    end
end

function LuckView:refreshDetail(args)
	local mygold = Cache.user.gold
	self.ditem:getChildByName("itemPrice"):setString(1 .. GameTxt.string_luck_14)
	self.ditem:getChildByName("itemCost"):setString(Util:getFormatString(checknumber(self.lastInput)) .. GameTxt.string_luck_12)
	self.ditem:getChildByName("itemTime"):setString(self.lastInput .. GameTxt.string_luck_13)
	self.ditem:getChildByName("itemRemain"):setString(Util:getFormatString(mygold - checknumber(self.lastInput)) .. GameTxt.string_luck_12)

	self.currency:setString(string.format(GameTxt.string_luck_11, Util:getFormatString(mygold)))
end

return LuckView