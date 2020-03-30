--牌桌动画
local GameAnimationConfig = import("src.games.game_brnn.modules.game.components.animation.AnimationConfig")
local _GameAniClass = require("src.common.Gameanimation")
local Gameanimation       = class("Gameanimation", _GameAniClass)

local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()

local radio = winSize.height/winSize.width
GAME_RADIO = radio
if radio > 0.5625 then 
    FORCE_ADJUST_GAME = true
end

GAME_SCALE = 0.5625/GAME_RADIO

--winmoney 位置
Gameanimation.Winmoney = {
	[0] = { --自己
		res = GameAnimationConfig.WINMONEYMYSELF,
		position = {
			x = 0,
			y = -30
		},
		scale ={
			x = 1.2,
			y = 1.05
		}
	},
	[1] = { --座位上的人
		res = GameAnimationConfig.WINMONEY,
		position = {
			x = -15,
			y = -10
		},
		scale = {
			x = 0.9,
			y = 0.8
		}
	},
	[2] = { --庄家
		res = GameAnimationConfig.WINMONEY,
		position = {
			x = 403,
			y = 55
		},
		scale = {
			x = 0.9,
			y = 0.8
		}
	},
}

--播放赢钱动画
function Gameanimation:playWinmoney(paras)

	local idx = paras.idx -- 0 自己 1 座位上的人 2表示庄家
	local uin = paras.uin
	local node = paras.node
	local pos = paras.pos or self.Winmoney[idx].position
	local scale =  paras.scale or self.Winmoney[idx].scale
	local anchor = cc.p(0,0)
		if (node.uin ~= Cache.user.uin) and ((not node.isSeat) or (node.uin ~= uin)) then	
		return
	end
	self:play({anim=self.Winmoney[idx].res,position=pos ,forever=1,anchor=anchor,node=node, scale = scale})
end


return Gameanimation