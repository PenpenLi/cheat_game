
local GlobalController = class("GlobalController",qf.controller)
GlobalController.TAG = "GlobalController"

local globalView = import(".GlobalView")
local UserInfo = import(".components.UserInfo")
-- local GiveGiftTip = require("src.modules.global.components.GiveGiftTip")
local CommonTipView = import(".components.CommonTipView")
local CommonTipWindow = import(".components.CommonTipWindow")

-- local GoodDetailView = import("src.modules.shop.components.GoodDetailView")
-- local BuyPopupTipView = import("src.modules.shop.components.BuyPopupTipView")
-- local PayMethodView = import("src.modules.shop.components.PayMethodView")
-- local GiftCardTipView = import("src.modules.gift.components.GiftCardTipView")
local BigHeadImage=require("src.modules.global.components.big_head_image.BigHeadImage")
--------------------------dwc通用组件-------------------------

local ChangePwd = import("src.modules.common.changePwd.ChangePwdView")
local BindCard = import("src.modules.common.bindCard.BindCardView")
local InviteCode = import("src.modules.common.inviteCode.InviteCodeView")
local MessageBox = import("src.modules.common.messageBox.MessageBoxView")
-- local NewAgreement = import("src.modules.common.NewAgreementView")
local NewAcitivy = import("src.modules.common.activity.NewActivityView")
local GameRule = import("src.modules.common.GameRuleView")
local Mail = import("src.modules.common.MailView")
local Guide = import("src.modules.common.GuideView")
local ShopView = import("src.modules.shop.ShopView")
local RetMoneyView = import("src.modules.common.RetMoneyView")

local HongBaoView = import("src.modules.common.HongBaoView")
local AgencyView = import("src.modules.common.AgencyView")
local LuckView = import("src.modules.common.LuckView")
-------------------------------------------------------------

--------------------------dwc业务组件-------------------------
local PersonalInfo = import("src.modules.personal.PersonalView")
local Setting = import("src.modules.setting.SettingView")
local SafeBox = import("src.modules.safeBox.SafeBoxView")
local Custom = import("src.modules.custom.CustomView")
local CustomChat = import("src.modules.customerservice.CustomerServiceChat")
local AgencyAlert = import("src.modules.customerservice.AgencyAlert")
local CommunityView = import("src.modules.customerservice.CommunityView")
local Exchange = import("src.modules.exchange.exchangeView")
local Mail = import("src.modules.common.MailView")
local Maintain = import("src.modules.common.MainTainView")
local HeadMaskShopView = import("src.modules.shop.HeadMaskShopView")
local HeadMaskBagView = import("src.modules.shop.HeadMaskBagView")
local DebugView = import("src.modules.common.DebugView")

if Util:checkInReviewStatus() then
    MessageBox = import("src.modules.common.messageBox.ReviewMessageBoxView")
    ChangePwd = import("src.modules.common.changePwd.ReviewChangePwdView")
    PersonalInfo = import("src.modules.personal.ReviewPersonalView")
    SafeBox = import("src.modules.safeBox.ReviewSafeBoxView")
    Mail = import("src.modules.common.ReviewMailView")
    LuckView = import("src.modules.common.ReviewLuckView")
    Setting = import("src.modules.setting.ReviewSettingView")
    ShopView = import("src.modules.shop.ReviewShopView")
    NewAcitivy = import("src.modules.common.activity.ReviewNewActivityView")
    UserPolicyView = import("src.modules.common.UserPolicyView")
end

-------------------------------------------------------------
function GlobalController:ctor(parameters)
    self.super.ctor(self)
    self.waittingCount = 0
    self.waitting = false
    self.loginWaitting = false
    self._showHallBroadcast = {}
    self._showinGameBroadcast = {}
end

function GlobalController:initModuleEvent()

end

function GlobalController:removeModuleEvent()

end

function GlobalController:initGlobalEvent()
    --获取个人信息
    qf.event:addEvent(ET.GLOBAL_GET_USER_INFO, handler(self, self.processGetUserInfo))
    --显示个人信息
    qf.event:addEvent(ET.GLOBAL_SHOW_USER_INFO, handler(self, self.processShowUserInfo))

    qf.event:addEvent(ET.NET_USER_INFO_REQ,function(paras)
        loga("事件点击的分发1NET_USER_INFO_REQ");
        if paras == nil or paras.uin == nil then return end
        local regInfo = qf.platform:getRegInfo()
        GameNet:send({cmd=CMD.USER_INFO,body={other_uin=paras.uin,channel=regInfo.channel,version=regInfo.version},
            wait=paras.wait,txt=paras.txt,
            callback=function(rsp)
                local is_change_head = false
                if rsp.model then
                    if rsp.model.portrait ~= Cache.user.portrait and paras.uin == Cache.user.uin then
                        is_change_head = true
                    end
                end
                Cache.user:updateCacheByUseInfo(rsp.model,paras.uin)
                qf.event:dispatchEvent(ET.UPDATE_MIAN_USER_INFO)
                if is_change_head then
                    qf.event:dispatchEvent(ET.MAIN_UPDATE_USER_HEAD)
                end
                if(paras.callback) then paras.callback(rsp.model) end
            end})
    end)


    qf.event:addEvent(ET.CHANGE_BORADCAST_DELAYTIME,function(paras) 
        if true then return end
        local time = 0
        if paras == nil or paras.time == nil then time = 0 else time = paras.time end
        if self.view then self.view:changeBoradcastDelayTime(time) end
    end)

    qf.event:addEvent(ET.CHECK_REMOVE_BROAD_CAST,function(paras)
        if self.view and tolua.isnull(self.view) == false then
            self.view:removeBroadCast()
        end
    end)

    qf.event:addEvent(ET.GAME_GENERAL_NOTICE,function(paras)
        if paras.model.command == "GAME_WANT_RECHARGE" then
            self:wantRecharge()
        end
        qf.event:dispatchEvent(ET[paras.model.command])
    end)

    qf.event:addEvent(ET.GET_TIME_REWARD_INFO,handler(self,self.showTimeReward))
    qf.event:addEvent(ET.GET_POCAN_REWARD_INFO,handler(self,self.showPoCanReward))
    qf.event:addEvent(ET.COMMON_REWARD_NOTIFY,handler(self,self.xiaoHongDianRefresh))
    qf.event:addEvent(ET.WEEK_MONTH_CARD_NOTICE,handler(self,self.showWeekMonthPop))

    --刷新道具通知
    qf.event:addEvent(ET.EVENT_USER_DAOJU_CHANGE,handler(self,self.refreshDaoju))

    qf.event:addEvent(ET.SHOW_ACTIVE_NOTICE_VIEW,handler(self,self.showActiveNoticeView))
    qf.event:addEvent(ET.SHOW_ACTIVE_NOTICE,handler(self,self.showActiveNotice))
    qf.event:addEvent(ET.HIDE_ACTIVE_NOTICE,handler(self,self.hideActiveNotice))

    qf.event:addEvent(ET.DAILYREWAED,handler(self,self.dailylogin))

    --送礼申请
    qf.event:addEvent(ET.NET_SEND_GIFT_REQ,handler(self,self.processSendGift))

    qf.event:addEvent(ET.FIRST_PAY,handler(self,self.firstpay))

    qf.event:addEvent(ET.CHAOZHI_PAY,handler(self,self.chaozhipay))

    
    -- 支付loading界面显示
    qf.event:addEvent(ET.EVENT_SHOP_SHOWLOADING, function(paras)
        -- body
        self.view:showPayLoading(paras)
    end) 
    --刷新积分
