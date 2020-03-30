--[[
-- 公共提示弹窗
--]]

local M = class("CommonTipWindow", CommonWidget.PopupWindow)

M.COMMON_TYPE_1 = 1 -- 标题、内容、取消、确认、退出
M.COMMON_TYPE_2 = 2 -- 标题、内容、取消、确认
M.COMMON_TYPE_3 = 3 -- 标题、内容、确认
M.COMMON_TYPE_4 = 4 -- 标题、内容、退出比赛、取消
M.COMMON_TYPE_5 = 5 -- 标题、内容、退出比赛
M.COMMON_TYPE_6 = 6 -- 标题、内容、确认、取消
M.COMMON_TYPE_7 = 7 -- 标题、内容、前往下载
M.COMMON_TYPE_8 = 8 -- 标题、内容、前往商城
M.COMMON_TYPE_9 = 9 -- 标题、内容、继续旁观、快速匹配


--self.data
--cb_consure:确认按钮事件
--cb_cancel:取消按钮事件
--type:类型
--content：文本
--is_enabled:物理返回键、空白处能否响应点击
--auto_time:弹窗自动销毁的时间
--auto_type:自动销毁时执行的事件，=1确认事件 =2取消事件
function M:ctor( args )
	self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.commonTipWindowJson)

	self.data = args
	self.data.is_enabled = self.data.is_enabled ~= false

	self:initUI()
	self:initClick()

    self.super.ctor(self, {id=PopupManager.POPUPWINDOW["commonTipWindow"], child=self.root})
end

function M:initUI( ... )
	self.pan_root = self.root:getChildByName("pan_root")

	self.img_bg = self.pan_root:getChildByName("img_bg")
	self.img_title = self.pan_root:getChildByName("img_title")
	self.btn_cancel = self.pan_root:getChildByName("btn_cancel")
	self.img_cancel = self.btn_cancel:getChildByName("img_cancel")
	self.btn_consure = self.pan_root:getChildByName("btn_consure")
	self.img_consure = self.btn_consure:getChildByName("img_consure")
	self.btn_exit = self.pan_root:getChildByName("btn_exit")
	self.btn_godownload = self.pan_root:getChildByName("btn_godownload")
	self.btn_gochat = self.pan_root:getChildByName("btn_gochat")

	local fontsize
	if self.data.fontsize then
		fontsize=self.data.fontsize
	else
		fontsize=42
	end
	local lbl_content = cc.Label:createWithSystemFont("", GameRes.font1, fontsize)
    self.pan_root:addChild(lbl_content)
    lbl_content:setAnchorPoint(0.5, 0.5)
    lbl_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    lbl_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    lbl_content:setPosition(cc.p(560, 348))
    lbl_content:setDimensions(880, 0)

    self.lbl_content = lbl_content
    if self.data.color then
		self.lbl_content:setColor(self.data.color)
	end
	
	self:_initUI()
	self:_startAutoCloseTimer()
end

function M:_initUI( ... )
	local _type = self.data.type
	if _type == self.COMMON_TYPE_1 then
		self:_initUIByType1()
	elseif _type == self.COMMON_TYPE_2 then
		self:_initUIByType2()
	elseif _type == self.COMMON_TYPE_3 then
		self:_initUIByType3()
	elseif _type == self.COMMON_TYPE_4 then
		self:_initUIByType4()
	elseif _type == self.COMMON_TYPE_5 then
		self:_initUIByType5()
	elseif _type == self.COMMON_TYPE_6 then
		self:_initUIByType6()
	elseif _type == self.COMMON_TYPE_7 then
		self:_initUIByType7()
	elseif _type == self.COMMON_TYPE_8 then
		self:_initUIByType8()
	elseif _type == self.COMMON_TYPE_9 then
		self:_initUIByType9()
	end

	local content_size = self.lbl_content:getContentSize()
	if content_size.height < 100 then --假设这是一行
		self.lbl_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	end
end

function M:_initUIByType1( ... )
	self.lbl_content:setString(self.data.content)
end
function M:_initUIByType2( ... )
	self.lbl_content:setString(self.data.content)
	self.btn_exit:setVisible(false)
end
function M:_initUIByType3( ... )
	self.lbl_content:setString(self.data.content)
	self.btn_exit:setVisible(false)
	self.btn_cancel:setVisible(false)

	self.btn_consure:setPositionX(self:_getCenterX())
