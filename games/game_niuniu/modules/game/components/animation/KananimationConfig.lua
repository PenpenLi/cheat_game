M = {}
M = {
	START = {
		name='StartGO',
		res = Niuniu_Games_res.Kan_start,
		list={Niuniu_Games_res.Kan_start_list_0,Niuniu_Games_res.Kan_start_list_1,Niuniu_Games_res.Kan_start_list_2},
		preload =1
	},
	KUANG_HENG = {
		name='Rob_zhuang_heng01',
		res = Niuniu_Games_res.Zhuang_heng,
		list={Niuniu_Games_res.Zhuang_heng_list},
		preload =1
	},
	KUANG_SHU = {
		name='Rob_zhuang_shu01',
		res = Niuniu_Games_res.Zhuang_shu,
		list={Niuniu_Games_res.Zhuang_shu_list},
		preload =1
	},
	WIN = {
		name='win_money03',
		res = Niuniu_Games_res.Kan_win,
		list={Niuniu_Games_res.Kan_win_list_0},
		preload =3
	},
	LOST = {
		name='win_money00',
		res = Niuniu_Games_res.Kan_lost,
		list={Niuniu_Games_res.Kan_lost_list_0},
		preload =3
	},
	CHU = {
		name='kaipai',
		res = Niuniu_Games_res.Kan_chu_niu,
		list={Niuniu_Games_res.Kan_chu_niu_list_0},
		-- preload =3
	}
}



return M