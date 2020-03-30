
local M = {}

M.string001 = "思考中"
M.string002 = "弃牌"

M.string003 = "底池 : "


M.string004 = "all in"
M.string005 = "跟注"
M.string006 = "加注"
M.string007 = "看牌"
M.string101 = "亮牌"

M.string008 = {"高牌","对子","两对","三条","顺子","同花","葫芦","四条(金刚)","同花顺","皇家同花顺"}

M.string009 = "%s:%s号桌  %s"
M.game_must_spend_str = "  前注:%s"

M.string011 = "万"
M.string012 = "亿"
M.string013 = "千万"

--0 年 1 月 ("年","月","周","天","时","分")
M.TimerUnitStr = {
    "年","个月","周","天","小时","分钟"
};

--gameChat start--
M.game_chat_0 = {
    chatInfo_1 = "快点，我已经寂寞难耐了",
    chatInfo_2 = "想快点输你就全下吧",
    chatInfo_3 = "厉害啊，我一不小心就赢了好多",
    chatInfo_4 = "你是手滑了么？敢跟注我",
    chatInfo_5 = "打得不错，但下局没那么好运了",
    chatInfo_6 = "别怂！全部人都跟到底",
    chatInfo_7 = "这烂牌..根本停不下来",
    chatInfo_8 = "我全押，你敢跟吗？",
    chatInfo_9 = "牌小就不要跟我玩",
    chatInfo_10 = "不要走，决战到天亮",
    chatInfo_11 = "搏一搏，单车变摩托",
    chatInfo_12 = "请尊重Dealer"}
M.game_chat_1 = {
    chatInfo_1 = "你打牌怎么比女生还慢啊",
    chatInfo_2 = "太猴急了吧？人家想慢点打",
    chatInfo_3 = "敢跟注你姑姑，赢太多了吧",
    chatInfo_4 = "跟到底啦，人家喜欢真男人",
    chatInfo_5 = "怕了？真是胆小如鼠",
    chatInfo_6 = "烂牌天天有，今年特别多",
    chatInfo_7 = "我真不想说你，你个怂货",
    chatInfo_8 = "牌小就不要跟我玩",
    chatInfo_9 = "这都能赢？什么运气啊",
    chatInfo_10 = "不要走，决战到天亮",
    chatInfo_11 = "搏一搏，单车变摩托",
    chatInfo_12 = "请尊重Dealer"}
M.string632 = "请输入.."
M.string633 = {"/g", "/zz","/zy", "/cry","/cool",
        "/shit", "/naughty", "/speechless", "/angry","/sleep", 
        "/shy", "/crazy", "/happy", "/kiss", "/ama",
        "/knif", "/wow", "/ogle", "/gri","/h",
        "/ee", "/fist", "/love", "/pray", "/smile",
        "/hb","/yea","/whirr","/pitiful","/bye"}
M.string634 = {"/allin", "/help","/hi", "/feck","/check",
    "/aa", "/omg", "/you", "/no","/ha"}

M.string651 = "立即领取"
--gameChat end--

--new Shop start
M.string_shop_txt1 = "购买金额"
M.string_shop_txt3 = "道  具"
M.string_shop_txt2 = "兑换专区"
M.string_shop_item_txt1_2 = "金额"
M.string_shop_item_txt2 = "¥ 1"
M.string_shop_item_txt3 = "="
M.string_shop_item_txt4 = "%s金额"
M.string_shop_item_txt5 = "售价:%s元"
M.string_shop_item_txt6 = "(%s金额)"
M.string_yuan = "%s元"
M.string_shop_item_txt7 = "(%s张)"
M.string_rmb_to_diamond = "￥%d=%.1f钻石"
M.string_addmore_to_diamond = "1元=%q钻"
M.string_shop_item_txt8 = "首充多送%s"

M.string_pay_method_wx = "微信支付"
M.string_pay_method_zfb = "支付宝支付"
M.string_pay_method_yl = "银联支付"
M.string_pay_method_as = "Apple支付"

M.string_pay_status = "购买成功"

M.string_show_1 = "暂未开放"
M.string_show_2 = "请输入您要充值的金额"
M.string_show_3 = "点击过快，请稍后尝试"
M.string_show_4 = "请输入整数"
M.string_show_5 = "请输入大于%d的金额"
M.string_show_6 = "请输入小于%d的金额"
M.string_show_7 = "充值比例1元=100金额,"
M.string_show_8 = "充值比例1元=100金额，最低充值20元起"
M.string_show_9 = " 最低充值%d元起" 
M.string_show_10 = "请输入整数数字"
M.string_show_11 = "输入大于%d元~%d元的金额"
M.string_show_12 = "充值维护升级中，请稍后再试。"
M.string_show_13 = "请选择充值金额"
M.string_show_14 = "请求支付中"
M.string_show_15 = "支付订单失败"
M.string_show_16 = "切换中"
--new shop end

M.hot_loading_txt = "%.2f%% 游戏资源下载中..."
M.load001 = "加载中"
M.login001 = "努力加载中..."
M.main001 = "请求信息中..."

M.main002 = "总局数 : %d"
M.main003 = "入局率 : %d%%"
M.main004 = "胜率 : %d%%"
M.main005 = "最大赢取 : %s"
M.main006 = "最大手牌"
M.main007 = "%s个"
M.main008 = "%s元"

M.main002_hide = "总局数 :"
M.main003_hide = "入局率 :"
M.main004_hide = "胜率 :"
M.main005_hide = "最大赢取 :"
M.main006_hide = "最大手牌 :"

M.gameLoaddingTips001 = {
    "忍是为了下次all in",
    "你不能控制输赢,但能控制输赢的多少",
    "应该懂得什么时候放弃",
    "赌的不是运气,赢的是你的智慧",
    "冲动是魔鬼,心态好,运气自然来"
}

M.gameLoaddingTips002 = {
    "真正的绅士，不会谈论离别的女人和错过的底牌",
    "尊重对手就是尊重自己的钱包！",
    "软的怕硬的，硬的怕不要命的",
    "比赛8字口诀---先紧后松,先软后硬",
    "别指望狗屎运能给你带来胜利",
    "只要你活的比对手时间长你就赢了",
    "那个一直弃牌的傻瓜其实是才是能一口吞掉你的巨鲨",
    "装成保守的牌手，因为这样别人会把你的底牌想象的无限大",
    "打牌不偷鸡是不行的，老是偷鸡更是不行的",
    "不要只看到偷鸡成功的，还要看到有些为了鸡丧命的"
}
M.gameLoaddingTipTitle = "小贴士: "

--broadcast start
M.broadcast1= "恭喜%s在%s赢得金额%d万"
M.broadcast2= "恭喜%s在%s赢得金额%d"
M.broadcast_level3_0 = "恭喜"
M.broadcast_level3_1 = "" --广播占位
M.broadcast_level3_2 = "在"
M.broadcast_level3_3 = "" --广播占位
M.broadcast_level3_4 =  "赢得金额"
M.broadcast_level3_5 = "" --广播占位
M.broadcast_level3_6 = "万"
--broadcast end


M.string901 = "日常奖励"
M.string902 = "成就奖励"
M.string903 = "ID："
M.string904 = "昵称："
M.string905 = "性别："
M.string906 = "修改成功"
M.string907 = "名字不能为空"
M.string908 = "已经是第一页了"

M.login001 = "努力加载中..."
M.net002 = "加载中..."
M.reConnect = "网络恢复中..."
M.net003 = "正在处理..."
M.net004 = "网络异常，正在重连中..."

M.game201 = "游戏尚未结束，现在离开将不退还已下注金额，是否强行退出？"
M.game202 = "正在坐下..."
M.game203 = "等待游戏开始..."
M.game204 = "你确定要退出么？"
M.game205 = "确定"
M.game206 = "点错了"
M.game207 = "坐下失败，请稍后再试.."

M.login002 = "拉取服务器信息中"
M.login003 = "登录服务器中"
M.login004 = "拉取服务信息超时，请检查你的网络..."
M.login005 = "网络链接失败，请检查你的网络"
M.login006 = "登录失败，请尝试其他方式登录"
M.login007 = "    由于您的账号:%d存在异常，已被系统封停。"
M.login008 = "    由于您的账号存在异常，已被系统封停，如有疑问请联系客服。"
M.login009 = "    游戏正在维护中，会很快恢复哦！"
M.net005 = "拉取内容中..."
M.net006 = "处理订单中..."
M.nettimeout = "网络断开，请重新尝试"