end

function M:_initUIByType4( ... )
	self.lbl_content:setString(self.data.content)
	self.btn_exit:setVisible(false)
	self.img_cancel:loadTexture(GameRes.img_exit_game)
	self.img_consure:loadTexture(GameRes.img_cancel)
	self.lbl_content:setFontSize(60)
	self.data.cb_cancel, self.data.cb_consure = self.data.cb_consure, self.data.cb_cancel
end
function M:_initUIByType5( ... )
	self.lbl_content:setString(self.data.content)
	self.btn_exit:setVisible(false)
	self.img_cancel:setVisible(false)
	self.img_consure:loadTexture(GameRes.img_exit_game)

	self.btn_consure:setPositionX(self:_getCenterX())
end
function M:_initUIByType6( ... )
	self.lbl_content:setString(self.data.content)
	self.btn_exit:setVisible(false)
	self.img_cancel:loadTexture(GameRes.img_consure)
	self.img_consure:loadTexture(GameRes.img_cancel)
	self.data.cb_cancel, self.data.cb_consure = self.data.cb_consure, self.data.cb_cancel
end

function M:_initUIByType7( ... )
	self.lbl_content:setString(self.data.content)
	Util:setPosOffset(self.lbl_content, {y=30})
	self.btn_godownload:setVisible(true)
	self.btn_cancel:setVisible(false)
	self.btn_consure:setVisible(false)
end

function M:_initUIByType8( ... )
	self.lbl_content:setString(self.data.content)
	self.btn_consure:setVisible(false)
	self.btn_cancel:setVisible(false)
	self.btn_gochat:setVisible(true)
	local resName = Util:getReviewStatus() and GameRes.guide_to_shop_image or GameRes.guide_to_chat_image
	self.btn_gochat:getChildByName("img_consure"):loadTexture(resName, ccui.TextureResType.plistType)
end

function M:_initUIByType9( ... )
	self.lbl_content:setString(self.data.content)
	self.btn_consure:setVisible(true)
	self.btn_cancel:setVisible(true)
	self.btn_exit:setVisible(false)
	self.btn_consure:getChildByName("img_consure"):loadTexture(GameRes.guide_to_quick_start_image, ccui.TextureResType.plistType)
	self.btn_cancel:getChildByName("img_cancel"):loadTexture(GameRes.guide_to_quit_image, ccui.TextureResType.plistType)
end

function M:_getCenterX( ... )
	local posx_cancel = self.btn_cancel:getPositionX()
	local posx_consure = self.btn_consure:getPositionX()
	return (posx_consure+posx_cancel)/2
end

function M:initClick( ... )
	--如果设置不能点击空白区域
	if self.data.is_enabled then
	    Util:registerKeyReleased({self = self,cb = function ()
	        self:_onCancelClick()
	    end})
		addButtonEvent(self.root, function( ... )
			self:_onCancelClick()
		end)
	end
	addButtonEvent(self.btn_exit, function( ... )
		self:_onCancelClick()
	end)
	addButtonEvent(self.btn_cancel, function( ... )
		self:_onCancelClick()
	end)
	addButtonEvent(self.btn_consure, function( ... )
		self:_onConsureClick()
	end)
	addButtonEvent(self.btn_godownload, function( ... )
		self:_onDownLoadClick()
	end)
	addButtonEvent(self.btn_gochat, function( ... )
		self:_onConsureClick()
	end)
end
--自动关闭
function M:_startAutoCloseTimer( ... )
	local auto_time = checkint(self.data.auto_time)
	local auto_type = checkint(self.data.auto_type)
	if auto_time <= 0 then return end

	Display:addLocalTimer(self, auto_time, 1, nil, nil, function( ... )
		if auto_type == 1 then
			self:_onConsureClick()
		else
			self:_onCancelClick()
		end
	end)
end
function M:_onCancelClick( ... )
	self:close()
	if self.data.cb_cancel then
		self.data.cb_cancel()
	end
end
function M:_onConsureClick( ... )
	self:close()
	if self.data.cb_consure then
		self.data.cb_consure()
	end
end
function M:_onDownLoadClick( ... )
	self:close()
	if self.data.cb_godownload then
		self.data.cb_godownload()
	end
end

return M