--    // 事件 cmd 303 score变化
--message EvtScoreChanged {
--    optional int32 gain_score = 1;
--    optional int32 user_score = 2;
--    optional int32 credit_type = 3;  // 1, 2, 3, 4
--}
    qf.event:addEvent(ET.EVENT_SCORE_CHANGED,function(rsp)
        local model = rsp.model
        if model.credit_type == 1 then
            Cache.desk.jifen = rsp.model.gain_score
        elseif model.credit_type == 2 then --BR_JIFEN_EVT
            qf.event:dispatchEvent(ET.BR_JIFEN_EVT,{score = rsp.model.gain_score})
        elseif model.credit_type == 3 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.jifen_add_word..rsp.model.gain_score})
        end
        Cache.user.score = rsp.model.user_score
        logd(pb.tostring(rsp.model))
    end)

	qf.event:addEvent(ET.GLOBAL_WAIT_NETREQ,handler(self,self.processWaitReq))
	qf.event:addEvent(ET.GLOBAL_BROADCAST_TXT,handler(self,self.processBroadcast))
    qf.event:addEvent(ET.NET_BROADCAST_OTHER_EVT,handler(self,self.getBroadcast))
    qf.event:addEvent(ET.NET_LOGIN_NOTICE_EVT,handler(self,self.showDaylyEvent))
    qf.event:addEvent(ET.GLOBAL_TOAST,handler(self,self.showToast))
    qf.event:addEvent(ET.NET_RECEIVE_CHALLENGE_NOTICE_EVT,handler(self,self.processReceiveChallengeNoticeEvt))--5015通知用户是否响应挑战
	qf.event:addEvent(ET.GLOBAL_SHOW_BROADCASE_TXT,handler(self,self._showBroadcast))
    qf.event:addEvent(ET.GLOBAL_SHOW_BROADCASE_LAYOUT,handler(self,self._showBroadcast_layout))
    qf.event:addEvent(ET.GLOBAL_HIDE_BROADCASE_LAYOUT,handler(self,self._hideBroadcast_layout))
	qf.event:addEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,handler(self,self.processCoinAnimation))
    qf.event:addEvent(ET.GLOBAL_COIN_CHARGE_ANIMATION_SHOW,handler(self,self.processChargeCoinAnimation))
    qf.event:addEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, handler(self, self.processDiamondAnimation))
	qf.event:addEvent(ET.GAME_SHOW_SHOP_PROMIT,handler(self,self.processShopPromitShow))

    qf.event:addEvent(ET.GLOBAL_WAIT_EVENT,handler(self,self.processWaitEvent))
    qf.event:addEvent(ET.NET_AUTO_INPUT_ROOM,handler(self,self.processAutoInputRoom))
    
    qf.event:addEvent(ET.GLOBAL_HANDLE_BANKRUPTCY,handler(self,self.processHandlebankruptcy))
    qf.event:addEvent(ET.GLOBAL_HANDLE_WINNINGSTREAK,handler(self,self.processHandlewinningstreak))
    qf.event:addEvent(ET.GLOBAL_HANDLE_PROMIT,handler(self,self.processHandlePromit))
    --破产补助详细信息--
    qf.event:addEvent(ET.NET_COLLAPSE_PAY_REQ,function() 
        GameNet:send({cmd=CMD.COLLAPSE_PAY,txt=GameTxt.net002,
            callback=function(rsp)
                if rsp.ret == 0 and rsp.model ~= nil then
                    Cache.Config:setBankruptcyFetchCount(rsp.model.fetch_count)-- 保存领取破产补助次数         
                    local bankruptcy = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.bankruptcy)
                    if  bankruptcy ~= nil then
                        if rsp.model.fetch_count >= Cache.Config.bankrupt_count or Cache.user.gold > 1000 then
                            if bankruptcy:isVisible() == true then
                                bankruptcy:refreshBankruptcyInfo(rsp.model)
                            else
                                qf.event:dispatchEvent(ET.GLOBAL_SHOW_NEWBILLING,
                                    {room_id = Cache.desk.roomid or 1, ref=UserActionPos.GAME_POCHAN})
                            end
                        else
                            bankruptcy:refreshBankruptcyInfo(rsp.model)
                        end
                    end
                end
            end})
    end)
    --领取救济金请求
    qf.event:addEvent(ET.NET_GET_COLLAPSE_PAY_REQ,function() 
        GameNet:send({cmd=CMD.GET_COLLAPSE_PAY,txt=GameTxt.net002,body={refer=UserActionPos.SHORTCUT_REF},
            callback=function(rsp)
            loga(rsp.ret)
                if rsp.ret == 0 then
                    --qf.platform:umengStatistics({umeng_key = "HelpGold"})
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=GameTxt.global_string108})
                    qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{})
                    qf.event:dispatchEvent(ET.GET_POCAN_REWARD_INFO)
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=Cache.Config._errorMsg[rsp.ret]})
                end
            end})
    end)
    qf.event:addEvent(ET.NET_RECEIVE_GOLD_EVT,function(rsp) --活动送金币通知
        qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{number = 1000})
        if rsp and rsp.model and rsp.model.reward_gold then qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.task003,rsp.model.reward_gold)}) end
        logd(pb.tostring(rsp.model),self.TAG)
    end)

    --收到服务端 更新 活动图标的 消息
    qf.event:addEvent(ET.NET_GET_FINISH_ACTIVITY_EVT,function(rsp)
        Cache.Config.FinishActivityNum = rsp.model.num or 0
        qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="activity",number=Cache.Config.FinishActivityNum})
    end)

    -- 程序切入后台
    qf.event:addEvent(ET.APPLICATION_ACTIONS_EVENT, handler(self, self.processApplicationMessage))
    
    --新的每日登录领取
    qf.event:addEvent(ET.EVENT_LOGIN_REWARD_GET,function(paras)
        local cb
        if paras and paras.cb then cb=paras.cb end
            GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,
                callback= function(rsp)
                    if rsp.ret ~= 0 then
                        --不成功提示
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                    else   -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                        if ModuleManager:judegeIsInMain()==false then return end
                        if rsp.model.got_day_reward == 0 then
                            if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.dailylogin) then 
                                qf.event:dispatchEvent(ET.DAILYREWAED,{method="show",cb=paras.cb})
                            end
                        else
                            qf.event:dispatchEvent(ET.POPLISTPOPUP)
                        end
                        self.view:dailyLoginData(rsp.model)
                        -- qf.event:dispatchEvent(ET.DAILYREWAED,{method="show"})
                    end
                end})
    end)

    --显示最新计费
    qf.event:addEvent(ET.GLOBAL_SHOW_NEWBILLING,function(paras) 
        if self.view == nil or paras == nil then return end
        self.view:showNewBilling(paras)
    end)
    --注销功能
    qf.event:addEvent(ET.GLOBAL_CANCELLATION_BY_REQ,function()
        GameNet:send({cmd=CMD.LOGOUT,callback = function(rsp)
            if rsp.ret == 0 then
                Cache.user.show = nil
                loga("登出返回")
                self:processLogout()
            end
        end})
    end)

    qf.event:addEvent(ET.GET_DAY_LOGIN_REWARD_CFG,handler(self,self.getDayLoginRewardCfg))
    -- qf.event:addEvent(ET.GIVE_GIFT_TIP_EVENT, handler(self, self.showGiveGiftTip))
    qf.event:addEvent(ET.SHOW_COMMON_TIP_EVENT, handler(self, self.showCommonTip))
    qf.event:addEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, handler(self, self.handlerShowTipWindow))
    qf.event:addEvent(ET.EVENT_USER_LOGIN_ELSEWHERE, handler(self, self.userLoginElseWhere))
    	
	--用户信息更改
	qf.event:addEvent(ET.NET_PROFILE_CHANGE_EVT, handler(self, self.processProfileChanged))
	--个人头像上传成功
	qf.event:addEvent(ET.NET_HEAD_UPLOAD_SUCCESS_EVT, handler(self, self.processHeadUpdate))

	--时间宝箱
	qf.event:addEvent(ET.GLOBAL_TIMEBOX_SET, handler(self, self.setTimeBox))
	qf.event:addEvent(ET.GLOBAL_TIMEBOX_GET, handler(self, self.getTimeBox))

    -- 修改备注
    qf.event:addEvent(ET.NET_ALTER_NICK_REMARK, handler(self, self.processChangeRemark))
    --举报
    qf.event:addEvent(ET.EVT_USER_REPORT, handler(self, self.userReport))
    qf.event:addEvent(ET.CLOSE_BEAUTY_GALLERY, handler(self, self.closeBeautyGallery)) --关闭美女大图预览
    qf.event:addEvent(ET.SHOW_SNG_LEVEL_SYSTEM, handler(self, self.showSngLevelSystem)) --sng 等级 

    --[[
        支付/购买相关
    ]]
    qf.event:addEvent(ET.NET_BAROADCAST_DIM_EVT, handler(self, self.recevieDeliveryAdviceNotify))       --充值成功，发货通知
    qf.event:addEvent(ET.REFRESH_BANKRUPTCY_POPUP, handler(self, self.updateBankruptcyPopup))           --充值成功，更新破产补助弹框
    qf.event:addEvent(ET.NET_DIAMOND_CHANGE_GLOBAL_EVT, handler(self, self.userDiamondChangedNotify))   --钻石变更
    qf.event:addEvent(ET.NET_UPDATA_GOLD_EVT, handler(self, self.userGoldChangedNotify))                --金币变更
    qf.event:addEvent(ET.REFRESH_GAME_SHOP_GOLD, handler(self, self.handlerUpdateGameShopGoldNumber))
    -- 打开物品详情框
    -- qf.event:addEvent(ET.EVENT_SHOW_GOOD_DETAIL_VIEW, handler(self, self.handlerShowGoodDetailView))
    -- 打开购买提示框
    -- qf.event:addEvent(ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW, handler(self, self.handlerShowBuyPopupTipView))
    -- 打开支付方式框
    -- qf.event:addEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, handler(self, self.handlerShowPayMethodView))
    -- 打开礼物卡确认提示框
    qf.event:addEvent(ET.EVENT_SHOW_GIFT_CARD_POPUP_TIP_VIEW, handler(self, self.handlerShowGiftCardPopupTipView))
    -- 更新礼物卡确认提示框
    qf.event:addEvent(ET.EVENT_UPDATE_GIFT_CARD_VIEW, handler(self, self.updateGiftCardView))

    qf.event:addEvent(ET.GAME_PAY_NOTICE,handler(self,self.processPayNotice))                           --购买钻石
    qf.event:addEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, handler(self, self.exchangeProductByDiamond)) --用钻石兑换金币/道具
    qf.event:addEvent(ET.USER_ACTION_STATS_EVT, handler(self, self.userActionStatsProcess))             --用户行为统计

    -- 获取牌桌内商城自动选择状态
    qf.event:addEvent(ET.CHIPS_EXCHANGE_CFG, handler(self, self.handlerGetGameShopAutoState))
    -- 设置牌桌内商城自动选择按钮
    qf.event:addEvent(ET.EVENT_CHIPS_EXCHANGE_CFG, handler(self, self.handlerSetGameShopAutoState))
    -- 游戏内商城叶卡跳转
    qf.event:addEvent(ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK, handler(self, self.handlerGameShopJumpToBookmark))
    -- 显示大头像
    qf.event:addEvent(ET.SHOW_BIG_HEAD_IMAGE_EVENT, handler(self, self.handlerShowBigHeadImage))
    --显示大头像
    -- qf.event:addEvent(ET.EVT_SHOW_BIG_PHOTO_ALBUM_VIEW, handler(self, self.handlerShowBigPhotoAlbum))

    --显示登录等待页面
    qf.event:addEvent(ET.LOGIN_WAIT_EVENT, handler(self, self.handlerLoginWait))

    --全局广播浮动奖励发放通知
    qf.event:addEvent(ET.MTT_FLOAT_REWARD_PUSH_NTF, handler(self, self.handlerMTTFloatRewardPushNtf))


    -- 设置广播位置
    qf.event:addEvent(ET.SETBROADCAST, handler(self, self.setBroadCast))

    --安装游戏界面
    qf.event:addEvent(ET.INSTALL_GAME_POP, handler(self, self.installGame))


    -- --安装游戏
    qf.event:addEvent(ET.INSTALL_GAME, handler(self, self.downloadGame))
    qf.event:addEvent(ET.GET_HOT_UPDATA_DATA, handler(self, self.getHotUpdataSize))

    qf.event:addEvent(ET.ADDLISTPOPUP, handler(self, self.ADDLISTPOPUP))
    qf.event:addEvent(ET.POPLISTPOPUP, handler(self, self.POPLISTPOPUP))
    qf.event:addEvent(ET.CLEARLISTPOPUP, handler(self, self.CLEARLISTPOPUP))

    --互动表情显示
    qf.event:addEvent(ET.INTERACTIVE_EXPRESSION, handler(self, self.showInteractiveExpression))
    --互动表情删除
    qf.event:addEvent(ET.INTERACTIVE_EXPRESSION_REMOVE, handler(self, self.removeInteractiveExpression))


    --快捷聊天显示
    qf.event:addEvent(ET.SHOW_QUICKLY_CHAT, handler(self, self.showQuicklyChat))
    --删除快捷聊天
    qf.event:addEvent(ET.REMOVE_QUICKLY_CHAT, handler(self, self.removeQuicklyChat))
    ------------------------通用弹框，背景为黑暗图层--------------------------
    --打开修改密码、设置密码、绑定手机
    qf.event:addEvent(ET.CHANGE_PWD, handler(self, self.showChangePwd))
    --打开绑定银行卡、支付宝
    qf.event:addEvent(ET.BIND_CARD, handler(self, self.showBindCard))
    --打开绑定邀请码
    qf.event:addEvent(ET.INVITE_CODE, handler(self, self.showInviteCode))
    --打开通用提示框
    qf.event:addEvent(ET.MESSAGE_BOX, handler(self, self.showMessageBox))
    --打开商城页面
    qf.event:addEvent(ET.SHOP, handler(self, self.showShop))
    ------------------------------------------------------------------------
    ------------------------业务组件，背景为黑暗图层--------------------------
    --个人中心
    qf.event:addEvent(ET.PERSONAL_INFO, handler(self, self.showPersonalInfo))
    --兑换
    qf.event:addEvent(ET.EXCHANGE, handler(self, self.showExchange))
    --代理消息推送
    qf.event:addEvent(ET.AGENCY_CHAT_PUSH, handler(self, self.showProxcyChatPush))
    --社区
    qf.event:addEvent(ET.SHOW_COMMUNITY_POP, handler(self, self.showCommunityView))
    --客服
    qf.event:addEvent(ET.CUSTOM_CHAT, handler(self, self.showCustomerChat))
    --隐藏客服聊天
    qf.event:addEvent(ET.HIDE_CUSTOM_CHAT, handler(self, self.hideCustom))
    --客服
    qf.event:addEvent(ET.CUSTOM, handler(self, self.showCustom))
    --保险箱
    qf.event:addEvent(ET.SAFE_BOX, handler(self, self.showSafeBox))
    --设置
    qf.event:addEvent(ET.SETTING, handler(self, self.showSetting))
    --协议
    qf.event:addEvent(ET.AGREEMENT, handler(self, self.showAgreementView))
    --隐私策略
    qf.event:addEvent(ET.SHOW_USER_POLICY, handler(self, self.showUserPolicy))
    --新活动
    qf.event:addEvent(ET.NEWACITIVY, handler(self, self.showNewAcitivyView))
    --玩法
    qf.event:addEvent(ET.GAMERULE, handler(self, self.showGameRuleView))
    --邮箱
    qf.event:addEvent(ET.MAIL, handler(self, self.showMailView))
    --新手引导
    qf.event:addEvent(ET.GUIDE, handler(self, self.showGuideView))
    --周返现
    qf.event:addEvent(ET.RETMONEY, handler(self, self.requestShowRetMoneyView))

    --首冲红包
    qf.event:addEvent(ET.HONGBAO, handler(self, self.showHongbaoView))

    --联系代理
    qf.event:addEvent(ET.AGENCY, handler(self, self.clickAgencyBtn))

    --好运来
    qf.event:addEvent(ET.GOOD_LUCK, handler(self, self.clickGoodLuckBtn))

    --停服公告
    qf.event:addEvent(ET.MAIN_TAIN, handler(self, self.showMainTainView))
    

    --停服公告
    qf.event:addEvent(ET.DEBUG_VIEW, handler(self, self.showDebugView))
    
    -- 聊天消息登录
    qf.event:addEvent(ET.SHOW_PROXCY_POP, handler(self,self.showProxcyPopView))

    qf.event:addEvent(ET.CHECK_IF_NEWMESSAGE, handler(self, self.checkNewMessage))

    --钱包记录
    qf.event:addEvent(ET.WALLET, handler(self, self.showWalletRecord))

    -- 头像框购买
    qf.event:addEvent(ET.HEAD_MASK_SHOP, handler(self, self.showHeadMaskShop))

    -- 头像框背包
    qf.event:addEvent(ET.HEAD_MASK_BAG, handler(self, self.showHeadMaskBag))

    ------------------------------------------------------------------------
    --大转盘
    --大转盘配置
    qf.event:addEvent(ET.SHOW_TURNTABLE,function(paras)
        GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,callback= function(rsp)
                if rsp.ret ~= 0 then
                    --不成功提示
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                else   -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                   --[[ optional int32 reward_start_time = 4;            // 抽奖开始时间
                        optional int32 reward_end_time = 5;              // 抽奖结束时间
                        optional int32 is_right_time = 6;                // 当前可抽奖，0 为抽奖时间段 1为不在抽奖时间段--]]
                    local model={}
                    model.reward_start_time=rsp.model.reward_start_time
                    model.reward_end_time=rsp.model.reward_end_time
                    model.is_right_time=rsp.model.is_right_time
                    model.left_time=rsp.model.left_time
                    if paras and paras.cb then model.cb=paras.cb end
                    self:showTurnTable(model)
                end

            end})
    end)
    qf.event:addEvent(ET.REMOVE_TURNTABLE,handler(self,self.removeTurnTable))

    qf.event:addEvent(ET.SHOW_NEWSLEAD,handler(self,self.showNewsLead))--消息引导
    qf.event:addEvent(ET.REMOVE_NEWSLEAD,handler(self,self.removeNewsLead))--消息引导


    --免费金币快捷领取
    qf.event:addEvent(ET.SHOW_FREEGOLDSHORTCUT,function(paras)
        --self.view:showFreeGoldShortCut()
        GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,callback= function(rsp)
                if rsp.ret ~= 0 then
                    --不成功提示
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                else 
                    self.view:showFreeGoldShortCut(rsp.model)
                end

            end})
    end)
    qf.event:addEvent(ET.REMOVE_FREEGOLDSHORTCUT,handler(self,self.removeFreeGoldShortCut))

    qf.event:addEvent(ET.REFRESH_HONGBAO_BTN, handler(self, self.refreshHongBaoBtn))
    qf.event:addEvent(ET.REFRESH_NET_STRENGTH, handler(self, self.refreshNetStrength))

    qf.event:addEvent(ET.NO_GOLD_TO_RECHARGE, handler(self, self.noGoldGuideToChargeAction))
    qf.event:addEvent(ET.OVER_ROOM_MAX_LIMIT, handler(self, self.overRoomMaxLimitAction))
    qf.event:addEvent(ET.QUICK_START_GAME, handler(self, self.quickStartByRequest))