M.task001 = "任务完成"
M.task002 = "您的金额+%s"
M.task003 = "您成功获取了%s金额"
M.task005 = "您成功领取了%s金额"
M.task002_new = "您拥有的金额达到:%s"
M.task003_new = "获得奖励:"
M.task004 = "您成功获取了%s钻石"

--支付提示框 start--
M.global_exitStr = "您已退出了房间"
M.global_exit_desk_failed = "退桌失败. 错误码:%d"
M.global_request_timeout = "请求超时"
--支付提示框 end--


M.game_level_txt="亲，又赢了！！！您的资产已经达到了%s,这种小场已经不适合您这种赌神了，赶紧去高级场挑战德州高手赢取更多金额吧！"
M.game_level_challenge="现在就去"
M.game_level_cancel="我不想去"

M.giftname = {"玫瑰花","雞蛋","跑車","別墅","游艇"}
M.giftbroadcast = "%1s送給%2s价值%3d的%4s"
M.exchange_tips1 = "兑换成功"
M.exchange_tips2 = "请输入兑换码"
M.exchange_tips3 = "无效兑换码"
M.exchange_tips4 = "请输入手机号码"
M.exchange_tips5 = "输入错误，请重新输入"
M.exchange_tips6 = "%s兑换了您的邀请码并成为您的好友"
M.exchange_tips7 = "兑换成功，并且添加对方为好友"
M.exchange_tips8 = "请输入正确的兑换码"
M.exchange_huafei_desc = "输入您需要充值的手机号码，兑换的%s元话费将会充值到该号码"

M.head_tip1 = "生活照头像设置成功"
M.head_tip2 = "美女头像设置成功"
M.head_tip3 = "头像设置成功"
M.head_tip4 = "请上传生活照片或自拍照片！"

M.upload_user_icon_status_f1 = "上传头像失败！！！"
M.upload_user_icon_status_0 = "正在上传头像！"

M.string010 = "您的大名:"
M.string_search_room="请输入桌子ID:"
M.string_password="房间密码"
M.string_password_error="房间密码错误"

M.login_txt1 = "请输入账号"
M.login_txt2 = "请输入密码"
M.login_txt3 = "账号或者密码错误"
M.login_txt4 = "登录错误"

M.eounce_txt="来，今天一定要连你的内裤都输掉"
M.user_notline="被挑战者不在线"
M.refuse_challenge="对方拒绝您的挑战,3秒后自动退出..."

M.get_gifts_number = "%s"
M.get_gifts_word = "收到礼物："

M.day_event_btn_word = "立即前往"
M.day_event_txt_word1 = "快乐翻翻翻"
M.day_event_txt_word2 = "充值6元即有机会获得iPhone 6 plus哦!"
M.day_event_txt_word3 = "游戏公告"

M.newResTile = "新的资源版本"
M.newRes = "大侠，我们发现了新的资源，点击确定按钮下载%s的资源包(wifi环境下下载更省流量)。"
M.newResDone = "新的资源下载完成，请点击确定重启游戏。"
M.newResError = "资源下载失败"
M.dingtips = "正在下载中"
M.dingtxt1 = "大侠，正在努力下载中,请稍等..."
M.dingtxt2 = "下载已完成%s%%"

M.promitTitle = "温馨提示"
M.newversion = "发现新版本"

M.game_jh_bet_word = "已下注"
M.game_jh_nomal_btn_word_1 = "比牌"
M.game_jh_nomal_btn_word_2 = "弃牌"
M.game_jh_nomal_btn_word_3 = "看牌"
M.game_jh_nomal_btn_word_4 = "加注"
M.game_jh_nomal_btn_word_5 = "全押"
M.game_jh_nomal_btn_word_6 = "跟注"
M.game_jh_nomal_btn_word_7 = "跟到底"

M.string1200 = "总注 ："
M.string1201 = "单注 ："
M.string1202 = "回合 ："

M.br_time_txt1 = "休息一下吧"
M.br_time_txt2 = "请下注"

M.userinfo_name = "称号:"

M.br_no_seat_player = "当前无座玩家%s人"
M.br_help_x = "X%s倍"
M.br_result_txt_1 = "输%s倍%s元"
M.br_result_txt_2 = "赢%s倍%s元"

M.br_delar_exit_tips = "亲，您正在坐庄请先下庄"
M.qq_binding_txt = "QQ绑定失败,错误码%s"
M.wx_binding_txt = "微信绑定失败,错误码%s"

M.br_delar_seatdown_success = "申请上庄成功"
M.br_seatdown_error = "亲，金额不够坐下条件了哦"
M.br_delar_seatdown_error = "金额不足%s%s"
M.br_want_be_delar1 = "我要上庄"
M.br_want_be_delar2 = "上庄列表"

M.br_pool_name1 = "黑"
M.br_pool_name2 = "红"
M.br_pool_name3 = "梅"
M.br_pool_name4 = "方"

M.everyday_reward_string001 = "(剩余%d次)"
M.everyday_reward_string002 = "抽奖次数已用完，连续登录天数越多惊喜越多!"
M.everyday_reward_string003 = "去看看"
M.everyday_reward_string004 = "恭喜获得%s金额"


M.br_bet_error1 = "亲，金额大于50才可以下注"
M.br_bet_error2 = "亲，别再下了庄家都要给您跪下了"
M.br_bet_error3 = "您的余额不足，请充值后再下注哦"

M.firstpay = "需要¥6.0，客服QQ:1987994750"
M.firstget = "您还有一次抽取iPhone6的机会，请前往活动界面进行抽奖"

M.buy_word = "购买"

M.lobby_txt_1 = "房名/ID"
M.lobby_txt_3 = "最小/大携带"
M.lobby_txt_2 = "小/大盲"
M.lobby_txt_4 = "在玩人数"

M.lobby_person = "人"
M.LaBaSendTxt = "发  送"
M.LabaShopTxt = "个小喇叭"
M.GiftCardShopName = "礼物卡"
M.LabaShopName = "小喇叭 ×15"
M.WeekCardShopName = "银卡"
M.MonthCardShopName = "金卡"
M.WeekVipCardShopName = "周VIP"
M.MonthVipCardShopName = "月VIP"
M.weekcard_pop_desc = "获得当天银卡奖励  "
M.monthcard_pop_desc = "获得当天金卡奖励  "
M.weekcard_leftday_desc ="银卡奖励还剩%s天"
M.monthcard_leftday_desc ="金卡奖励还剩%s天"
M.monthcard_buy_desc ="，请及时购买"
M.weekcard_detail = "银卡详情"
M.monthcard_detail = "金卡详情"
M.common_detail = "点开详情"

M.gold_unit = "金额"
M.right_now_get = "立即获得"
M.every_day_get = "每日首次登录获得"
M.di_desc = "第"
M.day_desc = "天"
M.day_desc_1 = "(%d天)"
M.buySuccess = "成功购买"
M.setting_cancle_btn = "注  销"
M.cancellation_txt = "是否注销当前登录"
M.chat_send = "发送"
M.laba_desc = "可用于在全服发送广播，一次消耗一个。"
M.huafei_desc = "可用于在商城兑换页兑换话费"
M.card_desc_format = "每日首次登录自动获得%d万金币"
M.leftdays_desc = "还剩%s天"
M.giftcard_desc = "购买后获得%d万金币额度，使用礼物卡赠送礼物将不可获得额外赠送金币"

M.guashi = "暂未开放!"
M.loginRewardDesc = "您已经连续登录%d天,今日可领取"
M.loginReward_jinBiTxt = "金额: "
M.loginReward_huafeiTxt = "话费券"
M.loginReward_jifen = "积  分: "
M.loginReward_huafei_uti = "张"


