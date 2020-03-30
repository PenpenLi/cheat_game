local M = {}

local prefix = "game_niuniu/"


--[[json文件路径start]]
M.chatViewJson   = prefix.."ui/chat.json"         -- 炸金牛
M.HALL           = prefix.."ui/niuniu_hall_1.json"   -- 大厅界面


-- 炸金牛  png  start --
M.gold_coin             = "niuniu_gold.png"                          --金币
M.gold_diu              = prefix.."game/gold-coin.png"                           --丢金币
M.silver_coin           = prefix.."game/sliver.png"                           --银币
M.gold_brick            = prefix.."game/goldk.png"                            --金砖
M.progresstimer         = prefix.."game/game_user_timer.png"                  --进度条
M.progresstimer_line    = prefix.."game/game_user_timer_line.png"             --进度条
M.WINMONEY_FNT          = prefix.."game/add_123-export.fnt"--"game/winmoney.fnt"                         --fnt字体
M.KAN_WINMONEY_FNT      = prefix.."game/add_123-export.fnt"                         --fnt字体
M.KAN_LOSTMONEY_FNT     = prefix.."game/Reduction_123-export.fnt"                         --fnt字体
M.WINMONEY_BACK         = prefix.."game/winmoneyback.png"--"game/winmoneyback.png"                     --赢钱数后面的背景
M.LOSTMONEY_BACK        = prefix.."game/lose-01.png"                     --赢钱数后面的背景
M.LIGHTCARD_CARDBG      = prefix.."game/lightcardbg.png"                      --亮牌动画牌的背景
M.NUM_BG                = prefix.."game/num_bg.png"                           --赢钱数字的背景
M.KISS                  = "zjn_kiss.png"                          --kiss
M.PK_KUANG              = prefix.."game/pkkuang.png"                          --pkkuang
M.PK_ARROW              = prefix.."game/arrow.png"                            --arrow.png
M.BTN_YELLOW            = "zjn_btn2.png"
M.LIANG                 = prefix.."game/liang.png"
M.TIPS_BG               = prefix.."game/frame01.png"
M.Loading               = prefix.."game/loding.png"                           --loading界面
M.Title_zha             = prefix.."ui/niuniu_hall/Front_hal_010_06.png"
M.Titile_niu            = prefix.."ui/niuniu_hall/Front_hal_dou_niu.png"
--炸金牛 end --

M.game_chat1 = prefix.."game/game_chat1.png"
M.game_chat2 = prefix.."game/game_chat2.png"
--chat end ---

--看牌抢庄--
M.Kan_pai_room = prefix.."ui/game_douniu.json"
M.Kan_start    = prefix.."armature_anim/kangame/start/StartGO.ExportJson"
M.Kan_start_list_0 = prefix.."armature_anim/kangame/start/StartGO0.plist"
M.Kan_start_list_1 = prefix.."armature_anim/kangame/start/StartGO1.plist"
M.Kan_start_list_2 = prefix.."armature_anim/kangame/start/StartGO2.plist"
M.Zhuang_heng      = prefix.."armature_anim/kangame/Rob_zhuang_heng01/Rob_zhuang_heng01.ExportJson"
M.Zhuang_heng_list = prefix.."armature_anim/kangame/Rob_zhuang_heng01/Rob_zhuang_heng010.plist"
M.Zhuang_shu       = prefix.."armature_anim/kangame/Rob_zhuang_shu01/Rob_zhuang_shu01.ExportJson"
M.Zhuang_shu_list  = prefix.."armature_anim/kangame/Rob_zhuang_shu01/Rob_zhuang_shu010.plist"

M.Kan_niu_0        = "dn_meiniu.png"
M.Kan_niu_1        = "dn_niuyi.png"
M.Kan_niu_2        = "dn_niuer.png"
M.Kan_niu_3        = "dn_niusan.png"
M.Kan_niu_4        = "dn_niusi.png"
M.Kan_niu_5        = "dn_niuwu.png"
M.Kan_niu_6        = "dn_niuliu.png"
M.Kan_niu_7        = "dn_niuqi.png"
M.Kan_niu_8        = "dn_niuba.png"
M.Kan_niu_9        = "dn_niujiu.png"
M.Kan_niu_10        = "dn_niuniu.png"
M.Kan_niu_15        = "dn_sizha.png"
M.Kan_niu_17        = "dn_wuhua.png"
M.Kan_niu_18        = "dn_wuxiao.png"
M.Kan_niu_wan      = "dn_weancheng1.png"

