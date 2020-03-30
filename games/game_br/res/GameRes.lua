local M = {}

local prefix = "game_br/"

M.chatViewJson = prefix .."ui/chat.json"
M.chat_emoji_img1 = prefix.."ui/chat/brchat_emoji.png"
M.chat_emoji_img2 = prefix.."ui/chat/brchat_emoji1.png"
M.chat_history_img1 = prefix.."ui/chat/br_chat_history.png"
M.chat_history_img2 = prefix.."ui/chat/br_chat_history1.png"
--下注按钮
--M.br_addBetBtnImg = prefix.."ui/brgame/chips/add_chips_%d.png"

M.br_addNewBetBtnImg = prefix .. "ui/brgame/img_chip_x%d.png"

M.br_bet_time_tips_img = prefix .. "ui/brgame/br_bet_time_%d.png"

--选场大厅
M.brGameJson = prefix .. "ui/brGame.json"--百人场界面
M.brPersonJson = prefix .. "ui/brPerson.json"--百人场旁观界面
M.brHistoryJson = prefix .. "ui/brHistory.json"--百人场历史记录
M.brDelarListJson = prefix .. "ui/delarList.json"--百人场上庄列表
M.brHelpJson = prefix .. "ui/explanation.json"--百人场上庄列表
M.brResultJson = prefix .. "ui/brGameResult.json"--百人场结算界面

M.br_add_btn_round = prefix .. "ui/brgame/chips/chips_mask.png"
M.br_win_word = prefix .. "ui/brgame/history/br_win_word.png"
M.br_loser_word = prefix .. "ui/brgame/history/br_loser_word.png"

M.trend_win = prefix .. "ui/brgame/trend_win.png"
M.trend_lose = prefix .. "ui/brgame/trend_lose.png"
M.trend_win_mask = prefix .. "ui/brgame/trend_win_mask.png"
M.trend_lose_mask = prefix .. "ui/brgame/trend_lose_mask.png"

M.br_game_state_txt_1 = prefix .. "ui/brgame/txt_rest_time.png"
M.br_game_state_txt_2 = prefix .. "ui/brgame/txt_bet_time.png"
M.br_game_card_type_2 = prefix .. "ui/brgame/card_type/txt_card_type_1_%d.png" -- 赢
M.br_game_card_type_1 = prefix .. "ui/brgame/card_type/txt_card_type_2_%d.png" -- 输
M.br_game_win_multi = prefix .. "ui/brgame/win_or_lose/txt_win_%d.png" -- 赢
M.br_game_lose_multi = prefix .. "ui/brgame/win_or_lose/txt_lose_%d.png" -- 输
M.br_game_no_mulit = prefix .. "ui/brgame/win_or_lose/txt_no_bet.png" -- 没有下注
M.br_default_head_icon = prefix .. "ui/brgame/img_br_head.png" -- 百人场默认头像
M.br_game_vip_bg = prefix .. "ui/brgame/img_br_head_vip_bg.png" -- VIP头像背景
M.br_game_common_bg = prefix .. "ui/brgame/img_br_head_bg.png" -- 普通头像背景

M.br_game_chip_s_1 = prefix .. "ui/brgame/img_chip_1.png" -- 100
M.br_game_chip_s_2 = prefix .. "ui/brgame/img_chip_2.png" -- 1000
M.br_game_chip_s_3 = prefix .. "ui/brgame/img_chip_3.png" -- 10000
M.br_game_chip_s_4 = prefix .. "ui/brgame/img_chip_4.png" -- 100000
M.br_game_chip_s_5 = prefix .. "ui/brgame/img_chip_5.png" -- 1000000

