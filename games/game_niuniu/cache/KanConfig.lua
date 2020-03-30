local KanConfig = class("KanConfig")

KanConfig.bull_classic_room = {}   --看牌抢庄房间配置
KanConfig.bull_classic_room_arr = {}   --看牌抢庄房间配置
KanConfig.classic_limitest   = 10000

function KanConfig:ctor ()
    
end

function KanConfig:saveKanConfig(model)	-- body
	self.bull_classic_room_arr = {}
	self.bull_classic_room.mount = 0

	for i=1,model.bull_classic_room:len() do
		local item = model.bull_classic_room:get(i)
		self.bull_classic_room[item.room_level] = {}
		self.bull_classic_room[item.room_level].room_name = item.room_name
		self.bull_classic_room[item.room_level].base_chip = item.base_chip
		self.bull_classic_room[item.room_level].enter_limit_low = item.enter_limit_low
		self.bull_classic_room[item.room_level].enter_limit_high = item.enter_limit_high
		self.bull_classic_room[item.room_level].online_user_count = item.online_user_count
		self.bull_classic_room[item.room_level].room_level = item.room_level
		self.bull_classic_room[item.room_level].pic_url    = item.pic_url
		self.bull_classic_room[item.room_level].disable    = item.disable
		self.bull_classic_room[item.room_level].room_group = item.room_group
		self.bull_classic_room[item.room_level].payment_recommend = item.payment_recommend
		self.bull_classic_room[item.room_level].room_color  = item.room_color 
		self.bull_classic_room.mount = self.bull_classic_room.mount + item.online_user_count
		self.bull_classic_room[item.room_level].call_score_list = {}
        for i = 1, item.call_score_list:len() do
            local u1 = item.call_score_list:get(i)
            table.insert(self.bull_classic_room[item.room_level].call_score_list,item.call_score_list:get(i))
        end

        local defaultCallScoreList = {5,10,15,20,25}
        -- 设置默认值
        if #self.bull_classic_room[item.room_level].call_score_list == 0 then
            self.bull_classic_room[item.room_level].call_score_list = defaultCallScoreList
        end
		
		if item.enter_limit_low < self.classic_limitest  then
			self.classic_limitest  = item.enter_limit_low
		end

		local tmp             = {}
		tmp.room_name         = item.room_name
		tmp.base_chip         = item.base_chip
		tmp.enter_limit_low   = item.enter_limit_low
		tmp.enter_limit_high  = item.enter_limit_high
		tmp.online_user_count = item.online_user_count
		tmp.room_level        = item.room_level
		tmp.pic_url           = item.pic_url
		tmp.disable           = item.disable
		tmp.room_group        = item.room_group
		tmp.room_color        = item.room_color
		tmp.call_score_list   = self.bull_classic_room[item.room_level].call_score_list
		table.insert(self.bull_classic_room_arr, tmp)
	end
	table.sort(self.bull_classic_room_arr, function (a, b)
		return a.enter_limit_high < b.enter_limit_high
	end)
end

-- 根据当前金币，获取可以进入的场次
function KanConfig:getAvailableRoom( ... )
	local currentGold = Cache.user.gold
	for _, info in ipairs(self.bull_classic_room_arr) do
		if currentGold >= info.enter_limit_low and currentGold <= info.enter_limit_high then
			return info.room_level
		end
	end
	return nil
end

function KanConfig:getLimitMoney(room_level)
	local game_conf = self.bull_classic_room_arr
	local roomConfig = nil
    local cur_limit_gold_str
	for k, v in pairs(game_conf) do
        if checknumber(v.room_level) == checknumber(room_level) then
            roomConfig = v
            break
        end
	end
	local limitMin = Cache.packetInfo:getProMoney(roomConfig.enter_limit_low)
	local limitMax = Cache.packetInfo:getProMoney(roomConfig.enter_limit_high)
	cur_limit_gold_str = Util:getFormatString(limitMin)
	-- 无上限
	if roomConfig.enter_limit_high >= 300000000000 then
		cur_limit_gold_str = cur_limit_gold_str .. Niuniu_GameTxt.hall_limt_txt
	else
		cur_limit_gold_str = cur_limit_gold_str .. "-" .. Util:getFormatString(limitMax)
	end
	return limitMin, cur_limit_gold_str
end

function KanConfig:getLimitMinAndMax(room_level)
	local game_conf = self.bull_classic_room_arr
	local roomConfig = nil
    local cur_limit_gold_str
	for k, v in pairs(game_conf) do
        if checknumber(v.room_level) == checknumber(room_level) then
            roomConfig = v
            break
        end
	end
	return roomConfig.enter_limit_low, roomConfig.enter_limit_high
end

function KanConfig:getRoom(room_level)
	local game_conf = self.bull_classic_room_arr 
    local cur_limit_gold
	for k, v in pairs(game_conf) do
        if checknumber(v.room_level) == checknumber(room_level) then
			return v
        end
	end
end


--设置当前桌子的信息
function KanConfig:setCurDeskInfo(room)
	self.curRoom = room
	-- room.room
	self.isBlue = room.room_color == GameConstants.NIUNIU_DESKCOLOR.BLUE
end

KanConfig.UI_DESK = 1
KanConfig.UI_TIP = 2
KanConfig.UI_TIPFNT = 3
KanConfig.UI_BACKCARD = 4
KanConfig.UI_STARTIMG = 5
KanConfig.UI_STARTIMGBG = 6
KanConfig.UI_DIGITALFNT = 7
KanConfig.UI_DNNUMDI = 8
function KanConfig:getUIResource(uiKey)
	local kanTbl = {
		{Niuniu_Games_res.brownDesk, Niuniu_Games_res.brownTishiyu, Niuniu_Games_res.brownTishiyuFnt,
			Niuniu_Games_res.brownBackCard, Niuniu_Games_res.brownPrepareStart, Niuniu_Games_res.brownPrepareStartBg,
		    Niuniu_Games_res.brownDigitalFnt, Niuniu_Games_res.brownDnNumDi
			},
		{Niuniu_Games_res.blueDesk, Niuniu_Games_res.blueTishiyu, Niuniu_Games_res.blueTishiyuFnt,
			Niuniu_Games_res.blueBackCard, Niuniu_Games_res.bluePrepareStart, Niuniu_Games_res.bluePrepareStartBg,
			Niuniu_Games_res.blueDigitalFnt, Niuniu_Games_res.blueDnNumDi
			}
	}

	if self.isBlue then
		return kanTbl[2][uiKey]
	end
	return kanTbl[1][uiKey]
end

return KanConfig