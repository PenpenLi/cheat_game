--[[
    对于ccui.Button的扩展
    扩展1: 按钮的点击事件监听. addButtonEventListener
]]
local CButton = class("CButton", function(node)
    if node ~= nil then
        if "ccui.Button" == tolua.type(node) or "ccui.ImageView" == tolua.type(node) then
            return node
        else
            return nil
        end
    else
        return ccui.Button:create()
    end
end)

--[[
    关于按钮事件的说明:
    CLICK: 单击事件，在按钮抬起时触发
    DOUBLE_CLICK: 双击事件，在按钮双击后抬起时触发
    LONG_PRESS_DOWN: 长按按下事件，在判断长按开始时触发
    LONG_PRESS_UP: 长按抬起事件，在判断长按结束后触发
]]
CButton.EVENT = enum(0,
    "UNKONWN",
    "CLICK", 
    "DOUBLE_CLICK", 
    "LONG_PRESS_DOWN", 
    "LONG_PRESS_UP")

CButton.DOUBLE_CLICK_THRESHOLD = 250    --判断双击事件的阀值, 单位毫秒
CButton.LONG_PRESS_THRESHOLD = 500      --判断长按事件的阀值, 按下LONG_PRESS_THRESHOLD秒视为长按
CButton.TIMER_STEP = 50                 --计时器步长, 是longpress阀值的10%


function CButton:ctor()
    self.down_tick = 0
    self.up_tick = 0
    self.is_pressed = false
    self.is_double_click_down = false
    self.is_long_press_down = false
end

--扩展接口:监听按钮事件. 与addTouchEventListener互斥,会互相覆盖
function CButton:addButtonEventListener(touchEventHandler)
    self._touchEventHandler = touchEventHandler
    self:addTouchEventListener(handler(self, self._touchEventListener))
end

function CButton:_touchEventListener(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self:_clearEvent()  --清除事件记录
        self.down_tick = qf.time.getTime()
        self.is_pressed = true
        self.is_double_click_down = false
        self.is_long_press_down = false
        --判断上次点击抬起的时间. 小于双击阀值, 则认为是开始双击
        if (self.down_tick - self.up_tick) * 1000 <= CButton.DOUBLE_CLICK_THRESHOLD then
            self.is_double_click_down = true
        end
        --开始长按事件计时
        self:_startLongPressTimer()
    elseif eventType == ccui.TouchEventType.ended then
        --停止长按事件计时
        self:_stopLongPressTimer()
        --判断事件类型，单击事件/双击事件/长按抬起
        if self.is_long_press_down then
            self.up_tick = 0    --下一次快速连击不视为double click
            self:_dispatchButtonEvent(CButton.EVENT.LONG_PRESS_UP)
        elseif self.is_double_click_down then
            self.up_tick = 0    --下一次快速连击不视为double click
            self:_dispatchButtonEvent(CButton.EVENT.DOUBLE_CLICK)
        else
            self.up_tick = qf.time.getTime()
            self:_dispatchButtonEvent(CButton.EVENT.CLICK)
        end
        self:_clearEvent()
    elseif eventType == ccui.TouchEventType.canceled then
        self:_stopLongPressTimer()
        self:_clearEvent()
    end
end

--触发按钮事件
function CButton:_dispatchButtonEvent(event)
    if self._touchEventHandler ~= nil then
        self._touchEventHandler(self, event)
    end
end

--清除事件记录
function CButton:_clearEvent()
    self.is_pressed = false
    self.is_double_click_down = false
    self.is_long_press_down = false
end

--开始长按事件监测
function CButton:_startLongPressTimer()
    self:_stopLongPressTimer()
    local count = 0;
    local action = cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(CButton.TIMER_STEP / 1000),
            cc.CallFunc:create(function()
                count = count + 1
                --长按事件开始
                if (count * CButton.TIMER_STEP >= CButton.LONG_PRESS_THRESHOLD) 
                    and (self.is_long_press_down == false)
                    and (self.is_pressed == true) then
                    --触发长按事件
                    self:_dispatchButtonEvent(CButton.EVENT.LONG_PRESS_DOWN)
                    self.is_long_press_down = true
                end
            end)
        )
    )
    self:runAction(action)
end
--停止长按事件监测
function CButton:_stopLongPressTimer()
    self:stopAllActions()
end

return CButton