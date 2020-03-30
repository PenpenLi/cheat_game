
M = {}


M.INPUT_GAME_EVT    = 1700-- 进入（服务端会将当前所有用户的信息推送过来）
M.GAME_STAR_EVT     = 1701-- 游戏开始 发牌
M.USER_FOLD_CARD    = 1711-- 用户弃牌
M.USER_RE_FOLD_CARD = 1710--用户请求弃牌
M.USER_RE_COMPARE   = 1706-- 用户请求比牌
M.USER_COMPARE      = 1707-- 用户比牌
M.USER_RAISE_CALL   = 1705-- 用户跟注call
M.USER_RE_RAISE_CALL= 1704-- 用户请求跟注call
M.USER_KAN_PAI      = 1703-- 用户看牌
M.USER_RE_KAN_PAI   = 1702-- 用户请求看牌
M.GAME_OVER         = 1110-- 游戏结束
M.RE_LIGHT_CARD     = 1712-- 请求亮牌
M.LIGHT_CARD        = 1713-- 亮牌
M.NOLIMITCOMPARE    = 1709--全场比牌
M.GAME_OVER         = 1714-- 游戏结束
M.QUIT              = 1715--退桌
M.QUERY_DESK        = 1034--查询牌桌
M.CALL_ALL          = 1716--跟到底
M.FIRE_RE           = 1719--请求火拼
M.FIRE              = 1720--火拼返回

M.CHANGE_TABLE      = 1456--换桌协议
M.DASHANG           = 1717--打赏荷官请求
M.DASHANG_RSP       = 1718--打赏荷官请求返回
M.RE_XUEPING        = 1719--请求血拼
M.XUEPING           = 1720--血拼结果
M.CMD_EVENT_GOLD_FLOWER_SEAT_REQ = 1722                 --请求：用户请求坐下
M.CMD_EVENT_GOLD_FLOWER_SEAT_NTF = 1723                 --通知：用户请求坐下，失败才会收到
M.CMD_EVENT_GOLD_FLOWER_UP_REQ = 1724					-- 请求：用户请求站起
M.CMD_EVENT_GOLD_FLOWER_UP_NTF = 1725                   --通知：用户请求站起回应
M.CMD_EVENT_GOLD_FLOWER_LIST_REQ = 1726                   --通知：用户请求旁观列表
M.CMD_EVENT_GOLD_FLOWER_LIST_NTF = 1727                   --通知：用户请求旁观列表回应
M.AUTO_SIT_WAIT_NUM_NTF = 1123                   --通知：用户请求旁观列表回应
Zjh_CMD = M