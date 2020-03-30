
local LHDDesk = class("LHDDesk")


function LHDDesk:ctor()
    self:clearCache()

    self.name = LHD_MATCHE_TYPE
end

function LHDDesk:clearCache()
    self.roomid = 0
    self.deskid = 0
    self.canBet = false
    self._user = {}
    self._delar = {}
    self.my_total_bets = {} --进房间时的总下注数
    self.total_chips = {}   --进房间时自己的总下注数
    self._all_chips = {} --总下注数
    self._my_chips = {}  --自己的总下注数
end

--更新自己的总下注筹码
function LHDDesk:updateMyBets(m)
    self.my_total_bets = {}
    for k = 1, m.settle:len() do
        local info = m.settle:get(k)
        self.my_total_bets[info.section] = Cache.packetInfo:getProMoney(info.chips)
    end
end

--获取我进房间的下注
function LHDDesk:getMyBets( ... )
    return self.my_total_bets
end

--获取我进房间时底池信息
function LHDDesk:getTotalChips( ... )
    return self.total_chips
end

--获取房间里我的总下注：只有我进房间下注后才有信息
function LHDDesk:getMyChipsRoom( )
    local my_chips = 0
    for i, v in pairs(self._my_chips) do
        my_chips = my_chips + v
    end
    return my_chips
end

--获取房间里下注时的总筹码:服务端下发更新后才有信息
function LHDDesk:getTotalChipsRoom( )
    local all_chips = 0
    for i, v in pairs(self._all_chips) do 
        all_chips = all_chips + v
    end
    return all_chips
end

--更新总下注
function LHDDesk:updateChipsPool(m)
    self.total_chips = {}
    for i = 1 , m.chips_count:len() do
        local allInfo = m.chips_count:get(i)
        self.total_chips[allInfo.section] = self.total_chips[allInfo.section] or {}
        for k = 1,allInfo.count:len() do
            local info = allInfo.count:get(k)
            self.total_chips[allInfo.section][k] = {}
            self.total_chips[allInfo.section][k].count = info.count
            self.total_chips[allInfo.section][k].chips = Cache.packetInfo:getProMoney(info.chips)
        end
    end
end

function LHDDesk:_updateProps( propsTable, src, dest )
    for k,v in pairs(propsTable) do
        if v == "odds" then
            dest[v] = tonumber(src[v])
        else
            if src[v] ~= nil then
                dest[v] = src[v]
            end
        end
    end
end

--update_portrait 是否更新头像
function LHDDesk:updateUser(m, update_portrait)
    update_portrait = update_portrait or false
    self._user = self._user or {}
    self._delar = self._delar or {}
    local propsTable = {}
    if update_portrait == true then
        propsTable = {"gold","chips","uin","nick","seatid","sex","b_rank","decoration","vip_days","hiding","portrait"}
    else
        propsTable = {"gold","chips","uin","nick","seatid","sex","b_rank","decoration","vip_days","hiding"}
    end
    for i = 1,m.users:len() do
        local u = m.users:get(i)
        if u.seatid == 0 then --庄家
            self:_updateProps(propsTable,u,self._delar)
            if u.uin == Cache.user.uin then
                self._user[u.uin] = self._user[u.uin] or {}
                self:_updateProps(propsTable,u,self._user[u.uin])
            end
        else
            self._user[u.uin] = self._user[u.uin] or {}
            self:_updateProps(propsTable,u,self._user[u.uin])
        end
    end
end

function LHDDesk:updateCacheByInput( m )
    self._user = {}
    self._delar = {}
    self:updateMyBets(m.lhd)
    self:updateChipsPool(m.lhd)
    self:updateUser(m, true)

    self.stage = m.lhd.stage
    self.lhd_show_qw_chip = m.lhd.lhd_show_qw_chip --龙虎斗专用，用来控制是否显示千万的筹码，True为显示，False为不显示
    self.time_remain = m.lhd.time_remain
    self.min_bet_carry = m.min_bet_carry
end

--有人上庄的时候
function LHDDesk:updateBrDelarSeat(m)
    
end

function LHDDesk:setStage(stage)
	loga("LHDDesk:setStage "..stage)
    self.stage = stage
end
--bUpdateByFollow  用来监控当前desk值是否已经得到更新
--原因 下注时的显示是纯客户端逻辑 与 服务器无关
function LHDDesk:getUpdateByFollowFlag()
    return self.bUpdateByFollowFlag
end

function LHDDesk:setUpdateByFollowFlag(value)
    self.bUpdateByFollowFlag = value
end