M.br_game_chip_sx_1 = prefix .. "ui/brgame/img_chip_x1.png" -- 1
M.br_game_chip_sx_2 = prefix .. "ui/brgame/img_chip_x2.png" -- 10
M.br_game_chip_sx_3 = prefix .. "ui/brgame/img_chip_x3.png" -- 50
M.br_game_chip_sx_4 = prefix .. "ui/brgame/img_chip_x4.png" -- 100
M.br_game_chip_sx_5 = prefix .. "ui/brgame/img_chip_x5.png" -- 500
M.br_game_chip_sx_6 = prefix .. "ui/brgame/img_chip_x6.png" -- 1000
M.br_game_chip_sx_7 = prefix .. "ui/brgame/img_chip_x7.png" -- 5000

M.br_result_user_bg1 = prefix .. "ui/brgame/result/img_br_ret_win_bg.png" -- 赢
M.br_result_user_bg2 = prefix .. "ui/brgame/result/img_br_ret_lose_bg.png" -- 输
M.br_result_btn_back1 = prefix .. "ui/brgame/result/btn_ret_win_back.png" -- 赢
M.br_result_btn_back2 = prefix .. "ui/brgame/result/btn_ret_lose_back.png" -- 输
M.br_result_title1 = prefix .. "ui/brgame/result/img_br_ret_title_win.png" -- 赢
M.br_result_title2 = prefix .. "ui/brgame/result/img_br_ret_title_lose.png" -- 输
M.br_result_type_1_1 = prefix .. "ui/brgame/result/img_ret_win_1.png" -- 赢
M.br_result_type_1_2 = prefix .. "ui/brgame/result/img_ret_lose_1.png" -- 输
M.br_result_type_2_1 = prefix .. "ui/brgame/result/img_ret_win_2.png" -- 赢
M.br_result_type_2_2 = prefix .. "ui/brgame/result/img_ret_lose_2.png" -- 输
M.br_result_type_3_1 = prefix .. "ui/brgame/result/img_ret_win_3.png" -- 赢
M.br_result_type_3_2 = prefix .. "ui/brgame/result/img_ret_lose_3.png" -- 输
M.br_result_type_4_1 = prefix .. "ui/brgame/result/img_ret_win_4.png" -- 赢
M.br_result_type_4_2 = prefix .. "ui/brgame/result/img_ret_lose_4.png" -- 输
M.br_result_star_1 = prefix .. "ui/brgame/result/img_ret_win_star.png" -- 赢
M.br_result_star_2 = prefix .. "ui/brgame/result/img_ret_lose_star.png" -- 输
M.br_result_light_1 = prefix .. "ui/brgame/result/img_ret_win_light.png" -- 赢
M.br_result_light_2 = prefix .. "ui/brgame/result/img_ret_lose_light.png" -- 输
M.br_result_bug_right_1 = prefix .. "ui/brgame/result/img_ret_win_right_bug.png" -- 赢
M.br_result_bug_left_1 = prefix .. "ui/brgame/result/img_ret_win_left_bug.png" -- 赢
M.br_result_bug_right_2 = prefix .. "ui/brgame/result/img_ret_lose_right_bug.png" -- 输
M.br_result_bug_left_2 = prefix .. "ui/brgame/result/img_ret_lose_left_bug.png" -- 输
M.br_result_num_1 = prefix .. "ui/brgame/result/br_ret_num_win.png" -- 赢
M.br_result_num_2 = prefix .. "ui/brgame/result/br_ret_num_lose.png" -- 输
M.br_result_gold_1 = prefix .. "ui/brgame/result/img_ret_win_gold.png" -- 赢
M.br_result_gold_2 = prefix .. "ui/brgame/result/img_ret_lose_gold.png" -- 输
M.br_game_btn_not_want_be_delar = prefix .. "ui/brgame/btn_br_down.png"  -- 我要下庄
M.br_game_btn_want_be_delar = prefix .. "ui/brgame/btn_br_up.png"  --我要上庄
M.br_game_btn_br_up = prefix .. "ui/brgame/btn_br_up.png"
M.br_game_card_color = prefix .. "ui/brgame/br_add_btn_%d_%d.png"
M.br_game_turn_left_2 = prefix .. "ui/brgame/img_turn_card_left.png" -- 赢
M.br_game_turn_right_2 = prefix .. "ui/brgame/img_turn_card_right.png" -- 输
M.br_game_turn_left_1 = prefix .. "ui/brgame/img_turn_card_left2.png" -- 赢
M.br_game_turn_right_1 = prefix .. "ui/brgame/img_turn_card_right2.png" -- 输

