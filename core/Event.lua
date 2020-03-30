--[[
    global  event
]]

-- event table
-- global obj

 

ET = {}


-- game Module

ET.NET_GAME_PAYATTENTIONTO_REQ = getUID()
ET.NET_GAME_CANCER_PAYATTENTION_REQ = getUID()
ET.NET_USER_MODIFY_REQ = getUID()
ET.NET_USER_TASKLIST_REQ = getUID()
ET.NET_USER_TASKREWARD_REQ = getUID()
ET.NET_USER_RECENTBEAUTY_REQ = getUID()
ET.NET_WORLD_WEEK_RECORD_RANK_REQ = getUID()
ET.NET_FRIEND_WEEK_RECORD_RANK_REQ = getUID()
ET.NET_WORLD_DAY_WIN_RANK_REQ = getUID()
ET.NET_FRIEND_DAY_WIN_RANK_REQ = getUID()
ET.NET_WORLD_GOLD_RANK_REQ = getUID()
ET.NET_FRIEND_GOLD_RANK_REQ = getUID()
ET.NET_COLLAPSE_PAY_REQ = getUID()
ET.NET_GET_COLLAPSE_PAY_REQ = getUID()
ET.NET_SEX_STATUS_REQ = getUID()
ET.NET_APPLY_REWARD_CODE_REQ = getUID()
ET.NET_FRIENDS_LIST_REQ = getUID()
ET.NET_LAST_WEEK_RANKING_REQ = getUID()
ET.NET_THIS_WEEK_RANKING_REQ = getUID()
ET.NET_SEND_GIFT_REQ = getUID()
ET.NET_ADD_FRIEND_REQ = getUID()
ET.NET_USER_INFO_REQ = getUID()
ET.NET_BEAUTY_DALIY_REWARD_REQ = getUID()
ET.NET_BEAUTY_WEEKLY_REWARD_REQ = getUID()
ET.NET_ALL_ACTIVITY_REQ = getUID()
ET.NET_GET_FINISH_ACTIVITY_EVT = getUID()

ET.NET_CHANGEGOLD_EVT = getUID()
ET.NET_RECEIVE_GIFT_EVT = getUID()
ET.NET_DESK_TASK_EVT = getUID()
ET.NET_DESK_TASK_REQ= getUID()	--拉取牌桌内任务列表
ET.NET_BROADCAST_OTHER_EVT = getUID()
ET.NET_BAROADCAST_DIM_EVT= getUID()--短信充值成功后台回返接口
ET.NET_UPDATA_GOLD_EVT = getUID()
ET.NET_EVENT_OTHER_GOLD_CHANGE = getUID()
ET.NET_LOGIN_NOTICE_EVT = getUID()
ET.NET_RECEIVE_GOLD_EVT = getUID()
--- 选场大厅
ET.UPDATE_CHOSEHALL_HEADIMG = getUID()   --更新选场大厅的头像
--应用逻辑协议 end--


--game proto start--
--[[进入房间]]
ET.NET_INPUT_REQ = getUID() 
ET.NET_BR_INPUT_REQ = getUID() 
ET.NET_BJL_INPUT_REQ = getUID()
ET.NET_SNG_INPUT_REQ = getUID()
--[[进入游戏后 服务端 推送过来游戏内的 详细信息]]
ET.NET_INPUT_GAME_EVT = getUID() 
--[[退出游戏的协议]]
ET.NET_EXIT_REQ = getUID() 
--[[换桌请求]]
ET.NET_CHANGE_DESK_REQ = getUID()

ET.NET_CHAT_REQ = getUID() 
ET.NET_CHAT_NOTICE_EVT = getUID() 


ET.NET_GETCONFIG_DONE = getUID()
ET.NET_AUTO_INPUT_ROOM = getUID()