end

function GlobalController:noGoldGuideToChargeAction(paras)
    Util:delayRun(0.25, function ()
        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, {type = 8, cb_consure = function ( ... )
            if paras.confirmCallBack then
                paras.confirmCallBack()
            end
        end ,content = paras.tipTxt, fontsize = 42})
    end)
end

function GlobalController:overRoomMaxLimitAction(paras)
    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, {type = 9, cb_consure = function ( ... )
        if paras.confirmCallBack then
            paras.confirmCallBack()
        end
    end, cb_cancel = function ( ... )
        if paras.cancleCallBack then
            paras.cancleCallBack()
        end
    end,content = GameTxt.string_room_limit_8, fontsize = 42 , is_enabled = false})
end

function GlobalController:quickStartByRequest(paras)
    -- 自动匹配，由外部传roomid，原deskid，走换桌逻辑
    if paras and paras.type == QUICKGAME_TYPE.QUICKMATCH then
        self:quickEnterGame(paras.roomid, paras.src_deskid)
    else
        GameNet:send({cmd = CMD.GLOBAL_QUICK_START_GAME, wait = true ,timeout = 5, callback = function(rsp)
            logd("【请求快速开始】 MainController:quickStartByRequest  rsp.ret = " .. rsp.ret)
            if rsp.ret ~= 0 then 
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end
            dump(rsp.model.room_id)
            if rsp.model then
                self:quickEnterGame(rsp.model.room_id)
            end
        end})
    end
end

function GlobalController:quickEnterGame(roomid, src_deskid)
    self:quickStartGame(roomid, src_deskid)
end

--快速开始逻辑
function GlobalController:quickStartGame(roomid, src_deskid)
    if not roomid then
        loge("【GlobalController】 quickStartGame === >>> roomid is nil")
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.enter_game_fail})
        return
    end

    local chooseGameUniq = Cache.user:getGameUniqByRoomid(roomid)
    --如果没有安装游戏的话
    if not GAME_INSTALL_TABLE[chooseGameUniq] then
        --通知去下载
        if ModuleManager.gameshall.view then
            ModuleManager.gameshall.view:installGame(chooseGameUniq)
        end
        return
    end

    --百人牛牛3倍场和10倍场 roomid，暂时是写死的
    if roomid == 40203 or roomid == 40210 then
        ModuleManager.BrnnHall:remove()
        ModuleManager.gameshall:remove()
        ModuleManager.brniuniugame:show({roomid=roomid})
        return
    end

    --龙虎斗
    if roomid == 40001 then
        ModuleManager:removeExistView()
        ModuleManager.lhdgame:show({name="main"})
        return
    end

    --百人扎金花
    if roomid == 40101 then
        ModuleManager:removeExistView()
        ModuleManager.texasbrgame:show({name="main"})
        return
    end

    local paras = {
        roomid = roomid, 
        src_deskid = src_deskid or 0, 
        dst_desk_id = 0, 
        password = "", 
        enter_source = 101, 
        new_desk = 0, 
        just_view = 0, 
        name = "", 
        must_spend = 0, 
        last_time = 0, 
        buyin_limit_multi = 0, 
    }
    GameNet:send({cmd = CMD.INPUT, body = paras, wait = true ,timeout = 5, callback = function(rsp)
        print("【GlobalController】 quickStartGame=========>>>>> rsp.ret = " .. rsp.ret)
        if rsp.ret ~= 0 then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end

        --炸金牛
        if rsp.model.room_id >= 30001 and rsp.model.room_id <= 30100 then
            ModuleManager:removeExistView()
            ModuleManager.zhajinniugame:show()
            self._changeci_kind = 1
        end
        
        --抢庄牛牛
        if rsp.model.room_id >= 30101 and rsp.model.room_id <= 30200 then
            ModuleManager:removeExistView()
            ModuleManager.login:remove()
            ModuleManager.kancontroller:show({roomid = rsp.model.room_id})
            self._changeci_kind = 2
        end

        --扎金花
        if rsp.model.room_id >= 30201 and rsp.model.room_id <= 30206 then
            ModuleManager:removeExistView()
            ModuleManager.zjhglobal:show()
            ModuleManager.zjhgame:show({roomid=roomid})
        end
    end})
end

--互动表情
function GlobalController:showInteractiveExpression(paras)
    self.view:showInteractiveExpression(paras)
end
--互动表情
function GlobalController:removeInteractiveExpression()
    self.view:removeInteractiveExpression()
end

--添加弹窗队列
function GlobalController:ADDLISTPOPUP(paras)
    if self.poplist == nil then self.poplist = {} end
    local canAddAgainPop={
        {id=ET.SHOW_FRIENDTIPS,popid=PopupManager.POPUPWINDOW.friendtips},
        {id=ET.SHOW_ACTIVE_NOTICE_VIEW,popid=PopupManager.POPUPWINDOW.activeNotice}
    }
    local removePop=true
    local checkNotAddPopupList = function (id)
        for m,n in pairs(canAddAgainPop)do
            if n.id==id then
                removePop=false
                break
            end
        end
        return removePop
    end

    --已经显示出来的就不要再加了
    if paras.popid and PopupManager:getPopupWindow(paras.popid)~=nil and checkNotAddPopupList(paras.id) then
        return
    end
    if #self.poplist>0 then
        for k, v in pairs(self.poplist) do
            if v.id == paras.id then
                if checkNotAddPopupList(v.id)then
                    return
                end
            end
        end
    end

    table.insert(self.poplist,{id=paras.id,priority=paras.priority,name=paras.name,paras=paras})
    table.sort( self.poplist,function (a,b )
        -- body
        return a.priority > b.priority
    end)
end


--添加弹窗队列
function GlobalController:POPLISTPOPUP()
    if not self.poplist or #self.poplist <= 0 then return end

    local i = 1 
    if not PopupManager:checkRemoveBackground() and self.poplist[i] then 
        local v = self.poplist[i]
        local paras =  v.paras ~= nil and  v.paras or {}
        qf.event:dispatchEvent(v.id,paras)
    
        table.remove(self.poplist,i) 
    elseif PopupManager:checkRemoveBackground() then
        PopupManager:downwardAllPopup()
    end 
end

--添加弹窗队列
function GlobalController:CLEARLISTPOPUP()
    self.poplist={}
end


-- --安装游戏

function GlobalController:downloadGame(paras)
    local HotUpdateMainGlobal = require("src.update.HotUpdateMain")
    -- HotUpdateMainGlobal:main()
    HotUpdateMainGlobal:installGame(paras)
end

-- 获取需要更新的文件大小
function GlobalController:getHotUpdataSize(paras)
    local HotUpdateMainGlobal = require("src.update.HotUpdateMain")
    HotUpdateMainGlobal:installGame(paras)
end



--安装游戏界面
function GlobalController:installGame(paras)
    if paras.method == "show" then --展示被踢了界面
        self.view:showInstallGame(paras)
    elseif paras.method == "hide" then --隐藏被踢了界面
        self.view:hideInstallGame()
    end
end

--每日登陆
function GlobalController:dailylogin(paras)
  -- body
    do
        return
    end
  if paras.method == "show" then --展示被踢了界面
        self.view:showDailyLogin(paras)
  elseif paras.method == "hide" then --隐藏被踢了界面
        self.view:hideDailyLogin()
  end

end

-- function GlobalController:showFriendTips(paras)
--     -- body
--     self.view:showFriendTips(paras)
-- end

--首冲
function GlobalController:firstpay(paras)
-- body
    do
    return
    end
    --屏蔽新人大礼包
    if paras.method == "show" then --展示被踢了界面
        self.view:showFirstpay(paras)
    elseif paras.method == "hide" then --隐藏被踢了界面
        self.view:hideFirstpay()
    end

end

-- 超值礼包
function GlobalController:chaozhipay(paras)
  -- body
    do
        return
    end
  if paras.method == "show" then --展示被踢了界面
        self.view:showChaoZhipay(paras)
  elseif paras.method == "hide" then --隐藏被踢了界面
        self.view:hideChaoZhipay()
  end

end

function GlobalController:handlerLoginWait(paras)
    if paras == nil or paras.method == nil or self.view == nil then return end

    if paras.method == "show" then
        self.view:showLoginWait(paras.txt)
    elseif paras.method == "hide" then
        self.view:hideLoginWait()
    end
end

function GlobalController:processApplicationMessage(paras)
    if not paras or not paras.type then return end
    local cache_desk = Cache.DeskAssemble:getCache()

    local deskid = cache_desk and checkint(cache_desk.deskid) or 0
    local roomid = cache_desk and checkint(cache_desk.roomid) or 0
    local game_type = Cache.DeskAssemble:getGameType()

    loga("game_typegame_typegame_typegame_type:".. game_type .. "   roomid =" .. roomid .. "    deskid = " .. deskid)
    if paras.type == "show" then
        local inGame = false
        if (0 < deskid and 0 < roomid) or (Cache.DeskAssemble:judgeGameType(BRC_MATCHE_TYPE)) or (Cache.DeskAssemble:judgeGameType(LHD_MATCHE_TYPE)) or (Cache.DeskAssemble:judgeGameType(BRNN_MATCHE_TYPE)) or Cache.DeskAssemble:judgeGameType(BJL_MATCHE_TYPE) then -- 在房间中
            inGame = true
        elseif Cache.DeskAssemble:judgeGameType(MTT_MATCHE_TYPE) then
            local event_id = checkint(cache_desk:getEventId())
            if event_id > 0 then
                inGame = true
            end
        end

        if Cache.TBZPlayerInfo then
            if Cache.TBZPlayerInfo.Game_Type == 1 then --在推豹子房间中
                inGame = true 
            end 
        end

        if Cache.DDZDesk and Cache.DDZDesk.bFirstStart then
            inGame = true
        end

        if qf.device.platform == "ios" and not MusicPlayer:isPlayMusic() then
            --为了解决cocos2dx的平台适配问题。在IOS平台下会出现后台返回音效消失问题，通过重新实例化SimpleAudioEngine来解决。
            MusicPlayer:stopBackGround()
            MusicPlayer:destroyInstance()
        end

        self:processAudioResumeFromBg(inGame, game_type)
        -- 由于切入后台再切入前台，lua端会删除一部分网络消息，其中包括onDisconnect事件。
        -- 比如 游戏切入后台后，完全断网，隔一段时间后切入前台，就会出现检测不到onDisconnect的情况。所以需要自己判断一下，手工出发一下onDisconnect
        -- 并弹出loading框，进行reconnect
        GameNet:resume()
        if not GameNet:isConnected() then
            -- 后台切回来之后会判断网络状态
            Util:delayRun(0.03,function () -- 解决MI3后台断网重连崩溃bug
                GameNet:onDisconnect()
            end)
        else
            NetDelayTool:startHeartBeatTimeOutCheck()
        end
        if inGame then
            -- 显示等待界面
            -- qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})

            -- 处理各类牌桌后台返回
            if game_type == BRC_MATCHE_TYPE then                --百人场
                self:_processBRGameResume()
            elseif game_type == BRNN_MATCHE_TYPE then           --百人牛牛
                self:_processBRNNGameResume(roomid, deskid)
            elseif game_type == LHD_MATCHE_TYPE then            --龙虎斗
                self:_processLHDGameResume(roomid, deskid)
            elseif game_type == GAME_TBZ then                   --退豹子
                self:_processTBZGameResume(roomid, deskid)
            elseif game_type == GAME_NIU_ZHA then               --炸金牛
                self:_processZJNGameResume(roomid, deskid)
            elseif game_type == GAME_NIU_KAN then               --看牌抢庄
                self:_processNIUKANGameResume(roomid, deskid)
            elseif game_type == GAME_ZJH then                   --炸金花
                self:_processZJHGameResume(roomid, deskid)
            elseif game_type == GAME_DDZ then                   --斗地主
                self:_processDDZGameResume(roomid, deskid)
            end
        else
            qf.event:dispatchEvent(ET.APPLICATION_RESUME_NOTIFY, {})    --不在游戏内的其他模块需要处理后台返回，可以处理此消息
        end

        if inGame then
            Cache.user.come_back =true
        else
            Cache.user.come_back =false
        end
        self:refreshShopView()
        self:refreshCustomerChatList()
    elseif paras.type == "hide" then
        self:processAudioPauseToBg()
        GameNet:pause()
    else
    end
end

--将来可能要针对很多页面做这种切后台的处理来进行刷新
function GlobalController:refreshShopView()
    local view = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newShop)
    if view then
        view:refreshView()
    end
