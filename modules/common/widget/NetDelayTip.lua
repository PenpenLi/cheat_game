local NetDelayTip = class("NetDelayTip",function ()
    return cc.Node:create()
end)

local unit = "ms"
function NetDelayTip:ctor(paras)	
	local text =  ccui.Text:create("", GameRes.font1, 30)
	text:setAnchorPoint(cc.p(0, 0.5))
	text:setPosition(30, -5)
	self:addChild(text)
	self._text = text

	local signalImg = ccui.ImageView:create(GameRes.signal1)
	self:addChild(signalImg)
	signalImg:setPosition(3, -3)
	self._signalImg = signalImg

	local wifiImg = ccui.ImageView:create(GameRes.wifi1)
	self:addChild(wifiImg)
	wifiImg:setPosition(3, -3)
	wifiImg:setScale(1.1)
	self._wifiImg = wifiImg

	self:setWifiVisible(false)
	self:setSignalVisible(false)
	if paras and paras.showcolor then
		self.showcolor = paras.showcolor
	end

	local lastShowDelayTime = NetDelayTool:getLastShowDelayTime()
	local lastNetInfo = NetDelayTool:getLastNetInfo()
	if lastShowDelayTime or lastNetInfo then
		self:refresh({delayTime = lastShowDelayTime, netInfo = lastNetInfo})
	end
	self:startDeviceStatusMonitor()
end

function NetDelayTip:setWifiVisible(bVis)
	self._wifiImg:setVisible(bVis)
end

function NetDelayTip:setSignalVisible(bVis)
	self._signalImg:setVisible(bVis)
end

function NetDelayTip:refresh(paras)
	-- dump(paras)
	if paras == nil then
		return
	end
	
	if paras.delayTime then
		self:setTextString(paras.delayTime .. unit)
		self:setTextColor(paras.delayTime)
	end
	if paras.netInfo then
		self:refreshNetInfo(paras.netInfo)
	end
end

function NetDelayTip:setTextString(txt)
	if txt then
		self._text:setString(txt)
	end
end

function NetDelayTip:getTextColor(delayTime)
	if delayTime <= 60 then
		return cc.c3b(169, 208, 142)
	elseif delayTime <= 120 then
		return cc.c3b(255, 217, 102)
	else
		if self.showcolor then
			return  self.showcolor 
		end
		return cc.c3b(229, 27, 27)
	end
end

function NetDelayTip:setTextColor(delayTime)
	local color = self:getTextColor(delayTime)
	self._text:setColor(color)
end

function NetDelayTip:getWifiIcon(wifiLevel)
	if (5 >= wifiLevel) and (wifiLevel >= 4) then
		return GameRes.wifi1
	elseif (3>= wifiLevel) and (wifiLevel >= 2) then
		return GameRes.wifi2
	else
		return GameRes.wifi3
	end
end

function NetDelayTip:getSignalIcon(dbm)
	if (dbm >= -95) then
		return GameRes.signal1
	elseif (dbm >= -105) then
		return GameRes.signal2
	elseif (dbm >= -115) then
		return GameRes.signal3
	else
		return GameRes.signal4
	end
end

function NetDelayTip:getNormalSignalIcon(level)
	return GameRes["signal" .. level]
end

function NetDelayTip:getNormalWifiIcon(level)
	return GameRes["wifi" .. level]
end

function NetDelayTip:refreshNetInfo(netInfo)
	if netInfo == nil then
		return
	end

	self:setWifiVisible(false)
	self:setSignalVisible(false)
	if netInfo.bWifiConnected then
		self:setWifiVisible(true)
		if netInfo.wifiLevel then
			local wifiRes = self:getWifiIcon(checknumber(netInfo.wifiLevel))
			self._wifiImg:loadTexture(wifiRes)
		end
		if netInfo.signalStrength then
			local wifiRes = self:getNormalWifiIcon(checknumber(netInfo.signalStrength))
			self._wifiImg:loadTexture(wifiRes)
		end
	elseif netInfo.bNetConnected then
		self:setSignalVisible(true)
		if netInfo.dbm then
			local wifiRes = self:getSignalIcon(checknumber(netInfo.dbm))
			self._wifiImg:loadTexture(wifiRes)
		end
		if netInfo.signalStrength then
			local wifiRes = self:getNormalSignalIcon(checknumber(netInfo.signalStrength))
			self._wifiImg:loadTexture(wifiRes)
		end
	end
end

function NetDelayTip:startDeviceStatusMonitor( ... )
	-- body
	self:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.CallFunc:create(function()
				--获取电池电量
				local voltage = qf.platform:getBatteryLevel()
				--获取系统时间
                local time = os.time()
				--刷新显示
				self:refreshDeviceInfo(voltage, time)
				self:refreshIOSDeviceInfo()
			end),
			cc.DelayTime:create(5)
		)
	))
end

function NetDelayTip:isIOSPlatform( ... )
	local device = cc.Application:getInstance():getTargetPlatform()
	if device == cc.PLATFORM_OS_IPHONE or device == cc.PLATFORM_OS_IPAD then
		return true
	end
	return false
end

function NetDelayTip:refreshIOSDeviceInfo( ... )
	if self:isIOSPlatform() then
		local info = qf.platform:getNetTypeAndSignalLevel()
		-- dump(info)
		local netInfo = {
			bWifiConnected = info.wifiConnect == 1,
			bNetConnected = info.WWANConnect == 1,
			signalStrength = info.signalStrength
		}
		self:refreshNetInfo(netInfo)
	end
end

--[[
	刷新设备状况
	battery_level, 电池电量. (0 - 100); 
	time, 系统时间
]]
function NetDelayTip:refreshDeviceInfo(battery_level, time)

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
	-- print("refreshDeviceInfo redraw >>>>", battery_level, clock_str)
end

--[[
	绘制设备状况
	battery_level, 电池电量. (0 - 100); 
	clock_str, 时间显示
]]
function NetDelayTip:drawDeviceInfo(battery_level, clock_str)
	--得到设备信息层
	if self.batteryImg and tolua.isnull(self.batteryImg) == false then
		self.batteryImg:removeFromParent()
		self.batteryImg = nil
	end

	if self.clockImg and tolua.isnull(self.clockImg) == false then
		self.clockImg:removeFromParent()
		self.clockImg = nil
	end

	--电池电量
	local battery = cc.Sprite:create()
	if battery_level > 10 then  --10%以下显示低电
		battery:setTexture(GameRes.device_battery_frame)
		local voltage = cc.Sprite:create(GameRes.device_battery_level)
		voltage:setScaleX(battery_level / 100)
		voltage:setAnchorPoint(1, 0)
		voltage:setPosition(battery:getContentSize().width - 3, 3)
		voltage:setColor(cc.c3b(119, 187, 86))
		battery:addChild(voltage)
	else
		battery:setTexture(GameRes.device_battery_low_power)	--低电
	end
	
	local battery_size = battery:getContentSize()
	self:addChild(battery, 1)
	battery:setAnchorPoint(0, 0.5)
	battery:setColor(cc.c3b(119, 187, 86))
	battery:setPosition(-20, -40)
	self.batteryImg = battery

    --系统时间
    local clock = cc.LabelTTF:create(clock_str, GameRes.font1, 30)
    clock:setAnchorPoint(0, 0.5)
    clock:setPosition(30, -40)
	clock:setColor(cc.c3b(119, 187, 86))
	self:addChild(clock)
	self.clockImg = clock
end

return NetDelayTip