local Gamequit   = import(".components.Gamequit")
local GlobalView = class("GlobalView", qf.view)

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

return GlobalView