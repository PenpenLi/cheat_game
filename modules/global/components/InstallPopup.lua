local InstallPopup    = class("InstallPopup",CommonWidget.PopupWindow)


InstallPopup.cancel   = 6
InstallPopup.confirm  = 7
InstallPopup.progress  = 16
InstallPopup.progress_panel = 12
InstallPopup.if_install = 13
InstallPopup.font = 5
InstallPopup.num  = 23

function InstallPopup:ctor(para)
	self.name = para.name
	self.size = para.size
	self.unit = para.unit
	self.confirmHandle = para.confirmHandle
	self.uniq = para.uniq
	self.target = para.target
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.install_games)
	self.super.ctor(self, {id=PopupManager.POPUPWINDOW.installgame, child =self.gui })
	self:init()
	
	self:initevent()
end


function InstallPopup:init()
	self.cancel  =  ccui.Helper:seekWidgetByTag(self.gui,InstallPopup.cancel) 
	self.confirm =  ccui.Helper:seekWidgetByTag(self.gui,InstallPopup.confirm) 
	self.progress =  ccui.Helper:seekWidgetByTag(self.gui,InstallPopup.progress)
	self.progress_panel =  ccui.Helper:seekWidgetByTag(self.gui,InstallPopup.progress_panel)
	self.if_install =  ccui.Helper:seekWidgetByTag(self.gui,InstallPopup.if_install)
	self.font =  ccui.Helper:seekWidgetByTag(self.gui,InstallPopup.font)
	self.num =  ccui.Helper:seekWidgetByTag(self.gui,InstallPopup.num)
	-- self.progress_panel:setVisible(false)
	-- self.if_install:setVisible(false)
	local unit = self.unit
	if self.unit == nil then
		unit = ""
	end
	self.font:setString(string.format(GameTxt.INSTALL_GAMES_TIPS,self.name,self.size..unit))
end


function InstallPopup:initevent()
	addButtonEvent(self.cancel,function()
		self:close()
	end)

	--下载游戏回调
    local  installProgress= function (count,total_count)
        self.progress_panel:setVisible(true)
        self.if_install:setVisible(false)
        local percent = math.floor(count*100/total_count)
        percent = percent > 100 and 100 or percent
        self.progress:setPercent(percent)
        self.num:setString(percent)
    end

    local installed = function ()
        -- body
        self.target:setVisible(false)
        table.insert(GAME_INSTALL_LIST,self.uniq)
        GAME_INSTALL_TABLE[self.uniq] = 1
        cc.UserDefault:getInstance():setStringForKey(SKEY.GAME_INSTALL_LIST ,json.encode(GAME_INSTALL_LIST))
        cc.UserDefault:getInstance():flush();
        require("src.games."..self.uniq..".init")
        qf.event:dispatchEvent(ET.INSTALL_GAME_POP,{method="hide"})
    end

	addButtonEvent(self.confirm,function()
		if self.confirmHandle then
			self.confirmHandle()
			self:close()
		else
			self.progress_panel:setVisible(true)
	        self.if_install:setVisible(false)
	        self.num:setString(0)
	        qf.event:dispatchEvent(ET.INSTALL_GAME,{uniq=self.uniq,installProgress=installProgress,installed=installed})
		end
		
	end)
end


function InstallPopup:closeView()
    self:close()
end

return InstallPopup