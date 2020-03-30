--[[
--@tomas 2017-2-7 16:47
--页签
--使用方法
--1，继承CocosStudio中Widget或layout，控制页签的宽高
--2，直接继承layout，并手动设置页签的宽高
--页签具有方向：1横向 2竖向
--页签有几种类型
--横向：1，正常态大小286X78，2，正常态大小297X74，3，正常态大小374X74，
--		4，正常态大小236X89
--截止2017-2-9，只支持横向布局
--]]

local M = class("Tabs", function( args )
	return args.node
end)

M.ON_CLICK = "ON_CLICK" --点击后触发
function M:ctor( args )
	--qf(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.size = self:getContentSize()
	self.width = self.size.width
	self.height = self.size.height
	self.center_pos = cc.p(self.width*0.5, self.height*0.5)
	if args.listener then
		self.eventListener=args.listener
	end
	self:_initDefault()

	self:init(args)

	self:initUI()

	self:initClick()

	self:_onClick(self.selected_index)
end

function M:_initDefault( ... )
	self.num = 2 --默认有2个按钮
	self.gap = 2 --每个tab的间隔
	self.kind = 1 --默认使用第一种类型
	self.lbl_kind = 1 --label默认是系统字
	self.direction = 1 --默认横向
	self.selected_index = 1 --默认选中第1个
	self.res_list = {}

	--初始化默认的横向4类所用到的资源
	self._default_res_list = {}
	for i = 1, 4 do
		local left_dis = LHD_Games_res[string.format("btn_tabs_%d_left_dis", i)]
		local left_nor = LHD_Games_res[string.format("btn_tabs_%d_left_nor", i)]
		local center_dis = LHD_Games_res[string.format("btn_tabs_%d_center_dis", i)]
		local center_nor = LHD_Games_res[string.format("btn_tabs_%d_center_nor", i)]
		table.insert(self._default_res_list, {
				[1] = {left_dis, left_dis, left_nor}
				, [2] = {center_dis, center_dis, center_nor}
				, [3] = {left_dis, left_dis, left_nor}
			})
	end
end

function M:init( args )
	self.num = args.num or self.num
	self.gap = args.gap or self.gap
	self.kind = args.kind or self.kind
	self.direction = args.direction or self.direction 
	self.selected_index = args.selected_index or self.selected_index
	self.res_list = clone(self._default_res_list[self.kind])
end

function M:initUI( ... )
	self.btn_list = {}
	self.img_list = {}
	self.lbl_list = {}
	self.btn_size_list = {}
	self.btn_size_total = cc.size(0, 0)
	for i = 1, self.num do
		local kind = i == 1 and 1 or i == self.num and 3 or 2
		local btn = self:createButton(kind)
		btn._index = i
		self:addChild(btn)
		table.insert(self.btn_list, btn)
		table.insert(self.btn_size_list, btn:getContentSize())

		local img = self:createImageView(kind)
		img._index = i
		self:addChild(img)
		table.insert(self.img_list, img)
	end

	for i = 1, self.num do
		self.btn_size_total = cc.size(self.btn_size_total.width+self.btn_size_list[i].width,self.btn_size_total.height+ self.btn_size_list[i].height)
	end
	self.btn_size_total.width = self.btn_size_total.width + (self.num - 1)*self.gap

	self:resetAllPosition()
end

function M:resetAllPosition( ... )
	local total_sz = self.btn_size_total
	local left_pos_x = self.center_pos.x - total_sz.width*0.5
	local left_pos_y = self.center_pos.y

	self.btn_pos_list = {}
	for i = 1, self.num do
		local cur_sz = self.btn_size_list[i]
		left_pos_x = left_pos_x + cur_sz.width*0.5

		self.btn_pos_list[i] = cc.p(math.floor(left_pos_x), left_pos_y)
		self.btn_list[i]:setPosition(self.btn_pos_list[i])
		self.img_list[i]:setPosition(self.btn_pos_list[i])

		left_pos_x = left_pos_x + cur_sz.width*0.5 + self.gap
	end
end

--重新设置label
--kind 1系统字 2美术字
--args数组 系统字文案或美术字图片
function M:resetLabel( kind, args )
	self.lbl_kind = kind or self.lbl_kind

	args = args or {}
	table.foreach(args, function( k, v )
		local lbl = self:createLabel(v)
		lbl:setPosition(self.btn_pos_list[k])
		self:addChild(lbl)

		self.lbl_list[k] = lbl
	end)

end

function M:initClick( ... )
	for i = 1, self.num do
		addButtonEvent(self.btn_list[i], function( sender )
			self:onClick(sender._index)
            MusicPlayer:playMyEffect("BTN")
		end)
	end
end

function M:_onClick( index )
	self.btn_list[self.selected_index]:setEnabled(true)
	self.img_list[self.selected_index]:setVisible(false)

	self.btn_list[index]:setEnabled(false)
	self.img_list[index]:setVisible(true)

	self.selected_index = index
end


function M:onClick( index )
	self:_onClick(index)
	self.eventListener({index=index})
end

function M:setClick( index )
	self:_onClick(index)
end

function M:createButton( kind )
	local btn = ccui.Button:create(self.res_list[kind][1], self.res_list[kind][2]
		, self.res_list[kind][3])
	btn:setEnabled(true)
	if kind == 3 then
		btn:setFlippedX(true)
	end
	return btn
end

function M:createImageView( kind )
	local img = ccui.ImageView:create(self.res_list[kind][3])
	img:setVisible(false)
	if kind == 3 then
		img:setFlippedX(true)
	end
	return img
end

function M:createLabel( args )
	local val = args.val
	local font = args.font or GameRes.font1
	local size = args.size or 60
	local lbl
	if self.lbl_kind == 1 then --系统字
		lbl = ccui.Text:create(val, font, size)
	elseif self.lbl_kind == 2 then
		lbl = ccui.ImageView:create(val)
	elseif self.lbl_kind == 3 then
		local cache = cc.SpriteFrameCache:getInstance()
		lbl = cc.Sprite:createWithSpriteFrame(cache:getSpriteFrameByName(val))
	end

	return lbl
end

function M:getSelectedIndex( ... )
	return self.selected_index
end

function M:getLabelByIndex( index )
	return self.lbl_list[index]
end

function M:setVisibleByIndex( index, visible )
	self.btn_list[index]:setVisible(visible)
	self.lbl_list[index]:setVisible(visible)
end
--重置位置：忽略不可见的元素
function M:resetByIgnoreHided( ... )
	local left_pos_y = self.center_pos.y
	local list = {}
	for i = 1, self.num do
		if self.btn_list[i]:isVisible() then
			table.insert(list, i)
		end
	end
	local total_sz = cc.size(0, 0)
	for i = 1, #list do
		total_sz = cc.sizeAdd(total_sz, self.btn_list[list[i]]:getContentSize())
	end
	total_sz.width = total_sz.width + (#list - 1)*self.gap
	local left_pos_x = self.center_pos.x - total_sz.width*0.5

	for i = 1, #list do
		local cur_sz = self.btn_list[list[i]]:getContentSize()
		left_pos_x = left_pos_x + cur_sz.width*0.5

		self.btn_list[list[i]]:setPosition(left_pos_x, left_pos_y)
		self.img_list[list[i]]:setPosition(left_pos_x, left_pos_y)
		self.lbl_list[list[i]]:setPosition(left_pos_x, left_pos_y)

		left_pos_x = left_pos_x + cur_sz.width*0.5 + self.gap
	end
end

return M