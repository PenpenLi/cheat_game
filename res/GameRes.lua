
local M = {}

local prefix = ""

--[[json文件路径start]]
M.gameChestJson = prefix .. "ui/game_chest.json" --游戏宝箱
M.gameChestPopJson = prefix .. "ui/game_chest_pop.json" --游戏宝箱
M.gameWaitingQueueTipJson = prefix .. "ui/waiting_queue_tip.json"

M.mohubg = prefix .. "share/common/moban_di01.jpg" -- 模糊背景

M.userInfoJson = prefix .. "ui/userinfo.json"--  个人信息界面json文件
M.broadcastJson = prefix .. "ui/broadcast.json"--  广播json文件
M.globalPromit = prefix .. "ui/globalPromit.json"-- 公共提示框

M.commonTipWindowJson = prefix .. "ui/common_tip_window.json" -- 公共的弹窗提示
M.mainViewJson = prefix .. "ui/hall_layer.json" -- qif3  主界面
M.agreementViewJson = prefix .. "ui/agreement.json"--  用户协议界面json文件

M.pcLoginJson = prefix .. "ui/pcLogin_1.json" -- pc登录
M.loginloginLayout1Json = prefix .. "ui/loginLayout.json"
M.loginLayoutJson = prefix .. "ui/login_layer.json"--"ui/loginLayout.json"--login界面
M.safeBox = prefix .. "ui/safe_box_layer.json" --保险箱
M.personal = prefix .. "ui/personal_info_layer.json" --个人中心
M.changePwd = prefix .. "ui/change_pwd_layer.json"   --修改密码
M.exchange = prefix .. "ui/exchange_layer.json"--提现
M.bindCard = prefix .. "ui/bind_bankcard_layer.json"--绑卡界面（银行卡、支付宝）
M.shop = prefix .."ui/shop_layer.json" --只有充值入口的商城
M.setting = prefix .."ui/setting_layer.json" --设置
M.globalLoading = prefix .."ui/NewUi_1.json" --新的loading
M.inviteCode = prefix .."ui/invite_layer.json" --邀请码填写
M.custom = prefix.."ui/custom_layer.json"   --客服
M.messageBox = prefix.."ui/message_box_layer.json"   --通用弹框
M.newAgreementViewJson = prefix.."ui/new_agreement_layer.json"   --新的用户协议界面json文件
M.newActivityJson = prefix.."ui/activity_layer.json"   --活动界面json文件
M.gameRuleJson = prefix.."ui/player_rule_layer.json"   --规则界面json文件
M.mailJson = prefix.."ui/mall_layer.json"   --邮箱界面json文件
M.luckJson = prefix.."ui/luck_layer.json"   --好运来界面json文件
M.agencyJson = prefix.."ui/agency_layer.json"   --代理界面json文件
M.guideJson = prefix.."ui/guide_layer.json"   
M.gameLabaJson = prefix .. "ui/Laba_1.json"--  喇叭界面json文件
M.DaojuJson = prefix .. "ui/Daoju_1.json"--  道具界面json文件
M.gift = prefix .. "ui/gift.json"--  礼物界面json文件
M.giftCardPopupTipJson = prefix .. "ui/gift_card_popup_tip.json" -- 礼物卡购买礼物提示框
M.WordMsgJson = prefix .. "ui/world_msg.json"--  世界广播json文件
M.cancellationJson = prefix .. "ui/cancellation.json"--注销确认界面
M.retMoneyJson = prefix.."ui/ret_money_layer.json"   --周福利json文件
M.hongbaoJson = prefix.."ui/hongbao_layer.json"   --绑定有礼json文件
M.maintainViewJson = prefix.."ui/maintain_layer.json"   --维护公告json文件
M.debugViewJson = prefix.."ui/debug_layer.json"   --debug界面json文件
M.userPolicyViewJson = prefix.."ui/user_privacy_policy.json"   --隐私策略json文件
M.communityViewJson = prefix.."ui/community.json"   --社区json文件


M.scoreExchangeJson = prefix .. "ui/exchange.json"--分兑换窗口

M.GiveGiftTipJson = prefix .. "ui/give_gift_tip.json"--二次确认
M.hotUpdateJson = prefix .. "ui/hot_update.json" --热更新

M.bueatyAnimate = prefix .. "ui/global/animate/NewAnimation20180415woman/NewAnimation20180415woman.ExportJson"
M.photoNodeJson = prefix .. "ui/photo_node.json"--相册节点
M.galleryJson = prefix .. "ui/Gallery_1.json"--相册节点
M.photoBigNodeJson = prefix .. "ui/photo_big_node.json"--相册节点
M.beautyShareJson = prefix .. "ui/beauty_share.json"--美女分享
M.galleryPageViewJson = prefix .. "ui/gallery_pageview_layout.json"--美女相册pageview 节点
M.chatViewJson = prefix .. "ui/chat.json"

--客服聊天
M.customerServiceJson = prefix .. "ui/customer_chat.json"
M.agencyAlertJson = prefix .. "ui/agency_pop.json"


--[[json文件路径end]]

--[[提前加载图片 start]]
M.preLoadingImg = {
    prefix .. "ui/global/global_dialog_bg.png", 
    prefix .. "ui/global/global_dialog_close.png", 
    prefix .. "ui/global/global_beauty_bg.jpg", 
}
--[[提前加载图片end]]

--[[动画文件路径]]
M.gameChatPlist = prefix .. "ui/game_chat/gameChat.plist" --表情动画plist文件
M.gameChatNoblePlist = prefix .. "ui/game_chat/gameChatNoble.plist" --贵族表情动画plist文件
--[[动画文件路径]]
--星星图片
M.main_effect_star = prefix .. "share/common/star.png"

M.res002 = prefix .. "share/animation/fanpai01.png"
M.res003 = prefix .. "share/animation/fanpai02.png"
M.res004 = prefix .. "share/animation/fanpai03.png"
M.res005 = prefix .. "share/animation/fanpai04.png"
M.res006 = prefix .. "share/animation/fanpai05.png"
M.res007 = prefix .. "share/animation/fanpai06.png"


M.chips_shadow_yellow_img = prefix .. "share/chips/chips_shadow_yellow_img.png"
M.chips_yellow_img = prefix .. "share/chips/chips_yellow_img.png"
M.chips_shadow_orange_img = prefix .. "share/chips/chips_shadow_orange_img.png"
M.chips_orange_img = prefix .. "share/chips/chips_orange_img.png"
M.chips_shadow_black_img = prefix .. "share/chips/chips_shadow_black_img.png"
M.chips_black_img = prefix .. "share/chips/chips_black_img.png"
M.chips_shadow_purple_img = prefix .. "share/chips/chips_shadow_purple_img.png"
M.chips_purple_img = prefix .. "share/chips/chips_purple_img.png"
M.chips_shadow_red_img = prefix .. "share/chips/chips_shadow_red_img.png"
M.chips_red_img = prefix .. "share/chips/chips_red_img.png"
M.chips_shadow_green_img = prefix .. "share/chips/chips_shadow_green_img.png"
M.chips_green_img = prefix .. "share/chips/chips_green_img.png"
M.chips_shadow_blue_img = prefix .. "share/chips/chips_shadow_blue_img.png"
M.chips_blue_img = prefix .. "share/chips/chips_blue_img.png"

M.chip_03 = prefix .. "share/chips/chip_03.png"
M.chip_04 = prefix .. "share/chips/chip_04.png"
M.chip_05 = prefix .. "share/chips/chip_05.png"

M.font1 = "Arial"

--imageLoading
M.image_loading_plist = prefix .. "share/loading/ImageLoading.plist"
M.image_loading_png = prefix .. "share/loading/ImageLoading.png"
M.image_loading_name = "image_load_%d.png"

