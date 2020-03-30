
M = {}
-------------------龙虎斗-------------------------
CMD.LHD_EVENT_ENTER_DESK = 3228          --通知： 进入牌桌

CMD.LHD_USER_ENTER_DESK 	= 3201 --请求进桌
CMD.LHD_GAME_FOLLOW_BET 	= 3202 --下注
CMD.LHD_GAME_EXIT_DESK 		= 3203 --退桌
CMD.LHD_GAME_USER_SIT_DOWN 	= 3204 --坐下
CMD.LHD_USER_BANKER_APPLY 	= 3205 --请求上庄
CMD.LHD_USER_BANKER_EXIT 	= 3206 --下庄
CMD.LHD_QUERY_PLAYER_DESK	= 3207 --查询桌子
CMD.LHD_QUERY_PLAYER_LIST 	= 3208 --请求无座玩家列表
CMD.LHD_QUERY_RECENT_TREND 	= 3209 --请求走势信息
CMD.LHD_QUERY_BANKER_LIST 	= 3219 --请求上庄列表

CMD.LHD_EVENT_EXIT_DESK = 3223           --通知： 离开牌桌
CMD.LHD_EVENT_FOLLOW_BET = 3224          --通知： 下注
CMD.LHD_EVENT_NEW_BANKER = 3225          --通知： 上庄
CMD.LHD_EVENT_USER_SIT_DOWN = 3226       --通知： 用户坐下
CMD.LHD_EVENT_ONE_ROUND_OVER = 3227      --通知： 一轮结束
CMD.LHD_EVENT_OPEN_CARDS = 3229          --通知： 开牌
CMD.LHD_EVENT_BET_START = 3230           --通知： 进入下注时间
CMD.LHD_EVENT_GAME_OVER = 3231           --通知： 游戏结束
CMD.LHD_EVENT_BANKER_WAITING = 3232      --通知： 等待上庄
CMD.LHD_EVENT_BANKER_EXIT = 3233         --通知： 退庄
CMD.LHD_EVENT_UPDATE_TIME = 3236 	     --通知： 更新时间
CMD.LHD_EVENT_NO_BET = 3237				 --通知： 停止下注
CMD.LHD_DAY_WIN_INFO = 3238				 --请求龙虎斗盈利榜
CMD.LHD_GAME_USER_SIT_UP 	= 3240       --站起
CMD.LHD_EVENT_USER_SIT_UP = 3241       --通知： 站起

CMD.LHD_USER_DESK_CHAT = 3222            --请求 牌桌聊天
CMD.LHD_EVENT_DESK_CHAT = 3234           --通知： 牌桌聊天
LHD_CMD = M