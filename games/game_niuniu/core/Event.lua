M = {}

M.CHAT                          = getUID() --聊天
M.GAME_QUIT_KICK                = getUID() --长时间没操作被踢了
M.SEND_LOGIN_PRO                = getUID() --发送登陆协议
M.RE_QUIT                       = getUID() --请求退出房间
M.ENTERGAMECLICK				= getUID() --直接进入游戏

--看牌抢庄
M.KAN_ENTER_ROOM                = getUID() --看牌抢庄入场
M.KAN_NET_INPUT_REQ             = getUID() --看牌抢庄重连
M.KAN_QUIT                      = getUID() --看牌抢庄退出房间
M.KAN_GAME_START                = getUID() --游戏开始
M.KAN_USER_QIANG                = getUID() --用户抢庄
M.KAN_ZHUANG                    = getUID() --广播庄
M.USER_BASE                     = getUID() --广播下分
M.USER_LAST_CARD                = getUID() --最后一张牌
M.SEND_CARD                     = getUID() --玩家出牌
M.KAN_GAME_OVER                 = getUID() --玩家出牌
M.KAN_UPDATE_USER               = getUID() --更新用户
M.KAN_SELF_QUIT                 = getUID() --tuichu
M.KAN_CALC_NOTICE               = getUID() --tuichu
M.GAME_SHOW_USER_INFO           = getUID() --tuichu

M.CHANGE_TABLE                  = getUID() --换桌
M.CHUOHE_CLOSE                  = getUID() --关闭撮合
M.DESKINFO_CLOSE                = getUID() --关闭撮合

M.NO_GOLD                       = getUID() --金额不足判断弹什么
M.QUICKSTARTCLICK				= getUID() --快速开始

M.SITDOWN                       = getUID() -- 坐下
M.STANDUP                       = getUID() -- 站起

Niuniu_ET = {} 
Niuniu_ET = M