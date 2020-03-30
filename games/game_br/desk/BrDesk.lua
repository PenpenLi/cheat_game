--[[
    百人场牌桌缓存
--]]
local BrDesk = class("BrDesk")


BrDesk.br_info = {}
BrDesk.br_user = {}
BrDesk.br_all_chips = {} --百人场下注的总数
BrDesk.br_my_chips = {} --自己下的注

function BrDesk:ctor ()
    self.name = BRC_MATCHE_TYPE
    self:clearCache()
end

function BrDesk:clearCache()
    self.roomid = 0
    self.deskid = 0
    self.br_info = {}
    self.br_user = {}
    self.br_all_chips = {} --百人场下注的总数
    self.br_my_chips = {} --自己下的注
end

--[[--
EvtDeskUserEnter 更新cache
]]
function BrDesk:updateCacheByBrInput( m )
    self.br_user = {}
    self.br_delar = {}
    self:updateBrTotalBets(m.br)
    self:updateBrUser(m, true)
    self:updateBrChipsPool(m.br)
    self:updateBrAddChipsInfo(m.br)
    self.min_bet_carry = m.min_bet_carry
end

function BrDesk:updateBrAddChipsInfo(model)
    self.maxOdds = model.max_odds --赔率
    self.is_blow_up = model.is_blow_up
    if self.is_blow_up == nil then self.is_blow_up = 0 end
    self.addChipList = {}
    self.addChipList2 = {}
    self.minChipValue = Cache.packetInfo:getProMoney(model.bet_list2_use_min)
    -- self.minChipValue = model.bet_list2_use_min/GameConstants.RATE
    self.maxBankerSitTimes = model.banker_max_sit_times
    for i=1,model.bet_list:len() do
        local bet = model.bet_list:get(i)
        self.addChipList[i] = Cache.packetInfo:getProMoney(bet) --百人筹码跟随金币改为1：1
    end
    for i = 1, model.bet_list2:len() do
        local bet = model.bet_list2:get(i)
        self.addChipList2[i] = Cache.packetInfo:getProMoney(bet)
    end
    self.min_banker = model.min_banker or 50000000  --最低上庄金额
    self.min_poor_bank = model.min_poor_bank or 20000000 --低于多少钱下庄

    local defaultChipList = self.addChipList
    if self:judgeBrUseChipList2() then
        defaultChipList = self.addChipList2
    end


    local defaultChoice = 0
    if model.bet_choiced then
        defaultChoice = model.bet_choiced
    end
    self.bet_choiced = defaultChipList[defaultChoice + 1]
end

function BrDesk:updateBrInfo(model)
    local propsTable = {"stage","time_remain"}
    self:_updateProps(propsTable,model,self.br_info)
end

function BrDesk:_updateProps( propsTable , src,dest )
  for k,v in pairs(propsTable) do
    dest[v] = src[v]
  end
end

--百人场发牌
function BrDesk:updateBrShareCards(m)
    self.br_sharecards = {}
    self.br_delar = self.br_delar or {}
    self.br_pool = self.br_pool or {}
    local function getCards(cards,to)
        for i = 1, cards:len() do
            to[i] = cards:get(i)
        end
    end
    getCards(m.share_cards,self.br_sharecards)
    for i = 1, m.cards:len() do
        local value = m.cards:get(i)
        if value.type == 2 then --庄家
            self.br_delar.cards = {}
            self.br_delar.card_type = value.card_type
            getCards(value.cards,self.br_delar.cards)
        else
            self.br_pool[value.id] = self.br_pool[value.id] or {}
            self.br_pool[value.id].cards = {}
            self.br_pool[value.id].card_type = value.card_type
            getCards(value.cards,self.br_pool[value.id].cards)
        end
    end
end

--有人上庄的时候
function BrDesk:updateBrDelarSeat(m)
    
end

--跟新下注时间
function BrDesk:updateBetTiem(m)
    self.bet_time = m.bet_time
end


