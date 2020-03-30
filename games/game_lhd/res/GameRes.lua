local M = {}

local prefix = "game_lhd/"

M.brGameJson = prefix.."ui/brGame.json"--  游戏内界面json文件
--------------龙虎斗---------------
M.lhd_chip_panel_frame_big = "lhd_chip_panel_frame_big.png"
M.lhd_chip_panel_frame_small = "lhd_chip_panel_frame_small.png"
M.lhd_desk_bg = prefix.."ui/lhdgame/lhd_desk_bg.jpg"
M.lhd_game_plist = prefix.."ui/lhdgame/lhdgame.plist"
M.lhd_game_png = prefix.."ui/lhdgame/lhdgame.png"
M.lhd_game_win_num = prefix.."ui/lhdgame/lhd_win_num.fnt"   --龙虎斗赢金币数字
M.lhd_game_lose_num = prefix.."ui/lhdgame/lhd_lose_num.fnt" --龙虎斗输金币数字
M.lhdgame_win_long = "lhd_win_long.png"
M.lhdgame_win_hu   = "lhd_win_hu.png"
M.lhdgame_win_he   = "lhd_win_he.png"
M.lhd_delar_btn = "lhd_delar_btn.png"
M.lhd_up_delar_txt = "lhd_up_delar_txt.png"
M.lhd_down_delar_txt = "lhd_down_delar_txt.png"
M.lhd_head_bg = "img_lhd_head_bg.png"
M.lhdgame_game_cover = "lhd_game_cover.png"
M.lhdgame_win_txt_bg = "lhd_win_txt_bg.png"
M.lhdgame_result_win_bg = "lhd_result_win_bg.png"
M.lhdgame_result_lose_bg = "lhd_result_lose_bg.png"
M.lhdgame_lhd_card_frame = "lhd_card_frame.png"
M.lhdgame_history_ball_1 = "circle_1.png"
M.lhdgame_history_ball_2 = "circle_2.png"
M.lhdgame_history_ball_3 = "circle_3.png"
M.lhd_history_tab_1 = "lhd_history_tab_1.png"
M.lhd_history_tab_2 = "lhd_history_tab_2.png"
M.lhd_history_tab_3 = "lhd_history_tab_3.png"
M.lhd_history_tab_1_0 = "lhd_history_tab_1_0.png"
M.lhd_history_tab_2_0 = "lhd_history_tab_2_0.png"
M.lhd_history_tab_3_0 = "lhd_history_tab_3_0.png"
M.lhdgame_history_nobet = "lhd_history_shuying_line2.png"
M.lhdcard_card_back = "poker_card_back.png"
M.br_add_btn_round = prefix .. "ui/brgame/br_btn_round.png"

--龙虎斗按钮动画
M.lhdbtn_lhd_hu_1 = "lhd_hu_1.png"
M.lhdbtn_lhd_hu_2 = "lhd_hu_2.png"
M.lhdbtn_lhd_hu_3 = "lhd_hu_3.png"
M.lhdbtn_lhd_hu_4 = "lhd_hu_4.png"
M.lhdbtn_lhd_hu_5 = "lhd_hu_5.png"
M.lhdbtn_lhd_hu_6 = "lhd_hu_6.png"
M.lhdbtn_lhd_hu_7 = "lhd_hu_7.png"
M.lhdbtn_lhd_hu_8 = "lhd_hu_8.png"
M.lhdbtn_lhd_hu_9 = "lhd_hu_9.png"
M.lhdbtn_lhd_hu_10 = "lhd_hu_10.png"
M.lhdbtn_lhd_hu_11 = "lhd_hu_11.png"

M.lhdbtn_lhd_long_1 = "lhd_long_1.png"
M.lhdbtn_lhd_long_2 = "lhd_long_2.png"
M.lhdbtn_lhd_long_3 = "lhd_long_3.png"
M.lhdbtn_lhd_long_4 = "lhd_long_4.png"
M.lhdbtn_lhd_long_5 = "lhd_long_5.png"
M.lhdbtn_lhd_long_6 = "lhd_long_6.png"
M.lhdbtn_lhd_long_7 = "lhd_long_7.png"
M.lhdbtn_lhd_long_8 = "lhd_long_8.png"
M.lhdbtn_lhd_long_9 = "lhd_long_9.png"
M.lhdbtn_lhd_long_10 = "lhd_long_10.png"
M.lhdbtn_lhd_long_11 = "lhd_long_11.png"

M.br_game_state_txt_1 = "rest_time_txt.png"
M.br_game_state_txt_2 = "bet_time_txt.png"
M.br_game_state_txt_3 = "stop_bet_txt.png"
M.br_game_state_txt_4 = "cut_off_time.png"
M.br_game_state_txt_5 = "last_calculate_time_txt.png"

M.lhd_bet_time_img = "lhd_bet_time_%d.png"

M.font1 = "Arial"