--rank start--
M.rank_friend_bg01 = prefix .. "ui/rank/ranking_friend_down_btn.png"
M.rank_friend_bg02 = prefix .. "ui/rank/ranking_friend_up_btn.png"
M.rank_world_bg01 = prefix .. "ui/rank/ranking_world_down_btn.png"
M.rank_world_bg02 = prefix .. "ui/rank/ranking_world_up_btn.png"
M.rank_gold_icon = prefix .. "ui/rank/ranking_chips_img.png"
M.rank_number_one = prefix .. "ui/rank/ranking_gold_img.png"
M.rank_number_two = prefix .. "ui/rank/ranking_silver_img.png"
M.rank_number_three = prefix .. "ui/rank/ranking_copper_img.png"
--rank end--
--youxi/ chat chat--
M.game_chat1 = prefix .. "ui/game_chat/game_chat1.png"
M.game_chat2 = prefix .. "ui/game_chat/game_chat2.png"
M.game_chat1_big = prefix .. "ui/game_chat/game_chat1_big.png"
M.game_chat2_big = prefix .. "ui/game_chat/game_chat2_big.png"
--youxi/ chat end--
--global start--
M.default_man_icon = prefix .. "ui/global/global_default_icon01.png"
M.default_girl_icon = prefix .. "ui/global/global_default_icon02.png"
M.default_man_large_icon = prefix .. "ui/global/global_default_large_icon01.png"
M.default_girl_large_icon = prefix .. "ui/global/global_default_large_icon02.png"
M.default_sq_man_icon = prefix .. "ui/hall/default_icon_60_1.png"
M.default_sq_girl_icon = prefix .. "ui/hall/default_icon_60_2.png"
M.rank_money_img = prefix .. "ui/global/global_money_img.png"
M.shop_item_2 = prefix .. "ui/global/shop_item_bg01.png"
M.shop_item_6 = prefix .. "ui/global/shop_item_bg02.png"
M.shop_item_10 = prefix .. "ui/global/shop_item_bg03.png"
M.shop_item_20 = prefix .. "ui/global/shop_item_bg04.png"
M.shop_item_50 = prefix .. "ui/global/shop_item_bg05.png"
M.shop_item_100 = prefix .. "ui/global/shop_item_bg06.png"
M.shop_item_200 = prefix .. "ui/global/shop_item_bg07.png"
M.shop_item_400 = prefix .. "ui/global/shop_item_bg08.png"
M.shop_car = prefix .. "ui/shop/img_car_icon_%d.png"
M.shop_diamond = prefix .. "ui/shop/img_buy_diamond_%d.png"
M.shop_gold_suffix = prefix .. "ui/shop/img_suffix_2.png"
M.shop_white_gold_word = prefix .. "ui/shop/img_txt_white_gold.png"
M.shop_white_rmb_unit = prefix .. "ui/shop/img_icon.png"
M.shop_bookmark_gold = prefix .. "ui/shop/img_bookmark_gold.png"
M.shop_bookmark_gold_sel = prefix .. "ui/shop/img_bookmark_gold_sel.png"
M.shop_bookmark_diamond = prefix .. "ui/shop/img_bookmark_diamond.png"
M.shop_bookmark_diamond_sel = prefix .. "ui/shop/img_bookmark_diamond_sel.png"
M.shop_bookmark_props = prefix .. "ui/shop/img_bookmark_props.png"
M.shop_bookmark_props_sel = prefix .. "ui/shop/img_bookmark_props_sel.png"
M.shop_bookmark_exchange = prefix .. "ui/shop/img_bookmark_exchange.png"
M.shop_bookmark_exchange_sel = prefix .. "ui/shop/img_bookmark_exchange_sel.png"
M.shop_title_gift_card = prefix .. "ui/shop/img_title_gift_card.png" -- 礼物卡
M.shop_title_week_card = prefix .. "ui/shop/img_title_week_card.png" -- 周卡
M.shop_title_month_card = prefix .. "ui/shop/img_title_month_card.png" -- 月卡
M.shop_title_poker_face = prefix .. "ui/shop/img_title_poker_face.png" -- pokerface
M.shop_title_week_vip = prefix .. "ui/shop/img_title_month_card.png" -- 周VIP
M.shop_title_month_vip = prefix .. "ui/shop/img_title_month_card.png" -- 月VIP
M.shop_title_pay_method = prefix .. "ui/shop/img_title_pay_method.png" -- 支付方式
M.shop_title_buy_gold = prefix .. "ui/shop/img_title_buy_gold.png" -- 购买金币
M.shop_title_buy_props = prefix .. "ui/shop/img_title_buy_props.png" -- 购买道具
M.shop_title_tip = prefix .. "ui/shop/img_title_tip.png" -- 温馨提示

M.shop_add_gold_txt = prefix .. "ui/shopPromit/add_gold_text_%d.png" -- 补充金币
M.shop_add_diamond_txt = prefix .. "ui/shopPromit/add_diamond_text_%d.png" -- 补钻石

M.game_shop_item_6 = prefix .. "ui/gameShop/game_shop_item_coin_1.png"
M.game_shop_item_10 = prefix .. "ui/gameShop/game_shop_item_coin_2.png"
M.game_shop_item_20 = prefix .. "ui/gameShop/game_shop_item_coin_3.png"

M.global_forbid_btn = prefix .. "ui/global/global_btn_gray.png"
M.global_allow_btn = prefix .. "ui/global/global_btn.png"
M.global_purple_btn = prefix .. "ui/global/btn_normal_351x113_n.png"
M.image_item_normal = prefix .. "ui/global/image_item_normal.png"
M.image_item_select = prefix .. "ui/global/image_item_select.png"

M.image_item_normal2 = prefix .. "ui/global/image_item_normal2.png"
M.image_item_select2 = prefix .. "ui/global/image_item_select2.png"
M.playerFrameImage = prefix .. "ui/global/global_img_713_113.png"
--global end--

M.game_chest_close_bt = prefix .. "ui/game_chest/game_chest_close_bt.png"
M.game_chest_open_bt1 = prefix .. "ui/game_chest/baoxiang.png"
M.game_chest_open_bt2 = prefix .. "ui/game_chest/baoxiang02.png"
M.game_chest_open_ani = prefix .. "ui/game_chest/kaiqibaoxiang_xx%d.png"

--activity start
M.activity_head = prefix .. "ui/activity/promotion_word_img.png" --活动
M.activity_status1 = prefix .. "ui/activity/xtk__0005_006.png" --活动火爆
M.activity_status2 = prefix .. "ui/activity/xtk__0004_007.png" --活动最新
M.activity_status3 = prefix .. "ui/activity/xtk__0003_008.png" --活动限时

M.activity_new_status1 = prefix .. "ui/activity/fire.png"      --火爆
M.activity_new_status2 = prefix .. "ui/activity/hot.png"       --最热
M.activity_new_status3 = prefix .. "ui/activity/limit.png"     --限时
M.activity_new_status4 = prefix .. "ui/activity/new.png"       --最新
M.activity_new_status5 = prefix .. "ui/activity/recommend.png" --推荐
--activity end

--beauty start
M.beauty_title = prefix .. "ui/global/global_beauty_word.png" --美女
M.beauty_auth1 = prefix .. "ui/beauty/sex_auth1_img1.png" --
M.beauty_head_bg = prefix .. "ui/beauty/bg_recent_auth_photo.png"
M.beauty_sex_auth3_btn1 = prefix .. "ui/beauty/sex_auth3_btn1.png"
--beauty end
M.global_wait_bg = prefix .. "ui/global/global_wait_bg.png"
M.global_wait_txt_frame = prefix .. "ui/global/net_loading_txt_bg.png"
M.global_wait_frame = prefix .. "ui/global/global_wait_frame.png"
M.login_chips_1 = prefix .. "share/chips/login_chips1.png"
M.login_chips_2 = prefix .. "share/chips/login_chips2.png"
M.login_chips_3 = prefix .. "share/chips/login_chips3.png"
M.login_golds_1 = prefix .. "share/chips/login_golds1.png"
M.login_golds_2 = prefix .. "share/chips/login_golds2.png"
M.login_golds_3 = prefix .. "share/chips/login_golds3.png"
M.login_golds_4 = prefix .. "share/chips/login_golds4.png"
M.bankruptcy_btn_tag = prefix .. "ui/bankruptcy/bankruptcy_btn_tag.png"
M.login_chip_shadow = prefix .. "share/chips/chip_shadow.png"

M.user_default0 = prefix .. "ui/global/default_icon_60_1.png"
M.user_default1 = prefix .. "ui/global/default_icon_60_2.png"



M.reward_goon_btn = prefix .. "ui/reward/reward_goon_btn.png"
M.reward_have_btn = prefix .. "ui/reward/reward_have_finish.png"
M.reward_get_btn = prefix .. "ui/reward/reward_get_btn.png"
M.reward_type_1 = prefix .. "ui/reward/xtk__0004_09.png"
M.reward_type_2 = prefix .. "ui/reward/xtk__0005_08.png"
M.reward_type_3 = prefix .. "ui/lobby/d_input_password_title.png"
M.reward_type_4 = prefix .. "ui/reward/reward_type_4.png"

--changeuserinfo start
M.ok_word_img = prefix .. "ui/global/ok_word_img.png"
M.local_upload_word_img = prefix .. "ui/change_userinfo/local_upload_word_img.png"
M.photograph_word_img = prefix .. "ui/change_userinfo/photograph_word_img.png"
--changeuserinfo en

M.shop_title = prefix .. "ui/shop/shop_word.png"
M.shop_ok = prefix .. "ui/shop/exchange_ok.png"
M.shop_send = prefix .. "ui/shop/shop_send.png"
M.shop_txt = prefix .. "ui/shop/shop_buy_txt2.png"
M.shop_number = prefix .. "ui/shop/shop_number.png"
M.shop_sell_img1 = prefix .. "ui/shop/img_label_recommend.png"
M.shop_sell_img2 = prefix .. "ui/shop/img_label_best_sell.png"
M.shop_sell_img3 = prefix .. "ui/shop/top_shop.png"

M.toast_bg = prefix .. "ui/global/game_broadcast_tv_bg.png"

--[[音效start]]
M.all_music = {
    BIGYING = prefix .. "music/bigying.mp3", 
    BTN = prefix .. "music/menu_click_06.wav", 
    CHIP = prefix .. "music/chip.mp3", 
    CHIP_FLY = prefix .. "music/chipfly.mp3", 
    FAPAI = prefix .. "music/fapai.mp3", 
    GAME_WIN = prefix .. "music/game_win.mp3", 
    G_ALARM = prefix .. "music/g_alarm.mp3", 
    G_RECVGIFT = prefix .. "music/g_recvgift.mp3", 
    LOB_BG = prefix .. "music/lob_bg.mp3", 
    LOSE = prefix .. "music/lose.mp3", 
    POPUP = prefix .. "music/popup.mp3",  
    TASK_FINISH = prefix .. "music/task_finish.mp3", 
    TASK_GOLD = prefix .. "music/task_gold.mp3", 
    KISS = prefix .. "music/kiss.mp3", 
    PENG = prefix .. "music/peng.mp3", 
    phiz_py_daoshui = prefix .. "music/py_daoshui.mp3", 
    phiz_py_dianzan = prefix .. "music/py_dianzan.mp3", 
    phiz_py_ganbei = prefix .. "music/py_ganbei.mp3", 
    phiz_py_meigui = prefix .. "music/py_meigui.mp3", 
    DIAMOND_POPUP = prefix .. "music/diamond_popup.mp3", 
    phiz_py_xihongshi = prefix .. "music/py_xihongshi.mp3",
    giftCar = prefix .. "music/gift_car5.mp3",
    giftCar1 = prefix .. "music/gift_car4.mp3",
    xxlBg = prefix .. "music/xxlMusic.mp3",
    GMAE_COMMON_BGM = prefix .. "music/normal_game_bg.mp3"
}
--[[音效end]]

M.setting_btn_open = prefix .. "ui/setting/setting_btn_open.png"
M.setting_btn_openclose = prefix .. "ui/setting/setting_btn_openclose.png"

