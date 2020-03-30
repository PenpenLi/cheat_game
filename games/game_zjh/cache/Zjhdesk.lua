local Zjhdesk = class("Zjhdesk")

Zjhdesk._player_info  = {}  --用户信息
Zjhdesk._viewer_info  = {}  --围观用户信息
Zjhdesk.chat          = {}  --用户信息
Zjhdesk.ifFire        = false

Zjhdesk.WINNUM        =0  --连赢数目
Zjhdesk.WINTYPE        = 0  --连赢结果(0：无连胜，1:3连胜，2:5连胜，3:10连胜)
Zjhdesk.ISINPUTREQ        =false  --断线重连不充值连赢 
Zjhdesk.changetable=false
function Zjhdesk:ctor ()
    self.can_operator_arr = {}
    self.now_chips        = 0
end

--入场更新Niuniudesk 数据
function Zjhdesk:updateCacheByInput( model )
    if self["chat"] == nil then
        self["chat"]  = {}
    end

    if model.op_uin==Cache.user.uin then
        self._player_info={}
    end

    self:_updateProps({"view_table","rush_uin","rush_money_now","rush_money","start_time","round_count","base_chip","max_round","max_chips","roomid","op_uin","status","dealer","dealer_seatid","player_op_past_time","deskid","next_uin","total_chips","magic_express_money","can_not_change_table","can_not_chat","wait_num","can_seat_num","first_uin"},model,self)
    local propsTable = {"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","decoration","vip_days","hiding","portrait","is_master","auto_play"}
    if model.view_table==1 and model.is_view==1 and model.op_uin==Cache.user.uin then
        Cache.user.meIndex = 0
    end
    
    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        if model.view_table==1 and model.is_view == 1 and  model.op_uin == u1.uin then
            self._player_info[u1.uin] = nil 
        else
            local u2 = self._player_info[u1.uin] or {}
            self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
            self._player_info[u1.uin]             = u2
            self._player_info[u1.uin].fold        = self._player_info[u1.uin].fold or 0
            self._player_info[u1.uin].user_money  = u1.round_chips --用户当局下注总数
            self._player_info[u1.uin].gold_tmp   = u1.gold
            self._player_info[u1.uin].nick        = Util:showUserName(u2.nick)
            self._player_info[u1.uin].showcard   = 0
            if u2.status == 1050 then
                self._player_info[u1.uin].fold   = 1
            end

            if u2.status == 1045 then
                self._player_info[u1.uin].look   = 1
            else
                self._player_info[u1.uin].look   = false
            end
            --保存用户
            if u1.uin == Cache.user.uin then
                Cache.user.meIndex = u1.seatid or -1
            end
        end
    end

    if model.next_uin == Cache.user.uin then 
        self.can_operator =model.can_operator
        self:getCanOperate()
    end
    self:ifCanFire(model.can_operator)
    if  model.op_uin == Cache.user.uin then
        self["iscompare"]                           = nil
        if model.is_view~=1 or (model.view_table==1 and model.is_view~=1) then
            self._player_info[Cache.user.uin].auto_call = model.chips_all
            self._player_info[Cache.user.uin]["card"]        = {}     
            for j=1,model.card:len() do
                table.insert(self._player_info[Cache.user.uin]["card"],model.card:get(j))
                self._player_info[Cache.user.uin]["card_type"] = model["card_type"]
            end
            self.ismeWait=nil
        end
        self["chip_list"] = {}
        for i =1,model.chip_list:len() do
            table.insert(self["chip_list"],Cache.packetInfo:getProMoney(model.chip_list:get(i)))
        end

        self.now_chips = Cache.packetInfo:getProMoney(model.call_money)   --当前桌子总下注数
        if model.rush_money_now > 0  then 
            self.now_fire_chip = Cache.packetInfo:getProMoney(model.rush_money_now)
            self.now_chips     = Cache.packetInfo:getProMoney(model.rush_money_now)
        end
        self:_updateProps({"rush_diamond","is_view"},model,self)
    end
end