M.br_add_btn_round = prefix.."ui/brgame/br_btn_round.png"
M.brchips_1 = "img_chip_1.png" -- 50
M.brchips_2 = "img_chip_2.png" -- 100
M.brchips_3 = "img_chip_3.png" -- 1000
M.brchips_4 = "img_chip_4.png" -- 10000
M.brchips_5 = "img_chip_5.png" -- 100000
M.brchips_6 = "img_chip_6.png" -- 1000000
M.brchips_7 = "img_chip_7.png" -- 10000000
M.game_chip_num = prefix.."chip/game_chip_num.png"
M.game_chip_wan = prefix.."chip/game_chip_wan.png"
M.effctLabaJson = prefix.."ui/effectLaba.json" --龙虎斗结算界面喇叭动画效果
M.lhdGameEndJson = prefix.."ui/lhdGameEnd.json" --龙虎斗结算界面
M.lhdHistoryJson = prefix.."ui/lhdHistory.json" --龙虎斗路单
M.lhdPersonJson = prefix.."ui/brPerson.json" --龙虎斗站起人
M.lhdDelarListJson= prefix.."ui/delarList.json" --龙虎斗庄家列表
M.br_game_chips_png = prefix.."ui/brgame/brchips.png"
M.br_game_chips_plist = prefix.."ui/brgame/brchips.plist"

M.br_help_exp1 = prefix.."ui/brgame/br_help_exp1_selected.png"
M.br_help_exp2 = prefix.."ui/brgame/br_help_exp2_selected.png"
M.btn_tabs_1_left_nor = prefix.."ui/global/btn_tabs_1_left_nor.png"
M.btn_tabs_1_left_dis = prefix.."ui/global/btn_tabs_1_left_dis.png"
M.btn_tabs_1_center_nor = prefix.."ui/global/btn_tabs_1_center_nor.png"
M.btn_tabs_1_center_dis = prefix.."ui/global/btn_tabs_1_center_dis.png"
M.btn_tabs_2_left_nor = prefix.."ui/global/btn_tabs_2_left_nor.png"
M.btn_tabs_2_left_dis = prefix.."ui/global/btn_tabs_2_left_dis.png"
M.btn_tabs_2_center_nor = prefix.."ui/global/btn_tabs_2_center_nor.png"
M.btn_tabs_2_center_dis = prefix.."ui/global/btn_tabs_2_center_dis.png"
M.btn_tabs_3_left_nor = prefix.."ui/global/btn_tabs_3_left_nor.png"
M.btn_tabs_3_left_dis = prefix.."ui/global/btn_tabs_3_left_dis.png"
M.btn_tabs_4_left_nor = prefix.."ui/global/btn_tabs_4_left_nor.png"
M.btn_tabs_4_left_dis = prefix.."ui/global/btn_tabs_4_left_dis.png"
M.btn_tabs_4_center_nor = prefix.."ui/global/btn_tabs_4_center_nor.png"
M.btn_tabs_4_center_dis = prefix.."ui/global/btn_tabs_4_center_dis.png"


M.all_music ={
    START_BET = prefix .. "sound/start.mp3",
    STOP_BET = prefix .. "sound/stop_bet.mp3",
    FANPAI = prefix .. "sound/fanpai.mp3",
    FAPAI = prefix .. "sound/fapai.mp3",
}

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

M.trend_img_name = "trend_win_flag_%d.png"

M.noloseScoreFont = prefix.."ui/lhdgame/lhdgame_PList.Dir/font_nolose.png"
M.loseScoreFont = prefix.."ui/lhdgame/lhdgame_PList.Dir/font_lose.png"
M.winScoreFont = prefix.."ui/lhdgame/lhdgame_PList.Dir/font_win.png"

M.time_count_font_0 = prefix .. "ui/font/time_count_font_0.fnt"
M.time_count_font_1 = prefix .. "ui/font/time_count_font_1.fnt"

M.delar_off = prefix.."ui/brgame/window/gotoDelarOff.png"
M.delar_on = prefix.."ui/brgame/window/gotoDelarOn.png"

M.result_animation = prefix.."armature_anim/lhd_show_result/NewAnimation0410lhd01.ExportJson"
M.result_pk_animation = prefix.."armature_anim/lhd_pk/NewAnimation20190429juedou.ExportJson"
M.result_chipspool_animation = prefix.."armature_anim/lhd_chipspool/NewAnimation20190429win.ExportJson"
M.result_selfwin_animation = prefix.."armature_anim/lhd_self_win/NewAnimation20190509zjiwin.ExportJson"

M.br_game_btn_not_want_be_delar = prefix .. "ui/brgame/btn_br_down.png"  -- 我要下庄
M.br_game_btn_want_be_delar = prefix .. "ui/brgame/btn_br_up.png"  --我要上庄

M.poker_anim = prefix .. "card/animation/fanpai0%d.png"

LHD_Games_res = {}
LHD_Games_res = M