--message EvtBRBetInfo {
--    message BetInfo {
--        optional int32 uin = 1;
--        optional int64 chips=2; //下注之后，用户拥有的筹码
--        optional int64 round_chips=3;  //自己在本轮总下注的额度
--        optional int64 bet_chips=4;
--        repeated SecChipsCounter counter = 5;
--    }
--    repeated BetInfo bet_info = 1;
--    repeated SecChipsCounter total_chips = 2;  //  这个区域的下注总数
--    optional int32 bet_type = 3;  // 0是实时转发，1是定时转发
--}
function BrDesk:updateByBrFllow(m)
    self.br_second_bets = self.br_second_bets or {}
    for i = 1 ,m.bet_info:len() do
        local info = m.bet_info:get(i)
        local propsTable = {"uin","chips","round_chips","bet_chips"}
        self.br_user[info.uin] = self.br_user[info.uin] or {}
        
        self:_updateProps(propsTable,info,self.br_user[info.uin])
        
        self.br_user[info.uin].counter = {}
        for k = 1, info.counter:len() do
            local countInfo = info.counter:get(k) 
            self.br_user[info.uin].counter[countInfo.section] = {}
            
            for j = 1 , countInfo.count:len() do
                local chipsInfo = countInfo.count:get(j)
                self.br_user[info.uin].counter[countInfo.section][chipsInfo.chips] = chipsInfo.count
                if info.uin == Cache.user.uin then
                    self.br_second_bets = self.br_second_bets or {}
                    self.br_second_bets[countInfo.section] = self.br_second_bets[countInfo.section] or {}
                    self.br_second_bets[countInfo.section][chipsInfo.chips] = self.br_second_bets[countInfo.section][chipsInfo.chips] or 0
                    self.br_second_bets[countInfo.section][chipsInfo.chips] = self.br_second_bets[countInfo.section][chipsInfo.chips] + chipsInfo.count
                end
                
            end
        end
    end
    
    if self.br_user[-1] ~= nil then 
        for i , allInfo in pairs(self.br_user[-1].counter) do
            for chips, info in pairs(allInfo) do
                if self.br_second_bets[i] ~= nil and self.br_second_bets[i][chips] ~= nil and self.br_user[Cache.user.uin].seatid == -1 then
                    self.br_user[-1].counter[i][chips] = self.br_user[-1].counter[i][chips] - self.br_second_bets[i][chips]
                end
            end
        end 
    end
    
    if m.bet_type == 1 then
        self.br_second_bets = {}
    end
    self.is_blow_up = m.is_blow_up
end

function BrDesk:updateBrSitUser(m)
    self.br_user = self.br_user or {}
    local propsTable = {"gold","chips","uin","nick","seatid","sex","beauty","b_rank", "decoration", "vip_days", "hiding", "portrait"}
    for i = 1, m.users:len() do
        local u = m.users:get(i)
        self.br_user[u.uin] = self.br_user[u.uin] or {}
        self:_updateProps(propsTable,u,self.br_user[u.uin])
    end
end

function BrDesk:updateBrSitUserBySomeoneLeave(m)
    local someoneUin = m.uin
    self.br_user = self.br_user or {}
    if self.br_user[someoneUin] then
        self.br_user[someoneUin].seatid = -1
    end
end

function BrDesk:updateBrSitDelar(m)
    self:updateBrUser(m, true)
end