--other proto end--
ET.GAME_CHANGE_BUTTON_STATUS = getUID()  -- 游戏中改变自己的按钮
ET.GAME_SHOW_USER_INFO = getUID()
ET.GAME_SHOW_CHAT = getUID()
ET.GAME_HIDE_CHAT = getUID()
ET.GAME_SHOW_SHOP = getUID()
ET.GAME_HIDE_SHOP = getUID()
ET.GAME_SHOW_SHOP_PROMIT = getUID()
ET.GAME_PAY_NOTICE = getUID()
ET.NOTIFY_REFRESH_DESK = getUID()
ET.NOTIFY_REFESH_HEADIMG = getUID()

ET.LOGIN_REQUEST_LAST_SERVER = getUID()

ET.GLOBAL_WAIT_NETREQ = getUID()

ET.MAIN_BUTTON_CLICK = getUID()
ET.MAIN_MOUDLE_VIEW_EXIT = getUID()
ET.GLOBAL_GET_USER_INFO = getUID()
ET.GLOBAL_SHOW_USER_INFO = getUID()


ET.GLOBAL_BROADCAST_TXT = getUID()
ET.GLOBAL_SHOW_BROADCASE_TXT = getUID()
ET.GLOBAL_COIN_ANIMATION_SHOW = getUID()
ET.GLOBAL_COIN_CHARGE_ANIMATION_SHOW = getUID()
ET.GLOBAL_DIAMOND_ANIMATION_SHOW = getUID()
ET.GLOBAL_SHOW_BROADCASE_LAYOUT = getUID()
ET.GLOBAL_HIDE_BROADCASE_LAYOUT = getUID()

ET.GLOBAL_FRESH_MAIN_GOLD = getUID()--刷新主界面
ET.GLOBAL_FRESH_LOBBIES_GOLD = getUID()--刷新大厅
ET.GLOBAL_FRESH_CUSTOMIZE_GOLD = getUID() --刷新私人定制大厅
ET.GLOBAL_TOAST = getUID()--吐司

ET.GLOBAL_WAIT_EVENT = getUID() --全屏等待
ET.LOGIN_WAIT_EVENT = getUID()
ET.GLOBAL_HANDLE_BANKRUPTCY = getUID()--弹出破产提示
ET.GLOBAL_HANDLE_WINNINGSTREAK = getUID()--弹出连赢提示
ET.GLOBAL_HANDLE_PROMIT = getUID() -- 公共框消息处理

ET.MAIN_UPDATE_BNT_NUMBER = getUID()

ET.MAIN_UPDATE_USER_HEAD = getUID()
ET.CHANGE_VIEW_UPDATE_USER_HEAD = getUID()
ET.APPLICATION_ACTIONS_EVENT = getUID()


ET.SHOW_LOGIN = getUID()

ET.MODULE_SHOW = getUID()
ET.MODULE_HIDE = getUID()

ET.REFRESH_FRIEND_LISTVIEW = getUID()

ET.CHANGE_BORADCAST_DELAYTIME = getUID()
ET.REFRESH_SHOP_GOLD = getUID()
ET.REFRESH_GAME_SHOP_GOLD = getUID() --更新游戏内商城金币
ET.GAME_GENERAL_NOTICE = getUID()--通用服务器通知
ET.GAME_WANT_RECHARGE = getUID()--服务器通知关闭webview然后去商城
ET.MAIN_VIEW_DISMISS_ANIMATION = getUID()--主界面模块消失
ET.MAIN_VIEW_SHOW_ANIMATION = getUID()--主界面出现
ET.PRELOAD_JSON_END = getUID()--预加载结束
ET.EVENT_USER_CHIPS_CHANGE = getUID() --单独通知筹码变化



ET.GLOBAL_SHOW_NEWBILLING = getUID() --显示最新计费界面
ET.LOBBY_LIST_MOVE = getUID()--大厅控制滑动

ET.GET_DAOJU_LIST = getUID() -- 获取道具列表
ET.EVENT_USER_DAOJU_CHANGE = getUID() -- 道具发货通知
ET.GLOBAL_CANCELLATION = getUID()--注销功能
ET.GLOBAL_CANCELLATION_BY_REQ = getUID --需要注销请求
ET.GAME_USER_RETURN_INDEX = getUID() --点击坐下的时候返回index


