local RankInfo = class("RankInfo")

RankInfo.TAG = "RankInfo"

RankInfo._rankCache = {}


function RankInfo:copyList(filedList,model,key,is_master_credit) --大师分的 数组名字是 ranks  不是 rank_list
    self._rankCache[key] = {}
    if model == nil then return end
    local rank_list
    if is_master_credit== true then rank_list=model.ranks else rank_list=model.rank_list end
    local bMine = false
    for i = 1, rank_list:len() do
        self._rankCache[key][i] = {}
        self:copyFiled(filedList,rank_list:get(i),self._rankCache[key][i])
        if self._rankCache[key][i].uin == Cache.user.uin then
            bMine = true
        end
    end
    if not bMine then
        local intl = #self._rankCache[key]+1
        self._rankCache[key][intl] = {}
        self:copyFiled(filedList, model.my_rank,self._rankCache[key][intl])
        self._rankCache[key][intl].noBar = true
        if  rank_list:len()==0  then self._rankCache[key][intl].noBar = false  end --如果排行榜是空的  自己就是上榜的
    end
end
function RankInfo:updateFriendWeekList(model,key)--好友周战绩榜 数据
	if model ~= nil then logd("好友周战绩榜:\n"..pb.tostring(model)) end
    local filename = {
        "win_times",
        "nick",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end


function RankInfo:updateWorldWeekList(model,key)--世界排名周战绩榜 数据
	if model ~= nil then logd("世界排名周战绩榜:\n"..pb.tostring(model)) end
    local filename = {
        "win_times",
        "nick",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:updateFriendWeekWinList(model,key)--好友排名周盈利榜 数据
	if model ~= nil then logd("好友排名周盈利榜:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "win_gold",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:updateWorldWeekWinList(model,key)--世界排名周盈利榜数据
	if model ~= nil then logd("世界排名周盈利榜数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "win_gold",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:getRankByKey( key )
    return self._rankCache[key]
end

function RankInfo:updateFriendDayWinList(model,key)--好友排名日单局榜数据
	if model ~= nil then logd("好友排名日单局榜数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "single_win_gold",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:updateWorldDayWinList(model,key)--世界排名日单局榜数据
	if model ~= nil then logd("世界排名日单局榜数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "single_win_gold",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:updateFriendGoldList(model,key)--好友排名财富榜数据
	if model ~= nil then logd("好友排名财富榜数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "rank",
        "gold",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:updateWorldGoldList(model,key)--世界排名财富榜数据
	if model ~= nil then logd("世界排名财富榜数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "rank",
        "gold",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:updateFriendMasterCreditList(model,key)--好友排名竞技分榜 数据
    if model ~= nil then logd("好友排名大师分榜 数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "gold",
        "value",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key,true)
end

function RankInfo:updateWorldMasterCreditList(model,key)--世界排名竞技分榜数据
    if model ~= nil then logd("世界排名大师分榜数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "gold",
        "value",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key,true)
end

function RankInfo:updateFriendDayMasterCreditList(model,key)--好友周排名竞技分榜 数据
    if model ~= nil then logd("好友日排名大师分榜 数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "gold",
        "value",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key,true)
end

function RankInfo:updateWorldDayMasterCreditList(model,key)--世界排名周竞技分榜数据
    if model ~= nil then logd("世界日排名大师分榜数据:\n"..pb.tostring(model)) end
    local filename = {
        "nick",
        "gold",
        "value",
        "rank",
        "uin",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key,true)
end

function RankInfo:getMyScoreRank()--我的积分排名数据
    return self.myScoreRank
end

function RankInfo:updateMyScoreRank(model)--我的积分排名数据
	if model ~= nil then logd("我的积分排名数据:\n"..pb.tostring(model)) end
    local filename = {
        "rank",
        "uin",
        "nick",
        "uin",
        "value",
        "gold",
        "gender",
        "vip_days",
        "portrait"
    }
    self.myScoreRank = {}
    self:copyFiled(filename,model,self.myScoreRank)
end

function RankInfo:updateScoreList(model,key)--积分排名数据
	if model ~= nil then logd("积分排名数据:\n"..pb.tostring(model)) end
    local filename = {
        "rank",
        "uin",
        "nick",
        "uin",
        "value",
        "gold",
        "gender",
        "vip_days",
        "portrait"
    }
    self:copyList(filename,model,key)
end

function RankInfo:clearInfo()
    self._rankCache = {}
end

function RankInfo:copyFiled(p,s,d)
    for k,v in pairs(p) do
        if type(v) == "table" then
            d[k] = {}
            self:copyFiled(v,s[k],d[k])
        else
            d[v] = s[v]
        end    
    end
end

return RankInfo