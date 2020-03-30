
local M = class("Display")


M.TAG = "Display"
local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local sharedAnimationCache   = cc.AnimationCache:getInstance()

local winSize = cc.Director:getInstance():getWinSize() 

M.cx  = winSize.width
M.cy  = winSize.height 
M.winSize = winSize

function M:ctor()

end


function M:showSmalWait()
	
end

function M:showBigWait()
end

--[[
txt
noclick
]]
function M:getChipWait(paras)  --筹码旋转等待动画
	local ret = cc.Node:create()
--	local f = GameRes.progress_item_bg
--	local dx = sprite:getContentSize().width/4
--	local dy = sprite:getContentSize().height/3

--	local start = cc.Sprite:create(f,cc.rect(0,0,dx,dy))
    local start = cc.Sprite:create(TexasRes.progress_item_1)
    local dx = start:getContentSize().width/4
    local size = start:getContentSize()
	local spriteFrames = {}
	for i = 1, 12  do
--		local y = math.floor( (i-1) /4)
--		local x = (i%4) - 1 if x == -1 then x = 3 end
        spriteFrames[i] = cc.SpriteFrame:create(TexasRes["progress_item_"..i],cc.rect(0,0,size.width,size.height))
	end
	local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.1)
    start:runAction(cc.RepeatForever:create( cc.Animate:create(animation) ) ) 
    local txt = cc.LabelTTF:create(paras.txt or GameTxt.net002, GameRes.font1, 36)
    txt:setTag(255)
    txt:setAnchorPoint(cc.p(0.5,1))
    txt:setPosition(10,-50)
    ret:addChild(txt)
    ret:addChild(start)

    function ret:setString(txt) 
    	local _t = self:getChildByTag(255)
    	if _t ~= nil then _t:setString(txt) end
    end

 --   	if paras.noclick == true then 
	--     local listener1 = cc.EventListenerTouchOneByOne:create()
	--     listener1:setSwallowTouches(true)
	--     listener1:registerScriptHandler(function(touch,event)
	--         return true
	--     end,cc.Handler.EVENT_TOUCH_BEGAN)

	--     listener1:registerScriptHandler(function(touch,event)

	--     end,cc.Handler.EVENT_TOUCH_ENDED)


	--     local eventDispatcher = ret:getEventDispatcher()
	--     eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, ret)
	-- end

    -- start:setScale(1.5)

	return ret
end
function M:getChipWait2(paras)  --筹码旋转等待动画
    local ret = cc.Node:create()
    local f = TexasRes.progress_item_bg
    local sprite = cc.Sprite:create(f)
    local dx = sprite:getContentSize().width/4
    local dy = sprite:getContentSize().height/3

    local start = cc.Sprite:create(f,cc.rect(0,0,dx,dy))
    local spriteFrames = {}
    for i = 1, 12  do
        local y = math.floor( (i-1) /4)
        local x = (i%4) - 1 if x == -1 then x = 3 end
        spriteFrames[i] = cc.SpriteFrame:create(f,cc.rect(x*dx,y*dy,dx,dy))
    end
    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.1)
    start:runAction(cc.RepeatForever:create( cc.Animate:create(animation) ) ) 

    local txt = cc.LabelTTF:create(paras.txt or GameTxt.net002, GameRes.font1, 36)
    txt:setTag(255)
    txt:setAnchorPoint(cc.p(0,0.5))
    txt:setPosition(dx*0.8,0)
    ret:addChild(txt)
    ret:addChild(start)

    function ret:setString(txt) 
        local _t = self:getChildByTag(255)
        if _t ~= nil then _t:setString(txt) end
    end
    return ret
end

--[[
node - sprite

	example : 
    local circle = Display:getCircleHead({file="a.png"})
    circle:setPosition(500,500)
    self:addChild(circle)

]]
function M:getCircleHead(paras)
	if paras == nil or paras.file == nil then return end
	return QNative:shareInstance():getCirleImg(GameRes.mask_png,paras.file)
end


