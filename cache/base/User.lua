local User = class("User")

function User:ctor() 
	
end

--[[
    optional int32 uin = 1;  // user id
    optional string key = 2; // user password
    optional string nick = 3;  //user nick
    optional int32 sex = 4; // user sex
    optional int64 gold = 5; // user gold
    optional int32 win = 6; // user win times
    optional int32 lose = 7; // user lose times
    optional int32 day = 8; // user login days
    optional string title = 9;  // user  title
    optional int32 vip_level = 10; // user vip level
    optional bool got_day_reward = 11; // user day reward flag
    optional bool got_vip_day_reward = 12;  // user vip_day_reward flag
    optional bool recharged = 13;  // recharge?
    optional int32 view_times = 14; // 观看次数
    optional int32 play_over_times = 15; // 玩到底的次数
    optional int32 play_times = 16;   // 玩的次数
    repeated int32 max_history_cards = 17;  // 历史最大手牌
    optional int32 max_history_win_chips = 18;  // 最大赢取筹码数
    optional int32 level =19; // 等级
    optional bool beauty = 20;  // 是否是认证美女
    optional bool got_beauty_day_reward = 21;  // 是否获取了美女每日奖励
    optional bool got_beauty_rank_week_reward = 22; //  获取美女每周排行奖励
    optional int32 last_week_beauty_rank = 23; // 上周美女排行
    optional string invite_code = 24; // 邀请码
    optional int32 online = 25; //在线人数
    optional int32 old_roomid = 26; // 给断线重连用的

]]
function User:updateCacheByLogin(model)
    if model == nil then return end
	local filedname = {
		"uin",
	    "key",
	    "nick",
	    "sex",
	    "gold",
	    "win",
	    "lose",
	    "day",
	    "title",
	    "vip_level",
	    "got_day_reward",
	    "got_vip_day_reward",
	    "recharged",
	    "view_times",
	    "play_over_times",
	    "play_times",
	    "max_history_win_chips",
	    "level",
	    "beauty",
	    "got_beauty_day_reward",
	    "got_beauty_rank_week_reward",
	    "last_week_beauty_rank",
	    "invite_code",
	    "online",
	    "old_roomid",
	    "room_type",
        "account_bind_status",
        "remain_times",
        "score",
        "pokerface",
        "diamond",
        "contest_credit",
        "anti_stealth",
        "event_id",
        "event_exit_reason", --用户旁观MTT，断网重连回来不能进桌的原因
        "promotion_code",
        "is_new_user",
        "first_recharge_flag",
        "first_recharge_url",
        "code_money",
        "cnd_path",
        "remain_time",
        "show_lucky_wheel_or_not",
        "IsRightTime",
        "left_time",
        "day_reward_start_time",
        "day_reward_end_time",
        "night_reward_start_time",
        "night_reward_end_time",
        "show_cumulate_login_or_not",
        "cumulate_login_reward",
        "is_new_reg_user",
        "show_third_pay_or_not",
        "game_list_type",
        "up_game_list",
        "down_game_list",
        "login_type",
        "portrait",
        "show_rank_or_not",  -- // 1:美女榜 2:财富榜 3:都显示 4: 都不显示
        "is_bind_phone", --绑定的手机号，为空表示未绑定
        "show_passwd_set", --是否显示密码设置，1：显示
        "safe_password",   --安全密码 0没有 1设置了
        "show_promotion",
        "invite_from",	--代理邀请
        "content",				-- 公告内容
        "begin_time",
        "end_time",
        "switch",				-- 公告开关
        "is_proxy",				-- 是否是代理
       	"hot_game_list", 		--热门游戏列表 其中游戏数字的定义如上列down_game_list
   		"suggest_game_list", 	--推荐游戏列表 其中游戏数字的定义如上列down_game_list
   		"guide_to_game",  		--0 代表不展示 其他roomid 用于快速开始
   		"login_token",			--聊天服务的token
   		"first_bind_proxy",      --是不是自动导入绑定的用户
   		"store_first_recharge"   --上架包商城首充 0 不展示, 1 展示
	}

	self.first_bind_proxy = 1

	for k,v in pairs(filedname) do
		if model[v] then
			--loga("updateCacheByLogin key = "..k.." value = "..v)
			self[v] = model[v]
			if v == "nick" then
				self[v] = Util:showUserName(model[v])
			end
		end
	end
	self.store_first_recharge = self.store_first_recharge or 0
	self.guide_to_game_uniq = self:getGameUniqByRoomid(self.guide_to_game)

	--金币自动除以100，因为跟法币是1:1
	-- self.gold = self.gold / GameConstants.RATE
	self.max_history_cards = {}

	--最大历史手牌
	for i=1,model.max_history_cards:len() do
		self.max_history_cards[i] = model.max_history_cards:get(i)
	end
	--self.got_day_reward = false
    if model.max_history_win_chips64 ~= nil then
        self.max_history_win_chips = model.max_history_win_chips64  --最大赢取在服务器端改为64位存储
    end

    self.start_time = os.time()
    self.turn_os_time=os.time()
    self.show       = 1
    --self.reConnect_status       = true
	self.upGameList={}
	self.downGameList = {}		
	if self.up_game_list ~= "" then
		self:updateGameList(self.up_game_list,self.upGameList)
	end
	if self.down_game_list ~= "" then
		self:updateGameList(self.down_game_list,self.downGameList)
	end

	--更新下方游戏列表flag （推荐、热门）
	self:updateGameFlag(self.hot_game_list, self.suggest_game_list, self.downGameList)

	local setDefault = function ()
		self.game_list_type = 2
		self.downGameList = {
			{name="1",status="0"},
			{name="2",status="0"},
			{name="6",status="0"},
			{name="3",status="0"},
			{name="8",status="0"},
			{name="9",status="0"},
			{name="11",status="0"}
		}
	end
	if self.game_list_type == 0 then
		setDefault()
	end
	if self.up_game_list == "" and self.down_game_list == "" then
		setDefault()
	end

	self:updateCommunityStatus(self.account_bind_status)

    self:setShowVisitorTip(true)
	--代理信息 是否已经代理了
	Cache.agencyInfo:saveConfig(model.invite_from)
