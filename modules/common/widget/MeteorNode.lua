--[[
    按规则移动的流光效果控件
        Author: Lynn
        Date: 2015/02/25        
    创建控件的必要参数:
        paras.image 移动的图片
        paras.width, paras.height 控件大小
        paras.duration 完成一次运动轨迹需要的时间
        paras.circle 是否做圆周运动
        paras.trail 轨迹描述表, 精灵将按照此轨迹运动。
            当做圆周运动时(circle==true)，trail结构如下：
                {x = 100, y = 100, center = cc.p(200, 200), clockwise=true}
                其中，x, y是起始位置, center是圆心, clockwise表示是否按顺时针旋转
            当轨迹是多边形或者带弧线的不规则图形时(circle==false)，trail结构如下: 
                {
                    {x=1, y=1, isBezierPoint=false}, 
                    {x=2, y=2, isBezierPoint=true}, 
                }
                其中x, y是点的坐标, 直接填入美术给出的坐标即可, 即以左上角为(0, 0)点，如下
                 (0, 0) ------------->
                    |  (1, 1) (2, 1) ...
                    |  (1, 2) (2, 2) ...
                    |   ...   ...
                    |   ...   ...
                    v
                isBezierPoint=true代表是贝塞尔曲线上的点
                注意, 1. 要求第一个点不能是贝塞尔曲线上的点; 2. 轨迹将被认为是一个闭合图形
        创建控件的可选参数:
            paras.repeat_num 重复次数. <=0 则被视为永远重复. 默认值为0.
    使用示例:
        见文档SampleMeteorNode
]]

local MeteorNode = class("MeteorNode",function (paras)
    return cc.Node:create()
end)

MeteorNode.TAG = "MeteorNode"
MeteorNode.DEBUG = false
MeteorNode.TRAIL_TYPE_UNKNOW = 0   --未知轨迹
MeteorNode.TRAIL_TYPE_LINE = 1     --直线
MeteorNode.TRAIL_TYPE_BEZIER = 2   --贝塞尔曲线

function MeteorNode:ctor(paras)
    self:_init(paras)
end

--[[    
    public interface 
]]

--设置自定义的拖尾效果. 参数: cc.MotionStreak对象. 不设置则使用默认的拖尾效果. 
function MeteorNode:setCustomMotionStreak(motion_streak)
    self.components.motion_streak = motion_streak
end
--禁用拖尾效果
function MeteorNode:disableMotionStreak()
    self.properties.motion_streak_enabled = false
end

--设置自定义的粒子效果. 参数: cc.ParticleXX 对象. 不设置则使用默认的例子效果。
function MeteorNode:setCustomParticle(particle)
    self.components.particle = particle
end
--禁用粒子效果. 
function MeteorNode:disableParticle()
    self.properties.particle_enabled = false
end

--播放动画
function MeteorNode:playAnimation()
    if self:_createAllComponents() then --创建所有组件
        --创建动作
        local base_action
        if self.properties.circle then
            base_action = self:_createActionCircle()
        else
            base_action = self:_createActionPolygon()
        end
        if base_action == nil then 
            self:_log("base action create failed")
            return 
        end
        --重复动作
        local repeat_action
        if self.properties.repeat_num <= 0 then
            repeat_action = cc.RepeatForever:create(base_action)
        elseif self.properties.repeat_num > 1 then
            repeat_action = cc.Repeat:create(base_action, self.properties.repeat_num)
        else
            repeat_action = base_action
        end
        --执行动作
        self.components.sprite:runAction(repeat_action)
        if self.properties.motion_streak_enabled and self.components.motion_streak ~= nil then
            local follow_action = repeat_action:clone()
            self.components.motion_streak:runAction(follow_action)
        end
        if self.properties.particle_enabled and self.components.particle ~= nil then
            local follow_action = repeat_action:clone()
            self.components.particle:runAction(follow_action)
        end
    else
        self:_log("create components failed")
    end
end


--停止动画
function MeteorNode:stopAnimation()
    if self.components.sprite and not tolua.isnull(self.components.sprite) then 
    self.components.sprite:stopAllActions()
    end
    if self.components.motion_streak and not tolua.isnull(self.components.motion_streak) then
    self.components.motion_streak:stopAllActions()
   end
end


