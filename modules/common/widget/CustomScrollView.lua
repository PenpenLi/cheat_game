local CustomScrollView = class("CustomScrollView",function(paras)
	return ccui.ScrollView:create() --paras.node
end)
CustomScrollView.TAG = "CustomScrollView"

local CustomTabViewCell = import(".CustomTabViewCell")
function CustomScrollView:ctor(paras)
	self.inner = self:getInnerContainer()
	self.itemList = {}
	self.itemsHeight = {}
	self.itemsWidth = {}
	self.defaultItem = nil
	self.itemsMargin = 0
	self.freshScroll = false
	self.removeRefresh = false
	self.freshInnerSize = false
	self.innerContentEnable = true
	self.showAction = false
	self.topRefresh = false
	self.topRefreshCallback = nil
	self.selectItem = nil
	self.preItem = nil
	self.nextItem = nil
	self.cur_inner_refresh_posY = 0
	self.cur_inner_posX = 0
	self.cur_inner_posY = 0
	if paras then
		--datalist必须有序
		self.datalist = paras.datalist == nil and {} or paras.datalist
		self.limitMaxNum = paras.limitMaxNum == nil and 6 or paras.limitMaxNum
		self.defaultNode = paras.defaultNode
		self.updata = paras.updata
		self.direction = paras.direction == nil and ccui.ScrollViewDir.vertical or paras.direction
		self.delay = paras.delay == nil and 0 or paras.delay
	end
	self:initView()
end

function CustomScrollView:getDefaultItem()
	local node = self.defaultNode:clone()
	self.defaultItem = CommonWidget.CustomTabViewCell.new({
	        node = node,
	        updata = self.updata
	    })
	return self.defaultItem
end

function CustomScrollView:initView()
	self:setBounceEnabled(true)
	self:setDirection(self.direction)
	self:addEventListener(handler(self, self.scrollListViewEvent))
	if #self.datalist <= 0 then return end
	self:initScrollViewSize()
	self:refreshScrollView(true)
end

function CustomScrollView:initScrollViewSize()
	self.freshInnerSize = true
	local defaultItem = self:getDefaultItem()
	--初始化容器高度
	for i,v in pairs(self.datalist) do
		self:setItemContentSize(i, defaultItem)
	end
	self:updateInnerContentSize()
	self.cur_inner_posY = self.inner:getPositionY()
end

function CustomScrollView:refreshScrollView(totop,startIndex)
	if totop then
		self:hideAllItems()
	end
	self.freshInnerSize = true
	local startIndex = startIndex or 1
	self:stopAllActions()
	--self:stopAutoScrollChildren() --停止惯性滚动
	--跳转到顶部，并重置当前Item序号
	if totop then
		self:jumpToTop()
		for i,v in pairs(self.itemList) do
			v.listkey = i
		end
	end

	--当现有数据小于已有Item时,删除多余的item
	if #self.datalist < #self.itemList then
		for i = #self.itemList,#self.datalist + 1,-1  do
			self:removeChild(self.itemList[i],true)
			table.remove(self.itemList, i)
		end
	end

	--当现有数据小于已有Item的最大数据时,同步item数据为当前datalist的最大数据
	if #self.itemList > 0 and #self.datalist < self.itemList[#self.itemList].listkey then
		local item
		for i=1,#self.itemList do
			item = self.itemList[i]
			item.listkey = #self.datalist - #self.itemList + i
		end
	end

	--刷新数据
	local delay = self.delay
	local showAction = self.showAction
	if self.removeRefresh then
		delay = 0
		showAction = false
		self.removeRefresh = false
	end
	for i = startIndex, #self.datalist do
		local delay = self.itemList[1] and (i - self.itemList[1].listkey + 1)*delay or (i - startIndex + 1)*delay
		self:runAction(
	        cc.Sequence:create(cc.DelayTime:create(delay),
	        cc.CallFunc:create(function()
	        	self:_updateItem(i,showAction)
	        end)))
	end
end

