local M = {}

local prefix = "game_zjh/"


--大厅--
--场次图片
M.HallJsonView  = prefix.."ui/niuniu_hall_1.json"         -- 炸金花大厅场景
M.zjhHallPlist = prefix.."ui/zjh_hall/zjh_hall.plist" --炸金花大厅plist
M.zjhHallPng = prefix.."ui/zjh_hall/zjh_hall.png"
--大厅end--


--ui场景start--
M.ZjhJsonView   = prefix.."ui/game_zjh.json"                -- 炸金花游戏场景
M.gamePlist= prefix.."ui/zjh_game/zjh_game.plist"
M.gamePng= prefix.."ui/zjh_game/zjh_game.png"
M.giftLeadPlist= prefix.."ui/NewsLead/zjh_giftLead.plist"
M.giftLeadPng= prefix.."ui/NewsLead/zjh_giftLead.png"
--ui场景end--



M.chatViewJson   = prefix.."ui/chat.json"         -- 聊天


--poker --
M.pokerlightback=prefix.."game/poker-border.png"


M.Chips_1= "zjh_Chip_jia01.png"
M.Chips_2= "zjh_Chip_jia02.png"
M.Chips_3= "zjh_Chip_jia03.png"
M.Chips_4= "zjh_Chip_jia04.png"
M.Chips_5= "zjh_Chip_jia05.png"
-- M.Chips_6= "zjh_0023_24.png"


M.CardType_1= "zjh_0008_09.png"
M.CardType_2= "zjh_0009_10.png"
M.CardType_3= "zjh_0010_11.png"
M.CardType_4= "zjh_0015_16.png"
M.CardType_5= "zjh_0011_12.png"
M.CardType_6= "zjh_0012_13.png"

M.Chips_font = prefix.."ui/zjh_game/Chip_digital01-export.fnt"
M.Chips_font_1 = prefix.."ui/zjh_game/Chip_digital03-export.fnt"
M.Chips_font_2 = prefix.."ui/zjh_game/Chip_digital02-export.fnt"

M.progresstimer         = prefix.."game/game_user_timer.png"                  --进度条


M.Status_black    = "zjh_0005_06.png" 
M.Status_white    = "zjh_0024_25.png" 
M.Status_GiveUp     = "zjh_pqbs__0000_05.png" 
M.Status_CompareFail     = "zjh_pqbs__0001_04.png" 

M.PK_KUANG              = prefix.."game/pkkuang.png"                          --pkkuang
M.PK_ARROW              = prefix.."game/arrow.png"                            --arrow.png


--动画 start--
M.PK          = prefix.."armature_anim/game/pk/pk001.ExportJson"               --pk动画
M.PKFIRE = prefix.."armature_anim/game/zjh_bomb/zjh_bomb.ExportJson"		 --pk扔炸弹
M.PK_LIST_01  = prefix.."armature_anim/game/pk/pk0010.plist"
M.PK_LIST_02  = prefix.."armature_anim/game/pk/pk0011.plist"
--M.PK_LIST_03  = prefix.."armature_anim/game/pk/pk0012.plist"
M.PKFIRE_LIST  = prefix.."armature_anim/game/zjh_bomb/zjh_bomb0.plist"		 --pk扔炸弹

M.cancelBtnAni  = prefix.."armature_anim/game/cancelBtnAni/NewAnimation.ExportJson"		 --取消动画
M.cancelBtnPlist  = prefix.."armature_anim/game/cancelBtnAni/NewAnimation0.plist"		 --取消动画

M.callBtnAni  = prefix.."armature_anim/game/callBtnAni/NewAnimation.ExportJson"		 --取消动画
M.callBtnPlist  = prefix.."armature_anim/game/callBtnAni/NewAnimation0.plist"		 --取消动画

M.GUZHUYIZHI          = prefix.."armature_anim/game/guzhuyizhi/guzhuyizhi.ExportJson"               --孤注一掷
M.GUZHUYIZHI_PLIST    = prefix.."armature_anim/game/guzhuyizhi/guzhuyizhi0.plist"               --


M.WINNERSHOW          = prefix.."armature_anim/game/wm_01/win_money.ExportJson"               --赢牌玩家
M.WINNERSHOW_PLIST    = prefix.."armature_anim/game/wm_01/win_money0.plist"               --

M.BUTTONFIRE          = prefix.."armature_anim/game/button_fire/button_fire.ExportJson"               --按钮火
M.BUTTONFIRE_LIST_01  = prefix.."armature_anim/game/button_fire/button_fire0.plist"               --按钮火