ET.EVENT_LOGIN_REWARD_GET = getUID() --每日登录奖励领取

ET.EVENT_EXCHANGE_FEE_TICKET_TO_CASH  = getUID()      --兑换话费券为话费
ET.EVENT_QUERY_FEE_TICKET = getUID()                  --查询话费券

ET.EVENT_SCORE_CHANGED = getUID() --服务器通知积分变化

ET.LOGIN_SIGN_IN = getUID() --登录
ET.LOGIN_NET_GOTO_LOGIN = getUID()

ET.BR_JIFEN_EVT = getUID() --百人场积分通知

--关于时间宝箱的计时器控制、状态读取、消息通知等，全部通过以下三个事件, 不直接读Cache
ET.GLOBAL_TIMEBOX_SET = getUID()	--时间宝箱控制(开始或继续计时/暂停计时/计时器重置)
ET.GLOBAL_TIMEBOX_GET = getUID()	--时间宝箱获取(当前任务信息, 计时器时间)


ET.WEEK_MONTH_CARD_NOTICE = getUID() -- 周卡月卡通知
ET.WEEK_MONTH_GOTO_SHOP_DAOJU = getUID() -- 周卡月卡通知到商城道具界面

ET.SHOW_GIFT = getUID() --打开礼物界面
ET.CHANGE_GIFT = getUID() --打开礼物界面
ET.NET_GIFT_MODULE_SEND_GIFT = getUID() --送礼物给玩家
ET.NET_USER_CHANGE_DECORATION = getUID() --更换挂饰
ET.EVENT_USER_CHANGE_DECORATION = getUID() --同桌更换挂饰

ET.GET_TIME_REWARD_INFO = getUID() --查询定时奖励信息
ET.GET_POCAN_REWARD_INFO = getUID() --查询破产奖励

ET.COMMON_REWARD_NOTIFY = getUID() -- 通用小红点通知
ET.REFRESH_FREE_GILD_RED_NUM = getUID() -- 刷新免费金币按钮的小红点

ET.DA_SHANG_NPC = getUID()  	-- 打赏荷官
ET.FRIEND_INVITE_SHOW = getUID()  -- 打开邀请界面
ET.NET_FRIEND_FIND = getUID()  -- 查找好友
ET.NET_FRIEND_APPLY = getUID()  -- 添加好友
ET.NET_FRIEND_REPLY_APPLY = getUID()  -- 同意被添加为好友
ET.NET_FRIEND_INVITE = getUID()  -- 邀请好友一起玩游戏
ET.NET_FRIEND_RECV_INVITE = getUID()  -- 被邀请和好友一起玩游戏
ET.NET_FRIEND_DELETE = getUID()  -- 删除好友
ET.NET_FRIEND_RECV_REFUSE_INVITE = getUID() --邀请好友玩游戏被好友拒绝


ET.SHOW_SHARE = getUID() --分享
ET.SHARE_HIDE = getUID() --关闭分享
ET.CHECK_BR_WIN_SHARE = getUID() -- 百人场赢钱分享通知
ET.CHECK_WIN_SHARE = getUID() -- 普通场赢钱分享通知
ET.NET_SCORE_CLIENT_SHARE = getUID() -- 积分兑换礼物分享通知
ET.SHARE_CHECK_SHOW = getUID() -- 积分兑换礼物分享通知
ET.INVITE_CODE_BE_EXCHANGED = getUID() -- 兑换码被兑换通知

ET.GAME_INVITE_FRIEND = getUID() -- 通知客户端打开邀请界面通知
ET.GOTO_ACTIVITY = getUID() -- 跳到指定的活动

ET.SHOW_BEGINNERS_GUIDE= getUID() -- 新的新手引导

ET.EVENT_SHOW_SCORE_EXCHANGE = getUID()--打开积分兑换界面

ET.GET_SHOP_MAI_1_SONG_1_LIST = getUID()  -- 获取商城买就送匹配列表

