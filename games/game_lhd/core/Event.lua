M = {}

M.LHD_EVENT_RANK_WIN = getUID()
M.LHD_EXIT_REQ 		= getUID() --龙虎斗退桌
M.NET_LHD_INPUT_REQ 	= getUID() --龙虎斗进桌
M.LHD_NET_INPUT_GAME_EVT = getUID() --进桌
M.BR_DELARLIST_SHOW = getUID() --打开上庄列表弹窗
M.BR_QUERY_BANKER_LIST_CLICK = getUID() --请求上庄列表
M.BR_DELAR_REQ = getUID() --请求上庄
M.BR_DELAR_EXIT_REQ = getUID() --请求下庄
M.BR_QUERY_RECENT_TREND_CLICK = getUID() --请求走势信息
M.BR_QUERY_PLAYER_LIST_CLICK = getUID() --请求无座玩家列表
M.NET_FOLLOW_REQ = getUID() --请求下注
M.NET_AUTO_SIT_DOWN_REQ = getUID() --请求坐下
M.NET_AUTO_SIT_UP_REQ = getUID() --请求站起
M.BR_JIFEN_EVT= getUID()--显示积分
M.GAME_LHD_EXIT_EVENT = getUID() --点击退出按钮
M.GAME_SHOW_USER_INFO = getUID() --打开玩家个人信息

M.BR_NET_EVENT_GAME_OVER = getUID() --百人场下注时间
M.BR_NET_EVENT_BET_START = getUID() --百人场结局
M.BR_NET_SIT_DOWN_EVT = getUID() --百人场坐下通知
M.BR_NET_BANKER_CHANGE = getUID() --百人场上庄
M.BR_NET_OPEN_SHARE_CARDS_EVT = getUID() --百人场发公共牌
M.BR_NET_EXIT_RESPONSE_EVT = getUID() --百人场退卓通知
M.BR_NET_EVENT_BANKER_EXIT = getUID() --百人场下庄通知
M.NET_BR_FOLLOW_BET_EVT = getUID() --百人场下注通知
M.EVENT_USER_CHANGE_DECORATION = getUID() --龙虎斗停止下注
M.LHD_EVENT_NO_BET_NTF = getUID() --停止下注阶段
M.BR_NET_SIT_UP_EVT = getUID() --百人场站起通知
M.GAME_REFRESH_ADDBTN = getUID()
M.LHD_EVENT_DESK_CHAT = getUID() --百人场聊天通知
-- M.LHD_WINMONEY = getUID() --赢钱动画

LHD_ET = {} 
LHD_ET = M