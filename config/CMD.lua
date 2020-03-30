
CMD = {}      
--游戏内逻辑 start
CMD.INPUT = 1010--进入
CMD.INPUT_GAME_EVT = 1020-- 进入（服务端会将当前所有用户的信息推送过来）
CMD.EXIT = 1030-- 退出
CMD.QUERY_DESK_ON_SHOW = 1031

CMD.QQ_REG = 15 -- qq登陆
--CMD.FACEBOOK_REG = 16 -- facebook
CMD.WX_REG = 17 -- 微信登陆

--游戏内逻辑 end
--应用逻辑协议 start--
CMD.REG = 2
CMD.LOGIN = 3 --用户登录
CMD.PHONE_LOGIN_PIN = 5  --手机号验证码验证注册/登录
CMD.PHONE_LOGIN_PWD = 6  --手机号密码验证注册/登录
CMD.HEARTBEAT = 7--心跳
CMD.CHANGEGOLD_EVT = 9
CMD.RECEIVE_GIFT_EVT = 10
CMD.LOGOUT = 11 --注销
CMD.PHONE_RESET_PWD = 16  --重置手机密码
CMD.PHONE_SET_PWD = 18  --设置手机密码
CMD.PHONE_FIND_PWD = 21  --找回手机密码
CMD.CONFIG = 31 --获取config配置信息
CMD.ZERO_CONFIG = 32 --获取0点config配置信息
CMD.USER_MODIFY = 35
CMD.TASKLIST = 38
CMD.TASKREWARD = 39
CMD.RECENTBEAUTY = 50--美女认证
CMD.WORLD_WEEK_RECORD_RANK = 51
CMD.FRIEND_WEEK_RECORD_RANK = 52
CMD.WORLD_DAY_WIN_RANK = 55
CMD.FRIEND_DAY_WIN_RANK = 56
CMD.WORLD_GOLD_RANK = 57
CMD.FRIEND_GOLD_RANK = 58
CMD.COLLAPSE_PAY = 60--破产补助
CMD.GET_COLLAPSE_PAY = 61--破产补助领钱
CMD.SEX_STATUS = 1764--美女状态
--应用逻辑协议 end--
   
CMD.CHAT = 145
CMD.CHAT_NOTICE_EVT = 146
CMD.BROADCAST_OTHER_EVT = 148 -- 
CMD.BAROADCAST_DIM_EVT = 149--服务器所有下发金币的通知
CMD.FRIENDS_LIST = 154
CMD.LAST_WEEK_RANKING = 155
CMD.THIS_WEEK_RANKING = 156
CMD.SEND_GIFT = 158
CMD.ADD_FRIEND= 159
CMD.USER_INFO= 160
CMD.BEAUTY_DALIY_REWARD = 161--获取美女日常奖励
CMD.BEAUTY_WEEKLY_REWARD = 162
CMD.ALL_ACTIVITY = 163
CMD.GIFT_CONF = 164     --查询礼物配置
CMD.USER_SEND_GIFT_TO_ALL = 165 --送礼物给全桌人
CMD.USER_CHANGE_DECORATION = 166  -- 更换头饰
CMD.EVENT_USER_CHANGE_DECORATION = 167  --同桌 更换头饰通知
CMD.GAME_TYPE_LIST = 243            --场次类型
CMD.GAME_RECORD = 244               --牌局记录
CMD.PAY_RECORD = 245               --充值记录
CMD.CHANGE_LOGIN_PWD = 246         --修改登录密码
CMD.GET_BINDING_CONFIG = 247      --获取个人提现配置（包括可用银行，支付宝）
CMD.BIND_CARD = 248               --绑定/解绑卡片（银行卡、支付宝）
CMD.GET_EXCHANGE_CONFIG = 249      --获取提现配置（包括可用银行，最小限额等）
CMD.REQ_EXCHANGE = 251             --申请提现
CMD.INVITE_CODE = 603             --邀请码

CMD.PLAY_GOOGLEPLAY_FIAL = 180
CMD.UPDATA_GOLD_EVT = 190
CMD.EVENT_OTHER_GOLD_CHANGE = 194       -- 牌桌内其他用户金币变化
CMD.LOGIN_NOTICE_EVT = 195 --弹出公告通知
CMD.RECEIVE_GOLD_EVT = 202--活动跟新金币
CMD.GET_FINISH_ACTIVITY_NUM_EVT = 203 --获取已完成活动的个数
CMD.EVENT_SCORE_CHANGED = 303  -- 通知： 积分变化

CMD.DESK_TASK_EVT = 5001  --通知： 牌局内任务列表
CMD.APPLY_REWARD_CODE = 5010 -- 请求奖励码 奖励
CMD.GENERAL_NOTICE = 5030 --服务器通用通知