M.loginReward_gold_fomat = "成功领取%d金币"
M.loginReward_jifen_fomat = "，%d积分"
M.loginReward_huafei_fomat = "，%d话费券"
M.huafei_buzhu_desc = "您的话费券不足"
M.txt_meiri = "每日"
M.timeRewardDesc = "可领取奖励，过时清零"
M.txt_wucan = "丰盛午餐："
M.txt_wancan = "豪华晚餐："
M.txt_xiaoye = "奢华宵夜："
M.pocan_desc1 = "玩牌后金币不足"
M.pocan_desc2 = "时可以领取破产补助，每日可获得3次"
M.notice_title = "尊敬的《"..GAME_NAME.."》用户："
M.notice_content = "欢迎来到"..GAME_NAME.."~在这里您可以和高手竞技切磋，交流棋牌的心得技巧哦~"

M.jifen_add_word = "积分+"

M.input_roomerror_tips = "进桌失败,错误码%s"

M.shop_uinit_price = "1元=10000金币"
M.shop_old_price = "原价：%s元"
M.shop_now_price = "售价:￥%s"
M.string_shop_buy_gold_use_diamond = "确认使用%d钻石兑换%s（赠送%s金币）吗？"
M.string_shop_buy_props_use_diamond = "确认使用%d钻石兑换%s吗？"
M.string_shop_buy_props_use_gold = "确认使用%s金币兑换%s吗？"

M.br_share_card_word = "公共牌区域"
M.game_shop_getmax_chips = "金额不足时自动补充到最大"

M.noMoney = "金币不足"

M.hasBinding = "已绑定手机"
M.BindingDesc1 = "绑定手机可以有效的保护您的账号安全，建议您尽可能绑定手机"
M.BindingDesc2 = "绑定成功之后即可获得畅玩礼包"
M.BindingFailedTip = "验证码错误"
M.get_verification_code_failed = "获取验证码失败"
M.get_verification_code_success_no_phone = "验证码已发送至您的手机"
M.get_verification_code_success = "验证码已发送至%s"
M.get_voice_verification_code_failed = "获取语音验证码失败"
M.get_voice_verification_code_success = "我们将致电到您的手机号，语音播报验证码"
M.giftTips = "礼物包空空如也！"
M.gift_day = "天"

M.br_cannot_follow_tip = "不好意思您的下注达到上限"
M.daShang_failed_desc = "只有坐下才能打赏哦！"

M.share_game_name_android = ""..GAME_NAME..""
M.share_game_name_ios = ""..GAME_NAME..""
M.share_url_android = HOST_PREFIX..HOST_CN_NAME.."/share_link/android?c="..GAME_CHANNEL_NAME
M.share_url_ios = HOST_PREFIX..HOST_CN_NAME.."/share_link/ios?c="..GAME_CHANNEL_NAME


M.setting_txt_open = "开"
M.setting_txt_close = "关"
M.game_reconnect_text = "  您的账号已在其他设备上登录，请确保账号安全，是否要重新登录？"

M.hot_update_string_1 = "正在加载游戏"
M.hot_update_string_2 = "即将进入游戏"
M.hot_update_string_3 = "请稍后"
M.hot_update_string_4 = "游戏资源更新成功，正在进入游戏"
M.hot_update_string_5 = "游戏资源加载失败，请点击屏幕重试！"
M.hot_update_string_6 = "游戏资源加载失败，请点击屏幕重试！"
M.hot_update_string_7 = "优先体验新功能？"
M.hot_update_string_8 = "网络连接超时，请检查您的网络！"
M.hot_update_string_9 = "服务器没有响应，请稍后重试！"
M.hot_update_string_10 = "游戏出现了某些问题，请联系开发人员进行反馈！"
M.hot_update_string_11 = "请求超时，请点击屏幕重试！"

M.hot_update_string_12 = "更新游戏资源失败，重新加载中..."
M.hot_update_string_13 = "网络链接超时，尝试重新加载中..."
M.hot_update_string_14 = "解压游戏资源失败，重新加载中..."

M.hot_update_string_15 = "正在解压加载游戏资源..."
M.hot_update_string_16 = "游戏资源加载成功，正在对比游戏资源..."
M.hot_update_string_17 = "正在下载配置文件"

-----------------------------回赠礼物
M.gift_receive_record_format ="%s给您赠送礼物“%s”，返现%d金币"
M.gift_receive_record_name_format ="【%s】"
M.gift_receive_record_mes_format ="%s"
M.gift_receive_record_time_format ="%d-%d-%d"
M.gift_no_record ="还没有人送礼给你哦"
M.gift_rebated ="已回赠"
M.gift_rebate ="回赠礼物"
M.gift_rebate_message_1="送你玫瑰花，愿你的生活充满爱~"
M.gift_rebate_message_2="谢谢你，你是一个好人~！"
M.gift_rebate_message_3="搏一搏，单车变摩托，祝你天天好运"
M.gift_rebate_message_4="来杯啤酒放松一下吧~"
M.gift_rebate_message_5="送你一辆特斯拉，做自己，乐不宜迟。"
M.gift_rebate_message_6="还记得给我送礼，表现很好嘛~赏你大钻戒，继续努力哦！"
M.gift_rebate_message_7="财神常来到，大牌天天爆"
M.gift_rebate_message_8="哼，这礼物群发的吧，回头送个真的来！"




M.customize_roomname_placeholder = "的房间"
M.customize_password_placeholder = "点击设置房间密码"
M.customize_pre_bet = "前注: "
M.customize_blinds = "盲注: "
M.customize_desk_id = "牌桌: "
M.customize_service_fee = "服务费: "
M.customize_game_over = "对局结束"
M.customize_game_over_tip = "该对局已结束"
M.customize_share_failed = "分享失败"
M.customize_leak_chips = "您桌上金额不足，无法开始游戏，系统帮您站起"
M.customize_exchange_chips_tip = "以实际补充金额数量的%d%%收取服务费"

-------------------------- 性美女-------------------------

M.beauty_three_reward = "奖励:%s金币"
M.beauty_gallery_net = "获取相册中"
M.beauty_share_reward_format = "%d金币"
M.beauty_share_content_format="快来围观，本女神排名第%d，还获得了%s金币奖励，欢迎前来%s膜拜~"


M.vipcard_daoju_desc = "可使用专属标示，隐身功能、入场动画、免费使用贵族表情、好友备注等"
M.vipcard_daoju_num_desc_format = "VIP卡\n(剩余%d天)"
M.vipcard_shop_desc = "购买后立即获得%d万金币、专属\n标示，隐身功能、入场动画、免费\n使用贵族表情、好友备注等"
M.vip_enter_broadcast = "VIP用户\"%s\"进场啦，快来挑战！"
M.vip_hide_function_tip = "隐身功能仅限VIP用户使用!"
M.vip_hide_open_failed = "隐身开启失败"
M.vip_hide_close_failed = "隐身关闭失败"
M.vip_hide_effective_open_tip = "隐身功能在游戏开启"
M.vip_hide_effective_close_tip = "隐身功能在游戏关闭"
M.vip_hide_effective_in_game = "隐身设置将在游戏内生效"
M.vip_hiding_name = "神秘人"
M.vip_hiding_status_desc = "(隐身中)"
M.vip_hiding_userinfo_string_2 = "??"
M.vip_hiding_userinfo_string_3 = "???"
M.vip_hiding_br_tip = "百人场内不支持隐身功能"
M.vip_hiding_sng_tip = "比赛场内不支持隐身功能"
M.vip_detail = "VIP详情"

M.galleryUploadSuc="图片上传成功"
M.galleryUploading="图片上传中"
M.galleryUploadFail="图片上传失败"
M.gameCheckChipToSetTxt = "系统自动帮您按照离桌时的金额量进行补充"

M.gallery_no_photo = "该用户未上传照片"
M.gallery_photo_caoshi ="超时"

M.remark_no_remark_name = "无备注"
M.remark_not_remark_name ="VIP用户才能修改备注"
M.remark_not_all_space ="备注名不能全是空格"

M.levelup_desc_1 = "您已赢取"
M.levelup_desc_2 = "，是否升入大场赢取更多金额？"
M.customize_buyin_no_limit = "无限制"
M.customize_buyin_description = "Buy-in上限: %s"
M.customize_buyin_limit_tip_1 = "因为对局总buyin金额限制，只能补充到%d金额"
M.customize_buyin_limit_tip_2 = "已达到对局总buyin金额上限，无法继续补充金额"
M.customize_buyin_losing_all = "您输完了，请下次继续努力！"

