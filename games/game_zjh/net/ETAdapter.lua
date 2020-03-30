local ETAdapter = class("ETAdapter")
ETAdapter.TAG = "Niuniu-ETAdapter"

function ETAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 GameNet._ada._etable[Niuniu_CMD.INPUT_GAME_EVT] = {Niuniu_ET.A,Niuniu_ET.B}
    -- 
    --


    GameNet._ada._etable[Zjh_CMD.INPUT_GAME_EVT]    =  Zjh_ET.ENTER_ROOM
    GameNet._ada._etable[Zjh_CMD.QUIT]              =  Zjh_ET.QUIT_ROOM
    GameNet._ada._etable[Zjh_CMD.GAME_STAR_EVT]     =  Zjh_ET.GAME_START
    GameNet._ada._etable[Zjh_CMD.USER_FOLD_CARD]    =  Zjh_ET.USER_FOLD
    GameNet._ada._etable[Zjh_CMD.USER_RAISE_CALL]   =  Zjh_ET.USER_RAISE
    GameNet._ada._etable[Zjh_CMD.USER_KAN_PAI]      =  Zjh_ET.USER_CHECK
    GameNet._ada._etable[Zjh_CMD.USER_COMPARE]      =  Zjh_ET.USER_COMPARE
    GameNet._ada._etable[Zjh_CMD.GAME_OVER]         =  Zjh_ET.GAME_END
    GameNet._ada._etable[Zjh_CMD.LIGHT_CARD]        =  Zjh_ET.LIGHT_CARD
    GameNet._ada._etable[Zjh_CMD.FIRE]              =  Zjh_ET.FIRE
    
    GameNet._ada._etable[Zjh_CMD.DASHANG_RSP]       =  Zjh_ET.DASHANG_RSP
    GameNet._ada._etable[Zjh_CMD.NOLIMITCOMPARE]    =  Zjh_ET.USER_COMPARE_ALL
    GameNet._ada._etable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_UP_NTF] = Zjh_ET.STANDUP
    GameNet._ada._etable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_SEAT_NTF] = Zjh_ET.SITDOWN
    GameNet._ada._etable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_LIST_NTF] = Zjh_ET.LOOKUPLIST
    GameNet._ada._etable[Zjh_CMD.AUTO_SIT_WAIT_NUM_NTF] = Zjh_ET.AUTO_SIT_WAIT_NUM_NTF
    
end


return ETAdapter