--SNG 和 MTT

M.res008 = prefix .. "ui/playgame/game_all_in_font.png"
M.res009 = prefix .. "ui/playgame/game_auto_give_away_font.png"
M.res010 = prefix .. "ui/playgame/game_big_fllow_font.png"
M.res011 = prefix .. "ui/playgame/game_buttom_pool_font00.png"
M.res012 = prefix .. "ui/playgame/game_buttom_pool_font01.png"
M.res013 = prefix .. "ui/playgame/game_buttom_pool_font02.png"
M.res014 = prefix .. "ui/playgame/game_fllow_any_font.png"
M.res015 = prefix .. "ui/playgame/game_fllow_more_font.png"
M.res016 = prefix .. "ui/playgame/game_four_mutil_blind_font.png"
M.res017 = prefix .. "ui/playgame/game_give_away_discard_font.png"
M.res018 = prefix .. "ui/playgame/game_giveup_font.png"
M.res019 = prefix .. "ui/playgame/game_look_cards_font.png"
M.res020 = prefix .. "ui/playgame/game_num_font.png"
M.res021 = prefix .. "ui/playgame/game_num_unit1.png"
M.res022 = prefix .. "ui/playgame/game_three_mutil_blind_font.png"

M.res023 = prefix .. "ui/playgame/game_small_fllow_font.png"
M.res024 = prefix .. "ui/playgame/game_num_unit2.png"

--筹码信息
M.chips_bg = prefix .. "ui/brgame/chips/add_chips_%s_1.png"

M.stt_tip_bg = prefix .. "ui/stt/tip_bg.png"
M.stt_icon_microphone = prefix .. "ui/stt/icon_microphone.png"
M.stt_icon_tip = prefix .. "ui/stt/icon_tip.png"
M.stt_lbl_max_time = prefix .. "ui/stt/lbl_max_time.png"
M.stt_lbl_too_short = prefix .. "ui/stt/lbl_too_short.png"
M.stt_numbers = prefix .. "ui/stt/numbers.png"

M.stt_volume_level = prefix .. "ui/stt/volume_%d.png"
M.stt_converting_dot = prefix .. "ui/stt/chat/chat_tip_dot.png"

M.gamemenu_common_bg = prefix .. "ui/playgame/game_menu/menu_bg_common.png"
M.gamemenu_item_normal = prefix .. "ui/playgame/game_menu/game_menu_bt%02d_n.png"
M.gamemenu_item_press = prefix .. "ui/playgame/game_menu/game_menu_bt%02d_p.png"
M.gamemenu_record_new_flag = prefix .. "ui/playgame/game_menu/new_point.png"


