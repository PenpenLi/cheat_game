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
M.Deskinfo         = "底分:%f 单注上限:%f"
M.DeskTurn         = "第%d/%d轮"
M.Auto_call        = "自动跟注"
M.Cancel_auto_call = "取消跟注"


M.Fire_free        = "本次免费"
M.Fire_cost        = "x%d"

M.Daily_login = {
	[1] = '第一天',
	[2] = '第二天',
	[3] = '第三天',
	[4] = '第四天',
	[5] = '第五天',
	[6] = '第六天',
	[7] = '第七天',
}

M.QuicklyChatWord = {
	"不要走，决战到天亮",
	"你的牌打得也太好了",
	"开个好牌啊",
	"唉，现在又处于下风"
}

M.CardType_txt = {
 [0]  = "高牌",
 [1]  = '对子',
 [2]  = '顺子',  
 [3]  = '金三顺',  
 [4]  = '同花顺', 
 [5]  = '三条', 
}

--站起相关 start
M.stand_fail_up = "站起失败"
M.stand_up_tips = "您正在游戏中确定要站起么？"
--站起相关 end

--聊天 
M.chat_other_num_str = "%s人"

--选场
M.hall_limt_txt = "以上"
M.hall_limt_txt_1 = "单注上限:"
M.hall_limt_txt_2 = "底分"

--游戏提示
M.game_tips_1 = "前面还有%d人等待"
M.game_tips_2 = "等待坐下，前面还有%d人"

M.dila_txt_1 = '听说打赏越多来好牌的几率越大哦~'
M.dila_txt_2 = '再来一次打赏，再来一次好牌~'
M.dila_txt_3 = '输牌赢牌，都不要忘记打赏哦~'
M.dila_txt_4 = '看牌之后再下注，获胜的几率才会高哦~'
M.dila_txt_5 = '赢了别忘记打赏我哦~'
M.dila_txt_6 = '打赏的越多收获的越多~'
M.dila_txt_7 = '听说打赏的越多，获胜的机会越大哦~'

M.chat_txt_1 = "大家好，很高兴见到各位"
M.chat_txt_2 = "运气不错哦！"
M.chat_txt_3 = "太厉害了！"
M.chat_txt_4 = "你可太背了"
M.chat_txt_5 = "别走啊，决战到天亮"
M.chat_txt_6 = "赢的太轻松了"
M.chat_txt_7 = "唉，输光了，洗洗睡了"
M.chat_txt_8 = "今日运气不好，我明日再来"
M.chat_txt_9 = "开个好牌啊"
M.chat_txt_10 = "快点吧，我等的花儿都谢了"
M.chat_txt_11 = "唉，现在又处于下风"
M.chat_txt_12 = "你的牌打得也太好了"
M.chat_txt_13 = "天灵灵地灵灵，太上老君快显灵"
M.chat_txt_14 = "不要一把全下，细水要长流"
M.chat_txt_15 = "青山不改，绿水长流，后会有期"

Zjh_GameTxt = M