M.Kan_win          = prefix.."armature_anim/win_money/win_money03.ExportJson"
M.Kan_win_list_0   = prefix.."armature_anim/win_money/win_money030.plist"
M.Kan_win_list_1   = prefix.."armature_anim/win_money/win_money031.plist"

M.Kan_lost          = prefix.."armature_anim/lose_money/win_money00.ExportJson"
M.Kan_lost_list_0   = prefix.."armature_anim/lose_money/win_money000.plist"
M.Kan_lost_list_1   = prefix.."armature_anim/lose_money/win_money001.plist"
M.Kan_chupai_timer  = "dn_quan.png"
M.Kan_chupai_timer1  = "dn_quan_01.png"
M.Kan_chupai_timer_font_green  = prefix.."ui/game_douniu/digital_07-export.fnt"
M.Kan_chupai_timer_font_yellow  = prefix.."ui/game_douniu/digital_08-export.fnt"
M.Kan_chupai_timer_font_red  = prefix.."ui/game_douniu/digital_06-export.fnt"

M.Kan_chu_niu        = prefix.."armature_anim/kangame/chupai/kaipai.ExportJson"
M.Kan_chu_niu_list_0 = prefix.."armature_anim/kangame/start/kaipai0.plist"

M.Title_kan             = prefix.."ui/niuniu_hall/Front_hal_009_07.png"

--看牌抢庄end--

--poker --
M.poker_f01=prefix.."card/poker_f01.png"
M.poker_f02=prefix.."card/poker_f02.png"
M.poker_f03=prefix.."card/poker_f03.png"
M.poker_f04=prefix.."card/poker_f04.png"
M.poker_f05=prefix.."card/poker_f05.png"
M.poker_f06=prefix.."card/poker_f06.png"
M.poker_f07=prefix.."card/poker_f07.png"
M.poker_f08=prefix.."card/poker_f08.png"
M.poker_f09=prefix.."card/poker_f09.png"
M.poker_f10=prefix.."card/poker_f10.png"
M.poker_f11=prefix.."card/poker_f11.png"
M.poker_f12=prefix.."card/poker_f12.png"
M.poker_f13=prefix.."card/poker_f13.png"
M.poker_h01=prefix.."card/poker_h01.png"
M.poker_h02=prefix.."card/poker_h02.png"
M.poker_h03=prefix.."card/poker_h03.png"
M.poker_h04=prefix.."card/poker_h04.png"
M.poker_h05=prefix.."card/poker_h05.png"
M.poker_h06=prefix.."card/poker_h06.png"
M.poker_h07=prefix.."card/poker_h07.png"
M.poker_h08=prefix.."card/poker_h08.png"
M.poker_h09=prefix.."card/poker_h09.png"
M.poker_h10=prefix.."card/poker_h10.png"
M.poker_h11=prefix.."card/poker_h11.png"
M.poker_h12=prefix.."card/poker_h12.png"
M.poker_h13=prefix.."card/poker_h13.png"
M.poker_m01=prefix.."card/poker_m01.png"
M.poker_m02=prefix.."card/poker_m02.png"
M.poker_m03=prefix.."card/poker_m03.png"
M.poker_m04=prefix.."card/poker_m04.png"
M.poker_m05=prefix.."card/poker_m05.png"
M.poker_m06=prefix.."card/poker_m06.png"
M.poker_m07=prefix.."card/poker_m07.png"
M.poker_m08=prefix.."card/poker_m08.png"
M.poker_m09=prefix.."card/poker_m09.png"
M.poker_m10=prefix.."card/poker_m10.png"
M.poker_m11=prefix.."card/poker_m11.png"
M.poker_m12=prefix.."card/poker_m12.png"
M.poker_m13=prefix.."card/poker_m13.png"
M.poker_r01=prefix.."card/poker_r01.png"
M.poker_r02=prefix.."card/poker_r02.png"
M.poker_r03=prefix.."card/poker_r03.png"
M.poker_r04=prefix.."card/poker_r04.png"
M.poker_r05=prefix.."card/poker_r05.png"
M.poker_r06=prefix.."card/poker_r06.png"
M.poker_r07=prefix.."card/poker_r07.png"
M.poker_r08=prefix.."card/poker_r08.png"
M.poker_r09=prefix.."card/poker_r09.png"
M.poker_r10=prefix.."card/poker_r10.png"
M.poker_r11=prefix.."card/poker_r11.png"
M.poker_r12=prefix.."card/poker_r12.png"
M.poker_r13=prefix.."card/poker_r13.png"
M.pokerback=prefix.."card/poker.png"
M.pokerlightback=prefix.."game/poker-border.png"
-- pokre end--