CMD.CMD_GET_LUCKY_WHEEL_REWARD = 68   -- 抽取幸运转盘奖励
CMD.CMD_GET_CUMULATE_LOGIN_REWARD = 69   --累计登陆

CMD.NEW_GONGGAO = 700		--新公告
CMD.GET_ONLINE_NUMBER = 701		--获取线上人数


CMD.GET_MAIL_INFO = 702		--获取邮箱信息
CMD.DEL_MAIL 	  = 703		--删除邮件
CMD.READ_MAIL 	  = 704		--读取邮件

CMD.ASK_QES = 255		--客服咨询
CMD.QES_REQ = 256		--咨询列表详情

CMD.RET_MONEY = 705 --周福利查询
CMD.RET_EXCHANGE = 706 --周福利领取

CMD.REQ_BUY_MAMMON = 260 --购买财神爷请求
CMD.RSP_BUY_MAMMON = 261 --购买财神爷返回

CMD.REQ_MAMMON_INFO = 262 --查询财神爷信息请求
CMD.RSP_MAMMON_INFO = 263 --查询财神爷信息返回

CMD.REQ_MAMMON_RECORD = 264 --查询财神爷购买记录请求
CMD.RSP_MAMMON_RECORD = 265 --查询财神爷购买记录返回

CMD.BIND_AGENCY = 707 --绑定代理
CMD.GET_AGENCY_INFO = 708 --获取代理信息

CMD.GET_DESK_LIST_INFO  = 70 --获取牌桌列表

--------------------- 金花场专用 ----------------------------#
CMD.EVENT_USER_CHIPS_CHANGE = 191       --# 用户筹码变化
CMD.EVENT_USER_DAOJU_CHANGE = 192       --# 用户道具变化


--------------------- 百人场专用end ----------------------------#

CMD.CMD_BR_QUERY_PLAYER_DESK_V2 = 3107      -- 查询桌子

--------------------- 签到转盘cmd -----------------------------#

CMD.CMD_GET_DAOJU_LIST = 204  --获取道具列表

CMD.EVENT_LOGIN_REWARD_GET = 65  -- 每日登录奖励领取
CMD.CMD_EXCHANGE_FEE_TICKET_TO_CASH  = 301   -- 兑换话费券为话费
CMD.CMD_QUERY_FEE_TICKET = 302   -- 查询话费券
CMD.WEEK_MONTH_CARD_NOTICE  = 1765        -- 周卡月卡通知

CMD.PHONE_NUM_BINDING  = 196        -- 手机号码绑定

--------------------- 免费金币 -----------------------------#
CMD.CMD_COMMON_REWARD_NOTIFY = 5500  --# 通用小红点通知
CMD.CMD_QUERY_SCHED_REWARD = 5501  --# 查询定时奖励
CMD.CMD_PICK_SCHED_REWARD = 5502  --# 领取定时奖励
CMD.CMD_QUERY_BILLBOARD = 5503   --# 公告
CMD.CMD_QUERY_DAILY_REWARD = 5504   --# 查询每日奖励
CMD.CMD_QUERY_BROKE_SUPPLY = 5505 --# 破产补助查询

--------------------- 好友新功能start ----------------------------#

CMD.FRIENDS_APPLY = 400 --发起好友添加
CMD.FRIEND_REPLY_APPLY = 401 --答复好友添加
CMD.FRIEND_DELETE = 402 --删除好友
CMD.FRIENDS_FIND = 403 --通过uin 查找指定的好友
CMD.FRIEND_ONLINE = 404 --查询在线的好友
CMD.FRIEND_INVITE = 405 --邀请好友一起玩游戏
CMD.FRIEND_RECV_INVITE = 406 --收到好友邀请一起玩游戏
CMD.FRIEND_REFUSE_INVITE = 407 --拒绝好友邀请的游戏
CMD.FRIEND_RECV_REFUSE_INVITE = 408 --邀请好友玩游戏被好友拒绝
CMD.FRIEND_REMOVE_RED_POINT = 409 --删除小红点

----------------------- 好友新功能end ----------------------------#
CMD.SCORE_CLIENT_SHARE = 5031 --积分兑换礼品通知
CMD.INVITE_CODE_BE_EXCHANGED = 210 --兑换代码被用户兑换了


CMD.GET_SHOP_MAI_1_SONG_1_LIST = 67  -- 获取商城买就送匹配列表
CMD.CHIPS_EXCHANGE_CFG = 141         -- 房间兑换筹码配置
CMD.GET_DAY_LOGIN_REWARD_CFG = 172  -- 拉取每日登录奖励配置