M.all_music ={ 
    CHAT_0_1 = prefix .. "music/m_chat1.mp3", 
    CHAT_0_2 = prefix .. "music/m_chat2.mp3", 
    CHAT_0_3 = prefix .. "music/m_chat3.mp3", 
    CHAT_0_4 = prefix .. "music/m_chat4.mp3", 
    CHAT_0_5 = prefix .. "music/m_chat5.mp3", 
    CHAT_0_6 = prefix .. "music/m_chat6.mp3", 
    CHAT_0_7 = prefix .. "music/m_chat7.mp3", 
    CHAT_0_8 = prefix .. "music/m_chat8.mp3", 
    CHAT_0_9 = prefix .. "music/m_chat9.mp3", 
    CHAT_0_10 = prefix .. "music/m_chat10.mp3", 
    CHAT_0_11 = prefix .. "music/m_chat11.mp3", 
    CHAT_0_12 = prefix .. "music/m_chat12.mp3", 
    CHAT_1_1 = prefix .. "music/f_chat1.mp3", 
    CHAT_1_2 = prefix .. "music/f_chat2.mp3", 
    CHAT_1_3 = prefix .. "music/f_chat3.mp3", 
    CHAT_1_4 = prefix .. "music/f_chat4.mp3", 
    CHAT_1_5 = prefix .. "music/f_chat5.mp3", 
    CHAT_1_6 = prefix .. "music/f_chat6.mp3", 
    CHAT_1_7 = prefix .. "music/f_chat7.mp3", 
    CHAT_1_8 = prefix .. "music/f_chat8.mp3", 
    CHAT_1_9 = prefix .. "music/f_chat9.mp3", 
    CHAT_1_10 = prefix .. "music/f_chat10.mp3", 
    CHAT_1_11 = prefix .. "music/f_chat11.mp3", 
    CHAT_1_12 = prefix .. "music/f_chat12.mp3",
    START_BET = prefix .. "music/start.mp3",
    STOP_BET = prefix .. "music/stop_bet.mp3",
    WIN_MONEY = prefix .. "music/win_mony.mp3"
}
M.chat_noble_allin = prefix .. "other/chatAni/NewAnimation2.ExportJson"--
M.chat_noble_help = prefix .. "other/chatAni/NewAnimation5.ExportJson"--
M.chat_noble_hi = prefix .. "other/chatAni/NewAnimation6.ExportJson"--
M.chat_noble_feck = prefix .. "other/chatAni/NewAnimation4.ExportJson"--
M.chat_noble_check = prefix .. "other/chatAni/NewAnimation7.ExportJson"--
M.chat_noble_aa = prefix .. "other/chatAni/NewAnimation.ExportJson"--
M.chat_noble_omg = prefix .. "other/chatAni/NewAnimationHJH.ExportJson"--
M.chat_noble_you = prefix .. "other/chatAni/NewAnimation10.ExportJson"--
M.chat_noble_no = prefix .. "other/chatAni/NewAnimation9.ExportJson"--
M.chat_noble_ha = prefix .. "other/chatAni/NewAnimation3.ExportJson"--
M.chat_noble_allin_plist = prefix .. "other/chatAni/NewAnimation20.plist"--
M.chat_noble_allin_png = prefix .. "other/chatAni/NewAnimation20.png"--

M.chat_noble_help_plist = prefix .. "other/chatAni/NewAnimation50.plist"--
M.chat_noble_help_png = prefix .. "other/chatAni/NewAnimation50.png"--

M.chat_noble_hi_plist = prefix .. "other/chatAni/NewAnimation60.plist"--
M.chat_noble_hi_png = prefix .. "other/chatAni/NewAnimation60.png"--

M.chat_noble_feck_plist = prefix .. "other/chatAni/NewAnimation40.plist"--
M.chat_noble_feck_png = prefix .. "other/chatAni/NewAnimation40.png"--

M.chat_noble_check_plist = prefix .. "other/chatAni/NewAnimation70.plist"--
M.chat_noble_check_png = prefix .. "other/chatAni/NewAnimation70.png"--

M.chat_noble_aa_plist = prefix .. "other/chatAni/NewAnimation0.plist"--
M.chat_noble_aa_png = prefix .. "other/chatAni/NewAnimation0.png"--

M.chat_noble_omg_plist = prefix .. "other/chatAni/NewAnimationHJH0.plist"--
M.chat_noble_omg_png = prefix .. "other/chatAni/NewAnimationHJH0.png"--
M.chat_noble_omg_plist_1 = prefix .. "other/chatAni/NewAnimationHJH1.plist"--
M.chat_noble_omg_png_1 = prefix .. "other/chatAni/NewAnimationHJH1.png"--

M.chat_noble_you_plist = prefix .. "other/chatAni/NewAnimation100.plist"--
M.chat_noble_you_png = prefix .. "other/chatAni/NewAnimation100.png"--