end

--切换后台刷新客服聊天数据
-- 1.这时候消息是收到的，但是因为在后台界面没有刷新
function GlobalController:refreshCustomerChatList( ... )
    local view = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat)
    if view then
        view:refreshChatList(true)
    end
end

function GlobalController:_processLHDGameResume( ... )
    logd("_processLHDGameResume:")
    ModuleManager.lhdgame:remove(PopupManager.POPUPWINDOW.customerServiceChat)

    local name = "gameshall"
    ModuleManager:removeExistView()
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    local function _queryDesk( ... )
        GameNet:send({cmd= CMD.LHD_QUERY_PLAYER_DESK, body={room_id=roomid,desk_id=deskid},callback=function ( rsp )
            logd("龙虎斗查询桌子 rsp.ret=" .. rsp.ret)
            if rsp.ret == 0 then 
                Cache.user.come_back = true --记录从后台切换回来
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                ModuleManager.lhdgame:show({name=name})
                ModuleManager.lhdgame:handlerInputGameNtf(rsp)
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                Util:delayRun(0.5, function( ... )
                    _queryDesk()
                end)
            else -- 查询失败，退桌
                --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
                if rsp.ret ~= 14 then
                    Util:delayRun(1.5,function ()
                        if LHD_CMD then
                            qf.event:dispatchEvent(LHD_CMD.LHD_GAME_EXIT_DESK,{send=false})
                        end
                        ModuleManager.gameshall:show({stopEffect = true})
                        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                    end)
                end
                
            end
        end})
    end
    _queryDesk()
end

function GlobalController:_processZJHGameResume( roomid, deskid  )
    -- body
    logd("_processZJHGameResumeroomidroomidroomidroomidroomid:"..roomid)
    logd("deskiddeskiddeskiddeskiddeskiddeskid:"..deskid)
    ModuleManager:removeExistView()
    local tipContent = GameTxt.gameLoaddingTips001[math.random(1, #GameTxt.gameLoaddingTips001)] or ""
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=tipContent})

    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    local function _queryDesk( ... )
    GameNet:send({cmd=Zjh_CMD.QUERY_DESK, body={room_id=roomid,desk_id=deskid},callback=function ( rsp )
        logd("GlobalController:_processZJHGameResume:"..rsp.ret)
        if rsp.ret == 0 then 
            Cache.user.come_back = true --记录从后台切换回来
            -- qf.event:dispatchEvent(Niuniu_ET.NET_INPUT_REQ,{roomid = roomid})
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
            ModuleManager.zjhglobal:show()
            ModuleManager.zjhgame:show({name="gameshall",roomid=roomid})
            ModuleManager.zjhgame:enterRoomsuc(rsp)

            -- ModuleManager.tbzgame:show({name="tbzlobby"})
            
        elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
            Util:delayRun(0.5, function( ... )
                _queryDesk()
            end)
        else -- 查询失败，退桌
            --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
            if rsp.ret ~= 14 then
                Util:delayRun(1.5,function ()
                    qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                    ModuleManager.gameshall:show({stopEffect = true})
                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                end)
            end
        end
    end})
    end
    _queryDesk()
end


function GlobalController:_processNIUKANGameResume( roomid, deskid  )
    -- body
    ModuleManager:removeExistView()
    local tipContent = GameTxt.gameLoaddingTips001[math.random(1, #GameTxt.gameLoaddingTips001)] or ""
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=tipContent})

    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    local function _queryDesk( ... )
        GameNet:send({cmd=Niuniu_CMD.KAN_QUERY_DESK, body={room_id=roomid,desk_id=deskid},callback=function ( rsp )
            if rsp.ret == 0 then 
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                Cache.user.come_back = true --记录从后台切换回来
                ModuleManager.kancontroller:show({name="gameshall"})
                ModuleManager.kancontroller:enterRoomsuc(rsp)
                
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                Util:delayRun(0.5, function( ... )
                    _queryDesk()
                end)
            else -- 查询失败，退桌
                --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
                if rsp.ret ~= 14 then
                    Util:delayRun(1.5,function ()
                        qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                        ModuleManager.gameshall:show({stopEffect = true})
                        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                    end)
                end
            end
        end})
    end
    _queryDesk()


end

function GlobalController:_processZJNGameResume( roomid, deskid  )
    -- body
    ModuleManager:removeExistView()
    local tipContent = GameTxt.gameLoaddingTips001[math.random(1, #GameTxt.gameLoaddingTips001)] or ""
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=tipContent})

    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    local function _queryDesk( ... )
    GameNet:send({cmd=Zhajinniu_CMD.QUERY_DESK,  body={room_id=roomid,desk_id=deskid},callback=function ( rsp )

        if rsp.ret == 0 then 
            Cache.user.come_back = true --记录从后台切换回来
            -- qf.event:dispatchEvent(Niuniu_ET.NET_INPUT_REQ,{roomid = roomid})
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
            ModuleManager.zhajinniugame:show({name="gameshall"})
            ModuleManager.zhajinniugame:enterRoomsuc(rsp)

            -- ModuleManager.tbzgame:show({name="tbzlobby"})
            
        elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
            Util:delayRun(0.5, function( ... )
                _queryDesk()
            end)
        else -- 查询失败，退桌
            --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
            if rsp.ret ~= 14 then
                Util:delayRun(1.5,function ()
                    qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                    ModuleManager.gameshall:show({stopEffect = true})
                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                end)
            end
        end
    end})
    end
    _queryDesk()
end

function GlobalController:_processNIUZHAGameResume( roomid, deskid  )
    -- body
    ModuleManager:removeExistView({"customerServiceChat"})
    local tipContent = GameTxt.gameLoaddingTips001[math.random(1, #GameTxt.gameLoaddingTips001)] or ""
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=tipContent})

    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    local function _queryDesk( ... )
    GameNet:send({cmd=Niuniu_CMD.QUERY_DESK,  body={room_id=roomid,desk_id=deskid},callback=function ( rsp )

        if rsp.ret == 0 then 
            Cache.user.come_back = true --记录从后台切换回来
            -- qf.event:dispatchEvent(Niuniu_ET.NET_INPUT_REQ,{roomid = roomid})
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
            ModuleManager.niuniugame:show({name="gameshall"})
            ModuleManager.niuniugame:enterRoomsuc(rsp)

            -- ModuleManager.tbzgame:show({name="tbzlobby"})
            
        elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
            Util:delayRun(0.5, function( ... )
                _queryDesk()
            end)
        else -- 查询失败，退桌
            --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
            Util:delayRun(1.5,function ()
                qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                ModuleManager.gameshall:show({stopEffect = true})
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
            end)
        end
    end})
    end
    _queryDesk()
end

function GlobalController:_processTBZGameResume( roomid, deskid )
    -- body
    ModuleManager.tbzgame:remove()
    local tipContent = GameTxt.gameLoaddingTips001[math.random(1, #GameTxt.gameLoaddingTips001)] or ""
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=tipContent})

    local function _queryDesk( ... )
        GameNet:send({cmd=Tbz_CMD.CMD_TBZ_QUERY_PLAYER_DESK ,callback=function ( rsp )
            if rsp.ret == 0  then
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                ModuleManager.DDZgame:show({name="tbzlobby"})
                ModuleManager.DDZgame:EvtJoinRoom(rsp) 
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                Util:delayRun(0.5, function( ... )
                    _queryDesk()
                end)
            else
                Util:delayRun(1.5,function ()
                    Cache.TBZPlayerInfo.Game_Type = -1
                    ModuleManager.gameshall:show()
                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                end) 
            end
        end})
    end
    _queryDesk()
end

function GlobalController:_processDDZGameResume( roomid, deskid )
    -- body
    loga("_processDDZGameResumeroomidroomidroomidroomidroomid:"..roomid)
    loga("deskiddeskiddeskiddeskiddeskiddeskid:"..deskid)
    --如果这个
    if Cache.DDZDesk.bFirstStart or Cache.DDZDesk.gameOverFlag  then
        MusicPlayer:setBgMusic(string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType))
        MusicPlayer:playBackGround()
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
        return
    end
    ModuleManager.DDZgame:remove()
    local tipContent = GameTxt.gameLoaddingTips001[math.random(1, #GameTxt.gameLoaddingTips001)] or ""
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=tipContent})

    local function _queryDesk( ... )
        GameNet:send({cmd=DDZ_CMD.QUERY_DESK ,callback=function ( rsp )
            if rsp.ret == 0  then
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                ModuleManager.DDZgame:show({name="gameshall"})
                ModuleManager.DDZgame:enterRoom(rsp) 
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                Util:delayRun(0.5, function( ... )
                    _queryDesk()
                end)
            else
                if rsp.ret ~= 14 then
                    Util:delayRun(1.5,function ()
                        qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                        ModuleManager.gameshall:show({stopEffect = true})
                        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})

                        --游戏打完了，被踢出桌子了
                        MusicPlayer:stopBackGround()
                        MusicPlayer:setBgMusic()
                        MusicPlayer:playBackGround()
                    end) 
                end
            end
        end})
    end
    _queryDesk()
end

function GlobalController:_processNormalGameResume(roomid, deskid)       
    local name = ModuleManager.texasgame:getPreviousModuleName()
    ModuleManager.texasgame:remove()
    
    --支付后台切回来 刷新个人金币(SNG场不兑换金币, 百人场金币全部兑换成筹码，所以只有经典场需要刷新金币)
    local function _refreshGold(gold)  
        local num =  gold - Cache.user.gold
        if num >0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.task003,num)})
        end
        Cache.user.gold = gold              
    end

    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    local function _queryDesk( ... )
        GameNet:send({cmd=CMD.QUERY_DESK_ON_SHOW, body={room_id=roomid,desk_id=deskid},callback=function ( rsp )
            if rsp.ret == 0 then 
                Cache.user.come_back = true --记录从后台切换回来
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                _refreshGold(rsp.model.gold)
                ModuleManager.texasgame:show({name=name})
                ModuleManager.texasgame:processInputGameEvt(rsp)
                self:refreshDiamondReenterDesk(rsp.model.diamond)   --重新进桌后刷新钻石
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                Util:delayRun(0.5, function( ... )
                    _queryDesk()
                end)
            else -- 查询失败，退桌
                --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
                Util:delayRun(1.5,function ()
                    qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                    ModuleManager.gameshall:show({stopEffect = true})
                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                end)
            end
        end})
    end
    _queryDesk()
end

function GlobalController:_processBRGameResume(roomid, deskid)
    local name = "gameshall"
    ModuleManager.texasbrgame:remove(PopupManager.POPUPWINDOW.customerServiceChat)
    ModuleManager:removeExistView()
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    local function _queryDesk( ... )
        GameNet:send({cmd=CMD.CMD_BR_QUERY_PLAYER_DESK_V2, body={room_id=roomid,desk_id=deskid},callback=function ( rsp )
            if rsp.ret == 0 then 
                Cache.user.come_back = true --记录从后台切换回来
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                ModuleManager.texasbrgame:show({name=name})
                ModuleManager.texasbrgame:brprocessInputGameEvt(rsp)
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                Util:delayRun(0.5, function( ... )
                    _queryDesk()
                end)
            else -- 查询失败，退桌
                --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
                if rsp.ret ~= 14 then
                    Util:delayRun(1.5,function ()
                        if BR_ET then
                            qf.event:dispatchEvent(BR_ET.BR_EXIT_REQ,{send=false})
                        end
                        ModuleManager.gameshall:show({stopEffect = true})
                        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                    end)
                end
            end
        end})
    end
    _queryDesk()

end

function GlobalController:_processBRNNGameResume(roomid, deskid)
    local name = "gameshall"
    ModuleManager.brniuniugame:remove(PopupManager.POPUPWINDOW.customerServiceChat)
    ModuleManager:removeExistView()
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
    --查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
    --如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
    logd("_processBRNNGameResume roomid=" .. Cache.BrniuniuDesk.roomid)
    local function _queryDesk( ... )
        local cmd = Cache.BrniuniuDesk:getRoomType() == 14 and BRNN_CMD.CMD_BR_BULL_QUERY_PLAYER_DESK_V3 or BRNN_CMD.CMD_BR_BULL_QUERY_PLAYER_DESK_V10
        GameNet:send({cmd = cmd, body={room_id=roomid,desk_id=deskid},callback=function ( rsp )
            if rsp.ret == 0 then 
                Cache.user.come_back = true --记录从后台切换回来
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                ModuleManager.brniuniugame:show({name=name})
                ModuleManager.brniuniugame:brprocessInputGameEvt(rsp)
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                Util:delayRun(0.5, function( ... )
                    _queryDesk()
                end)
            else -- 查询失败，退桌
                --**这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
                if rsp.ret ~= 14 then
                    Util:delayRun(1.5,function ()
                        if BR_ET then
                            qf.event:dispatchEvent(BRNN_ET.BR_EXIT_REQ,{send=false})
                        end
                        ModuleManager.gameshall:show({stopEffect = true})
                        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                    end)
                end
            end
        end})
    end
    _queryDesk()
end

