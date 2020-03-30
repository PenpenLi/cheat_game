--[[
    流光效果控件
        Author: Lynn
        Date: 2015/02/24
    使用示例:
        local bloomNode = BloomNode.new({image=xxx})    --创建
        xxx:addChild(bloomNode)
        bloomNode:playAnimation()   --开始闪光
    必要参数:
        paras.image: 图片文件
    可选参数, 用于调节流光效果时设置:
        paras.create: 是否创建图片，还是只添加流光效果。默认为true。
        paras.beam:  光束文件, 默认使用 ui/common/beam.png
        paras.direction: 光束移动方向, 参见BloomNode.DIRECTION_xxx, 默认值为 DIRECTION_LEFT_TO_RIGHT(从左至右)
        paras.move_time: 光束从图片一侧移动到另一侧花费的时间(秒), 默认按每秒移动BloomNode.MOVE_SPEED个像素点计算
        paras.move_back: 正向移动完成后，是否反向移动. 默认为false
        paras.move_repeat: 重复次数, 默认值为1
        paras.move_forever: 是否一直重复, 默认值为false. 如果设置了move_forever, move_repeat无效. 
        paras.move_interval: 当一直重复时，间隔时间。默认为move_time * 4. 当move_forever=true时有效. 
]]
local BloomNode = class("BloomNode",function (paras)
    return cc.ClippingNode:create()
end)
BloomNode.DEBUG = false
BloomNode.TAG = "BloomNode"

--光效运动方向
BloomNode.DIRECTION_LEFT_TO_RIGHT = 0               --从左至右
BloomNode.DIRECTION_UP_TO_BOTTOM = 1                --从上至下
BloomNode.DIRECTION_UPPERLEFT_TO_BOTTOMRIGHT = 2    --左上到右下

--光效运动速度
BloomNode.MOVE_SPEED = 1000

function BloomNode:ctor(paras)
    if paras == nil or paras.image == nil then
        return
    end
    self:_init(paras)
end

-- 播放闪光动画. 如果传入回调函数，则在一次动作完成后调用
function BloomNode:playAnimation(cb)
    self.properties.cb = cb
    if self.components.beam_sprite then
        self.components.beam_sprite:setVisible(true)
        local action = self:_getBeamAction()
        if action ~= nil then
	        self.components.beam_sprite:runAction(action)
        end
    end
end


-- 播放闪光动画. 在闪光动画move完成后立即调用回调
function BloomNode:playAnimationWithMoveCB(move_cb)

    self.properties.move_cb = move_cb

    if self.components.beam_sprite then
        local action = self:_getBeamAction()
        if action ~= nil then
            self.components.beam_sprite:runAction(action)
        end
    end
end

-- 停止闪光动画
function BloomNode:stopAnimation()
    if self.components.beam_sprite then
        self.components.beam_sprite:setVisible(false)
	    self.components.beam_sprite:stopAllActions()
    end
end

-- 初始化属性和子控件
function BloomNode:_init(paras)

    local stencil 
    if not paras.loadByPlist then
        stencil = cc.Sprite:create(paras.image)
    else
        stencil = cc.Sprite:createWithSpriteFrameName(paras.image)
    end
    self:setStencil(stencil)
    self:setAlphaThreshold(0)

    self.components = {}
    if paras.create then
        if not paras.loadByPlist then
            self.components.main_sprite = cc.Sprite:create(paras.image) 
        else
            self.components.main_sprite = cc.Sprite:createWithSpriteFrameName(paras.image)
        end
                                        --基本图像
        self:addChild(self.components.main_sprite)
    end
    self.components.beam_sprite = cc.Sprite:create(paras.beam or GameRes.common_widget_beam)    --光束图像
    self.components.beam_sprite:setVisible(false)
	self:addChild(self.components.beam_sprite)

    self.properties = {}
    self.properties.size = stencil:getContentSize()
    self.properties.direction = paras.direction or BloomNode.DIRECTION_LEFT_TO_RIGHT    --光束运动方向
    self.properties.move_time = paras.move_time or self:_getMoveTime(self.properties.direction)   --光束移动速度
    self.properties.move_back = paras.move_back or false                                --是否反向移动
    self.properties.move_repeat = paras.move_repeat or 1                                --光束闪过次数
    self.properties.move_forever = paras.move_forever or false                          --光束一直闪动
    self.properties.move_interval = paras.move_interval or self.properties.move_time * 4 --每次闪动的间隔
    if self.DEBUG then dump(self.properties) end
