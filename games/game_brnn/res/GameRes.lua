local M = {}

local prefix = "game_brnn/"

M.br_addNewBetBtnImg = prefix .. "ui/brgame/img_chip_x%d.png"

M.br_bet_time_tips_img = prefix .. "ui/brgame/br_bet_time_%d.png"

--选场大厅
M.brGameJson = prefix .. "ui/brGame.json"--百人场界面
M.brGame3Json = prefix .. "ui/brGame_3.json"--3倍场百人场界面
M.brPersonJson = prefix .. "ui/brPerson.json"--百人场旁观界面
M.brHistoryJson = prefix .. "ui/brHistory.json"--百人场历史记录
M.brDelarListJson = prefix .. "ui/delarList.json"--百人场上庄列表
M.brHelpJson = prefix .. "ui/explanation.json"--百人场上庄列表

M.br_add_btn_round = prefix .. "ui/brgame/chips/chips_mask.png"
M.br_win_word = prefix .. "ui/brgame/history/br_win_word.png"
M.br_loser_word = prefix .. "ui/brgame/history/br_loser_word.png"

M.trend_win = prefix .. "ui/brgame/trend_win.png"
M.trend_lose = prefix .. "ui/brgame/trend_lose.png"
M.trend_win_mask = prefix .. "ui/brgame/trend_win_mask.png"
M.trend_lose_mask = prefix .. "ui/brgame/trend_lose_mask.png"

M.br_game_state_txt_1 = prefix .. "ui/brgame/txt_rest_time.png"
M.br_game_state_txt_2 = prefix .. "ui/brgame/txt_bet_time.png"
M.br_game_card_type = "niuniu_%d_%d.png" --百人牛牛输赢
M.br_game_card_type_10 = "niuniu_%d_%d_10.png" --百人牛牛输赢
M.br_game_card_type_bg = "niuniu_result_bg_%d.png" --百人牛牛输赢
M.br_game_win_multi = prefix .. "ui/brgame/win_or_lose/txt_win_%d.png" -- 赢
M.br_game_lose_multi = prefix .. "ui/brgame/win_or_lose/txt_lose_%d.png" -- 输
M.br_game_no_mulit = prefix .. "ui/brgame/win_or_lose/txt_no_bet.png" -- 没有下注
M.br_default_head_icon = prefix .. "ui/brgame/img_br_head.png" -- 百人场默认头像
M.br_game_vip_bg = prefix .. "ui/brgame/img_br_head_vip_bg.png" -- VIP头像背景
M.br_game_common_bg = prefix .. "ui/brgame/img_br_head_bg.png" -- 普通头像背景

M.br_game_btn_not_want_be_delar = prefix .. "ui/brgame/btn_br_down.png"  -- 我要下庄
M.br_game_btn_want_be_delar = prefix .. "ui/brgame/btn_br_up.png"  --我要上庄
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

M.gamemenu_common_bg = prefix .. "ui/playgame/game_menu/menu_bg_common.png"
M.gamemenu_item_normal = prefix .. "ui/playgame/game_menu/game_menu_bt%02d_n.png"
M.gamemenu_item_press = prefix .. "ui/playgame/game_menu/game_menu_bt%02d_p.png"
M.gamemenu_record_new_flag = prefix .. "ui/playgame/game_menu/new_point.png"


M.all_music ={ 
    START_BET = prefix .. "music/start.mp3",
    STOP_BET = prefix .. "music/stop_bet.mp3",
    WIN_MONEY = prefix .. "music/win_mony.mp3",

    NIU_1_0     = prefix.."music/OX_NO_FEMALE_SOUND.mp3",
    NIU_1_1     = prefix.."music/OX_1_FEMALE_SOUND.mp3",
    NIU_1_2     = prefix.."music/OX_2_FEMALE_SOUND.mp3",
    NIU_1_3     = prefix.."music/OX_3_FEMALE_SOUND.mp3",
    NIU_1_4     = prefix.."music/OX_4_FEMALE_SOUND.mp3",
    NIU_1_5     = prefix.."music/OX_5_FEMALE_SOUND.mp3",
    NIU_1_6     = prefix.."music/OX_6_FEMALE_SOUND.mp3",
    NIU_1_7     = prefix.."music/OX_7_FEMALE_SOUND.mp3",
    NIU_1_8     = prefix.."music/OX_8_FEMALE_SOUND.mp3",
    NIU_1_9     = prefix.."music/OX_9_FEMALE_SOUND.mp3",
    NIU_1_10     = prefix.."music/OX_10_FEMALE_SOUND.mp3",
    NIU_1_15     = prefix.."music/OX_BOMB_FEMALE_SOUND.mp3",
    NIU_1_17     = prefix.."music/OX_SUPEROX_FEMALE_SOUND.mp3",
    NIU_1_18     = prefix.."music/OX_5_LITTLE_OX_MALE_SOUND.mp3",
}

M.br_result_snow1 = prefix .. "ui/brgame/br_result_snow1.png"
M.br_result_snow2 = prefix .. "ui/brgame/br_result_snow2.png" 
M.br_result_start = prefix .. "ui/brgame/br_result_start.png"

M.bei_fnt = prefix .. "ui/brgame/font/beiTxt.fnt"
M.bei_fnt_img = prefix .. "ui/brgame/font/beiTxt.png"

M.lose_num_fnt = prefix .. "ui/brgame/font/lose_num.fnt"
M.lose_num_fnt_img = prefix .. "ui/brgame/font/lose_num.png"

-------------  牌相关  start  ----------------
M.poker_textrue_plist = prefix .. "card/br_card.plist"
M.poker_textrue = prefix .. "card/br_card.png"
M.poker_bg = "poker_bg.png"
M.poker_back = "poker_back_bg.png"
M.poker_anim = "fanpai0%d.png"

M.poker_point = "poker_%d_%d.png"
M.poker_color_large = "poker_color_%d_large.png"
M.poker_color_small = "poker_color_%d_small.png"
M.poker_color_special = "poker_color_%d_%d.png"
-------------  牌相关  end  ----------------

-- 爆庄
M.ALLFIRE         = prefix.."game/animation/all_fire/all_fire.ExportJson"
M.BAO         = prefix.."game/animation/baoDelar/NewAnimation.ExportJson"

M.br_add_layer         = prefix.."ui/brgame/br_add_layer_%d.png"

M.br_game_status_animation = prefix .. "game/animation/game_status_ani/NewAnimation0312geshazhuang.ExportJson"



M.WINMONEY = prefix.."game/animation/winmoney/other/winmoney.ExportJson"
M.WINMONEY_PLIST = prefix.."game/animation/winmoney/other/winmoney.plist"

M.WINMONEY_MY = prefix.."game/animation/winmoney/myself/winmoneymyself.ExportJson"
M.WINMONEY_MY_PLIST = prefix.."game/animation/winmoney/myself/winmoneymyself.plist"

M.table_bg_img = prefix .. "ui/brgame/img_br_bg_%d.png"
M.table_blue_bg_img = prefix .. "ui/brgame/img_br_bg_1.jpg"
M.table_pool_bg_img = prefix .. "ui/brgame/chips_pool_%d_%d.png"

BrniuniuRes = {}
BrniuniuRes = M