--用户信息变更广播处理(消息分发)
function GlobalController:processProfileChanged(paras)
	if paras == nil or paras.model == nil then return end
	logd("用户隐身广播(506)\n"..pb.tostring(paras.model))
    local cache_desk = Cache.DeskAssemble:getCache()
    local user=cache_desk:getUserByUin(paras.model.uin)
    local userinfo_view = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.userinfo)--中途更改数据 通知个人资料卡
    if userinfo_view ~= nil then
        if userinfo_view.uin==paras.model.uin then 
            local nickName = Util:showUserName(paras.model.nick)
            userinfo_view.real_hiding=paras.model.hiding
            userinfo_view.real_nick=nickName
            userinfo_view.real_portrait=paras.model.portrait
            if paras.model.hiding==1 then --如果打开隐身
                userinfo_view.hide_nick=nickName
            end
            userinfo_view:setBreakHideName(nickName)
        end
    end
    if user and user.be_antit and paras.model.hiding==1 then --如果这个在这个玩家被破隐且是改成隐身状态时则屏蔽这个玩家的修改
       return
    end
	if paras.model.uin == Cache.user.uin then
		Cache.user:updateCacheByProfileChange(paras.model)	--更新缓存
	end
	qf.event:dispatchEvent(ET.PROFILE_CHANGE_GAME_EVT, paras.model)		--游戏中处理用户信息变更
end

--头像上传成功通知(消息分发)
function GlobalController:processHeadUpdate(paras)
	if paras == nil or paras.model == nil then return end
	logd("头像上传成功通知(507)\n"..pb.tostring(paras.model))
	Cache.user.portrait = paras.model.portrait
	--用户信息编辑界面头像刷新
	qf.event:dispatchEvent(ET.CHANGE_VIEW_UPDATE_USER_HEAD)
	--主界面头像刷新
	qf.event:dispatchEvent(ET.MAIN_UPDATE_USER_HEAD)
    qf.event:dispatchEvent(ET.UPDATE_CHOSEHALL_HEADIMG)
end

function GlobalController:wantRecharge()
    if not Util:isHasReviewed() then return end
    if ModuleManager:judegeIsInShop() then
        local shopView = ModuleManager["shop"]:getView()
        shopView:webviewExit()
        return 
    end
    -- qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name = "shop",delay = 0,cb = function() end})
    qf.event:dispatchEvent(ET.SHOP)
    qf.platform:removeWebView()
end

function GlobalController:processHandlePromit(paras)
    if paras.type == 1 then --弹出公共提示框
        self.view:showGlobalPromit(paras.body)
    elseif paras.type == 2 then --隐藏公共提示框
        self.view:hideGlobalPromit()
    end
end

function GlobalController:processHandlebankruptcy(paras)
    if paras.method == "show" then --展示破产界面
        self.view:showBankruptcy(paras)
    elseif paras.method == "hide" then --隐藏破产界面
        self.view:hideBankruptcy()
    elseif paras.method == "update" then --更新破产界面
        self.view:updateBankruptcy(paras.type)
    end
end

function GlobalController:processHandlewinningstreak(paras)
    if paras.method == "show" then --展示连赢界面
        --self.view:showWinningStreak(paras)
    elseif paras.method == "hide" then --隐藏连赢界面
        self.view:hideWinningStreak()
    end
end

function GlobalController:processAutoInputRoom()
    print("断线重连. roomid="..Cache.user.old_roomid..", event_id="..Cache.user.event_id..", gametype="..Cache.user.room_type..", old_roomid="..Cache.user.old_roomid)
    print("断线重连. roomid="..Cache.user.old_roomid..", event_id="..Cache.user.event_id..", gametype="..Cache.user.room_type..", old_roomid="..Cache.user.old_roomid)
    if Cache.user.old_roomid > 0 then
        if Cache.user.room_type == RoomType.BR then
            qf.event:dispatchEvent(ET.NET_BR_INPUT_REQ,{})
            ModuleManager:removeExistView()
            ModuleManager.texasbrgame:show({name="main"})
        elseif Cache.user.room_type == RoomType.SNG then
            qf.event:dispatchEvent(ET.NET_SNG_INPUT_REQ,{body = {roomid = Cache.user.old_roomid}})
        elseif Cache.user.room_type == RoomType.TBZ then
                
             qf.event:dispatchEvent(Tbz_ET.Join_Tuibaozi,{roomid = Cache.user.old_roomid})
        --炸金花
        elseif Cache.user.room_type == RoomType.ZJH then

            GameNet:send({cmd=CMD.CONFIG,body = {timestamp = "",os = qf.device.platform},
                callback=function(rsp)
                    if rsp.ret ~= 0 then
                        return 
                    end
                    Cache.zhajinhuaconfig:saveConfig(rsp.model)
                end
            })
             
            qf.event:dispatchEvent(Zjh_ET.KAN_NET_INPUT_REQ,{roomid = Cache.user.old_roomid})
        --龙虎斗
        elseif Cache.user.room_type == RoomType.LHD then
            qf.event:dispatchEvent(LHD_ET.NET_LHD_INPUT_REQ,{roomid = 0})
            ModuleManager:removeExistView()
            --ModuleManager.lhdgame:getView()
            ModuleManager.lhdgame:show({name="main"})
        --斗地主
        elseif Cache.user.room_type == RoomType.DDZ then
            GameNet:send({cmd=CMD.CONFIG,body = {timestamp = "",os = qf.device.platform},
                callback=function(rsp)
                    if rsp.ret ~= 0 then
                        return 
                    end
                    Cache.DDZconfig:saveConfig(rsp.model)
                end
            })
             
            qf.event:dispatchEvent(DDZ_ET.KAN_NET_INPUT_REQ,{roomid = Cache.user.old_roomid})

        --百人牛牛3,10倍场
        elseif Cache.user.room_type == RoomType.BRNN_V3 or Cache.user.room_type == RoomType.BRNN_V10 then
            loga(">>>>>>百人牛牛断线重连" .. Cache.user.old_roomid)
            qf.event:dispatchEvent(BRNN_ET.NET_BR_BULL_INPUT_REQ,{roomid = Cache.user.old_roomid, roomType = Cache.user.room_type})
            ModuleManager:removeExistView()
            Cache.BrniuniuDesk:setRoomID(Cache.user.old_roomid)
            ModuleManager.brniuniugame:show({name="main", roomType = Cache.user.room_type})
        else
            if Cache.user.old_roomid >= 30001 and Cache.user.old_roomid <= 30100 then
                if  Cache.zhajinniudesk.status then
                    GameNet:send({cmd=CMD.CONFIG,body = {timestamp = "",os = qf.device.platform},
                        callback=function(rsp)
                            if rsp.ret ~= 0 then
                                return 
                            end
                            Cache.zhajinniuconfig:saveConfig(rsp.model)
                        end
                    })
                end
               qf.event:dispatchEvent(Niuniu_ET.NET_INPUT_REQ,{roomid = Cache.user.old_roomid})
            elseif Cache.user.old_roomid > 30100 and Cache.user.old_roomid < 30200 then
                if  Cache.kandesk.status then
                    GameNet:send({cmd=CMD.CONFIG,body = {timestamp = "",os = qf.device.platform},
                        callback=function(rsp)
                            if rsp.ret ~= 0 then
                                return 
                            end
                            Cache.kanconfig:saveKanConfig(rsp.model)
                        end
                    })
                end
                qf.event:dispatchEvent(Niuniu_ET.KAN_NET_INPUT_REQ,{roomid = Cache.user.old_roomid})
            else
                qf.event:dispatchEvent(ET.NET_INPUT_REQ,{roomid = Cache.user.old_roomid})
            end        
        end
    elseif Cache.user.event_id > 0 then
        qf.event:dispatchEvent(ET.EVENT_MTT_GAME_BEGIN_NOTIFY, {event_id=Cache.user.event_id})
    else
        --如果之前没在牌桌内再要判断有没有在MTT大厅内
        qf.event:dispatchEvent(ET.APPLICATION_RESUME_NOTIFY)
        Cache.user.reConnect_status = false

    end

    self:checkIsTerminationExitMTT(Cache.user.event_exit_reason)
end
--检查是否是异常退出MTT：旁观时断网重连回来牌桌被拆、赛事结束
function GlobalController:checkIsTerminationExitMTT( reason )
    if not reason then return end

    local content
    if reason == SERVER_REASON.USER_EXIT_REASON_MTT_EVENT_TEAR_DESK then -- 旁观时桌子被拆，转到其他桌子继续旁观
        content = GameTxt.mtt_tip_termination_1
    elseif reason == SERVER_REASON.USER_EXIT_REASON_MTT_EVENT_END then --赛事已结束
        content = GameTxt.mtt_tip_termination_2
    else
        return
    end
    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, {type=3, content=content})
end
function GlobalController:processWaitEvent (paras) 
    if paras == nil or paras.method == nil or self.view == nil then return end

    if paras.method == "show" then
        self.view:showFullWait(paras)
    elseif paras.method == "update" then 
        self.view:updateFullWait(paras.txt)
    elseif paras.method == "hide" then
        self.view:hideFullWait()
    end
end

function GlobalController:processChargeCoinAnimation( paras )
    MusicPlayer:playMyEffect("PENG") 
    self.view:showChargeCoinAnimation(paras)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
end

function GlobalController:processCoinAnimation ( paras )
    MusicPlayer:playMyEffect("TASK_GOLD")
	self.view:showCoinAnimation(paras)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
end

--[[
    播放得到钻石动画.
    参数: diamond, 得到的钻石. free, 免费的钻石
]]
function GlobalController:processDiamondAnimation(paras)
    MusicPlayer:playMyEffect("DIAMOND_POPUP")
	self.view:showDiamondAnimation(paras)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
end


function GlobalController:processShopPromitShow(paras)
    self.view:showShopPromit(paras)
end

--[[
    payType 0代表商城支付
            1代表促销方式
            2代表游戏内主动点击 快捷支付
            3代表进入房间时 金额不足弹出的支付
            4代表游戏内 金额不足被踢起 时提醒支付
        （payType仅用于umeng统计）
]]
function GlobalController:processPayNotice(paras)
    if qf.device.platform == "ios" then
        qf.event:dispatchEvent(ET.EVENT_SHOP_SHOWLOADING,{isVisible = true})
    end
    --调用 Android 或者 iso的支付接口
    paras.payType = paras.payType or 0 --如果没有传递支付类型 默认是从商城过来的支付
    paras.cb = handler(self,self.payCallBack)
    paras.ref = paras.ref or UserActionPos.SHOP_REF
    --支付信息备份
    self.pay_record = {}
    self.pay_record.paymethod = paras.paymethod --支付方式
    self.pay_record.refer = paras.ref           --ref id
    self.pay_record.buy_diamond = paras.diamond --买入钻石
    self.pay_record.return_diamond = paras.return_diamond or 0   --返还钻石
    --开始支付
    paras.return_diamond = nil
    qf.platform:allPay(paras)
end
--[[-- 
    resultCoden 0支付成功  1支付成功显示等待服务端回调进度条
    --]]
function GlobalController:payCallBack(paymethod, paras)
    if qf.device.platform == "ios" then
        qf.event:dispatchEvent(ET.EVENT_SHOP_SHOWLOADING,{isVisible = false})
    end
    local paras = qf.json.decode(paras)
    local resultCode = tonumber((paras.resultCode or 0))
    paras.payType = tonumber(paras.payType or 0)
    if resultCode == 0 then
        Util:delayRun(0.4,function ( sender )
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            if paymethod == PAYMETHOD_APPSTORE then
                --ios支付弹窗会导致网络消息堆积,这里在游戏内则重新进桌
                qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT,{type="show"})
            end
        end)
    elseif resultCode == 1 then
        Util:delayRun(0.1,function ( sender )
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.net006})
        end)
    else
        Util:delayRun(0.1,function ( sender )
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            if paymethod == PAYMETHOD_APPSTORE then
                --ios支付弹窗会导致网络消息堆积,这里在游戏内则重新进桌
                qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT,{type="show"})
            end
        end)
    end
end

--这里是服务器推送消息数据过来的逻辑
function GlobalController:processBroadcast(paras)
    local item = {}
    item = paras
    
    local function updateBroadData(broadcast)
        table.insert(broadcast,item)
        if #broadcast >20 then --超过限制条数就移除旧的消息
            table.remove(broadcast,1)
        end
        Cache.wordMsg:sortMsgByRule(broadcast)
    end

    if paras.forHall == 1 then
        updateBroadData(self._showHallBroadcast)
    end

    if paras.forGame == 1 then
        updateBroadData(self._showinGameBroadcast)
    end

    local customerChatView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat)
    if paras.forCustomer == 1 then
        if customerChatView then
            customerChatView:showScrollMessage(item)
        end
    end

    if self._showBroadcastIng ~= true and not self.view.isRuning then
        if paras.forHall == 1 then
            self:showBroadcastInHall()
        end
        if paras.forGame == 1 then
            self:showBroadcastInGame()
        end
        if paras.forCustomer == 1 then
            self:showBroadcastInCustomer(paras)
        end
    end
end

