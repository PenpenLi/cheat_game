local LHDInfo = class("LHDInfo")
LHDInfo.TAG = "LHDInfo"

function LHDInfo:ctor ()
    self.tab_ludan = {}
    self.tab_my_result = {}
    self.tab_rank_win = {} --龙虎斗盈利榜
    self.rank_my = nil --自己的盈利排行信息
    self.chip_list = {} --筹码选择列表
    self.long_num = 0
    self.hu_num = 0
    self.he_num = 0
end

function LHDInfo:updateHistory(m)
    logi("=====>>>LHDInfo:updateHistory" .. pb.tostring(m))
	self.tab_ludan = {}
	self.tab_my_result = {}
    self.long_num = 0
    self.hu_num = 0
    self.he_num = 0
	for i = 1, m.histo:len() do
        local info = m.histo:get(i)
        local section = info["section"]
        self.tab_ludan[i] = info["section"]
        if tonumber(section) == 1 then
            self.long_num  = self.long_num + 1
        end
        if tonumber(section) == 2 then
            self.hu_num  = self.hu_num + 1
        end
        if tonumber(section) == 3 then
            self.he_num  = self.he_num + 1
        end
	end

	for i = 1 , m.user_histo:len() do
        local info = m.user_histo:get(i)
        local my_result = {}
        for j = 1 , info.detail:len() do
            my_result[j] = {}
            local detail = info.detail:get(j)
            self:_updateProps({"section","chips"},detail, my_result[j])
        end
        self.tab_my_result[i] = my_result
    end
end

function LHDInfo:getLongAndHuRate( ... )
    local long_rate, hu_rate = 0, 0
    local long_count, hu_count = 0, 0
    local totalCount = #self.tab_ludan
    local index = 0
    local rateRound = 20
    for i = 1, totalCount do
        local section = self.tab_ludan[i]
        index = index + 1
        if index <= rateRound then
            if tonumber(section) == 1 then
                long_count  = long_count + 1
            end
            if tonumber(section) == 2 then
                hu_count  = hu_count + 1
            end
        else
            break
        end
    end
    long_rate = long_count / rateRound *100
    hu_rate = hu_count / rateRound * 100
    return long_rate == 0 and "0%" or string.format("%d%%", long_rate), hu_rate == 0 and "0%" or string.format("%d%%", hu_rate)
end

function LHDInfo:updateChipList( m )
    -- body
	self.chip_list = {}
    for i=1,m.lhd.bet_list:len() do
        table.insert(self.chip_list, m.lhd.bet_list:get(i))
    end
end

--更新24小时盈利排行榜信息和自己的排行信息
function LHDInfo:updateRankWin(m)
    --盈利排行榜
    self.tab_rank_win = {}
    local infoTable = {"uin","rank","nick","gender","gold","vip_days","portrait"}
    for i=1,m.rank_list:len() do
        self.tab_rank_win[i] = {}
        local info = m.rank_list:get(i)
        self:_updateProps(infoTable, info, self.tab_rank_win[i])
    end
    --排行榜列表中不显示自己
    for i = #self.tab_rank_win,1,-1 do
        if self.tab_rank_win[i].uin == Cache.user.uin then
            table.remove(self.tab_rank_win, i)
        end
    end

    --自己的排行信息
    self.rank_my = {}
    local info = m.my_rank
    self:_updateProps(infoTable, info, self.rank_my)
end

function LHDInfo:updateOthers(m)
    if m ~= nil then logd("无座玩家 "..pb.tostring(m)) end
    self.others = {}
    self.others_count = m.count
    local propsTable = {"uin","nick","gender","chips","portrait","col_portrait"}
    for i = 1 , m.players:len() do
        self.others[i] = {}
        self:_updateProps(propsTable,m.players:get(i),self.others[i])
    end
end

function LHDInfo:updateDelarList(m)
    self.delars = {}
    self.delars_count = m.count
    self.be_delaring = false
    local propsTable = {"uin","nick","gender","chips","gold", "portrait"}
    for i = 1 , m.players:len() do
        local info = m.players:get(i)
        if info.uin == Cache.user.uin then self.be_delaring = true end
        self.delars[i] = {}
        self:_updateProps(propsTable,info,self.delars[i])
    end
end

function LHDInfo:_updateProps( propsTable , src,dest )
    for k,v in pairs(propsTable) do
        dest[v] = src[v]
        ----------结算跟随金币改为1：1-------------
        if v == "chips" then
            dest[v] = Cache.packetInfo:getProMoney(dest[v])
        end
        -----------------------------------------
    end
end

function LHDInfo:getLuDanTab()
    return self.tab_ludan
end

--获取盈利排行榜
function LHDInfo:getRankWinTab()
    return self.tab_rank_win
end

--获取自己的盈利排行信息
function LHDInfo:getMyRankWin()
    return self.rank_my
end

function LHDInfo:addLuDanTab(value)
    table.insert(self.tab_ludan, 1, value)
end

return LHDInfo