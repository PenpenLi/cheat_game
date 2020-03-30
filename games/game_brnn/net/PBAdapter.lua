local PBAdapter = class("PBAdapter")
PBAdapter.TAG = "Brniuniu-PBAdapter"

function PBAdapter:ctor()

    --百人牛牛3倍场
    GameNet._pbad._rsptable[BRNN_CMD.USER_LEAVE_SEAT] = "BRBullVipStandUpNtf" --用户站起
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_USER_ENTER_DESK_V2] = "GameEnterDeskReq" -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_USER_ENTER_DESK_V2] = "GameEnterDeskRsp" -- new
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_ENTER_DESK] = "EvtDeskUserEnter"
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_EXIT_DESK_V2] = "GameExitDeskReq" -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_GAME_EXIT_DESK_V2] = "GameExitDeskRsp" -- new
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_USER_SIT_DOWN] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_BANKER_CHANGE] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_EXIT_DESK] = "EvtUserExit"
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_BANKER_EXIT] = "EvtDeskUserStandUp"--百人场下庄通知
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_FOLLOW_BET] = "EvtBRBullBetInfo"--百人场下注通知
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_OPEN_CARDS] = "EvtOpenBRBullShareCards"--百人场公共牌
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_BET_START] = "EvtBRBullBetStart"--百人场下注时间
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_GAME_OVER] = "EvtBRBullGameOver"--百人场结局通知
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_USER_SIT_DOWN_V2] = "BRBullGameVIPSitDownReq" -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_GAME_USER_SIT_DOWN_V2] = "BRBullGameVIPSitDownReq" -- new
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_FOLLOW_BET_V2] = "BRBullGameFollowBetReq" -- new
    
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_PLAYER_LIST_V2] = "BRBullReqQueryPlayers" -- 百人场玩家列表 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_PLAYER_LIST_V2] = "BRBullRspAllPlayers" -- 百人场上庄列表 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_BANKER_LIST_V2] = "BRBullRspAllPlayers" -- 百人场上庄列表 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_RECENT_TREND_V2] = "BRBullRspRecentHistory" -- 百人场历史记录 -- new

    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_USER_SIT_UP_V2] = "EvtUserStandUpReq" -- new
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_BULL_QUERY_PLAYER_DESK_V3] = "QueryDeskReq"   -- 后台恢复时请求 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_BULL_QUERY_PLAYER_DESK_V3] = "EvtDeskUserEnter" -- 桌子信息 -- new

    --百人牛牛10倍场
    GameNet._pbad._rsptable[BRNN_CMD.USER_LEAVE_SEAT_V10] = "BRBullVipStandUpNtf" --用户站起
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_USER_ENTER_DESK_V10] = "GameEnterDeskReq" -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_USER_ENTER_DESK_V10] = "GameEnterDeskRsp" -- new
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_ENTER_DESK_V10] = "EvtDeskUserEnter"
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_EXIT_DESK_V10] = "GameExitDeskReq" -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_GAME_EXIT_DESK_V10] = "GameExitDeskRsp" -- new
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_USER_SIT_DOWN_V10] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_BANKER_CHANGE_V10] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_EXIT_DESK_V10] = "EvtUserExit"
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_BANKER_EXIT_V10] = "EvtDeskUserStandUp"--百人场下庄通知
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_FOLLOW_BET_V10] = "EvtBRBullBetInfo"--百人场下注通知
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_OPEN_CARDS_V10] = "EvtOpenBRBullShareCards"--百人场公共牌
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_BET_START_V10] = "EvtBRBullBetStart"--百人场下注时间
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_GAME_OVER_V10] = "EvtBRBullGameOver"--百人场结局通知
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_USER_SIT_DOWN_V10] = "BRBullGameVIPSitDownReq" -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_GAME_USER_SIT_DOWN_V10] = "BRBullGameVIPSitDownReq" -- new
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_FOLLOW_BET_V10] = "BRBullGameFollowBetReq" -- new
    
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_PLAYER_LIST_V10] = "BRBullReqQueryPlayers" -- 百人场玩家列表 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_PLAYER_LIST_V10] = "BRBullRspAllPlayers" -- 百人场上庄列表 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_BANKER_LIST_V10] = "BRBullRspAllPlayers" -- 百人场上庄列表 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_QUERY_RECENT_TREND_V10] = "BRBullRspRecentHistory" -- 百人场历史记录 -- new

    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_GAME_USER_SIT_UP_V10] = "EvtUserStandUpReq" -- new
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_BULL_QUERY_PLAYER_DESK_V10] = "QueryDeskReq"   -- 后台恢复时请求 -- new
    GameNet._pbad._rsptable[BRNN_CMD.CMD_BR_BULL_QUERY_PLAYER_DESK_V10] = "EvtDeskUserEnter" -- 桌子信息 -- new


    --聊天相关
    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_USER_DESK_CHAT_V10] = "DeskChatReq" -- 百人场聊天请求 -- new
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_DESK_CHAT_V10] = "EvtDeskChat" -- 百人场聊天通知

    GameNet._pbad._reqtable[BRNN_CMD.CMD_BR_USER_DESK_CHAT_V3] = "DeskChatReq" -- 百人场聊天请求 -- new
    GameNet._pbad._rsptable[BRNN_CMD.BR_EVENT_DESK_CHAT_V3] = "EvtDeskChat" -- 百人场聊天通知

end


return PBAdapter