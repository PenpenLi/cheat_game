local GameStandup = class("GameStandup",CommonWidget.PopupWindow)

GameStandup.Text          = 1228 --弹窗内容
GameStandup.Confirm       = 1226 --确定
GameStandup.Confirm_quit  = 1236 --确定退出
GameStandup.Cancel_quit   = 1238 --取消退出

function GameStandup:ctor()

	PopupManager.POPUPWINDOW = insert_enum(PopupManager.POPUPWINDOW,{"gamestandup"})
	
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.game_quit_pop)
	self.super.ctor(self, {id=PopupManager.POPUPWINDOW.gamestandup, child =self.gui })
	self:init()

	


end

function GameStandup:init()
	self.text = ccui.Helper:seekWidgetByTag(self.gui,GameStandup.Text)                       --弹窗内容
	self.text:setString(Zjh_GameTxt.stand_up_tips)

	self.confirm      = ccui.Helper:seekWidgetByTag(self.gui,GameStandup.Confirm)            --确定
	self.confirm:setVisible(false)
	self.confirm_quit = ccui.Helper:seekWidgetByTag(self.gui,GameStandup.Confirm_quit)       --确定退出
	self.confirm_quit:setVisible(true)
	self.cancel_quit  = ccui.Helper:seekWidgetByTag(self.gui,GameStandup.Cancel_quit)        --取消退出
	self.cancel_quit:setVisible(true)
	--取消退出
	addButtonEvent(self.cancel_quit,function (sender)
		qf.event:dispatchEvent(Zjh_ET.GAME_Standup,{method="hide"})
	end)

	--确定退出
	addButtonEvent(self.confirm_quit,function (sender)
		GameNet:send({cmd=Zjh_CMD.CMD_EVENT_GOLD_FLOWER_UP_REQ,body={uin=Cache.user.uin,desk_id=Cache.zjhdesk.deskid}})
		qf.event:dispatchEvent(Zjh_ET.GAME_Standup,{method="hide"})
	end)






end

function GameStandup:closeView()
    self:close()
end



function GameStandup:show(paras)
    self.super.show(self)
    self.paras = {}
    self.paras = paras
end

return GameStandup