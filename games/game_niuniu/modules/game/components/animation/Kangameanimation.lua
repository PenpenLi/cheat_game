local _GameAniClass = require("src.common.Gameanimation")

local Gameanimation       = class("Gameanimation", _GameAniClass)

local GameAnimationConfig = import("src.games.game_niuniu.modules.game.components.animation.KananimationConfig")

Gameanimation.Mount = {
	[1] = 3,
	[3] = 2
}

function Gameanimation:ctor ( paras )
	self.super.ctor(self, paras)
	-- self:init()
end

--播放动画
function Gameanimation:play(paras)
	-- body
	local face = self.super.play(self, paras)
	if FULLSCREENADAPTIVE and (paras.anim == GameAnimationConfig.START or paras.anim == GameAnimationConfig.WIN or paras.anim == GameAnimationConfig.LOST) then 
		loga("变换位置")
		local winSize = cc.Director:getInstance():getWinSize()
		face:setPositionX(face:getPositionX()-winSize.width/2+1920/2)
	end

	return face
end

--加载plist
function Gameanimation:init(ptype,cb, config)
	self.loaded = 0
	for k,v in pairs(GameAnimationConfig) do
		if v.preload == ptype then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(v.res,function ( ... )
				self.loaded = self.loaded + 1
				if self.Mount[ptype] then
					if self.loaded >= self.Mount[ptype] then
						if cb then cb() end
					end
					
				end
			end)
		end
	end	
end

return Gameanimation