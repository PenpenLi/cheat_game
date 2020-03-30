

local PBAdapter = class("PBAdapter")
PBAdapter.TAG = "PBAdapter"
PBAdapter.prefix = "texas.net.proto."
function PBAdapter:ctor(paras)
    -- _reqtable請求消息類名稱列表
    -- _rsptable 響應回來的消息 對象名稱列表

    self._reqtable = {}
    self._rsptable = {}



    --game proto start--
    self._reqtable[CMD.INPUT] = "GameEnterDeskReq"
    self._rsptable[CMD.INPUT] = "GameEnterDeskRsp"
    
    self._rsptable[CMD.INPUT_GAME_EVT] = "EvtDeskUserEnter"
    self._rsptable[CMD.GENERAL_NOTICE] = "NtfClientCommand"

    self._reqtable[CMD.EXIT] = "GameExitDeskReq"
    self._rsptable[CMD.EXIT] = "GameExitDeskRsp"

    self._rsptable[CMD.GET_USER_GAME_INFO] = "query_user_info_rsp"
    self._reqtable[CMD.GET_USER_GAME_INFO] = "query_user_info_req"
    
    self._rsptable[CMD.EVENT_USER_CHIPS_CHANGE] = "EvtUserChipsChange"
    
    self._rsptable[CMD.CHIPS_EXCHANGE_CFG] = "PullChipsExchangeCfgRsp"
    
    self._reqtable[CMD.CMD_GET_LUCKY_WHEEL_REWARD] ="LuckyWheelRewardReq" -- 大厅大转盘每日登录奖励，转动转盘请求
    self._rsptable[CMD.CMD_GET_LUCKY_WHEEL_REWARD] ="LuckyWheelRewardRsp" --转盘请求的返回


    self._reqtable[CMD.CMD_GET_CUMULATE_LOGIN_REWARD] ="CumulateLoginRewardReq" -- 大厅累计登陆奖励，累计登陆领奖请求
    self._rsptable[CMD.CMD_GET_CUMULATE_LOGIN_REWARD] ="CumulateLoginRewardRsp" --累计登陆的返回
    --game proto end--

    --应用逻辑协议 start--
    self._reqtable[CMD.REG] = "UserRegReq"
    self._rsptable[CMD.REG] = "UserLoginRsp"
    self._reqtable[CMD.LOGIN] = "UserLoginReq"
    self._rsptable[CMD.LOGIN] = "UserLoginRsp"
    self._rsptable[CMD.CHANGEGOLD_EVT] = "EvtDeskGoldChanged"
    self._rsptable[CMD.RECEIVE_GIFT_EVT] = "EvtDeskRecvGift"
    self._reqtable[CMD.CONFIG] = "GameConfReq"
    self._rsptable[CMD.CONFIG] = "GameConfRsp"
    self._rsptable[CMD.ZERO_CONFIG] = "ZeroGameConfRsp"
    self._reqtable[CMD.USER_MODIFY] = "SetProfileReq"
    self._rsptable[CMD.USER_MODIFY] = "SetProfileReq"
    self._rsptable[CMD.TASKLIST] = "TaskListRsp"
    self._reqtable[CMD.TASKREWARD] = "PickRewardReq"
    self._rsptable[CMD.RECENTBEAUTY] = "FetchRecentBeautyRsp"
    self._rsptable[CMD.WORLD_WEEK_RECORD_RANK] = "WorldWeekWinRankRsp"
    self._rsptable[CMD.FRIEND_WEEK_RECORD_RANK] = "FriendWeekWinRankRsp"
    self._rsptable[CMD.WORLD_DAY_WIN_RANK] = "WorldDaySingleWinGoldRankRsp"
    self._rsptable[CMD.FRIEND_DAY_WIN_RANK] = "FriendDaySingleWinGoldRankRsp"
    self._rsptable[CMD.WORLD_GOLD_RANK] = "WorldGoldRankRsp"
    self._rsptable[CMD.FRIEND_GOLD_RANK] = "FriendGoldRankRsp"
    self._rsptable[CMD.SEX_STATUS] = "CheckBeautyStatusRsp"
    self._reqtable[CMD.APPLY_REWARD_CODE] = "ApplyRewardCodeReq"
    self._rsptable[CMD.APPLY_REWARD_CODE] = "ApplyRewardCodeRsp"
    self._rsptable[CMD.COLLAPSE_PAY] = "DayGoldSendInfoRsp"
    self._rsptable[CMD.GET_COLLAPSE_PAY] = "FetchDayGoldRsp"
    self._reqtable[CMD.GET_COLLAPSE_PAY] = "FetchDayGoldReq"
    self._reqtable[CMD.PHONE_LOGIN_PIN] = "PhoneLoginReq"
    self._rsptable[CMD.PHONE_LOGIN_PIN] = "UserLoginRsp"
    self._reqtable[CMD.PHONE_LOGIN_PWD] = "UserPhoneLgoinReq"
    self._rsptable[CMD.PHONE_LOGIN_PWD] = "UserLoginRsp"
    self._reqtable[CMD.PHONE_SET_PWD] = "SetPhonePasswdReq"
    self._rsptable[CMD.PHONE_SET_PWD] = "SetPhonePasswdReq"
    self._reqtable[CMD.PHONE_RESET_PWD] = "ResetPasswdReq"
    self._rsptable[CMD.PHONE_RESET_PWD] = "ResetPasswdReq"
    self._reqtable[CMD.SAFE_DEPOSIT] = "SafeDepositReq"
    self._rsptable[CMD.SAFE_DEPOSIT] = "SafeDepositRsp"
    self._reqtable[CMD.SAFE_WITHDRAW] = "SafeWithDrawReq"
    self._rsptable[CMD.SAFE_WITHDRAW] = "SafeWithdrawtRsp"
    self._reqtable[CMD.SAFE_CHANGE_PASSWORD] = "SafeChangePassword"
    self._rsptable[CMD.SAFE_CHANGE_PASSWORD] = "SafeChangePassword"
    self._reqtable[CMD.SAFE_QUERY_MONEY] = "SafeQueryGoldRep"
    self._rsptable[CMD.SAFE_QUERY_MONEY] = "SafeQeuryGoldRsp"
    self._reqtable[CMD.PHONE_FIND_PWD] = "ResetPasswdReq"
    self._rsptable[CMD.PHONE_FIND_PWD] = "ResetPasswdReq"
    self._reqtable[CMD.GAME_TYPE_LIST] = "GetDeskTypeReq"
    self._rsptable[CMD.GAME_TYPE_LIST] = "GetDeskTypeRsp"
    self._reqtable[CMD.GAME_RECORD] = "GetGameRecordReq"
    self._rsptable[CMD.GAME_RECORD] = "GetGameRecordRsp"
    self._reqtable[CMD.PAY_RECORD] = "GetRechargeReq"
    self._rsptable[CMD.PAY_RECORD] = "GetRechargeRsp"
    self._reqtable[CMD.GET_EXCHANGE_CONFIG] = "GetBindConfReq"
    self._rsptable[CMD.GET_EXCHANGE_CONFIG] = "GetBindConfRsp"
    self._reqtable[CMD.GET_BINDING_CONFIG] = "GetBindInfoReq"
    self._rsptable[CMD.GET_BINDING_CONFIG] = "GetBindInfoRsp"
    self._reqtable[CMD.REQ_EXCHANGE] = "UserWithDrawReq"
    self._rsptable[CMD.REQ_EXCHANGE] = "UserWithDrawReq"
    self._reqtable[CMD.BIND_CARD] = "BindCardReq"
    self._rsptable[CMD.BIND_CARD] = "BindCardReq"
    self._reqtable[CMD.CHANGE_LOGIN_PWD] = "BindPhoneReq"
    self._rsptable[CMD.CHANGE_LOGIN_PWD] = "BindPhoneReq"
    self._reqtable[CMD.INVITE_CODE] = "UserCodeReq"
    self._rsptable[CMD.INVITE_CODE] = "UserCodeRsp"
    self._reqtable[CMD.CLOSE_GUIDE_VIEW] = "CloseNewUserGuideReq"
    self._rsptable[CMD.CLOSE_GUIDE_VIEW] = "CloseNewUserGuideRsp"
    self._reqtable[CMD.QUERY_CHAT_INFO] = "QueryCustomServiceReq" -- 查询客服信息
    self._rsptable[CMD.QUERY_CHAT_INFO] = "QueryCustomServiceRsp"

    self._reqtable[CMD.QUERY_FIRST_RECHARGE] = "QueryFirstRechargeReq" --查询首充红包信息
    self._rsptable[CMD.QUERY_FIRST_RECHARGE] = "QueryFirstRechargeRsp"
    self._reqtable[CMD.GET_FIRST_RECHARGE] = "GetFirstRechargeReq" -- 获取首充红包
    self._rsptable[CMD.GET_FIRST_RECHARGE] = "GetFirstRechargeRsp"

    self._reqtable[CMD.GET_PROXCY_SERVICE_INFO] = "GuestRechargeReq" -- 获取代理客服消息
    self._rsptable[CMD.GET_PROXCY_SERVICE_INFO] = "GuestRechargeRsp"

    self._reqtable[CMD.BUY_HEAD_MASK] = "UserBuyPortraitFrameReq" --用户购买头像框
    self._rsptable[CMD.BUY_HEAD_MASK] = "UserBuyPortraitFrameRsp"

    self._reqtable[CMD.BUY_HEAD_MASK] = "UserBuyPortraitFrameReq" --用户购买头像框
    self._rsptable[CMD.BUY_HEAD_MASK] = "UserBuyPortraitFrameRsp"

    self._reqtable[CMD.GET_HEAD_MASK_CONFIG] = "PortraitFrameInfoReq" --获取头像框信息
    self._rsptable[CMD.GET_HEAD_MASK_CONFIG] = "PortraitFrameInfoRsp"

    self._reqtable[CMD.USER_CHOOSE_HAED_MASK] = "UsePortraitFrameReq" --用户选择头像框
    self._rsptable[CMD.USER_CHOOSE_HAED_MASK] = "UsePortraitFrameRsp"

    self._reqtable[CMD.QUERY_USER_APPSTORE_FIRST] = "StoreFirstRechargeReq" --查询用户购买appstore首冲情况
    self._rsptable[CMD.QUERY_USER_APPSTORE_FIRST] = "StoreFirstRechargeRsp"
    
    --应用逻辑协议 end--



    --other proto start--
    self._reqtable[CMD.CHAT] = "DeskChatReq"
    self._rsptable[CMD.CHAT_NOTICE_EVT] = "EvtDeskChat"

    self._rsptable[CMD.BROADCAST_OTHER_EVT] = "EvtBroadCast"

    self._rsptable[CMD.FRIENDS_LIST] = "UserFriendsRsp"
    self._rsptable[CMD.LAST_WEEK_RANKING] = "LastWeekRecvGiftRankRsp"
    self._rsptable[CMD.THIS_WEEK_RANKING] = "WeekRecvGiftRankRsp"
    self._reqtable[CMD.SEND_GIFT] = "DeskSendGiftReq"
    self._reqtable[CMD.USER_SEND_GIFT_TO_ALL] = "DeskSendGiftReq"
    
    self._rsptable[CMD.EVENT_USER_CHANGE_DECORATION] = "EvtUserChangeDecoration"
    
    self._reqtable[CMD.GIFT_CONF] = "GiftListReq"
    self._rsptable[CMD.GIFT_CONF] = "GiftListRsp"
    self._reqtable[CMD.USER_CHANGE_DECORATION] = "ChangeDecorationReq"
    self._rsptable[CMD.USER_CHANGE_DECORATION] = "ChangeDecorationRsp"
    
    self._reqtable[CMD.ADD_FRIEND] = "ApplyFriendReq"
    self._reqtable[CMD.USER_INFO] = "OtherUserInfoReq"
    self._rsptable[CMD.USER_INFO] = "OtherUserInfoRsp"

    self._rsptable[CMD.ALL_ACTIVITY] = "GetAllActivityRsp"

    self._rsptable[CMD.NEW_GONGGAO] = "SysNoticeRsp" 
    self._rsptable[CMD.GET_ONLINE_NUMBER] = "EvtQueryPlayerNumsRsp" 
    self._rsptable[CMD.GET_MAIL_INFO] = "MailRsp" 

    self._reqtable[CMD.DEL_MAIL] = "DeleteMailReq"    
    self._rsptable[CMD.DEL_MAIL] = "DeleteMailRsp" 

    self._reqtable[CMD.READ_MAIL] = "ReadMailReq"    
    self._rsptable[CMD.READ_MAIL] = "ReadMailRsp" 


    self._rsptable[CMD.GET_FINISH_ACTIVITY_NUM_EVT] = "ActivityInfoRsp"
    self._rsptable[CMD.UPDATA_GOLD_EVT] = "EvtUserGoldChange"
    self._rsptable[CMD.EVENT_OTHER_GOLD_CHANGE] = "EvtOtherUserGoldChange"
    self._rsptable[CMD.LOGIN_NOTICE_EVT] = "EvtUserLoginNotice"
    self._rsptable[CMD.RECEIVE_GOLD_EVT] = "EvtActivityReceiveGold"
    self._rsptable[CMD.DESK_TASK_EVT] = "EvtDeskTask"
    
    self._rsptable[CMD.BROADCAST_OTHER_EVT] = "EvtBroadCast"
    self._rsptable[CMD.BAROADCAST_DIM_EVT] = "EvtBuySucc"
     

    self._reqtable[CMD.ASK_QES] = "UserAskQuestionReq"
    self._rsptable[CMD.ASK_QES] = "UserAskQuestionRsp"

    self._reqtable[CMD.QES_REQ] = "QuestionListReq"
    self._rsptable[CMD.QES_REQ] = "QuestionListRsp"
    

    self._reqtable[CMD.RET_MONEY] = "ReturnProfitReq"
    self._rsptable[CMD.RET_MONEY] = "ReturnProfitRsp"

    self._reqtable[CMD.RET_EXCHANGE] = "ReturnSettlementReq"
    self._rsptable[CMD.RET_EXCHANGE] = "ReturnSettlementRsp"


    self._reqtable[CMD.REQ_BUY_MAMMON] = "UserBuyMammonReq"
    self._rsptable[CMD.REQ_BUY_MAMMON] = "UserBuyMammonRsp"

    self._reqtable[CMD.REQ_MAMMON_INFO] = "UserGetMammonInfoReq"
    self._rsptable[CMD.REQ_MAMMON_INFO] = "UserGetMammonInfoRsp"

    self._reqtable[CMD.REQ_MAMMON_RECORD] = "UserGetMammonRecordReq"
    self._rsptable[CMD.REQ_MAMMON_RECORD] = "UserGetMammonRecordRsp"
 
    self._reqtable[CMD.BIND_AGENCY] = "BindProxyReq"
    self._rsptable[CMD.BIND_AGENCY] = "QueryProxyListRsp"

    self._reqtable[CMD.GET_AGENCY_INFO] = "QueryProxyListReq"
    self._rsptable[CMD.GET_AGENCY_INFO] = "QueryProxyListRsp"

    self._reqtable[CMD.GET_DESK_LIST_INFO] = "AllDeskGroundsReq"
    self._rsptable[CMD.GET_DESK_LIST_INFO] = "AllDeskGroundsRsp"

    self._reqtable[CMD.TEST_CONNECTION] = "TestForConnectionReq"
    self._rsptable[CMD.TEST_CONNECTION] = "TestForConnectionRsp"

    self._reqtable[CMD.GLOBAL_QUICK_START_GAME] = "GetUserQuickRoomIdReq"
    self._rsptable[CMD.GLOBAL_QUICK_START_GAME] = "GetUserQuickRoomIdRsp"


    --other proto end--

    -- for key, var in pairs(self._reqtable) do
    --     logd(key .. "=" .. var , "FBAdapter")
    -- end

    self._reqtable[CMD.QUERY_DESK_ON_SHOW] = "QueryDeskReq"   -- 后台恢复时请求
    self._rsptable[CMD.QUERY_DESK_ON_SHOW] = "EvtDeskUserEnter" -- 桌子信息
    self._reqtable[CMD.CMD_BR_QUERY_PLAYER_DESK_V2] = "QueryDeskReq"   -- 后台恢复时请求 -- new
    self._rsptable[CMD.CMD_BR_QUERY_PLAYER_DESK_V2] = "EvtDeskUserEnter" -- 桌子信息 -- new

    self._reqtable[CMD.QQ_REG] = "QQUserRegReq"
    self._rsptable[CMD.QQ_REG] = "UserRegRsp"

    self._reqtable[CMD.WX_REG] = "WXUserRegReq"
    self._rsptable[CMD.WX_REG] = "UserLoginRsp"

    --self._reqtable[CMD.FACEBOOK_REG] = "FBUserRegReq"
    --self._rsptable[CMD.FACEBOOK_REG] = "UserRegRsp"
    
    self._rsptable[CMD.EVENT_USER_DAOJU_CHANGE] = "EvtBuyPropSucc"  -- 道具发货通知

    self._rsptable[CMD.EVENT_LOGIN_REWARD_GET] = "PickDayRewardV2Rsp"  -- 每日登录奖励领取
    --self._rsptable[CMD.EVENT_LOGIN_REWARD_RECVE] = "PickDayRewardV2Rsp"  -- 每日登录奖励领取结果
    
    self._reqtable[CMD.CMD_EXCHANGE_FEE_TICKET_TO_CASH] = "ExchangeFeeTicketToCashReq"--兑换话费券为话费
    self._rsptable[CMD.CMD_EXCHANGE_FEE_TICKET_TO_CASH] = "ExchangeFeeTicketToCashRsp"--兑换话费券为话费
    self._reqtable[CMD.CMD_QUERY_FEE_TICKET] = "QueryFeeTicketReq"--查询话费券
    self._rsptable[CMD.CMD_QUERY_FEE_TICKET] = "QueryFeeTicketRsp"--查询话费券
    
    self._rsptable[CMD.EVENT_SCORE_CHANGED] = "EvtScoreChanged"--积分变化通知
    self._rsptable[CMD.WEEK_MONTH_CARD_NOTICE] = "NtfPropUsed"--周卡月卡通知
    self._reqtable[CMD.PHONE_NUM_BINDING] = "BindPhoneNumberReq"--绑定手机号

    self._reqtable[CMD.CMD_QUERY_SCHED_REWARD] = "SchedRewardConfReq"--查询定时奖励
    self._rsptable[CMD.CMD_QUERY_SCHED_REWARD] = "SchedRewardConfRsp"--查询定时奖励
    self._reqtable[CMD.CMD_PICK_SCHED_REWARD] = "PickSchedRewardReq"--领取定时奖励
    self._rsptable[CMD.CMD_QUERY_BROKE_SUPPLY] = "BrokeSupplyStatus"--查询破产补助

    self._reqtable[CMD.CMD_QUERY_BILLBOARD] = "RewardBillboardReq"--查询系统公告
    self._rsptable[CMD.CMD_QUERY_BILLBOARD] = "RewardBillboardRsp"--
    self._rsptable[CMD.CMD_COMMON_REWARD_NOTIFY] = "PickableRewardsNtf"--小红点通知

    self._reqtable[CMD.FRIENDS_FIND] = "QueryUserReq"--根据uin查找用户
    self._rsptable[CMD.FRIENDS_FIND] = "QueryUserRsp"
    self._reqtable[CMD.FRIENDS_APPLY] = "AskFriendReq"--根据uin查找用户
    self._rsptable[CMD.FRIENDS_APPLY] = "AskFriendRsp"
    self._reqtable[CMD.FRIEND_REPLY_APPLY] = "ReplyFriendReq"--确定要添加氮气好友
    self._rsptable[CMD.FRIEND_REPLY_APPLY] = "ReplyFriendReq"
    self._reqtable[CMD.FRIEND_ONLINE] = "QueryOnlineFriendsReq"--查询在线的好友
    self._rsptable[CMD.FRIEND_ONLINE] = "QueryOnlineFriendsRsp"  
    self._reqtable[CMD.FRIEND_INVITE] = "InviteFriendPlayGameReq"--邀请好友一起玩游戏
    self._rsptable[CMD.FRIEND_INVITE] = "InviteFriendPlayGameRsp"  
    self._rsptable[CMD.FRIEND_RECV_INVITE] = "InviteFriendPlayGameNtf" --被邀请和朋友一起玩游戏
    self._reqtable[CMD.FRIEND_REFUSE_INVITE] = "RefuseInviteFriendPlayGameReq" --拒绝被邀请和朋友一起玩游戏
    self._rsptable[CMD.FRIEND_REFUSE_INVITE] = "RefuseInviteFriendPlayGameRsp"
    self._reqtable[CMD.FRIEND_DELETE] = "DeleteFriendReq" --删除好友
    self._rsptable[CMD.FRIEND_DELETE] = "DeleteFriendRsp"
    self._rsptable[CMD.FRIEND_RECV_REFUSE_INVITE] = "RefuseInviteFriendPlayGameNtf"
    self._rsptable[CMD.SCORE_CLIENT_SHARE] = "CommandClientShare"
    self._rsptable[CMD.INVITE_CODE_BE_EXCHANGED] = "InviteCodeBeExchanged" -- 兑换码被兑换通知 

    
    self._reqtable[CMD.GET_SHOP_MAI_1_SONG_1_LIST] = "BoughtItemIdsReq" --商城买一送一请求
    self._rsptable[CMD.GET_SHOP_MAI_1_SONG_1_LIST] = "BoughtItemIdsRsp"
    self._rsptable[CMD.GET_DAY_LOGIN_REWARD_CFG] = "DailyRewardConfRsp" -- 拉取每日登录奖励配置

    self._rsptable[CMD.RECEIVE_CHALLENGE_NOTICE_EVT] = "EvtUserChallengeNotice"
    
    self._reqtable[CMD.STORE_BUYING_USING_GOLD] = "StoreBuyReq"--用金币购买
    self._rsptable[CMD.STORE_BUYING_USING_GOLD] = "StoreBuyRsp" -- 有金币购买

    self._rsptable[CMD.CMD_EVENT_USER_LOGIN_ELSEWHERE] = "EventUserLoginElsewhere" -- 在其他设备上登录，断线重连判断
 

    self._reqtable[CMD.USER_GIFT_RECORD] = "GiftRecordReq" -- 收礼礼物
    self._rsptable[CMD.USER_GIFT_RECORD] = "GiftRecordRsp" -- 收礼礼物y

    self._rsptable[CMD.PRIVATE_DESK_SETTLE] = "PrivateDeskSettleEvt"	--私人房间结算广播
    self._rsptable[CMD.PROFILE_CHANGE] = "ProfileChangedEvt"	--玩家信息修改广播
    self._rsptable[CMD.HEAD_UPLOAD_SUCCESS] = "PortraitUploadedNtf"	--个人头像上传成功通知
    
    self._reqtable[CMD.VIP_HIDING_REQ] = "SetHidingReq"		--VIP隐身请求
    self._rsptable[CMD.VIP_HIDING_REQ] = "SetHidingRsp"		--VIP隐身回复




   