--场次图片
M.changci_1 = prefix.."ui/niuniu_hall/_0005_01.png"  --新手场
M.changci_2 = prefix.."ui/niuniu_hall/_0004_02.png"  --初级场
M.changci_3 = prefix.."ui/niuniu_hall/_0003_03.png"  --中级场
M.changci_4 = prefix.."ui/niuniu_hall/_0002_04.png"  --高级场
M.changci_5 = prefix.."ui/niuniu_hall/_0001_05.png"  --伯爵场
M.changci_6 = prefix.."ui/niuniu_hall/_0000_06.png"  --尊爵场

--music  0男 1 女--
M.all_music ={
	GEN_ALL    = prefix.."sound/COMMON_CLICK_BTN_SOUND.mp3",
	DIU_CHIPS  = prefix.."sound/Coin_Changed_Sound.mp3",
	COLLECT     = prefix.."sound/Coin_Changed_Sound.mp3",

	FLIP        = prefix.."sound/Deal_Card_Sound_A.mp3",
	START       = prefix.."sound/Rand_Game_Start_Sound.mp3",
	SETZHUANG   = prefix.."sound/set_banker.mp3",
	QIANG       = prefix.."sound/ApplyBank.mp3",
	COMPLETE_0  = prefix.."sound/COMMON_FLIP_CARD_SOUND_A.mp3",
	COMPLETE_1  = prefix.."sound/COMMON_FLIP_CARD_SOUND_B.mp3",
	COU_PAI     = prefix.."sound/Rand_Deal_Card_Sound.mp3",
	NIU_0_0     = prefix.."sound/OX_NO_MALE_SOUND.mp3",
	NIU_1_0     = prefix.."sound/OX_NO_FEMALE_SOUND.mp3",
	NIU_0_1     = prefix.."sound/OX_1_MALE_SOUND.mp3",
	NIU_1_1     = prefix.."sound/OX_1_FEMALE_SOUND.mp3",
	NIU_0_2     = prefix.."sound/OX_2_MALE_SOUND.mp3",
	NIU_1_2     = prefix.."sound/OX_2_FEMALE_SOUND.mp3",
	NIU_0_3     = prefix.."sound/OX_3_MALE_SOUND.mp3",
	NIU_1_3     = prefix.."sound/OX_3_FEMALE_SOUND.mp3",
	NIU_0_4     = prefix.."sound/OX_4_MALE_SOUND.mp3",
	NIU_1_4     = prefix.."sound/OX_4_FEMALE_SOUND.mp3",
	NIU_0_5     = prefix.."sound/OX_5_MALE_SOUND.mp3",
	NIU_1_5     = prefix.."sound/OX_5_FEMALE_SOUND.mp3",
	NIU_0_6     = prefix.."sound/OX_6_MALE_SOUND.mp3",
	NIU_1_6     = prefix.."sound/OX_6_FEMALE_SOUND.mp3",
	NIU_0_7     = prefix.."sound/OX_7_MALE_SOUND.mp3",
	NIU_1_7     = prefix.."sound/OX_7_FEMALE_SOUND.mp3",
	NIU_0_8     = prefix.."sound/OX_8_MALE_SOUND.mp3",
	NIU_1_8     = prefix.."sound/OX_8_FEMALE_SOUND.mp3",
	NIU_0_9     = prefix.."sound/OX_9_MALE_SOUND.mp3",
	NIU_1_9     = prefix.."sound/OX_9_FEMALE_SOUND.mp3",
	NIU_0_10     = prefix.."sound/OX_10_MALE_SOUND.mp3",
	NIU_1_10     = prefix.."sound/OX_10_FEMALE_SOUND.mp3",
	NIU_0_15     = prefix.."sound/OX_BOMB_MALE_SOUND.mp3",
	NIU_1_15     = prefix.."sound/OX_BOMB_FEMALE_SOUND.mp3",
	NIU_0_17     = prefix.."sound/OX_SUPEROX_MALE_SOUND.mp3",
	NIU_1_17     = prefix.."sound/OX_SUPEROX_FEMALE_SOUND.mp3",
	NIU_0_18     = prefix.."sound/OX_5_LITTLE_OX_FEMALE_SOUND.mp3",
	NIU_1_18     = prefix.."sound/OX_5_LITTLE_OX_MALE_SOUND.mp3",
	SHOU         = prefix.."sound/shou.mp3",
	WIN_GAME     = prefix.."sound/win.mp3",
	LOST_GAME    = prefix.."sound/lost.mp3",
	chipsSound= prefix.."sound/chips.mp3",
	TimeIsOver= prefix.."sound/timeisover.mp3",
	CHAT_0   = prefix.."sound/chat/chat%s_man.mp3",
	CHAT_1   = prefix.."sound/chat/chat%s_wom.mp3",
}


