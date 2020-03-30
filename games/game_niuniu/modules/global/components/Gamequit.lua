local Gamequit = class("Gamequit",CommonWidget.PopupWindow)

Gamequit.Text          = 1228 --弹窗内容
Gamequit.Confirm       = 1226 --确定
Gamequit.Confirm_quit  = 1236 --确定退出
Gamequit.Cancel_quit   = 1238 --取消退出

function Gamequit:ctor()

	PopupManager.POPUPWINDOW = insert_enum(PopupManager.POPUPWINDOW,{"gamequit"})
	
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.game_quit_pop)
	self.super.ctor(self, {id=PopupManager.POPUPWINDOW.gamequit, child =self.gui })
	self:init()
end

function Gamequit:init()
	self.text = ccui.Helper:seekWidgetByTag(self.gui,Gamequit.Text)                       --弹窗内容
	self.text:setString(Niuniu_GameTxt.Game_quited)

	self.confirm      = ccui.Helper:seekWidgetByTag(self.gui,Gamequit.Confirm)            --确定
	self.confirm_quit = ccui.Helper:seekWidgetByTag(self.gui,Gamequit.Confirm_quit)       --确定退出
	self.cancel_quit  = ccui.Helper:seekWidgetByTag(self.gui,Gamequit.Cancel_quit)        --取消退出


	addButtonEvent(self.confirm,function (sender)
		-- body
		-- ModuleManager.global:show()
		qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="hide"})
		if self.paras.games == "kan" and self.paras.type=="nohandle" then
			ModuleManager.kancontroller:startAgain()
		end

		if self.paras.type=="nogold" then
			ModuleManager.niuniuhall:show()
		end
		
	end)

	--取消退出
	addButtonEvent(self.cancel_quit,function (sender)
		qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="hide"})
	end)

	--关闭按钮
	addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"btn_exit"),function (sender)
		qf.event:dispatchEvent(Niuniu_ET.GAME_QUIT_KICK,{method="hide"})
	end)
	ccui.Helper:seekWidgetByName(self.gui,"btn_exit"):setVisible(false)

	--确定退出
	addButtonEvent(self.confirm_quit,function (sender)
		qf.event:dispatchEvent(Niuniu_ET.RE_QUIT)
	end)
end

function Gamequit:closeView()
    self:close()
end



function Gamequit:show(paras)
    self.super.show(self)
    self.paras = {}
    self.paras = paras
    
    if paras.type == "nohandle" then
    	self.text:setString(Niuniu_GameTxt.Game_quited)
    	self.confirm:setVisible(true)
    	self.confirm_quit:setVisible(false)
    	self.cancel_quit:setVisible(false)
    end

    if paras.type == "nogold" then
    	self.text:setString(Niuniu_GameTxt.Game_no_gold)
    	self.confirm:setVisible(true)
    	self.confirm_quit:setVisible(false)
    	self.cancel_quit:setVisible(false)
    end

    if paras.type == "myselfquit" then
    	self.text:setString(Niuniu_GameTxt.Game_choose_quit)
    	self.confirm:setVisible(false)
    	self.confirm_quit:setVisible(true)
    	self.cancel_quit:setVisible(true)
    end


    if paras.type == "kanmyselfquit" then
    	self.text:setString(Niuniu_GameTxt.Kan_quit_tuo)
    	self.confirm:setVisible(false)
    	self.confirm_quit:setVisible(true)
    	self.cancel_quit:setVisible(true)
    end

end

return Gamequit