--游戏牌桌内
function GlobalController:showBroadcastInGame ()
    print("【GlobalController】 ===== 游戏内广播 =======")
    if not ModuleManager:judegeIsIngameWithBorad() then return end
    self._showBroadcastIng = false
    for k,v in pairs(self._showinGameBroadcast) do
        self.view:showBoradcastTxt_inGame(v)
        table.remove(self._showinGameBroadcast,1) 
        break
    end
end

--大厅展示
function GlobalController:showBroadcastInHall( ... )
    print("【GlobalController】 ===== 大厅广播 =======")
    if ModuleManager:judegeIsIngameWithBorad() then
        return 
    end
    self._showBroadcastIng = false
    for k,v in pairs(self._showHallBroadcast) do
        self.view:showBoradcastTxt_inGame(v)
        table.remove(self._showHallBroadcast,1) 
        break
    end
end

--客服通知展示
function GlobalController:showBroadcastInCustomer(paras)
    print("【GlobalController】 ===== 客服广播 =======")
    local serviceChat = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat)
    if serviceChat then
        serviceChat:showScrollMessage(paras)
    end
end

--这里是内部界面跳转展示广播
function GlobalController:_showBroadcast()
    --游戏内
    if ModuleManager:judegeIsIngameWithBorad() then
        self:showBroadcastInGame()
    --其他的就是大厅
    else
        self:showBroadcastInHall()
    end
end

--设置广播位置
function GlobalController:setBroadCast(paras)
    qf.event:dispatchEvent(ET.CHECK_REMOVE_BROAD_CAST)
    self.view:setBroadCast(paras)
end

function GlobalController:_showBroadcast_layout ()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    if self.view.isRuning then
        self.view:showBoradcast()
    end
end
function GlobalController:_hideBroadcast_layout()
    self.view:hideBoradcast()
end

function GlobalController:getBroadcast(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then return end
    paras = paras.model
    logd(pb.tostring(paras),self.TAG)
    logd(paras.content,self.TAG)
    logd(paras.nick,self.TAG)
    local isRealGoldChannel = Cache.packetInfo:isRealGold()
    local paras_contents = isRealGoldChannel and paras.contents or paras.shelf_contents
    local paras_content = isRealGoldChannel and paras.content or paras.shelf_content
    local paras_new_content = isRealGoldChannel and paras.new_content or paras.shelf_new_content
    -- 这里兼容下后台配置的广播
    if paras_content == "" or paras_new_content == "" then
        paras_contents = paras.contents
        paras_content = paras.content
        paras_new_content = paras.new_content
    end
    local level = paras.level or 4
    local msgItem = {}
    msgItem.time = os.time()
    msgItem.level = paras.level
    msgItem.nick = paras.nick
    msgItem.content = paras_content
    msgItem.new_content = paras_new_content
    msgItem.contents = {}
    msgItem.contents["str1"] = paras_contents["str1"]
    msgItem.contents["str2"] = paras_contents["str2"]
    msgItem.contents["str3"] = paras_contents["str3"]
    msgItem.contents["str4"] = paras_contents["str4"]
    msgItem.forGame = paras.gb_game or 0
    msgItem.forCustomer = paras.gb_customer or 0
    msgItem.forHall = paras.gb_hall or 0
    --只有500的广播才会走其他的
    if paras.level ~= 500 then
        msgItem.forHall = 1
    end
    Cache.wordMsg:saveMsg(msgItem)
    
    qf.event:dispatchEvent(ET.GLOBAL_BROADCAST_TXT,msgItem)
end

--loading
function GlobalController:processWaitReq(paras)
	paras = paras or {}
	local method = paras.method or "none"
	local txt = paras.txt or "waitting..."
    
    if method == "add" then 
        
        if paras.reConnect == 1 then
            if self.loginWaitting == false then
                self.view:addWaitting({txt = txt,reConnect = paras.reConnect})
                self.loginWaitting = true
            end
        else
            self.waittingCount = self.waittingCount + 1
            if self.waitting == false then
                self.view:addWaitting({txt = txt})
                self.waitting = true
            end
        end
        
    elseif method == "remove" then 
        if paras.reConnect == 1 then
            if self.loginWaitting == true then 
                self.view:removeWaitting(paras.reConnect)
                self.loginWaitting= false
            end
        elseif paras.hard == true then  --强制性解除loading
            self.view:removeWaitting("hard")
            self.waitting= false
        else
            self.waittingCount = self.waittingCount <= 0 and 0 or self.waittingCount - 1
            if self.waitting == true and self.waittingCount == 0 then 
                self.view:removeWaitting()
                self.waitting= false
            end
         end
    else
    end
end

function GlobalController:showDaylyEvent(paras)
    if paras == nil or paras.ret ~= 0 or paras.model == nil then return end
    if self.view == nil then return end
    self.view:showDayEvent(paras.model)
    --logd(pb.tostring(paras.model),self.TAG)
end

function GlobalController:showToast(paras)
    if self.view then self.view:showToast(paras) end 
end

function GlobalController:initView(parameters)
    local view = globalView.new()
    return view
end
function GlobalController:refreshDaoju(paras)
    if paras.model == nil then
    	return
    end
    local name = paras.model.name
    local num = paras.model.amount
    if name == "little_horn" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.buySuccess..num..GameTxt.LabaShopTxt})
    elseif name == "vip_card" then	--VIP卡发货，更新主界面的用户信息
		if paras.model.vip_days ~= nil and paras.model.vip_days > 0 then
			Cache.user.vip_days = paras.model.vip_days
			qf.event:dispatchEvent(ET.GLOBAL_FRESH_MAIN_GOLD)
		end
    elseif name == "anti_stealth_card" then  --破隐卡发货，更新主界面的用户信息
            Cache.user.anti_stealth = paras.model.remain
    end
end

function GlobalController:showWeekMonthPop(paras)
    if paras.model == nil then return end
    if self.view then 
        local data = paras.model
        self.view:showWeekMonthReward(data)
    end
end

function GlobalController:showTimeReward()
    GameNet:send({cmd=CMD.CMD_QUERY_SCHED_REWARD,txt=GameTxt.net002,
        callback=function(rsp)
                if rsp.ret == 0 and rsp.model ~= nil then

                    local freeGold = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.freeGold)
                    if freeGold then
                       freeGold:showTimeReward(rsp.model)
                    end
                else
                     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end})
end

function GlobalController:showPoCanReward()
    GameNet:send({cmd=CMD.CMD_QUERY_BROKE_SUPPLY,txt=GameTxt.net002,
        callback=function(rsp)
                if rsp.ret == 0 and rsp.model ~= nil then
                    local freeGold = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.freeGold)
                    if freeGold then
                       freeGold:showPoCanReward(rsp.model)
                    end
                else
                     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end})
end

function GlobalController:xiaoHongDianRefresh(paras)
    qf.event:dispatchEvent(ET.FRIEND_RED_POINT,paras)
    if self.view then self.view:xiaoHongDianRefresh(paras) end
end

function GlobalController:showActiveNotice(paras)
     qf.event:dispatchEvent(ET.NET_ALL_ACTIVITY_REQ,{cb = function(model)        
        local len = model.activities:len()
        local showNum = 0
        for i=1,len do
            local item = {}
            item.show_board = model.activities:get(i).show_board
            item.page_url = model.activities:get(i).page_url
            item.board_type = model.activities:get(i).board_type
            item.id = model.activities:get(i).id
            item.board_url = model.activities:get(i).board_url
            if  item.show_board == 1 then
                qf.event:dispatchEvent(ET.ADDLISTPOPUP,{id=ET.SHOW_ACTIVE_NOTICE_VIEW,model=item,priority=1})
            end
        end
        if showNum > 0 then

        else
            qf.event:dispatchEvent(ET.AUTO_SHOW_FREE_GOLD)
            qf.event:dispatchEvent(ET.POPLISTPOPUP)
        end
    end}) 
end

function GlobalController:showActiveNoticeView(paras)
    if self.view then self.view:showActiveNotice(paras.model) end
end

function GlobalController:hideActiveNotice()
    if self.view then self.view:hideActiveNotice(paras) end
end

function GlobalController:getDayLoginRewardCfg()

    GameNet:send({cmd=CMD.GET_DAY_LOGIN_REWARD_CFG,wait=true,txt=GameTxt.net002,
            callback=function(rsp)
                if rsp.ret == 0 and self.view then
                    self.view:setDayLoginRewardCfg(rsp.model)
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=Cache.Config._errorMsg[rsp.ret]})
                end
            end})
end

-- -- 显示送礼物二次提示view
-- function GlobalController:showGiveGiftTip( paras )
--     local _tipView = GiveGiftTip.new(paras)
--     _tipView:show()
-- end

--显示通用提示框
function GlobalController:showCommonTip(paras)
    if paras.blur == true then
        -- local _tipView = GiveGiftTip.new(paras)
        -- _tipView:show()
    else
        local _tipView = CommonTipView.new(paras)
        if self.view then 
            self.view:addChild(_tipView)
            _tipView:show()
        end
    end
end

function GlobalController:handlerShowTipWindow( args )
    local tipWindow = CommonTipWindow.new(args)
    tipWindow:show()
end

-- 用户在别处登录，断线重连判断
function GlobalController:userLoginElseWhere( paras )
    BOL_AUTO_RE_CONNECT = false -- 设置不自动重连
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN) -- 登录方式设置为0，表示没有登录
    cc.UserDefault:getInstance():flush()
    -- ModuleManager:removeExistView()
    game.cancellationLogin()
    qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
end

--时间宝箱控制. opcode定义: TimeBoxOpcode
function GlobalController:setTimeBox(paras)
	if self.view and paras ~= nil and paras.opcode ~= nil then
		self.view:setTimeBox(paras)
	end
end
--获取时间宝箱信息
function GlobalController:getTimeBox()
	if self.view then
		return self.view:getTimeBox()
	else
		return nil
	end
end


-- 删除存在的View
function GlobalController:removeExistView()
    if self.view then
        self.view:removeExistView()
    end
end
function GlobalController:processChangeRemark(paras)
     local info={}
      info.uin=paras.uin
      info.nick=paras.remark_name
      GameNet:send({ cmd = CMD.ALTERNICKREMARK ,body = {remark=info}, callback = function(rsp)
           
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
            else   
             if  rsp.model then 
                  logd(pb.tostring(rsp.model))
                  qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =GameTxt.string_global_1,time = 2})
             end

            end
        end
        })

end

function GlobalController:processAudioResumeFromBg(inGame, gameType)
    if qf.device.platform == "ios" and not MusicPlayer:isPlayMusic() then
        --为了解决cocos2dx的平台适配问题。在IOS平台下会出现后台返回音效消失问题，通过重新实例化SimpleAudioEngine来解决。
        MusicPlayer:stopBackGround()
        MusicPlayer:destroyInstance()
    end
    if inGame == false then
        MusicPlayer:setBgMusic()
        --登陆播放音效
        if not ModuleManager:judegeIsInLogin() then
            MusicPlayer:playBackGround()
        end
    end
end

function GlobalController:processAudioPauseToBg()
    MusicPlayer:stopBackGround()
end

function GlobalController:userReport(paras)
    if paras== nil then return end
        GameNet:send({ cmd = CMD.USER_REPORT ,body = {uin =  paras.uin  ,type = paras.type , reason = paras.reason}, callback = function(rsp)
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
            else   
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =GameTxt.send_report_ok})
            end
        end
        })
end


function GlobalController:processLogout()
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    cc.UserDefault:getInstance():setStringForKey("loginBody", "")
    cc.UserDefault:getInstance():flush()
    MusicPlayer:setBgMusic()
    MusicPlayer:stopBackGround()
    PopupManager:removeAllPopup()
    ModuleManager:removeSubGameHall()
    ModuleManager:removeSubGames()
    ModuleManager:removeByCancellation()
    game.cancellationLogin()
    --登出一定要退回loginview
    --qf.event:dispatchEvent(ET.LOGIN_NET_GOTO_LOGIN)
end

--获取个人信息
function GlobalController:processGetUserInfo(paras)
    qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{
        uin = paras.uin,
        wait = false,
        txt = GameTxt.login001,
        callback = function(model) 
            if paras.cb then
                xpcall(paras.cb({model = model}),function()end) 
            end 
        end
    })
end

--显示个人信息
function GlobalController:processShowUserInfo(parameters)
    --qf3改为个人信息和别人信息统一为不可编辑的UI
    -- if parameters.uin == Cache.user.uin then    
    --     ModuleManager.change_userinfo:remove()
    --     local view = ModuleManager.change_userinfo:getView({name="change_userinfo0",isedit=parameters.isedit,localinfo=parameters.localinfo,cb=parameters.cb})
    --     Display:showScalePop({view=view})
    -- else
            -- qf.event:dispatchEvent(ET.GLOBAL_GET_USER_INFO, {uin = parameters.uin, cb = function(paras) 
            --     if paras == nil or paras.model == nil then return end
            --     local userInfo = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.userinfo)
            --     if userInfo then
            --         userInfo:initView(paras)
            --     end
            -- end})
    GameNet:send({cmd=CMD.USER_INFO,body={other_uin=parameters.uin},
    wait=false,txt="",
    callback=function(rsp)
        local userInfo = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.userinfo)
        if not userinfo then
            userInfo = UserInfo.new(parameters)
            userInfo:show(parameters)
        end
        userInfo:initView(rsp)
    end})