M.games_record_list_index = "第%d手牌"
M.games_record_desk_player_num = "%d人"
M.games_record_details_deskinfo = "%s: %d/%d"
M.games_record_details_classic_mustspend= "必下: %d"
M.games_record_details_customize_mustspend= "前注: %d"
M.games_record_details_deskid = "%d号桌"
M.games_record_details_hiding_status = "(隐身)"
M.games_record_no_record = "当前没有对局记录!"

M.customize_desk_lock_tip = "只有房主可以给对局上锁"
M.customize_desk_unlock_tip = "只有房主可以给对局解锁"
M.customize_desk_lock_success = "设置密码成功"
M.customize_desk_lock_placehold = "设置房间密码"
M.customize_desk_lock_invalidate = "请输入密码"
M.customize_desk_locked_notify = "本对局成为私密对局，需要密码进入"
M.customize_desk_unlock_success = "解锁成功"
M.customize_desk_unlocked_broadcast = "本对局成为开放对局，无需密码进入"
M.customize_desk_owner_changed_broadcast = "玩家 %s 成为房主"

M.shop_promit_tip_1 = "进入房间金额不足，请充值！"
M.shop_promit_tip_2 = "坐下金额不足，请充值！"
M.shop_promit_tip_3 = "自动坐下金额不足，请充值！"
M.shop_promit_tip_4 = "上庄金额不足，请充值！"
M.shop_promit_tip_5 = "创建房间金额不足，请充值！"
M.shop_promit_tip_6 = "请选择充值面额"
M.shop_promit_tip_7 = "请选择兑换面额"
M.shop_promit_tip_8 = "充值过程中如有任何疑问请加%s咨询：%s"
M.charge_success = "充值成功！"

M.lobby_must_name = "必下桌"

M.stt_not_support = "语音转换文字功能正在开发中, 敬请期待"
M.stt_convert_error = "语音转换文字失败"
M.stt_microphone_error = "请去“设置”内打开“麦克风”权限"
M.stt_network_error = "网络连接出现问题, 语音转换文字失败"

M.heguan_name_1 = "Ross"
M.heguan_name_2 = "Ross(圣诞装)"
M.heguan_name_3 = "Nancy"
M.heguan_name_4 = "Julie"
M.heguan_name_5 = "Henry"
M.heguan_name_6 = "Mary"
M.heguan_not_change = "坐下后才可以替换您喜欢的荷官"
M.nan_heguan_dashang_content = {"不经意间的打赏确是那么醉人", "打赏越多得到越多", "再来一次打赏，再来一次好牌",
 "据说打赏越多，allin越容易获胜", "赢了别忘了打赏我"}

M.send_gift_tip = "您正在进行送礼操作，确定继续吗？"
M.send_report_ok = "发送成功！"
M.report_no_type = "请选择一个举报理由！"

M.gift_card_daoju_desc_1 = "当前剩余"
M.gift_card_daoju_desc_2 = "金币额度，使用礼物卡赠送礼物将不可获得额外赠送金币"
M.gift_card_tips_content_1 = "您的礼物卡额度还剩余"
M.gift_card_tips_content_2 = "金币，是否优先使用礼物卡赠送？"
M.gift_gold_expend = "消耗："
M.gift_card_rest = "剩余："

---------SNG---------
M.sng_game_levels_on_desktop = { "普通场", "职业场", "精英场", "专家场", "大师场", "传奇场"}
M.sng_game_desktop_txt = "%s(%d人桌)   盲注: %d/%d"
M.sng_game_waitting_start_tip = "满%d人可开始比赛..."
M.sng_game_dashang_lose_tip = "您已被淘汰, 无需再打赏荷官"
M.sng_game_blind_raise_notify = "下局将升盲至%d/%d"
M.sng_game_start_notify = "%d人已满，比赛马上开始"
M.sng_game_downward_user_exit = "玩家\"%s\"默默地离开了牌桌"
M.sng_game_downward_user_enter = "玩家\"%s\"加入了牌桌"
M.sng_game_downward_user_lose = "玩家\"%s\"被淘汰了"
M.sng_game_downward_user_merge = "玩家\"%s\"并桌进来了"
M.sng_game_downward_myself_merge = "因为公平竞争原则，将您并到本桌！"
M.sng_game_downward_user_rebuy = "玩家\"%s\"重购回来了"
M.sng_game_downward_user_addon = "玩家\"%s\"增购回来了"
M.sng_game_start_notify = "6人已满，比赛马上开始"
M.sng_player_win_desc = "恭喜您成功登顶，您的名字将会刻入史册!!!"
M.sng_player_lose_desc = "您离冠军并不遥远，调整好状态再来一局吧！"

--sng选场---
M.sng_lobby_cansaifei = "参赛费:"
M.sng_lobby_fuwufei = "服务费:"
M.sng_game_rule = "1、报名人数满6人立即开赛\n2、中途不可以增加金额,输完金额默认离桌\n3、每场比赛玩家会获得用来计数的金额(本金额不等于金币,该金额只用于本场比赛的计数),淘汰赛默认5000金额用于计数\n4、比赛中盲注会随着时间逐渐增长\n5、淘汰赛获胜后可获得金币、大师分等奖励，参赛级别越高获得的奖励越多\n6、大师分等值于积分,获得大师分后玩家同时获得等值积分。"
M.sng_game_rule_new = "1、免费参赛，报名人数满6人立即开赛\n\n2、每场比赛玩家可以获得用来计数的5000金额\n\n3、中途不可以自己增加金额，输完金额默认离桌\n\n4、比赛中盲注会随着时间逐渐增长\n\n5、比赛获胜后第1名和第2名可以获得积分奖励\n\n6、通过积分可以获得对于的称号。"
M.sng_game_result_rank_desc = "第%d名"
M.sng_game_result_rank_score = "%d分"

M.userinfo_no_sng_info = "暂未参加免费赛"
M.userinfo_no_mtt_info = "暂未参加大奖赛"
M.userinfo_sng_times = "共参赛%d次，得奖情况如下:"
M.userinfo_mtt_times= "共参赛%d次，锦标赛最好成绩如下:"
M.userinfo_mtt_rank= "第%d名"
M.sng_miao= "秒"

M.sng_coin_not_enough= "您的金额不足，请充值！"
M.sng_coin_not_enough_ex= "您的金额不足，请充值或者选择低场次进入"

M.mit_not_open= "暂未开放，敬请期待"


M.challenge_declaration_txt_1 = "来，今天一定要连你的底裤都输掉"
M.challenge_declaration_txt_2 = "只要你敢来，我一跟到底！"
M.challenge_declaration_txt_3 = "上桌吧，让我看看你的手段。"
M.challenge_declaration_txt_4 = "别瞎晃悠了，来跟我比比牌。"
M.challenge_declaration_txt_5 = "说其他都是假的，有种牌桌上见真章！"
M.challenge_declaration_txt_6 = "快进场，我已经饥渴难耐了！"


M.sng_mit_not_send_gift="比赛场不支持送礼"
M.not_send_gift_to_all = "该场景不支持送给所有人"


M.customize_takein_txt = "带入"
M.customize_takein_max_txt = "最大带入"
M.customize_takein_min_txt = "最小带入"
M.customize_vip_permission_tip = "只有VIP用户才有此权限"
M.input_friend_uin = "请输入好友ID"

---- 手机绑定 -----
M.phone_binding_place_phone = "请输入手机号码"
M.phone_binding_place_code = "请输入验证码"
M.phone_binding_resend_txt = "%ds后重新发送"
M.phone_binding_error_form = "手机号不存在,请重新输入!"
M.phone_binding_error_long = "手机号长度不正确,请重新输入!"
M.phone_binding_error_empty = "请输入您的手机号码!"
M.phone_binding_error_code = "验证码输入有误,请重新输入!"

