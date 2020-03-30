local Gamequit   = import(".components.Gamequit")
local GlobalView = class("GlobalView", qf.view)
local GameStandup   = import(".components.GameStandup")

function GlobalView:ctor(parameters)
	 self.super.ctor(self,parameters)
end


function GlobalView:init()
    self.winSize = cc.Director:getInstance():getWinSize()

end



function GlobalView:getRoot()
    return LayerManager.Global
end

function GlobalView:removeExistView()

end

--[[-- 弹出没操作被人踢了提示框]]
function GlobalView:showGamequit(paras)
    qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
    local gamequit = Gamequit.new()
    gamequit:show(paras)

end

--[[-- 隐藏没操作被人踢了提示框]]
function GlobalView:hideGamequit()
	local gamequit = nil
	if  PopupManager.POPUPWINDOW.gamequit then
	   gamequit = 	PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.gamequit)
	end

    if gamequit ~= nil then
        gamequit:closeView()
    end
end

--站起
function GlobalView:showGameStandup(paras)
    qf.event:dispatchEvent(ET.REMOVE_QUICKLY_CHAT)
    local gamestandup = GameStandup.new()
    gamestandup:show(paras)

end

--站起
function GlobalView:hideGameStandup()
    local gamestandup = nil
    if  PopupManager.POPUPWINDOW.gamestandup then
       gamestandup =   PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.gamestandup)
    end

    if gamestandup ~= nil then
        gamestandup:closeView()
    end
end

return GlobalView