end

function User:updateGameInfo(model)
	local filedname = {
        "total_play_times",
    	"total_win_rate",
        "single_win_max",
	    "week_gameing_result",
	    "jh_play_times",
	    "jh_win_rate",
	    "dn_play_times",
	    "dn_win_rate",

	    "jh_max_history_cards",
	    "dn_max_history_cards"
	}
	for k,v in pairs(filedname) do
		self[v] = model[v]

	end
	self.jh_max_history_cards = {}
	self.dn_max_history_cards = {}
	self.total_play_times = self.total_play_times  or 0
	self.total_win_rate = self.total_win_rate  or 0
	self.single_win_max = self.single_win_max  or 0
	self.week_gameing_result = self.week_gameing_result  or 0
	self.jh_play_times = self.jh_play_times  or 0

	self.jh_win_rate = self.jh_win_rate  or 0
	self.dn_play_times = self.dn_play_times  or 0
	self.dn_win_rate = self.dn_win_rate or 0
	-- 抢庄牛牛最大历史手牌

	for i=1,model.dn_max_history_cards:len() do
		self.dn_max_history_cards[i] = model.dn_max_history_cards:get(i)
	end

	-- 金花最大历史手牌
	for i=1,model.jh_max_history_cards:len() do
		self.jh_max_history_cards[i] = model.jh_max_history_cards:get(i)
	end
end

function User:updateGameList(listcontent,list)
	-- body
	local content = listcontent
	local gamelist = {}
	gamelist = string.split(content,"|")
	local checkIfHasGame = function (gameIndex)
		if not gameIndex or gameIndex == "" then return false end 
		if tonumber(gameIndex) <= 0 then return false end
		local gameName = GAMES_CONF[tonumber(gameIndex)].uniq
		local allGames = string.split(Util:getDesDecryptString(TB_SERVER_INFO.hall_show_list),"|")
		for k,v in pairs(allGames) do
			if v == gameName then
				return true
			end
		end
		return false
	end

	for k,v in pairs(gamelist)do
		local info = {}
		info = string.split(v,":")
		if checkIfHasGame(info[1]) then
			local gameinfo = {}
			if info[1]=="1" then
				self.defaultGame = "game_zjh"
			elseif info[1] == "2" and not self.defaultGame then
				self.defaultGame = "game_niuniu"
			end
			gameinfo.bPlaceholder = false
			gameinfo.name = info[1]
			gameinfo.status = info[2]
			gameinfo.uniq = GAMES_CONF[tonumber(info[1])].uniq
			gameinfo.hot = 0 --热门
			gameinfo.suggest = 0 --推荐
			table.insert(list,gameinfo)
		-- 如果是0的话就是占位，只是为了实现某个特殊的排布
		elseif tonumber(info[1]) == 0 then
			local gameinfo = {}
			gameinfo.bPlaceholder = true
			gameinfo.name = ""
			gameinfo.status = info[2]
			gameinfo.uniq = ""
			gameinfo.hot = 0 --热门
			gameinfo.suggest = 0 --推荐
			table.insert(list,gameinfo)
		end
	end