----------趣凡账号登录系统--------------
M.qufan_login_string_1 = "请输入您的手机号"
M.qufan_login_string_2 = "请输入6~18个数字或字母"
M.qufan_login_string_3 = "请输入验证码"
M.qufan_login_string_4 = "获取验证码"
M.qufan_login_string_5 = "s后重新发送"
M.qufan_login_string_7 = "账号不存在或密码有误，请重新输入"
M.qufan_login_string_9 = "验证码输入有误，请重新输入"
M.qufan_login_string_10 = "密码格式有误，请重新输入"
M.qufan_login_string_11 = "请输入正确的密码格式"
M.qufan_login_string_12 = "请输入您的原密码"
M.qufan_login_string_13 = "请输入您的新密码"
M.qufan_login_string_14 = "密码信息输入不完整，请重新输入"
M.qufan_login_string_15 = "修改密码成功，请牢记您的新密码"
M.qufan_login_string_16 = "手机号不存在，请重新输入"
M.qufan_login_string_17 = "密码格式有误，请重新输入"
M.qufan_login_string_18 = "请输入您的原密码"
M.qufan_login_string_19 = "和新密码保持一致"
M.qufan_login_string_20 = "86"
M.qufan_login_string_21 = "重发验证码"
M.qufan_login_string_22 = "您的的手机可能无法接受短信验证码，是否接受语音验证码？"


------------- 选场大厅------------------
M.chosehall_shengfen_rank = "胜分榜排名:"
M.chosehall_fufen_rank = "负分榜排名:"
M.chosehall_numfen = "%d分"

M.sng_level_name = {"初级菜鸟","高级菜鸟", "初入赌坛","展露头角","赌坛新秀","小有名气","赌资百万",
 "赌坛干将","赌术大成","千万赌徒","赌资丰厚","赌坛贵族","以赌为生","家财万贯","富可敌国","迪拜来客",
 "亿万赌豪","赌侠","赌霸","赌王","赌王之王","赌圣","赌神"}

M.sng_level_desc = {"≤0","≥1", "≥5","≥20","≥50","≥100","≥200",
 "≥300","≥400","≥500","≥600","≥700","≥800","≥900","≥1000","≥2000",
 "≥3000","≥4000","≥5000","≥6000","≥7000","≥8000","≥9000"}

 M.sng_level_not_go_game_desc = "您正在游戏中"
M.sng_level_master_desc = "参加免费比赛获取竞技分"

---私人厂限制
M.private_limit_txt = "限制买入房间"
M.private_nolimit_txt = "无限制买入房间"

M.chosehall_no_rank = "当前并无排名"
M.sng_new_room_name = "免费对局"

M.exchange_product_success_tip = "您已成功购买 %s"
M.exchange_product_failed_tip = "购买 %s 失败"
M.exchange_gift_not_me = "本礼物只支持钻石兑换送自己,不支持赠送他人"

M.shop_currency_diamond = "钻石"
M.shop_currency_gold = "金币"
M.shop_currency_tenthousand_gold = "万金币"

M.waiting_queue_countdown_txt = "(%d秒后自动前往)"
M.waiting_queue_countdown_btn = "进入新桌(%d)"

--------------比赛场退出提示-------------

----------MTT大厅--------------
M.mtt_lobby_string_1 = "1、固定时间开始比赛，当参赛人数小于最低开赛人数时，比赛将被取消\
2、每场比赛玩家会获得用来计数的金额（本金额不等于金币），该金额只用于本场比赛的计数\
3、前注（ante）:比赛进行过程中，每局开始前强制每位玩家自动下注若干金额，即为前注\
4、重购金额（rebuy）:在配置了rebuy的比赛开始前的某个盲注级别前，当玩家手中的金额≤初始金额时，玩家可以点击重购金额按钮花费报名费再次买入初始的金额，不同的比赛可重购的次数不定，当玩家手中金额为0时也可以通过rebuy复活\
5、Add-on(增购金额)：在配置了可以Add-on的比赛某个盲注级别时间段内，玩家可以点击增购金额按钮花费报名费再次买入若干金额值，不同的比赛可增购的次数不定，当玩家手中金额为0时也可以通过add-on复活\
6、按照玩家退出比赛的顺序取得名次，第一位金额输完的即为最后一名，依次类推，如果有2位以上参赛者于同一局被淘汰，则按照牌力、本局开始时金额定位名次，牌力大的排名在前，开始金额多的排名在前\
7、当比赛里只剩下最后一名玩家时比赛结束，最后一名玩家即冠军\
8、为提高比赛激烈程度盲注会在比赛过程中逐步提升\
9、大奖赛获胜后可获得金币、实物兑换券奖励，参赛费越高获得的奖励越多\
10、所有奖励将会在赛事结束后统一发放到玩家账户\
11、玩家获得兑换券奖励后可前往活动中心兑换豪礼活动内兑换奖品\
12、玩家优先使用门票报名，金币报名（参赛+服务费，“10万+1万”）、退赛与报名未参赛都将仅退还参赛费，赛前3分钟无法退赛"
M.mtt_lobby_string_2 = "今天"
M.mtt_lobby_string_3 = "明天"
M.mtt_lobby_string_4 = "昨天"
M.mtt_lobby_string_5 = "可重购比赛%d次"
M.mtt_lobby_string_6 = "可增购比赛%d次"
M.mtt_lobby_string_7 = "第"
M.mtt_lobby_string_8 = "个盲注级别可用"
M.mtt_lobby_string_9 = "可延时登记时间为%d分钟"
M.mtt_lobby_string_10 = "分"
M.mtt_lobby_string_11 = "秒"
M.mtt_lobby_string_12 = "积分"
M.mtt_lobby_string_13 = "无Rebuy"
M.mtt_lobby_string_14 = "无Add-on"
M.mtt_lobby_string_15 = "您拥有%d张"
M.mtt_lobby_string_16 = "今天暂时没有已结束的比赛"
M.mtt_lobby_string_17 = "还未报名任何比赛，赶紧去报名吧"
M.mtt_lobby_string_18 = "%d金币"
M.mtt_lobby_string_19 = "%d金额"
M.mtt_lobby_string_20 = "（总奖池："
M.mtt_lobby_string_21 = "金币*买入次数）"
M.mtt_lobby_string_22 = "总奖池"
M.mtt_lobby_string_23 = "您的金币不足，请补充金币或者选择其他比赛进入"
M.mtt_lobby_string_24 = "赛前"
M.mtt_lobby_string_25 = "小时"
M.mtt_lobby_string_26 = "分钟"
M.mtt_lobby_string_27 = "开放"
M.mtt_lobby_string_28 = "比赛已开始延迟报名中"
M.mtt_lobby_string_29 = "比赛已开始延迟参赛中"
M.mtt_lobby_string_30 = "您错过了"
M.mtt_lobby_string_31 = "开赛的"
M.mtt_lobby_string_32 = "，参赛费用已经退还！"
M.mtt_lobby_string_33 = "今天暂时没有热门赛事"
M.mtt_lobby_string_34 = "您的金币不足，无法重购，请补充金币"
M.mtt_lobby_string_35 = "您的金币不足，无法增购，请补充金币"
M.mtt_lobby_string_36 = "今天暂时没有赛事"
M.mtt_lobby_string_37 = "现在退赛将只返还您的参赛费，是否确认退出？"
M.mtt_lobby_string_38 = "您参加的"
M.mtt_lobby_string_39 = "大奖赛，最终奖励是："
M.mtt_lobby_string_40 = "下拉刷新..."

