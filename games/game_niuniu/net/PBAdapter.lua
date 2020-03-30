local PBAdapter = class("PBAdapter")
PBAdapter.TAG = "Niuniu-PBAdapter"

function PBAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 GameNet._ada._etable[Niuniu_CMD.INPUT_GAME_EVT] = {Niuniu_ET.A,Niuniu_ET.B}

    GameNet._pbad._rsptable[Niuniu_CMD.KAN_INPUT_GAME_EVT]        = "EvtBullFrightClassicDeskUserEnter" --看牌抢庄进入
    GameNet._pbad._rsptable[Niuniu_CMD.KAN_GAME_STAR_EVT]         = "EvtBullFrightClassicGameStart" --看牌抢庄游戏开始
    GameNet._pbad._reqtable[Niuniu_CMD.USER_RE_QIANG]             = "UserGrabBankReq" --玩家请求抢庄
    GameNet._pbad._rsptable[Niuniu_CMD.USER_QIANG]                = "UserGrabBankNtf" --广播玩家抢庄
    GameNet._pbad._rsptable[Niuniu_CMD.ZHUANG]                    = "EvtBullFrightClassicBankNtf" --广播：谁是本轮的庄
    GameNet._pbad._reqtable[Niuniu_CMD.USER_RE_BASE]              = "UserCallTimesReq" --玩家请求倍数
    GameNet._pbad._rsptable[Niuniu_CMD.USER_BASE]                 = "UserCallTimesNtf" --广播：玩家请求倍数
    GameNet._pbad._rsptable[Niuniu_CMD.USER_LAST_CARD]            = "EvtBullFrightClassicLastCard" --通知：玩家最后一张牌
    GameNet._pbad._reqtable[Niuniu_CMD.USER_REQ_SEND_CARD]        = "UserOutCardReq" --玩家请求出牌
    GameNet._pbad._rsptable[Niuniu_CMD.SEND_CARD]                 = "UserOutCardNtf" --广播玩家出牌
    GameNet._pbad._rsptable[Niuniu_CMD.KAN_GAME_OVER]             = "BullFrightClassicGameOver" --游戏结束
    GameNet._pbad._rsptable[Niuniu_CMD.KAN_QUIT]                  = "EvtUserExit" --退出游戏
    GameNet._pbad._rsptable[Niuniu_CMD.KAN_SELF_QUIT]             = "MTTEnterDeskRsp" --退出游戏

    GameNet._pbad._reqtable[Niuniu_CMD.KAN_QUERY_DESK]             = "QueryDeskReq" --查询桌子 切换后台重连使用
    GameNet._pbad._rsptable[Niuniu_CMD.KAN_QUERY_DESK]             = "EvtBullFrightClassicDeskUserEnter" -- 切换后台返回的对应的rsp

    GameNet._pbad._reqtable[Niuniu_CMD.CHANGE_TABLE]             = "BullFrightUserChangeDeskReq" --换桌
    GameNet._pbad._rsptable[Niuniu_CMD.CHANGE_TABLE]             = "CheckBeautyStatusReq" --换桌返回

    GameNet._pbad._reqtable[Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_UP_REQ]             = "GoldFlowerUserUpReq" --站起
    GameNet._pbad._rsptable[Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_UP_NTF]             = "GoldFlowerUserUpNtf" --站起
    GameNet._pbad._reqtable[Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_SEAT_REQ]             = "GoldFlowerUserSeatReq" --坐下
    GameNet._pbad._rsptable[Niuniu_CMD.CMD_EVENT_BULL_FRIGHT_CLASSIC_SEAT_NTF]             = "GoldFlowerUserSeatNtf" --坐下
end


return PBAdapter