local ETAdapter = class("ETAdapter")
ETAdapter.TAG = "Br-ETAdapter"

function ETAdapter:ctor()
    GameNet._ada._etable[BR_CMD.CMD_BR_QUERY_BANKER_LIST_V2]    =  BR_ET.UPDATE_DELAR_INFO
    GameNet._ada._etable[BR_CMD.USER_LEAVE_SEAT]    =  BR_ET.USER_LEAVE_SEAT_EVENT
    GameNet._ada._etable[BR_CMD.BR_EVENT_ENTER_DESK] =  BR_ET.BR_NET_INPUT_GAME_EVT
    GameNet._ada._etable[BR_CMD.BR_EVENT_USER_SIT_DOWN] =  BR_ET.BR_NET_SIT_DOWN_EVT
    GameNet._ada._etable[BR_CMD.BR_EVENT_BANKER_CHANGE] =  BR_ET.BR_NET_BANKER_CHANGE
    GameNet._ada._etable[BR_CMD.BR_EVENT_EXIT_DESK] =  BR_ET.BR_NET_EXIT_RESPONSE_EVT
    GameNet._ada._etable[BR_CMD.BR_EVENT_BANKER_EXIT] =  BR_ET.BR_NET_EVENT_BANKER_EXIT--百人场通知有人下庄
    GameNet._ada._etable[BR_CMD.BR_EVENT_DESK_CHAT] =  BR_ET.BR_NET_EVENT_DESK_CHAT
    GameNet._ada._etable[BR_CMD.BR_EVENT_FOLLOW_BET] = BR_ET.NET_BR_FOLLOW_BET_EVT
    GameNet._ada._etable[BR_CMD.BR_EVENT_OPEN_CARDS] =  BR_ET.BR_NET_OPEN_SHARE_CARDS_EVT--百人场公共牌
    GameNet._ada._etable[BR_CMD.BR_EVENT_BET_START] =  BR_ET.BR_NET_EVENT_BET_START--百人场进入下注时间
    GameNet._ada._etable[BR_CMD.BR_EVENT_GAME_OVER] = BR_ET.BR_NET_EVENT_GAME_OVER
end


return ETAdapter