M.global_ranking_gold_img = prefix .. "ui/global/global_ranking_gold_img.png"
M.global_ranking_silver_img = prefix .. "ui/global/global_ranking_silver_img.png"
M.global_ranking_copper_img = prefix .. "ui/global/global_ranking_copper_img.png"

M.beauty_rank_hat_1 = prefix .. "ui/global/global_ranking_gold_img.png"
M.beauty_rank_hat_2 = prefix .. "ui/global/global_ranking_silver_img.png"
M.beauty_rank_hat_3 = prefix .. "ui/global/global_ranking_copper_img.png"
M.beauty_rank_hat_4 = prefix .. "ui/global/global_is_sex_img.png"

M.gameChat = prefix .. "ui/game_chat/gameChat.png"
M.gameChatNoble = prefix .. "ui/game_chat/gameChatNoble.png"

M.default_icon_60_2 = prefix .. "ui/global/default_icon_60_2.png"




--[[新手教程end]]

M.sendgift_word_img = prefix .. "ui/global/send_gift_word.png"
M.bnt_number_bg = prefix .. "ui/global/bnt_number_bg.png"

M.main_rank_1 = prefix .. "ui/hall/Front-hall_0007_26.png"
M.main_rank_2 = prefix .. "ui/hall/Front-hall_0006_27.png"
M.main_rank_3 = prefix .. "ui/hall/Front-hall_0005_28.png"

M.userstatus_showcards_animation = prefix .. "share/animation/user_status/show_cards/%d.png"
M.userstatus_allin_animation = prefix .. "share/animation/user_status/all_in/100%02d.png"




M.beauty_week_rank1 = prefix .. "ui/beauty/beauty_this_week_word.png"
M.beauty_week_rank2 = prefix .. "ui/beauty/beauty_last_week_word.png"



M.game_chip_wan = prefix .. "share/chips/game_chip_wan.png"
M.game_chip_num = prefix .. "share/chips/game_chip_num.png"

M.login_bnt_bg = prefix .. "ui/global/login_bnt_bg.png"
M.binding_qq_bnt = prefix .. "ui/global/binding_qq_bnt.png"
M.binding_qq_tips = prefix .. "ui/global/binding_qq_tips.png"
M.binding_wx_bnt = prefix .. "ui/global/binding_wx_bnt.png"
M.binding_wx_tips = prefix .. "ui/global/binding_wx_tips.png"

M.br_result_snow1 = prefix .. "ui/brgame/br_result_snow1.png"
M.br_result_snow2 = prefix .. "ui/brgame/br_result_snow2.png"
M.br_result_start = prefix .. "ui/brgame/br_result_start.png"

M.game_chat_btn_img = prefix .. "ui/game_chat/bg_icon_1.png"

M.gameChatJson = prefix .. "ui/gameChat_1.json"--  聊天信息界面json文件
M.exitDialogJson = prefix .. "ui/exitDialog.json"--  退出游戏界面json文件

M.shop_giftcard_icon = prefix .. "ui/shop/shop_giftcard.png"
M.shop_laba_icon = prefix .. "ui/shop/shop_laba.png"
M.shop_weekcard_icon = prefix .. "ui/shop/shop_weekcard.png"
M.shop_monthcard_icon = prefix .. "ui/shop/shop_monthcard.png"
M.shop_vip_week_icon = prefix .. "ui/shop/shop_vip_weekcard.png"
M.shop_vip_month_icon = prefix .. "ui/shop/shop_vip_monthcard.png"

M.chat_bg_icon1 = prefix .. "ui/game_chat/bg_icon_1.png"
M.chat_bg_icon2 = prefix .. "ui/game_chat/bg_icon_2.png"
M.chat_bg_icon3 = prefix .. "ui/game_chat/bg_icon_3.png"
M.chat_bg_icon4 = prefix .. "ui/game_chat/bg_icon_4.png"
M.chat_bg_icon5 = prefix .. "ui/game_chat/bg_icon_5.png"


--[[设置界面开关资源]]
M.setting_switch_plist = prefix .. "ui/setting/switch.plist"
M.setting_switch_png = prefix .. "ui/setting/switch.png"
M.setting_switch_plist1 = prefix .. "ui/setting/switch1.plist"
M.setting_switch_png1 = prefix .. "ui/setting/switch1.png"

M.msg_line = prefix .. "ui/laba/line.png"

M.weekMonthCardJson = prefix .. "ui/weekcard_pop_1.json"

M.week_card_title = prefix .. "ui/weekcard_pop/img_week.png"
M.month_card_title = prefix .. "ui/weekcard_pop/img_month.png"
M.week_card_icon = prefix .. "ui/weekcard_pop/icon_weekcard.png"
M.month_card_icon = prefix .. "ui/weekcard_pop/icon_monthcard.png"

M.shop_coins_icon_1 = prefix .. "ui/shop/icon_coins1.png"
M.shop_coins_icon_2 = prefix .. "ui/shop/icon_coins2.png"
M.shop_coins_icon_3 = prefix .. "ui/shop/icon_coins3.png"
M.shop_coins_icon_4 = prefix .. "ui/shop/icon_coins4.png"
M.shop_coins_icon_5 = prefix .. "ui/shop/icon_coins5.png"
M.shop_coins_icon_6 = prefix .. "ui/shop/icon_coins6.png"
M.shop_coins_icon_7 = prefix .. "ui/shop/icon_coins7.png"
M.shop_coins_icon_8 = prefix .. "ui/shop/icon_coins8.png"

M.shop_channel_huafei = prefix .. "ui/shop/channel_duanxin.png"

M.gift_icon_0 = prefix .. "ui/global/gift01.png"
M.gift_icon_1 = prefix .. "ui/global/gift02.png"
M.gift_icon_2 = prefix .. "ui/global/gift03.png"
M.gift_icon_3 = prefix .. "ui/global/gift04.png"
M.gift_icon_4 = prefix .. "ui/global/gift05.png"
M.gift_icon_5 = prefix .. "ui/global/gift06.png"
-- M.gift_icon_7 = prefix.."ui/global/gift07.png"
-- M.gift_icon_8 = prefix.."ui/global/gift08.png"
-- M.gift_icon_9 = prefix.."ui/global/gift09.png"
-- M.gift_icon_10 = prefix.."ui/global/gift10.png"
-- M.gift_icon_11 = prefix.."ui/global/gift11.png"
-- M.gift_icon_12 = prefix.."ui/global/gift12.png"

M.gift_icon_1005 = prefix .. "share/gift/1005.png"
M.gift_icon_1006 = prefix .. "share/gift/1006.png"
M.gift_icon_1007 = prefix .. "share/gift/1007.png"
M.gift_icon_1008 = prefix .. "share/gift/1008.png"
M.gift_icon_1009 = prefix .. "share/gift/1009.png"
M.gift_icon_1010 = prefix .. "share/gift/1010.png"
M.gift_icon_1011 = prefix .. "share/gift/1011.png"
M.gift_icon_1012 = prefix .. "share/gift/1012.png"
M.gift_icon_1013 = prefix .. "share/gift/1013.png"
M.gift_icon_1014 = prefix .. "share/gift/1014.png"
M.gift_icon_1015 = prefix .. "share/gift/1015.png"
M.gift_icon_1016 = prefix .. "share/gift/1016.png"
M.gift_icon_1017 = prefix .. "share/gift/1017.png"
M.gift_icon_1018 = prefix .. "share/gift/1018.png"
M.gift_icon_1019 = prefix .. "share/gift/1019.png"
M.gift_icon_1020 = prefix .. "share/gift/1020.png"
M.gift_icon_1021 = prefix .. "share/gift/1021.png"
M.gift_icon_1022 = prefix .. "share/gift/1022.png"
M.gift_icon_1023 = prefix .. "share/gift/1023.png"
M.gift_icon_1024 = prefix .. "share/gift/1024.png"
M.gift_icon_1025 = prefix .. "share/gift/1025.png"
M.gift_icon_1026 = prefix .. "share/gift/1026.png"
M.gift_icon_1027 = prefix .. "share/gift/1027.png"
M.gift_icon_1028 = prefix .. "share/gift/1028.png"
M.gift_icon_1029 = prefix .. "share/gift/1029.png"
M.gift_icon_1030 = prefix .. "share/gift/1030.png"
M.gift_icon_1031 = prefix .. "share/gift/1031.png"
M.gift_icon_1032 = prefix .. "share/gift/1032.png"
M.gift_icon_1033 = prefix .. "share/gift/1033.png"
M.gift_icon_1034 = prefix .. "share/gift/1034.png"
M.gift_icon_1035 = prefix .. "share/gift/1035.png"
M.gift_icon_1036 = prefix .. "share/gift/1036.png"
M.gift_icon_1037 = prefix .. "share/gift/1037.png"
M.gift_icon_1038 = prefix .. "share/gift/1038.png"
M.gift_icon_1039 = prefix .. "share/gift/1039.png"
M.gift_icon_1040 = prefix .. "share/gift/1040.png"
M.gift_icon_1041 = prefix .. "share/gift/1041.png"
M.gift_icon_1042 = prefix .. "share/gift/1042.png"
M.gift_icon_1043 = prefix .. "share/gift/1043.png"
M.gift_icon_1044 = prefix .. "share/gift/1044.png"
M.gift_icon_1045 = prefix .. "share/gift/1045.png"

M.gift_icon_2000 = prefix .. "share/gift/2000.png"
M.gift_icon_2001 = prefix .. "share/gift/2001.png"
M.gift_icon_2002 = prefix .. "share/gift/2002.png"
M.gift_icon_2003 = prefix .. "share/gift/2003.png"
M.gift_icon_2004 = prefix .. "share/gift/2004.png"
M.gift_icon_2005 = prefix .. "share/gift/2005.png"

