local M = {}
--desk start --
M.Desk_base     = "底分%d   上限%d"
M.Desk_round    = "本局下注  第%d/%d轮"
M.Kanpai        = "看牌"
M.Fold          = "弃牌"
M.Compare_fail  = "比牌失败"
M.Game_starting = "游戏即将开始:%d"
M.Game_started  = "游戏正在进行中,请等待"
M.Game_quited   = "因长时间没有游戏,您已离开游戏."
M.Game_has_quit = "您已离开游戏"
M.Game_compare_all = "下分封顶开始比牌"
M.Game_choose_quit = "您正在游戏中,确定要离开么?"
M.Game_cuohe       = "正在撮合..."
M.Game_no_gold     = "金额不足"
-- desk end --

--看牌抢庄--
M.Kan_qiang_zhuang = "请抢庄:%d"
M.Kan_xia_fen      = "请选择下分数:%d"
M.Kan_xia_fen_deng = "请等待其他玩家下分:%d"
M.Kan_you_niu      = "手上的牌是有牛的噢,再看一眼?"
M.Kan_san_zhang    = "未选满三张牌没法有牛哟!"
M.Kan_no_niu       = "'有牛'需要是10的倍数哦!"
M.Kan_no_card      = "没办法选择更多牌啦!"
M.Kan_had_user     = "还有人在冥思苦想中:%d"
M.Kan_calc         = "%d"
M.Kan_no_quit      = "游戏正在进行中,本局完成后自动退出"
M.Kan_quit_tuo     = "现在退出,系统将帮你打完这一局哟!"
M.Kan_jin_fail     = "进入房间失败,请重试!"
M.Base_fen         = "底分%s"
M.Gameing          = "游戏正在进行中..."
M.Limit            = "进房下限"
M.Waiting          = "正在等待玩家进入..."


M.Call             = "%s跟注"
M.Fire             = "%s火拼"
M.Compare          = "%s比牌"
M.Deskinfo         = "底分:%d 单注上限:%s"
M.DeskTurn         = "第%d/%d轮"
M.Auto_call        = "自动跟注"
M.Cancel_auto_call = "取消跟注"


M.Fire_free        = "本次免费"
M.Fire_cost        = "x%d"



--看牌抢庄end--


M.Daily_login = {
	[1] = '第一天',
	[2] = '第二天',
	[3] = '第三天',
	[4] = '第四天',
	[5] = '第五天',
	[6] = '第六天',
	[7] = '第七天',
}

M.QuicklyChatWord = {"不要走，决战到天亮",
"你的牌打得也太好了",
"开个好牌啊",
"唉，现在又处于下风",	
}
M.string_chat_noble_anim_path= {BrRes.chat_noble_allin, BrRes.chat_noble_help,BrRes.chat_noble_hi, 
    BrRes.chat_noble_feck,BrRes.chat_noble_check,BrRes.chat_noble_aa,BrRes.chat_noble_omg,
    BrRes.chat_noble_you ,BrRes.chat_noble_no, BrRes.chat_noble_ha}    
M.string_chat_noble_action_name = {"NewAnimation2", "NewAnimation5","NewAnimation6", 
    "NewAnimation4","NewAnimation7",
    "NewAnimation", "NewAnimationHJH", "NewAnimation10", "NewAnimation9","NewAnimation3"}
M.string_chat_noble_action_plist = {BrRes.chat_noble_allin_plist, BrRes.chat_noble_help_plist,BrRes.chat_noble_hi_plist, 
    BrRes.chat_noble_feck_plist,BrRes.chat_noble_check_plist,BrRes.chat_noble_aa_plist,BrRes.chat_noble_omg_plist,
    BrRes.chat_noble_you_plist ,BrRes.chat_noble_no_plist, BrRes.chat_noble_ha_plist}
    
M.string_chat_noble_action_png = {BrRes.chat_noble_allin_png, BrRes.chat_noble_help_png,BrRes.chat_noble_hi_png, 
    BrRes.chat_noble_feck_png,BrRes.chat_noble_check_png,BrRes.chat_noble_aa_png,BrRes.chat_noble_omg_png,
    BrRes.chat_noble_you_png ,BrRes.chat_noble_no_png, BrRes.chat_noble_ha_png}

M.br_state = {
    [1] = {"休息一下", "上一手结算中"},
    [2] = "下注时间"
}

M.delarWait = "等待：%d人"
M.delar_tips = "至少携带%s"
M.br_delarlist_exit_tip = "申请下庄成功！如果您是庄家，将在本局结束后下庄！"
M.br_sitdown_failed_error = "哎呀，有人手速更快先抢到座位了呢"
M.br_sitdown_failed_error1 = "您已经是庄家了"

M.br_delar_exit_tips = "已经在游戏中"
M.br_ingame = "正在游戏中"

M.br_bet_error3 = "不在下注时间哦！"
M.system_dealer = "系统当庄"
M.LEASTTIP = "下注所需最低携带%s%s"

M.br_delarlist_txt1 = "上庄条件需%s，低于%s或连续上庄10局将自动下庄"
M.br_delarlist_btn_1 = "申请上庄"
M.br_delarlist_btn_2 = "申请下庄"
M.br_delarlist_wait_num = "当前等待上庄人数: %s人"
M.br_delarlist_nobody = "当前无庄"
M.br_delarlist_success = "成功进入上庄队列"
M.br_delar_stand_error_tips = "您现在是庄家，无法站起"
M.br_stand_tips = "您现在还没有坐下"

M.br_choose_bet_error = "请先选定下注金额"

BrTXT = M