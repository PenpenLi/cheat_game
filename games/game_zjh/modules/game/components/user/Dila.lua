local Dila = class("Dila",function (paras)
	return paras.node
end)


Dila.Kiss_position = {
	[0] = {
		x = -320,
		y = -330 
	},
	[1] = {
		x = 900,
		y = -400 
	},
	[2] = {
		x = 900,
		y = -100
	},
	[3] = {
		x = -600,
		y = -100,
	},
	[4] = {
		x = -600,
		y = -400,
	},

}

function Dila:ctor()


end

--荷官飞吻
function Dila:kiss(paras)
	local kill_s = cc.Sprite:createWithSpriteFrameName(Zjh_Games_res.KISS)
	self:addChild(kill_s)
	kill_s:setPosition(138,180)
	kill_s:setScale(0.2)
	kill_s:setRotation(10)

	local User  = import("src.modules.game.components.user.User")
	local index = User:getIndex(paras.uin)


	local move  = cc.MoveTo:create(1,cc.p(self.Kiss_position[index].x,self.Kiss_position[index].y))
	local scale = cc.ScaleTo:create(0.7,1)
	local delay = cc.DelayTime:create(0.7)
	local fadeo = cc.FadeOut:create(0.3)
	local del   = cc.CallFunc:create(function ()
		-- body
		self:removeChild(kill_s)
	end)

	local squence = cc.Sequence:create(delay,fadeo,del)
	local spawn   = cc.Spawn:create(move,scale,squence)
	kill_s:runAction(spawn)
end



return Dila