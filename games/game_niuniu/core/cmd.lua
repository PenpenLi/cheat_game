
M = {}


--看牌抢庄--
M.KAN_INPUT_GAME_EVT= 1600--看牌抢庄进入
M.KAN_GAME_STAR_EVT = 1601--看牌抢庄游戏开始

M.USER_RE_QIANG     = 1610--玩家请求抢庄
M.USER_QIANG        = 1611--广播玩家抢庄
M.ZHUANG            = 1612--广播谁是庄
M.USER_RE_BASE      = 1621--玩家请求下分倍数
M.USER_BASE         = 1622--广播下分倍数
M.USER_LAST_CARD    = 1623--通知：玩家最后一张牌
M.USER_REQ_SEND_CARD= 1641--玩家请求出牌
M.SEND_CARD         = 1642--广播玩家出牌

M.KAN_GAME_OVER     = 1650--游戏结束
M.KAN_QUIT          = 1651--退出游戏广播
M.KAN_SELF_QUIT     = 1652--游戏中玩家退出（系统代打）
M.KAN_QUERY_DESK    = 1033--查询牌桌 

M.CHANGE_TABLE      = 1456--换桌协议

M.CMD_EVENT_BULL_FRIGHT_CLASSIC_SEAT_REQ = 1654 --请求：用户请求坐下
M.CMD_EVENT_BULL_FRIGHT_CLASSIC_SEAT_NTF = 1655 --通知：用户请求坐下，失败才会收到
M.CMD_EVENT_BULL_FRIGHT_CLASSIC_UP_REQ = 1656 --请求：用户请求站起
M.CMD_EVENT_BULL_FRIGHT_CLASSIC_UP_NTF = 1657 -- 通知：用户请求站起回应

Niuniu_CMD = M