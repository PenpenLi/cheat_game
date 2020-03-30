--[[
    server msg adapter to game event
    根据服务器发来的数据包，解析其唯一标识
    然后分发到本地游戏中的事件
]]



local ETAdapter = class("ETAdapter")
ETAdapter.TAG = "ETAdapter"


function ETAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 self._etable[CMD.INPUT_GAME_EVT] = {ET.A,ET.B}
    -- 
    --

	self._etable = {}
    --game proto start--
    self._etable[CMD.INPUT_GAME_EVT] =  ET.NET_INPUT_GAME_EVT
    self._etable[CMD.GENERAL_NOTICE] =  ET.GAME_GENERAL_NOTICE


    self._etable[CMD.EVENT_USER_CHIPS_CHANGE] =  ET.EVENT_USER_CHIPS_CHANGE

    
    --game proto end--
    --other proto start--
    self._etable[CMD.CHANGEGOLD_EVT] =  ET.NET_CHANGEGOLD_EVT
    self._etable[CMD.CHAT_NOTICE_EVT] =  ET.NET_CHAT_NOTICE_EVT
    self._etable[CMD.RECEIVE_GIFT_EVT] =  ET.NET_RECEIVE_GIFT_EVT
    self._etable[CMD.EVENT_USER_CHANGE_DECORATION] =  ET.EVENT_USER_CHANGE_DECORATION
    self._etable[CMD.DESK_TASK_EVT] =  ET.NET_DESK_TASK_EVT
    self._etable[CMD.GET_FINISH_ACTIVITY_NUM_EVT] =  ET.NET_GET_FINISH_ACTIVITY_EVT
    
    --other proto end--
    --global proto start--
    self._etable[CMD.BROADCAST_OTHER_EVT] = ET.NET_BROADCAST_OTHER_EVT
    self._etable[CMD.BAROADCAST_DIM_EVT] = {
            ET.NET_BAROADCAST_DIM_EVT,
            ET.REFRESH_BANKRUPTCY_POPUP
    }
    self._etable[CMD.UPDATA_GOLD_EVT] = {
            ET.NET_UPDATA_GOLD_EVT,
            ET.GLOBAL_FRESH_MAIN_GOLD,
            ET.GLOBAL_FRESH_LOBBIES_GOLD,
            ET.GLOBAL_FRESH_CUSTOMIZE_GOLD,
            ET.REFRESH_SHOP_GOLD,
            ET.REFRESH_GAME_SHOP_GOLD,
            ET.REFRESH_GAME_SHOP_GOLD,
            ET.NET_CHANGEGOLD_EVT
    }
    self._etable[CMD.EVENT_OTHER_GOLD_CHANGE] = ET.NET_EVENT_OTHER_GOLD_CHANGE
    self._etable[CMD.LOGIN_NOTICE_EVT] = ET.NET_LOGIN_NOTICE_EVT
    self._etable[CMD.RECEIVE_GOLD_EVT] = ET.NET_RECEIVE_GOLD_EVT
    
    self._etable[CMD.EVENT_USER_DAOJU_CHANGE] = ET.EVENT_USER_DAOJU_CHANGE

    self._etable[CMD.EVENT_LOGIN_REWARD_GET] = ET.EVENT_LOGIN_REWARD_GET

    self._etable[CMD.EVENT_SCORE_CHANGED] = ET.EVENT_SCORE_CHANGED
    
    self._etable[CMD.WEEK_MONTH_CARD_NOTICE] = ET.WEEK_MONTH_CARD_NOTICE -- 周卡月卡通知

    self._etable[CMD.CMD_COMMON_REWARD_NOTIFY] = ET.COMMON_REWARD_NOTIFY -- 通用小红点通知
    self._etable[CMD.RECEIVE_CHALLENGE_NOTICE_EVT] =  ET.NET_RECEIVE_CHALLENGE_NOTICE_EVT
    self._etable[CMD.WEEK_MONTH_CARD_NOTICE] = ET.WEEK_MONTH_CARD_NOTICE -- 周卡月卡通知
    self._etable[CMD.FRIEND_RECV_INVITE] = ET.NET_FRIEND_RECV_INVITE -- 邀请好友玩游戏通知
    self._etable[CMD.FRIEND_RECV_REFUSE_INVITE] = ET.NET_FRIEND_RECV_REFUSE_INVITE -- 邀请好友玩游戏通知
    self._etable[CMD.SCORE_CLIENT_SHARE] = ET.NET_SCORE_CLIENT_SHARE -- 积分兑换礼物分享通知
    self._etable[CMD.INVITE_CODE_BE_EXCHANGED] = ET.INVITE_CODE_BE_EXCHANGED -- 兑换码被兑换通知
    self._etable[CMD.CMD_EVENT_USER_LOGIN_ELSEWHERE] = ET.EVENT_USER_LOGIN_ELSEWHERE -- 在其他设备上登录，断线重连判断
    
    self._etable[CMD.PRIVATE_DESK_SETTLE] = ET.PRIVATE_DESK_SETTLE_EVT -- 私人定制结算
    self._etable[CMD.DESK_ASK_FEIEND] = ET.NET_DESK_ASK_FEIEND_EVT -- 有人发送加好友请求
    self._etable[CMD.PROFILE_CHANGE] = ET.NET_PROFILE_CHANGE_EVT -- 隐身状态修改广播
    self._etable[CMD.HEAD_UPLOAD_SUCCESS] = ET.NET_HEAD_UPLOAD_SUCCESS_EVT -- 个人头像上传成功通知
    self._etable[CMD.DESK_ASK_FRIENDTIPS] = ET.NET_DESK_ASK_FRIENDTIPS_EVT -- 发送加好友请求反馈

    --self._etable[CMD.CMD_GET_LUCKY_WHEEL_REWARD] = ET.NET_GET_LUCKY_WHEEL_REWARD -- 大厅欢乐转盘

    --global proto end



    

    --MTT

    --用户钻石变化
    self._etable[CMD.USER_DIAMOND_CHANGED] = {
        ET.NET_DIAMOND_CHANGE_GLOBAL_EVT, 
        ET.NET_DIAMOND_CHANGE_USERINFO_EVT,
        ET.NET_DIAMOND_CHANGE_SHOP_EVT,
        ET.NET_DIAMOND_CHANGE_HALL,
        ET.NET_DIAMOND_CHANGE_NIUNIU_HALL
    }
    self._etable[CMD.MTT_FLOAT_REWARD_PUSH_NTF] = ET.MTT_FLOAT_REWARD_PUSH_NTF --浮动奖励发放通知


    --互动表情
    self._etable[CMD.CMD_INTERACT_PHIZ_NTF] = ET.INTERACT_PHIZ_NTF -- 互动表情通知
    self._etable[CMD.PHONE_FIND_PWD] = ET.RESET_PASSWORD    --重置密码
end

function ETAdapter:praseMsg(paras)
    if paras == nil then loge("  error 服务器主动下发消息接收错误 .... ",self.TAG)  return end
    
    if self._etable[paras.cmd] == nil then 
        loge(" error , 未定义的cmd与事件.." ..  paras.cmd ,self.TAG) 
        return 
    end

    qf.event:dispatchEvent(self._etable[paras.cmd],paras)
end

return ETAdapter