--message EvtBRGameOver {
--    optional int32 time_remain = 1;  // 空闲时间
--    repeated GameUserInfo users=2;
--    message SettleResult {
--        optional int32 uin = 1;          // -1 表示其他人
--        message SettleDetail {
--            optional int32 section = 1;  // 下注区域
--            optional int32 odds = 2;     // 庄家<-->天地玄黄之间的赔率, 正数为天地玄黄胜, 负数为庄家胜。
--            optional int64 chips = 3;    // 这个区域输赢的筹码
--        }
--        repeated SettleDetail settle = 2;  // 区域结算
--    }
--    repeated SettleResult settle = 3;
--}
function BrDesk:updateByBrOver(m)
    -- loga(" -- BrDesk:updateByBrOver --" .. pb.tostring(m))
    self.br_info.time_remain = m.time_remain
    self.br_result = {}
    self.self_result = {}
    self.br_result_count = {}
    self.other_result = {}
    self.br_delar = self.br_delar or {}
    self.br_sit_users = {} --在座玩家
    self.br_totle_result = {}

    self:updateBrTotalBets(m.my_total_bets)

    local m_retCount = self.br_result_count
    m_retCount.myself = 0
    m_retCount.delar = 0
    local m_myBets = self.br_my_bets

    local function insToTab( dest, src )
        dest = dest or {}
        table.insert(dest, src)
        return dest
    end

    for i = 1 ,m.settle:len() do
        local uin = m.settle:get(i).uin
        local seatid = m.settle:get(i).seatid
        local settle = m.settle:get(i).settle
        for j = 1,settle:len() do
            local result = settle:get(j)
            local _section = result.section
            local _chips = result.chips
            local _ret = {
                uin = uin
                , odds = result.odds
                , chips = _chips
                , seatid = seatid
            }
            self.br_result[_section] = insToTab(self.br_result[_section], _ret)
            if uin == -1 then
                self.other_result[_section] = _ret
            else
                if uin == Cache.user.uin then
                    self.self_result[_section] = _ret
                    m_retCount.myself = m_retCount.myself or 0
                    local chip = _chips - m_myBets[_section]
                    m_retCount.myself = m_retCount.myself + chip 
                end
                if uin == self.br_delar.uin then
                    m_retCount.delar = m_retCount.delar or 0
                    m_retCount.delar = m_retCount.delar + _chips
                end
            end
        end
    end

    for i = 1 ,m.users:len() do
        local user = m.users:get(i)
        self.br_sit_users[user.uin] = {}
        self.br_sit_users[user.uin].uin = user.uin
        self.br_sit_users[user.uin].chips = user.chips
        self.br_sit_users[user.uin].nick = user.nick
        self.br_sit_users[user.uin].seatid = user.seatid
        self.br_sit_users[user.uin].sex = user.sex
        self.br_sit_users[user.uin].portrait = user.portrait
    end
    
    for k, v in pairs(self.br_result) do
        for index , value in pairs(v) do
            if value.uin ~= -1 and value.uin ~= self.br_delar.uin  then
                self.other_result[k].chips = self.other_result[k].chips - value.chips
            end 
        end
    end

    for i=1,m.total_result:len() do
        local result = m.total_result:get(i)
        self.br_totle_result[result.uin] = result.chips
    end

    self:updateBrUser(m, false)
end

function BrDesk:getMyAndDelarWinChips()
    local myself , delar = 0, 0
    myself = self.br_result_count.myself
    if Cache.user.uin == self.br_delar.uin then
        myself = -self.br_result_count.delar
    end
    delar = -self.br_result_count.delar
    return myself, delar
end

function BrDesk:getWinChipsByUin(uin)
    local winChips = 0
    if not self.br_result then return winChips end
    for k,v in pairs(self.br_result) do
        if #v > 0 then
            for kk,vv in pairs(v) do
                if vv.uin == uin then
                    -- 如果是庄家 那么就 odds < 0 表示赚钱  odds > 0 表示输钱 反之正好相反
                    if uin == self.br_delar.uin then
                        if vv.odds < 0 then --庄家赢钱
                            local chips = math.abs(vv.chips)
                            winChips = winChips + chips
                        else --庄家输钱
                            local chips = math.abs(vv.chips)
                            winChips = winChips - chips   
                        end
                    else
                        if vv.odds < 0 then --庄家赢钱
                            local chips = math.abs(vv.chips)
                            winChips = winChips - chips
                        else
                            local chips = math.abs(vv.chips)
                            winChips = winChips + chips
                        end                        
                    end
                end
            end
        end
    end
    return winChips
end