M["gift_icon_s_-1"] = prefix .. "ui/global/userinfo_img_gift.png"
M.gift_icon_s_0 = prefix .. "share/gift/0_s.png"
M.gift_icon_s_1 = prefix .. "share/gift/1_s.png"
M.gift_icon_s_2 = prefix .. "share/gift/2_s.png"
M.gift_icon_s_3 = prefix .. "share/gift/3_s.png"
M.gift_icon_s_4 = prefix .. "share/gift/4_s.png"
-- M.gift_icon_s_7 = prefix.."share/gift/7_s.png"
-- M.gift_icon_s_8 = prefix.."share/gift/8_s.png"
-- M.gift_icon_s_9 = prefix.."share/gift/9_s.png"
-- M.gift_icon_s_10 = prefix.."share/gift/10_s.png"
-- M.gift_icon_s_11 = prefix.."share/gift/11_s.png"
-- M.gift_icon_s_12 = prefix.."share/gift/12_s.png"
M.gift_icon_s_1005 = prefix .. "share/gift/1005_s.png"
M.gift_icon_s_1006 = prefix .. "share/gift/1006_s.png"
M.gift_icon_s_1007 = prefix .. "share/gift/1007_s.png"
M.gift_icon_s_1008 = prefix .. "share/gift/1008_s.png"
M.gift_icon_s_1009 = prefix .. "share/gift/1009_s.png"
M.gift_icon_s_1010 = prefix .. "share/gift/1010_s.png"
M.gift_icon_s_1011 = prefix .. "share/gift/1011_s.png"
M.gift_icon_s_1012 = prefix .. "share/gift/1012_s.png"
M.gift_icon_s_1013 = prefix .. "share/gift/1013_s.png"
M.gift_icon_s_1014 = prefix .. "share/gift/1014_s.png"
M.gift_icon_s_1015 = prefix .. "share/gift/1015_s.png"
M.gift_icon_s_1016 = prefix .. "share/gift/1016_s.png"
M.gift_icon_s_1017 = prefix .. "share/gift/1017_s.png"
M.gift_icon_s_1018 = prefix .. "share/gift/1018_s.png"
M.gift_icon_s_1019 = prefix .. "share/gift/1019_s.png"
M.gift_icon_s_1020 = prefix .. "share/gift/1020_s.png"
M.gift_icon_s_1021 = prefix .. "share/gift/1021_s.png"
M.gift_icon_s_1022 = prefix .. "share/gift/1022_s.png"
M.gift_icon_s_1023 = prefix .. "share/gift/1023_s.png"
M.gift_icon_s_1024 = prefix .. "share/gift/1024_s.png"
M.gift_icon_s_1025 = prefix .. "share/gift/1025_s.png"
M.gift_icon_s_1026 = prefix .. "share/gift/1026_s.png"
M.gift_icon_s_1027 = prefix .. "share/gift/1027_s.png"
M.gift_icon_s_1028 = prefix .. "share/gift/1028_s.png"
M.gift_icon_s_1029 = prefix .. "share/gift/1029_s.png"
M.gift_icon_s_1030 = prefix .. "share/gift/1030_s.png"
M.gift_icon_s_1031 = prefix .. "share/gift/1031_s.png"
M.gift_icon_s_1032 = prefix .. "share/gift/1032_s.png"
M.gift_icon_s_1033 = prefix .. "share/gift/1033_s.png"
M.gift_icon_s_1034 = prefix .. "share/gift/1034_s.png"
M.gift_icon_s_1035 = prefix .. "share/gift/1035_s.png"
M.gift_icon_s_1036 = prefix .. "share/gift/1036_s.png"
M.gift_icon_s_1037 = prefix .. "share/gift/1037_s.png"
M.gift_icon_s_1038 = prefix .. "share/gift/1038_s.png"
M.gift_icon_s_1039 = prefix .. "share/gift/1039_s.png"
M.gift_icon_s_1040 = prefix .. "share/gift/1040_s.png"
M.gift_icon_s_1041 = prefix .. "share/gift/1041_s.png"
M.gift_icon_s_1042 = prefix .. "share/gift/1042_s.png"
M.gift_icon_s_1043 = prefix .. "share/gift/1043_s.png"
M.gift_icon_s_1044 = prefix .. "share/gift/1044_s.png"
M.gift_icon_s_1045 = prefix .. "share/gift/1045_s.png"

M.gift_icon_s_2000 = prefix .. "share/gift/2000_s.png"
M.gift_icon_s_2001 = prefix .. "share/gift/2001_s.png"
M.gift_icon_s_2002 = prefix .. "share/gift/2002_s.png"
M.gift_icon_s_2003 = prefix .. "share/gift/2003_s.png"
M.gift_icon_s_2004 = prefix .. "share/gift/2004_s.png"
M.gift_icon_s_2005 = prefix .. "share/gift/2005_s.png"


M.particle_win = prefix .. "share/animation/particle_win9.plist"
M.effect_win = prefix .. "share/animation/effect_win%02d.png"


M.icon_number = prefix .. "ui/global/img_icon_num.png"
M.img_mine = prefix .. "ui/rank/img_me.png"

--主界面商城按钮特效
M.img_main_shop_shape = prefix .. "ui/hall/main_shop_shape.png"

-- 主界面商城按钮特效 v460
--M.main_new_shop = prefix .. "ui/armature_anim/main_shop_btn/NewAnimation.ExportJson"
-- 主界面商城按钮特效
-- M.main_new_shop = prefix.."ui/hall/animation/shop/store.ExportJson"
-- 主界面兑换按钮特效
-- M.main_exchange = prefix.."ui/hall/animation/exchange/duihuan.ExportJson"

-- 主界面快速开始按钮特效 v460
M.main_quickStart = prefix .. "ui/armature_anim/main_quick_btn/NewAnimation.ExportJson"
M.main_quickStart_douniu = prefix .. "ui/armature_anim/main_quick_btn/douniu/NewAnimation.ExportJson"

-- 主界面集合包炸金花按钮特效 v460
M.main_zjh_item = prefix .. "ui/armature_anim/main_zjh_item/NewAnimation_red_one.ExportJson"

--主界面雪花效果
M.img_main_snow_particle = prefix .. "ui/armature_anim/particle_texture_sonw_dating.plist"


----聊天优化
M.game_chat_face_select_bt_selected = prefix .. "ui/game_chat/face_select_bt_selected.png" -- 
M.game_chat_face_select_bt_normal = prefix .. "ui/game_chat/face_select_bt_normal.png" -- 
M.global_trans_bt = prefix .. "ui/global/global_trans_bt.png" --

M.mainviewAni = prefix .. "ui/global/animate/NewAnimation190313cztixkf/NewAnimation190313cztixkf.ExportJson"
M.mainGameBtnAni = prefix .. "ui/global/animate/NewAnimation0314ICON1/NewAnimation0314ICON1.ExportJson"
M.zhouFanXianAni = prefix .. "ui/global/animate/NewAnimation190319zhoufanxian/NewAnimation190319zhoufanxian.ExportJson"
M.BJLBtnAni = prefix .. "ui/global/animate/NewAnimation0326ICON8/NewAnimation0326ICON8.ExportJson"
M.longHuoAni = prefix .. "ui/global/animate/NewAnimation0330longhuo/NewAnimation0330longhuo.ExportJson"
M.bindRewardAni = prefix .. "ui/global/animate/NewAnimation190401BDYL/NewAnimation190401BDYL.ExportJson"
M.LXDLBtnAni = prefix .. "ui/global/animate/NewAnimation0516LXDL/NewAnimation0516LXDL.ExportJson"
M.CSYBtnAni = prefix .. "ui/global/animate/NewAnimation0517csy/NewAnimation0517csy.ExportJson"
M.HYLBtnAni = prefix .. "ui/global/animate/NewAnimationxiafenDH/NewAnimationxiafenDH.ExportJson"
M.GAMEFLAGANI = prefix .. "ui/global/animate/NewAnimationtuijian1/NewAnimationtuijian1.ExportJson"
M.GUIDEHEADANI = prefix .. "ui/global/animate/NewAnimationxsyd01/NewAnimationxsyd01.ExportJson"
M.NewMessageAni = prefix .. "ui/global/animate/NewAnimationxinxiaoxi04/NewAnimationxinxiaoxi04.ExportJson"
M.HongbaoAni = prefix .. "ui/global/animate/NewAnimationdtshouchong3/NewAnimationdtshouchong3.ExportJson"
M.RtMoneyAni2 = prefix .. "ui/global/animate/NewAnimationbaifenbaifanxian2/NewAnimationbaifenbaifanxian1.ExportJson"
M.exchangeAni = prefix .. "ui/global/animate/NewAnimationtixian0917/NewAnimationtixian0917.ExportJson"
M.BDSJBtnAni = prefix .. "ui/global/animate/NewAnimationbangdingshouji1/NewAnimationbangdingshouji1.ExportJson"
M.CSYAni = prefix .. "ui/global/animate/NewAnimation0517TCcaishen/NewAnimation0517TCcaishen.ExportJson"

------天天斗牛主页动效 start------
M.hall_game_btn_sprite_plist_1 = prefix .. "ui/hall/animation/game_niuniu_btn_ani.plist"
M.hall_game_btn_sprite_png_1 = prefix .. "ui/hall/animation/game_niuniu_btn_ani.png"
M.hall_game_btn_sprite_plist_2 = prefix .. "ui/hall/animation/game_other_btn_ani.plist"
M.hall_game_btn_sprite_png_2 = prefix .. "ui/hall/animation/game_other_btn_ani.png"

M.hall_game_btn_frame_name = {
    ["game_niuniu"] = "20200225qznn1_%d.png",
    ["game_br"] = "20200225brzjh5_%d.png",
    ["game_zjh"] = "20200225zjh4_%d.png",
    ["game_brnn"] = "20200225brnn2_%d.png",
    ["game_lhd"] = "20200225lhd3_%d.png",
}