ET.SHOW_ACTIVE_NOTICE_VIEW = getUID() --活动弹窗显示
ET.SHOW_ACTIVE_NOTICE = getUID() -- 显示活动公告
ET.HIDE_ACTIVE_NOTICE = getUID() -- 隐藏活动公告


ET.FRIEND_RED_POINT = getUID()   --     好友小红点
ET.FRIEND_REMOVE_RED_POINT = getUID()   --      删除好友小红点
ET.AUTO_SHOW_FREE_GOLD = getUID()   -- 自动显示免费金币

ET.CHIPS_EXCHANGE_CFG = getUID()   -- 获取房间兑换筹码配置
ET.EVENT_CHIPS_EXCHANGE_CFG = getUID() -- 设置房间内商城自动按钮选择状态
ET.GET_DAY_LOGIN_REWARD_CFG = getUID() -- 获取登录奖励配置
ET.NOTIFY_REFESH_LIFE = getUID()   -- 
ET.NOTIFY_REFESH_BEAUTY = getUID() -- 

ET.NET_RECEIVE_CHALLENGE_NOTICE_EVT =  getUID()

--[[用户更换筹码]]
ET.NET_EXCAHNGE_CHIPS_REQ = getUID() 


--付费表情
ET.NET_STORE_BUYING_USING_GOLD_REQ = getUID() 

-- 送礼物二次确认框
ET.GIVE_GIFT_TIP_EVENT = getUID()
ET.EVENT_USER_LOGIN_ELSEWHERE = getUID() -- 在其他设备上登录，断线重连判断

--显示通用提示框
ET.SHOW_COMMON_TIP_EVENT = getUID()
ET.SHOW_COMMON_TIP_WINDOW_EVENT = getUID()

-- 收礼记录
ET.NET_USER_GIFT_RECORD_REQ = getUID() 
-- 更新礼物界面礼物卡余额
ET.UPDATE_VIEW_GIFT_CARD = getUID()


ET.CUSTOMIZE_SETTLE_CLOSE_EVT = getUID()			--私人定制关闭结算
ET.NET_PROFILE_CHANGE_EVT = getUID()			--玩家信息修改广播(头像和昵称修改、隐身状态改变消息)
ET.PROFILE_CHANGE_GAME_EVT = getUID()		--游戏中玩家信息修改事件
ET.NET_HEAD_UPLOAD_SUCCESS_EVT = getUID()	--个人头像上传成功通知
--[[私人定制 end]]

ET.REWARD_SORT_CHECK = getUID()

----------------------------------  新美女--------------------------
ET.NET_LAST_WEEK_THREE_RANKING_REQ= getUID()  ---上周前三美女排行就是上周排行
ET.NET_GET_BEAUTY_PHOTO_LIST_REQ= getUID() 
ET.NET_REMOVE_BEAUTY_PHOTO_REQ= getUID() 
ET.NET_GET_LAST_WEEK_RANK_REWARD_CONF_REQ= getUID() 

ET.GALLERY_UPLOAD= getUID()
ET.NET_CHANGE_USERINFO_GET_IS_BEAUTY= getUID()
ET.NET_DESK_ASK_FEIEND_EVT= getUID()
ET.NET_DESK_ASK_FRIENDTIPS_EVT= getUID()

ET.NET_ALTER_NICK_REMARK = getUID() -- 


ET.EVT_SHOW_GAMES_RECORD = getUID() --显示牌局记录
ET.NET_QUERY_GAMES_RECORD_LIST = getUID()   --拉取牌局记录列表
ET.NET_QUERY_GAMES_RECORD_DETAILS = getUID()   --查询牌局记录详细信息



ET.SPEECHTOTEXT_STATUS_NOTIFY = getUID()   --语音识别通知
ET.SPEECHTOTEXT_VOLUME_NOTIFY = getUID()   --音量变化通知
ET.EVT_USER_REPORT            = getUID()   --举报

