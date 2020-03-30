M = {}



M = {}


M.USER_ENTER_ROOM               = getUID() --用户进入房间
M.ENTER_ROOM                    = getUID() --进入房间
M.QUIT_ROOM                     = getUID() --退出房间
M.GAME_START                    = getUID() --牌局开始
M.PLAYER_SEND_CARD              = getUID() --玩家发牌
M.PLAYER_DIU_CHIP               = getUID() --玩家丢筹码
M.PLAYER_SHOW_ROUND_CHIPS       = getUID() --显示玩家下注数量
M.DESK_SHOW_INFO                = getUID() --显示桌子的信息
M.USER_HANDLE_TURN              = getUID() --到了用户操作
M.USER_HANDLED                  = getUID() --用户具体的动作
M.USER_CHECK                    = getUID() --用户看牌
M.USER_RAISE                    = getUID() --用户加注
M.USER_CALL                     = getUID() --用户跟注
M.USER_FOLD                     = getUID() --用户弃牌
M.USER_COMPARE                  = getUID() --用户比牌
M.HIDE_ZHEZHAO                  = getUID() --隐藏遮罩层
M.GAME_END                      = getUID() --游戏结算
M.LIGHT_CARD                    = getUID() --亮牌
M.LOGIN_REQUEST_LAST_SERVER     = getUID() --链接服务器socket
M.LOGINING                      = getUID() --正在登陆
M.USER_COMPARE_ALL              = getUID() --全场比牌
M.CHAT                          = getUID() --聊天
M.GAME_QUIT_KICK                = getUID() --长时间没操作被踢了
M.SEND_LOGIN_PRO                = getUID() --发送登陆协议
M.TIME_CLEAR_DESK               = getUID() --取消定时去清理桌面的
M.RE_QUIT                       = getUID() --请求退出房间
M.REWARD                        = getUID() --任务奖励请求返回
M.REWARDPOP                     = getUID() --任务奖励弹窗
M.REQ_REWARD_LIST               = getUID() --请求任务列表
M.TEST                          = getUID() --请求任务列表
M.GET_CONFIG                    = getUID() --获取配置
M.DAILY_REWARD_CONF             = getUID() --每日登陆奖励信息
M.PERSONAL_POP                  = getUID() --个人信息
M.NET_INPUT_REQ                 = getUID() --重连游戏
M.DASHANG_RSP                   = getUID() --打赏
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


M.NO_GOLD                       = getUID() --金币不足判断弹什么
M.FIRE                          = getUID() --火拼
M.UNFIRE						= getUID() --取消火

M.USER_HANDLE_TURN_NOTIMER      = getUID() --取消火

M.RECONNECT_FIRE                = getUID() --取消火

M.BEAUTYNPCSPEAK                = getUID() --美女进入
M.QUICKSTARTCLICK				= getUID()--快速开始
M.STANDUP                       = getUID()--站起
M.SITDOWN                       = getUID()--坐下
M.LOOKUPLIST					= getUID()--旁观列表
M.CHATPOINT						= getUID()--聊天红点
M.AUTO_SIT_WAIT_NUM_NTF         = getUID()--自动坐下
M.GAME_Standup					= getUID()--点击站起

M.SEND_GIFT_LEAD       			= getUID()--送礼回调
M.KICK_ADJUST					= getUID()
Zjh_ET = {} 
Zjh_ET = M