end

--更新热门和推荐
function User:updateGameFlag(hotGameList, suggestGameList, gameListInfo)
	--热门
	for i=1,hotGameList:len() do
		local gameName = hotGameList:get(i)
		for _,v in ipairs(gameListInfo) do
			if v.name == gameName then
				v.hot = 1
				break
			end
		end
	end

	--推荐
	for i=1,suggestGameList:len() do
		local gameName = suggestGameList:get(i)
		for _,v in ipairs(gameListInfo) do
			if v.name == gameName then
				v.suggest = 1
				break
			end
		end
	end
end

function User:getGameUniqByRoomid(roomid)
	local uniq = nil
	if roomid >= 30001 and roomid <= 30100 then
		uniq = "game_zhajinniu"
	elseif roomid >= 30101 and roomid <= 30200 then
		uniq = "game_niuniu"
	elseif roomid >= 30201 and roomid <= 30206 then
		uniq = "game_zjh"
	elseif roomid == 40203 or roomid == 40210 then
		uniq = "game_brnn"
	elseif roomid == 40101 then
		uniq = "game_br"
	elseif roomid == 40001 then
		uniq = "game_lhd"
	end
	return uniq
end

function User:getGameInfoByUniq(uniq)
	if not self.downGameList then return nil end
	local gameinfo = nil
	for _,v in ipairs(self.downGameList) do
		if v.uniq == uniq then
			gameinfo = v
			break
		end
	end
	return gameinfo
end

function User:getGameInfoByServerName(name)
	if not self.downGameList then return nil end
	local gameinfo = nil
	for _,v in ipairs(self.downGameList) do
		if tonumber(v.name) == name then
			gameinfo = v
			break
		end
	end
	return gameinfo
end


