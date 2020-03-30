local Kandesk  = class("Kandesk")
local calcObjc = import("src.games.game_niuniu.modules.game.components.calc")
Kandesk._player_info  = {}  --用户信息
Kandesk._result_info  = {}  --用户信息
Kandesk.WINNUM        = 0  --连赢数目 
Kandesk.WINTYPE        = 0  --连赢结果(0：无连胜，1:3连胜，2:5连胜，3:10连胜)
Kandesk.ISINPUTREQ        =false  --断线重连不充值连赢 
--入场更新Niuniudesk 数据
function Kandesk:updateCacheByInput( model )
    if self.chat == nil then
        self.chat = {}
    end


    if model.op_uin == Cache.user.uin then
       self.zhuang_uin = model.dealer
    --    self._player_info = {}
    --    self._result_info = {}
    end

    self.play = 1
    local propsTable = {"card_type","status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","decoration","vip_days","hiding","portrait","is_master","auto_play"}
    self:_updateProps({"round_count","can_operator","base_chip","max_round","max_chips","roomid","op_uin","status","dealer","dealer_seatid","player_op_past_time","deskid","next_uin","total_chips"},model,self)
    local table_tmp = {}
    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        table_tmp[u1.uin] = 1
        local card = {}
        for j=1,u1.cards:len() do
            table.insert(card,u1.cards:get(j))
        end
        if #card == 5 then
            card =  calcObjc:rankCards(card)
        end
        --保存用户
        if u1.uin == Cache.user.uin then
            Cache.user.meIndex = u1.seatid or -1
        end
        u2.fold = 0
        u2.user_money = u1.round_chips
        u2.quit = 0
        u2.nick = Util:showUserName(u2.nick)
        u2.card = card
        u2.card_type = u1.card_type
        self._player_info[u1.uin] = u2
    end

    local player_info = {}
    for k, v in pairs(self._player_info) do
        if table_tmp[k] == 1 then
            player_info[k] = v
        end
    end
    self._player_info = player_info
    --剩余时间
    self.left_time = model.left_time
    if model.op_uin == Cache.user.uin then  
        for i=1,model.grab_info:len() do
            local u1 = model.grab_info:get(i)
            self._player_info[u1.uin].grab_score = u1.grab_score
        end

        for i=1,model.call_score_info:len() do
            local u1 = model.call_score_info:get(i)
            self._player_info[u1.uin].callscore_time = u1.callscore_time
        end

        self.grab_score = {}
        for i = 1, model.grab_score:len() do
            local u1 = model.grab_score:get(i)
            table.insert(self.grab_score,model.grab_score:get(i))
        end

        self.call_score_list = {}
        for i = 1, model.call_score_list:len() do
            local u1 = model.call_score_list:get(i)
            table.insert(self.call_score_list,model.call_score_list:get(i))
        end
    end
end

--游戏开始
function Kandesk:updateCacheByGameStart(model)
    self:_updateProps({"status","grab_time"},model,self)

    local propsTable = {"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","decoration","vip_days","hiding","portrait","is_master","auto_play"}

    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin]         = u2
        self._player_info[u1.uin].chips   = 0
        if u1.uin == Cache.user.uin then
            loga("goldgoldgoldgoldgoldgoldgoldgold:"..u1.gold)
        end
    end

    if self._player_info[Cache.user.uin] then
        self._player_info[Cache.user.uin]["card"]        = {}
        for j=1,model.card:len() do
            table.insert(self._player_info[Cache.user.uin]["card"],model.card:get(j))
        end
    end

    self.grab_score = {}
    for i = 1, model.grab_score:len() do
        local u1 = model.grab_score:get(i)
        table.insert(self.grab_score,model.grab_score:get(i))
    end
end

--广播庄
function Kandesk:updateCacheByZhuang(model)
    self.zhuang_uin = model.uin
    self.call_score_time = model.call_score_time

    self.call_score_list = {}
    for i = 1, model.call_score_list:len() do
        local u1 = model.call_score_list:get(i)
         table.insert(self.call_score_list,model.call_score_list:get(i))
    end

    self.user_grab_list     = {}
    table.insert(self.user_grab_list,self.zhuang_uin)
    self.user_grab_list_len = model.user_grab_list:len()
    for i = 1, model.user_grab_list:len() do
        local u1 = model.user_grab_list:get(i)
        if u1 ~= self.zhuang_uin then
          table.insert(self.user_grab_list,u1)
        end
    end
end



--广播用户最后一张牌
function Kandesk:updateCacheByLastCard(model)
  -- body
    self.out_card_time = model.out_card_time
    self.last_card = model.card
    -- print(">>>>>>>>>>>>>>", self._player_info, Cache.user.uin)
    if self._player_info[Cache.user.uin] then
        -- print("XXXXXXXXXXXXXXXXX")
        table.insert(self._player_info[Cache.user.uin]["card"],model.card)

        if #self._player_info[Cache.user.uin]["card"] == 5 then
            self._player_info[Cache.user.uin]["card"] = calcObjc:rankCards(self._player_info[Cache.user.uin]["card"])
        end

        self._player_info[Cache.user.uin]['card_type'] =model.card_type
    end
end


