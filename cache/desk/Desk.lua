--[[
    经典场/SNG场牌桌缓存
--]]
local Desk = class("Desk")

Desk._user = {}
Desk._currentList = {}
Desk._result = {}
Desk._share_cards  = {}
Desk._winners = {}
Desk.play_info = {}
Desk.op_user = {}
Desk.round_info = {}
Desk.isGameSettling=false --判断桌子是否在结算中  为MD5校验
function Desk:ctor ()
    self.name = JDC_MATCHE_TYPE
    self:clearCache()
end

function printSNG(str, tab)
    loge("[SNG DATA] "..str)
end

function Desk:clearCache()
    self.isGameSettling=false
    self.roomid = 0
    self.deskid = 0
    self.op_uin = 0
    self.status = 0   --
    self.dealer = 0   -- uin
    self.dealer_seatid = 0
    self.player_op_past_time = 0
    self.total_chips = 0
    self.bet_type = 0
    self._customize_password = ""
    self.jifen = nil
    
    self._user = {}
    self._currentList = {}
    self._result = {}
    self._share_cards  = {}
    self._winners = {}
    self.play_info = {}
    self.op_user = {}
    self.round_info = {}
    self._historyList = {}
end

--[[--
EvtDeskUserEnter 更新cache
]]

function Desk:updateCacheByInput( model )
    -- printSNG("进桌:"..pb.tostring(model))
    local propsTable = {"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","decoration","vip_days","hiding","portrait","is_master","auto_play","be_anti"}
    self._currentList = {}
    -- 拷贝一些基础信息
    self:_updateProps({"roomid","op_uin","status","dealer","dealer_seatid","player_op_past_time","deskid","next_uin","total_chips"},model,self)

    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._user[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._user[u1.uin] = u2
        self._currentList[#self._currentList + 1]  = u1.uin
    end

    -- 拷贝card 信息
    self._share_cards = {}
    for i = 1, model.share_cards:len() do
      self._share_cards[i] = model.share_cards:get(i)
    end
    if self.status == 1 or model.op_uin == Cache.user.uin then
        self:updatePlayInfo(model.play_info)
    end
    self:updateTotalChipsDetails(model.total_chips_detail)
    
    self:updateCustomizeInfo(model.cm_data) --更新私人定制信息
    self.buyin_limit_multi = checkint(model.buyin_limit_multi)    --本桌买入筹码限制倍数
    self:updateMyTotalBuyin(model.total_buyin_chips)    --本人在这个桌子兑换的筹码累加

    --jackpot start
    self.jackpot_status = checkint(model.jackpot_status) -- 是否支持Jackpot =0不支持 =1支持
    if  model.op_uin == Cache.user.uin then
        self.jackpot_amount_changed = true
    end
    self.jackpot_amount = checkint(model.jackpot) -- 进桌时奖池大小
    --jackpot end

    --更新用户手牌信息
    self:updateUserCardsInfomation(model, 1)
end

function Desk:updateByShareCards(model)
    --缓存基本信息
    self:_updateProps({"next_uin","deskid","roomid"},model,self)
    --缓存本人信息
    self:updatePlayInfo(model.play_info)
    --缓存公共牌
    self._share_cards = {}
    for i = 1, model.share_cards:len() do
        self._share_cards[i] = model.share_cards:get(i)
    end

    self:updateUserCardsInfomation(model, 2)
end
--更新用户的手牌信息
function Desk:updateUserCardsInfomation( model, from )
    --缓存本人最大牌型. 当手牌和公共牌的顺序翻转时，说明所有人都allin了
    self._all_user_cards_formation = nil
    self._my_cards_formation = nil
    -- 标记是否要摊牌
    self.reverse_show_cards_order = model.reverse_show_cards_order == 1
    if self.reverse_show_cards_order then
        self._all_user_cards_formation = {}
        for i = 1, model.users:len() do
            local user_card = model.users:get(i)
            if user_card.uin == Cache.user.uin then
                self._my_cards_formation = {}
                if from == 2 then --如果是从翻公共牌消息过来的，则就要更新3、4张公共牌的牌型
                    for j = 1, user_card.formations:len() do
                        local max_card_formation = user_card.formations:get(j)
                        self._my_cards_formation[max_card_formation.share_cards_num] = max_card_formation.cards_formation
                    end
                end
                self._my_cards_formation[5] = self.play_info.max_cards_formation
            end
            -- 把每个人的手牌也存储起来
            self._all_user_cards_formation[user_card.uin] = {}
            --做下兼容，如果没有cards数据则会崩溃
            if user_card.cards and user_card.cards:len() > 0 then
                self._all_user_cards_formation[user_card.uin].card1 = user_card.cards:get(1)
                self._all_user_cards_formation[user_card.uin].card2 = user_card.cards:get(2)
            end
        end
    end
end

--获取本人的最大牌型. cards_num: 当前开了几张牌. 当cards_num==nil时，返回默认的最大牌型
function Desk:getMyMaxCardsFormation(cards_num)
    local max_card = 0
    if cards_num == nil or self._my_cards_formation == nil then
        max_card = self.play_info.max_cards_formation   --不传入桌牌数，取当前PlayInfo牌型
    else
        if cards_num < 3 then
            max_card = nil     --桌牌不满3张，没有供更新的牌型
        else
            max_card = self._my_cards_formation[cards_num]   --当前桌牌数对应的最大牌型
        end
    end
    return max_card
end

function Desk:updateTotalChipsDetails (model) 
    self.total_chips_detail = {} -- 拷贝 total_chips_detail 属性
    if not model then return end

    for i = 1 , model:len() do
        local t1 = model:get(i)
        local t2 = {}
        t2.chips = t1.chips
        t2.users = {}
        for j = 1 , t1.users:len() do
            t2.users[j] = t1.users:get(j)
        end
        self.total_chips_detail[i] = t2
    end
end

--[[
  cards: 50
  cards: 22
  max_cards_formation: 0
  min_bet: 0
  max_bet: 990
  dft_improve_bet: 10
  chips: 990
  round_chips: 10
]]
function Desk:updatePlayInfo (src)
  self.play_info.cards =  {}
  
  for i=1,src.cards:len() do
    self.play_info.cards[i] = src.cards:get(i)
  end
  
  self:_updateProps({"max_cards_formation","min_bet","max_bet","dft_improve_bet","show_cards","rank","status","round_cost"},src,self.play_info)
end
--更新play_info中的rank
function Desk:updateRankInPlayInfo( rank )
    self.play_info = self.play_info or {}
    self.play_info.rank = rank
end

function Desk:clearUserByuin(uin)
    if self._user then self._user[uin] = nil end
end

function Desk:updateRound(m)
    self.round_info = {}
    self:_updateProps({"max_rounds","cur_round"},m,self.round_info)
end

function Desk:getRound()
    if self.round_info == nil or self.round_info.max_rounds == nil or self.round_info.cur_round == nil then return end
    return self.round_info.cur_round.."/"..self.round_info.max_rounds
end

function Desk:getShareCards()
    return self._share_cards
end

--游戏开始时如果有前注要更新每个人应该要交的前注
function Desk:updatePreviousBetsByStart( model )
    self.previous_bets = {}
    if not model then return end

    for i = 1, model:len() do
        local item = model:get(i)
        self.previous_bets[item.uin] = item.bet
    end
end
function Desk:getPreviousBetByUin( uin )
    return self.previous_bets and self.previous_bets[uin] or 0
end
--[[--EvtGameStart]]
function Desk:updateCacheByStart( model )
    -- printSNG("游戏开始:"..pb.tostring(model))
    self:_updateProps({"status","dealer","dealer_seatid","next_uin","total_chips"},model,self)
    -- printSNG("!!! 庄家位置: "..self.dealer_seatid)
    local propsTable = {"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","decoration","hiding","portrait","auto_play","be_anti"}
    self._currentList = {}
    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._user[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._user[u1.uin] = u2
        self._currentList[#self._currentList + 1]  = u1.uin
    end

    --更新底池详情
    self:updateTotalChipsDetails(model.total_chips_detail)
    --更新每个玩家的前注信息
    self:updatePreviousBetsByStart(model.previous_bets)

    self._share_cards = {}  --公共牌在开牌的时候清空
    self:updatePlayInfo(model.play_info)
    self:updateMyTotalBuyin(model.total_buyin_chips)

    self._my_cards_formation = nil
    self._all_user_cards_formation = nil
    self.reverse_show_cards_order = false
end

--[[EvtGameOver]]
function Desk:updateCacheByOver (model)
    -- printSNG("结算:"..pb.tostring(model))
    -- self.status = 0
    local fieldName = {"next_uin"
        , "deskid"
        , "roomid"
        , "dealer_seatid"
        , "status" --游戏状态
    }
    self:_updateProps(fieldName, model, self)
    local propsTable = {"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","hiding","portrait","auto_play","be_anti"}
    self._currentList = {}
    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._user[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息

        -- 拷贝cards 和 max_cards
        u2.cards = nil
        if u1.cards:len() ~= 0 then
            u2.cards = {}
            for j = 1 , u1.cards:len() do
                u2.cards[j] = u1.cards:get(j)
            end
        end

        u2.max_cards = nil
        if u1.max_cards:len() ~= 0 then 
            u2.max_cards = {}
            for j = 1,u1.max_cards:len() do
              u2.max_cards[j] = u1.max_cards:get(j)
            end
        end

        u2.max_cards_formation = u1.max_cards_formation

        self._user[u1.uin] = u2
        self._currentList[#self._currentList + 1]  = u1.uin
    end
    
    self._winners = {}
    self.meiswinner = false
    if model.winners ~= nil then 
        for i=1,model.winners:len() do
            local uin = model.winners:get(i)
            self._winners[i] = uin
            self.meiswinner = self.meiswinner or (uin == Cache.user.uin)
        end
    end
    
    self._result  = {}
    self.total_chips_detail = {}

    for i = 1,model.result:len() do
        local r1 = model.result:get(i)
        local r2 = {}
        r2.chips = r1.chips
        r2.settle = {}
        for j = 1,r1.settle:len() do
            r2.settle[j] = {}
            self:_updateProps({"uin","chips"},r1.settle:get(j),r2.settle[j])
        end
        self._result[i] = r2 
        self.total_chips_detail[i] = {}
        self.total_chips_detail[i].chips = r1.chips  -- 最后一次要更新分堆信息
    end

    --抽水后的结果
    self._real_result = {}
    for i = 1, model.real_result.settle:len() do
        local result = model.real_result.settle:get(i)
        self._real_result[result.uin] = result.chips
    end

    self:updatePlayInfo(model.play_info)
    
    self.remain_time = model.remain_time	--牌局剩余时间

    --jackpot start
    if self.jackpot_amount ~= model.jackpot then --判断奖池有无变化
        self.jackpot_amount_changed = true
    end
    self.jackpot_amount = checkint(model.jackpot)      --牌局结束时jackpot奖池大小
    self.jackpot_before = checkint(model.jackpot_before)    --如果有人击中奖池，结算前奖池的大小(如果无人击中奖池, 该值与jackpot_amount相等)
    self:updateJackpotHited(model)
    --jackpot end
end

function Desk:updateCacheBySitDown(model)
  local propsTable = {"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","decoration","vip_days","hiding","portrait","is_master","auto_play","be_anti"}
  self._currentList = {}

  self:_updateProps({"roomid","op_uin","next_uin","player_op_past_time"},model,self)
  for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._user[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._user[u1.uin] = u2
        self._currentList[#self._currentList + 1]  = u1.uin
    end
    if self.status == 1 or  model.op_uin == Cache.user.uin then
        self:updatePlayInfo(model.play_info)
    end
end

function Desk:updateCacheByStandUp (model)
    self:updateTotalChipsDetails(model.total_chips_detail)
    self:_updateProps({"deskid","roomid","dealer","dealer_seatid","op_uin","next_uin","total_chips","lack_money"},model,self)

    self._currentList = {}
    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._user[u1.uin] or {}
        self:_updateProps({"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","hiding","portrait","auto_play","be_anti"},u1,u2)  -- 拷贝user 信息
        self._user[u1.uin] = u2
        self._currentList[#self._currentList + 1]  = u1.uin
    end
    if self.status == 1 or model.op_uin == Cache.user.uin then
        self:updatePlayInfo(model.play_info)
    end
    if model.total_chips64 ~= nil then
        self.total_chips = model.total_chips64  --升到64位存储
    end
end

function Desk:updateCacheByGiveUp(model)
    -- printSNG("弃牌:"..pb.tostring(model))
    self:updatePlayInfo(model.play_info)
    self:_updateProps({"deskid","op_uin","next_uin","total_chips","roomid"},model,self)
    self:updateUserByOpUser(model.op_user)
end

function Desk:getUserChecked(uin)
    local u = self:getUserByUin(uin)
    return u ~= nil and u.checked or nil
end

function Desk:updateUserByOpUser(model)
    local uin = model.uin
    self.op_user = {}
    self:_updateProps({"uin","gold","chips","status"},model,self.op_user) -- copy到user Cache

    local u = self:getUserByUin(uin)
    if u then self:_updateProps({"uin","gold","chips","status"},model,u) end
    self._user[uin] = u
    
end

function Desk:updateUserByExit( model ) 
    -- printSNG("退桌:"..pb.tostring(model))
    self:updateTotalChipsDetails(model.total_chips_detail)
    self:updateUserByOpUser(model.op_user)
    
    if self.status == 1 then
        self:updatePlayInfo(model.play_info)
    end
    self:_updateProps({"deskid","dealer","dealer_seatid","next_uin","total_chips","player_op_past_time","roomid"},model,self)
end
function Desk:removeExitUser(u)
    for k, v in pairs(self._currentList) do
        if v == u then
            table.remove(self._currentList, k)
        end
    end
end

function Desk:getWinnerList()
    local ret = {}
    for k,v in pairs(self._winners) do
        ret[k] = self._user[v]
    end
    return ret
end

function Desk:getResult()
    return clone(self._result)
end

-- 是否有退注筹码.（如果结果信息中出现非赢玩家的uin则认为需要退注）
function Desk:hasLeftChips()
    local ret = self:getResult()
    local wlist = self:getWinnerList()
    local ulist = self:getUserList()

    if not ret or not wlist or not ulist then return false end

    local uinRetList = {}
    for _, v in pairs(ret) do
        if v and v.settle then
            for _, s in pairs(v.settle) do
                uinRetList[s.uin] = true
            end
        end
    end

    for _, v in pairs(wlist) do
        uinRetList[v.uin] = false
    end

    for _, v in pairs(uinRetList) do
        if v then
            return true
        end
    end

    return false
end

function Desk:getRealWinChipsByUin(uin)
    if self._real_result ~= nil and self._real_result[uin] ~= nil then
        return self._real_result[uin]
    else
        return 0
    end
end

--[[--
]]
function Desk:updateCacheByBet(model)
    -- printSNG("跟注:"..pb.tostring(model))
    self:_updateProps({"total_chips","next_uin","deskid","roomid"},model,self)
    local u1 = model.op_user
    local u2 = self._user[u1.uin] or {}
    self:_updateProps({"uin","gold","chips","round_chips","bet_chips","status","bet_type"},u1,u2)
    self._user[u1.uin] = u2
    self.bet_type = u1.bet_type
    self:updatePlayInfo(model.play_info)
end

function Desk:getUserList()
    local ret = {}
    for k,v in pairs(self._currentList) do
        ret[k] = self._user[v]
    end
    return ret
end

function Desk:getUserNumber()
    local num = 0
    for k,v in pairs(self._currentList) do
        num = num + 1
    end
    return num
end

function Desk:getUserNumberWithoutOneself()
    local users = self:getUserList() or {}
    local num = table.getn(users)
    for k,v in pairs(users) do
        if v.uin == Cache.user.uin then
            num = num - 1
            return num
        end
    end
end

--[[-- 获取cache的先检查，现在的userList]]
function Desk:_checkUserInList ( uin) 
  for k,v in pairs(self._currentList) do
    if uin == v then return true end
  end
  return false
end

function Desk:getSomeOneUin()
    for k, v in pairs(self._currentList) do
        if v ~= Cache.user.uin then return v end
    end
end

function Desk:getUserByUin(uin)
  if self:_checkUserInList(uin) then return self._user[uin] end
  return nil
end

function Desk:updateChipsByUin(uin,chips)
    local u = self:getUserByUin(uin)
    if u == nil then return end
    u.chips = chips
end

function Desk:_updateProps( propsTable , src,dest )
  for k,v in pairs(propsTable) do
    dest[v] = src[v]
  end
end

function Desk:judgeMyselfIsIngame()
    if ModuleManager:judegeIsIngame() ~= true then
        return true
    end
    local u = self:getUserByUin(Cache.user.uin)
    if u == nil then return false end
    return u.status >= UserStatus.USER_STATE_READY
end

function Desk:getEnterTotal()
    local result = self.total_chips or 0
    for k,v in pairs(self._currentList) do
        result = result - self._user[v].round_chips
    end
    return result < 0 and 0 or result
end


-------------------实时战绩---------------
--判断该房间是否可以显示实时战绩
function Desk:judgePeriod()
	local result = Cache.texasConfig:judgePeriodByRoomid(self.roomid)
	return result
end
-------------------大亨房间---------------
--判断是否是大场
function Desk:isBigwayRoom()
  local result = (Cache.Config._roomList[self.roomid].group == 3)
  return result
end
-------------------私人房间---------------
--判断是否是私人定制房间
function Desk:isCustomizeRoom()
	local result = Cache.texasConfig:isCustomizeRoom(self.roomid)
	return result
end
--更新私人定制桌子信息
function Desk:updateCustomizeInfo(data)
	self._customize_info = {}
	self._customize_info.name = data.name
	self._customize_info.must_spend = data.must_spend
	self._customize_info.last_time = data.last_time
	self._customize_info.remain_time = data.remain_time
    self:updateCustomizePassword(data.password)
end
--获取私人定制桌子信息
function Desk:getCustomizeInfo()
	return self._customize_info
end
--更新私人定制实时战绩
function Desk:updateCustomizeRealtimeRecord(model)  
	self._customize_rt_record = {}
	for i=1, model.data_list:len() do
		local item_info = model.data_list:get(i)
		self._customize_rt_record[i] = {}
		self:_updateProps({"uin","nick","exchange_chips","win_chips","win_times","play_times","hiding","portrait"}, item_info, self._customize_rt_record[i])
    end
    --按盈利排序
    table.sort(self._customize_rt_record, function(a,b) return a.win_chips > b.win_chips end)
end
--获取私人定制实时战绩
function Desk:getCustomizeRealtimeRecord(model)
	return self._customize_rt_record
end
--更新私人定制牌局结算
function Desk:updateCustomizeSettle(model)
	self._customize_settle = {}
	--牌局信息
	local field = {"desk_id", "round_count", "max_ante", "exchange_count"}
	self:_updateProps(field, model, self._customize_settle)
	local roominfo = Cache.texasConfig:getCustomizeRoomInfoById(self.roomid)
    if roominfo ~= nil then
    	--盲注
		self._customize_settle.big_blind = roominfo.big_blind
		self._customize_settle.small_blind = roominfo.small_blind
    end
	
	--称号信息
	field = {"uin", "sex", "nick", "hiding","portrait"}
	self._customize_settle.best_user = {}
	self:_updateProps(field, model.best_user, self._customize_settle.best_user)
	self._customize_settle.worst_user = {}
	self:_updateProps(field, model.worst_user, self._customize_settle.worst_user)
	self._customize_settle.tuhao_user = {}
	self:_updateProps(field, model.tuhao_user, self._customize_settle.tuhao_user)

	--排行信息
	self._customize_settle.most_win = 0
	self._customize_settle.most_lost = 0
	self._customize_settle.rank_info = {}
	for i=1, model.rank_info:len() do
		local rank = model.rank_info:get(i)
		self._customize_settle.rank_info[i] = {}
		self._customize_settle.rank_info[i].uin = rank.user.uin
		self._customize_settle.rank_info[i].sex = rank.user.sex
		self._customize_settle.rank_info[i].nick = rank.user.nick
		self._customize_settle.rank_info[i].hiding = rank.user.hiding
		self._customize_settle.rank_info[i].portrait = rank.user.portrait
		self._customize_settle.rank_info[i].exchange_count = rank.exchange_count
		self._customize_settle.rank_info[i].win_chips = rank.win_chips
		--记录输赢最多的数值
		if rank.win_chips > self._customize_settle.most_win and rank.win_chips > 0 then
			self._customize_settle.most_win = rank.win_chips
		elseif rank.win_chips < self._customize_settle.most_lost and rank.win_chips < 0 then
			self._customize_settle.most_lost = math.abs(rank.win_chips)
		end
    end
    
    --排行信息按盈利排序
    table.sort(self._customize_settle.rank_info, function(a,b) return a.win_chips > b.win_chips end)    
end
--获取私人定制牌局结算
function Desk:getCustomizeSettle()
	return self._customize_settle
end
--获取开始游戏需要的最小筹码数
function Desk:getCustomizeMinChips(uin)
    local roominfo = Cache.texasConfig:getCustomizeRoomInfoById(self.roomid)
    local min_chips = roominfo.must_spend + roominfo.big_blind
    return min_chips
end
--获取私人场buyin限制信息(本人已购筹码数, 最大购入筹码数, 剩余可购筹码数)
function Desk:getCustomizeBuyin()
	local roomInfo = Cache.Config._roomList[self.roomid]
    local buyin_limit = roomInfo.carry_limit * self.buyin_limit_multi
    local remain_buyin = buyin_limit - self.total_buyin_chips
    return self.total_buyin_chips, buyin_limit, remain_buyin
end
--更新本人buyin
function Desk:updateMyTotalBuyin(total_buyin)
    self.total_buyin_chips = checkint(total_buyin)
end
--设置/获取桌子密码
function Desk:updateCustomizePassword(password)
    if password == nil then
        self._customize_password = ""
    else
        self._customize_password = password
    end
end
function Desk:getCustomizePassword()
    return self._customize_password
end
--判断是否是房主
function Desk:isCustomizeRoomOwner(uin)
    local user = self:getUserByUin(uin)
    if user == nil or user.is_master == nil or user.is_master == 0 then
        return false
    else
        return true
    end
end
--更新房主
function Desk:updateCustomizeRoomOwner(uin)
    if uin == nil then return end
    for k, v in pairs(self._user) do
        if k == uin then
            v.is_master = 1
        else
            v.is_master = 0
        end
    end
end
-------------------------vip / 隐身-------------------------
--更新历史记录
function Desk:refreshHistoryRecord()
	self._historyList = self._historyList or {}
	local dumpstr = ""
	for k, v in pairs(self._currentList) do
		if self._historyList[v] == nil then
			self._historyList[v] = 0	--还未曾站起。如果已站起过则置为1
		end
	end
end

--清除指定用户的历史记录
function Desk:clearHistoryRecordByUin(uin)
	if uin == nil then return end
	if self._historyList == nil then return end
	if self._historyList[uin] ~= nil then
		self._historyList[uin] = nil
	end
end

--查看历史记录中是否有该用户
function Desk:isInHistoryRecord(uin)
	if uin == nil then return true end
	if self._historyList == nil then return false end
	local in_history = false
	if self._historyList[uin] ~= nil then
		in_history = true
	end
	return in_history
end

--普通场判断是否是vip用户
function Desk:judgeIsVip(uin)
	if self._user[uin] == nil or self._user[uin].vip_days == nil or self._user[uin].vip_days <= 0 then
		return false
	else
		return true
	end
end

--普通场判断是否处于隐身状态
function Desk:judgeIsHiding(uin)
	local user = self._user[uin]
	if user == nil or user.vip_days == nil or user.hiding == nil then return false end
	if user.vip_days > 0 and user.hiding == 1 then
		return true
	else
		return false
	end
end

--更新隐身配置
function Desk:updateProfile(model)
	if model.uin == nil then return end
	local user = self._user[model.uin]
	if user == nil then return end
	user.nick = Util:showUserName(model.nick)
	user.portrait = model.portrait
	user.hiding = model.hiding
end
--更新牌局状态
function Desk:updateGameStatus( game_status )
    self.status = checkint(game_status)
end


-------------------jackpot---------------
--判断是否支持jackpot
function Desk:judgeSupportJackpot()
    return 1 == self.jackpot_status
end

--奖池总额是否发生变化
function Desk:isJackpotAmountChanged(model)
    return self.jackpot_amount_changed
end

--判断是否支持积分
function Desk:judgeSupportScore()
    if self:isCustomizeRoom() == true then
        return false
    else
        local roomInfo = Cache.Config._roomList[self.roomid]
        if roomInfo ~= nil and roomInfo.big_blind >= 1000 then  --大盲大于1000的场次支持积分
            return true
        else
            return false
        end
    end
end

--更新经典场击中奖池信息
function Desk:updateJackpotHited(model)
    self.jackpot_rewards = {}   --击中奖池信息
    if model.jackpot_rewards ~= nil then
        local index = 1
        for i = 1, model.jackpot_rewards:len() do
            local reward = model.jackpot_rewards:get(i)
            if reward.amount ~= 0 then  --容错处理, 当奖金是0的时候不计算在内
                self.jackpot_rewards[index] = {}
                self.jackpot_rewards[index].uin = reward.uin
                self.jackpot_rewards[index].type = reward.type
                self.jackpot_rewards[index].amount = reward.amount
                index = index + 1
            end
        end
        if #self.jackpot_rewards > 0 then
            self.jackpot_amount_changed = true
        end
    end
end
--获取击中奖池全部信息
function Desk:getJackpotHitedAll()
    return self.jackpot_rewards
end
--获取单个用户的击中奖池信息
function Desk:getJackpotHitedByUin(uin)
    if self.jackpot_rewards == nil then return nil end
    for i = 1, #self.jackpot_rewards do
        local reward = self.jackpot_rewards[i]
        if reward.uin == uin then
            return reward
        end
    end
    return nil
end
--判断是否有人击中奖池
function Desk:judgeJackpotHited()
    if (self.jackpot_rewards == nil) or (#self.jackpot_rewards == 0) then 
        return false 
    else
        return true
    end 
end

function Desk:getRoomCarryMin()
    return Cache.Config:getRoomCarryMin( self.roomid )
end

function Desk:getRoomCarryLimit()
    return Cache.Config:getRoomCarryLimit( self.roomid )
end

function Desk:getRoomBlind()
  return Cache.Config:getRoomBlind( self.roomid )
end


function Desk:clearShareCard()--为了MD5校验
    self._share_cards = {}
end

function Desk:setUsersStatus(status)--为了MD5校验
    for k, v in pairs(self._currentList) do
        local user=self._user[v]
        if user then
            user.status=status 
        end
    end
end

--[[
    获取需要参与校验的数据描述
    参数: cmd, 命令字
    返回: 描述表, 描述内容如下:
            check_users, 是否校验用户数据
            check_share_cards, 是否校验公共牌
            check_total_chips, 是否校验底池筹码总数
--]]
function Desk:getMD5CheckContent(cmd,op_uin)--op_uin 主要用于用户退桌时  先将退桌的用户剔除
    local content = {}
    content.users = {}
    local index=1
    for k, v in pairs(self._currentList) do
        if op_uin and op_uin==v then
            
        else
            content.users[index] = clone(self._user[v])
            index=index+1
        end
    end
    --seatid从小到大排列
    if table.getn(content.users) > 1 then
        table.sort(content.users, function(a, b)
            return a.seatid < b.seatid
        end)
    end

    if cmd == CMD.INPUT_GAME_EVT then --其他人进桌
        content.check_users = true
        content.check_share_cards = false
        content.check_total_chips = true
    elseif cmd == TEXAS_CMD.GAME_STAR_EVT then    --牌局开始
        content.check_users = true
        content.check_share_cards = false
        content.check_total_chips = true
    elseif cmd == TEXAS_CMD.OPEN_SHARE_CARDS_EVT then --发公共牌
        for k, user in pairs(content.users) do
            user.round_chips = 0  --为了MD5校验
        end
        content.check_users = true
        content.check_share_cards = true
        content.check_total_chips = true
    elseif cmd == TEXAS_CMD.FOLLOW_RESPONSE_EVT then --跟注
        content.check_users = true
        content.check_share_cards = true
        content.check_total_chips = true
    elseif cmd == TEXAS_CMD.GIVEUP_RESPONSE_EVT then --弃牌
        content.check_users = true
        content.check_share_cards = true
        content.check_total_chips = true
    elseif cmd == TEXAS_CMD.SIT_DOWN_EVT then --坐下
        content.check_users = true
        content.check_share_cards = false
        content.check_total_chips = true
    elseif cmd == TEXAS_CMD.STAND_UP_RESPONSE_EVT then --站起
        content.check_users = true
        content.check_share_cards = false
        content.check_total_chips = true
    elseif cmd == TEXAS_CMD.EXIT_RESPONSE_EVT then --有人退桌
        content.check_users = true
        content.check_share_cards = false
        content.check_total_chips = true
    end
    return content
end

--[[
    获取校验字符串
    参数: content, 需要参与校验的数据描述
    返回: 按规则构造的字符串
--]]
function Desk:getMD5CheckString(content)
    --构造规则: 数据块之间用|分隔, 数据块的子项之间用,分隔
    local function addBlockSeparator(str)
        --if string.len(str) > 0 then
            str = str.."|"  --竖线应该都有 
        --end
        return str
    end
    local function addItemSeparator(str)
        if string.len(str) > 0 then
            str = str..","
        end
        return str
    end
    local function addDataSeparator(str)
        if string.len(str) > 0 then
            str = str.."&"
        end
        return str
    end


    --用户数据
    local users_str = ""
    if content.check_users then
        for k, user in pairs(content.users) do
            if user then 
                users_str = addItemSeparator(users_str)..user.uin
                users_str = addDataSeparator(users_str)..user.status
                users_str = addDataSeparator(users_str)..user.chips
                --users_str = addDataSeparator(users_str)..user.round_chips --round_chips暂不校验
            end
        end
    end
    
    --公共牌
    local cards_str = ""
    if content.check_share_cards then
        for k,v in pairs(self._share_cards) do
            cards_str = addDataSeparator(cards_str)..v
        end
    end
    
    --底池筹码
    local total_chips_str = "" 
    if content.check_total_chips and self.total_chips then
        total_chips_str = tostring(self.total_chips)
    end
    
    --构造校验字符串
    local check_str = users_str
    check_str = addBlockSeparator(check_str)..cards_str
    check_str = addBlockSeparator(check_str)..total_chips_str
    return check_str
end

--[[
    判断MD5校验值是否正确
    参数: md5
    返回: true/false
--]]
function Desk:judgeMD5Checksum(cmd, md5, op_uin)
    if (not md5) or (string.len(md5) == 0) then   --服务器未下发MD5,不校验
        return true 
    end
    if self.isGameSettling then     --正在结算中,不校验MD5
        return true
    end

    local strList = string.split(md5, "#")
    local md5_md = strList[1]
    local md5_yuan = strList[2]
    local function doCheck()
        local content = self:getMD5CheckContent(cmd,op_uin)
        local check_str = self:getMD5CheckString(content)
        local value = QNative:shareInstance():md5(check_str)
        local correct = (md5_md == value)
        --local correct = (md5 == check_str)
        if not correct then
            local msg = "[MD5 CHECK FAILED] cmd="..tostring(cmd)
                ..", server="..tostring(md5_md)
                ..", client="..tostring(value)
                ..", client="..tostring(check_str)
                ..", client="..tostring(md5_yuan)
                .."\n"..debug.traceback()
            --game.uploadError(msg) --频繁上传报错会引起内存泄漏，只有测试时才做这样的操作
            loge(msg)
        end
        return correct
    end

    local result = true
    xpcall(
        function()  --try
            result = doCheck()
        end,
        function(msg)   --catch
            result = true   --如果计算校验值过程中出现lua报错，减小影响
        end
    )
    return result
end

return Desk