-- MTT
M.second = "%ds"
M.rebuy_tip_rebuy_num = "（允许重购次数：%d次）"
M.rebuy_tip_addon_num = "（允许增购次数：%d次）"
M.rebuy_tip_rebuy_content = "是否愿意花费%s金币重购%s金额("
M.rebuy_tip_rebuy_content_2 = "是否愿意花费%s金币重购%s金额？"
M.rebuy_tip_addon_content = "是否愿意花费%s金币增购%s金额("
M.rebuy_tip_addon_content_2 = "是否愿意花费%s金币增购%s金额？"
M.rebuy_tip_rebuy_content_tail = ")？"
M.rebuy_error_tip = "当前金额超过初始金额，无法购买！"
M.mtt_exit_tip_1 = "比赛中途退出，您的报名费将不会返还，并且无法回来，是否确认退出？"
M.mtt_exit_tip_2 = "比赛即将开始，现在退出牌桌有可能错过比赛！"
M.mtt_billing_rank_1 = "恭喜您获得本场锦标赛冠军，您的名字将会载入史册！！！"
M.mtt_billing_rank_2 = "恭喜您成功斩获1次锦标赛亚军！！！"
M.mtt_billing_rank_3 = "恭喜您成功斩获1次锦标赛季军！！！"
M.mtt_billing_rank_4 = "恭喜您进入奖励圈，获得本场比赛奖励！"
M.mtt_billing_rank_5 = "您离奖励圈并不遥远，调整好状态再来一场吧！"
M.mtt_billing_rank_6 = "恭喜您成为本场赛事的“泡沫玩家”！"
M.mtt_split_desk_tip_1 = "牌桌已被拆桌，是否前往其他桌继续旁观？"
M.mtt_split_desk_tip_2 = "您所在牌桌因为人数过少\n暂时停止发牌，请等候\n并桌"
M.mtt_sync_send_card_tip = "进入全场同步发牌"
M.mtt_sync_send_card_tip_2 = "等待全场同步发牌"
M.mtt_final_wait_tip = "恭喜您杀进决赛桌！正在等待其他玩家加入"
M.mtt_tip_rebuy_to_wait_next = "重购后在大盲位置，等待下一局！"
M.mtt_tip_termination_1 = "您之前的牌桌已被拆分！"
M.mtt_tip_termination_2 = "比赛已经结束！"
M.mtt_game_over = "本场比赛已经结束！"
M.mtt_reward_1 = "金币："
M.mtt_reward_2 = "兑换券："
M.mtt_reward_3 = "参赛券："

M.breakHideCardShopName="破隐卡"
M.break_hide_card_desc="对隐身的玩家使用破隐卡,可查看他的信息,持续5分钟,只在牌桌内有效"
M.break_hide_card_not_enough = "您的破隐卡不足，请到商城购买"

M.common_detail = "点开详情"

M.enter_ticket_name = "%s门票"
M.enter_ticket_desc_1 = "可用于参加"
M.enter_ticket_desc_2 = "一次消耗一张。有效期至%s"
M.mtt_event_canceled_tip = "您报名的%s因不够最低参赛人数取消开赛,报名费用已经返还!"
M.mtt_cur_rank = "当前第%d名"
M.mtt_string_rebuy_success_1 = "重购成功，获得%d金额"
M.mtt_string_addon_success_1 = "增购成功，获得%d金额"
M.mtt_string_rebuy_success_2 = "重购成功，下局为您增加%d金额"
M.mtt_string_addon_success_2 = "增购成功，下局为您增加%d金额"
M.mtt_tip_request_event_error = "请求赛事信息出错！"
M.mtt_rebuy_error_code = "重购或增购失败，错误码：%d"
M.mtt_merge_desk_tip_1 = "您将被并入新的牌桌"
M.mtt_string_enter_wait = "进场等待"
M.mtt_string_countdown_enter_1 = "您报名的 %s 将在 "
M.mtt_string_countdown_enter_2 = "%s秒"
M.mtt_string_countdown_enter_3 = "后开赛！"


M.OREADY_GAME = "您的账号正在游戏中,请稍后再试"


M.Daily_login = {
    [1] = '第一天',
    [2] = '第二天',
    [3] = '第三天',
    [4] = '第四天',
    [5] = '第五天',
    [6] = '第六天',
    [7] = '第七天',
}

M.INSTALL_GAMES_TIPS = "进入%s之前需要下载资源文件(大小为%s),您现在就要下载资源包吗?"

M.GAMENOTOPEN = "疯狂研发中，敬请期待！"

M.invite_wingame1 = "他们都说我是蒙的"
M.invite_wingame2 = "我仿佛听到背后有人说我帅"
M.invite_wingame3 = "恕我直言，在座的都不会打牌"

M.phizStrings = {[2] = "xihongshi"
    , [4] = "meigui"
    , [5] = "bingtong"
    , [1] = "niubei"
    , [3] = "dianzan"
}
M.MainTips={
    "好习惯就是每天清任务",
    "有充就有送",
    "送人玫瑰，手有余香",
    "今天的奖励都领了吗？",
    "打满50场，决战到天亮！",
    "传头像也是有奖励的",
    "豹子、同花顺、牛牛都想要！",
    "连续登陆7天，每天领7K金币",
    "给荷官打赏是绅士的礼貌",
    "设置里可以调整立即开始的玩法",
    "您有奖励可以立即领取哟"
}


M.share_result = {
    ["success"] = "分享成功",
    ["cancel"] = "取消分享",
    ["error"] = "分享失败"
}

M.INSTALLGAME = "已有下载进行中，请稍后再试"

M.VISTORTIP = "  您正在使用游客模式进行游戏，游客模式下的数据（包含付费数据）会在删除游戏、更换设备后清空。为了保障那你的虚拟财产安全，以及让您获得更完善的游戏体验，我们建议您使用微信/手机登录进行游戏！"

M.PASSWORDERRORTIP1 = "两次输入密码不一致，请重新输入"
M.PASSWORDERRORTIP2 = "登录密码需设置为%d-%d位字母或数字，请重新输入"
M.PASSWORDTIP1 = "为了保证您的账号安全，密码长度不低于%d位数"
M.loadingGame = "正在加载中..."

M.no_gold_tips = "金额不足，是否前往商城充值？"
M.paras_error_tips = "参数错误！"

M.customer_view_placehodler_str = "请描述您遇到的问题，字数长度不能超过50个。"
M.commit_success = "提交成功！"
M.commit_error = "提交内容不能为空"

M.limitLeastMoneyTip = "账号必须留底%s元"
M.exchangePlaceTxt = "最低提现金额%s元"
M.no_band_bank_card = "您暂未绑定银行卡，请先绑定银行卡！"

--大厅相关
M.copy_tips = "网址已复制，请分享给好友哦"
M.developing = "疯狂研发中，敬请期待！"

--设置
M.setting_txt_1 = "版本号："

--保险箱 start
M.string_safebox_1 = "请输入整数数字"
M.string_safebox_2 = "请输入您想要存入的金额"
M.string_safebox_3 = "请输入您想要取出的金额"
M.string_safebox_4 = "请输入6位安全密码"
M.string_safebox_5 = "请输入大于0的金额"
M.string_safebox_6 = "操作成功"
M.string_safebox_7 = "密码错误"
M.string_safebox_8 = "请勿频繁操作"
M.string_safebox_9 = "保险箱余额不足"
--保险箱 end

--个人信息 start
M.string_person_1 = "绑定手机："
M.string_person_2 = "未绑定手机"
M.string_person_3 = "我的邀请码："
M.string_person_4 = "当天"
M.string_person_5 = "近一周"
M.string_person_6 = "近一个月"
M.string_person_7 = "昵称长度最多五个汉字，或者10个字符"
M.string_person_8 = "昵称中不能含有空格"
M.string_person_9 = "修改成功"
M.string_person_10 = "修改失败"
--个人信息 end

--登陆界面 start
M.string_login_1 = "请输入手机号"
M.string_login_2 = "请输入验证码"
M.string_login_3 = "请输入正确的手机号"
M.string_login_4 = "发送验证码"
M.string_login_5 = "请填写手机号码"
M.string_login_6 = "请输入密码"
M.string_login_7 = "请再次输入密码"
M.string_login_8 = "两次输入的密码不一致"
M.string_login_9 = "请填写密码"
M.string_login_10 = "请输入邀请码"
M.string_login_11 = "您还有未填写内容，请输入后提交"
M.string_login_12 = "您的手机号输入有误，请重新输入"
M.string_login_13 = "请确认您的密码"
M.string_login_14 = "请求超时，请重试！"
M.string_login_15 = "请求失败，请重试！"
M.string_login_16 = "密码找回成功"
M.string_login_17 = "请输入您的密码"