M.hall_game_btn_bg_arm = prefix .. "ui/hall/animation/NewAnimation20200224znn1/NewAnimation20200224znn1.ExportJson"
M.hall_shop_btn_arm = prefix .. "ui/hall/animation/NewAnimation20200221shangcheng2/NewAnimation20200221shangcheng2.ExportJson"
M.hall_shop_tips_arm = prefix .. "ui/hall/animation/NewAnimation20200224scfb4/NewAnimation20200224scfb4.ExportJson"
M.hall_quick_start_arm = prefix .. "ui/hall/animation/NewAnimation20200221ksks3/NewAnimation20200221ksks3.ExportJson"
M.hall_gold_arm = prefix .. "ui/hall/animation/NewAnimation20200221jinbi1/NewAnimation20200221jinbi1.ExportJson"
------天天斗牛主页动效 end------

--分享图片
M.invite_img = prefix .. "ui/invite/invite_icon.png"
--微信分享图片
M.share_icon_img = prefix .. "ui/share/wxshare_icon.png"

M.chat_shop_icon = prefix .. "ui/game_chat/chat_shop_icon.png"--
M.chat_prop_icon = prefix .. "ui/game_chat/chat_prop_icon.png"--

M.game_text_reconnect = prefix .. "ui/game//text_reconnect.png"

M.shop_channel_app = prefix .. "ui/shop/channel_apple.png"
M.shop_channel_duanxin = prefix .. "ui/shop/channel_duanxin.png"
M.shop_channel_zhifubao = prefix .. "ui/payMethod/channel_zhifubao.png"
M.shop_channel_weixin = prefix .. "ui/payMethod/channel_weixin.png"
M.shop_channel_bank = prefix .. "ui/shop/channel_bank.png"
M.shop_channel_qq = prefix .. "ui/shop/channel_qq.png"


M.pay_item_wx = prefix .. "ui/global/pay_item_wx.png"
M.pay_item_zfb = prefix .. "ui/global/pay_item_zfb.png"
M.pay_item_yl = prefix .. "ui/global/pay_item_yl.png"
M.pay_item_as = prefix .. "ui/global/pay_item_as.png"

M.pay_item_wx_0 = prefix .. "ui/global/pay_item_wx_0.png"
M.pay_item_zfb_0 = prefix .. "ui/global/pay_item_zfb_0.png"
M.pay_item_yl_0 = prefix .. "ui/global/pay_item_yl_0.png"
M.pay_item_as_0 = prefix .. "ui/global/pay_item_as_0.png"

M.pay_item_img_wx = prefix .. "ui/global/pay_img_wx.png"
M.pay_item_img_zfb = prefix .. "ui/global/pay_img_zfb.png"
M.pay_item_img_yl = prefix .. "ui/global/pay_img_yl.png"
M.pay_item_img_as = prefix .. "ui/global/pay_img_as.png"

M.radio_btn_selected = prefix .. "ui/global/radio_btn_selected.png"
M.radio_btn_unselected = prefix .. "ui/global/radio_btn_unselected.png"

M.shoppromit_item_selected_frame = prefix .. "ui/global/item_selected.png"

-----------------------------------------------------礼物记录start------------------------------
M.giftRebateJson = prefix .. "ui/rebate.json"--
-----------------------------------------------------礼物记录end------------------------------

----------------------------------------新的美女start.............................................
M.beauty_new_beauty = prefix .. "ui/beauty/beauty_new_beauty.png" --美女
M.beauty_new_word = prefix .. "ui/beauty/beauty_new_beauty.png" --美女
M.beauty_auth1 = prefix .. "ui/beauty/sex_auth1_img1.png" --
M.beauty_head_bg = prefix .. "ui/beauty/bg_recent_auth_photo.png"
M.beauty_add_photo = prefix .. "ui/beauty/beauty_add_photo.png"
M.beaury_share_icon = prefix .. "ui/beauty/beauty_share_img.jpg"
M.beauty_item_gl_bg = prefix .. "ui/beauty/beauty_item_gl_bg.png"
M.beauty_item_normal_bg = prefix .. "ui/main/main_rank_item_bg.png"
M.beauty_txt_1 = prefix .. "ui/beauty/beauty_apply_word.png" -- 申请认证
M.beauty_txt_2 = prefix .. "ui/beauty/beauty_ing_word.png" -- 认证中
M.beauty_txt_3 = prefix .. "ui/beauty/beauty_fail_word.png" -- 申请失败
M.beauty_txt_4 = prefix .. "ui/beauty/beauty_success_word.png" -- 认证成功
----------------------------------------新的美女end.............................................



M.customize_coin_test = prefix .. "ui/shop/shop_coin.png"
M.customize_entry_animation = prefix .. "share/animation/customize/sirendonghua.ExportJson"
M.customize_entry_animation_texture = prefix .. "share/animation/customize/sirendonghua0.plist"

M.text_addfriend = prefix .. "ui/global/text_addfriend.png"
M.text_deletfriend = prefix .. "ui/global/text_deletfriend.png"
M.text_tiaozhan = prefix .. "ui/global/text_tiaozhan.png"

M.share_logo_danji = prefix .. "ui/customize_gameresult/share_logo_danji.png"
M.share_logo_tiantian = prefix .. "ui/customize_gameresult/share_logo_tiantian.png"

M.gift_wing_envelop = prefix .. "share/animation/giftAnimation/gift_wing_envelop.png"
M.gift_wing_left = prefix .. "share/animation/giftAnimation/gift_wing_left.png"
M.gift_wing_right = prefix .. "share/animation/giftAnimation/gift_wing_right.png"

M.device_wifi_strength = prefix .. "ui/device/wifi_strength_%d.png"--wifi信号强度
M.device_gprs_strength = prefix .. "ui/device/gprs_strength_%d.png"--gprs信号强度
M.device_battery_frame = prefix .. "ui/device/battery_frame.png"--电池图标
M.device_battery_level = prefix .. "ui/device/battery_level.png"--电池电量
M.device_battery_low_power = prefix .. "ui/device/battery_low_power.png"--电池低电
M.device_info_bg = prefix .. "ui/device/device_info_bg.png"--设备信息底图

M.levelup_animations = prefix .. "ui/levelup/arrow_animation_%d.png"

M.img_user_info_my_sex = prefix .. "ui/change_userinfo/img_sex_%d.png"
M.btn_user_info_edit_sure = prefix .. "ui/change_userinfo/btn_edit_sure.png"
M.btn_user_info_edit = prefix .. "ui/userinfo/gameinfo/eid.png"
M.userinfo_cardBg  = prefix .. "ui/userinfo/gameinfo/img_max_card_frame.png"
M.userinfo_cardBg1 = prefix .. "ui/userinfo/gameinfo/img_max_card_frame1.png"


--特效控件
M.common_widget_beam = prefix .. "ui/common/beam.png"
M.common_widget_meteor_particle = prefix .. "ui/common/par_hot_star.plist"
M.common_widget_dark_bg = prefix .. "ui/common/temp_blur.png" --临时用的弹框背景，用于windows调试
M.common_widget_back_btn = prefix .. "ui/global/global_back_up_btn.png"
M.common_tips_image_name_1 = "tool_tips_title.png"
M.common_tips_image_name_2 = "new_version_title_txt.png"

--积分兑换默认图片
M.score_exchange_default_img = prefix .. "ui/exchange/img/16.png"


M.global_confirm_button_351x113 = prefix .. "ui/global/btn_normal_351x113_y.png"
M.global_cancel_button_351x113 = prefix .. "ui/global/btn_normal_351x113_n.png"



--手机绑定弹框

M.global_btn_green = prefix .. "ui/global/btn_green.png"
M.global_btn_gray = prefix .. "ui/global/btn_gray.png"


--获取钻石弹窗
M.global_got_diamond_ani_json = prefix .. "share/animation/diamond/NewAnimation123.ExportJson"
M.global_got_diamond_ani_buygoldbg = prefix .. "share/animation/diamond/buygoldbg.png"
M.global_got_diamond_title_shape = prefix .. "share/animation/diamond/title_clipping.png"
M.global_got_diamond_title_beam = prefix .. "share/animation/diamond/beam.png"
M.global_got_diamond_plus_symbol = prefix .. "ui/global/diamond_plus.png"
M.global_diamond_text = prefix .. "ui/shop/img_txt_diamond.png"
M.global_diamond_num_atlas = prefix .. "ui/shop/img_diamond_word.png"
M.global_gold_text = prefix .. "ui/shop/img_txt_diamond2.png"
M.global_gold_num_atlas = prefix .. "ui/shop/img_diamond_word21.png"
M.change_userinfo_right_btn = prefix .. "ui/change_userinfo/change_userinfo_right_btn.png"

M.break_hide_card_icon = prefix .. "ui/userinfo/break_hide/break_hide_card.png"
M.shop_break_hide_card = prefix .. "ui/shop/shop_break_hide_card.png"
M.shop_break_hide_card_title = prefix .. "ui/shop/img_title_break_hide.png"
M.break_hide_card_using_icon = prefix .. "ui/userinfo/break_hide/break_hide_icon.png"
M.break_hide_card_using_icon_ingame = prefix .. "ui/userinfo/break_hide/break_hide_icon_ingame.png"
M.break_hide_bg = prefix .. "ui/userinfo/break_hide/break_hide_bg.png"
M.break_hide_btn_title = prefix .. "ui/userinfo/break_hide/break_hide_btn_title.png"
M.break_hide_page_light = prefix .. "ui/change_userinfo/change_userinfo_sng_light.png"

M.btn_normal_175_72 = prefix .. "ui/global/btn_normal_175_72.png"

M.login_bg = prefix .. "ui/pc_login/login_bg.png"
M.loading_review_bg = prefix .. "ui/global/bg_login2.jpg"

M.login_1 = prefix .. "share/animation/login/login_1.png"
M.login_2 = prefix .. "share/animation/login/login_2.png"
M.login_3 = prefix .. "share/animation/login/login_3.png"
M.login_4 = prefix .. "share/animation/login/login_4.png"
M.btn_show_pwd = prefix .. "ui/login/btn_show_pwd.png"
M.btn_hide_pwd = prefix .. "ui/login/btn_hide_pwd.png"