M.chat_noble_no_plist = prefix .. "other/chatAni/NewAnimation90.plist"--
M.chat_noble_no_png = prefix .. "other/chatAni/NewAnimation90.png"--

M.chat_noble_ha_plist = prefix .. "other/chatAni/NewAnimation30.plist"--
M.chat_noble_ha_png = prefix .. "other/chatAni/NewAnimation30.png"--

M.br_result_snow1 = prefix .. "ui/brgame/br_result_snow1.png"
M.br_result_snow2 = prefix .. "ui/brgame/br_result_snow2.png" 
M.br_result_start = prefix .. "ui/brgame/br_result_start.png"

M.bei_fnt = prefix .. "ui/brgame/font/beiTxt.fnt"
M.bei_fnt_img = prefix .. "ui/brgame/font/beiTxt.png"

M.lose_num_fnt = prefix .. "ui/brgame/font/lose_num.fnt"
M.lose_num_fnt_img = prefix .. "ui/brgame/font/lose_num.png"

M.poker_bg = prefix .. "card/poker_bg.png"
M.poker_back = prefix .. "card/poker_back_bg.png"
M.poker_anim = prefix .. "card/animation/fanpai0%d.png"

M.poker_point = prefix .. "card/poker_%d_%d.png"
M.poker_color_large = prefix .. "card/poker_color_%d_large.png"
M.poker_color_small = prefix .. "card/poker_color_%d_small.png"
M.poker_color_special = prefix .. "card/poker_color_%d_%d.png"

M.br_result_head_1 = prefix .. "ui/brgame/result/br_result_win_head.png"
M.br_result_head_2 = prefix .. "ui/brgame/result/br_result_lose_head.png"
M.br_result_1 = prefix .. "ui/brgame/result/br_result_win.png"
M.br_result_2 = prefix .. "ui/brgame/result/br_result_lose.png"
M.br_result_special_tp = prefix .. "ui/brgame/result/br_result_tp.png"
M.br_result_special_ts = prefix .. "ui/brgame/result/br_result_ts.png"
M.br_result_line_1 = prefix .. "ui/brgame/result/br_result_line_gold.png"
M.br_result_line_2 = prefix .. "ui/brgame/result/br_result_line_sliver.png"

M.br_game_result_ts = prefix .. "game/animation/result_ts/NewAnimation.ExportJson"
M.br_game_result_tp = prefix .. "game/animation/result_tp/NewAnimation.ExportJson"

-- 爆庄
M.ALLFIRE         = prefix.."game/animation/all_fire/all_fire.ExportJson"
M.BAO         = prefix.."game/animation/baoDelar/NewAnimation.ExportJson"

M.br_add_layer         = prefix.."ui/brgame/br_add_layer_%d.png"

M.noloseScoreFont = prefix.."ui/brgame/result/font_nolose.png"
M.loseScoreFont = prefix.."ui/brgame/result/font_lose.png"
M.winScoreFont = prefix.."ui/brgame/result/font_win.png"

M.br_new_result_special_tp = prefix .. "ui/brgame/result/img_tongpei.png"
M.br_new_result_special_ts = prefix .. "ui/brgame/result/img_tongsha.png"
M.br_new_result_head_1 = prefix .. "ui/brgame/result/img_winBg.png"
M.br_new_result_head_2 = prefix .. "ui/brgame/result/img_loseBg.png"

M.br_game_status_animation = prefix .. "game/animation/game_status_ani/NewAnimation0312geshazhuang.ExportJson"



M.WINMONEY = prefix.."game/animation/winmoney/other/winmoney.ExportJson"
M.WINMONEY_PLIST = prefix.."game/animation/winmoney/other/winmoney.plist"

M.WINMONEY_MY = prefix.."game/animation/winmoney/myself/winmoneymyself.ExportJson"
M.WINMONEY_MY_PLIST = prefix.."game/animation/winmoney/myself/winmoneymyself.plist"


BrRes = {}
BrRes = M