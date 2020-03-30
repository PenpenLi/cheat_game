local PBAdapter = class("PBAdapter")
PBAdapter.TAG = "Br-PBAdapter"

function PBAdapter:ctor()

    GameNet._pbad._rsptable[BR_CMD.USER_LEAVE_SEAT] = "VipStandUpNtf" --用户站起
    GameNet._pbad._reqtable[BR_CMD.CMD_BR_USER_ENTER_DESK_V2] = "GameEnterDeskReq" -- new
    GameNet._pbad._rsptable[BR_CMD.CMD_BR_USER_ENTER_DESK_V2] = "GameEnterDeskRsp" -- new
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_ENTER_DESK] = "EvtDeskUserEnter"
    GameNet._pbad._reqtable[BR_CMD.CMD_BR_GAME_EXIT_DESK_V2] = "GameExitDeskReq" -- new
    GameNet._pbad._rsptable[BR_CMD.CMD_BR_GAME_EXIT_DESK_V2] = "GameExitDeskRsp" -- new
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_USER_SIT_DOWN] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_BANKER_CHANGE] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_EXIT_DESK] = "EvtUserExit"
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_BANKER_EXIT] = "EvtDeskUserStandUp"--百人场下庄通知
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_DESK_CHAT] = "EvtDeskChat" -- 百人场聊天通知
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_FOLLOW_BET] = "EvtBRBetInfo"--百人场下注通知
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_OPEN_CARDS] = "EvtOpenBRShareCards"--百人场公共牌
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_BET_START] = "EvtBetStart"--百人场下注时间
    GameNet._pbad._rsptable[BR_CMD.BR_EVENT_GAME_OVER] = "EvtBRGameOver"--百人场结局通知
    GameNet._pbad._reqtable[BR_CMD.CMD_BR_GAME_USER_SIT_DOWN_V2] = "BRGameVIPSitDownReq" -- new
    GameNet._pbad._rsptable[BR_CMD.CMD_BR_GAME_USER_SIT_DOWN_V2] = "GameUserAutoSitDownRsp" -- new
    GameNet._pbad._reqtable[BR_CMD.CMD_BR_GAME_FOLLOW_BET_V2] = "BRGameFollowBetReq" -- new
    
    GameNet._pbad._rsptable[BR_CMD.CMD_BR_QUERY_PLAYER_LIST_V2] = "RspAllPlayers" -- 百人场玩家列表 -- new
    GameNet._pbad._rsptable[BR_CMD.CMD_BR_QUERY_BANKER_LIST_V2] = "RspAllPlayers" -- 百人场上庄列表 -- new
    GameNet._pbad._rsptable[BR_CMD.CMD_BR_QUERY_RECENT_TREND_V2] = "RspRecentHistory" -- 百人场历史记录 -- new
    GameNet._pbad._reqtable[BR_CMD.CMD_BR_USER_DESK_CHAT_V2] = "DeskChatReq" -- 百人场聊天请求 -- new

    GameNet._pbad._reqtable[BR_CMD.CMD_BR_GAME_USER_SIT_UP_V2] = "EvtUserStandUpReq" -- new
end


return PBAdapter