function CustomScrollView:_updateItem(index,showAction)
	local j = 0
	local k = 0
	local item
	if #self.itemList == 0 or index > self.itemList[#self.itemList].listkey then
		if #self.itemList >= self.limitMaxNum then
			--如果大于item最大限制数则不再新增
			return
		end
		--如果当前显示的item还没有达到限制则补齐item
		item = self:getDefaultItem()
		item.listkey = index
		addButtonEvent(item, handler(self, self.itemTouchCallback))
		self:addChild(item)
		table.insert(self.itemList, item)
		k = k + 1
		--loge("新增:"..k)
	elseif index >= self.itemList[1].listkey then
		--刷新现有item
		item = self.itemList[index - self.itemList[1].listkey + 1]
		item.updata = self.updata
		j = j + 1
		--loge("刷新:"..j)
	end
	if item then
		item:updataCell(self.datalist[item.listkey])
		self:setItemContentSize(item.listkey, item)
		--更新inner大小
		self:updateItemPos(index)
		item:setVisible(false)

		if showAction then
        	local width = self:getInnerContainerSize().width
        	local height = item:getPositionY() - item:getContentSize().height*item:getAnchorPoint().y
        	local anchor = item:getAnchorPoint()
        	item:setVisible(true)
        	item:setAnchorPoint(0.5,0.5)
        	item:setPosition(cc.p(width/2 - item:getContentSize().width/2 + item:getContentSize().width*item:getAnchorPoint().x, height + item:getContentSize().height*item:getAnchorPoint().y))
			Display:showScalePop({view = item,time = 0.1,cb=function(item)
				local width = self:getInnerContainerSize().width
        		local height = item:getPositionY() - item:getContentSize().height*item:getAnchorPoint().y
		        item:stopAllActions()
		        item:setAnchorPoint(anchor)
		        item:setPosition(cc.p(width/2 - item:getContentSize().width/2 + item:getContentSize().width*item:getAnchorPoint().x, height + item:getContentSize().height*item:getAnchorPoint().y))
		    end})
		else
			item:setVisible(true)
		end
	end
end