M.mask_png = prefix .. "share/game/game_mask_a.png"
M.sq_mask_png = prefix .. "share/game/game_mask_a_square.png"
M.blank_content = prefix .. "share/game/blank_content.png"

M.DAILY_LOGIN_POP = prefix .. "ui/dailylogin.json" -- 每日登陆奖励 
M.DAILY_LOGIN_Get = prefix .. "ui/daily/mrdl_01_01.png" -- 每日登陆奖励 
M.DAILY_LOGIN_Today = prefix .. "ui/daily/mrdl_01_02.png" -- 每日登陆奖励 
M.Gold_pis = prefix .. "share/coin/%d.png"
M.Gold_plist = prefix .. "share/coin/gold.plist"
M.Gold_plist_png = prefix .. "share/coin/gold.png"
M.DAILY_REWARD_LIGHT = prefix .. "ui/armature_anim/Login-to-reward/Login-to-reward.ExportJson" --领奖星星
M.DAILY_REWARD = prefix .. "ui/armature_anim/Login-to-reward01/Login-to-reward01.ExportJson" --领奖动画
M.DAILY_REWARD_2 = prefix .. "ui/armature_anim/Login-to-reward02/Login-to-reward02.ExportJson" --领奖动画

M.login_plist = prefix .. "share/animation/login/login.plist"
M.login_png = prefix .. "share/animation/login/login.png"


M.install_games = prefix .. "ui/install_game_pop.json" -- 安装游戏
M.Peng_gold_sound = prefix .. "music/peng.mp3" -- 喷金币声音



M.EMOJI01 = prefix .. "share/animation/emoji/smiley8/smiley8.ExportJson"
M.EMOJI_LIST_01 = prefix .. "share/animation/emoji/smiley8/smiley80.plist"
M.EMOJI02 = prefix .. "share/animation/emoji/smiley9/smiley9.ExportJson"
M.EMOJI_LIST_02 = prefix .. "share/animation/emoji/smiley9/smiley90.plist"
M.EMOJI03 = prefix .. "share/animation/emoji/smiley10/smiley10.ExportJson"
M.EMOJI_LIST_03 = prefix .. "share/animation/emoji/smiley10/smiley100.plist"
M.EMOJI04 = prefix .. "share/animation/emoji/smiley11/smiley11.ExportJson"
M.EMOJI_LIST_04 = prefix .. "share/animation/emoji/smiley11/smiley110.plist"
M.EMOJI05 = prefix .. "share/animation/emoji/smiley12/smiley12.ExportJson"
M.EMOJI_LIST_05 = prefix .. "share/animation/emoji/smiley12/smiley120.plist"
M.EMOJI06 = prefix .. "share/animation/emoji/smiley13/smiley13.ExportJson"
M.EMOJI_LIST_06 = prefix .. "share/animation/emoji/smiley13/smiley130.plist"





--首充部分
M.SHOUCHONG = prefix .. "share/animation/shouchong/shouchong.ExportJson"
M.SHOUCHONGJIEMIAN = prefix .. "share/animation/shouchong/shouchongdonghua.ExportJson"
M.firstpoint = prefix .. "ui/firstpay/red_01.png"
M.ShouChongZheZhao = prefix .. "ui/firstpay/sc_0005_08.png"
M.Firstpay = prefix .. "ui/firstpay_1.json"
--超值礼包
M.ChaoZhiLiBao = prefix .. "share/animation/ChaoZhiLiBao/ChaoZhi.ExportJson"
M.ChaoZhipay = prefix .. "ui/chaozhipay.json"
M.CHAOZHIJIEMIAN = prefix .. "share/animation/ChaoZhi/ChaoZhiLiBao.ExportJson"

M.HOTGAMEICON = prefix .. "ui/hall/Front_hal_006_11.png"

M.WinningStreak = prefix .. "ui/WinningStreak.json"--连胜
M.WinningStreakPng1 = prefix .. "ui/winningstreak/lyfx_0002_07.png"--3连胜
M.WinningStreakPng2 = prefix .. "ui/winningstreak/lyfx_0002_08.png"--5连胜
M.WinningStreakPng3 = prefix .. "ui/winningstreak/lyfx_0002_09.png"--10连胜
M.WinningStreakJpg1 = prefix .. "ui/winningstreak/lyfx_0003_07.jpg"--3连胜分享
M.WinningStreakJpg2 = prefix .. "ui/winningstreak/lyfx_0003_08.jpg"--5连胜分享
M.WinningStreakJpg3 = prefix .. "ui/winningstreak/lyfx_0003_09.jpg"--10连胜分享

M.LackGold = prefix .. "ui/LackGold.json" --没钱进游戏弹框

M.hallGameImage = {
    prefix .. "ui/hall/btn_jingdian_zhajinhua",
    prefix .. "ui/hall/btn_douniu",
    prefix .. "ui/hall/btn_zhajinniu",
    prefix .. "ui/hall/btn_texas",
    prefix .. "ui/hall/btn_jingdian_zhajinhua",
    prefix .. "ui/hall/btn_longhudou",
    prefix .. "ui/hall/btn_jingdian_zhajinhua",
    prefix .. "ui/hall/btn_zhajinhua",
    prefix .. "ui/hall/btn_ddz",
    prefix .. "ui/hall/btn_baijiale",
    prefix .. "ui/hall/btn_brnn",
}

M.InteractiveExpression = prefix .. "ui/InteractiveExpression.json" --互动表情
M.chat_animation_bingtong = prefix .. "ui/game_chat/animation/bingtong.ExportJson" -- bingtong动画
M.chat_animation_dayu = prefix .. "ui/game_chat/animation/dayu.ExportJson" -- dayu动画
M.chat_animation_niubei = prefix .. "ui/game_chat/animation/niubei.ExportJson" -- niubei动画
M.chat_animation_zhuaji = prefix .. "ui/game_chat/animation/zhuaji.ExportJson" -- zhuaji动画
M.chat_animation_xihongshi = prefix .. "ui/game_chat/animation/xihongshi.ExportJson" -- xihongshi动画
M.chat_animation_dianzan = prefix .. "ui/game_chat/animation/dianzan.ExportJson" -- 玫瑰动画
M.chat_animation_meigui = prefix .. "ui/game_chat/animation/meigui.ExportJson" -- 点赞动画

M.interactPhizSmall = prefix .. "ui/game_chat/interact_phiz_%s.png" -- 小互动表情
M.interactPhizReady001 = prefix .. "ui/game_chat/phiz_ready/phiz_001.png"
M.interactPhizReady002 = prefix .. "ui/game_chat/phiz_ready/phiz_002.png"
M.interactPhizReady003 = prefix .. "ui/game_chat/phiz_ready/phiz_003.png"
M.interactPhizReady004 = prefix .. "ui/game_chat/phiz_ready/phiz_004.png"
M.interactPhizReady005 = prefix .. "ui/game_chat/phiz_ready/phiz_005.png"
M.interactPhizReady006 = prefix .. "ui/game_chat/phiz_ready/phiz_006.png"
M.interactPhizReady007 = prefix .. "ui/game_chat/phiz_ready/phiz_007.png"
M.interactPhizReady008 = prefix .. "ui/game_chat/phiz_ready/phiz_008.png"

M.phiz_py_daoshui = prefix .. "ui/game_chat/phiz_ready/phiz_006.mp3"

M.QuicklyChat = prefix .. "ui/QuicklyChat.json"--快捷聊天


M.downChooseImg = prefix .. "ui/lackgold/pcbz_0008_03.png"--向下的三角形（用于选择支付方式显示和隐藏）
M.upChooseImg = prefix .. "ui/lackgold/pcbz_0008_04.png"--向上的三角形（用于选择支付方式显示和隐藏）

M.NewBankruptcyJson = prefix .. "ui/newbankruptcy.json"--新破产补助

--好友提示
M.FirendTipsJson = prefix .. "ui/FriendTips.json"--请求成功微笑图片
M.FirendTips_TipsYes = prefix .. "ui/friendtips/hyfk_0002_04.png"--请求成功微笑图片
M.FirendTips_TipsNo = prefix .. "ui/friendtips/hyfk_0001_05.png"--请求失败沮丧图片
M.FirendTips_ResTitle = prefix .. "ui/friendtips/hyfk_qu_0004_03.png"--好友请求标题图片
M.FirendTips_TipsTitle = prefix .. "ui/friendtips/hyfk_0003_03.png"--好友提示图片


--大转盘
M.TURNTABLE = prefix .. "share/animation/zp_icon/zp_icon.ExportJson"
M.TURNTABLEIcon0 = prefix .. "ui/TurnTable/dtzp__0009_02.png"
M.TURNTABLEIcon1 = prefix .. "ui/TurnTable/dtzp__0009_03.png"
M.TurnTableJson = prefix .. "ui/TurnTable.json"
M.img_TurnTable_shape = prefix .. "ui/TurnTable/zp__0005_07.png"--欢乐转盘特效
M.TURNTABLELight0 = prefix .. "ui/TurnTable/zp_light01.png"
M.TURNTABLELight1 = prefix .. "ui/TurnTable/zp_light02.png"
M.TURNTABLEOVER = prefix .. "share/animation/Get-the-success02/Get-the-success01.ExportJson"
M.shop_diamond2 = prefix .. "ui/shop/img_buy_diamond_2.png"--2个钻是
M.shop_diamond5 = prefix .. "ui/shop/img_buy_diamond_3.png"--5个钻石
M.shop_diamond20 = prefix .. "ui/shop/img_buy_diamond_6.png"--一箱钻石
M.TurnTableGoldCard = prefix .. "ui/TurnTable/shop_monthcard.png"--金卡
M.TurnTableSliverCard = prefix .. "ui/TurnTable/shop_weekcard.png"--银卡
M.TurnTableGold0 = prefix .. "ui/TurnTable/zp_lq_12.png"--金币
M.TurnTableGold1 = prefix .. "ui/TurnTable/zp_lq_11.png"--金币
M.TurnTableGold2 = prefix .. "ui/TurnTable/zp_lq_13.png"--金币
M.TurnTableGold3 = prefix .. "ui/TurnTable/zp_lq_10.png"--金币
M.TurnTableBgLight = prefix .. "ui/TurnTable/zp_lq_02.png"--背景光

