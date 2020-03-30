local GameChest = class("GameChest")

GameChest.TAG = "GameChest"

function GameChest:updateInfo(paras)
    if paras == nil or paras.model == nil then Cache.GameChestList = nil Cache.chest = false return end
    local modle = paras.model
    logd("牌局内任务信息: "..pb.tostring(paras.model), "TimeBox")
    Cache.GameChestList = {}
    Cache.chest = false
    for i=1,modle.done_task_list:len() do
        local chestInfo2 = modle.done_task_list:get(i)
        if chestInfo2 and chestInfo2.task_id==TIMEBOX_TASK_ID_STR then
            local chsetInfo1={}
            local chestInfo2 = modle.done_task_list:get(i)
            chsetInfo1.task_id = chestInfo2.task_id
            chsetInfo1.task_type = chestInfo2.task_type
            chsetInfo1.task_status = chestInfo2.task_status
            chsetInfo1.progress = chestInfo2.progress
            chsetInfo1.condition = chestInfo2.condition
            chsetInfo1.desc = chestInfo2.desc
            chsetInfo1.gold = chestInfo2.gold
            Cache.GameChestList[#Cache.GameChestList+1] = chsetInfo1
            if chsetInfo1.task_id==TIMEBOX_TASK_ID_STR then
                Cache.chest = Cache.chest or chsetInfo1.task_status == 1
            end
        -- else
        --     break
        end
    end
    for i=1,modle.undone_task_list:len() do
        local chestInfo2 = modle.undone_task_list:get(i)
        if chestInfo2 and chestInfo2.task_id==TIMEBOX_TASK_ID_STR then
            local chsetInfo1={}
            chsetInfo1.task_id = chestInfo2.task_id
            chsetInfo1.task_type = chestInfo2.task_type
            chsetInfo1.task_status = chestInfo2.task_status
            chsetInfo1.progress = chestInfo2.progress
            chsetInfo1.condition = chestInfo2.condition
            chsetInfo1.desc = chestInfo2.desc
            chsetInfo1.gold = chestInfo2.gold
            Cache.GameChestList[#Cache.GameChestList+1] = chsetInfo1
        -- else
        --     break
        end
    end
    Cache.timebox_index = paras.model.box_index
    --logd("更新牌桌内任务数据完毕. Cache.chest="..tostring(Cache.chest)..", 计时宝箱更新: ",Cache.Config.box_index,"==>"..Cache.timebox_index, "TimeBox")
end

function GameChest:existTimeboxTask()
	if Cache.timebox_index == nil then Cache.timebox_index  = -1 end
	if Cache.GameChestList == nil then Cache.timebox_index  = -1 end
	return Cache.Config:judgeTimeboxIndexCorrect(Cache.timebox_index)
end

return GameChest