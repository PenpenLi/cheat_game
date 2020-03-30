GAMES_CONF = {}

GAME_NAME = qf.platform:getAppName()

GAME_NAME = GAME_NAME or "天天斗牛"

GAMES_CONF= {
		{
		  uniq="game_zjh",
		  name='炸金花',
		  rank=1
		},
		{
		  uniq="game_niuniu",
		  name='抢庄牛牛',
		  rank=2
		},
		{
		  uniq="game_zhajinniu",
		  name='炸金牛',
		  rank=3
		},
		{
		  uniq="game_texas",
		  name='德州扑克',
		  rank=4
		},
		{
		  uniq="game_tbz",
		  name='推豹子',
		  rank=5
		},
		{
		  uniq="game_lhd",
		  name='龙虎斗',
		  rank=6
		},
		{
		  uniq="game_ShuangQ",
		  name='双扣',
		  rank=7
		},
		{
		  uniq="game_br",
		  name='百人炸金花',
		  rank=8
		},
		{
		  uniq="game_ddz",
		  name='斗地主',
		  rank=9
		},
		{
		  uniq="game_bjl",
		  name='百家乐',
		  rank=10
		},
		{
		  uniq="game_brnn",
		  name='百人牛牛',
		  rank=11
		}
}

GAMES_CONF_UNIQ = {}

for k,v in pairs(GAMES_CONF) do
	GAMES_CONF_UNIQ[v.uniq] = v
end


GAMES_ANDROID = {'ADHM_HM001'}