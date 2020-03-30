local Handlebutton = class("Handlebutton",function ( paras )
	return paras.button
end)



function Handlebutton:ctor(paras)

	addButtonEvent(self,function()
		self:setOpacity(500)
		if self.call then
			self.call(self)
		end
		
	end,
	function ()
		self:setOpacity(130)
	end)
	self._value = 0
end

function Handlebutton:setValue(value)
	self._value  = value
end

function Handlebutton:getValue()
	return self._value  
end

--
function Handlebutton:callback(call)
	self.call =call
end







--设置不可按状态
function Handlebutton:setDisable()
	self:setOpacity(130)
	self:setTouchEnabled(false)
end

--设置可按
function Handlebutton:setPressable()
	self:setOpacity(500)
	self:setTouchEnabled(true)
end

return Handlebutton