--[[

	optional string nick = 1;
    optional int64 gold =2;
    optional int32 win =3;
    optional int32 lose =4;
    optional string title=5;
    optional int32 sex=6;
    optional int32 vip_level=7;
    optional int32 last_week_beauty_rank=8;
    repeated GiftReceivedInfo gifts =9;
    optional bool is_friend = 10;
    optional bool is_beauty = 11;
    optional bool is_collect_player=12;                 // 是否已经关注
    optional bool is_be_collected_player=13;            // 是否被关注

    optional int32 play_times = 14;
    optional int32 ruju_prob=15;                        // 入局率
    optional int32 tanpai_prob =16;
    optional int32 win_prob =17;
    optional int32 view_times = 18;

    optional int32 play_over_times = 19;
    repeated int32 max_history_cards = 20[packed=true];
    optional int64 max_history_win_chips =21;
    optional int32 level =22;
    optional int32 decoration = 23;                     // 头像装饰
    optional int32 vip_days = 24;                       // vip 剩余天数
    optional int32 hiding = 25;                         // 是否隐身，0：否，1：是
    optional string portrait = 26;                      // 头像url

    message SendGift{
       optional int32 id = 1;
       optional string name = 2;
       optional int32 price = 3;
    }
    repeated SendGift send_gifts = 27;              // 拉取本条信息的玩家最近送出的礼物


    optional int64 diamond = 29;                    // 钻石数量
    optional int32 contest_credit = 30;             // 比赛积分
    optional int32 anti_stealth_time = 31;          // 使用反隐身卡的剩余时间
    optional int64 gift_card_sum = 32;              // 礼物卡总额
    optional string alias_nick = 33;                // 反隐身别名，隐身后的真实名称
	optional int64 chips = 34;						//用户身上的筹码
	message Inner {
        optional int32 category = 1;  // 10-邮件
        optional int32 item = 2;			// 暂时不启用
        optional int32 status = 3;    // 0 无小红点 1 有小红点
        optional int32 show_num = 4;	// 暂时不启用
    }
    repeated Inner notify = 35; // 小红点
]]
local NotityCategoryStatus = {
	mail = 11
}
function User:updateCacheByUseInfo (model,uin)
	if uin ~= self.uin or model == nil then 
		logd(" -- don't update userCache --  "..uin , "UserCache" )
		return 
	end
	local filedname = {
	"nick",
	"gold",
	"win",
	"lose",
	"title",
	"sex",
	"vip_level",
	"last_week_beauty_rank",
	"is_friend",
	"is_beauty",
	"is_collect_player",
	"is_be_collected_player",
	"play_times",
	"ruju_prob",
	"tanpai_prob",
	"win_prob",
	"view_times",
	"play_over_times",
	"max_history_win_chips",
	"level",
    "decoration",
    "vip_days",
    "hiding",
    "portrait",
    "diamond",
    "gift_card_sum",
    "number"
	}
	for k,v in pairs(filedname) do
		self[v] = model[v]
		if v == "nick" then
			self[v] = Util:showUserName(model[v])
		end
	end

	
    self.send_gifts = {}
    if model.send_gifts then
        for i = 1, model.send_gifts:len() do
            local _info = model.send_gifts:get(i)
            self.send_gifts[i] = {
                price = _info.price 
                , name = _info.name 
                , id = _info.id
            }
        end
    end

	self.gifts = {}
	for i=1,model.gifts:len() do
		local g = model.gifts:get(i)
        self.gifts[g.id+1] = {}
		self.gifts[g.id+1].id = g.id
        self.gifts[g.id+1].num = g.num
        self.gifts[g.id+1].name = g.name
        self.gifts[g.id+1].price = g.price
        self.gifts[g.id+1].remain = g.remain
        self.gifts[g.id+1].category = g.category + 1
	end

	self.max_history_cards = {}
	for i=1,model.max_history_cards:len() do
		self.max_history_cards[i] = model.max_history_cards:get(i)
	end
	self.sng_info = {}
	self.sng_info.match_count =  0
	self.sng_info.first_place =  0
	self.sng_info.second_place = 0
	self.sng_info.third_place =  0
	-- if model.sng_info then
	-- 	self.sng_info.match_count = model.sng_info.match_count or 0
	-- 	self.sng_info.first_place = model.sng_info.first_place  or 0
	-- 	self.sng_info.second_place = model.sng_info.second_place  or 0
	-- 	self.sng_info.third_place = model.sng_info.third_place  or 0
	-- end
	--qf.event:dispatchEvent(ET.NET_BEAUTY_WEEKLY_REWARD_REQ)

	self.mtt_info = {}
	-- if model.mtt_info then
	-- 	self.mtt_info.best_rank_1 = model.mtt_info.best_rank_1
	-- 	self.mtt_info.best_rank_1_value = model.mtt_info.best_rank_1_value
	-- 	self.mtt_info.best_rank_1_reward_name = model.mtt_info.best_rank_1_reward_name
	-- 	self.mtt_info.match_url_1 = model.mtt_info.match_url_1
	-- 	self.mtt_info.best_rank_2 = model.mtt_info.best_rank_2
	-- 	self.mtt_info.reward_name = model.mtt_info.reward_name
	-- 	self.mtt_info.reward_count = model.mtt_info.reward_count
	-- 	self.mtt_info.reward_name_2 = model.mtt_info.reward_name_2
	-- 	self.mtt_info.reward_count_2 = model.mtt_info.reward_count_2
	-- 	self.mtt_info.match_count = model.mtt_info.match_count
	-- 	self.mtt_info.match_url_2 = model.mtt_info.match_url_2
	-- end


	--邮件信息
	-- for i=1,model.notify:len() do
	-- 	local t = model.notify:get(i)
	-- 	if t.category == NotityCategoryStatus.mail then
	-- 		Cache.mailInfo:setNewMailFlag(t.status)
	-- 	end
	-- end

	--财神爷信息
	local mammon_info = model.mammon_info
	Cache.mammonInfo:saveConfig(mammon_info)

	--品牌包及相关信息
	self.gold = Cache.packetInfo:getProMoney(self.gold)
end

--是否是VIP用户
function User:isVip()
	if self.vip_days ~= nil and self.vip_days > 0 then
		return true
	else
		return false
	end
end

--是否已经隐身
function User:isHiding()
	if self:isVip() == true and self.hiding ~= nil and self.hiding == 1 then
		return true
	else
		return false
	end
end

--更新用户信息
function User:updateCacheByProfileChange(model)
	if model == nil or model.uin == nil or model.uin ~= self.uin then return end
	self.hiding = model.hiding
	if model.hiding == 0 then	--Cache.user 只存储用户本人自定义头像和昵称, 不存储隐身头像和昵称
		Cache.user.portrait = model.portrait
		Cache.user.nick = Util:showUserName(model.nick)
	end