--滑动处理
function CustomScrollView:scrollListViewEvent(sender,eventType)
	if eventType == ccui.ScrollviewEventType.bounceTop then
		if self.topRefresh and self.topRefreshCallback then
			--下拉刷新回调
			if self.cur_inner_refresh_posY + self.inner:getChildByName("topText"):getPositionY() + 100 < self:getContentSize().height then
				self.topRefreshCallback()
			end
		end
	else
		self.cur_inner_refresh_posY = self.inner:getPositionY()
	end

	if eventType ~= ccui.ScrollviewEventType.scrolling or self.freshScroll or #self.itemList < self.limitMaxNum then return end
	local cur_item
	if self.direction == ccui.ScrollViewDir.vertical then
		if self.inner:getPositionY() - self.cur_inner_posY > 0 then
        	--向上滑动，并且当前最下面的item key值小于datalist的数量
	        while self.itemList[#self.itemList].listkey < #self.datalist 
	        	and self.inner:getPositionY() + self.itemList[#self.itemList]:getPositionY() + self.itemList[#self.itemList]:getContentSize().height > 0 do
	        	--最下面只剩1个item没有进入视线时刷新
                cur_item = self.itemList[1]  
                if cur_item:getPositionY() + self.inner:getPositionY() > self:getContentSize().height then
                	--可以回收第一个item
                	table.remove(self.itemList,1)
	                cur_item.listkey = self.itemList[#self.itemList].listkey + 1
	                cur_item:updataCell(self.datalist[cur_item.listkey])
	                table.insert(self.itemList,cur_item)
	                self:setItemContentSize(cur_item.listkey, cur_item)
	                self:updateItemPosY(#self.itemList)
	            else
	            	--不可以回收第一个item，新增item
	            	self:addItemBottom()
	            end
	        end
		else
			--向下滑动，并且当前最上面的item key值大于datalist的第一个key
        	while self.itemList[1].listkey > 1 
        		and self.inner:getPositionY() + self.itemList[1]:getPositionY() < self:getContentSize().height do
	            cur_item = self.itemList[#self.itemList]
	            --最上面只剩1个item没有进入视线时刷新
	            local height = self:getItemHeightByIndex(self.itemList[1].listkey - 1)
	            if self.inner:getPositionY() < -cur_item:getContentSize().height then
	            	--可以回收最后一个item
	            	table.remove(self.itemList,#self.itemList)
		            cur_item.listkey = self.itemList[1].listkey - 1
		            cur_item:updataCell(self.datalist[cur_item.listkey])
		            table.insert(self.itemList,1,cur_item)
		            self:setItemContentSize(cur_item.listkey, cur_item)
	                self:updateItemPosY(1)
		        else
		        	--不可以回收最后一个item，新增item
		        	self:addItemTop()
		        end
		        if math.abs(height - cur_item:getContentSize().height) > 0.1 then
		        	--视野上方的item大小发生变化，为了防止item跳动，移动inner的坐标使原来的item在视野中位置不变
                	self.inner:setPositionY(self.inner:getPositionY() + (cur_item:getContentSize().height - height))
                end
	        end
        end
  		self.cur_inner_posY = self.inner:getPositionY()
    elseif self.direction == ccui.ScrollViewDir.horizontal then
    	if self.inner:getPositionX() - self.cur_inner_posX > 0 and self.itemList[#self.itemList].listkey < #self.datalist then
        	--向左滑动，并且当前最右边的item key值小于datalist的数量
        	self.cur_inner_posX = self.inner:getPositionX()
	        if self.cur_inner_posX > - self.itemList[#self.itemList]:getContentSize().width then
	        	--最右边只剩1个item没有进入视线时刷新
                cur_item = self.itemList[1]  
                if cur_item:getPositionX() + self.cur_inner_posX > self:getContentSize().width then
	                --可以回收第一个item
                	table.remove(self.itemList,1)
	                self.cur_inner_posX = self.inner:getPositionX()
	                cur_item.listkey = self.itemList[#self.itemList].listkey + 1
	                cur_item:updataCell(self.datalist[cur_item.listkey])
	                table.insert(self.itemList,cur_item)
	                self:setItemContentSize(cur_item.listkey, cur_item)
	                self:updateItemPosX(#self.itemList)
	            else
	            	--不可以回收第一个item，新增item
	            	self:addItemBottom()
	            end
	        end
		elseif self.itemList[1].listkey > 1 then
			--向右滑动，并且当前最左边的item key值大于datalist的第一个key
		    self.cur_inner_posX = self.inner:getPositionX()
        	if self.cur_inner_posY + self:getInnerContainerSize().width - self.itemList[1]:getContentSize().width < self:getContentSize().width then
	            cur_item = self.itemList[#self.itemList]
	            --最左边只剩1个item没有进入视线时刷新
	            if self.cur_inner_posX < -cur_item:getContentSize().width then
		            --可以回收最后一个item
	            	table.remove(self.itemList,#self.itemList)
		            self.cur_inner_posX = self.inner:getPositionX()
		            cur_item.listkey = self.itemList[1].listkey - 1
		            cur_item:updataCell(self.datalist[cur_item.listkey])
		            table.insert(self.itemList,1,cur_item)
		            self:setItemContentSize(cur_item.listkey, cur_item)
	                self:updateItemPosX(1)
		        else
		        	--不可以回收最后一个item，新增item
		        	self:addItemTop()
		        end
	        end
        end
        self.cur_inner_posX = self.inner:getPositionX()
    end
end

--新数据刷新列表,datalist:数据table, totop:是否跳到顶部
function CustomScrollView:refreshData(datalist,totop)
	self.datalist = clone(datalist)
	self:initScrollViewSize()
	self:refreshScrollView(totop,1)
end

function CustomScrollView:updateInnerContentSize()
	if self.direction == ccui.ScrollViewDir.vertical then
		self:updateInnerHeight()
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		self:updateInnerWidth()
	end
end

function CustomScrollView:updateItemPos(index)
	self.freshInnerSize = true
	if self.direction == ccui.ScrollViewDir.vertical then
		self:updateItemPosY(index)
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		self:updateTtemPosX(index)
	end
end

--设置单个Item的size
function CustomScrollView:setItemContentSize(index,item)
	if self.direction == ccui.ScrollViewDir.vertical then
		if not self.itemsHeight[index] or math.abs(self.itemsHeight[index] - item:getContentSize().height) > 0.1 then
			self.itemsHeight[index] = item:getContentSize().height
			self.freshInnerSize = true
		end
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		if not self.itemsWidth[index] or math.abs(self.itemsWidth[index] - item:getContentSize().width) > 0.1 then
			self.itemsWidth[index] = item:getContentSize().width
			self.freshInnerSize = true
		end
	end
end

--获取单个Item的size
function CustomScrollView:getItemHeightByIndex(index)
	return self.itemsHeight[index]
end

--更新滑动容器的高度
function CustomScrollView:updateInnerHeight()
	if not self.freshInnerSize then return end
	self.freshInnerSize = false
	self.freshScroll = true
	local height= 0
	if self.preItem then
		height = height + self.preItem:getContentSize().height
	end
	if self.nextItem then
		height = height + self.nextItem:getContentSize().height
	end
	for i,v in pairs(self.itemsHeight) do
		if i > #self.datalist then break end
		if i == 1 then
			height = height + v
		else
			height = height + v + self.itemsMargin
		end
	end
	if height ~= self:getInnerContainerSize().height then
		self:setInnerContainerSize(cc.size(self:getContentSize().width, height))
	end

	if self.inner:getChildByName("topText") then
		self.inner:getChildByName("topText"):setPositionY(self:getInnerContainerSize().height + 100)
	end
	self.freshScroll = false
end

function CustomScrollView:updateInnerWidth()
	-- body
end

function CustomScrollView:updateItemPosY(index)
	self:updateInnerHeight()
	if #self.itemsHeight == 0 then return end
	local width  = self:getInnerContainerSize().width
	local height = self:getInnerContainerSize().height
	local item = nil --self.itemList[index]暂时没有使用，目前每次都更新所有item的坐标
	if self.preItem then
		height = height - self.preItem:getContentSize().height
		self.preItem:setPosition(cc.p(width/2 - self.preItem:getContentSize().width/2 + self.preItem:getContentSize().width*self.preItem:getAnchorPoint().x, height + self.preItem:getContentSize().height*self.preItem:getAnchorPoint().y))
	end
	for i,v in pairs(self.itemsHeight) do
		if i == 1 then
			height = height - v
		else
			height = height - v - self.itemsMargin
		end

		if self.itemList[1] and i >= self.itemList[1].listkey and i <= self.itemList[#self.itemList].listkey then
			item = self.itemList[i - self.itemList[1].listkey + 1]
			item:setPosition(cc.p(width/2 - item:getContentSize().width/2 + item:getContentSize().width*item:getAnchorPoint().x, height + item:getContentSize().height*item:getAnchorPoint().y))
			if i == self.itemList[#self.itemList].listkey then
				break
			end
		end
	end
	if self.nextItem then
		self.nextItem:setPosition(cc.p(width/2 - self.nextItem:getContentSize().width/2 + self.nextItem:getContentSize().width*self.nextItem:getAnchorPoint().x, self.nextItem:getContentSize().height*self.nextItem:getAnchorPoint().y))
	end
end

function CustomScrollView:updateTtemPosX()
	
end

function CustomScrollView:addItemTop()
	if self.itemList[1].listkey <= 1 then return end
	local cur_item = self:getDefaultItem()
	cur_item.listkey = self.itemList[1].listkey - 1
	cur_item:updataCell(self.datalist[cur_item.listkey])
	self:addChild(cur_item)
	table.insert(self.itemList,1, cur_item)
    self:setItemContentSize(cur_item.listkey, cur_item)
	self:updateItemPos(1)
	if #self.itemList > self.limitMaxNum then
		self.limitMaxNum = #self.itemList
	end
end
function CustomScrollView:addItemBottom()
	if #self.datalist <= self.itemList[#self.itemList].listkey then return end
	local cur_item = self:getDefaultItem()
	cur_item.listkey = self.itemList[#self.itemList].listkey + 1
	cur_item:updataCell(self.datalist[cur_item.listkey])
	self:addChild(cur_item)
	table.insert(self.itemList, cur_item)
    self:setItemContentSize(cur_item.listkey, cur_item)
	self:updateItemPos(#self.itemList)
	if #self.itemList > self.limitMaxNum then
		self.limitMaxNum = #self.itemList
	end
end

--设置下拉刷新
function CustomScrollView:setTopRefresh(enable,string,callback)
	self.topRefresh = enable
	self.topRefreshCallback = callback
	local top_ttf = self.inner:getChildByName("topText")
	local str = string == nil and "" or string
	if tolua.isnull(top_ttf) then
		top_ttf = cc.LabelTTF:create(str, GameRes.font1, 40)
		top_ttf:setName("topText")
		top_ttf:setAnchorPoint(cc.p(0.5,0.5))
		top_ttf:setPosition(cc.p(self:getInnerContainerSize().width/2, self:getInnerContainerSize().height + 100))
		self.inner:addChild(top_ttf)
	end
	top_ttf:setString(str)
    top_ttf:setVisible(enable)
end

--item点击回调
function CustomScrollView:itemTouchCallback(sender)
	self.selectItem = sender
end

--获取选中的Item
function CustomScrollView:getSelectItem()
	if tolua.isnull(self.selectItem) then return nil end
	return self.selectItem
end

--根据序号更新Item
function CustomScrollView:updateItemByKey(key,data)
	if self.datalist[key] and data then
		self.datalist[key] = clone(data)
	end
	local item = self:getItemByKey(key)
	if item then
		item:updataCell(self.datalist[item.listkey])
	end
end

function CustomScrollView:hideAllItems()
	for i,v in pairs(self.itemList) do
		v:setVisible(false)
	end
end

function CustomScrollView:showAllItems()
	for i,v in pairs(self.itemList) do
		v:setVisible(true)
	end
end

--设置Item初始化动画
function CustomScrollView:setShowActionEnabled(enable)
	self.showAction = enable
end

--设置item间距
function CustomScrollView:setItemsMargin(margin)
	self.itemsMargin = margin
end

--清空列表
function CustomScrollView:removeAllItems()
	self:stopAllActions()
	for i,v in pairs(self.itemList) do
		self:removeChild(v,true)
	end
	self.freshInnerSize = true
	self.itemList = {}
	self.itemsHeight = {}
	self.itemsWidth = {}
	self.datalist = {}
	self:updateInnerContentSize()
end

--删除某条记录,尚未测试
function CustomScrollView:removeItemByIndex(index)
	if not self.datalist[index] then return end
	table.remove(self.datalist,index)
	if self.direction == ccui.ScrollViewDir.vertical then
		table.remove(self.itemsHeight,index)
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		table.remove(self.itemsWidth,index)
	end
	--当要显示的item数小于已有的Item数时，删除当前item(可以解决item闪烁的问题，未详细测试慎用)
	-- if #self.datalist < #self.itemList then
	-- 	local i = 1
	-- 	while self.itemList[i] do
	-- 		if self.itemList[i].listkey == index then
	-- 			self:removeChild(self.itemList[i])
	-- 			table.remove(self.itemList,i)
	-- 			for j = i, #self.itemList do
	-- 				self.itemList[j].listkey = self.itemList[j].listkey - 1
	-- 			end
	-- 			break
	-- 		else
	-- 			i = i + 1
	-- 		end
	-- 	end
	-- end
	self.removeRefresh = true
	self:refreshScrollView(false)
end

--设置ItemModel
function CustomScrollView:setItemModel(node)
	self.defaultNode = node
end

--设置更新方法
function CustomScrollView:setUpdateFunc(func)
	self.updata = func
end

--底部插入一条数据，并刷新
function CustomScrollView:pushBackItemByData(data)
	self.datalist[#self.datalist + 1] = clone(data)
	self:refreshScrollView(false,#self.datalist)
end

--底部插入一段数据，并刷新
function CustomScrollView:pushBackItemsByData(data)
	local refresh_index = #self.datalist
	for i,v in pairs(data) do
		self.datalist[#self.datalist + 1] = clone(v)
	end
	self:refreshScrollView(false, refresh_index)
end

--更新某条数据
function CustomScrollView:updateData(index, data, refresh)
	if index <= #self.datalist then
		self.datalist[index] = clone(data)
	end
	if refresh then
		self:refreshScrollView()
	end
end

--序号获取Item
function CustomScrollView:getItemByKey(key)
	for i,v in pairs(self.itemList) do
		if key == v.listkey then
			return v
		end
	end
	return nil
end

--上一页
function CustomScrollView:setPrePage(enable,item)
	if not enable then
		if self.preItem and not tolua.isnull(self.preItem) then
			self:removeChild(self.preItem,true)
			self.preItem = nil
		end
	else
		if self.preItem ~= item then
			self:removeChild(self.preItem,true)
			self.preItem = item
			self:addChild(self.preItem)
		end
	end
	--刷新所有Item坐标
	self:updateItemPos()
end

--下一页
function CustomScrollView:setNextPage(enable,item)
	if not enable then
		if self.nextItem and not tolua.isnull(self.nextItem) then
			self:removeChild(self.nextItem,true)
			self.nextItem = nil
		end
	else
		if self.nextItem ~= item then
			self:removeChild(self.nextItem,true)
			self.nextItem = item
			self:addChild(self.nextItem)
		end
	end
	--刷新所有Item坐标
	self:updateItemPos()
end

--序号
function CustomScrollView:getIndex(item)
	return item.listkey
end

function CustomScrollView:getListCount()
	return #self.datalist
end

return CustomScrollView