--gamestart
function Zjhdesk:updateCacheByGamestart(model)
    local propsTable = {"status","gold","chips","uin","nick","seatid","sex","round_chips","beauty","b_rank","checked","decoration","vip_days","hiding","portrait","is_master","auto_play"}
    self["iscompare"]                           = nil   --上次是否时比牌 
    for i = 1, model.users:len() do
        local u1 = model.users:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin] = u2

        --初始用户当前的下注数 和 下注总数
        self._player_info[u1.uin]["user_money"] = self.base_chip
        self._player_info[u1.uin]["call_money"] = self.base_chip
        self._player_info[u1.uin]["play"]       = 1
        self._player_info[u1.uin].fold          = 0
        self._player_info[u1.uin]["look"]       = nil
        self._player_info[u1.uin].compare_failed=nil
        self._player_info[u1.uin].compare_win   = nil
    end
    self:_updateProps({"status","max_round","round_count","dealer","next_uin","total_chips","first_uin"},model,self)
    self.now_chips = Cache.packetInfo:getProMoney(self.base_chip)
    if model.next_uin == Cache.user.uin then
        self:_updateProps({"can_operator"},model,self)
        self:getCanOperate()
        self["chip_list"] = {}
        for i =1,model.chip_list:len() do
            table.insert(self["chip_list"],Cache.packetInfo:getProMoney(model.chip_list:get(i)))
        end
    end
    self:ifCanFire(model.can_operator)
end


--user call raise --
function  Zjhdesk:updateCacheByUserraisecall(model)
    self["iscompare"]                           = nil   --上次是否时比牌 
    self:_updateProps({"round_count","next_uin"},model,self)
    self["total_chips"]                               = model["desk_total_chip"]
    self._player_info[model.uin]["user_money"]             = model["user_money"]           --用户总下注金币
    self._player_info[model.uin]["call_money"]             = model["call_money"]           --用户下注金币
    self.call_money  = model["call_money"]
    local rate = 1
    if self._player_info[model.uin].look == 1 then
        rate = 2
    end
    
    if self.ifFire  then
        self._player_info[model.uin]["call_money"]    =     model["rush_money"] 
        self.now_chips = Cache.packetInfo:getProMoney(model["rush_money"])
    else
        self.now_chips = Cache.packetInfo:getProMoney(model["call_money"])
    end
    self._player_info[model.uin].gold                      = self._player_info[model.uin].gold   - self._player_info[model.uin]["call_money"]*rate

    if model.next_uin==Cache.user.uin then
        self.can_operator =model.can_operator
        self:getCanOperate()
    end
    self:ifCanFire(model.can_operator)
end

--user 弃牌 --
function Zjhdesk:updateCacheByUserflod(model)
    self["iscompare"]                           = nil   --上次是否时比牌 
    self:_updateProps({"round_count","next_uin"},model,self)
    self["total_chips"]                         = model["desk_total_chip"]
    self._player_info[model.uin]["user_money"]  = model["user_money"]  --用户总下注金币
    
    self._player_info[model.uin].fold           = 1 
    self._player_info[model.uin].status         = 1050

    self._player_info[model.uin]["card"]        = {} 
    for i=1,model.card:len() do
        table.insert(self._player_info[model.uin]["card"],model.card:get(i))
        self._player_info[model.uin]["card_type"] = model["card_type"]
    end

    if model.next_uin==Cache.user.uin then
        self.can_operator =model.can_operator
        self:getCanOperate()
    end
    self:ifCanFire(model.can_operator)
end

--user  看牌 --
function Zjhdesk:updateCacheByUsercheck(model) 
    self._player_info[model.uin]["card"]      = {}
    
    self._player_info[model.uin]["look"]      = 1
    for i=1,model.card:len() do
        table.insert(self._player_info[model.uin]["card"],model.card:get(i))
    end
    self._player_info[model.uin]["card_type"] = model["card_type"]
    if model.uin == Cache.user.uin then
        self.can_operator =model.can_operator
        self:getCanOperate()
    end
    self:ifCanFire(model.can_operator)
end

--玩家亮牌
function Zjhdesk:updateCacheByLightcard(model)
    local uin =model.uin
    self._player_info[uin]["card"]      = {}

    for i=1,model.card:len() do
        table.insert(self._player_info[uin]["card"],model.card:get(i))
        self._player_info[uin]["card_type"] = model["card_type"]
    end
end


--全场比牌 update
function Zjhdesk:updateCacheByCompareNoLimit(model)
    for i=1,model.userlist:len() do
        local tmp = model.userlist:get(i)
        if tmp ~= model.win_uin then
            self["lost_uin"]  = tmp
        end
    end
    loga("全场比牌长度"..model.userlist:len())
    self["win_uin"] = model.win_uin
    self._player_info[self["lost_uin"]]["card"]      = {}
        
    for i=1,model.card:len() do
        table.insert(self._player_info[self["lost_uin"]]["card"],model.card:get(i))
        self._player_info[self["lost_uin"]]["card_type"] = model["card_type"]
    end

    --就是为了记录是不是开始全桌比牌了
    if self["allcom"] == nil  then
        self["allcom"] = 0
    else
        self["allcom"] = self["allcom"] + 1
    end

end

