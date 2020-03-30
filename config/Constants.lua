
-------Constants.lua 
-------用来放置全局用到的常量

UserStatus = UserStatus or {}

UserStatus.USER_STATE_NORMAL = 1000 --// 不存在(进入游戏时初始化时的默认状态)
UserStatus.USER_STATE_STAND = 1010 --// 旁观中
UserStatus.USER_STATE_STAND_WAIT = 1015 --// 站着等
UserStatus.USER_STATE_READY = 1020 --// 坐下，如果已经开局，那么是不能操作的
UserStatus.USER_STATE_INGAME = 1030 --//  玩游戏中
UserStatus.USER_STATE_ALLIN = 1040 --// allin
UserStatus.USER_STATE_GIVEUP = 1050 --// 弃牌
UserStatus.USER_STATE_LOSE = 1080   --被淘汰(SNG)


-- 游戏状态
GameStatus = GameStatus or {}
GameStatus.GAME_STATE_READY = 0  -- 准备中
GameStatus.GAME_STATE_INGAME = 1  -- 游戏中
GameStatus.GAME_STATE_GLOBAL_WAIT = 2 --等待全场同步发牌
GameStatus.GAME_STATE_MERGE_WAIT = 3 --等待并桌
GameStatus.GAME_STATE_FINAL_WAIT = 4 --等待决赛并桌

ACCOUNT_BIND_STATUS_GUOPAN = 1
ACCOUNT_BIND_STATUS_QQ = 2
ACCOUNT_BIND_STATUS_FB = 4
ACCOUNT_BIND_STATUS_WX = 8
ACCOUNT_BIND_STATUS_MIGU = 16

--start------------模块开关--------------
TB_MODULE_BIT = {
	MODULE_BIT_STORE 	= 1,		-- 商城模块
	MODULE_BIT_EASY_BUY = 2,		-- 场内-快捷支付
	MODULE_BIT_KNAPSACK = 4,		-- 道具
	MODULE_BIT_ACTIVITY = 8,		-- 活动
	MODULE_BIT_REVIEW 	= 16,	-- 审核
	MODULE_BIT_SPECIAL_PAY = 64, -- 1000、2000元订单隐藏
	MODULE_BIT_STORE_TAB = 128, -- 其他页签关闭：金币购买、道具超市、兑换专区
	MODULE_BIT_STORE_BANNER = 256, -- 商城banner（广告条）关闭
	BOL_MODULE_BIT_STORE = false, -- 商城模块-根据 MODULE_BIT_STORE 取值
	BOL_MODULE_BIT_EASY_BUY = false, -- 快捷支付-根据 MODULE_BIT_EASY_BUY 取值
	BOL_MODULE_BIT_KNAPSACK = false, -- 道具-根据 MODULE_BIT_KNAPSACK 取值
	BOL_MODULE_BIT_ACTIVITY = false, -- 活动-根据 MODULE_BIT_ACTIVITY 取值
	BOL_MODULE_BIT_REVIEW = false, -- 审核开关-根据 MODULE_BIT_REVIEW 取值
	BOL_MODULE_BIT_REVIEW1 = false, -- 审核开关-根据 MODULE_BIT_REVIEW 取值
	BOL_MODULE_BIT_SPECIAL_PAY = false, -- 1000、2000元订单隐藏
	BOL_MODULE_BIT_STORE_TAB = false, -- 其他页签关闭：金币购买、道具超市、兑换专区
	BOL_MODULE_BIT_STORE_BANNER = false, -- 商城banner（广告条）关闭
	BOL_MODULE_BIT_STORE_EXCHANGE = false -- 商城兑换页面控制
}
--end------------模块开关-----------------

--退桌原因
GameExitReason = {}
GameExitReason.USER_EXIT_REASON_INVALID_DESK = 1	--错误的桌子
GameExitReason.USER_EXIT_REASON_OFF_LINE = 2	--断线了
GameExitReason.USER_EXIT_REASON_CUSTOM_OVER = 3	--私人定制超时
GameExitReason.USER_EXIT_REASON_CUSTOM_LOCKED = 4	--私人定制桌上锁
GameExitReason.USER_EXIT_REASON_MY_REQUEST = 5  --我自己请求退桌

--时间宝箱常量定义
TimeBoxOpcode = {}	--操作码
TimeBoxOpcode.TIMER_START = 1	-- 开始计时
TimeBoxOpcode.TIMER_PAUSE = 2	-- 暂停计时
TimeBoxOpcode.TIMER_RESET = 3	-- 重置计时器
TimeBoxOpcode.TASK_DONE = 4		-- 任务完成,领取奖励
TimeBoxOpcode.TASK_LEVELUP = 5	-- 任务进阶
TIMEBOX_TASK_ID	= 22			-- 时间宝箱任务ID
TIMEBOX_TASK_ID_STR	= "22"		-- 时间宝箱任务ID

