local PBAdapter = class("PBAdapter")
PBAdapter.TAG = "Niuniu-PBAdapter"

function PBAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 GameNet._ada._etable[Niuniu_CMD.INPUT_GAME_EVT] = {Niuniu_ET.A,Niuniu_ET.B}
    -- 
    --

    GameNet._pbad._rsptable[Zjh_CMD.INPUT_GAME_EVT] = "EvtGoldFlowerDeskUserEnter"
    GameNet._pbad._rsptable[Zjh_CMD.QUIT]           = "EvtUserExit"
    GameNet._pbad._rsptable[Zjh_CMD.GAME_STAR_EVT]  = "EvtGoldFlowerameStart"

    GameNet._pbad._reqtable[Zjh_CMD.USER_RE_FOLD_CARD] ="GoldFlowerUserFoldReq" --用户请求弃牌
    GameNet._pbad._rsptable[Zjh_CMD.USER_FOLD_CARD]  = "GoldFlowerUserFlodNtf"

    GameNet._pbad._reqtable[Zjh_CMD.USER_RE_RAISE_CALL] ="GoldFlowerUserChipReq" --用户请求加注
    GameNet._pbad._rsptable[Zjh_CMD.USER_RAISE_CALL]  = "GoldFlowerUserChipNtf"

    GameNet._pbad._reqtable[Zjh_CMD.USER_RE_KAN_PAI] ="GoldFlowerUserLookCardReq" --用户请求看牌
    GameNet._pbad._rsptable[Zjh_CMD.USER_KAN_PAI]  = "GoldFlowerUserLookCardNtf"

    GameNet._pbad._reqtable[Zjh_CMD.USER_RE_COMPARE]  = "GoldFlowerUserCompareReq"--比牌
    GameNet._pbad._rsptable[Zjh_CMD.USER_COMPARE]  = "GoldFlowerUserCompareNtf"
    GameNet._pbad._rsptable[Zjh_CMD.NOLIMITCOMPARE] = "GoldFlowerRoundOverCompareCard" --全场比牌


    GameNet._pbad._rsptable[Zjh_CMD.GAME_OVER]  = "GoldFlowerGameOver"
    GameNet._pbad._reqtable[Zjh_CMD.CALL_ALL]              = "GoldFlowerUserChipsAll" --请求跟到底
    GameNet._pbad._rsptable[Zjh_CMD.CALL_ALL]              = "BullFrightWinnerOpenCardReq" --请求跟到底返回

    GameNet._pbad._reqtable[Zjh_CMD.RE_LIGHT_CARD]              = "GoldFlowerWinnerOpenCardReq" --请求亮牌
    GameNet._pbad._rsptable[Zjh_CMD.LIGHT_CARD]              = "GoldFlowerWinnerOpenCardNtf" --请求亮牌返回

    GameNet._pbad._reqtable[Zjh_CMD.FIRE_RE]              = "GoldFolwerRushQeq" --请求火拼
    GameNet._pbad._rsptable[Zjh_CMD.FIRE]              = "GoldFolwerRushNtf" --火拼返回
    
    GameNet._pbad._reqtable[Zjh_CMD.DASHANG]                  = "GoldFlowerRewardDealerReq" --打赏
    GameNet._pbad._rsptable[Zjh_CMD.DASHANG_RSP]              = "GoldFlowerRewardDealerNtf" --打赏返回
    GameNet._pbad._reqtable[Zjh_CMD.CHANGE_TABLE]             = "BullFrightUserChangeDeskReq" --换桌
    GameNet._pbad._rsptable[Zjh_CMD.CHANGE_TABLE]             = "CheckBeautyStatusReq" --换桌返回
    GameNet._pbad._reqtable[Zjh_CMD.QUERY_DESK]             = "QueryDeskReq" --玩家请求抢庄
    GameNet._pbad._rsptable[Zjh_CMD.QUERY_DESK]             = "EvtGoldFlowerDeskUserEnter" --广播玩家抢庄
    GameNet._pbad._reqtable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_UP_REQ]             = "GoldFlowerUserUpReq" --站起
    GameNet._pbad._rsptable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_UP_NTF]             = "GoldFlowerUserUpNtf" --站起
    GameNet._pbad._reqtable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_SEAT_REQ]             = "GoldFlowerUserSeatReq" --坐下
    GameNet._pbad._rsptable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_SEAT_NTF]             = "GoldFlowerUserSeatNtf" --坐下
    GameNet._pbad._reqtable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_LIST_REQ]             = "GoldFlowerViewListReq" --旁观列表
    GameNet._pbad._rsptable[Zjh_CMD.CMD_EVENT_GOLD_FLOWER_LIST_NTF]             = "GoldFlowerViewListNtf" --旁观列表
    GameNet._pbad._rsptable[Zjh_CMD.AUTO_SIT_WAIT_NUM_NTF]             = "AutoSitWaitNumNtf" --自动坐下
end


return PBAdapter