ET.EVT_AUTO_SUPPLY_CHIPS_REMIND = getUID()  --自动补充筹码到最大提醒

---------------------------------------
-- start MTT

ET.MTT_GAME_EXIT = getUID()  				--MTT退出游戏

-- end MTT
---------------------------------------
------------------SNG------------------
ET.SNG_GAME_EXIT = getUID()             --SNG退出

--sng 选场
ET.EVENT_SNG_MASTER_CREDIT_RANK_LIST = getUID()         --SNG 大师分排行榜


ET.EVENT_SNG_FRIEND_MASTER_CREDIT_RANK_LIST = getUID()         --SNG 好友大师分排行榜
ET.EVENT_SNG_DAY_MASTER_CREDIT_RANK_LIST = getUID()         --SNG 日大师分排行榜
ET.EVENT_SNG_DAY_FRIEND_MASTER_CREDIT_RANK_LIST = getUID()         --SNG 日好友大师分排行榜

ET.CLOSE_BEAUTY_GALLERY = getUID()         --关闭美女相册预览

ET.GAME_SHARE_CARDS_EVENT = getUID()        --牌桌内公共牌翻开事件


--手机绑定
ET.HIDE_PHONE_BINDING = getUID()

ET.GAME_SHOW_BOUNCE_BTN = getUID()			--显示跳动筹码或金币  1-筹码 2-金币

----------- qufanlogin start ---------
ET.QUFAN_LOGIN_CHANGE_PASSWORD = getUID() -- 趣凡修改密码
----------- qufanlogin end ----------

ET.SHOW_SNG_LEVEL_SYSTEM = getUID() -- 显示sng等级系统

ET.NET_DIAMOND_CHANGE_GLOBAL_EVT = getUID()     --用户钻石变更消息.
ET.NET_DIAMOND_CHANGE_USERINFO_EVT = getUID()   --个人信息页面钻石变更通知.
ET.NET_DIAMOND_CHANGE_SHOP_EVT = getUID()       --商城信息页面钻石变更通知.
ET.EVENT_SHOP_JUMP_TO_BOOKMARK = getUID() 		-- 商城标签叶卡跳转
ET.EVENT_SHOW_GOOD_DETAIL_VIEW = getUID()		-- 打开物品详情框
ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW = getUID() 	-- 购买提示框
ET.EVENT_SHOW_PAY_METHOD_VIEW = getUID() 		-- 支付方式框
ET.EVENT_SHOW_GIFT_CARD_POPUP_TIP_VIEW = getUID() --礼物卡提示框
ET.EVENT_UPDATE_GIFT_CARD_VIEW = getUID()		--更新礼物卡提示框
ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND = getUID()   --用钻石兑换金币/道具
ET.EVENT_SHOP_AD_DOWN_FINISH = getUID() 		-- 商城内广告下载完成
ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK = getUID() 	-- 游戏内商城叶卡跳转
ET.USER_ACTION_STATS_EVT = getUID()             --用户行为统计
ET.REFRESH_BANKRUPTCY_POPUP = getUID()          --钻石发货 更新破产补助弹框

ET.CHEST_START_TIME_BOX_TIMER = getUID()          --宝箱计时器
ET.CHEST_SHOW_AND_HIDE = getUID()          --宝箱计时器
ET.CHEST_ADJUST_TIME_BOX_TIMER = getUID()          --调整宝箱计时器
ET.CHEST_SHOW_CHEST_POP= getUID()          --弹起宝箱弹框
ET.CHEST_BOX_TIME_CHANGE= getUID()          --宝箱时间改变
ET.CHEST_HIDE_CHEST_POP= getUID()          --隐藏宝箱弹框
ET.CHEST_TOUCH_EVENT= getUID()          --宝箱TOUCH

ET.NET_DISCONNECT_NOTIFY = getUID()         --断线重连通知
ET.APPLICATION_RESUME_NOTIFY = getUID()     --后台返回通知

