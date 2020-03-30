
M = {}

M.USER_LEAVE_SEAT = 3123				
M.CMD_BR_USER_ENTER_DESK_V2 = 3101        -- 用户进入牌桌
M.BR_EVENT_ENTER_DESK = 3015          --# 通知： 进入牌桌        --已加入
M.CMD_BR_GAME_EXIT_DESK_V2 = 3103         -- 离开牌桌
M.BR_EVENT_USER_SIT_DOWN = 3013       --# 通知： 用户坐下        --已加入
M.BR_EVENT_BANKER_CHANGE = 3012       --# 通知： 上庄                  --已加入
M.BR_EVENT_EXIT_DESK = 3010           --# 通知： 离开牌桌        --已加入
M.BR_EVENT_BANKER_EXIT = 3021         --# 通知： 退庄                   --已加入

--------------------- 百人场专用start ----------------------------#
M.BR_EVENT_FOLLOW_BET = 3011          --# 通知： 下注                  --已加入
M.BR_EVENT_OPEN_CARDS = 3016          --# 通知： 开牌                  --已加入
M.BR_EVENT_BET_START = 3017           --# 通知： 进入下注时间--已加入
M.BR_EVENT_GAME_OVER = 3018           --# 通知： 游戏结束         --已加入
M.BR_EVENT_DESK_CHAT = 3023           --# 通知： 牌桌聊天         --已加入 通知牌桌聊天
--------------------- 百人场2专用 begin ---------------------#
M.CMD_BR_GAME_FOLLOW_BET_V2 = 3102        -- 下注
M.CMD_BR_GAME_USER_SIT_DOWN_V2 = 3104     -- 用户坐下
M.CMD_BR_USER_BANKER_APPLY_V2 = 3105      -- 申请上庄
M.CMD_BR_USER_BANKER_EXIT_V2 = 3106       -- 退庄
M.CMD_BR_QUERY_PLAYER_LIST_V2 = 3108      -- 查询玩家列表
M.CMD_BR_QUERY_RECENT_TREND_V2 = 3109     -- 查询走势
M.CMD_BR_QUERY_BANKER_LIST_V2 = 3119      -- 查询庄家列表
M.CMD_BR_USER_DESK_CHAT_V2 = 3122         -- 牌桌聊天 发送聊天请求
M.CMD_BR_GAME_USER_SIT_UP_V2 = 3124		  -- 用户站起
--------------------- 百人场2专用 end -----------------------#
BR_CMD = M