M.string_login_18 = "找回密码参数错误"
M.string_login_19 = "账号不存在"
M.string_login_20 = "密码修改成功"
M.string_login_21 = "设置密码参数错误"
M.string_login_22 = "密码设置失败"
M.string_login_23 = "密码设置成功"
M.string_login_24 = "登录失败，请检查账号或密码是否正确。"
M.string_login_25 = "该账号已被注册，请使用密码登录。若忘记密码，请使用找回密码功能。"
M.string_login_26 = "该账号尚未注册，请确认是正确的账号"

M.string_login_27 = "无效的手机号码"
M.string_login_28 = "验证码校验失败"
M.retry_send_code = "%d重新发送"
--登陆界面 end

--客服 start
M.string_custom_1 = "请描述您遇到的问题，字数长度不能超过50个。"
M.string_custom_2 = "提交内容不能为空"
M.string_custom_3 = "提交成功！！！！"
M.string_custom_4 = "待处理"
M.string_custom_5 = "已回复"
M.string_custom_6 = "不要频繁提交，1分钟再尝试"
M.string_custom_7 = "关闭当前窗口前往投诉与提供建议！"
--客服 end

--邀请 start
M.string_invite_1 = "邀请码为2位字母和2位数字组合,请重新输入"
M.string_invite_2 = "您的邀请码有误，请重新核对"
M.string_invite_3 = "安全密码修改成功"
M.string_invite_4 = "邀请码绑定成功"
--邀请 end

M.string_global_1 = "修改备注名成功"
M.string_global_2 = "暂时没有最新活动与公告"

--绑定 start
M.string_bind_1 = "请输入您的手机号码"
M.string_bind_2 = "请输入您的姓名"
M.string_bind_3 = "请输入您的银行卡号"
--绑定 end

--提现 start
M.string_exchange_1 = "请填写可提现金额"
M.string_exchange_2 = "客服QQ："
M.string_exchange_3 = "客服电话："
M.string_exchange_4 = "单笔最低提现金额为"
M.string_exchange_5 = "元，请重新输入"
M.string_exchange_6 = "单笔最高提现金额为"
M.string_exchange_7 = "余额不足"
M.string_exchange_8 = "提现失败"
M.string_exchange_9 = "提现成功"
M.string_exchange_10 = "支付完成"
M.string_exchange_11 = "等待提现中"
M.string_exchange_12 = "安全密码错误"
M.string_exchange_13 = "请输入整数"
M.string_exchange_14 = "支付宝功能暂时无法使用"
M.string_exchange_15 = "请输入提现金额"
M.string_exchange_16 = "1.提现后需要等待人工审核，可在「钱包记录」中查看进度。\n\n2.提现收取2%%支付手续费，且账号内至少保留10元。\n\n3.最低提现金额%d元"
--提现 end

--周返现 start
M.string_retmoney_1 = "第%s档"
M.string_retmoney_2 = "当前处于"
M.string_retmoney_3 = "再产生"
M.string_retmoney_4 = "流水，可升级为"
M.string_retmoney_6 = "已达到最大流水奖励挡位，再接再厉，祝您一本万利，八方来财！"
M.string_retmoney_7 = "兑换成功"
M.string_retmoney_8 = {
    "一","二","三","四","五","六","七","八","九","十"
}
--周返现 end

--修改密码 start
M.string_changepwd_1 = "元启动资金"
M.string_changepwd_2 = "密码修改失败"
M.string_changepwd_3 = "安全密码仅支持6位数字，请重新输入"
M.string_changepwd_4 = "修改安全密码失败"
M.string_changepwd_5 = "修改安全密码成功"
M.string_changepwd_6 = "该手机号已经被绑定"
M.string_changepwd_7 = "您已绑定手机，还需设置安全密码"
M.string_changepwd_8 = "设置安全密码失败"
M.string_changepwd_9 = "设置安全密码成功"
M.string_changepwd_10 = "绑定手机失败"
M.string_changepwd_11 = "绑定赠送%s%s"
--修改密码 end

M.string_bind_status_1 = "解绑失败"
M.string_bind_status_2 = "您已成功解绑该银行卡"
M.string_bind_error_3 = "银行卡号中只能包含大写英文字符和数字"
M.string_bind_4 = "开户支行中只能包含汉字和数字"
M.string_bind_5 = "请填写开户人姓名"
M.string_bind_6 = "请选择银行"
M.string_bind_7 = "请选择省份"
M.string_bind_8 = "请选择城市"
M.string_bind_9 = "请填写支行信息"
M.string_bind_10 = "请填写银行卡号"
M.string_bind_11 = "开户人姓名中只能包含中文汉字且最多五个汉字"
M.string_bind_12 = "请查阅协议并同意"
M.string_bind_13 = "信息填写错误，请仔细检查后提交"                    
M.string_bind_14 = "您已成功绑定该银行卡"
M.string_bind_15 = "安全密码修改失败"

M.string_agency_1 = "请输入6位邀请码"
M.string_agency_2 = "您输入邀请码有误，请重新输入"
M.string_agency_3 = "微信号复制成功"
M.string_agency_4 = "QQ号复制成功"

M.string_luck_1 = "当前携带金额："
M.string_luck_2 = "金额："
M.string_luck_3 = "请输入金额"
M.string_luck_4 = "最低%s元，且账号内至少保留%s元"
M.string_luck_5 = "请输入金额"
M.string_luck_6 = "输入金额数需大于%d，请重新输入"
M.string_luck_7 = "输入金额需为正整数"
M.string_luck_8 = "您身上携带金额不足，请及时充值。"
M.string_luck_9 = "已经是第一页了"
M.string_luck_10 = "已经是最后一页了"
M.string_luck_11 = "当前携带：%s 元"
M.string_luck_12 = "元"
M.string_luck_13 = "秒"
M.string_luck_14 = "元/秒"
M.string_luck_15 = "金额"
M.string_luck_16 = "代理不具有此权限"

M.string_policy_txt = "    本游戏尊重并保护所有使用服务用户的个人隐私权。为了给您提供更准确、更有个性化的服务，本游戏会按照本隐私权政策的规定使用和披露您的个人信息。但本游戏将以高度的勤勉、审慎义务对待这些信息。除本隐私权政策另有规定外，在未征得您事先许可的情况下，本游戏不会将这些信息对外披露或向第三方提供。本游戏会不时更新本隐私权政策。 您在同意本游戏服务使用协议之时，即视为您已经同意本隐私权政策全部内容。本隐私权政策属于本游戏服务使用协议不可分割的一部分。\n1. 适用范围\na) 在您注册本游戏帐号时，您根据本游戏要求提供的个人注册信息；\nb) 在您使用本游戏网络服务，或访问本游戏平台网页时，本游戏自动接收并记录的您的浏览器和计算机上的信息，包括但不限于您的IP地址、浏览器的类型、使用的语言、访问日期和时间、软硬件特征信息及您需求的网页记录等数据；\nc) 本游戏通过合法途径从商业伙伴处取得的用户个人数据。\n您了解并同意，以下信息不适用本隐私权政策\na) 您在使用本游戏平台提供的搜索服务时输入的关键字信息；\nb) 本游戏收集到的您在本游戏发布的有关信息数据，包括但不限于参与活动、成交信息及评价详情；\nc) 违反法律规定或违反本游戏规则行为及本游戏已对您采取的措施。\n2. 信息使用\na) 本游戏不会向任何无关第三方提供、出售、出租、分享或交易您的个人信息，除非事先得到您的许可，或该第三方和本游戏单独或共同为您提供服务，且在该服务结束后，其将被禁止访问包括其以前能够访问的所有这些资料。\nb) 本游戏亦不允许任何第三方以任何手段收集、编辑、出售或者无偿传播您的个人信息。任何本游戏平台用户如从事上述活动，一经发现，本游戏有权立即终止与该用户的服务协议。\nc) 为服务用户的目的，本游戏可能通过使用您的个人信息，向您提供您感兴趣的信息，包括但不限于向您发出产品和服务信息，或者与本游戏合作伙伴共享信息以便他们向您发送有关其产品和服务的信息（后者需要您的事先同意）。\n3. 信息披露\n在如下情况下，本游戏将依据您的个人意愿或法律的规定全部或部分的披露您的个人信息：\na) 经您事先同意，向第三方披露；\nb) 为提供您所要求的产品和服务，而必须和第三方分享您的个人信息；\nc) 根据法律的有关规定，或者行政或司法机构的要求，向第三方或者行政、司法机构披露；\nd) 如您出现违反中国有关法律、法规或者本游戏服务协议或相关规则的情况，需要向第三方披露；\ne) 如您是适格的知识产权投诉人并已提起投诉，应被投诉人要求，向被投诉人披露，以便双方处理可能的权利纠纷；\nf) 在本游戏平台上创建的某一交易中，如交易任何一方履行或部分履行了交易义务并提出信息披露请求的，本游戏有权决定向该用户提供其交易对方的联络方式等必要信息，以促成交易的完成或纠纷的解决。\ng) 其它本游戏根据法律、法规或者网站政策认为合适的披露。\n4. 信息存储和交换\n本游戏收集的有关您的信息和资料将保存在本游戏及（或）其关联公司的服务器上，这些信息和资料可能传送至您所在国家、地区或本游戏收集信息和资料所在地的境外并在境外被访问、存储和展示。\n5. Cookie的使用\na) 在您未拒绝接受cookies的情况下，本游戏会在您的计算机上设定或取用cookies，以便您能登录或使用依赖于cookies的本游戏平台服务或功能。本游戏使用cookies可为您提供更加周到的个性化服务，包括推广服务。\nb) 您有权选择接受或拒绝接受cookies。您可以通过修改浏览器设置的方式拒绝接受cookies。但如果您选择拒绝接受cookies，则您可能无法登录或使用依赖于cookies的本游戏网络服务或功能。\nc) 通过本游戏所设cookies所取得的有关信息，将适用本政策。\n6. 信息安全\na) 本游戏帐号均有安全保护功能，请妥善保管您的用户名及密码信息。本游戏将通过对用户密码进行加密等安全措施确保您的信息不丢失，不被滥用和变造。尽管有前述安全措施，但同时也请您注意在信息网络上不存在“完善的安全措施”。\nb) 在使用本游戏网络服务进行网上交易时，您不可避免的要向交易对方或潜在的交易对方披露自己的个人信息，如联络方式或者邮政地址。请您妥善保护自己的个人信息，仅在必要的情形下向他人提供。如您发现自己的个人信息泄密，尤其是本游戏用户名及密码发生泄露，请您立即联络本游戏客服，以便本游戏采取相应措施。"