end

--更新美女信息
--[[
CheckBeautyStatusRsp
    optional int32 status = 1; // status
    optional int32 remain_times = 2; // 还剩下多少次申请机会，0的话代表没了
    optional string refuse_reason = 3; // 如果是被拒绝，这里是拒绝原因
    optional string pretty_image = 4;       // 艺术照
    optional string normal_image = 5;       // 实拍照
]]

--更新美女信息
function User:updateBeautyInfo(model)
	if model == nil then return end
	logd("User:updateBeautyInfo "..pb.tostring(model))
	if model.status==3 then
		self.is_beauty=true
	else
		self.is_beauty=false
	end
	local fields = {"status", "remain_times", "refuse_reason", "pretty_image", "normal_image"}
	self.beauty_info = {}
	for k,v in pairs(fields) do
		self.beauty_info[v] = model[v]
	end
end
function User:updateBeautyInfoByJson(info)
	logd("美女头像上传成功后, 数据更新\n 玩家可见: ", info.pretty_image, ", \n客服可见:", info.normal_image)
	self.beauty_info = self.beauty_info or {}
	self.beauty_info.status = 1
	self.beauty_info.pretty_image = info.pretty_image
	self.beauty_info.normal_image = info.normal_image
end

function User:updateSafeBoxConfig(model)
	if not model then return end
	self.safe_gold = Cache.packetInfo:getProMoney(model.safe_gold)
	self.free_gold = Cache.packetInfo:getProMoney(model.free_gold)
end

function User:getBeautyInfo()
	return self.beauty_info
end

function User:updateUserDiamond(diamond)
    if diamond ~= nil then
        self.diamond = diamond
    end
end

function User:updateUserGold(gold)
    if gold ~= nil then
        self.gold = gold
    end
end

function User:getGiftCardSum()
	return self.gift_card_sum
end

function User:getMTTInfo()
	return self.mtt_info
end

--确认是否已经绑定手机
function User:isBindPhone()
    if self.is_bind_phone then
        return string.len(self.is_bind_phone) > 0
    end
    return false
end


function User:checkShowVisitorTip()
    --1.打开商店
    --2.进入大厅
    --3.金钱不足时
    if Cache.user.login_type == 1 and self._visitorFlag and not ModuleManager:judegeIsIngame() then
        return true
    end
    return false
end

function User:setShowVisitorTip(bflag)
    self._visitorFlag = bflag --游客提示
end


--是否是代理
function User:isProxy( ... )
	return self.is_proxy == 1
end

function User:setProxy(isProxy)
	self.is_proxy = isProxy
end

-- 判断是不是客服(消息过来可以判断来源)
function User:isCustomerService(cid)
	return tonumber(cid) <= 1000
end

-- 判断是不是新增注册、绑定代理用户
function User:isNewRegAndHasProxcy( ... )
	if self.is_new_reg_user == 1 and self.invite_from > 0 then
		return true
	end
	return false
end

--[[
	0 - 已绑定社区 1 - 退出社区
	1.上架包绑定了代理，就默认是未加入社区
	2.线下包默认都是加入了社区
]]
function User:updateCommunityStatus(status, isRequest)
	if status == 1 and isRequest then
		-- 记录下退出时间
		local timestamp = os.time()
		cc.UserDefault:getInstance():setStringForKey("Chat_Cache_Quit_Community_Time" .. Cache.user.uin,  timestamp);
	    cc.UserDefault:getInstance():flush()
	end
	self.communityStatus = status
end

-- 获取退出社区的间隔
function User:getQuitCommunityMaxTime( ... )
	return 72*60*60
end

-- 是否需要提示退出太频繁
function User:isUserQuitCommunitySequeces( ... )
	local lastQuitTime = cc.UserDefault:getInstance():getStringForKey("Chat_Cache_Quit_Community_Time" .. Cache.user.uin, "0");
	lastQuitTime = tonumber(lastQuitTime)
	if lastQuitTime == 0 then
		return true
	end
	if os.time() - lastQuitTime > self:getQuitCommunityMaxTime() then
		return true
	end
	return false
end

-- 获取绑定状态
function User:getCommunityStatus()
	if Cache.packetInfo:isShangjiaBao() then
		return self.communityStatus
	end
	-- 其他的都是默认绑定了社区，因为其他的不需要这个，只有上架包才有
	return 0
end

function User:clear()
	-- self.popHongBao = false
end

return User