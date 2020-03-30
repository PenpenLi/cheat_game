
local IButton = class("IButton",function (paras) 
    return paras.node
end)


function IButton:ctor (paras) 
    self.src_posy=self:getPositionY()
	self:addTouchEventListener(

		function (sender, eventType)
			if sender.clickable == false then return false end
			if eventType == ccui.TouchEventType.began then
				return true
			elseif eventType == ccui.TouchEventType.moved then
			elseif eventType == ccui.TouchEventType.ended then
				MusicPlayer:playMyEffect("BTN")
				sender:click()
			elseif eventType == ccui.TouchEventType.canceled then
			end
		end
	)   
    self.callback = function () logd(" no click event ","IButton")end
    

    self.clickable = true
    self.value = 0
    if paras.keep == true then return end
    self:removeAllChildren()
    self:setTitleText("")
end

--[[--
改变外形及其功能

coat = {        纯外形
    res011 1/2 池底
    res012 2/3 池底
    res013 1 x 池底
    res022 3x大盲
    res016 4x大盲
    res014 跟任何住
    res009 自动看牌
    res017 看或弃
    res018 弃牌
    res008 all in
    res015 加注
    res019 看牌 
}



callback = function

number = 有数字 
fllow =  前面有个跟
value = 点击按钮时上传给服务器的值

实例
local a = IButton

a:changStatus({coat="res008",callback=function() end})   将按钮形状改为 allin
a:changStatus({number=100000}) // 显示纯数字 10w
a:changStatus({number=10000,fllow=true})  将按钮形状改为 跟10w

]]

function IButton:changeStatus(paras)

    if paras.coat then
        
        local c = cc.Sprite:create(GameRes[paras.coat])
        c:setPosition(self:getContentSize().width/2,self:getContentSize().height/2+4)
        self:removeAllChildren(true)
        self:addChild(c)
    end

    if paras.number then 
        local c = self:_genNumberNode(paras.number,paras.fllow,nil,paras.point_process)
        c:setPosition(self:getContentSize().width/2-c:getContentSize().width/2,self:getContentSize().height/2+4)
        self:removeAllChildren(true)
        self:addChild(c)

    end



    if paras.callback then
        self.callback = paras.callback
    end
    
    if paras.value then self.value = paras.value end

end

function IButton:changeStatusEx( paras )
    -- body
    if paras.resPath then
        
        -- local c = cc.Sprite:create(paras.resPath)
        -- c:setPosition(self:getContentSize().width/2,self:getContentSize().height/2+4)
        -- self:removeAllChildren(true)
        -- self:addChild(c)
    end
    if paras.number then 
        self:setTitleFontName(GameRes.font1)
        self:setTitleFontSize(40)
        self:setTitleText(paras.number)
    end
    if paras.value then self.value = paras.value end
end

function IButton:_appendNode ( father , node) 
    local size = father:getContentSize()
    node:setAnchorPoint(cc.p(0,0.5))
    node:setPosition(size.width,0)
    father:addChild(node)
    father:setContentSize(size.width+node:getContentSize().width,node:getContentSize().height)
end

function IButton:_genNumberNode( number,fllow , fllowres,point_process)
    local ret = cc.Node:create()
    ret:setContentSize(0,0)
    ret:setAnchorPoint(cc.p(0,0))
    local m = false
    local k = false

    local number, u = Util:getFormat(number)
    if u ~= nil then 
        if u == GameTxt.string012 then m = true
        elseif u == GameTxt.string011 then k = true
        else end
    end

    local nl = cc.LabelAtlas:_create(number,GameRes.res025, 32, 46, string.byte('.'))
    if point_process==true then
    local precision = (number > 1000000 and number < 100000000) and 0 or 2 
      local temp_txt= Util:getFormatString(number, precision)
       nl:setString(temp_txt)
    end
    
    if fllow == true then self:_appendNode(ret,cc.Sprite:create(fllowres or GameRes.res023)) end
    self:_appendNode(ret,nl)
    if m == true then self:_appendNode(ret,cc.Sprite:create(GameRes.res027)) end
    if k == true then self:_appendNode(ret,cc.Sprite:create(GameRes.res026)) end
    
    return ret
end




function IButton:setCallback(cb) 
    self.callback = cb
end

function IButton:click () 
    if self.callback == nil then return end
    self.callback(self)
end

function IButton:hide(is_action)
    if is_action==nil then 
     self:setVisible(false)
    else
     self:stopAllActions()
     self:runAction(cc.Sequence:create(
         cc.MoveTo:create(0.2,cc.p(self:getPositionX(),self.src_posy-200)),
        cc.CallFunc:create(function() 
              self:setVisible(false)  
            end)
        ))
    end
end

function IButton:show(unreset,is_action)
    
    if unreset == nil then 
        self:setEnable(true)
    end
    self:setVisible(true)
    if is_action then 
    self:stopAllActions()
    self:runAction(cc.MoveTo:create(0.3,cc.p(self:getPositionX(),self.src_posy)))
    end
end


function IButton:setEnable(var)
    if var == false then
        self.clickable = var
        self:setColor(cc.c3b(75,75,75))
    elseif var == true then 
        self.clickable = var
        self:setColor(cc.c3b(255,255,255))
    end
end

function IButton:setName(paras)
    if paras.name then self.name = paras.name end
    if paras.tag then self.tag = paras.tag end
    if paras.content then self.content = paras.content end
end
function IButton:setSelect(paras)
	if paras.select then self.select = paras.select end
end

return IButton