--[[    
    private function
]]
--初始化
function MeteorNode:_init(paras)
    --参数完整性检测
    if paras.image == nil or paras.width == nil or paras.height == nil 
        or paras.duration == nil or paras.circle == nil or paras.trail == nil then
        self:_log("MeteorNode.new() has wrong number of arguments.")
        return
    end
    
    self.components = {}    --子控件
    self.properties = {}    --属性

    --属性初始化
    self.properties.image = paras.image
    self.properties.width = paras.width
    self.properties.height = paras.height
    self.properties.duration = paras.duration
    self.properties.circle = paras.circle
    self.properties.repeat_num = paras.repeat_num or 0
    self.properties.motion_streak_enabled = true
    self.properties.particle_enabled = true

    self:setContentSize(paras.width, paras.height)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setPosition(cc.p(paras.width/2, paras.height/2))

    --创建轨迹
    if not paras.circle then
        self:_createTrailPolygon(paras.trail)
    else
        self:_createTrailCircle(paras.trail)
    end

    if self.DEBUG then dump(self.running_trail) end
    if self.DEBUG then dump(self.properties) end
end


--圆周运动轨迹记录
function MeteorNode:_createTrailCircle(trail)
    --轨迹
    self.running_trail = {}
    self.running_trail.x = trail.x
    self.running_trail.y = trail.y
    self.running_trail.center = trail.center
    self.running_trail.clockwise = trail.clockwise or true
    --记录起始点
    self.properties.position = cc.p(trail.x, trail.y)
end

