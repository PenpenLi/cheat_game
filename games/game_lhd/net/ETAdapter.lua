local ETAdapter = class("ETAdapter")
ETAdapter.TAG = "LHD-ETAdapter"

function ETAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 GameNet._ada._etable[Niuniu_CMD.INPUT_GAME_EVT] = {Niuniu_ET.A,Niuniu_ET.B}
    -- 
    --
    --龙虎斗
    GameNet._ada._etable[CMD.LHD_EVENT_ENTER_DESK] =  LHD_ET.LHD_NET_INPUT_GAME_EVT
    GameNet._ada._etable[CMD.LHD_EVENT_GAME_OVER] = LHD_ET.BR_NET_EVENT_GAME_OVER
    GameNet._ada._etable[CMD.LHD_EVENT_BET_START] =  LHD_ET.BR_NET_EVENT_BET_START--龙虎斗进入下注时间
    GameNet._ada._etable[CMD.LHD_EVENT_NEW_BANKER] =  LHD_ET.BR_NET_BANKER_CHANGE
    GameNet._ada._etable[CMD.LHD_EVENT_OPEN_CARDS] =  LHD_ET.BR_NET_OPEN_SHARE_CARDS_EVT--龙虎斗公共牌
    GameNet._ada._etable[CMD.LHD_EVENT_EXIT_DESK] =  LHD_ET.BR_NET_EXIT_RESPONSE_EVT
    GameNet._ada._etable[CMD.LHD_EVENT_BANKER_EXIT] =  LHD_ET.BR_NET_EVENT_BANKER_EXIT--龙虎斗通知有人下庄
    GameNet._ada._etable[CMD.LHD_EVENT_FOLLOW_BET] = LHD_ET.NET_BR_FOLLOW_BET_EVT
    GameNet._ada._etable[CMD.LHD_EVENT_NO_BET] = LHD_ET.LHD_EVENT_NO_BET_NTF --龙虎斗停止下注阶段通知    
    GameNet._ada._etable[CMD.LHD_EVENT_UPDATE_TIME] =  LHD_ET.LHD_NET_UPDATE_TIME_EVT

    GameNet._ada._etable[CMD.LHD_EVENT_USER_SIT_DOWN] =  LHD_ET.BR_NET_SIT_DOWN_EVT --坐下通知
    GameNet._ada._etable[CMD.LHD_EVENT_USER_SIT_UP] =  LHD_ET.BR_NET_SIT_UP_EVT   --站起通知
    
    GameNet._ada._etable[CMD.LHD_EVENT_DESK_CHAT] =  LHD_ET.LHD_EVENT_DESK_CHAT   --站起通知
end


return ETAdapter