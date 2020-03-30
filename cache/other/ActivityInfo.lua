--活动
local ActivityInfo = class("ActivityInfo")

ActivityInfo.TAG = "ActivityInfo"
ActivityInfo.BONUS_ID_1 = 17  --春节红包活动ID
ActivityInfo.BONUS_ID_2 = 18  --春节红包活动ID

--测试用
--ActivityInfo.BONUS_ID_1 = 7  --春节红包活动ID
--ActivityInfo.BONUS_ID_2 = 9  --春节红包活动ID

function ActivityInfo:ctor() 
    self.all_activity = {}
    self.all_notice = {}
end

function ActivityInfo:refreshData(model)
    self.all_activity = {}
	if model == nil or model.activities == nil then return end
    local items = {"id", "title", "content", "image_url", "page_url", "end_time", "reward_id", "can_pick",
                "show_board", "board_url", "board_type"}
    for i = 1, model.activities:len() do
        local item = {}
        local data = model.activities:get(i)
        for k,v in pairs(items) do
            item[v] = data[v]
        end
        self.all_activity[i] = item
    end
end

--获取春节红包活动的URL
function ActivityInfo:getBonusUrl()
    if self.all_activity == nil then return nil end
    local url = nil
    for k, v in pairs(self.all_activity) do

        if v.id == ActivityInfo.BONUS_ID_1 or v.id == ActivityInfo.BONUS_ID_2 then
            url = v.page_url
        end
    end
    return url
end

function ActivityInfo:refreshNoticeData(model)
    self.all_notice = {}
    if model == nil or model.sys_notice_list == nil then return end
    local items = {"use_flag", "title", "notice_title", "notice_text", "broad_user", "broad_time", "index"}
    local tempNoticeArr = {}
    for i = 1, model.sys_notice_list:len() do
        local item = {}
        local data = model.sys_notice_list:get(i)
        for k,v in pairs(items) do
            item[v] = data[v]
        end
        --启用才可以
        if item.use_flag == 2 then
            local xitem = {index = item.index, item = item}
            tempNoticeArr[#tempNoticeArr + 1] = xitem
        end
    end
    table.sort(tempNoticeArr, function (a, b)
        return a.index < b.index
    end)
    for i, v in ipairs(tempNoticeArr) do
        self.all_notice[i] = v.item
    end
end

return ActivityInfo