------------------新美女-------------------
    self._reqtable[CMD.GET_BEAUTY_PHOTO_LIST] = "QueryAlbumUrlsReq" -- 
    self._rsptable[CMD.GET_BEAUTY_PHOTO_LIST] = "QueryAlbumUrlsRsp" -- 
    self._reqtable[CMD.REMOVE_BEAUTY_PHOTO] = "RemoveAlbumImageReq" -- 
    self._rsptable[CMD.REMOVE_BEAUTY_PHOTO] = "RemoveAlbumImageRsp" -- 
    self._reqtable[CMD.GET_LAST_WEEK_RANK_REWARD_CONF] = "LastWeekRankRewardConfReq" -- 
    self._rsptable[CMD.GET_LAST_WEEK_RANK_REWARD_CONF] = "LastWeekRankRewardConfRsp" -- 

    self._rsptable[CMD.BEAUTY_DALIY_REWARD] = "PickBeautyDayRewardRsp"

    --self._reqtable[CMD.BEAUTY_WEEKLY_REWARD] = "PickBeautyRankWeekRewardReq" -- 
    self._rsptable[CMD.BEAUTY_WEEKLY_REWARD] = "PickBeautyRankWeekRewardRsp"
------------------新美女end-------------------
    self._rsptable[CMD.DESK_ASK_FEIEND] = "DeskAskFriendEvt"
    self._rsptable[CMD.DESK_ASK_FRIENDTIPS] = "ReplyFriendNotice"

    self._reqtable[CMD.QUERY_JACKPOT_RECORD] = "QueryJackpotHitedRecordReq" -- 查询jackpot中奖记录
    self._rsptable[CMD.QUERY_JACKPOT_RECORD] = "QueryJackpotHitedRecordRsp"
    self._reqtable[CMD.QUERY_GAMES_RECORD_LIST] = "MyPlayRecordListReq" -- 查询牌局记录
    self._rsptable[CMD.QUERY_GAMES_RECORD_LIST] = "MyPlayRecordListRsp"
    self._reqtable[CMD.QUERY_GAMES_RECORD_DETAILS] = "RoundPlayRecordsReq" -- 查询牌局记录详情
    self._rsptable[CMD.QUERY_GAMES_RECORD_DETAILS] = "RoundPlayRecordsRsp"


    self._reqtable[CMD.ALTERNICKREMARK] = "AlterNickRemarkReq"
    self._rsptable[CMD.ALTERNICKREMARK] = "NickRemarkListRsp"


    self._reqtable[CMD.USER_REPORT] = "MakeComplaintReq"                    --举报