end
function GlobalController:closeBeautyGallery(paras)
    if self.view  then 
      self.view:removeChildByTag(self.view.bigPhotoTag)
    end
end

--钻石购买成功，发货通知
function GlobalController:recevieDeliveryAdviceNotify(paras)
    if paras ~= nil and paras.model ~= nil then
        local item_id = paras.model.item_id
        local isBygGold = nil
        if IsInTable(item_id,Cache.PayManager:getPayGoldList()) then
            isBygGold = true
            if item_id == Cache.PayManager:getPayGoldList()[1] then
                qf.event:dispatchEvent(ET.FIRST_PAY, {method = "hide"})
                Cache.user.first_recharge_flag = 0
            else
                qf.event:dispatchEvent(ET.chaozhipay, {method = "hide"})
                Cache.user.first_recharge_flag = 2
            end
            qf.event:dispatchEvent(ET.UPDATE_PAY_LIBAO)
        end
        --弹出获取钻石弹框
        local got_diamond = paras.model.recharge_diamond or 0
        local return_diamond = paras.model.return_diamond or 0
        --安卓支付成功返回后会黑屏，似乎是播放声音时的问题，暂时通过延时解决
        Util:delayRun(1,function()
                qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond=got_diamond, free=return_diamond,isBygGold=isBygGold})
            end)
        --购买成功后更新默认的支付方式
        if self.pay_record ~= nil and self.pay_record.paymethod ~=nil then
            Cache.QuickPay:setDefaultPayMethod(self.pay_record.paymethod)
        end
    end
end

--钻石购买成功，更新破产补助
function GlobalController:updateBankruptcyPopup()
    qf.event:dispatchEvent(ET.GLOBAL_HANDLE_BANKRUPTCY, {method="update", type=Cache.QuickPay.JUDGE_ENOUGH.DIAMOND_ENOUGH})
end

--钻石更改通知
function GlobalController:userDiamondChangedNotify(paras)
    if paras ~= nil and paras.model ~= nil and paras.model.remain_diamond ~= nil then
        --更新用户钻石数量
        local remain_diamond = paras.model.remain_diamond
        Cache.user:updateUserDiamond(remain_diamond)
    end
end

--游戏内从后台返回
function GlobalController:refreshDiamondReenterDesk(diamond)
    if diamond == nil or diamond <= 0 then return end
    local org_diamond = Cache.user.diamond          --记录原用户钻石
    local got_diamond = diamond - org_diamond       --获取到的钻石
    Cache.user:updateUserDiamond(diamond)           --更新用户钻石数量
    --没有得到钻石或者没有支付记录，不进行下面的支付处理
    if got_diamond <= 0 or self.pay_record == nil or self.pay_record.paymethod == nil or self.pay_record.refer == nil 
        or self.pay_record.buy_diamond == nil or self.pay_record.return_diamond == nil then 
        return
    end
    --更新支付方式
    Cache.QuickPay:setDefaultPayMethod(self.pay_record.paymethod)
    --钻石弹框
    local buy_diamond, return_diamond = 0, 0
    if (self.pay_record.buy_diamond + self.pay_record.return_diamond ) == got_diamond then  --与支付数据对的上，显示购买+返还
        buy_diamond = self.pay_record.buy_diamond
        return_diamond = self.pay_record.return_diamond
    else    --与支付数据对不上，直接显示多出的钻石
        buy_diamond = got_diamond
    end
    qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond=buy_diamond, free=return_diamond})
end

--金币更改通知
function GlobalController:userGoldChangedNotify(paras)
    local gold = Cache.user.gold
    local old_gold = clone(gold)
    if paras.model == nil and paras.gold ~= nil then
        gold = paras.gold
    elseif paras.model ~= nil and paras.model.gold ~= nil then
        gold = paras.model.gold
    end
    Cache.user:updateUserGold(Cache.packetInfo:getProMoney(gold))

    --破产时用户在领取补助或在其他地方获得金币时，跳动金币变成跳动筹码
    if ModuleManager:judgeIsInNormalGame() and old_gold < 200 then
        if not Util:judgeIsBankruptcy() then
            qf.event:dispatchEvent(ET.GAME_SHOW_BOUNCE_BTN,{type="shopPromit"})
        end
    end
    if paras.model ~= nil and paras.model.gold ~= nil and paras.model.reason == "10" then
        qf.platform:print_log(tostring(qf.platform:isApplicationInBackground()))
        if qf.platform:isApplicationInBackground() then
            qf.event:dispatchEvent(ET.GLOBAL_COIN_CHARGE_ANIMATION_SHOW, {txt = GameTxt.charge_success})
        end
        if not Cache.packetInfo:isRealGold() then
            Cache.PayManager.product_info:updateAppStoreProductFirstBuyStatus(function ()
                if ModuleManager.shop then
                    ModuleManager.shop:refreshUI()
                end
            end)
        end
        
    end
    --更新MTT大厅界面的金币显示
    qf.event:dispatchEvent(ET.GLOBAL_FRESH_MTTLOBBY_GOLD)
end

--使用钻石兑换金币/道具
function GlobalController:exchangeProductByDiamond(paras)
    if paras == nil or paras.item_name == nil then return end
    local ref = paras.ref or UserActionPos.SHOP_REF --购买场景默认为商城
    GameNet:send({cmd = CMD.PRODUCT_EXCHANGE_BY_DIAMOND,
        body = { item_id=paras.item_name, refer=ref } ,
        callback = function(rsp)
            --根据item_id获取商品名称
            local product_name = Cache.PayManager:getDisplayNameByItemName(paras.item_name)
            --成功/失败提示
            local msg = ""
            if rsp.ret == 0 then
                msg = string.format(GameTxt.exchange_product_success_tip, product_name)
                if paras.cb then paras.cb(true) end
                qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{number = 1000})
            else
                msg = Cache.Config._errorMsg[rsp.ret] or string.format(GameTxt.exchange_product_failed_tip, product_name)
                if paras.cb then paras.cb(false) end
            end
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = msg})
        end
    })
end

-- 显示物品详情
function GlobalController:handlerShowGoodDetailView( args )
    local goodView = GoodDetailView.new(args)
    goodView:show()
end

-- 购买物品提示框
function GlobalController:handlerShowBuyPopupTipView( args )
    local buyTipView = BuyPopupTipView.new(args)
    buyTipView:show()
end

-- 打开支付方式框
function GlobalController:handlerShowPayMethodView( args )
    local payMethodView = PayMethodView.new(args)
    payMethodView:show()
end

-- 礼物卡使用提示框
function GlobalController:handlerShowGiftCardPopupTipView( args )
    local gold_expand = 0
    if args.id then
        gold_expand = Cache.giftInfo:getGiftPriceById(args.id) or 0
        if args.num then
            gold_expand = gold_expand*args.num
        end
    elseif args.price then
        gold_expand = args.price
    else 
        return
    end
    if gold_expand == 0 then return end
    local gift_card_sum = Cache.user:getGiftCardSum() or 0
    if gold_expand <= gift_card_sum then
        local giftCardTipView = GiftCardTipView.new(args)
        giftCardTipView:show()
    else
        local cb = args.cb
        if cb then cb(0) end
    end
end

-- 礼物卡提示界面更新
function GlobalController:updateGiftCardView()
    local giftCardTipView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.giftCardTipView)
    if giftCardTipView then
        giftCardTipView:updateGiftExpend()
    end
end

--[[
    用户行为上报
    qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {
        ref=UserActionPos.ROOM_SIT_LACK, 
        currency=PAY_CONST.CURRENCY_GOLD})
]]
function GlobalController:userActionStatsProcess(paras)
    if paras == nil or paras.ref == nil then return end
    xpcall(
        function()
            local refer_id = paras.ref
            local currency_type = paras.currency or PAY_CONST.CURRENCY_GOLD
            GameNet:send({cmd = CMD.PUSH_USER_ACTION_STATS, body = {refer = refer_id, type = currency_type}})
        end,
        function() 
            logd("数据上报出错")
        end
    )
end


-- function GlobalController:showSngLevelSystem(paras)
--     local  sngLevel = SNGLevel.new({})
--     sngLevel:show()
-- end

--显示大头像
function GlobalController:handlerShowBigHeadImage(paras)
    if self.view then
        local big_node = BigHeadImage.new(paras)
        self.view:addChild(big_node,0,self.view.bigPhotoTag)
    end
end
--显示大相册
-- function GlobalController:handlerShowBigPhotoAlbum( args )
--     if not self.view or tolua.isnull(self.view) then return end

--     self.view:showBigPhotoAlbum(args)
-- end

function GlobalController:handlerMTTFloatRewardPushNtf(paras)
    if paras == nil or paras.model == nil then return end

    local event_id = paras.model.event_id
    local event_name = paras.model.event_name
    local result = paras.model.result
    local reward = {}
    reward.gold = result.award --奖励金币, 浮动奖励的金币＝总的参赛费x浮动奖励比例
    reward.jifen = result.master_credit --奖励竞技分
    reward.coupon_id = result.coupon_id --兑换券ID, 大于0是有效对兑换券ID
    reward.coupon_name = result.coupon_name --兑换券名称
    reward.coupon_num = result.coupon_num --兑换券数量
    reward.ticket_id = result.ticket_id --门票ID,大于0才是有效对门票ID
    reward.ticket_name = result.ticket_name --门票名称
    reward.ticket_num = result.ticket_num --门票数量

    local str = ""
    if reward.gold and reward.gold > 0 then
        str = Util:getFormatString(reward.gold)..GameTxt.global_string113
    end
    if reward.jifen and reward.jifen > 0 then
        if str ~= "" then str = str.."、" end
        str = str..reward.jifen..GameTxt.mtt_lobby_string_12
    end
    if reward.coupon_id and reward.coupon_id > 0 then
        if str ~= "" then str = str.."、" end
        str = str..reward.coupon_name.."x"..reward.coupon_num
    end
    if reward.ticket_id and reward.ticket_id > 0 then
        if str ~= "" then str = str.."、" end
        str = str..reward.ticket_name.."x"..reward.ticket_num
    end
    local content = GameTxt.mtt_lobby_string_38..event_name..GameTxt.mtt_lobby_string_39..str
    local cb_consure = function()
        if Cache.DeskAssemble:judgeGameType(MTT_MATCHE_TYPE) then
            local desk_event_id = Cache.mttDesk:getEventId()
            if event_id == desk_event_id then
                local settle_view = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.mttSettle) 
                if not settle_view then
                    qf.event:dispatchEvent(ET.MTT_GAME_EXIT, {send=true, from="mtt_lobby"})--返回大厅
                end 
            end
        end
    end
    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, {type=3, cb_consure=cb_consure, content=content, auto_type=1, auto_time=10})
end

function GlobalController:showQuicklyChat(paras)
    -- body
    self.view:showQuicklyChat(paras)
end

function GlobalController:removeQuicklyChat(paras)
    -- body
--    self.view:removeQuicklyChat()
end

--找回密码、设置密码、绑定手机
function GlobalController:showChangePwd( paras )
    -- body
    local changePwdView = ChangePwd.new(paras)
    changePwdView:show(paras)
end

--商城
function GlobalController:showShop(paras)
    if not Util:isHasReviewed() then return end
    -- if Cache.user:isBindPhone() then
        if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newShop) then
            return
        end
        
        local shopView = ShopView.new(paras)
        shopView:show()
    -- else
    --     --商城未绑定手机的情况下  绑定手机后 直接弹商城页面
    --     qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 4, notTip = true, cb = function ( ... )
    --         local view = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.changePwd)
    --         if tolua.isnull(view) == false then
    --             view:close()
    --         end
    --         qf.event:dispatchEvent(ET.SHOP)
    --     end})
    -- end
end


--绑定银行卡、支付宝
function GlobalController:showBindCard( paras )
    -- body
    local BindCardView = BindCard.new(paras)
    BindCardView:show(paras)
end

  -- body
function GlobalController:showInviteCode( paras )
    local InviteCodeView = InviteCode.new(paras)
    InviteCodeView:show(paras)
end

--通用提示框
function GlobalController:showMessageBox( paras )
    -- body
    local MessageBoxView = MessageBox.new(paras)
    MessageBoxView:show(paras)
end

--协议
function GlobalController:showAgreementView(paras)
    -- body
    local NewAgreementView = NewAgreement.new(paras)
    NewAgreementView:show()
end

--隐私策略
function GlobalController:showUserPolicy(paras)
    local UserPolicyModule = UserPolicyView.new(paras)
    UserPolicyModule:show()
end

function GlobalController:showNewAcitivyView(paras)   
    GameNet:send({cmd = CMD.NEW_GONGGAO,callback = function(rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        Cache.activityInfo:refreshNoticeData(rsp.model)
        if #Cache.activityInfo.all_notice > 0  then
            if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newActivity) then
                local NewAcitivyView = NewAcitivy.new(paras)
                NewAcitivyView:show()        
            end
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_global_2})
        end
    end})
end

function GlobalController:showGameRuleView(paras)     
    local GameRuleView = GameRule.new(paras)
    GameRuleView:show()
end

