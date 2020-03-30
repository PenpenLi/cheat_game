local Config = class("Config")

Config.zhajinhua_room = {}           --炸金花房间配置

Config.zhajinhua_room_arr = {}       --炸金花房间配置

Config.limitest   = 10000

function Config:ctor ()
    
end

function Config:saveConfig(model)	-- body
	self.zhajinhua_room       = {}
	self.zhajinhua_room_arr   = {}
	self.zhajinhua_room.mount = 0
	

	for i=1,model.gold_flower_room:len() do
		local item = model.gold_flower_room:get(i)
		self.zhajinhua_room[item.room_level] = {}
		self.zhajinhua_room[item.room_level].room_name = item.room_name
		self.zhajinhua_room[item.room_level].base_chip = item.base_chip
		self.zhajinhua_room[item.room_level].enter_limit_low = item.enter_limit_low
		self.zhajinhua_room[item.room_level].enter_limit_high = item.enter_limit_high
		self.zhajinhua_room[item.room_level].online_user_count = item.online_user_count
		self.zhajinhua_room[item.room_level].room_level = item.room_level
		self.zhajinhua_room[item.room_level].pic_url    = item.pic_url
		self.zhajinhua_room[item.room_level].disable    = item.disable
		self.zhajinhua_room[item.room_level].room_group = item.room_group
		self.zhajinhua_room[item.room_level].room_color = item.room_color
		self.zhajinhua_room[item.room_level].payment_recommend = item.payment_recommend
		self.zhajinhua_room.mount = self.zhajinhua_room.mount + item.online_user_count
		if item.enter_limit_low < self.limitest  then
			self.limitest  = item.enter_limit_low
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
		table.insert( self.zhajinhua_room_arr, tmp )
	end
	table.sort(self.zhajinhua_room_arr, function (a, b)
		return a.enter_limit_high < b.enter_limit_high
	end)
end

function Config:getRoom(room_id)
	local game_conf = self.zhajinhua_room_arr 
    -- local cur_limit_gold
    for k, v in ipairs(game_conf) do
        if checknumber(v.room_level) ==checknumber(room_id) then
			return v
			-- cur_limit_gold = Cache.packetInfo:getProMoney(v.enter_limit_low)
            -- break
        end
	end
	-- return cur_limit_gold
end

-- 根据当前金币，获取可以进入的场次
function Config:getAvailableRoom( ... )
	local currentGold = Cache.user.gold
	for _, info in ipairs(self.zhajinhua_room_arr) do
		if currentGold >= info.enter_limit_low and currentGold <= info.enter_limit_high then
			return info.room_level
		end
	end
	return nil
end

function Config:getLimitMoney(room_level)
	local game_conf = self.zhajinhua_room_arr
	local roomConfig = nil
    local cur_limit_gold
    for k, v in ipairs(game_conf) do
        if checknumber(v.room_level) ==checknumber(room_level) then
            roomConfig = v
            break
        end
	end
	local limitMin = Cache.packetInfo:getProMoney(roomConfig.enter_limit_low)
	local limitMax = Cache.packetInfo:getProMoney(roomConfig.enter_limit_high)
	cur_limit_gold_str = Util:getFormatString(limitMin)
	-- 无上限
	if roomConfig.enter_limit_high >= 300000000000 then
		cur_limit_gold_str = cur_limit_gold_str .. Zjh_GameTxt.hall_limt_txt
	else
		cur_limit_gold_str = cur_limit_gold_str .. "-" .. Util:getFormatString(limitMax)
	end
	return limitMin, cur_limit_gold_str
end

return Config