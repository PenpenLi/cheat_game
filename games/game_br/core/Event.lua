
M = {}

M.UPDATE_DELAR_INFO = getUID() --庄列表更新
M.GET_DELAR_INFO_IN_DESK = getUID() --获取庄家信息
M.BR_UNFIRE = getUID()
M.BR_WINMONEY = getUID() --赢钱的动画

M.USER_LEAVE_SEAT_EVENT = getUID() --百人场站起通知
M.BR_NET_INPUT_GAME_EVT = getUID() --百人场进桌通知
M.BR_NET_SIT_DOWN_EVT = getUID() --百人场坐下通知
M.BR_NET_BANKER_CHANGE = getUID() --百人场上庄
M.BR_NET_EXIT_RESPONSE_EVT = getUID() --百人场退卓通知
M.BR_NET_EVENT_BANKER_EXIT = getUID() --百人场下庄通知
M.BR_CLICK_POOL = getUID()--点击了黑红梅方中的一个
M.BR_SEATDOWN_REQ = getUID()--百人场请求坐下
M.BR_DELAR_REQ = getUID()--百人场请求上庄
M.BR_DELAR_EXIT_REQ = getUID()--百人场请求退庄
M.NET_BR_FOLLOW_BET_EVT = getUID() --百人场下注通知
M.BR_NET_OPEN_SHARE_CARDS_EVT = getUID() --百人场发公共牌
M.BR_DELARLIST_SHOW = getUID() --百人场显示上庄列表
M.BR_NET_EVENT_BET_START = getUID() --百人场下注时间
M.BR_NET_EVENT_GAME_OVER = getUID() --百人场结局
M.BR_QUERY_BANKER_LIST_CLICK = getUID() --申请上庄列表
M.BR_QUERY_RECENT_TREND_CLICK = getUID() --百人场历史记录
M.BR_QUERY_RECENT_TREND_UPDATE_DESK = getUID() --牌桌内百人场历史记录更新
M.BR_QUERY_PLAYER_LIST_CLICK = getUID() --百人场旁观玩家
M.BR_NET_EVENT_DESK_CHAT = getUID() --百人场聊天通知
M.BR_EXIT_REQ = getUID()
M.GAME_BR_SHOW_MENU = getUID() -- 弹出百人场菜单
M.GAME_BR_HIDE_MENU = getUID() -- 隐藏百人场菜单
M.GAME_BR_SHOW_HELP = getUID() -- 显示百人帮助面板
M.GAME_BR_EXIT_EVENT = getUID() -- 菜单点击退出按钮
M.GAME_REFRESH_ADDBTN = getUID()
M.BR_SEATUP_REQ = getUID()--百人场请求站起
M.BR_NET_SIT_UP_EVT = getUID() --百人场坐下通知
BR_ET = {} 
BR_ET = M