M.YOUWIN         = prefix.."armature_anim/game/JHyou_win/JHyou_win.ExportJson"               --pk动画
M.YOUWIN_LIST_01 = prefix.."armature_anim/game/JHyou_win/JHyou_win0.plist"               --pk动画

M.KUANGFIRE         = prefix.."armature_anim/game/fire_touxiangkuang/fire_touxiangkuang.ExportJson"               --头像框火
M.KUANGFIRE_LIST_01  = prefix.."armature_anim/game/fire_touxiangkuang/fire_touxiangkuang0.plist"               --头像框火


-- M.SANTIAO          = prefix.."armature_anim/game/Article_3/Article_3.ExportJson"               --三条动画
-- M.SANTIAO_LIST_01  = prefix.."armature_anim/game/Article_3/Article_30.plist"                   --三条动画
M.SANTIAO          = prefix.."armature_anim/game/baozi_01/baozi_01.ExportJson"               --三条动画
M.SANTIAO_LIST_01  = prefix.."armature_anim/game/baozi_01/baozi_010.plist"                   --三条动画
M.SANTIAO_LIST_02  = prefix.."armature_anim/game/baozi_01/baozi_011.plist"                   --三条动画
M.SANTIAO_LIST_03  = prefix.."armature_anim/game/baozi_01/baozi_012.plist"                   --三条动画

-- M.TONGHUASHUN          = prefix.."armature_anim/game/flush/flush.ExportJson"               --同花顺动画
-- M.TONGHUASHUN_LIST_01  = prefix.."armature_anim/game/flush/flush0.plist"                   --同花顺动画
M.TONGHUASHUN          = prefix.."armature_anim/game/flush_01/flush.ExportJson"               --同花顺动画
M.TONGHUASHUN_LIST_01  = prefix.."armature_anim/game/flush_01/flush0.plist"                   --同花顺动画


M.BIGCARDBG            = "zjh_lianpai.png"                   --同花顺动画


M.WINMONEY_FNT          = prefix.."game/add_123-export.fnt"--prefix.."game/winmoney.fnt"                         --fnt字体


M.ALLFIRE         = prefix.."armature_anim/game/all_fire/all_fire.ExportJson"               --头像框火
M.ALLFIRE_LIST_01  = prefix.."armature_anim/game/all_fire/all_fire0.plist"               --头像框火
M.ALLFIRE_LIST_02  = prefix.."armature_anim/game/all_fire/all_fire1.plist"               --头像框火
M.ALLFIRE_LIST_03  = prefix.."armature_anim/game/all_fire/all_fire2.plist"               --头像框火
M.ALLFIRE_LIST_04  = prefix.."armature_anim/game/all_fire/all_fire3.plist"               --头像框火
M.ALLFIRE_LIST_05  = prefix.."armature_anim/game/all_fire/all_fire4.plist"               --头像框火
--chat start --
M.game_chat1 = prefix.."game/game_chat1.png"
M.game_chat2 = prefix.."game/game_chat2.png"
M.game_chat3 = prefix.."game/game_chat3.png"
--chat end ---
M.TIPS_BG               = prefix.."game/frame01.png"						 --tips背景
M.Loading               = prefix.."game/loding.png"                           --loading界面

M.BTN_YELLOW            = prefix.."game/btn2.png"
M.LIANG                 = prefix.."game/liang.png"
M.NUM_BG                = prefix.."game/num_bg.png"                           --赢钱数字的背景
M.LIGHTCARD_CARDBG      = prefix.."game/lightcardbg.png"                      --亮牌动画牌的背景
M.KISS                  = prefix.."game/kiss.png"                          --kiss