ET.SHOW_BIG_HEAD_IMAGE_EVENT= getUID()      --显示大头像
ET.EVT_SHOW_BIG_PHOTO_ALBUM_VIEW = getUID() --显示大相册
ET.PRIVATE_DESK_SETTLE_EVT = getUID()			--私人定制结算广播事件
----------- mttlobby start ---------
ET.GLOBAL_FRESH_MTTLOBBY_GOLD = getUID()		--更新mtt大厅金币显示
ET.EVENT_MTT_LOBBY_UPDATE_MY_MTT_NUM = getUID() -- 更新mtt大厅我的赛事数目
----------- mttlobby end ----------

ET.EVENT_MTT_GAME_BEGIN_NOTIFY = getUID()  --全局广播mtt开赛事件
ET.MAIN_SHOW_MTT_LOBBY = getUID()  --mtt显示大厅
ET.MTT_FLOAT_REWARD_PUSH_NTF = getUID()  --全局广播浮动奖励发放通知

ET.SETBROADCAST = getUID()  --设置喇叭位置
ET.DAILYREWAED  = getUID()  --设置喇叭位置
ET.BG_CLOSE     = getUID()  --关闭模糊背景
ET.HALL_UPDATE_INFO = getUID()  --大厅更新个人信息
ET.INSTALL_GAME  = getUID()  --安装游戏
ET.INSTALL_GAME_POP = getUID()  --安装游戏弹窗
ET.NET_DIAMOND_CHANGE_HALL = getUID() --大厅钻石更改
ET.NET_DIAMOND_CHANGE_NIUNIU_HALL = getUID() --抢庄牛牛大厅钻石更改
ET.FIRST_PAY = getUID() --首冲弹窗
ET.CHAOZHI_PAY = getUID() --超值弹窗
ET.UPDATE_PAY_LIBAO = getUID() --超值弹窗

ET.ADDLISTPOPUP = getUID()--添加弹窗队列
ET.POPLISTPOPUP = getUID()--弹出弹窗队列
ET.CLEARLISTPOPUP = getUID()--清空弹窗队列

ET.INTERACTIVE_EXPRESSION=getUID()--互动表情弹窗
ET.INTERACTIVE_EXPRESSION_REMOVE=getUID()--互动表情弹窗
ET.INTERACT_PHIZ_NTF = getUID() -- 互动表情
ET.RESET_PASSWORD = getUID() -- 重置密码


ET.SHOW_QUICKLY_CHAT = getUID() -- 快捷聊天显示
ET.REMOVE_QUICKLY_CHAT = getUID() -- 快捷聊天删除

ET.SHOW_FRIENDTIPS = getUID() -- 桌内好友请求


ET.SHOW_TURNTABLE = getUID() -- 大转盘弹窗
ET.REMOVE_TURNTABLE = getUID() -- 大转盘弹窗
ET.UPDATETURNICON = getUID() --更新大转盘

ET.SHOW_NEWSLEAD = getUID() -- 消息引导弹窗
ET.REMOVE_NEWSLEAD = getUID() -- 消息引导弹窗

ET.SHOW_FREEGOLDSHORTCUT = getUID() -- 免费金币快捷领取
ET.REMOVE_FREEGOLDSHORTCUT = getUID() --  免费金币快捷领取
ET.MAIN_UPDATE_SHORTCUT_NUMBER = getUID() -- 免费金币快捷领取

-- ET.SHOW_VISITORTIPS = getUID()
-- ET.REMOVE_VISITORTIPS = getUID()
ET.GET_HOT_UPDATA_DATA = getUID()
ET.EVENT_SHOP_SHOWLOADING = getUID() -- 显示商城loading
ET.SETTING_QUICK_START_CHOOSE_CHANGE = getUID()  --设置界面选择快速开始游戏设置

ET.SHOW_GIFTCAR_ANI = getUID() --显示小车入场动画
ET.REMOVE_GIFTCAR_ANI = getUID() --删除小车入场动画

