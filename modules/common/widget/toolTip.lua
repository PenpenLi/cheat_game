local toolTips = class("DeviceStatus",function ()
    return cc.Layer:create()
end)

function toolTips:ctor()	
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.toolTipsJson)
	self:addChild(self.gui)
	self:init()
	self:initClick()

	self.winSize = cc.Director:getInstance():getWinSize()
	
	if FULLSCREENADAPTIVE then 
		local fullscreenX = -(self.winSize.width/2-1920/2)
		self.gui:setPositionX(-fullscreenX)
		self.closeP:setPositionX(fullscreenX)
		self.closeP:setContentSize(self.closeP:getContentSize().width+self.winSize.width-1920,self.closeP:getContentSize().height)
	end
end

function toolTips:init()
	-- body
	self.closeP = ccui.Helper:seekWidgetByName(self.gui,"closeP") 
	self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"closebtn") 
	self.sureBtn = ccui.Helper:seekWidgetByName(self.gui,"surebtn") 
	self.topText = ccui.Helper:seekWidgetByName(self.gui,"tipstop") 
	self.tipsText = ccui.Helper:seekWidgetByName(self.gui,"tipstext") 
	self.downText = ccui.Helper:seekWidgetByName(self.gui,"tipsdown") 
	self.tipsP = ccui.Helper:seekWidgetByName(self.gui,"tipsP") 
end

function toolTips:initClick( ... )
	-- body
	addButtonEvent(self.closeBtn,function( ... )
		-- body
		self:removeSelf()
	end)
	addButtonEvent(self.sureBtn,function( ... )
		-- body
		self:removeSelf()
	end)
	addButtonEvent(self.closeP,function( ... )
		-- body
		self:removeSelf()
	end)
end

function toolTips:removeSelf( ... )
	qf.event:dispatchEvent(ET.TOOL_TIPS_CLOSE)
	self:removeFromParent()
end

function toolTips:setTipsText(msg)
	-- body
	self.tipsText:setString(msg)
end

function toolTips:removeCloseTouch()
	-- body
	self.closeBtn:setVisible(false)
	self.sureBtn:setVisible(false)
end

return toolTips