--user compare --
function Zjhdesk:updateCacheByUsercompare(model)
    self:_updateProps({"round_count","next_uin"},model,self)
    self["iscompare"]                           = 1 
    self["total_chips"]                         = model["desk_total_chip"]

    self._player_info[model.uin]["user_money"]       = self._player_info[model.uin]["user_money"] +   model["user_pay_real_money"]         --用户总下注金币


    self._player_info[model.uin]["call_money"]       = model["user_pay_real_money"]  --用户实际出了多少钱
    self._player_info[model.uin].gold                = self._player_info[model.uin].gold   - model["user_pay_real_money"]
    self["win_uin"]  = model["compare_uin"]
    self["lost_uin"] = model["uin"]

    if model.next_uin==Cache.user.uin then
        self.can_operator =model.can_operator
        self:getCanOperate()
    end
    self:ifCanFire(model.can_operator)

    if model["result"] == 1 then
        self["win_uin"]  = model["uin"]
        self["lost_uin"] = model["compare_uin"]
    end
    self._player_info[self["lost_uin"]].fold  = 1

    self._player_info[self["lost_uin"]]["card"]      = {}
    self._player_info[self["lost_uin"]].compare_failed = 1
    self._player_info[self["win_uin"]].compare_win     = 1


    for i=1,model.card:len() do
        table.insert(self._player_info[self["lost_uin"]]["card"],model.card:get(i))
        self._player_info[self["lost_uin"]]["card_type"] = model["card_type"]
    end
    
    
end

function Zjhdesk:updateCacheByUserFire(model)
    self["iscompare"]                           = nil   --上次是否时比牌 
    self:_updateProps({"round_count","next_uin"},model,self)
    self["total_chips"]                               = model["desk_total_chip"]

    if model.uin==Cache.user.uin then self["rush_diamond"]=model["rush_diamond"] end

    self._player_info[model.uin]["user_money"]             = model["user_money"]           --用户总下注金币
    self._player_info[model.uin]["call_money"]             = model["money"]           --用户下注金币
    local rate = 1
    if self._player_info[model.uin].look == 1 then
        rate = 2
    end
    self._player_info[model.uin].gold                      = self._player_info[model.uin].gold   - model["money"]*rate
    self.now_chips = Cache.packetInfo:getProMoney(model["money"])
    if model.next_uin==Cache.user.uin then
        self.can_operator =model.can_operator
        self:getCanOperate()
    end
    self:ifCanFire(model.can_operator)
    self.now_fire_chip = Cache.packetInfo:getProMoney(model["money"])
end

function Zjhdesk:updateCacheByLookupList(model)
    -- body
    self.view_total=model.view_total
    self._viewer_info={}
    for i = 1, model.view_list:len() do
        local u1 = model.view_list:get(i)
        local user={}
        user.uin=u1.uin
        user.nick=u1.nick
        user.gold=u1.gold
        user.sex=u1.sex
        user.portrait=u1.portrait
        table.insert(self._viewer_info,user)
    end
end

function Zjhdesk:updateCacheByAutoSitWaitNum(model)
    -- body
    self.wait_num=model.wait_num
    self.can_seat_num=model.can_seat_num
end

function Zjhdesk:updateCacheBySitDown(model)
    -- body
    self.wait_num=model.wait_num
    if model.uin==Cache.user.uin then
        if model.error_type == 1 then
            self.ismeWait=true
        else
            self.ismeWait=nil
        end
    end
    --self._player_info[uin]=self._viewer_info[uin]
    --self._viewer_info[uin]=nil
end

function Zjhdesk:updateCacheByStandUp(model)
    -- body
    --self._viewer_info[model.uin]=self._player_info[model.uin]
    self._player_info[model.uin]=nil
    self.wait_num=model.wait_num
    if model.uin==Cache.user.uin then
        self.ismeWait=nil
    end
end



--比赛结束
function Zjhdesk:updateCacheByGameover(model)

    self:_updateProps({"winner","start_time"},model,self)
    for i = 1, model.result:len() do
        local u1 = model.result:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps({"win_money","showcard"},u1,u2)  -- 拷贝user 信息
        --退出协议在结算之前 先判断一下
        if self._player_info[u1.uin] then
            self._player_info[u1.uin]["card"]        = {}   


            u2.gold =  u1.user_money
                

            for j=1,u1.card:len() do
                table.insert(self._player_info[u1.uin]["card"],u1.card:get(j))
                self._player_info[u1.uin]["card_type"] = u1["card_type"]
            end
        loga("游戏结束"..u1.uin.."   "..u1.showcard.."  牌型 "..u1.card:get(1).."   "..u1.card:get(2).."   "..u1.card:get(3))
        end
    end
    self["status"] = 0
    self["iscompare"]                           = nil   --上次是否时比牌 
   
end




function Zjhdesk:_updateProps( propsTable , src,dest )
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