CMD.RECEIVE_CHALLENGE_NOTICE_EVT = 5015 --接收到对方发起的挑战通知



--------------------- 付费表情start-----------------------------#
CMD.STORE_BUYING_USING_GOLD = 220          --打赏荷官


--------------------- 好友新功能end ----------------------------#
CMD.CMD_EVENT_USER_LOGIN_ELSEWHERE = 10200 -- 在其他设备上登录，确认登录

CMD.USER_GIFT_RECORD = 168
--------------------- 礼物end ----------------------------#


----------------------私人定制-----------------------------#
CMD.PRIVATE_DESK_SETTLE = 500              -- 私有房间牌局总结
CMD.VIP_HIDING_REQ = 505	--VIP隐身请求
CMD.PROFILE_CHANGE = 506	--修改隐身状态广播
CMD.HEAD_UPLOAD_SUCCESS = 507	--头像上传成功

--------------新美女start-------------------------------------
CMD.GET_BEAUTY_PHOTO_LIST = 206
CMD.REMOVE_BEAUTY_PHOTO = 207
CMD.GET_LAST_WEEK_RANK_REWARD_CONF = 208
----------------------新美女end---------------------------------
CMD.DESK_ASK_FEIEND = 410--桌内加好友提示
CMD.DESK_ASK_FRIENDTIPS = 413--桌内加好友反馈

CMD.QUERY_JACKPOT_RECORD = 231  --查询jackpot中奖纪录

CMD.ALTERNICKREMARK=412


CMD.QUERY_GAMES_RECORD_LIST = 5506
CMD.QUERY_GAMES_RECORD_DETAILS = 5507


-------------------举报--------------------------
CMD.USER_REPORT = 5510              				--用户举报

-----------------保险箱--------------------------
CMD.SAFE_DEPOSIT = 5511                 -- 保险箱存钱
CMD.SAFE_WITHDRAW = 5512                -- 保险箱取钱
CMD.SAFE_CHANGE_PASSWORD = 5513         -- 保险箱修改密码
CMD.SAFE_QUERY_MONEY = 5514             -- 查询保险箱
------------------------------------------------


--------------------- 选场大厅--------------------
CMD.SUCCESS_WORLD_RANKING =  1300 --比赛积分胜分榜-世界排行
CMD.SUCCESS_FRIEND_RANKING = 1302 --比赛积分胜分榜-好友排行
CMD.SUCCESS_WORLD_WEEK_RANKING = 1303 --周比赛积分胜分榜-世界排行
CMD.SUCCESS_FRIEND_WEEK_RANKING = 1304 --周比赛积分胜分榜-好友排行

-----------------------商城(钻石/金币)--------------------
CMD.USER_DIAMOND_CHANGED = 193          --用户的钻石信息变更
CMD.PRODUCT_EXCHANGE_BY_DIAMOND = 221   --用钻石兑换金币/道具
CMD.PUSH_USER_ACTION_STATS = 320        --用户行为上报


CMD.MTT_QUERY_PLAYER_DESK_REQ= 6013 --后台切入前台查询牌桌
CMD.MTT_FLOAT_REWARD_PUSH_NTF = 6033 --浮动奖励发放通知

CMD.USE_ANTI_STEALTH_CARD = 601        --使用破隐卡

CMD.CMD_INTERACT_PHIZ = 175 -- #互动表情
CMD.CMD_INTERACT_PHIZ_NTF = 176 -- #互动表情


-----------------用户游戏数据-------------------
CMD.GET_USER_GAME_INFO = 232

-----------------用户引导-------------------
CMD.CLOSE_GUIDE_VIEW = 604

-----------------客服聊天-------------------
CMD.QUERY_CHAT_INFO = 712

-----------------红包相关-------------------
CMD.QUERY_FIRST_RECHARGE = 714 -- #查询首充红包信息
CMD.GET_FIRST_RECHARGE = 715 -- #获取首充红包

-----------------延迟相关-------------------
CMD.TEST_CONNECTION = 27 -- #查询首充红包信息

-----------------快速开始游戏-------------------
CMD.GLOBAL_QUICK_START_GAME = 716

-----------------代理客服信息-------------------
CMD.GET_PROXCY_SERVICE_INFO = 718

-----------------代理头像框购买信息--------------
CMD.BUY_HEAD_MASK = 266
CMD.GET_HEAD_MASK_CONFIG = 267
CMD.USER_CHOOSE_HAED_MASK = 268

----------------查询用户购买appstore首冲情况--------------
CMD.QUERY_USER_APPSTORE_FIRST = 719