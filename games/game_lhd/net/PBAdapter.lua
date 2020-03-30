local PBAdapter = class("PBAdapter")
PBAdapter.TAG = "Niuniu-PBAdapter"

function PBAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 GameNet._ada._etable[Niuniu_CMD.INPUT_GAME_EVT] = {Niuniu_ET.A,Niuniu_ET.B}
    -- 
    --
     ---------龙虎斗---------
    GameNet._pbad._reqtable[CMD.LHD_USER_ENTER_DESK] = "GameEnterDeskReq" -- new
    GameNet._pbad._rsptable[CMD.LHD_USER_ENTER_DESK] = "GameEnterDeskRsp" -- new
    
    GameNet._pbad._reqtable[CMD.LHD_GAME_USER_SIT_DOWN] = "LHDGameVIPSitDownReq"
    GameNet._pbad._rsptable[CMD.LHD_GAME_USER_SIT_DOWN] = "GameUserAutoSitDownRsp"

    GameNet._pbad._reqtable[CMD.LHD_GAME_FOLLOW_BET] = "LHDGameFollowBetReq"
    GameNet._pbad._rsptable[CMD.LHD_EVENT_BET_START] = "EvtLHDBetStart"--龙虎斗下注时间
    GameNet._pbad._rsptable[CMD.LHD_EVENT_FOLLOW_BET] = "EvtLHDBetInfo"--龙虎斗下注通知
    GameNet._pbad._rsptable[CMD.LHD_EVENT_GAME_OVER] = "EvtLHDGameOver"--龙虎斗结局通知
    GameNet._pbad._rsptable[CMD.LHD_QUERY_PLAYER_LIST] = "LHDAllPlayersRsp"
    GameNet._pbad._rsptable[CMD.LHD_QUERY_BANKER_LIST] = "LHDAllPlayersRsp"
    GameNet._pbad._rsptable[CMD.LHD_EVENT_OPEN_CARDS] = "EvtOpenLHDShareCards"
    GameNet._pbad._rsptable[CMD.LHD_QUERY_RECENT_TREND] = "LHDRecentHistoryRsp" -- 龙虎斗历史记录
    GameNet._pbad._reqtable[CMD.LHD_DAY_WIN_INFO] = "LHDWinRankInfoReq" -- 请求龙虎斗盈利榜
    GameNet._pbad._rsptable[CMD.LHD_DAY_WIN_INFO] = "LHDWinRankInfoRsp" -- 返回龙虎斗盈利榜

    GameNet._pbad._reqtable[CMD.LHD_GAME_EXIT_DESK] = "GameExitDeskReq" -- new
    GameNet._pbad._rsptable[CMD.LHD_GAME_EXIT_DESK] = "GameExitDeskRsp" -- new
    GameNet._pbad._reqtable[CMD.LHD_QUERY_PLAYER_DESK] = "QueryDeskReq"   -- 后台恢复时请求
    GameNet._pbad._rsptable[CMD.LHD_QUERY_PLAYER_DESK] = "EvtDeskUserEnter" -- 桌子信息
    GameNet._pbad._rsptable[CMD.LHD_EVENT_ENTER_DESK] = "EvtDeskUserEnter"
    GameNet._pbad._rsptable[CMD.LHD_EVENT_EXIT_DESK] = "EvtUserExit"
    GameNet._pbad._rsptable[CMD.LHD_EVENT_NEW_BANKER] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[CMD.LHD_EVENT_USER_SIT_DOWN] = "EvtDeskUserSitDown"
    GameNet._pbad._rsptable[CMD.LHD_EVENT_BANKER_EXIT] = "EvtDeskUserStandUp"--龙虎斗下庄通知
    GameNet._pbad._rsptable[CMD.LHD_EVENT_UPDATE_TIME] = "EvtLHDBankerSitDown" --龙虎斗更新时间

    GameNet._pbad._reqtable[CMD.LHD_GAME_USER_SIT_UP] = "EvtUserStandUpReq" --龙虎斗站起请求
    GameNet._pbad._rsptable[CMD.LHD_EVENT_USER_SIT_UP] = "EvtUserStandUpNtf" --龙虎斗站起通知

    GameNet._pbad._reqtable[CMD.LHD_USER_DESK_CHAT] = "DeskChatReq" --龙虎斗站起请求
    GameNet._pbad._rsptable[CMD.LHD_EVENT_DESK_CHAT] = "EvtDeskChat" --龙虎斗站起通知
end


return PBAdapter