--计算多边形运动轨迹
function MeteorNode:_createTrailPolygon(trail)
    self.running_trail = {} --轨迹
    
    --转换点
    local convertPos = function(pos)
        return cc.p(pos.x, self.properties.height - pos.y)
    end

    --将点写入轨迹
    local writeToTrail = function(new_trail, trail_type, point)
        if point == nil then return end
        if new_trail then
            self.running_trail[#self.running_trail + 1] = {}
        end
        local element = self.running_trail[#self.running_trail] --要写入的轨迹
        local finish = false  --这条轨迹是否已经处理完毕
        --将点写入轨迹
        if trail_type == MeteorNode.TRAIL_TYPE_LINE then
            --将点写入一条直线
            element.type = MeteorNode.TRAIL_TYPE_LINE
            if element.start_point == nil then
                element.start_point = convertPos(point)
            else
                element.end_point = convertPos(point)
                finish = true
            end
        elseif trail_type == MeteorNode.TRAIL_TYPE_BEZIER then
             --将点写入贝塞尔曲线
            element.type = MeteorNode.TRAIL_TYPE_BEZIER
            if element.p0 == nil then
                element.p0 = convertPos(point)
            elseif element.p1 == nil then
                element.p1 = convertPos(point)
            elseif element.p2 == nil then
                element.p2 = convertPos(point)
            else
                element.p3 = convertPos(point)
                finish = true
            end
        end
        return finish
    end

    --逐个点处理，分解轨迹
    local trail_type = MeteorNode.TRAIL_TYPE_UNKNOW    --轨迹类型
    local stack_pointer = 2
    local processOnePoint
    processOnePoint = function()
        local previous_point = (stack_pointer == 1) and trail[#trail] or trail[stack_pointer - 1]
        local current_point = trail[stack_pointer]
        local next_point = (stack_pointer == #trail) and trail[1] or trail[stack_pointer + 1]
        self:_log("==========================================")
        self:_log("stack_pointer = "..stack_pointer)
        self:_log("previous_point = "..tostring(previous_point.isBezierPoint))
        self:_log("current_point = "..tostring(current_point.isBezierPoint))
        self:_log("next_point = "..tostring(next_point.isBezierPoint))
        
        if trail_type == MeteorNode.TRAIL_TYPE_UNKNOW then
            --未知轨迹类型, 根据前后点、当前点确定轨迹类型，并新建
            if current_point.isBezierPoint then
                self:_log("process: add new bezier trail")
                --当前点是贝塞尔曲线上的点。加入前一点作为起始点。
                writeToTrail(true, MeteorNode.TRAIL_TYPE_BEZIER, previous_point)
                --加入当前点
                writeToTrail(false, MeteorNode.TRAIL_TYPE_BEZIER, current_point)
                --确定类型
                trail_type = MeteorNode.TRAIL_TYPE_BEZIER
            else
                if not previous_point.isBezierPoint then
                    self:_log("process: add new line trail")
                    --前一个点不是贝塞尔曲线上的点，添加一条直线
                    writeToTrail(true, MeteorNode.TRAIL_TYPE_LINE, previous_point)
                    writeToTrail(false, MeteorNode.TRAIL_TYPE_LINE, current_point)
                else
                    --前一个点是贝塞尔曲线上的点，不处理
                end
            end          
        else
            self:_log("process: continue writting bezier trail")
            --已知轨迹类型, 说明当前还有轨迹在处理, 继续将点加入
            local finish = writeToTrail(false, trail_type, current_point)
            if finish then trail_type = MeteorNode.TRAIL_TYPE_UNKNOW end
        end

        --最后一个点，做图形闭合
        if stack_pointer == #trail then
            self:_log("process: finish writting")
            if current_point.isBezierPoint then
                writeToTrail(false, MeteorNode.TRAIL_TYPE_BEZIER, next_point)
            elseif not next_point.isBezierPoint then
                writeToTrail(true, MeteorNode.TRAIL_TYPE_LINE, current_point)
                writeToTrail(false, MeteorNode.TRAIL_TYPE_LINE, next_point)
            end
        else
            stack_pointer = stack_pointer + 1
            processOnePoint()
        end
    end

    --计算贝塞尔曲线控制点
    local getBezierControlPoint = function()
        for i = 1, #self.running_trail do
            local t = self.running_trail[i]
            if t.type == MeteorNode.TRAIL_TYPE_BEZIER then
                local p1, p2 = CommonAlgorithm.Bezier:getBezierControlPoints(t.p0, t.p3, 0.33, t.p1, 0.67, t.p2)
                self.running_trail[i].p1 = p1
                self.running_trail[i].p2 = p2
            end
        end
    end


    --计算每段运动的距离和总距离
    self.running_length = 0
    local getRunningLength = function()
        for i = 1, #self.running_trail do
            local t = self.running_trail[i]
            local len = 0
            if t.type == MeteorNode.TRAIL_TYPE_LINE then
                len = CommonAlgorithm.Geometry:getPointsDistance(t.start_point, t.end_point)
            elseif t.type == MeteorNode.TRAIL_TYPE_BEZIER then
                len = CommonAlgorithm.Bezier:getArcLength(t.p0, t.p1, t.p2, t.p3, 10)
            end
            self.running_trail[i].length = len
            self.running_length = self.running_length + len
        end
    end

    processOnePoint()   --开始分解轨迹
    getBezierControlPoint() --计算贝塞尔曲线的控制点
    getRunningLength()  --获取每段轨迹的运动长度

    --记录起始点
    local first_trail = self.running_trail[1]
    if first_trail.type == MeteorNode.TRAIL_TYPE_LINE then
        self.properties.position = cc.p(first_trail.start_point.x, first_trail.start_point.y)
    elseif first_trail.type == MeteorNode.TRAIL_TYPE_BEZIER then
        self.properties.position = cc.p(first_trail.p0.x, first_trail.p0.y)
    else
        self.properties.position = cc.p(0,0)
    end
end

--创建子控件
function MeteorNode:_createAllComponents()
    --创建移动的精灵
    if self.components.sprite == nil then
        self.components.sprite = cc.Sprite:create(self.properties.image)
        if self.components.sprite ~= nil then
            self:addChild(self.components.sprite)
            self.components.sprite:setPosition(self.properties.position)
            self:_log("create sprite")
        else
            return false 
        end
    end
    local size = self.components.sprite:getContentSize()

    --创建拖尾
    if self.properties.motion_streak_enabled and self.components.motion_streak == nil then
        self.components.motion_streak = cc.MotionStreak:create(1, 2, size.height, cc.c3b(255, 255, 255), self.properties.image)
        if self.components.motion_streak ~= nil then
            self.components.motion_streak:setFastMode(true)
            self:addChild(self.components.motion_streak)
            self.components.motion_streak:setPosition(self.properties.position)
            self:_log("create motion_streak")
        else
            return false
        end
    end

    --创建粒子
    if self.properties.particle_enabled and self.components.particle == nil then
        self.components.particle = cc.ParticleSystemQuad:create(GameRes.common_widget_meteor_particle)
        if self.components.particle ~= nil then
            self.components.particle:setStartSize(size.height)
            self.components.particle:setTotalParticles(30)
            self:addChild(self.components.particle)
            self.components.particle:setPosition(self.properties.position)
            self:_log("create particle")
        else
            return false
        end
    end
    return true
end

--创建圆周运动action
function MeteorNode:_createActionCircle()
    local angle = self.running_trail.clockwise and -360 or 360
    return MoveCircle:create(self.properties.duration, self.running_trail.center, angle)
end

--创建多边形运动action
function MeteorNode:_createActionPolygon()
    local actions_array = {}
    for i = 1, #self.running_trail do
        local trail = self.running_trail[i]
        local time = trail.length / self.running_length * self.properties.duration
        local action
        if trail.type == MeteorNode.TRAIL_TYPE_LINE then
            action = cc.MoveTo:create(time, trail.end_point)
        elseif trail.type == MeteorNode.TRAIL_TYPE_BEZIER then
            local bezier = {trail.p1, trail.p2, trail.p3}
             action = cc.BezierTo:create(time, bezier)
        end
        if action ~= nil then
            actions_array[#actions_array + 1] = action
        end
    end
    if #actions_array > 0 then
        return cc.Sequence:create(actions_array)
    else
        return nil
    end
end

--打印日志
function MeteorNode:_log(str)
    if self.DEBUG then logd(str, self.TAG) end
end

return MeteorNode