-- M.GAMEBG				=prefix.."ui/zjh_game/zjh_background_0%s.jpg"  --背景1 
M.BLUEGAMEBG			=prefix.."ui/zjh_game/newGameRes/blueDesk.png"  --背景1 
M.REDGAMEBG				=prefix.."ui/zjh_game/newGameRes/redDesk.png"  --背景1
M.GAMEBG_1				=prefix.."ui/zjh_game/newGameRes/bg.png"  --背景1
M.GAMEBG_2				=prefix.."ui/zjh_game/newGameRes/bg_2.png"  --背景1 
M.DILA					="zjh_0013_%s.png"  --背景1  
M.CHIPBG0				="zjh_zuanshi_di.png"  --背景1 
M.CHIPBG1				="zjh_0016_18.png"  --背景1  
M.CHIPICON0				="zjh_0017_18.png"  --背景1 
M.CHIPICON1				="zjh_0017_19.png"  --背景1  
--music  0男 1 女--
M.all_music ={
	GEN_ALL    = prefix.."sound/COMMON_CLICK_BTN_SOUND.mp3",
	DIU_CHIPS  = prefix.."sound/Coin_Changed_Sound.mp3",
	COLLECT     = prefix.."sound/Coin_Changed_Sound.mp3",
	BAOZI_1 = prefix.."sound/BAOZI_MAN.mp3",
	BAOZI_0 = prefix.."sound/BAOZI_WOM.mp3",
	BI_PAI  = prefix.."sound/BI_PAI.mp3",
	BIPAI_0_1 = prefix.."sound/Npk1.mp3",
	BIPAI_0_2 = prefix.."sound/Npk2.mp3",
	BIPAI_1   = prefix.."sound/pk1.mp3",
	BIPAI_WIN   = prefix.."sound/BI_PAI_WIN.mp3",
	DALI_KISS   = prefix.."sound/DALI_KISS.mp3",
	DUIZI_0   = prefix.."sound/DUIZI_MAN.mp3",
	DUIZI_1   = prefix.."sound/DUIZI_WOM.mp3",
	FAIL   = prefix.."sound/FAIL.mp3",
	GAOPAI_0   = prefix.."sound/GAOPAI_MAN.mp3",
	GAOPAI_1   = prefix.."sound/GAOPAI_WOM.mp3",
	JIAZHU   = prefix.."sound/JIAZHU.mp3",
	JIAZHU_0_1   = prefix.."sound/Njiazhu1.mp3",
	JIAZHU_0_2   = prefix.."sound/Njiazhu2.mp3",
	JIAZHU_0_3   = prefix.."sound/Njiazhu3.mp3",
	JIAZHU_0_4   = prefix.."sound/Njiazhu4.mp3",
	JIAZHU_1_1   = prefix.."sound/jiazhu1.mp3",
	JIAZHU_1_2   = prefix.."sound/jiazhu2.mp3",
	JIAZHU_1_3   = prefix.."sound/jiazhu3.mp3",
	JIAZHU_1_4   = prefix.."sound/jiazhu4.mp3",
	CALL_0_1   = prefix.."sound/Ngenzhu1.mp3",
	CALL_0_2   = prefix.."sound/Ngenzhu2.mp3",
	CALL_0_3   = prefix.."sound/Ngenzhu3.mp3",
	CALL_1_1   = prefix.."sound/genzhu1.mp3",
	CALL_1_2   = prefix.."sound/genzhu2.mp3",
	CALL_1_3   = prefix.."sound/genzhu3.mp3",
	KANPAI_0   = prefix.."sound/Nkanpai1.mp3",
	KANPAI_1   = prefix.."sound/kanpai1.mp3",
	LIANGPAI   = prefix.."sound/LIANGPAI.mp3",
	QIPAI_0_1   = prefix.."sound/Nqipai1.mp3",
	QIPAI_0_2   = prefix.."sound/Nqipai2.mp3",
	QIPAI_0_3   = prefix.."sound/Nqipai3.mp3",
	QIPAI_1 = prefix.."sound/qipai1.mp3",
	SHUNZI_0 = prefix.."sound/SHUNZI_MAN.mp3",
	SHUNZI_1     = prefix.."sound/SHUNZI_WOM.mp3",
	TONGHUA_0         = prefix.."sound/TONGHUA_MAN.mp3",
	TONGHUA_1       = prefix.."sound/TONGHUA_WOM.mp3",
	TONGHUASHUN_0        = prefix.."sound/TONGHUASHUN_MAN.mp3",
	TONGHUASHUN_1       = prefix.."sound/TONGHUASHUN_WOM.mp3",
	XIAYILUN       = prefix.."sound/XIAYILUN.mp3",
	XUEPING  = prefix.."sound/XUEPING.mp3",
	XUEPING_0  = prefix.."sound/XUEPING_MAN.mp3",
	XUEPING_1     = prefix.."sound/XUEPING_WOM.mp3",
	ZHADAN     = prefix.."sound/ZHADAN.mp3",
	COMPARE_BTN = prefix.."sound/zjn_compCard_touchBtn.mp3",
	COMPARE_BTN_CHOOSE = prefix.."sound/zjn_compCard_touchHead.mp3",
	FLIP        = prefix.."sound/Deal_Card_Sound_A.mp3",
	SHOU         = prefix.."sound/shou.mp3",
	LOST_GAME    = prefix.."sound/lost.mp3",
	LIGHTCARD   = prefix.."sound/zjn_showCard_show.mp3",
	CHAT_0   = prefix.."sound/chat/chat%s_man.mp3",
	CHAT_1   = prefix.."sound/chat/chat%s_wom.mp3",
	chipsSound= prefix.."sound/chips.mp3",
	EnterRoom= prefix.."sound/enterroom.mp3",
	GoldChip= prefix.."sound/goldchip.mp3",
	TimeIsOver= prefix.."sound/timeisover.mp3",
	WINGAME= prefix.."sound/win.mp3",
	GUZHUYIZHI_SOUND_0=prefix.."sound/guzhuyizhi_man.mp3",
	GUZHUYIZHI_SOUND_1=prefix.."sound/guzhuyizhi_wom.mp3",
	NOWISME= prefix.."sound/nowisme.mp3",
	TONGHUASHUNSOUND= prefix.."sound/tonghuashun.mp3",
	SANTIAOSOUND= prefix.."sound/santiao.mp3",
}


