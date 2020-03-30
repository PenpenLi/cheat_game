local CommonTipView = class("CommonTipView", function()
    return cc.Node:create()
end)

function CommonTipView:ctor( paras )
	self:init()
	self:setData(paras)
end

function CommonTipView:init( ... )
	local _wins = cc.Director:getInstance():getWinSize()
	local _root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.GiveGiftTipJson)
    self:addChild(_root)

    local _listen = cc.EventListenerTouchOneByOne:create()
    _listen:setSwallowTouches(true)
    _listen:registerScriptHandler(function( ... )
    	return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    _listen:registerScriptHandler(function( ... )
    	self:onClick("close")
    end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(_listen, _root)
    self._globalTouchListen = _listen

    _root:addTouchEventListener(function(sender,eventType)
	    if eventType == ccui.TouchEventType.began then
	        return true
	    elseif eventType == ccui.TouchEventType.moved then
	    elseif eventType == ccui.TouchEventType.ended then
	        self:onClick("close")
	    elseif eventType == ccui.TouchEventType.canceled then
	    end
	end)
	
    self._btnOk = ccui.Helper:seekWidgetByName(_root, "btn_ok")
    addButtonEvent(self._btnOk, function( ... )
    	self:onClick("consure")
    end)
    self._btnNo = ccui.Helper:seekWidgetByName(_root, "btn_no")
    addButtonEvent(self._btnNo, function( ... )
    	self:onClick("cancel")
    end)
    self._lblContent = ccui.Helper:seekWidgetByName(_root, "lbl_content")
    self._root = _root
end

function CommonTipView:initView( ... )
	-- body
end

function CommonTipView:setData( paras )

	self._lblContent:setVisible(false)
    local normalColor = cc.c3b(102, 147, 225)
	if paras.color then
		normalColor = paras.color
	end

	if self._rText then
        self._rText:removeFromParent(true)
        self._rText = nil
    end

    local rText = Util:createRichText({size = cc.size(self._lblContent:getContentSize().width,self._lblContent:getContentSize().height), vspace = 10})
    self._lblContent:getParent():addChild(rText)
    local richDesc = {
        {desc = paras.content, color = normalColor}
    }

    for i, v in ipairs(richDesc) do
        local color = v.color
        local desc = v.desc
        local txt = ccui.RichElementText:create(1, color, 255, desc, GameRes.font1, 38)
        rText:pushBackElement(txt)
    end
    
    rText:setPosition(cc.p(self._lblContent:getPositionX(), self._lblContent:getPositionY()))
    self._rText = rText

	self._cbConsure = paras.cbConsure 
	self._cbCancel = paras.cbCancel
end

function CommonTipView:initGlobalEvent( ... )
	-- body
end

function CommonTipView:initModuleEvent( ... )
	-- body
end

function CommonTipView:show( ... )
    Display:popAction({time=0.2,view=view})
end

function CommonTipView:close()
    BOL_AUTO_RE_CONNECT = true
    Display:backAction({time=0.15,view=self,cb=function(sender)
        self:removeFromParent(true)
    end})
end

function CommonTipView:onClick( _btnName )
	if _btnName == "close" then
		self:close()
	elseif _btnName == "cancel" then
		if self._cbCancel then
			self._cbCancel()
		end
		self:onClick("close")
	elseif _btnName == "consure" then
		if self._cbConsure then
			self._cbConsure()
		end
		self:onClick("close")
	end
end

return CommonTipView