--以下用来设置用户状态
GameUserStatus = {}
GameUserStatus.STATUS_NONE = 0  --未设置状态
GameUserStatus.STATUS_THINKING = 1  --思考中
GameUserStatus.STATUS_SHOWCARDS = 2 --亮牌
GameUserStatus.STATUS_LOOK = 3      --看牌
GameUserStatus.STATUS_GIVEUP = 4    --弃牌
GameUserStatus.STATUS_FOLLOW = 5    --跟注
GameUserStatus.STATUS_ADD = 6       --加注
GameUserStatus.STATUS_ALLIN = 7     --All in
GameUserStatus.STATUS_LOSE = 8      --被淘汰(SNG)

--语音识别状态通知
SpeechToTextStatus = {}
SpeechToTextStatus.STT_START_WORK = 0       --识别工作开始
SpeechToTextStatus.STT_END_WORK = 1         --识别工作结束
SpeechToTextStatus.STT_REFRESH_TEXT = 2     --中间结果更新
SpeechToTextStatus.STT_RESULT = 3           --最终结果
SpeechToTextStatus.STT_USER_CANCEL = 4      --用户取消
SpeechToTextStatus.STT_ERROR = 5            --出现错误
SpeechToTextStatus.STT_RECORD_SEC = 100     --录音计时
--语音识别错误码
SpeechToTextErrorCode = {}
SpeechToTextErrorCode.STT_REC_TIMEOUT = 0       --录音超时
SpeechToTextErrorCode.STT_START_TIMEOUT = 1     --等待开始超时
SpeechToTextErrorCode.STT_CONVERT_TIMEOUT = 2   --等待转换超时
SpeechToTextErrorCode.STT_RECORD_TOO_SHORT = 3  --录音时间太短
SpeechToTextErrorCode.STT_DEVICE_PREMISSION = 4 --没有麦克风使用权限
SpeechToTextErrorCode.STT_NETWORK_EXECEPTION = 5--网络连接异常
SpeechToTextErrorCode.STT_UNKONWN_ERROR = 6     --其他错误


NET_WORK_ERROR = {
	TIMEOUT = -200
}
RoomType = {}
RoomType.NORMAL = 1 --经典场
RoomType.BR = 3     --百人场
RoomType.TBZ = 5    --推豹子
RoomType.SNG = 6    --SNG比赛场
RoomType.MTT = 7    --MTT比赛场
RoomType.ZJH = 10   --炸金花
RoomType.LHD = 11   --龙虎斗
RoomType.DDZ = 13   --斗地主
RoomType.BRNN_V3 = 14   --百人牛牛3倍场
RoomType.BRNN_V10 = 15   --百人牛牛10倍场

SNG_WINNER_NUM = 2  --SNG场赢家个数

GAME_SHOW_UIN_FLAG = false      --默认个人信息不显示用户ID

---------支付/兑换相关常量定义------
PAY_CONST = {}
--商品类型
PAY_CONST.ITEM_TYPE_GOLD = 0
PAY_CONST.ITEM_TYPE_PROP = 1
PAY_CONST.ITEM_TYPE_DIAMOND  = 2
--兑换类型
PAY_CONST.ITEM_CURRENCY_TYPE_GOLD = 0 --用金币去兑换
PAY_CONST.ITEM_CURRENCY_TYPE_DIAMOND = 1  --用钻石去兑换
--热卖信息
PAY_CONST.ITEM_LABEL_TYPE_NONE = 0
PAY_CONST.ITEM_LABEL_TYPE_RECOMMEND = 1
PAY_CONST.ITEM_LABEL_TYPE_HOT = 2


-- 商城内页签
PAY_CONST.BOOKMARK = {}
PAY_CONST.BOOKMARK.GOLD = 0		-- 购买金币
PAY_CONST.BOOKMARK.DIAMOND = 1	-- 购买砖石
PAY_CONST.BOOKMARK.PROPS = 2	-- 购买道具

-- 游戏内商城页签
PAY_CONST.BOOKMARK_ROOM = {}
PAY_CONST.BOOKMARK_ROOM.GOLD = 0	-- 购买金币
PAY_CONST.BOOKMARK_ROOM.DIAMOND = 1	-- 购买砖石
PAY_CONST.BOOKMARK_ROOM.SUPPLY = 2	-- 补充筹码