function M:getSqHead(paras)
    if paras == nil or paras.file == nil then return end
    return QNative:shareInstance():getCirleImg(GameRes.sq_mask_png,paras.file)
end

---------窗口从左往右移出动作---------
--@param time,view,function
--@return action
function M:popToRightByScreen(paras)
    if paras.time==nil then paras.time=0.2 end
    if paras.view then
        paras.view:stopAllActions()
        paras.view:setAnchorPoint(cc.p(0,0))
        paras.view:setPosition(-paras.view:getContentSize().width, 0)
        paras.view:runAction(cc.Sequence:create(
            cc.MoveTo:create(paras.time,cc.p(0, 0)),
            cc.CallFunc:create(function ( sender )
                if paras.cb then paras.cb(sender) end
            end)
        ))
    end
end

---------窗口从右移出向左移出屏幕动作---------
--@param time,view,function
--@return action
function M:popBackByScreen(paras)
    if paras.time == nil then paras.time = 0.2 end
    if paras.view then
        paras.view:stopAllActions()
        -- paras.view:runAction(cc.Sequence:create(cc.FadeTo:create(paras.time, 0)))
        paras.view:runAction(cc.Sequence:create(
            cc.MoveBy:create(paras.time, cc.p(-paras.view:getContentSize().width, 0)), 
            cc.CallFunc:create(function (sender)
                if paras.cb then paras.cb(sender) end
            end)
        ))
    end
end

---------窗口从中心弹出动作---------
--@param time,view,function
--@return action
function M:popAction(paras)
    paras = paras or {}
    if paras.time==nil then paras.time=0.2 end
    if paras.view then
    	paras.view:setOpacity(0)
    	paras.view:runAction(cc.Sequence:create(
	        cc.EaseSineOut:create (cc.Spawn:create(
	            cc.ScaleTo:create(paras.time,1),
	            cc.FadeIn:create(paras.time)
	            )),
            cc.EaseSineOut:create(cc.ScaleTo:create(0.05,1.05)),
            cc.EaseSineIn:create(cc.ScaleTo:create(0.05,1)),
	        cc.CallFunc:create(function ( sender )
	            if paras.cb then paras.cb(sender) end
	        end)
        ))
    end
end

--------窗口收回到中心动作---------
--@param time,view,function
--@return action
function M:backAction(paras)
    paras = paras or {}
    if paras.time==nil then paras.time=0.2 end 
    if paras.view then 
        paras.view:runAction(cc.Sequence:create(
            cc.Spawn:create(
               --cc.ScaleTo:create(paras.time,0),
                cc.FadeOut:create(paras.time)
        ),
        cc.CallFunc:create(function(sender) 
            if paras.cb then paras.cb(sender) end 
        end)
        ))
    end
end

-------窗口从最小弹出来----------
--@param time,view,cb
function M:showScalePop(paras)
    paras = paras or {}
    paras.time = paras.time or 0.2
    if paras.view then
        paras.view:setAnchorPoint(0.5,0.5)
        paras.view:setScale(0)
        paras.view:runAction(cc.Sequence:create(
            cc.EaseSineOut:create(cc.ScaleTo:create(paras.time,1.1)),
            cc.EaseSineOut:create(cc.ScaleTo:create(paras.time,1)),
            cc.CallFunc:create(function(sender) 
                if paras.cb and type(paras.cb) == "function" then paras.cb(sender) end
            end)
        ))
    end
end



-------窗口缩小关闭----------
--@param view,cb
function M:showScaleBack(paras)
    paras = paras or {}
    local duration = paras.time or 0.1
    local scale = 0.8
    local opacity = 130
    if paras.view then 
        paras.view:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.ScaleTo:create(duration, scale),
                cc.FadeTo:create(duration, opacity)
            ),
            cc.CallFunc:create(function() 
                if paras.cb then paras.cb() end 
            end)
        ))
    end
end


function M:closeTouch(node)
	local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function(event,touch) return true end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener1:registerScriptHandler(function(event,touch)end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, node)
