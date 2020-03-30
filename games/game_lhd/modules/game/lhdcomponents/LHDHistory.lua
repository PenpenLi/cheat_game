--胜负走势UI
local LHDHistory = class("LHDHistory", CommonWidget.PopupWindow)
LHDHistory.TAG = "LHDHistory"

function LHDHistory:ctor(paras)
	self.winSize = cc.Director:getInstance():getWinSize()
	self.is_guide = paras.is_guide
	local bg_style = self.is_guide and PopupManager.BG_STYLE.NONE or nil
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(LHD_Games_res.lhdHistoryJson)
	self.super.ctor(self, {id = PopupManager.POPUPWINDOW.lhdHistory, child = self.gui, bg_style = bg_style})
    self.infoCache = Cache.lhdinfo
    self.dalu_num = 0
	self:init()
	if not Cache.packetInfo:isShangjiaBao() then
		Util:addTangKuangEffect(Util:getChildEx(self.gui, "img_top_texture"))
	end
end

function LHDHistory:init()
	self.Button_close = ccui.Helper:seekWidgetByName(self.gui, "Button_close")

	self.Panel_tab_show1 = ccui.Helper:seekWidgetByName(self.gui, "Panel_tab_show1")
	addButtonEvent(self.gui, function()
        self:close()
    end)
    addButtonEvent(self.Button_close, function()
        self:close()
    end)
    Util:registerKeyReleased({self = self,cb = function ()
        self:close()
    end})
end

function LHDHistory:refreshLuDan()
	self.ludan = self.infoCache:getLuDanTab()
	self:setDaLuTu(self.ludan)
end

function LHDHistory:resetLuDan()
	self.dalu_num = 0
    self.zhupan_num = 0
    self:refreshLuDan()
end

function LHDHistory:setDaLuTu(paras)
	if not paras then return end
	local ScrollView_dalu = self.Panel_tab_show1:getChildByName("ScrollView_dalu")
	ScrollView_dalu:setInnerContainerSize(cc.size(ScrollView_dalu:getContentSize().width, ScrollView_dalu:getContentSize().height))
	local Panel_dalu = ScrollView_dalu:getChildByName("Panel_dalu")
	Panel_dalu:removeAllChildren()
	self.dalu_num = 0
	self.daluobj_list = {}
	local line_width = 4
	local per_width = Panel_dalu:getContentSize().width/20 - line_width
	local start_x = per_width/2
	local start_y = 557 - per_width/2
	local dx = per_width + line_width
	local dy = per_width
	local cur_result = nil
	local obj_result
	local j = 0
	
	Panel_dalu:setPosition(cc.p(0, ScrollView_dalu:getContentSize().height))
	local cur_width = 0
	local cur_height = 0
	for i = #paras,1,-1 do
		if (paras[i] == cur_result or paras[i] == 7 or not cur_result) and j ~= 7 then
			j = j + 1
			start_y = start_y - line_width - dy
		else
			j = 1
			start_x = start_x + dx
			start_y = 557 - per_width/2 - line_width - dy
		end
		if i <= #paras - self.dalu_num then
			obj_result = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(LHD_Games_res["lhdgame_history_ball_"..paras[i]]))
			obj_result:setPosition(cc.p(start_x, start_y))
			self.daluobj_list[#self.daluobj_list + 1] = {obj = obj_result, section = paras[i]}
			Panel_dalu:addChild(obj_result, 2)
		end
		if paras[i] ~= 7 then
			cur_result = paras[i]
		end
		if 557 - line_width - per_width/2 - start_y > cur_height then 
			cur_height =  557 - per_width/2 - line_width - start_y 
		end
	end

	local totalInfo = {
		long_num = 0,
		hu_num = 0,
		he_num = 0
	}
	--将大路图走势图向右边对齐
	--begin
	--共有20列显示 所以用19
	local lastX = per_width/2 + dx * 19
	
	if self.daluobj_list and #self.daluobj_list > 0 then
		local lastDaluX = self.daluobj_list[#self.daluobj_list].obj:getPositionX()
		local offsetX = lastX - lastDaluX
		for i, v in ipairs(self.daluobj_list) do
			Util:setPosOffset(v.obj, {x = offsetX})
		end
		--针对于在网格中显示的所有路子
		for i, v in ipairs(self.daluobj_list) do
			if v.obj:getPositionX() >= per_width/2 then
				if v.section == 1 then
					totalInfo.long_num = totalInfo.long_num + 1
				elseif v.section == 2 then
					totalInfo.hu_num = totalInfo.hu_num + 1
				elseif v.section == 3 then
					totalInfo.he_num = totalInfo.he_num + 1
				end
			end
		end

	end
	--end



	
	cur_width = start_x + dx/2
	cur_height = cur_height + dy/7
	-- if cur_width > ScrollView_dalu:getInnerContainerSize().width then 
	-- 	ScrollView_dalu:setInnerContainerSize(CCSizeMake(cur_width, ScrollView_dalu:getInnerContainerSize().height))
	-- end
	-- if cur_height > ScrollView_dalu:getInnerContainerSize().height then
	-- 	ScrollView_dalu:setInnerContainerSize(CCSizeMake(ScrollView_dalu:getInnerContainerSize().width, cur_height))
	-- 	Panel_dalu:setPosition(cc.p(0, cur_height))
	-- end
	-- ScrollView_dalu:jumpToTopRight()

	self.dalu_num = #paras

	self:updateTotalInfo(totalInfo)
end

function LHDHistory:updateTotalInfo(totalInfo)
	local topPannel = self.Panel_tab_show1:getChildByName("top")
	local pannel = self.gui:getChildByName("Panel_history")
	local info = pannel:getChildByName("info")
	topPannel:getChildByName("long"):setString(string.format(LHD_Games_txt.long_count, totalInfo.long_num))
	topPannel:getChildByName("hu"):setString(string.format(LHD_Games_txt.hu_count, totalInfo.hu_num))
	topPannel:getChildByName("he"):setString(string.format(LHD_Games_txt.he_count, totalInfo.he_num))

	local longRate, huRate = Cache.lhdinfo:getLongAndHuRate()
	info:getChildByName("long"):setString(longRate)
	info:getChildByName("hu"):setString(huRate)
	topPannel:requestDoLayout()
end

return LHDHistory