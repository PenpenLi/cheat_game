
local IButton = class("IButton",function (paras) 
    return paras.node
end)

function IButton:setName(paras)
    self.name = paras.name
end

function IButton:ctor (paras) 

    self:addTouchEventListener(

            function (sender, eventType)
                if sender.clickable == false then return false end
                if eventType == ccui.TouchEventType.began then
                    return true
                elseif eventType == ccui.TouchEventType.moved then
                elseif eventType == ccui.TouchEventType.ended then
                    if Cache.clickNum == 0 then
                        MusicPlayer:playMyEffect("BTN")
                        sender:click()
                        Cache.clickNum = 1
                        Util:delayRun(0.018,function() Cache.clickNum = 0 end)
                    end
                elseif eventType == ccui.TouchEventType.canceled then
                end
            end
    ) 

    self.callback = function () logd("no click event ","IButton")end
    self.selected = false
end

function IButton:setCallback(cb) 
    self.callback = cb
end

function IButton:setSelect(bool)
    self.selected = bool;
end
function IButton:click () 
    if self.selected == false then
        self.callback(self)
    end
end

--[[--更新按钮的背景 以及内容显示
M. = "ui/rank/ranking_friend_down_btn.png"
M. = "ui/rank/ranking_friend_up_btn.png"
M. = "ui/rank/ranking_world_down_btn.png"
M.= "res/ui/rank/ranking_world_up_btn.png"

实例
local a = IButton
a:changStatus({coat="rank_friend_bg01"}) 好友排行显示亮的 背景 
a:changStatus({coat="rank_friend_bg02"}) 好友排行显示暗的 背景 
a:changStatus({coat="rank_world_bg01"}) 世界排行显示亮的 背景 
a:changStatus({coat="rank_world_bg02"}) 世界排行显示亮的 背景 
]]
function IButton:changeStatus(paras)
    
    if paras.coat and paras.type == 1 then
        local c = cc.Sprite:create(GameRes[paras.coat])
        c.setScale(c,-1,-1)
        c:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        --self:removeAllChildren(true)
        self:addChild(c)
    end
    if paras.coat then
        local c = cc.Sprite:create(GameRes[paras.coat])
        c:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        --self:removeAllChildren(true)
        self:addChild(c)
    end
end


return IButton