end

-- 添加一个绑定到对象的定时器
-- target: 目标对象
-- count: 执行的次数
-- step: 步长，每step秒执行一次
-- delay: 延时执行
-- callBack: 每次执行的回调
-- endCall: 尾调用
-- startCall: 开始执行时调用
function M:addLocalTimer( target, count, step, delay, callBack, endCall, startCall )
    if not target or tolua.isnull(target) then return end

    local sequence = {}
    if 0 < checkint(delay) then
        sequence[#sequence + 1] = cc.DelayTime:create(delay)
    end
    if startCall then
        sequence[#sequence + 1] = cc.CallFunc:create(function( sender )
            startCall(sender)
        end)
    end

    local exeBody = cc.Sequence:create(cc.DelayTime:create(step)
        , cc.CallFunc:create(function( sender )
            count = count - 1
            if callBack then
                callBack(sender, count)
            end
        end))

    if count <= 0 then
        sequence[#sequence + 1] = cc.RepeatForever:create(exeBody)
    else
        sequence[#sequence + 1] = cc.Repeat:create(exeBody, count)
        sequence[#sequence + 1] = cc.DelayTime:create(step)
        sequence[#sequence + 1] = cc.CallFunc:create(function( sender )
            if endCall then
                endCall(sender)
            end
        end)
    end

    local timer = target:runAction(cc.Sequence:create(sequence))
    return timer
end
-- 删除一个绑定到对象的定时器
function M:removeLocalTimer( target, timer )
    target:stopAction(timer)
end

--星星特效
function M:btnStarAni(star,delay,time)
    star:setScale(0.2)  
    star:setOpacity(0)  
    star:setVisible(true)
    star:runAction(self:_getStartAnimation(time,delay))
end

function M:_getStartAnimation(time,delay)
    local dtime = time/2
    local ret = cc.Sequence:create(
        cc.DelayTime:create(delay),
        cc.Spawn:create(
            cc.RotateBy:create(dtime,360),
            cc.Sequence:create(cc.FadeTo:create(dtime/2,255),cc.FadeTo:create(dtime/2,0)),
            cc.Sequence:create(cc.ScaleTo:create(dtime/2,1.1),cc.ScaleTo:create(dtime/2,0))
            )
        )
    return ret
end



--[[
-- 以特定模式创建一个包含多个图像帧对象的数组。
-- @function [parent=#display] newFrames
-- @param string pattern 模式字符串
-- @param integer begin 起始索引
-- @param integer length 长度
-- @param boolean isReversed 是否是递减索引
-- @return table#table frames (return value: table)  图像帧数组

-- 创建一个数组，包含 Walk0001.png 到 Walk0008.png 的 8 个图像帧对象
local frames = Display:newFrames("Walk%04d.png", 1, 8)

-- 创建一个数组，包含 Walk0008.png 到 Walk0001.png 的 8 个图像帧对象
local frames = Display:newFrames("Walk%04d.png", 1, 8, true)
--]]
function M:newFrames(pattern, begin, length, isReversed)
    local frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end

    for index = begin, last, step do
        local frameName = string.format(pattern, index)
        local frame = self:getFrame(frameName)
        if not frame then
            logd("Display:newFrames() - invalid frame, name %s", tostring(frameName))
            return
        end

        frames[#frames + 1] = frame
    end
    return frames
end
function M:getFrame( frameName )
    return sharedSpriteFrameCache:getSpriteFrame(frameName)
end


function M:newAnimation(frames, time)
    local count = #frames
    time = time or 1.0 / count
    return cc.Animation:createWithSpriteFrames(frames, time)
end
function M:setAnimationCache(name, animation)
    sharedAnimationCache:addAnimation(animation, name)
end
-- 获取一条骨骼动画
function M:getArmatureAnimation( name, complete_cb )
    local armature = ccs.Armature:create(name)
    local function animationEvent(armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.complete then
            if complete_cb then
                complete_cb(armature)
            end
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)

    return armature
end

Display = M.new()
