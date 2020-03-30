local BeautyInfo = class("BeautyInfo")

BeautyInfo.TAG = "BeautyInfo"

function BeautyInfo:updateRB(model)--最新认证
	if model ~= nil then logd("最新认证美女: \n"..pb.tostring(model)) end
    local filename = {
        "uin",
        "nick",
        "portrait"
    }
    self[1] = {}
    if model == nil or model.beauties:len() == 0 then self[1] = nil
    else
        for i = 1,model.beauties:len() do
            self[1][i] = {}
            self:copyFiled(filename,model.beauties:get(i),self[1][i])
        end
    end
end

function BeautyInfo:updateLWR(model)--上周排行数据
	if model ~= nil then logd("美女上周排行: \n"..pb.tostring(model)) end
    local filename = {
        "rank",
        "uin",
        "nick",
        "gift_gold",
        "gender",
        "vip_days",
        "portrait"
    }
    self[2] = {}
    if model == nil or model.rank_list:len() == 0 then
    	self[2] = nil
    	return
    else
        for i = 1,model.rank_list:len() do
             self[2][i] = {}
            self:copyFiled(filename,model.rank_list:get(i),self[2][i])
        end
    end

      self.last_week_list={}
        for i = 1,#self[2] do
            self.last_week_list[i] = {}
            self:copyFiled(filename,self[2][i],self.last_week_list[i])
        end

     if model==nil or model.my_rank==nil  or Cache.user.is_beauty==false   then return  end
    -- dump(model.my_rank)
     self.my_lw_rank={}
     self:copyFiled(filename,model.my_rank,self.my_lw_rank)
     table.insert(self.last_week_list,1,self.my_lw_rank)

      --[[ for i = 2,#self.last_week_list do
           if  self.last_week_list[i].uin==self.my_lw_rank.uin then
              table.remove(self.last_week_list,i)
              break
           end
        end--]]

   

end

function BeautyInfo:updateTWR(model)--本周排行数据
	if model ~= nil then logd("美女本周排行: \n"..pb.tostring(model)) end
    local filename = {
        "rank",
        "uin",
        "nick",
        "gift_gold",
        "vip_days",
        "portrait"
    }
    self[3] = {}
    if model == nil or model.rank_list:len() == 0 then self[3] = {}
    else
        for i = 1,model.rank_list:len() do
            self[3][i] = {}
            self:copyFiled(filename,model.rank_list:get(i),self[3][i])
        end
    end

        self.this_week_list={}
        for i = 1,#self[3] do
            self.this_week_list[i] = {}
            self:copyFiled(filename,self[3][i],self.this_week_list[i])
        end

     if model==nil or model.my_rank==nil  or Cache.user.is_beauty==false then return  end
     --dump(model.my_rank)
     self.my_tw_rank={}
     self:copyFiled(filename,model.my_rank,self.my_tw_rank)
    table.insert(self.this_week_list,1,self.my_tw_rank)

   --[[ for i = 2,#self.this_week_list do
           if  self.this_week_list[i].uin==self.my_tw_rank.uin then
              table.remove(self.this_week_list,i)
              break
           end
        end--]]
   

end

function BeautyInfo:clearInfo()
    for i = 1, 3 do
        self[i] = nil
    end
end

function BeautyInfo:copyFiled(p,s,d)
    for k,v in pairs(p) do
        if type(v) == "table" then
            d[k] = {}
            self:copyFiled(v,s[k],d[k])
        else
            d[v] = s[v]
        end    
    end
end

function BeautyInfo:saveRewardConf(model)--上周奖励配置
    self.rewardConf = {}
    if model == nil or model.rewards:len() == 0 then 

    else
        for i = 1,model.rewards:len() do

              local info={} 
              local data=model.rewards:get(i)  
               info.rank=data.rank
              info.gold=data.gold
            table.insert(self.rewardConf,#self.rewardConf+1,info)
        end
    end
end
return BeautyInfo