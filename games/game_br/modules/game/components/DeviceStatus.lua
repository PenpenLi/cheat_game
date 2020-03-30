local DeviceStatus = class("DeviceStatus",function (paras)
    return paras.layer
end)

function DeviceStatus:ctor(paras)
	self._device_layer = paras.layer
end

--开始检测设备状态(电池电量, 系统时间)
function DeviceStatus:startDeviceStatusMonitor()
	if self._device_layer == nil then return end

	self._device_layer:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.CallFunc:create(function()
				--获取电池电量
				local voltage = qf.platform:getBatteryLevel()
				--获取系统时间
                local time = os.time()
				--刷新显示
				self:refreshDeviceInfo(voltage, time)
			end),
			cc.DelayTime:create(5)
		)
	))
end

--[[
	刷新设备状况
	battery_level, 电池电量. (0 - 100); 
	time, 系统时间
]]
function DeviceStatus:refreshDeviceInfo(battery_level, time)

	--检测设备信息是否有变化
	local redraw = false
    local clock_str = Util:getDigitalTime(time)
    if self.clock_str == nil or self.clock_str ~= clock_str then
        redraw = true
    elseif self.battery_level == nil or self.battery_level ~= battery_level then
        redraw = false
    end
    
    --缓存设备信息
    self.clock_str = clock_str
    self.battery_level = battery_level

    --重绘
	if redraw then
	    self:drawDeviceInfo(battery_level, clock_str)
    end
end

--[[
	绘制设备状况
	battery_level, 电池电量. (0 - 100); 
	clock_str, 时间显示
]]
function DeviceStatus:drawDeviceInfo(battery_level, clock_str)
	--得到设备信息层
	if self._device_layer == nil then return end
	local layer_size = self._device_layer:getContentSize()
    local x = 20
    local y = layer_size.height / 2
	self._device_layer:removeAllChildren(true)

	--电池电量
	local battery = cc.Sprite:create()
	if battery_level > 10 then  --10%以下显示低电
		battery:setTexture(GameRes.device_battery_frame)
		local voltage = cc.Sprite:create(GameRes.device_battery_level)
		voltage:setScaleX(battery_level / 100)
		voltage:setAnchorPoint(1, 0)
		voltage:setPosition(battery:getContentSize().width - 3, 3)
		battery:addChild(voltage)
	else
		battery:setTexture(GameRes.device_battery_low_power)	--低电
	end
	local battery_size = battery:getContentSize()
	self._device_layer:addChild(battery, 1)
	battery:setAnchorPoint(0, 0.5)
	battery:setPosition(x, y)
    local battery_width = battery:getContentSize().width

    --系统时间
    local clock = cc.LabelTTF:create(clock_str, GameRes.font1, 30)
    clock:setAnchorPoint(0, 0.5)
    clock:setPosition(x + battery_width + 20, y)
    self._device_layer:addChild(clock)
    
end

return DeviceStatus