M.game_big_heart_img = prefix .. "game/game_big_heart.png"
M.game_small_heart_img = prefix .. "game/game_small_heart.png"

M.beauty_rank_hat_1 = prefix.."ui/beauty/global_ranking_gold_img01.png"
M.beauty_rank_hat_2 = prefix.."ui/beauty/global_ranking_silver_img01.png"
M.beauty_rank_hat_3 = prefix.."ui/beauty/global_ranking_copper_img01.png"
M.beauty_rank_hat_4 = prefix.."ui/beauty/global_is_sex_img.png"
M.beauty_rank_bg = prefix.."ui/beauty/global_ranking_mvbk01.png"
M.beauty_normal_bg = "zjh_circle.png"

M.menu_back = "zjh_quit.png"
M.menu_change = "zjh_change.png"
M.menu_standup = "zjh_change(up).png"
M.menu_detail = "zjh_pai_xing01.png"
M.menu_rule = prefix.."ui/zjh_game/rule.png"

M.chat_emojiImg = prefix.."ui/chat/lookon/emoji.png"
M.chat_emoji1Img = prefix.."ui/chat/lookon/emoji1.png"
M.chat_chatImg = prefix.."ui/chat/lookon/chat.png"
M.chat_chat1Img = prefix.."ui/chat/lookon/chat1.png"
M.chat_historyImg = prefix.."ui/chat/lookon/history.png"
M.chat_history1Img = prefix.."ui/chat/lookon/history1.png"
M.chat_othersImg = prefix.."ui/chat/lookon/others.png"
M.chat_others1Img = prefix.."ui/chat/lookon/others1.png"
M.chatPointImg = prefix.."ui/chat/lookon/tips.png"
--送礼引导
M.slLeadView = prefix.."ui/ZJH_SLLead.json"
M.slLeadViewPlist = prefix.."ui/NewsLead/zjh_giftLead.plist"
M.slLeadViewPng = prefix.."ui/NewsLead/zjh_giftLead.png"
M.sl_tipsAni1 = "zjh_sllead3.png"
M.sl_tipsAni2 = "zjh_sllead4.png"
M.sl_mineAni1 = "zjh_sllead5.png"
M.sl_mineAni2 = "zjh_sllead6.png"

M.menu_change_desk			=prefix.."ui/zjh_game/newGameRes/changeDesk.png"  
M.menu_wanfa				=prefix.."ui/zjh_game/newGameRes/wanfa.png" 
M.menu_paixing			=prefix.."ui/zjh_game/newGameRes/paixingBtn.png" 
M.menu_newback				=prefix.."ui/zjh_game/newGameRes/backGame.png" 
M.menu_newstandup				=prefix.."ui/zjh_game/newGameRes/standup.png" 
M.menu_newbank				=prefix.."ui/zjh_game/newGameRes/btnBank.png" 
M.menu_guang 				=prefix.."ui/zjh_game/newGameRes/menuBgGuang.png"
M.chipFnt_1 = prefix.."ui/zjh_game/zjhChip/green.fnt"
M.chipFnt_2 = prefix.."ui/zjh_game/zjhChip/cblue.fnt"
M.chipFnt_3 = prefix.."ui/zjh_game/zjhChip/zblue.fnt"
M.chipFnt_4 = prefix.."ui/zjh_game/zjhChip/violet.fnt"
M.chipFnt_5 = prefix.."ui/zjh_game/zjhChip/fred.fnt"
Zjh_Games_res = {}
Zjh_Games_res = M