function GlobalController:showMailView(paras)  
    if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.mailView) then
        return
    end
    local MailView = Mail.new(paras)
    MailView:show()
end

function GlobalController:showGuideView(paras) 
    local GuideView = Guide.new(paras)
    GuideView:show(self.view)
end

function GlobalController:showRetMoneyView(paras)
    if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.retMoneyView) then
        return
    end
    local view = RetMoneyView.new(paras)
    view:show()
end

function GlobalController:requestShowRetMoneyView(paras)
    Cache.retmoneyInfo:sendRetMoneyReq(function (data)
        self:showRetMoneyView({data = data})
    end)
end

-- function GlobalController:showBindRewardView(paras)
--     local view = BindRewardView.new(paras)
--     view:show()
-- end

function GlobalController:showHongbaoView(paras)
    Cache.hongbaoInfo:queryFirstRecharge(function (data)
        paras = paras or {}
        local showFlag = true
        if paras then
            -- 如果已经首冲过了，就不展示了
            if data.is_recharge == 1 then
                showFlag = false
            end
            if paras.bForeShow then
                showFlag = true
            end
        end
        if showFlag then
            paras.data = data
            if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.hongbaoView) then
                return
            end
            local view = HongBaoView.new(paras)
            view:show()
        else
            -- 特殊处理下，如果是pop队列里面的，如果发现不需要展示，那么继续下一个
            if paras and paras.bPopList then
                qf.event:dispatchEvent(ET.POPLISTPOPUP)
            end
        end
    end)
end


function GlobalController:showAgencyView(paras)
    local view = AgencyView.new(paras)
    view:show()
end

function GlobalController:clickAgencyBtn()
    if Cache.agencyInfo:checkBindAgency() or Cache.user:isProxy() then --绑定了邀请码 或者 是代理的情况展示联系代理页面
        Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
            self:showAgencyView(data)
        end)
    else
        Cache.agencyInfo:requestGetAgencyInfo2({}, function ()
            self:showAgencyView()
        end)
    end
end

function GlobalController:clickGoodLuckBtn()
    --代理情况下 不允许看界面
    if Cache.user:isProxy() then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_luck_16})
    elseif Cache.agencyInfo:checkBindAgency() or Util:checkInReviewStatus() then --绑定了代理的情况下 直接弹出好运来
        self:showGoodLuckView()
    else --未绑定代理的情况下 打开好运来 弹出绑定邀请码弹窗
        Cache.agencyInfo:requestGetAgencyInfo2({}, function ()
            self:showAgencyView({from = "LuckBtn", cb = function ()
                self:showGoodLuckView()
            end})
        end)
    end
end

function GlobalController:showGoodLuckView(paras)
    local view = LuckView.new(paras)
    view:show(paras)
end

function GlobalController:showMainTainView(paras)
    local view = Maintain.new(paras)
    view:show()
end

function GlobalController:showWalletRecord(paras)
    local view = WalletView.new(paras)
    view:show()
end

function GlobalController:showHeadMaskShop(paras)
    if Cache.user:isProxy() then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_luck_16})
        return
    end
    local view = HeadMaskShopView.new(paras)
    view:show()
end

function GlobalController:showHeadMaskBag(paras)
    local view = HeadMaskBagView.new(paras)
    view:show()
end

function GlobalController:showDebugView(paras)
    local view = DebugView.new(paras)
    view:show(paras)
end

--个人中心
function GlobalController:showPersonalInfo(paras)
    local PersonalView = PersonalInfo.new(paras)
    PersonalView:show(paras)
end

--保险箱
function GlobalController:showSafeBox( paras )
    if not Cache.user:isBindPhone() then
        qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 4})
        return
    end
    --没设置安全密码跳安全密码界面
    if Cache.user.safe_password == 0 then
        qf.event:dispatchEvent(ET.CHANGE_PWD,{actType = 1, showType = 5})
        return
    end
    if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.safeBox) then
        return
    end
    -- body
    local SafeBoxView = SafeBox.new(paras)
    SafeBoxView:show(paras)
end

function GlobalController:showProxcyChatPush(paras)
    if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.agencyAlert) then
        return
    end
    local agencyAlertView = AgencyAlert.new(paras)
    agencyAlertView:show()
end

function GlobalController:showCommunityView(paras)
    if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.communityView) then
        return
    end
    local cusCommunityView = CommunityView.new(paras)
    cusCommunityView:show()
end

function GlobalController:showProxcyPopView(paras)
    if not paras then return end
    if not paras.message then return end
    -- 如果是代理发来的消息，加入大厅弹框队列
    if not Cache.user:isCustomerService(paras.message.uin) and paras.message.msg_type ~= GameConstants.ChatMsgType.MSG_PIC_BRIEF and paras.message.uin ~= Cache.user.uin and paras.message.is_welcome == 0 then
        Cache.cusChatInfo:updateUnReadMessage(paras.message)
        if ModuleManager:judegeIsInMain() then
            if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat) then
                if paras.addListPopup then
                    qf.event:dispatchEvent(ET.ADDLISTPOPUP,{id=ET.AGENCY_CHAT_PUSH,priority=2,data = paras.message})
                    -- 没有其他弹框时，需要主动弹出来
                    Util:delayRun(0.25, function ( ... )
                        if #self.poplist == 1 then
                            qf.event:dispatchEvent(ET.POPLISTPOPUP)
                        end
                    end)
                else
                    qf.event:dispatchEvent(ET.AGENCY_CHAT_PUSH, {data = paras.message})
                end
            end
            Cache.cusChatInfo:clearUnReadMessage(2)
        end
    end

    -- 如果是代理图片消息
    if paras.message.msg_type == GameConstants.ChatMsgType.MSG_PIC_BRIEF and not Cache.user:isCustomerService(paras.message.uin) and paras.message.is_welcome == 0 then
        Cache.cusChatInfo:updateUnReadMessage(paras.message)
        local chatServiceView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat)
        --只在大厅
        if ModuleManager:judegeIsInMain() and not chatServiceView then
            ModuleManager.gameshall:refreshCustomeMessageStatus()
        end
    end

    -- 客服聊天消息
    if Cache.user:isCustomerService(paras.message.uin) then
        Cache.cusChatInfo:updateUnReadMessage(paras.message)
        local chatServiceView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat)
        --只在大厅
        if ModuleManager:judegeIsInMain() and not chatServiceView then
            ModuleManager.gameshall:refreshCustomeMessageStatus()
        end
        --在大厅而且在代理聊天界面
        if ModuleManager:judegeIsInMain() and chatServiceView and chatServiceView.forceLinkType == GameConstants.ChatUserType.PROXCY then
            chatServiceView:refreshCustomerRad()
        end
    end
end

function GlobalController:checkIfHasNewCustomerMsg( ... )
    local customMessage = Cache.cusChatInfo:getUnReadMessage(1)
    return customMessage and true or false
end

function GlobalController:checkNewMessage( ... )
    local refreshCustomerMsgStatusFunc = function ( ... )
        ModuleManager.gameshall:refreshCustomeMessageStatus()
    end
    local customMessage = Cache.cusChatInfo:getUnReadMessage(1)
    local proxcyMessage = Cache.cusChatInfo:getUnReadMessage(2)
    if ModuleManager:judegeIsInMain() and proxcyMessage then
        if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat) then
            if proxcyMessage.msg_type == GameConstants.ChatMsgType.MSG_PIC_BRIEF then
                refreshCustomerMsgStatusFunc()
            else
                if not Cache.user:isProxy() then
                    qf.event:dispatchEvent(ET.AGENCY_CHAT_PUSH, {data = proxcyMessage})
                end
            end
        end
        Cache.cusChatInfo:clearUnReadMessage(2)
    end

    if customMessage then
        refreshCustomerMsgStatusFunc()
    end
end

--展示客服聊天
function GlobalController:showCustomerChat(paras)
    --版本兼容
    if Util:checkNotUpdatePackage() then
        self:showCustom()
        return
    end

    local showCustomViewFunc = function (showParas)
        if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat) then
            return
        end
        local customChatView = CustomChat.new(showParas)
        customChatView:show()
    end

    local showFunc = function (showParas)
        if showParas.forceLinkType then
            -- 客服埋点
            GameNet:send({cmd = CMD.QUERY_CHAT_INFO,body = {refer = showParas.forceLinkType}})
            if Cache.user.invite_from > 0 then
                Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
                    showCustomViewFunc(showParas)
                end)
            else
                showCustomViewFunc(showParas)
            end
        end
    end

    if paras.autoLink then
        if Cache.user:getCommunityStatus() == 1 then
            qf.event:dispatchEvent(ET.SHOW_COMMUNITY_POP)
        else
            -- 默认是官方客服
            paras.forceLinkType = GameConstants.ChatUserType.OFFICIAL
            --普通用户绑定代理
            if not Cache.user:isProxy() and tonumber(Cache.user.invite_from) > 0 then
                paras.forceLinkType = GameConstants.ChatUserType.PROXCY
                local proxcyDataId = Cache.cusChatInfo:getLastChatProxcyDataId()
                if proxcyDataId > 0 then
                    Cache.agencyInfo:getServiceInfoByID(proxcyDataId, function (data)
                        paras.data = data
                        showFunc(paras)
                    end)
                else
                    showFunc(paras)
                end
            else
                showFunc(paras)
            end
        end
    else
        showFunc(paras)
    end
    
end

--客服
function GlobalController:showCustom( paras )
    if PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat) then
        return
    end
    local CustomView = Custom.new(paras)
    CustomView:show()
end

function GlobalController:hideCustom( paras )
    if Cache.user:getCommunityStatus() == 0 then
        local customerChatView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.customerServiceChat)
        if customerChatView then
            customerChatView:close()
        end
    else
        local cusCommunityView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.communityView)
        if cusCommunityView then
            cusCommunityView:close()
        end
    end
    
end

--设置
function GlobalController:showSetting( paras )
    -- body
    local SettingView = Setting.new(paras)
    SettingView:show(paras)
end

--兑换
function GlobalController:showExchange( paras )
    -- body
    local ExchangeView = Exchange.new(paras)
    ExchangeView:show(paras)

end

--大转盘显示
function GlobalController:showTurnTable(paras)
    -- body
    self.view:showTurnTable(paras)
end

--大转盘删除
function GlobalController:removeTurnTable(paras)
    -- body
    self.view:removeTurnTable(paras)
end

--累计登陆显示
function GlobalController:showNewTotalLogin(paras)
    -- body
    self.view:showNewTotalLogin(paras)
end

--累计登陆删除
function GlobalController:removeNewTotalLogin(paras)
    -- body
    self.view:removeNewTotalLogin(paras)
end

--消息引导显示
function GlobalController:showNewsLead(paras)
    -- body
    self.view:showNewsLead(paras)
end

--消息引导删除
function GlobalController:removeNewsLead(paras)
    -- body
    self.view:removeNewsLead(paras)
end

function GlobalController:processSendGift(paras)
    if paras == nil or paras.uin == nil or paras.giftId == nil then return end
    local myboad= {to_uin = paras.uin,gift_id = paras.giftId}
    if paras.mes then
        if string.len(paras.mes)>0 then
            myboad= {to_uin = paras.uin,gift_id = paras.giftId,words=paras.mes}
        end
    end
    if paras.from_record then
        myboad.from_record=paras.from_record
    end
    myboad.using_gift_card = paras.using_gift_card
    GameNet:send({cmd = CMD.SEND_GIFT,wait = true,txt=GameTxt.main001,body = myboad,callback = function(rsp)    
        if(rsp.ret == 0)then
            if myboad and myboad.using_gift_card == 1 then
                qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin})
            end
            qf.platform:umengStatistics({umeng_key = "Gift",umeng_value = paras.giftId})
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string863,time = 2})
            if paras.cb then paras.cb() end
        else

            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
        end
    end})
end

--由于红包是每个页面都有 所以统一处理比较好
function GlobalController:refreshHongBaoBtn()
    local moduelName = {
        "gameshall" --大厅
        -- "texasbrgame", -- 百人场 
        -- "brniuniugame",  --百人牛牛
        -- "lhdgame",  -- 龙虎斗
        -- "kancontroller",  --牛牛
        -- "zjhgame"  --炸金花
    }

    for i, v in ipairs(moduelName) do
        local ctrl = ModuleManager[v]
        if ctrl then
            local view = ctrl.view
            print(v)
            if view and tolua.isnull(view) == false then
                print("refreshHongBaoBtn >>>>>>>>>>>")
                view:refreshHongBaoBtn()
            end
        end
    end
end

function GlobalController:refreshNetStrength(paras)
local moduelName = {
        -- "gameshall", --大厅
        "texasbrgame", -- 百人场 
        "brniuniugame",  --百人牛牛
        "lhdgame",  -- 龙虎斗
        "kancontroller",  --牛牛
        "zjhgame"  --炸金花
    }

    for i, v in ipairs(moduelName) do
        local ctrl = ModuleManager[v]
        if ctrl then
            local view = ctrl.view
            if view and tolua.isnull(view) == false and view.refreshNetStrength then
                -- print("refreshNetStrength >>>>>>>>>>>")
                -- dump(paras)
                view:refreshNetStrength(paras)
            end
        end
    end
end

return GlobalController