ET.UPDATE_LOGIN_TIMES = getUID() -- 登录清除尝试登录次数
ET.SEARCH_GAME_RECORD = getUID() --查询牌局记录
ET.SEARCH_PAY_RECORD = getUID() --查询充值记录
ET.CHANGE_PWD = getUID()         --修改密码
ET.FINISH_BIND_PHONE = getUID()  --绑定完手机
ET.START_TO_LOGIN = getUID()     --连接socket
ET.LOGIN_NET_DISCONNECT = getUID()  --断开连接
ET.SET_INVITE = getUID()  --绑定邀请码
ET.BIND_CARD = getUID()  --绑定银行卡、支付宝
ET.INVITE_CODE = getUID()  --绑定邀请码
ET.FRESH_CARD_LIST = getUID()  --刷新绑定的银行卡
ET.MESSAGE_BOX = getUID() --通用提示弹框
ET.PERSONAL_INFO = getUID() --个人中心
ET.SAFE_BOX = getUID()      --保险箱
ET.EXCHANGE = getUID()      --兑换
ET.CUSTOM_CHAT = getUID()        --客服聊天
ET.HIDE_CUSTOM_CHAT = getUID()   --关闭客服聊天
ET.CUSTOM = getUID()        --客服
ET.SETTING = getUID()       --设置
ET.AGREEMENT = getUID()       --用户协议
ET.NEWACITIVY = getUID()       --新活动
ET.GAMERULE = getUID()       --玩法
ET.MAIL = getUID()       --邮箱
ET.GUIDE = getUID()       --新手引导
ET.UPDATE_MIAN_USER_INFO = getUID()
ET.XXLHELP = getUID()       --小游戏帮助页面
ET.SMALLSETTING = getUID()       --过审设置页面
ET.SHOP = getUID()      --绑定邀请码
ET.TOOL_TIPS_CLOSE = getUID()
ET.RETMONEY = getUID() --周返现
ET.HONGBAO = getUID() --红包
ET.CHECK_REMOVE_BROAD_CAST = getUID() --remove 通知栏
ET.MAIN_TAIN = getUID()        --维护公告
ET.AGENCY = getUID() --联系代理
ET.GOOD_LUCK = getUID() --好运来
ET.REFRESH_LUCK_BTN = getUID() --刷新好运来按钮
ET.DEBUG_VIEW = getUID()        --debug窗口
ET.SHOWHALLPOPVIEW = getUID() --展示大厅pop
------- 客服聊天相关 -------
ET.CHAT_MONITOR_EVENT = getUID() --聊天消息监听
ET.SHOW_PROXCY_POP = getUID() --代理消息发来，展示弹框
ET.SHOW_COMMUNITY_POP = getUID() --显示社区
ET.AGENCY_CHAT_PUSH = getUID() --代理消息推送
ET.NET_CLOSE_AND_CLOSE_CHAT_SERVICE = getUID() --游戏服断网，需要关闭聊天服
ET.UPDATE_CHAT_ITEM = getUID()
ET.CHECK_IF_NEWMESSAGE = getUID()

------ 红包相关 --------
ET.REFRESH_HONGBAO_BTN = getUID() --刷新红包按钮

------ 网络相关 --------
ET.REFRESH_NET_STRENGTH = getUID() --刷新网络强度标识

------ 游戏快速开始 --------
ET.QUICK_START_GAME = getUID()

------ 刷新上桌限制 ------
ET.REFRESH_NOMONEY_TIP =  getUID()

ET.WALLET = getUID() -- 钱包记录
ET.HEAD_MASK_SHOP = getUID() --头像框购买
ET.HEAD_MASK_BAG = getUID() --头像框购买

------ 隐私策略 ------
ET.SHOW_USER_POLICY = getUID() --显示隐私策略
ET.FRESH_HALL_SHOP_FIRST = getUID() --刷新大厅商城按钮

------ 金币不足引导充值 ------
ET.NO_GOLD_TO_RECHARGE = getUID()

------ 金币超房间上线提醒 ------
ET.OVER_ROOM_MAX_LIMIT = getUID()