function LHDDesk:updateByBrFllow(m)
    self.br_second_bets = self.br_second_bets or {}
    for i = 1 ,m.bet_info:len() do
        local info = m.bet_info:get(i)
        local propsTable = {"uin","chips","round_chips","bet_chips"}
        self._user[info.uin] = self._user[info.uin] or {}
        
        self:_updateProps(propsTable,info,self._user[info.uin])
        
        self._user[info.uin].counter = {}
        for k = 1, info.counter:len() do
            local countInfo = info.counter:get(k) 
            self._user[info.uin].counter[countInfo.section] = {}
            
            for j = 1 , countInfo.count:len() do
                local chipsInfo = countInfo.count:get(j)
                self._user[info.uin].counter[countInfo.section][chipsInfo.chips] = chipsInfo.count
                if info.uin == Cache.user.uin then
                    self.br_second_bets = self.br_second_bets or {}
                    self.br_second_bets[countInfo.section] = self.br_second_bets[countInfo.section] or {}
                    self.br_second_bets[countInfo.section][chipsInfo.chips] = self.br_second_bets[countInfo.section][chipsInfo.chips] or 0
                    self.br_second_bets[countInfo.section][chipsInfo.chips] = self.br_second_bets[countInfo.section][chipsInfo.chips] + chipsInfo.count
                end
                
            end
            
        end
    end

    if self._user[-1] ~= nil then 
        for i , allInfo in pairs(self._user[-1].counter) do
            for chips, info in pairs(allInfo) do
                if self.br_second_bets[i] ~= nil and self.br_second_bets[i][chips] ~= nil and self._user[Cache.user.uin].seatid == -1 then
                    self._user[-1].counter[i][chips] = self._user[-1].counter[i][chips] - self.br_second_bets[i][chips]
                end
            end
        end 
    end
    
    if m.bet_type == 1 then
        self.br_second_bets = {}
    end
    
end

function LHDDesk:updateCacheBySeatDown(m)
    self._user = self._user or {}
    local propsTable = {
        "gold"
        , "chips"
        , "uin"
        , "nick"
        , "seatid"
        , "sex"
        , "b_rank"
        , "decoration"
        , "vip_days"
        , "hiding"
        , "portrait"
    }
    for i = 1, m.users:len() do
        local u = m.users:get(i)
        self._user[u.uin] = self._user[u.uin] or {}
        self:_updateProps(propsTable,u,self._user[u.uin])
    end
end

function LHDDesk:updateCacheBySeatUp(m)
    self._user = self._user or {}
    if self._user[m.op_user.uin] then
        self._user[m.op_user.uin].seatid = -1
    end
end


--跟新下注时间
function LHDDesk:updateBetTiem(m)
    self.bet_time = m.bet_time
end

--龙虎斗发牌
function LHDDesk:updateShareCards(m)
    self._delar = self._delar or {}
    self._pool = self._pool or {}
    local function getCards(cards,to)
        for i = 1, cards:len() do
            to[i] = cards:get(i)
        end
    end
    for i = 1, m.cards:len() do
        local value = m.cards:get(i)
        self._pool[value.id] = self._pool[value.id] or {}
        self._pool[value.id].cards = {}
        getCards(value.cards,self._pool[value.id].cards)
    end
end

--根据id获取牌型：1龙， 2虎
function LHDDesk:getLhdCardsByCardId(cardid)
    if self._pool and self._pool[cardid] then
        return self._pool[cardid].cards[1]
    else
        return nil
    end
end

--获取玩家列表
function LHDDesk:getUserList( ... )
    return self._user
end
function LHDDesk:getUserByUin( uin )
    return self._user[uin]
end
function LHDDesk:getDelar()
    return self._delar
end
--判断给定的uin是否是庄家
function LHDDesk:isDelarByUin( uin )
    return self._delar and self._delar.uin == uin
end
function LHDDesk:updateDecorationByModel( model )
    local uin = model.uin
    local user_data = self._user[uin]
    if user_data then
        user_data.decoration = model.gift_id
        user_data.col_deco_url = model.col_deco_url
    end
    if uin == self._delar.uin then
        self._delar.decoration = model.gift_id
        self._delar.col_deco_url = model.col_deco_url
    end
end

function LHDDesk:updateUserChipsByUin(uin, chips)
    self._user[uin].chips = chips
end

function LHDDesk:updateDelarList(m)
    self.delars = {}
    self.delars_count = m.count
    self.be_delaring = false
    local propsTable = {"uin","nick","gender","chips","gold"}
    for i = 1 , m.players:len() do
        local info = m.players:get(i)
        if info.uin == Cache.user.uin then self.be_delaring = true end
        self.delars[i] = {}
        self:_updateProps(propsTable,info,self.delars[i])
    end
end