--广播游戏结束
function Kandesk:updateCacheByGameOver(model)
    self._result_info = {}
    self.status = 5
    local propsTable = {"win_money","card_type","uin","user_money"}
    self.playerNum=model.result:len()-1
    
    for i = 1, model.result:len() do

        local u1 = model.result:get(i)
        local u2 = self._result_info[u1.uin] or {}

        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._result_info[u1.uin]         = u2

        self._result_info[u1.uin]["card"]        = {}     
        for j=1,u1.card:len() do
            table.insert(self._result_info[u1.uin]["card"],u1.card:get(j))
        end

        if #self._result_info[u1.uin]["card"] == 5 then
          self._result_info[u1.uin]["card"] = calcObjc:rankCards(self._result_info[u1.uin]["card"])
        end

        self._player_info[u1.uin]['chips'] = self._player_info[u1.uin]['chips'] + u1.win_money

        self._player_info[u1.uin]['chips']  = 0
        if u1.uin == Cache.user.uin then
          loga("u1.user_moneyu1.user_moneyu1.user_moneyu1.user_money:"..u1.user_money)
        end
        self._player_info[u1.uin]['gold']   = u1.user_money
    end


    self.rank = {}
    for k,v in pairs(self._result_info) do
        if k ~= self.zhuang_uin then
            local tmp = {}
            table.insert(tmp,k)
            table.insert(tmp,v.card_type)
            table.insert(self.rank,tmp)
        end
    end



    table.sort(self.rank, function(a,b) 
      return a[2] < b[2]
    end)

    local tmp = {}
    table.insert(tmp,self.zhuang_uin)
    table.insert(tmp,self._result_info[self.zhuang_uin].card_type)
    table.insert(self.rank,tmp)
    self.start_time = model.start_time
    if self._player_info and self._player_info[Cache.user.uin] then
        loga("结束"..self.status.."   "..self._player_info[Cache.user.uin].status)
    end
end


function Kandesk:_updateProps( propsTable , src,dest )
  for k,v in pairs(propsTable) do
    if src[v] ~= nil then
        dest[v] = src[v]
        ----------结算跟随金币改为1：1-------------
        if v == "win_money" then
            dest[v] = Cache.packetInfo:getProMoney(dest[v])
        end
        -----------------------------------------
    end
  end
end


--Niuniudesk chat
function Kandesk:updateCacheByChat(model)
    local content=Util:filterEmoji(model.content or "")
    if content=="" then return end
    local sex = model.gender
    local rightUser = self._player_info[model.op_uin]
    if sex == nil and rightUser then
        sex = rightUser.sex or 0
    end
    local chat_table = {portrait=model.portrait,content=content,uin=model.op_uin,sex = sex}
    local index      = string.sub(model.content,1,1)
    if index ~= "#" and  index ~= "$" and string.len(model.content)>1 then 
        table.insert(self["chat"],chat_table)
    else
        chat_table = {portrait=model.portrait,content=content,uin=model.op_uin,emoji=true,sex = sex}
        table.insert(self["chat"],chat_table)
    end
    if #self["chat"]>20 then
        table.remove(self["chat"],1)
    end
end


function Kandesk:clear()
  -- body
    self._player_info  = {}
    self._result_info  = {}
    self.status        =  nil
end


function Kandesk:getUserByUin(uin)
    if self._player_info[uin] then return self._player_info[uin] end
    return nil
end

function Kandesk:getUsersNum()
    local i = 0
    for k,v in pairs(self._player_info) do
        if v ~= nil then
            i = i +1
        end
    end
    return i
end

function Kandesk:clearChat()
    -- body
    if self["chat"]~=nil then
        self["chat"]={}
    end
end

function Kandesk:checkNeedPlayerJoin()
    if not self:checkGameRunning() and self:getUsersNum() == 1 then
        return true
    end
    return false
end

function Kandesk:checkGameRunning()
    if (self.status ~= 1 and self.status ~= 5 ) then
        return true
    end
    if self.status >= 2 and self.status < 5 then
        return true
    end

    return false
end

function Kandesk:checkUserStatus(uin, status)
    if self._player_info[uin] and self._player_info[uin].status then
        return self._player_info[uin].status == status        
    end
    return false
end

function Kandesk:checkUserReady(uin)
    return self:checkUserStatus(uin, UserStatus.USER_STATE_READY)
end

function Kandesk:checkMeReady()
    return self:checkUserReady(Cache.user.uin)
end

function Kandesk:printStatus(uin)
    if self._player_info and self._player_info[uin] then
        if uin == Cache.user.uin then
            print("自己用户的status:", self._player_info[uin].status)
        else
            print("当前用户的状态 uin ", uin, " status: " , self._player_info[uin].status)
        end 
    end
end

--从_player_info 中删除对应的用户
function Kandesk:updateCacheByStandUp(model)
    self._player_info[model.uin]=nil
    if model.uin==Cache.user.uin then
        self.ismeWait=nil
    end
end

function Kandesk:updateCacheBySitDown(model)
    -- self.wait_num=model.wait_num
    if model.uin==Cache.user.uin then
        if model.error_type == 1 then
            self.ismeWait=true
        else
            self.ismeWait=nil
        end
    end
end

function Kandesk:getMeIndex()
    return Cache.user.meIndex or 0
end

function Kandesk:checkMeDown()
    return self._player_info[Cache.user.uin]  ~= nil
end

return Kandesk

