--牌桌动画
local GameAnimationConfig = import("src.games.game_zjh.modules.game.components.animation.AnimationConfig")
local User                = import("src.games.game_zjh.modules.game.components.user.User")
local _GameAniClass = require("src.common.Gameanimation")
local Gameanimation       = class("Gameanimation", _GameAniClass)
Gameanimation.Mine_icon_tag = 33

local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()

local radio = winSize.height/winSize.width
GAME_RADIO = radio
if radio > 0.5625 then 
    FORCE_ADJUST_GAME = true
end

GAME_SCALE = 0.5625/GAME_RADIO



Gameanimation.Mount = {
	[1] = 1,
	[2] = 4,
	[3] = 1
}


--winmoney 位置
Gameanimation.Winmoney = {
	[0] = {
		res = GameAnimationConfig.WINMONEYMYSELF,
		position = {
			x = Display.cx/2,
			y = Display.cy/2-5
		}
	},
	[1] = {
		res = GameAnimationConfig.WINMONEY,
		position = {
			x = Display.cx-140*GAME_SCALE,
			y = Display.cy-630*GAME_SCALE
		}
	},
	[2] = {
		res = GameAnimationConfig.WINMONEY,
		position = {
			x = Display.cx-140*GAME_SCALE,
			y = Display.cy-322*GAME_SCALE
		}
	},
	[3] = {
		res = GameAnimationConfig.WINMONEY,
		position = {
			x = 140*GAME_SCALE,
 			y = Display.cy-322*GAME_SCALE
		}
	},
	[4] = {
		res = GameAnimationConfig.WINMONEY,
		position = {
			x =  140*GAME_SCALE,
			y = Display.cy-630*GAME_SCALE
		}
	},

}



function  Gameanimation:getSide()
	local win_index  = User:getIndex(Cache.zjhdesk.win_uin)

	local lost_index = User:getIndex(Cache.zjhdesk.lost_uin)
	local side       = lost_index<win_index and 1 or 0
	if lost_index == 0 then
		side = win_index/2 > 1 and 1 or 0
	elseif win_index == 0 then
		side = lost_index/2 > 1 and 0 or 1
	end

	return side
end


--播放赢钱动画
function Gameanimation:playWinmoney(paras)
	local index    = User:getIndex(paras.uin)
	local bg       = self._parent_view._users[paras.uin]

	local px       = -14
	local py       = -16
	if paras.uin == Cache.user.uin then
		px = 20
		py = -15
	end

	local pos    = cc.p(px,py)
	local anchor = cc.p(0,0)

	self:play({anim=self.Winmoney[index].res,position=pos ,forever=1,anchor=anchor,node=self._parent_view._users[paras.uin]})
end

return Gameanimation