M.DARD_FNT=prefix.."ui/game_douniu/digital_03_01-export.fnt"  --黑色字体
M.LIGHT_FNT=prefix.."ui/game_douniu/digital_03-export-export.fnt"  --亮色字体

--美女皇冠显示
M.beauty_rank_hat_1 = prefix.."ui/beauty/global_ranking_gold_img01.png"
M.beauty_rank_hat_2 = prefix.."ui/beauty/global_ranking_silver_img01.png"
M.beauty_rank_hat_3 = prefix.."ui/beauty/global_ranking_copper_img01.png"
M.beauty_rank_hat_4 = prefix.."ui/beauty/global_is_sex_img.png"
M.beauty_rank_bg1 = prefix.."ui/beauty/global_ranking_mvbk01.png"
M.beauty_rank_bg2 = prefix.."ui/beauty/global_ranking_mvbk02.png"
M.beauty_normal_bg1 = prefix.."ui/hall/circle.png"
M.beauty_normal_bg2 = prefix.."ui/hall/infobg.png"

M.kp_beauty_rank_bg1 = "dn_shupai_01.png"
M.kp_beauty_rank_bg2 = "dn_hengpaibg_01.png"
M.kp_beauty_normal_bg1 = "dn_shupai.png"
M.kp_beauty_normal_bg2 = "dn_hengpaibg.png"

M.brownDesk = prefix .. "ui/game_douniu/paizhuo.jpg"
M.brownTishiyu = "dn_tishiyu.png"
M.brownTishiyuFnt = prefix .. "ui/game_douniu/zjh_tsy_01-export.fnt"
M.brownBackCard = prefix .. "card/poker.png"
M.brownPrepareStart = prefix .. "ui/game_douniu/zjh_tsy_04.png"
M.brownPrepareStartBg = prefix .. "ui/game_douniu/dn_zjh_tsy_02.png"
M.brownDigitalFnt =  prefix .. "ui/game_douniu/digital_05-export.fnt"
M.brownDnNumDi = "dn_num.png"

M.blueDesk = prefix .. "ui/game_douniu/blue_paizhuo.jpg"
M.blueTishiyu = "blue_dn_tishiyu.png"
M.blueTishiyuFnt = prefix .. "ui/game_douniu/blue_zjh_tsy_01-export.fnt"
M.blueBackCard = prefix .. "card/blue_poker.png"
M.bluePrepareStart = prefix .. "ui/game_douniu/blue_zjh_tsy_04.png"
M.bluePrepareStartBg = prefix .. "ui/game_douniu/blue_dn_zjh_tsy_02.png"
M.blueDigitalFnt =  prefix .. "ui/game_douniu/blue_digital_05-export.fnt"
M.blueDnNumDi =  "blue_dn_num.png"

Niuniu_Games_res = {}
Niuniu_Games_res = M