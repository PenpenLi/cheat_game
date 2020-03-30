local PreloadController = class("PreloadController",qf.controller)

local ProloadView = import(".PreloadView")

PreloadController.TAG = "PreloadController"

function PreloadController:ctor(parameters)
    self.super.ctor(self)
    
end


function PreloadController:initModuleEvent()
    
end

function PreloadController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function PreloadController:initGlobalEvent()
    qf.event:addEvent(ET.PRELOAD_JSON_END,handler(self,self.preloadEnd))
end
function PreloadController:initGame()

end

function PreloadController:preloadEnd()
    if LayerManager.PreloadLayer then 
        LayerManager.PreloadLayer:removeFromParent(true) 
        LayerManager.PreloadLayer = nil 
    end
--    ModuleManager.main:show()
--    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
--    qf.event:dispatchEvent(ET.NET_AUTO_INPUT_ROOM)
--    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove",reConnect = 1})
--    qf.event:dispatchEvent(ET.NOTIFY_REFRESH_DESK) --//通知刷新大厅界面
    self:remove()
end

function PreloadController:initView(parameters)
    if LayerManager.PreloadLayer == nil then self:preloadEnd() return end
    qf.event:dispatchEvent(ET.MODULE_SHOW,"preload")
    local view = ProloadView.new()
    return view
end

function PreloadController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"preload")
    self.super.remove(self)
end

return PreloadController