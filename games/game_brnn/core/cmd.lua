
M = {}

M.USER_LEAVE_SEAT = 3323				
M.CMD_BR_USER_ENTER_DESK_V2 = 3301        -- 用户进入牌桌
M.BR_EVENT_ENTER_DESK = 3315          --# 通知： 进入牌桌        --已加入
M.CMD_BR_GAME_EXIT_DESK_V2 = 3303         -- 离开牌桌
M.BR_EVENT_USER_SIT_DOWN = 3313       --# 通知： 用户坐下        --已加入
M.BR_EVENT_BANKER_CHANGE = 3312       --# 通知： 上庄                  --已加入
M.BR_EVENT_EXIT_DESK = 3310           --# 通知： 离开牌桌        --已加入
M.BR_EVENT_BANKER_EXIT = 3321         --# 通知： 退庄                   --已加入

--------------------- 百人场专用start ----------------------------#
M.BR_EVENT_FOLLOW_BET = 3311          --# 通知： 下注                  --已加入
M.BR_EVENT_OPEN_CARDS = 3316          --# 通知： 开牌                  --已加入
M.BR_EVENT_BET_START = 3317           --# 通知： 进入下注时间--已加入
M.BR_EVENT_GAME_OVER = 3318           --# 通知： 游戏结束         --已加入
M.BR_EVENT_DESK_CHAT_V3= 3325           --# 通知： 牌桌聊天         --已加入

--------------------- 百人场2专用 begin ---------------------#
M.CMD_BR_GAME_FOLLOW_BET_V2 = 3302        -- 下注
M.CMD_BR_GAME_USER_SIT_DOWN_V2 = 3304     -- 用户坐下
M.CMD_BR_USER_BANKER_APPLY_V2 = 3305      -- 申请上庄
M.CMD_BR_USER_BANKER_EXIT_V2 = 3306       -- 退庄
M.CMD_BR_QUERY_PLAYER_LIST_V2 = 3308      -- 查询玩家列表
M.CMD_BR_QUERY_RECENT_TREND_V2 = 3309     -- 查询走势
M.CMD_BR_QUERY_BANKER_LIST_V2 = 3319      -- 查询庄家列表
M.CMD_BR_GAME_USER_SIT_UP_V2 = 3324		  -- 用户站起
M.CMD_BR_USER_DESK_CHAT_V3  = 3322        -- 聊天请求
--------------------- 百人场2专用 end -----------------------#

M.CMD_BR_BULL_QUERY_PLAYER_DESK_V3 = 3307 --查询桌子

--------------------- 百人场 10倍场 begin ---------------------#
M.USER_LEAVE_SEAT_V10 = 3423				
M.CMD_BR_USER_ENTER_DESK_V10 = 3401        -- 用户进入牌桌
M.BR_EVENT_ENTER_DESK_V10 = 3415           --# 通知： 进入牌桌
M.CMD_BR_GAME_EXIT_DESK_V10 = 3403         -- 离开牌桌
M.BR_EVENT_USER_SIT_DOWN_V10 = 3413       --# 通知： 用户坐下
M.BR_EVENT_BANKER_CHANGE_V10 = 3412       --# 通知： 上庄 
M.BR_EVENT_EXIT_DESK_V10 = 3410           --# 通知： 离开牌桌
M.BR_EVENT_BANKER_EXIT_V10 = 3421         --# 通知： 退庄 

M.BR_EVENT_FOLLOW_BET_V10 = 3411          --# 通知： 下注
M.BR_EVENT_OPEN_CARDS_V10 = 3416          --# 通知： 开牌 
M.BR_EVENT_BET_START_V10 = 3417           --# 通知： 进入下注时间
M.BR_EVENT_GAME_OVER_V10 = 3418           --# 通知： 游戏结束
M.BR_EVENT_DESK_CHAT_V10 = 3425           --通知： 牌桌聊天

M.CMD_BR_GAME_FOLLOW_BET_V10 = 3402        -- 下注
M.CMD_BR_GAME_USER_SIT_DOWN_V10 = 3404     -- 用户坐下
M.CMD_BR_USER_BANKER_APPLY_V10 = 3405      -- 申请上庄
M.CMD_BR_USER_BANKER_EXIT_V10 = 3406       -- 退庄
M.CMD_BR_QUERY_PLAYER_LIST_V10 = 3408      -- 查询玩家列表3
M.CMD_BR_QUERY_RECENT_TREND_V10 = 3409     -- 查询走势
M.CMD_BR_QUERY_BANKER_LIST_V10 = 3419      -- 查询庄家列表
M.CMD_BR_BULL_QUERY_PLAYER_DESK_V10 = 3407 -- 查询桌子
M.CMD_BR_GAME_USER_SIT_UP_V10 = 3424	   -- 用户站起
M.CMD_BR_USER_DESK_CHAT_V10 = 3422         -- 牌桌聊天请求
--------------------- 百人场 10倍场 end -----------------------#
BRNN_CMD = M