M.FirstGameJson = prefix .. "ui/FirstGame.json"
M.NewsLeadJson = prefix .. "ui/NewsLead.json"


--累计登陆
M.NewTotalLoginJson = prefix .. "ui/NewTotalLogin.json"
M.NewTotalLoginAniPlist = prefix .. "ui/newtotallogin/newtotallogin.plist"
M.NewTotalLoginAniPng = prefix .. "ui/newtotallogin/newtotallogin.png"
M.ljdl_gift_icon = prefix .. "ui/newtotallogin/ljdl_gift%d_%d.png"--图标
M.ljdl_gift_prize = prefix .. "ui/newtotallogin/ljdl_prize%d_%d.png"--礼物
M.ljdl_gift_day = prefix .. "ui/newtotallogin/ljdl_day%d_%d.png"--天数
M.ljdl_main_icon1 = prefix .. "ui/newtotallogin/box1.png"--大厅icon
M.ljdl_main_icon2 = prefix .. "ui/newtotallogin/box2.png"--大厅icon
M.ljdl_dia_gold = prefix .. "ui/newtotallogin/img_buy_diamond_2.png"--钻石加金币
M.NEWTOTALLOGINOVER = prefix .. "share/animation/Get-the-success03/Get-the-success.ExportJson"
M.NEWTOTALLOGINOVERImg = prefix .. "ui/newtotallogin/zp_lq_15.png"--鸿运当头
M.ljdl_main_dian = prefix .. "ui/NewsLead/yddhk_006.png"--大厅点

--广播
M.BroadcastSystemImg = prefix .. "ui/laba/yddhk_009.png"--系统广播图片
M.BroadcastLabaImg = prefix .. "ui/laba/yddhk_010.png"--系统广播图片
M.BroadcastHuaImg = prefix .. "ui/laba/yddhk_012.png"--系统广播图片
M.BroadcastLineImg = prefix .. "ui/laba/line.png"--系统广播图片
M.BroadcastGuangBoImg = prefix .. "ui/laba/gg_laba01.png"--系统广播图片


M.Review_hall_shop = prefix .. "ui/hall/Front-hall_0015_18.png"
M.Review_hall_quickStart = prefix .. "ui/hall/ksks_01.png"

--新用户随机头像
M.DefaultHead = prefix .. "share/defaultUserHead/ourhead%d_%d.png"--系统广播图片

--免费金币快捷领取
M.FreeGoldShortCutJson = prefix .. "ui/FreeGoldShortCut.json"

--大厅单包上面游戏入口
M.MainSigleGame = prefix .. "ui/hall/sigleGames%d_%d.png"
--大厅单包房间入口
M.MainSigleRoom = prefix .. "ui/hall/zjh_syanniu0%d.png"

--游客提示
M.VisitorTipsJson = prefix .. "ui/VisitorTips.json"

--提示弹窗
M.toolTipsJson = prefix .. "ui/toolTips.json"
M.game_win_font = prefix .. "game_texas/game/win_word_number.png"

M.game_win_anim_bk_all = prefix .. "game_texas/game/game_win_anim_bk_all.png"
M.game_win_anim_wz_01 = prefix .. "game_texas/game/game_win_anim_wz_01.png"
M.game_result_star = prefix .. "game_texas/game/game_result_star.png"

M.pop_win = prefix .. "game_texas/game/victory_pop.png"

--游戏公告弹窗
M.game_quit_pop         = prefix.."ui/game_quit.json"    -- 被踢弹框

--游戏公告弹窗
M.gameHallJSON         = prefix.."game_common/gameHall/gameHall.json"    -- 被踢弹框
M.gameHallPlist         = prefix.."game_common/gameHall/zjh_hall/gameHall.plist"
M.gameHallPng         = prefix.."game_common/gameHall/zjh_hall/gameHall.png"
M.gameHallTitle_ZJH     = "gamehall_Titile_zhajinhua.png"--游戏大厅标题
M.gameHallTitle_DN     = "gamehall_Titile_douniu.png"--游戏大厅标题
M.gameHallTitle_ZJN     = "gamehall_Titile_zhajinniu.png"--游戏大厅标题
M.gameHallTitle_DDZ     = "gamehall_Titile_ddz.png"--游戏大厅标题

--新选场页面
M.gameNewHallJSON         = prefix.."game_common/gameNewHall/gamehall.json"    -- 被踢弹框

M.changci_1 = "gamehall__0005_01.png"  --新手场
M.changci_2 = "gamehall__0004_02.png"  --初级场
M.changci_3 = "gamehall__0003_03.png"  --中级场
M.changci_4 = "gamehall__0002_04.png"  --高级场
M.changci_5 = "gamehall__0001_05.png"  --伯爵场
M.changci_6 = "gamehall__0000_06.png"  --尊爵场
M.quick_start_anim ="gamehall_Front_hal_012_05.png"--快速开始光效
M.payloadingbg = "ui/shop/load_bgtwo.png"
M.payloadingtxt = "ui/shop/new loading.png"

M.gameTableJSON         = prefix.."game_common/gameTableHall/game_table_hall.json"    -- 被踢弹框

--小车动画
M.gift_carAni1 = prefix.."share/gift_car/git_carAni1/qiche_jiakechong.ExportJson"
M.gift_carAni2 = prefix.."share/gift_car/git_carAni2/qiche_lanbo.ExportJson"
M.gift_car1 = prefix.."share/gift_car/gift_car%d.png"
M.gift_carBtn = prefix.."share/gift/%d_s.png"
M.gift_carEle1 = prefix.."share/gift_car/gift_carEle1.png"
M.gift_carEle2 = prefix.."share/gift_car/gift_carEle2_%d.png"
M.gift_carEle3 = prefix.."share/gift_car/gift_carEle3_%d.png"
M.gift_carTxtBg = prefix.."share/gift_car/gift_tipsbg.png"
M.gift_carName = prefix.."share/gift_car/gift_carName%d.png"

--大厅游戏按钮图
M.hallGameBg = "%s%d.png"--按钮背景

--菜单按钮图片
M.menuImg = prefix.."ui/player_rule/btnMenu.png"
M.guildImg = prefix .. "ui/guide/%d.png"
M.defaultZhuangImg = prefix .. "ui/game/defaultZhuang.png" --默认庄家头像
M.defaultZhuangCircleImg = prefix .. "ui/game/defaultZhuangCircle.png" --默认庄家头像

M.ruleZJH = prefix.."ui/player_rule/zjhTxt.png"
M.ruleLHD = prefix.."ui/player_rule/lhdTxt.png"
M.ruleBR = prefix.."ui/player_rule/brTxt.png"
M.ruleDN = prefix.."ui/player_rule/douTxt.png"
M.ruleZJN = prefix.."ui/player_rule/zjnTxt.png"
M.ruleDDZ = prefix.."ui/player_rule/ddzTxt.png"
M.ruleBRNN = prefix.."ui/player_rule/brnnTxt.png"
M.ruleBJL = prefix.."ui/player_rule/bjlTxt.png"

-----------------GameCommon---------------------
M.game_common_add_money_fnt = "game_common/ui/font/add_123-export.fnt"
M.game_common_reduce_money_fnt = "game_common/ui/font/Reduction_123-export.fnt"
M.game_coomon_win_money_back = "game_common/ui/winmoneyback.png"
M.game_coomon_reduce_money_back = "game_common/ui/lose-01.png"

M.xuanchangAni = "game_common/gameNewHall/animation/NewAnimation0307xuancLAN/NewAnimation0307xuancLAN.ExportJson"
M.brnnChooseRoomAni = "game_common/gameNewHall/animation/NewAnimation0318BRNN/NewAnimation0318BRNN.ExportJson"
M.quickStartAni = "game_common/gameNewHall/animation/NewAnimation0311KSKS/NewAnimation0311KSKS.ExportJson"
M.qznn1 = "game_common/gameNewHall/gameHall/animation_got_qznn1.png"
M.qznn2 = "game_common/gameNewHall/gameHall/animation_got_qznn2.png"
M.qznn3 = "game_common/gameNewHall/gameHall/animation_got_qznn3.png"
M.ddz1 = "game_common/gameNewHall/gameHall/animation_got_nm1.png"
M.ddz2 = "game_common/gameNewHall/gameHall/animation_got_nm2.png"
M.ddz3 = "game_common/gameNewHall/gameHall/animation_got_nm3.png"
M.jinniu1 = "game_common/gameNewHall/gameHall/animation_got_jiniu1.png"
M.jinniu2 = "game_common/gameNewHall/gameHall/animation_got_jiniu2.png"
M.jinniu3 = "game_common/gameNewHall/gameHall/animation_got_jiniu3.png"
M.jinhua1 = "game_common/gameNewHall/gameHall/animation_got_jinhua1.png"
M.jinhua2 = "game_common/gameNewHall/gameHall/animation_got_jinhua2.png"
M.jinhua3 = "game_common/gameNewHall/gameHall/animation_got_jinhua3.png"

M.qznnTxt = "game_common/gameNewHall/gameHall/niuniu.png"
M.zjnTxt = "game_common/gameNewHall/gameHall/zjn.png"
M.zjhTxt = "game_common/gameNewHall/gameHall/zjh.png"
M.ddzTxt = "game_common/gameNewHall/gameHall/ddz.png"
M.brnnTxt = "game_common/gameNewHall/gameHall/brnn.png"

