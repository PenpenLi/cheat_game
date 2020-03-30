local RewardInfo = class("RewardInfo")

RewardInfo.TAG = "Reward"

RewardInfo.number = 0 --未领取任务奖励的任务个数
RewardInfo.rewardList = {} --成就奖励

function RewardInfo:updateInfo(model)
    local filedname = {
        "status",
        "desc",
        "id",
        "gold",
        "title",
        "condition",
        "image_url",
        "progress",
        "task_type"
    }
    self.number = 0
    local day_num = 0
    local sys_num = 0
    self.rewardList.day_task_list = {}
    self.rewardList.sys_task_list = {}
    for i = 1 ,model.day_task_list:len() do
        self.rewardList.day_task_list[i] = {}
        self:copyFiled(filedname,model.day_task_list:get(i),self.rewardList.day_task_list[i])
        if model.day_task_list:get(i).status == 1 then
            self.number = self.number + 1 
            day_num = day_num + 1
        end
        logd("日常任务["..self.rewardList.day_task_list[i].id.."] "..self.rewardList.day_task_list[i].title..", status="..self.rewardList.day_task_list[i].status..", progress="..self.rewardList.day_task_list[i].progress, "TimeBox")
    end
    for i = 1 ,model.sys_task_list:len() do
        self.rewardList.sys_task_list[i] = {}
        self:copyFiled(filedname,model.sys_task_list:get(i),self.rewardList.sys_task_list[i])
        if model.sys_task_list:get(i).status == 1 then 
            self.number = self.number + 1 
            sys_num = sys_num + 1 
        end
    end
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="prize",number=self.number})
    day_num = day_num + (isover == true and 1 or 0)
    if day_num == 0 and sys_num >0 then
        qf.event:dispatchEvent(ET.REWARD_SORT_CHECK)
    end
end

function RewardInfo:taskFinishChangeStatus(paras)
    if paras == nil or paras.id == nil or paras.type == nil then return end 
    Cache.RewardInfo.number = Cache.RewardInfo.number == 0 and 0 or Cache.RewardInfo.number - 1
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="prize",number=Cache.RewardInfo.number})
    if paras.type == "other" then return end
    if paras.type == "day" then
        if self.rewardList.day_task_list then
            for i = 1, #self.rewardList.day_task_list do
                if self.rewardList.day_task_list[i].id == paras.id then
                    self.rewardList.day_task_list[i].status = 2
                end
            end
        end
    elseif paras.type == "sys" then
        if self.rewardList.sys_task_list then
            for i = 1, #self.rewardList.sys_task_list do
                if self.rewardList.sys_task_list[i].id == paras.id then
                    self.rewardList.sys_task_list[i].status = 2
                end
            end
        end
    end
end

function RewardInfo:clearInfo()
    self.rewardList = {}
end

function RewardInfo:copyFiled(p,s,d)
    for k,v in pairs(p) do
        d[v] = s[v]
    end
end

return RewardInfo