function Zjhdesk:getCanOperate()
    local hand = self.can_operator
    self.can_operator_arr = {}    

    --判断看牌
    if Util:binaryAnd(hand,0x01) == 0x01 then
        self.can_operator_arr['kan'] = 1
    end
    --判断比牌
    if Util:binaryAnd(hand,0x02) == 0x02 then
        self.can_operator_arr['bi'] = 1
    end
    --判断弃牌
    if Util:binaryAnd(hand,0x04) == 0x04 then
        self.can_operator_arr['qi'] = 1
    end
    --判断跟注
    if Util:binaryAnd(hand,0x08) == 0x08 then
        self.can_operator_arr['gen'] = 1
    end
end

function Zjhdesk:ifCanFire(operator)
    -- body
    --判断是否火拼
    if Util:binaryAnd(operator,0x10) == 0x10 then
        self.can_operator_arr['fire'] = 1
        self.ifFire  =  true
    else
        if self.ifFire == true   then
            self.now_chips = self.call_money == nil and 0 or Cache.packetInfo:getProMoney(self.call_money)
        end
        self.ifFire  =  false
        qf.event:dispatchEvent(Zjh_ET.UNFIRE)
    end
end

function Zjhdesk:getUserByUin(uin)
  if self._player_info[uin] then return self._player_info[uin] end
  return nil
end



--其他用户退场 更新Niuniudesk信息
function Zjhdesk:userQuit(model)
    --更新先手
    self:_updateProps({"first_uin"},model,self)
    if model.op_user.uin == Cache.user.uin then
        self:clear()
    else
        if self._player_info[model.op_user.uin] then
            self._player_info[model.op_user.uin] = nil
            self._viewer_info[model.op_user.uin] = nil
        end 
    end
    
end




--用户退场协议 更新数据
function Zjhdesk:updateCacheByUserquit(model)
    self:_updateProps({"next_uin","reason"},model,self)

end


function Zjhdesk:clear()
    for k,v in pairs(self._player_info) do
        if k ~= Cache.user.uin then
            self._player_info[k] = nil
            self._viewer_info[k] = nil
        end
    end
    self.can_seat_num   = nil
    self.ismeWait       = nil
    self.is_view        = nil
    self.wait_num       = nil
    self["total_chips"] = nil
    self["round_count"] = nil
    self["start_time"]  = nil
    self["next_uin"]    = nil
    self["allcom"]      = nil
    self["iscompare"]   = nil
    self.status         = nil
    self.view_table     = nil
    self.is_view        = nil
    self.can_not_change_table = nil
    self.can_not_chat   = nil
end

function Zjhdesk:isSeatHaveUser(_player_info)
    -- body
    for k,v in pairs(self._player_info) do
        if v.seatid==_player_info.seatid and v.uin~=_player_info.uin then
            return true
        end
    end
    return nil
end

function Zjhdesk:refresh()
    for k,v in pairs(self._player_info) do
        self._player_info[k].look            = nil
        self._player_info[k].fold            = 0
        self._player_info[k].chips           = 0
        self._player_info[k].round_chips     = 0
        self._player_info[k].card            = {}
        self._player_info[k].card_type       = nil
        self._player_info[k].auto_call       = nil
        self._player_info[k].draw            = nil
        self._player_info[k].compare_failed  = nil
        self._player_info[k].compare_win     = nil
       -- self._player_info[k].iscpmareWithMe  = nil
        if v.quit == 1 then
            self._player_info[k] = nil
        end
    end
    self["total_chips"] = 0
    self["round_count"] = 0
    self["start_time"]  = nil
    self["next_uin"]    = nil
    self["allcom"]      = nil
    self["iscompare"]   = nil
end



--Niuniudesk chat
function Zjhdesk:updateCacheByChat(model)
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
    if not self.haveLookupChat and model.op_uin~=Cache.user.uin then
        local isplayer
        for k,v in pairs(self._player_info)do
            if k==model.op_uin then
                isplayer=true
                break
            end
        end
        if not isplayer then
            self.haveLookupChat=true
        end
    end
end


function Zjhdesk:getUsersNum()
    local i = 0
    for k,v in pairs(self._player_info) do
        if v ~= nil then
          i = i +1
        end

     end

    return i
end

function Zjhdesk:clearChat()
    -- body
    if self["chat"]~=nil then
        self["chat"]={}
    end
end

function Zjhdesk:checkSelfIsWatching()
    local playerInfo = Cache.zjhdesk._player_info
    return playerInfo[Cache.user.uin] == nil
end

function Zjhdesk:checkMeDown()
    return self._player_info[Cache.user.uin]  ~= nil
end

return Zjhdesk