----------------------选场大厅---------------------
    self._reqtable[CMD.SUCCESS_WORLD_RANKING] = "ContestCreditRankInfoReq"  --比赛积分胜分榜-世界排行
    self._rsptable[CMD.SUCCESS_WORLD_RANKING] = "ContestCreditRankInfoRsp" 


    self._reqtable[CMD.SUCCESS_WORLD_WEEK_RANKING] = "ContestCreditRankInfoReq"   --周比赛积分胜分榜-世界排行
    self._rsptable[CMD.SUCCESS_WORLD_WEEK_RANKING] = "ContestCreditRankInfoRsp"

    self._reqtable[CMD.SUCCESS_FRIEND_WEEK_RANKING] = "ContestCreditRankInfoReq"    --周比赛积分胜分榜-好友排行
    self._rsptable[CMD.SUCCESS_FRIEND_WEEK_RANKING] = "ContestCreditRankInfoRsp"

    self._rsptable[CMD.USER_DIAMOND_CHANGED] = "EvtUserDiamondChange"
    self._reqtable[CMD.PRODUCT_EXCHANGE_BY_DIAMOND] = "StoreBuyItemUsingDiamondReq"
    self._rsptable[CMD.PRODUCT_EXCHANGE_BY_DIAMOND] = "StoreBuyItemUsingDiamondRsp"
    self._reqtable[CMD.PUSH_USER_ACTION_STATS] = "PushStatDataReq"
    self._rsptable[CMD.PUSH_USER_ACTION_STATS] = "PushStatDataRsp"

    self._reqtable[CMD.USE_ANTI_STEALTH_CARD] = "UseAntiStealthCardReq"
    self._rsptable[CMD.USE_ANTI_STEALTH_CARD] = "UseAntiStealthCardRsp"

    self._reqtable[CMD.SUCCESS_FRIEND_RANKING] = "ContestCreditRankInfoReq"    --比赛积分胜分榜-好友排行
    self._rsptable[CMD.SUCCESS_FRIEND_RANKING] = "ContestCreditRankInfoRsp"
    
    self._reqtable[CMD.MTT_QUERY_PLAYER_DESK_REQ] = "QueryDeskReq" --mtt后台切入前台查询牌桌
    self._rsptable[CMD.MTT_QUERY_PLAYER_DESK_REQ] = "EvtDeskUserEnter" --mtt后台切入前台查询牌桌
    self._rsptable[CMD.MTT_FLOAT_REWARD_PUSH_NTF] = "MTTEventMyResult" --浮动奖励发放通知

    self._reqtable[CMD.CMD_INTERACT_PHIZ] = "MagicExpressionReq" -- 发送互动表情
    self._rsptable[CMD.CMD_INTERACT_PHIZ] = "MagicExpressionRsp"
    self._rsptable[CMD.CMD_INTERACT_PHIZ_NTF] = "EvtMagicExpression" -- 下发互动表情
end


--[[--
method=req|rsp
cmd
]]

function PBAdapter:findPBNameByCmd(paras)

    if(paras == nil or paras.method == nil or paras.cmd == nil ) then
        loge("error on find pbName",self.TAG)
    end

    if self["_"..paras.method.."table"][paras.cmd] == nil then
        loge(" -- cannot find pname by cmd ="..paras.cmd .. " on table = "..paras.method)
        return nil 
    end
    
    return self.prefix..self["_"..paras.method.."table"][paras.cmd]
end


function PBAdapter:getSignPBName()
    return self.prefix.."SignedBody"
end


return PBAdapter