end

--计算移动时间
function BloomNode:_getMoveTime(direction)
    local size = self.properties.size
    local time = 0
    if direction == BloomNode.DIRECTION_LEFT_TO_RIGHT then
        time = size.width / BloomNode.MOVE_SPEED    --默认每秒移动500个像素点
    elseif direction == BloomNode.DIRECTION_UP_TO_BOTTOM then
        time = size.height / BloomNode.MOVE_SPEED
    elseif direction == BloomNode.DIRECTION_UPPERLEFT_TO_BOTTOMRIGHT then
        local len = math.sqrt(size.width * size.width + size.height * size.height)
        time = len / BloomNode.MOVE_SPEED
    end
    return time
end

--初始化Action
function BloomNode:_getBeamAction()
    --计算光效移动坐标
    local main_size = self.properties.size
    local beam_size = self.components.beam_sprite:getContentSize()
    local start_x, start_y, move_x, move_y
    if self.properties.direction == BloomNode.DIRECTION_LEFT_TO_RIGHT then
        start_x = (-main_size.width - beam_size.width) / 2
        start_y = 0
        move_x = main_size.width + beam_size.width
        move_y = 0
    elseif self.properties.direction == BloomNode.DIRECTION_UP_TO_BOTTOM then
        start_x = 0
        start_y = (main_size.height + beam_size.height) / 2
        move_x = 0
        move_y = -main_size.height - beam_size.height
    elseif self.properties.direction == BloomNode.DIRECTION_UPPERLEFT_TO_BOTTOMRIGHT then
        start_x = (-main_size.width - beam_size.width) / 2
        start_y = (main_size.height + beam_size.height) / 2
        move_x = main_size.width + beam_size.width
        move_y = -main_size.height - beam_size.height
    else
        return nil
    end

    if self.DEBUG then logd("x1="..start_x..", y1="..start_y..", move_x="..move_x..", move_y="..move_y, self.TAG) end
    self.components.beam_sprite:setVisible(true)
    self.components.beam_sprite:setPosition(start_x, start_y)
    --按顺序执行action
    local move = cc.MoveBy:create(self.properties.move_time, cc.p(move_x, move_y))
	local delay = cc.DelayTime:create(self.properties.move_time)
    local move2 = cc.MoveBy:create(self.properties.move_time, cc.p(-move_x, -move_y))
    local delay2 = cc.DelayTime:create(self.properties.move_interval)
    local reset = cc.CallFunc:create(function(sender) 
        sender:setPosition(start_x, start_y)
    end)
    local move_cb = cc.CallFunc:create(function(sender) 
        if self.properties.move_cb then self.properties.move_cb() end --移动完成后调用用户回调
    end)

    local end_cb = cc.CallFunc:create(function(sender) 
        if self.properties.cb then self.properties.cb() end --播放一次动画后调用用户回调
    end)
    local sequence_action
    if self.properties.move_back then
        sequence_action = cc.Sequence:create(move,move_cb, delay, move2,move_cb, delay2, end_cb)
    else
        sequence_action = cc.Sequence:create(move,move_cb, delay, reset, end_cb)
    end

    --重复动作
    local repeat_action
    if self.properties.move_forever then
        repeat_action = cc.RepeatForever:create(sequence_action)
    elseif self.properties.move_repeat > 1 then
        repeat_action = cc.Repeat:create(sequence_action, self.properties.move_repeat)
    else
        repeat_action = sequence_action
    end

    return repeat_action
end

return BloomNode