PAY_CONST.ITEM_LABEL_TYPE_RECOMMEND = 1 --推荐
PAY_CONST.ITEM_LABEL_TYPE_HOT = 2      --热销
--展示的货币类型
PAY_CONST.CURRENCY_GOLD = 0
PAY_CONST.CURRENCY_DIAMOND = 1


--特殊牌型样式对照表           
_SPECIAL_STYLE = {"对子","三条","高牌","两对","顺子","同花",HJ="皇家",JG="金刚",HJTHS="皇家同花顺",HL="葫芦",THS="同花顺"}

MTT_CONTEST_STATUS = {
	EVENT_STATUS_INIT = 0 --未开放
	, EVENT_STATUS_ENTRY = 100 --报名阶段
	, EVENT_STATUS_ENTER = 200 --进场阶段
	, EVENT_STATUS_WAIT_BEGIN = 300 --等待游戏开始
	, EVENT_STATUS_PLAYING = 400 --游戏进行中
	, EVENT_STATUS_SYNC_PLAY = 401 --同步发牌阶段
	, EVENT_STATUS_MONEY = 402 --预决赛阶段:进入钱圈到决赛之间
	, EVENT_STATUS_FINAL = 403 --决赛阶段
	, EVENT_STATUS_END = 500 --已经结束
	, EVENT_STATUS_END_TOO_FEW = 501 --人数不足而取消赛事
	, EVENT_STATUS_END_WAITING = 502 --等待释放
}
SERVER_REASON = {
	USER_STAND_REASON_MTT_EVENT_REBUY = 2 --MTT玩家输光，需要重购
	, USER_STAND_REASON_MTT_EVENT_ADDON = 3 --MTT玩家输光，需要增购
	, USER_EXIT_REASON_MTT_EVENT_TEAR_DESK = 8 --桌子被拆，转到其他桌子继续旁观
	, USER_EXIT_REASON_MTT_EVENT_CANCELED = 9 --MTT比赛取消
	, USER_EXIT_REASON_MTT_EVENT_END = 10 --MTT比赛结束
}
MTT_USER_OP = {
	LOSE = 1 --被淘汰了
	, MERGE = 2 --并进来
	, JOIN = 3 --加入
	, EXIT = 4 --退赛
	, REBUY = 7 --重购回来了
	, ADDON = 8 --增购回来了
}

-- 登录方式(不仅是登录了,包括登录界面所有的操作)
VAR_LOGIN_TYPE_NO_LOGIN = "0" -- 被踢下线或没有登录过
VAR_LOGIN_TYPE_VISITOR = "-1" -- 游客登录
VAR_LOGIN_TYPE_QQ = "1" -- QQ登录
VAR_LOGIN_TYPE_WECHAT = "2" --微信登录
VAR_LOGIN_TYPE_PHONE_PWD = "3" --手机密码登录
VAR_LOGIN_TYPE_PHONE_PIN = "4" --手机验证码登录
VAR_LOGIN_TYPE_PHONE_REG = "5" --手机注册
VAR_LOGIN_TYPE_PHONE_FIND = "6" --找回密码
VAR_LOGIN_TYPE_PHONE_SET = "7" --设置密码

--游戏类型
JDC_MATCHE_TYPE = "JDC" --经典场
BRC_MATCHE_TYPE = "BRC" --百人场
BRNN_MATCHE_TYPE = "BRNN" --百人牛牛
SNG_MATCHE_TYPE = "SNG" --SNG场
MTT_MATCHE_TYPE = "MTT" --MTT场
GAME_TBZ        = "TBZ" --退豹子
GAME_NIU_ZHA    = "NIU" --牛牛扎金牛
GAME_NIU_KAN    = "NIUKAN" --牛牛看牌
GAME_ZJH        = "ZJH" --炸金花
GAME_DDZ        = "DDZ" --斗地主
LHD_MATCHE_TYPE = "LHD" --龙虎斗
BJL_MATCHE_TYPE = "BJL" --百家乐
LIST_ITEM_TIME = 0.08

FORCE_ADJUST_GAME = false
GAME_RADIO = 0.5625
GAME_DEAFULT_RADIO = 0.6

LOGIN_LOADING_ARMATURE_WIDTH = 202  --登录loading动画宽度值

CHIPCOLOR = {}
CHIPCOLOR.RED = 1
CHIPCOLOR.BLUE = 2
CHIPCOLOR.PURPLE = 3
CHIPCOLOR.GREEN = 4
CHIPCOLOR.ORANGE = 5
CHIPCOLOR.GRAYBLUE = 6

QUICKGAME_TYPE = {
	QUICKSTART = 1,
	QUICKMATCH = 2
}
