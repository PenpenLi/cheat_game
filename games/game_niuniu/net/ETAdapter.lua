local ETAdapter = class("ETAdapter")
ETAdapter.TAG = "Niuniu-ETAdapter"

function ETAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 GameNet._ada._etable[Niuniu_CMD.INPUT_GAME_EVT] = {Niuniu_ET.A,Niuniu_ET.B}

    GameNet._ada._etable[Niuniu_CMD.KAN_INPUT_GAME_EVT] =  Niuniu_ET.KAN_ENTER_ROOM
    GameNet._ada._etable[Niuniu_CMD.KAN_QUIT]           =  Niuniu_ET.KAN_QUIT
    GameNet._ada._etable[Niuniu_CMD.KAN_GAME_STAR_EVT]  =  Niuniu_ET.KAN_GAME_START
    GameNet._ada._etable[Niuniu_CMD.USER_QIANG]         =  Niuniu_ET.KAN_USER_QIANG
    GameNet._ada._etable[Niuniu_CMD.ZHUANG]             =  Niuniu_ET.KAN_ZHUANG
    GameNet._ada._etable[Niuniu_CMD.USER_BASE]          =  Niuniu_ET.USER_BASE
    GameNet._ada._etable[Niuniu_CMD.USER_LAST_CARD]     =  Niuniu_ET.USER_LAST_CARD
    GameNet._ada._etable[Niuniu_CMD.SEND_CARD]          =  Niuniu_ET.SEND_CARD
    GameNet._ada._etable[Niuniu_CMD.KAN_GAME_OVER]      =  Niuniu_ET.KAN_GAME_OVER
    GameNet._ada._etable[Niuniu_CMD.KAN_SELF_QUIT]      =  Niuniu_ET.KAN_SELF_QUIT

    GameNet._ada._etable[Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_UP_NTF]     =  Niuniu_ET.STANDUP--站起 通知
    GameNet._ada._etable[Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_SEAT_NTF]   =  Niuniu_ET.SITDOWN --坐下 通知
end


return ETAdapter