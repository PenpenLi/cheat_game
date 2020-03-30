--[[
	下拉框列表
]]
local comboList = class("comboList",function ()
    return cc.Layer:create()
end)


local setItemColor = function (item, color)
	if color and item then
		item:setColor(color)
	end
end

local setTitleColor = function (item, color)
	if color and item then
		item:setTitleColor(color)
	end
end

local hideType = ""
function comboList:ctor(displayCount, itemCount, itemSize, normalTexture, selectTexture, paras)
	self.normalTexture = normalTexture
	self.selectTexture = selectTexture
	self.normalTextColor = cc.c3b(93,151,217)
	self.selectTextColor = cc.c3b(255,255,255)
	self.itemSize = itemSize
	self.paras = paras
	self.childCallfunc = {}
	-- body
	if not normalTexture then
		return false
	end
	--mask
	local function onTouchMask (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
        	if hideType == "hide" then
        		self:setVisible(false)
        	else
        		self:removeFromParent()
        	end
        end
    end
	self.textureType = 0
	if self.paras then

		if self.paras.diPanelConfig then
			local panelConfig =  self.paras.diPanelConfig
			self:addChild(panelConfig.node)
			panelConfig.node:setPosition(panelConfig.pos)
		end
		if self.paras.textureType then
			self.textureType = self.paras.textureType
		end
		if self.paras.selectColor then
			self.selectColor =  self.paras.selectColor
		end
		if self.paras.normalColor then
			self.normalColor =  self.paras.normalColor
		end
		if self.paras.selectTextColor then
			self.selectTextColor =  self.paras.selectTextColor
		end
		if self.paras.normalTextColor then
			self.normalTextColor =  self.paras.normalTextColor
		end
	end

	local mask = ccui.Layout:create()
	mask:setContentSize(cc.Director:getInstance():getVisibleSize())
	mask:setTouchEnabled(true)
	mask:addTouchEventListener(onTouchMask)
	-- mask:setColor(cc.c3b(255,0,0))
	-- mask:setOpacity(100)
	-- mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	self:addChild(mask)
	self.mask=  mask

	--list
	self.list = ccui.ListView:create()
	if self.paras and self.paras.maxDisplay and self.paras.maxDisplay < displayCount then
		self.list:setContentSize(cc.size(itemSize.width, itemSize.height * self.paras.maxDisplay))
	else
	    self.list:setContentSize(cc.size(itemSize.width, itemSize.height * displayCount))
	end
    self.list:setBounceEnabled(false)
	-- self.list:setContentSize(cc.size(itemSize.width, itemSize.height * displayCount))
    self.list:setDirection(LISTVIEW_DIR_VERTICAL)
    self.list:setTouchEnabled(true)
    self.list:setAnchorPoint(0.5, 1)
    self:setContentSize(cc.Director:getInstance():getVisibleSize())
    self:addChild(self.list)

    self.itemModel = ccui.Button:create()
	--itemModel:loadTextureNormal(Niuniu_Games_res.BTN_YELLOW,ccui.TextureResType.plistType)
	self.itemModel:setScale9Enabled(true)
	self.itemModel:setContentSize(itemSize)
	self.itemModel:setTitleFontSize(36)
	self.itemModel:setTitleColor(cc.c3b(93,151,217))
	if self.paras and self.paras.capInsect then
		self.itemModel:setCapInsets(cc.rect(16,16,284,39))
	end

    self.list:setItemModel(self.itemModel)

    self.preSelectIndex = 1
	self.selectIndex = 1
	if self.paras and self.paras.addLen then	--延时加载的方式
		local addLen = self.paras.addLen
		local times = math.ceil(itemCount / addLen)
		for i = 1, times do
			local cntT = (i-1) * 10
			performWithDelay(self, function()
				for j = 1, addLen do
					local idx = cntT + j
					if idx > itemCount then
						break
					end
					self:addItem(normalTexture, selectTexture)
					if self.paras.addFunc then
						self.paras.addFunc(idx, self)
					end
				end
			end, 0.6 * (i - 1))
		end
		performWithDelay(self, function ( ... )
			self.list:jumpToTop()
		end, 0.03)
	else	--直接加载
		for i = 1, itemCount do
			self:addItem(normalTexture, selectTexture)
		end
	end
    self:setCursor(1)
end

function comboList:setListPostion( pos )
	-- body
	self.list:setPosition(pos)
end

--[[
itemCount = 显示的数目
itemSize = 每个条目尺寸
normalTexture = 条目底图 
selectTexture = 条目焦点图
]]
function comboList:create(displayCount, itemCount, itemSize, normalTexture, selectTexture)
	if not itemCount then
		itemCount = 1
	end
	self.childCallfunc = {}
	--if not itemSize then
		self:createWithTexture(itemCount, itemSize, normalTexture, selectTexture)
	-- else
	-- 	self:createWithSize(itemCount, itemSize)
	-- end
end

function comboList:createWithTexture(itemCount, itemSize, normalTexture, selectTexture)
	-- body
	if not normalTexture then
		return false
	end
	self.list = ccui.ListView:create()
    self.list:setContentSize(cc.size(itemSize.width, itemSize.height * itemCount))
    self.list:setDirection(LISTVIEW_DIR_VERTICAL)
    self.list:setTouchEnabled(true)
    self.list:setBounceEnabled(true)
    self:setContentSize()
    self:addChild(self.list)

    self.itemModel = ccui.Button:create()
	--itemModel:loadTextureNormal(Niuniu_Games_res.BTN_YELLOW,ccui.TextureResType.plistType)
	self.itemModel:setTitleFontSize(36)
	self.itemModel:setTitleColor(cc.c3b(93,151,217))	
	self.itemModel:setScale9Enabled(true)
	self.itemModel:setContentSize(itemSize)
    self.list:setItemModel(self.list_item)

    for i = 1, itemCount do
    	self:addItem(normalTexture, selectTexture)
    end
end

function comboList:addItem(normalTexture, selectTexture)
	-- body
	self.list:pushBackDefaultItem()
	local itemCount = #self.list:getItems()
	local curItem = self.list:getItem(itemCount - 1)
	curItem:loadTextureNormal(self.normalTexture, self.textureType)
	curItem:loadTexturePressed(self.normalTexture, self.textureType)
	setItemColor(curItem, self.normalColor)
	setTitleColor(curItem, self.normalTextColor)
	self:selectFunc({item = curItem, act = "unsel"})
	curItem:setAnchorPoint(cc.p(0, 0))

	local function btnCallfunc( sender )
		-- body
	end
	table.insert(self.childCallfunc, btnCallfunc)
	curItem:addTouchEventListener(btnCallfunc)
end

function comboList:getItemByIndex( index )
	-- body
	if index > 0 then
		return self.list:getItem(index - 1)
	end
end

function comboList:getAllItems( ... )
	return self.list:getItems()
end

function comboList:getLastItem( ... )
	-- body
	local count = self:getItemCount()
	return self.list:getItem(count - 1)
end

function comboList:getItemCount( ... )
	-- body
	return #self.list:getItems()
end

function comboList:getPreSelectIndex( ... )
	return self.preSelectIndex
end

function comboList:getSelectIndex( ... )
	return self.selectIndex
end

function comboList:createWithSize( ... )
	-- body
end

function comboList:setAutoHide( ... )
	-- body
	hideType = "hide"
end

function comboList:setCursor( index )
	-- body
	if self.preSelectIndex then
		local item = self:getItemByIndex(self.preSelectIndex)
		if item then
			item:loadTextureNormal(self.normalTexture, self.textureType)
			item:loadTexturePressed(self.normalTexture, self.textureType)
			setItemColor(item, self.normalColor)
			setTitleColor(item, self.normalTextColor)
			self:selectFunc({item = item, act = "unsel"})
		end	
	end

	self.selectIndex = index
	self.preSelectIndex = self.selectIndex
	if self.selectIndex then
		local item = self:getItemByIndex(self.selectIndex)
		if item then
			item:loadTextureNormal(self.selectTexture, self.textureType)
			item:loadTexturePressed(self.selectTexture, self.textureType)
			setItemColor(item, self.selectColor)
			setTitleColor(item, self.selectTextColor)
			self:selectFunc({item = item, act = "sel"})
		end
	end
end

function comboList:selectFunc(paras)

	if self.paras and type(self.paras.selectFunc) == "function" then
		self.paras.selectFunc(paras)
	end
end

function comboList:addInnerScrollViewEventListener(func)
	-- body
	self.list:addScrollViewEventListener(func)
end

function comboList:getListView()
	return self.list
end

return comboList