function LHDDesk:updateOthers(m)
    if m ~= nil then logd("无座玩家 "..pb.tostring(m)) end
    self.others = {}
    self.others_count = m.count
    local propsTable = {"uin","nick","gender","chips","portrait","col_portrait"}
    for i = 1 , m.players:len() do
        self.others[i] = {}
        self:_updateProps(propsTable,m.players:get(i),self.others[i])
    end
end

function LHDDesk:updateHistory(m)
    self.history = {}
    for i = 1 , m.histo:len() do
        local info = m.histo:get(i)
        local history = {}
        for j = 1 , info.detail:len() do
            history[j] = {}
            local detail = info.detail:get(j)
            self:_updateProps({"section","odds"},detail,history[j])
        end
        self.history[i] = history
    end
end

--更新用户简要信息
function LHDDesk:updateProfile(model)
    if model.uin == nil then return end
    local user_data = self._user[model.uin]

    if user_data then
        user_data.nick = Util:showUserName(model.nick)
        user_data.portrait = model.portrait
        user_data.col_portrait = model.col_portrait
    end

    if self._delar then
        self._delar.nick = Util:showUserName(model.nick)
        self._delar.portrait = model.portrait
        self._delar.col_portrait = model.col_portrait
    end
end

--龙虎斗结算
function LHDDesk:updateCacheByGameOver(m)
    -- loga("===========>>>>>>\n" .. pb.tostring(m))
    self.time_remain = m.time_remain
    self._result = {}
    self.self_result = {}
    self.br_result_count = {}
    self.other_result = {}
    self._delar = self._delar or {}
    self.lhd_total_result = {}

    self:updateMyBets(m.my_total_bets)


    local m_retCount = self.br_result_count
    m_retCount.myself = 0
    m_retCount.delar = 0
    local m_myBets = self.my_total_bets

    local function insToTab( dest, src )
        dest = dest or {}
        table.insert(dest, src)
        return dest
    end

    for i = 1 ,m.settle:len() do
        local uin = m.settle:get(i).uin 
        local settle = m.settle:get(i).settle
        for j = 1,settle:len() do
            local result = settle:get(j)
            local _section = result.section
            local _chips = Cache.packetInfo:getProMoney(result.chips)
            local _ret = {
                uin = uin
                , odds = tonumber(result.odds)
                , chips = _chips
            }
            self._result[_section] = insToTab(self._result[_section], _ret)
            if uin == Cache.user.uin then
                self.self_result[_section] = _ret
                m_retCount.myself = m_retCount.myself or 0
                local chip = _chips <= 0 and _chips - m_myBets[_section] 
                    or _chips - m_myBets[_section] 
                m_retCount.myself = m_retCount.myself + chip 
            end
            if uin == self._delar.uin then
                m_retCount.delar = m_retCount.delar or 0
                m_retCount.delar = m_retCount.delar + Cache.packetInfo:getProMoney(_chips)
            end
            if uin == -1 then
                self.other_result[_section] = _ret
            end
        end
    end

    for k, v in pairs(self._result) do
        for index , value in pairs(v) do
            if value.uin ~= -1 and value.uin ~= self._delar.uin  then
                self.other_result[k].chips = self.other_result[k].chips - value.chips
            end 
        end
    end
    
    self:updateUser(m, false)



    --大路图和路单
    self._win_card_id = tonumber(m.section)
    Cache.lhdinfo:addLuDanTab(self._win_card_id)

    --龙虎斗彩池
    local function insToTab( dest, src )
        dest = dest or {}
        table.insert(dest, src)
        return dest
    end

    for i=1,m.total_result:len() do
        local result = m.total_result:get(i)
        self.lhd_total_result[result.uin] = result.chips
    end
end

function LHDDesk:getLhdWinCardId()
    --获取获胜区域String "1"龙 "2"虎 "3"和
    return self._win_card_id
end

function LHDDesk:checkTenMillionBtnEnable()
    return self.lhd_show_qw_chip
end

--更新上庄与下庄限制
function LHDDesk:setShangZhuangLimit(m)
    self.min_banker = m.lhd.min_banker 
    self.min_pool_banker = m.lhd.min_poor_bank
    --新增最大上庄次数
    self.maxBankerSitTimes = m.lhd.banker_max_sit_times
end

--获取服务器下注时间
function LHDDesk:getServerBetTime( ... )
    return 18
end

--获取客户端实际下注时间
function LHDDesk:getClientBetTime( ... )
    return 15
end

--更新是否可以下注
function LHDDesk:updateCanBeBet(canBet)
    self.canBet = canBet
end

--获取是否可以下注状态
function LHDDesk:getCanBetStatus( ... )
    return self.canBet
end

--判定是否已经下注
function LHDDesk:checkXiaZhu()
    local brMyBet = self.my_total_bets
    local sum = 0
    for k, v in pairs(brMyBet) do
        sum = sum + v
    end
    return sum > 0
end

return LHDDesk