M.string_delarlist_1 = "玩家携带金额"


M.string_mail_1 = "是否删除该消息?"

M.string_room_limit_1 = "你当前金额不足%s%s，进入旁观状态！"
M.string_room_limit_2 = "您当前余额不足，请及时充值。"
M.string_room_limit_3 = "上桌需要%s%s，请及时充值！"
M.string_room_limit_4 = "金额不足%s%s，请联系客服协助处理！" --正式服
M.string_room_limit_5 = "金额不足%s%s，快去商城充值吧！" -- 审核状态
M.string_room_limit_6 = "，请联系客服协助处理！" --正式服
M.string_room_limit_7 = "，快去商城充值吧！" --审核服
M.string_room_limit_8 = "金币超过该牌桌上限，请前往更高场次！" --金币超房间上线

M.customer_chat_error_txt = "输入内容不能为空，请重新输入"
M.send_input_placeHolder_txt = "请点击输入"
M.customer_work_time = "工作时间：%s"
M.send_to_sequence_txt = "请不要频繁发言！"

M.to_update_apk_txt = "前往更新"
M.to_update_title_txt = "温馨提示"
M.to_update_content_txt = "当前版本过低，请前往更新！\n更新后进入游戏获取更畅快的游戏体验。"
M.to_update_content_txt_1 = "尊敬的玩家：\n当前版本过低，您需要升级到最新版本！"
M.to_update_content_txt_2 = "客官有新版本了，我们修复了细节问题，优化交互体验！已经为您准备好了，是否立即更新？"
M.to_update_low_version_txt = "您当前版本过低，请前往下载最新版本！"

-- M.chat_txt_1 = "大家好，很高兴见到各位"
-- M.chat_txt_2 = "跟你合作真的太愉快了"
-- M.chat_txt_3 = "你的牌打的也太好了~"
-- M.chat_txt_4 = "不怕神一样的对手，就怕猪一样的队友"
-- M.chat_txt_5 = "不要吵了，安心玩游戏吧"
-- M.chat_txt_6 = "再见了，不要想念我哦"

M.chat_txt_1 = "很高兴见到各位"
M.chat_txt_2 = "运气不错哦！"
M.chat_txt_3 = "太厉害了！"
M.chat_txt_4 = "你可太背了！"
M.chat_txt_5 = "别走啊，决战到天亮"
M.chat_txt_6 = "赢的太轻松了"

M.wan_unit = "万"
M.qian_unit = "千"
M.second_unit = "秒"
M.money_unit = "元"
M.pin_txt_1 = "请输入验证码"
M.pin_txt_2 = "安全密码为六位数字，请重新输入安全密码"
M.pin_txt_3 = "s重新发送"

M.luck_txt_1= "购买成功"

M.bind_txt_1 = "成功绑定后将获赠"
M.bind_txt_2 = "，是否前往绑定？"
M.hall_txt_1 = "在线%d人"
M.hall_txt_2 = "复制成功"
M.hall_txt_3 = "客服按钮暂未实现功能"
M.hall_txt_4 = "真人视讯百家乐近期将上线哦"
M.hall_txt_5 = "敬请期待"
M.hall_txt_6 = "准入："

M.exchange_txt_1 = "当前余额：" 

M.promit_txt_1 = "维护时间：%s 到 %s"

M.login_txt_1 = "请输入开关"
M.login_txt_2 = "找不到c:\\key.txt, 请咨询客户端开发人员"

M.person_txt_1 = "复制成功"
M.person_txt_2 = "已到底"
M.person_txt_3 = "我的ID："
M.person_txt_4 = "余额："
M.person_txt_5 = "保险箱余额:"
M.person_txt_6 = "未领取：" 
M.person_txt_7 = "进桌前："
M.person_txt_8 = "退桌后："
M.person_txt_9 = "（进） - "
M.person_txt_10 = "（退）"
M.person_txt_11 = "订单号："
M.person_txt_12 = "提现 - " 

M.shop_txt_1 = "游戏版本过低，请联系客服获取最新版"

M.agree_txt_1 = [==[
1.提前确定绑定银行卡信息准确无误
2.提现收取提现金额3%手续费
3.请务必使用指定银行卡，不要使用信用卡，信用卡无法正常收款
4.请输入正确的银行卡账号、以及持卡人姓名，否则会导致兑换失败
5.豪门牛牛承诺保护您的银行卡账号、手机号等隐私信息
6.请务必保管好您的银行卡和支付宝密码，如有遗漏请联系官方客服
    ]==]   

M.enter_game_fail = "游戏进入失败，请重试！" 
M.chat_input_placeHolder_txt = "可输入10个汉字字符"
M.chat_too_frequently_txt = "请勿频繁操作。"
M.chat_limit_empty_txt = "您输入内容为空，请重新输入。"
M.chat_shangzuo_txt = "需要上座或上庄才可发起聊天"
M.chat_pangguan_txt = "您当前处于旁观状态，无法进行聊天"
M.chat_myself_txt = "我"
M.use_status = {
    [0] = "",
    [1] = "使用中",
    [2] = "暂未购买"
}
M.head_mask_shop_mark_txt = "您将消耗%s%s购买此头像框(%s天)"
M.head_mask_buy_error_txt = "请选择购买数量！"
M.head_mask_buy_success_txt = "恭喜您，购买成功，共消耗%s"
M.head_mask_user_success_txt = "头像框使用成功"
M.showInsufficientTxt = "您的金币不足，请充值后再试"

-------- 牌桌列表 --------
M.table_tips_txt_1 = "场次维护中..."
M.table_tips_txt_2 = "正在努力拉取场次信息中..."

-------- 社区相关 --------
M.quit_sequeces_txt = "您操作过于频繁，将在3天内无法退出社区！"
M.become_master_txt = "感谢您的申请，审核通过将会通知您!"
M.community_tips_txt = "退出社区将享受不到社区相应福利!"
M.community_tips_txt_2 = "恭喜您已加入%s的社区！"

GameTxt = M