--公用筹码
M.chip_red_path = "game_common/component/chip/red"
M.chip_green_path = "game_common/component/chip/green"
M.chip_orange_path = "game_common/component/chip/orange"
M.chip_blue_path = "game_common/component/chip/blue"
M.chip_purple_path = "game_common/component/chip/purple"
M.chip_grayblue_path = "game_common/component/chip/grayblue"
M.chip_big_num_path = "game_common/component/chip/bigNumber"

--庄家列表、无座玩家
M.delarListJson = "game_common/ui/delarList.json"
M.noSeatJson = "game_common/ui/no_seat_layer.json"
M.game_btn_not_want_be_delar_txt = "game_common/ui/noseat_delarlist/btn_br_down_txt.png"
M.game_btn_want_be_delar_txt = "game_common/ui/noseat_delarlist/btn_br_up_txt.png"

--游戏pocker、扑克牌
M.poker_back_small_img_name = "poker_card_back_small.png"
M.poker_back_small_img_name_1 = "poker_card_back_small_1.png"
M.poker_back_big_img_name = "poker_card_back_big.png"
M.poker_plist = "game_common/component/pocker/lhd_card.plist"
M.poker_plist_png = "game_common/component/pocker/lhd_card.png"

--商城标识
M.shop_bank_path = "ui/shop/BANK_PNG.png"
M.shop_wx_path = "ui/shop/WX_PNG.png"
M.shop_zfb_path = "ui/shop/ZFB_PNG.png"
M.shop_ysf_path = "ui/shop/YSF_PNG.png"
--设置界面
M.setting_btn_off = "ui/setting/btn_off.png"
M.setting_btn_on = "ui/setting/btn_open.png"

--保险箱
M.safeBox_deposit = "ui/safebox/deposit.png"
M.safeBox_fetch2 = "ui/safebox/fetch2.png"
M.safeBox_fetch = "ui/safebox/fetch.png"
M.safeBox_image_in3 = "ui/safebox/image_in3.png"
M.safeBox_image_out3 = "ui/safebox/image_out3.png"
M.safeBox_fetch = "ui/safebox/fetch.png"
M.safeBox_deposit2 = "ui/safebox/deposit2.png"

--商城
M.shop_image_1 = "ui/shop/ch_bank.png"
M.shop_image_2 = "ui/shop/ch_bank_title2.png"
M.shop_image_3 = "ui/shop/ch_zfb_img.png"
M.shop_image_4 = "ui/shop/ch_zfb_title2.png"
M.shop_image_5 = "ui/shop/ch_wx_img.png"
M.shop_image_6 = "ui/shop/ch_wx_title2.png"
M.shop_image_7 = "ui/shop/ch_wx_img2.png"
M.shop_image_8 = "ui/shop/ch_wx_title.png"
M.shop_image_9 = "ui/shop/ch_zfb_img2.png"
M.shop_image_10 = "ui/shop/ch_zfb_title.png"
M.shop_image_11 = "ui/shop/ch_bank2.png"
M.shop_image_12 = "ui/shop/ch_bank_title.png"
M.shop_image_13 = "ui/shop/recommend.png"
M.shop_image_14 = "ui/shop/ch_wx_small_title.png"
M.shop_image_15 = "ui/shop/ch_wx_small_title2.png"
M.shop_image_16 = "ui/shop/ch_zfb_small_title.png"
M.shop_image_17 = "ui/shop/ch_zfb_small_title2.png"
M.shop_image_18 = "ui/shop/ch_ysf_img.png"
M.shop_image_19 = "ui/shop/ch_ysf_title.png"
M.shop_image_20 = "ui/shop/ch_ysf_title2.png"
M.shop_image_21 = "ui/shop/ch_zs_img.png"
M.shop_image_22 = "ui/shop/ch_zs_title.png"
M.shop_image_23 = "ui/shop/ch_zs_title2.png"


--提现
M.exchange_1 = "tianxian_yhktx.png"
M.exchange_2 = "tianxian_yhktx2.png"
--玩家信息
M.player_image_1 = "ui/personal/image_base_info_normal.png"
M.player_image_2 = "ui/personal/image_game_record_select.png"
M.player_image_3 = "ui/personal/image_pay_record_select.png"
M.player_image_4 = "ui/personal/image_base_info_select.png"
M.player_image_5 = "ui/personal/image_game_record_normal.png"
M.player_image_6 = "ui/personal/image_pay_record_normal.png"
M.player_image_7 = "ui/personal/image_find_pay_pwd.png"
M.player_image_8 = "ui/personal/wallet_record_normal.png"
M.player_image_9 = "ui/personal/wallet_record_select.png"

M.icon_flag_1 = "record_pay_img_zfb.png"
M.icon_flag_2 = "record_pay_img_yl.png"
M.icon_flag_3 = "record_weixin.png"
M.icon_flag_4 = "record_playcard.png"
M.icon_flag_5 = "record_shangfen.png"
M.icon_flag_6 = "record_safebox.png"
M.icon_flag_7 = "record_tixian.png"
M.icon_flag_8 = "record_xaifen.png"
M.icon_flag_9 = "record_ysf.png"
M.icon_flag_10 = "record_schb.png"
M.icon_flag_11 = "record_txfl.png"

M.fnt_score_1 = "ui/personal/font/blue.fnt"
M.fnt_score_2 = "ui/personal/font/green.fnt"
M.fnt_score_3 = "ui/personal/font/red.fnt"

--客服
M.custom_image_1 = "ui/safebox/kf_zx.png"
M.custom_image_2 = "ui/safebox/kf_zxjl1.png"
M.custom_image_3 = "ui/safebox/kf_zx2.png"
M.custom_image_4 = "ui/safebox/kf_zxjl2.png"

M.global_image_1 = "ui/global/image_line.png"

M.chipAnimate = prefix .. "game_common/component/animation/NewAnimation0506CMXZ/NewAnimation0506CMXZ.ExportJson"
M.betAnimate = prefix .. "game_common/component/animation/NewAnimation20200226ksxz/NewAnimation20200226ksxz.ExportJson"


M.red_point_image = prefix .. "ui/hall/redPoint.png"
M.gold_new_img = "ui/global/gold_new_301.png"

M.phone_country_code = "other/phoneCode.csv"

M.new_image_item_select = prefix .. "ui/personal/medium_blue_di.png"
M.new_image_item_normal = prefix .. "ui/personal/medium_dark_di2.png"


M.yellow_game_table = "game_niuniu_table_1.png"
M.blue_game_table_NN = "game_niuniu_table_2.png"
M.blue_game_table = "game_zjh_table_2.png"
M.red_game_table = "game_zjh_table_1.png"

M.agency_qq_img = prefix .. "ui/agency/qq.png"
M.agency_wx_img = prefix .. "ui/agency/wx.png"

M.hongbao_open = prefix .. "ui/hongbao/openhb.png"
M.hongbao_open_disable = prefix .. "ui/hongbao/openhb_disable.png"
M.hongbao_go = prefix .. "ui/hongbao/gotopay.png"
--------客服聊天相关---------
M.customer_chat_loadImage_fail = "load_img_fail.png"
M.customer_wx = "wechat_info.png"
M.customer_qq = "qq_info.png"
M.customer_msg_alert_line = "ui/customer_chat/customer_diban_line.png"


M.reviewMainViewJson = "ui/review_hall_layer.json"
M.reviewSettingJson = "ui/review_setting_layer.json"
M.reviewPersonJson = "ui/review_personal_info_layer.json"
M.reviewLuckJson = "ui/review_luck_layer.json"
M.reviewNewActivityJson = "ui/review_activity_layer.json"
M.reviewSafeBoxJson = "ui/review_safe_box_layer.json"
M.reviewMessageBoxJson = "ui/review_message_box_layer.json"
M.reviewMailJson = "ui/review_mall_layer.json"
M.reviewShopJson = "ui/review_shop_layer.json"
M.wifi1 = "ui/signal/wifi1.png"
M.wifi2 = "ui/signal/wifi2.png"
M.wifi3 = "ui/signal/wifi3.png"
M.signal1 = "ui/signal/signal1.png"
M.signal2 = "ui/signal/signal2.png"
M.signal3 = "ui/signal/signal3.png"
M.signal4 = "ui/signal/signal4.png"
M.reviewChangePwdJson = "ui/review_change_pwd_layer.json"

M.headMaskShopJson = "ui/head_mask_shop.json"
M.headMaskBagJson = "ui/head_mask_bag.json"

M.headMaskImage = "head_mask_image_%s_%s.png"
M.headMaskDefault = "game_hall_circle.png"
M.headMaskDefault_1 = "headkuan.png"
M.headMaskPlist = "ui/head_mask_shop/head_mask_gather_image.plist"
M.headMaskPng = "ui/head_mask_shop/head_mask_gather_image.png"
M.headMaskUseStatus = "head_mask_status_%s.png"

M.setting_btn_on_st = "onSt.png"
M.setting_btn_off_st = "offSt.png"
M.setting_btn_on_txt = "on.png"
M.setting_btn_off_txt = "off.png"

M.review_safeBox_deposit = "cunru.png"
M.review_safeBox_fetch2 = "quchu.png"
M.review_safeBox_fetch = "quchu3.png"
M.review_safeBox_image_in3 = "cunru2.png"
M.review_safeBox_image_out3 = "quchu2.png"
M.review_safeBox_deposit2 = "cunru3.png"

M.chat_info_cbtn = "ui/chat2/chat_info_chatbtn.png"

--------- game_guide ---------
M.guide_to_shop_image = "btn_go_shop.png"
M.guide_to_chat_image = "btn_go_chat.png"
M.guide_to_continue_image = "go_on_view.png"
M.guide_to_quit_image = "game_quit.png"
M.guide_to_quick_start_image = "quick_game_system.png"
--------- game_guide ---------

--------- mailview ---------
M.mail_unread_bg_name = "message_unread_bg.png"
M.mail_read_bg_name = "message_read_bg.png"
M.mail_unread_icon_name = "message_read_logo (2).png"
M.mail_read_icon_name = "message_read_logo (1).png"
--------- mailview ---------

GameRes = M