--判断玩家是赢还是输
function BrDesk:getPlayerPoolAreaResult(index, targetUin)
    if not self.br_result then return -1 end
    for k,v in pairs(self.br_result) do
        if index == k then
            for kk,vv in pairs(v) do
                local uin = vv.uin
                if uin == targetUin then
                    if targetUin == self.br_delar.uin then
                        return vv.odds < 0
                    end
                    return vv.odds > 0
                end
            end
        end
    end
end

function BrDesk:getGameResultForSpecial()
    local tp = 1
    local ts = 1
    for _,settle in pairs(self.br_result) do
        for _,subSettle in pairs(settle) do
            if subSettle.odds > 0 then
                ts = 0
            end
            if subSettle.odds < 0 then
                tp = 0
            end
        end
    end
    return tp , ts
end

function BrDesk:updateBrTotalBets(m)
    self.br_my_bets = {}
    for k = 1, m.settle:len() do
        local info = m.settle:get(k)
        self.br_my_bets[info.section] = info.chips
    end
end
--update_portrait 是否更新头像
function BrDesk:updateBrUser(m, update_portrait)
    logd("----updateBrUser-----")
    update_portrait = update_portrait or false
    self.br_user = self.br_user or {}
    self.br_delar = self.br_delar or {}
    local propsTable = {}
    if update_portrait == true then
    	propsTable = {"chips","uin","nick","seatid","sex","beauty","b_rank","decoration","vip_days","hiding","portrait"}
    else
    	propsTable = {"chips","uin","nick","seatid","sex","beauty","b_rank","decoration","vip_days","hiding"}
    end
    for i = 1,m.users:len() do
        local u = m.users:get(i)
        if u.seatid == 0 then
            self:_updateProps(propsTable,u,self.br_delar)
            if u.uin == Cache.user.uin then
                self.br_user[u.uin] = self.br_user[u.uin] or {}
                self:_updateProps(propsTable,u,self.br_user[u.uin])
            end
        else
            self.br_user[u.uin] = self.br_user[u.uin] or {}
            self:_updateProps(propsTable,u,self.br_user[u.uin])
        end
    end
end

function BrDesk:updateBrChipsPool(m)
    local propsTable = {"section"}
    self.br_chips_count = {}
    for i = 1 , m.chips_count:len() do
        local allInfo = m.chips_count:get(i)
        self.br_chips_count[allInfo.section] = self.br_chips_count[allInfo.section] or {}
        for k = 1,allInfo.count:len() do
            local info = allInfo.count:get(k)
            self.br_chips_count[allInfo.section][k] = {}
            self.br_chips_count[allInfo.section][k].count = info.count
            self.br_chips_count[allInfo.section][k].chips = info.chips
        end
    end
end

--百人场判断是否是vip用户
function BrDesk:judegeBrIsVip(uin)
	if self.br_user[uin] == nil or self.br_user[uin].vip_days == nil or self.br_user[uin].vip_days <= 0 then
		return false
	else
		return true
	end
end
--百人场判断是否处于隐身状态
function BrDesk:judegeBrIsHiding(uin)
	local user = self.br_user[uin]
	if user == nil or user.vip_days == nil or user.hiding == nil then return false end
	if user.vip_days > 0 and user.hiding == 1 then
		return true
	else
		return false
	end
end

--判断是否适用第二套chiplist
function BrDesk:judgeBrUseChipList2()

    if self.br_user[Cache.user.uin] and  self.br_user[Cache.user.uin].chips then
        local myMoney = Cache.packetInfo:getProMoney(self.br_user[Cache.user.uin].chips)
        -- local myMoney = self.br_user[Cache.user.uin].chips/GameConstants.RATE
        return myMoney > self.minChipValue
    end
    return false
end

--判定是否已经下注
function BrDesk:checkXiaZhu()
    local brMyBet = self.br_my_bets
    local sum = 0
    for k, v in pairs(brMyBet) do
        sum = sum + v
    end
    return sum > 0
end
return BrDesk